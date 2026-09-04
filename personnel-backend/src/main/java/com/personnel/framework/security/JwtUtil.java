package com.personnel.framework.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * JWT 令牌工具：生成、解析、校验
 */
@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    /** 过期时间（毫秒），默认 24 小时 */
    @Value("${jwt.expiration:86400000}")
    private Long expiration;

    private SecretKey getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 生成 token
     */
    public String generateToken(Long userId, String username) {
        Date now = new Date();
        Date expireDate = new Date(now.getTime() + expiration);
        return Jwts.builder()
                .subject(username)
                .claim("userId", userId)
                .issuedAt(now)
                .expiration(expireDate)
                .signWith(getKey())
                .compact();
    }

    /**
     * 从 token 解析用户名，无效/过期则抛出异常
     */
    public String getUsername(String token) {
        return parseClaims(token).getSubject();
    }

    /**
     * 从 token 解析用户 ID
     */
    public Long getUserId(String token) {
        Object userId = parseClaims(token).get("userId");
        if (userId instanceof Integer) {
            return ((Integer) userId).longValue();
        }
        return userId == null ? null : Long.valueOf(userId.toString());
    }

    /**
     * 校验 token 是否有效且属于指定用户
     */
    public boolean validateToken(String token, String username) {
        Claims claims = parseClaims(token);
        return claims.getSubject().equals(username);
    }

    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
