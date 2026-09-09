package com.personnel.framework.cache;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 缓存门面配置（前缀 app.cache），对应 application.yml：
 * <pre>
 * app:
 *   cache:
 *     backend: auto   # auto=有 Redis 用 Redis，连接失败自动降级进程内存；memory=强制仅用内存
 * </pre>
 *
 * 降级设计：有 Redis 用 Redis，没有 Redis 自动内存兜底。
 */
@Component
@ConfigurationProperties(prefix = "app.cache")
public class CacheProperties {

    /** 强制仅使用进程内存，完全不触碰 Redis */
    public static final String BACKEND_MEMORY = "memory";

    /** 后端模式：auto=先尝试 Redis（失败自动降级内存）；memory=强制仅用内存（默认 auto，即默认即可直接跑） */
    private String backend = "auto";

    public String getBackend() {
        return backend;
    }

    public void setBackend(String backend) {
        this.backend = backend;
    }

    /** 是否强制仅用内存模式 */
    public boolean isMemoryOnly() {
        return backend != null && BACKEND_MEMORY.equalsIgnoreCase(backend.trim());
    }
}
