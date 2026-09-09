package com.personnel.framework.cache;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;
import java.util.function.Function;

/**
 * 缓存门面 CacheStore —— 降级设计：有 Redis 用 Redis，没有 Redis 自动内存兜底。
 *
 * <p>后端模式由 {@link CacheProperties}（application.yml 的 app.cache.backend）决定：</p>
 * <ul>
 *   <li>{@code auto}（默认）：优先走 Redis，key 真实落在 Redis；
 *       执行任一次 Redis 命令抛异常（无 Redis/连接被拒/超时）时，打印一次 warn 并永久切换为进程内存，
 *       后续请求直接走内存、不再反复连接 Redis，保证无 Redis 的机器不卡顿、功能完全不变。</li>
 *   <li>{@code memory}：强制仅使用进程内存（ConcurrentHashMap + 过期时间，惰性过期），线程安全。</li>
 * </ul>
 *
 * <p>StringRedisTemplate 通过 {@link ObjectProvider} 延迟获取、到真正执行第一条 Redis 命令前才创建，
 * 且 Lettuce 连接本身是懒建立的，因此机器没有 Redis 时 bean 创建与应用启动都不会报错。</p>
 */
@Slf4j
@Component
public class CacheStore {

    /** 内存后端（进程内单例，永不降级） */
    private final MemoryBackend memoryBackend = new MemoryBackend();

    private final CacheProperties properties;
    private final ObjectProvider<StringRedisTemplate> redisTemplateProvider;

    /** 当前是否走 Redis；auto 模式初始为 true，首次 Redis 异常后原子切换为 false（volatile 保证可见） */
    private volatile boolean redisActive;
    /** 降级 warn 只打印一次 */
    private final AtomicBoolean fallbackLogged = new AtomicBoolean(false);
    /** Redis 后端延迟创建（无 Redis 机器不触发创建） */
    private volatile RedisBackend redisBackend;

    public CacheStore(CacheProperties properties,
                      ObjectProvider<StringRedisTemplate> redisTemplateProvider) {
        this.properties = properties;
        this.redisTemplateProvider = redisTemplateProvider;
        this.redisActive = !properties.isMemoryOnly();
        if (properties.isMemoryOnly()) {
            log.info("[cache] 缓存后端 = memory（app.cache.backend=memory，强制进程内存，不连接 Redis）");
        } else {
            log.info("[cache] 缓存后端 = auto（app.cache.backend=auto，优先 Redis，失败自动降级为进程内存）");
        }
    }

    /** 读取字符串值；key 不存在或已过期返回 null */
    public String get(String key) {
        return run(backend -> backend.get(key));
    }

    /** 写入字符串值并设置过期时间（秒）；ttlSeconds &lt;= 0 表示不过期 */
    public void set(String key, String value, long ttlSeconds) {
        run(backend -> {
            backend.set(key, value, ttlSeconds);
            return null;
        });
    }

    /** 删除 key */
    public void delete(String key) {
        run(backend -> {
            backend.delete(key);
            return null;
        });
    }

    /**
     * 对 key 原子自增并返回自增后的值；key 不存在时首次从 1 开始计数并设置 ttl 秒过期（不续期）。
     * 用于登录失败次数统计等场景。
     */
    public long increment(String key, long ttlSeconds) {
        return run(backend -> backend.increment(key, ttlSeconds));
    }

