package com.personnel.framework.qrlogin;

import com.personnel.common.Result;
import com.personnel.framework.cache.CacheStore;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 扫码登录控制器（演示用）：一次性登录票据在内存缓存中同步，跨设备真实生效。
 *
 * <p>票据值形如 {@code admin|waiting}：竖线前为申请登录的账号，竖线后为状态
 * （waiting/confirmed/rejected）。票据不携带密码，账号仅用于手机端确认页展示。
 * 三个接口均无需登录（SecurityConfig 已放行 /api/qr-login/**）。</p>
 */
@RestController
@RequestMapping("/api/qr-login")
public class QrLoginController {

    /** 票据缓存 key 前缀 */
    private static final String KEY_PREFIX = "qrlogin:";
    /** 账号维度缓存 key 前缀（电脑按账号轮询，扫码/刷新导致票据变化也能对上） */
    private static final String ACCT_PREFIX = "qrlogin:acct:";
    /** 票据有效期（秒） */
    private static final long TTL_SECONDS = 180L;

    private static final String STATUS_WAITING = "waiting";
    private static final String STATUS_CONFIRMED = "confirmed";
    private static final String STATUS_REJECTED = "rejected";

    @Resource
    private CacheStore cacheStore;

    /** 生成一次性登录票据：body {"account":"admin"}（account 可省略，默认 admin） */
    @PostMapping("/ticket")
    public Result<Map<String, Object>> createTicket(@RequestBody(required = false) Map<String, String> body) {
        String account = body == null ? null : body.get("account");
        if (account == null || account.trim().isEmpty()) {
            account = "admin";
        }
        String ticket = UUID.randomUUID().toString().replace("-", "");
        cacheStore.set(KEY_PREFIX + ticket, account + "|" + STATUS_WAITING, TTL_SECONDS);
        // 同时登记账号维度状态：电脑端按账号轮询，扫码/刷新二维码不会错过手机确认
        cacheStore.set(ACCT_PREFIX + account, account + "|" + STATUS_WAITING, TTL_SECONDS);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("ticket", ticket);
        data.put("account", account);
        data.put("expireSeconds", TTL_SECONDS);
        return Result.success(data);
    }

    /**
     * 查询登录状态：GET /status?ticket=xxx&account=admin
     * 传了 account 则按账号维度查询（推荐，避免票据变更导致错过确认）；否则按 ticket 查询。
     * 缓存无 key 一律视为 expired。
     */
    @GetMapping("/status")
    public Result<Map<String, Object>> status(@RequestParam(value = "ticket", required = false) String ticket,
                                              @RequestParam(value = "account", required = false) String account) {
        Map<String, Object> data = new LinkedHashMap<>();
        String cached = null;
        if (account != null && !account.trim().isEmpty()) {
            cached = cacheStore.get(ACCT_PREFIX + account.trim());
        }
        if (cached == null && ticket != null && !ticket.isEmpty()) {
            cached = cacheStore.get(KEY_PREFIX + ticket);
        }
        if (cached == null) {
            data.put("status", "expired");
            data.put("account", account);
            return Result.success(data);
        }
        int idx = cached.indexOf('|');
        data.put("account", idx >= 0 ? cached.substring(0, idx) : cached);
        data.put("status", idx >= 0 ? cached.substring(idx + 1) : STATUS_WAITING);
        return Result.success(data);
    }

    /** 手机端确认/拒绝：body {"ticket":"xxx","action":"confirm"|"reject"} */
    @PostMapping("/confirm")
    public Result<Map<String, Object>> confirm(@RequestBody Map<String, String> body) {
        String ticket = body == null ? null : body.get("ticket");
        String action = body == null ? null : body.get("action");
        String cached = (ticket == null || ticket.isEmpty()) ? null : cacheStore.get(KEY_PREFIX + ticket);
        if (cached == null) {
            return Result.error("二维码已失效，请刷新");
        }
        int idx = cached.indexOf('|');
        String account = idx >= 0 ? cached.substring(0, idx) : cached;
        String status = idx >= 0 ? cached.substring(idx + 1) : STATUS_WAITING;
        // 已决定过（confirmed/rejected）则幂等返回当前状态，不再改写
        if (STATUS_WAITING.equals(status)) {
            status = "reject".equalsIgnoreCase(action) ? STATUS_REJECTED : STATUS_CONFIRMED;
            cacheStore.set(KEY_PREFIX + ticket, account + "|" + status, TTL_SECONDS);
            // 同步账号维度状态，保证电脑端（按账号轮询）能立刻感知
            cacheStore.set(ACCT_PREFIX + account, account + "|" + status, TTL_SECONDS);
        }
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("account", account);
        data.put("status", status);
        return Result.success(data);
    }
}