    /** 读取整数值；key 不存在或内容非数字时返回 defaultValue */
    public long getLong(String key, long defaultValue) {
        String v = get(key);
        if (v == null) {
            return defaultValue;
        }
        try {
            return Long.parseLong(v.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * 统一执行入口：Redis 模式任一命令抛异常 → 打印一次 warn → 切内存，并在内存上重放本次命令，
     * 保证降级瞬间的这一次调用也能正常返回（功能不中断）。
     */
    private <T> T run(Function<CacheBackend, T> action) {
        if (!redisActive) {
            return action.apply(memoryBackend);
        }
        try {
            return action.apply(redisBackend());
        } catch (RuntimeException ex) {
            if (fallbackLogged.compareAndSet(false, true)) {
                log.warn("Redis 不可用（{}），缓存已自动降级为进程内存模式（降级设计：有 Redis 用 Redis，"
                        + "没有 Redis 自动内存兜底，后续请求直接走内存、不再连接 Redis，项目无需部署 Redis 即可完整运行）", ex.toString());
            }
            redisActive = false;
            return action.apply(memoryBackend);
        }
    }

    /** 延迟创建 Redis 后端：StringRedisTemplate 通过 ObjectProvider 获取，避免无 Redis 环境 bean 创建即抛错 */
    private RedisBackend redisBackend() {
        RedisBackend backend = redisBackend;
        if (backend == null) {
            synchronized (this) {
                if (redisBackend == null) {
                    StringRedisTemplate template = redisTemplateProvider.getIfAvailable();
                    if (template == null) {
                        // 理论不会发生（starter 在 classpath 时会自动装配 StringRedisTemplate）；抛异常由 run 捕获并降级
                        throw new IllegalStateException("StringRedisTemplate Bean 不存在，无法使用 Redis 缓存");
                    }
                    redisBackend = new RedisBackend(template);
                }
                backend = redisBackend;
            }
        }
        return backend;
    }

    /** 后端抽象：Redis / 进程内存各一份实现 */
    private interface CacheBackend {
        String get(String key);

        void set(String key, String value, long ttlSeconds);

        void delete(String key);

        long increment(String key, long ttlSeconds);
    }

    /** Redis 后端：内部用 StringRedisTemplate（字符串 key/value，与内存实现语义一致） */
    private static class RedisBackend implements CacheBackend {

        private final StringRedisTemplate template;

        RedisBackend(StringRedisTemplate template) {
            this.template = template;
        }

        @Override
        public String get(String key) {
            return template.opsForValue().get(key);
        }

        @Override
        public void set(String key, String value, long ttlSeconds) {
            if (ttlSeconds <= 0) {
                template.opsForValue().set(key, value);
            } else {
                template.opsForValue().set(key, value, ttlSeconds, TimeUnit.SECONDS);
            }
        }

        @Override
        public void delete(String key) {
            template.delete(key);
        }

        @Override
        public long increment(String key, long ttlSeconds) {
            Long v = template.opsForValue().increment(key);
            // 首次自增（返回 1）时设置 TTL，之后不续期：过期窗口从第一次失败起算，锁定期即 15 分钟
            if (v != null && v == 1L && ttlSeconds > 0) {
                template.expire(key, ttlSeconds, TimeUnit.SECONDS);
            }
            return v == null ? 0L : v;
        }
    }

    /** 进程内存后端：ConcurrentHashMap + 过期时间，惰性过期，线程安全 */
    private static class MemoryBackend implements CacheBackend {

        private final ConcurrentHashMap<String, Entry> map = new ConcurrentHashMap<>();

        @Override
        public String get(String key) {
            Entry e = map.get(key);
            if (e == null) {
                return null;
            }
            if (isExpired(e)) {
                map.remove(key, e);
                return null;
            }
            return e.value;
        }

        @Override
        public void set(String key, String value, long ttlSeconds) {
            map.put(key, new Entry(value, expireAt(ttlSeconds)));
        }

        @Override
        public void delete(String key) {
            map.remove(key);
        }

        @Override
        public long increment(String key, long ttlSeconds) {
            final long now = System.currentTimeMillis();
            final long newEntryExpireAt = expireAt(ttlSeconds);
            AtomicLong holder = new AtomicLong();
            // ConcurrentHashMap.compute 对同一 key 原子执行（串行化），保证并发自增不丢失
            map.compute(key, (k, old) -> {
                long base;
                long expireAt;
                if (old == null || isExpired(old, now)) {
                    base = 0L;
                    expireAt = newEntryExpireAt;   // 首次（或已过期重开）：从 1 计数，起算 TTL
                } else {
                    base = parseLong(old.value);
                    expireAt = old.expireAtMillis; // 已有计数：保持原过期时间，不续期
                }
                long v = base + 1;
                holder.set(v);
                return new Entry(Long.toString(v), expireAt);
            });
            return holder.get();
        }

        private static boolean isExpired(Entry e) {
            return isExpired(e, System.currentTimeMillis());
        }

        private static boolean isExpired(Entry e, long now) {
            return e.expireAtMillis <= now;
        }

        private static long expireAt(long ttlSeconds) {
            if (ttlSeconds <= 0) {
                return Long.MAX_VALUE;
            }
            return System.currentTimeMillis() + ttlSeconds * 1000L;
        }

        private static long parseLong(String v) {
            try {
                return Long.parseLong(v);
            } catch (NumberFormatException e) {
                return 0L;
            }
        }
    }

    /** 内存缓存条目：值 + 过期毫秒时间戳（惰性过期） */
    private static final class Entry {
        final String value;
        final long expireAtMillis;

        Entry(String value, long expireAtMillis) {
            this.value = value;
            this.expireAtMillis = expireAtMillis;
        }
    }
}
