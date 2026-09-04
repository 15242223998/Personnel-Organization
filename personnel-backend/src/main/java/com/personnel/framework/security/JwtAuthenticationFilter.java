package com.personnel.framework.security;

import jakarta.annotation.Resource;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * JWT 认证过滤器：解析 Authorization: Bearer <token>，
 * 校验通过后向 SecurityContext 注入认证信息
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String TOKEN_PREFIX = "Bearer ";

    @Resource
    private JwtUtil jwtUtil;

    @Resource
    private UserDetailsServiceImpl userDetailsServiceImpl;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String authHeader = request.getHeader("Authorization");
        if (StringUtils.hasText(authHeader) && authHeader.startsWith(TOKEN_PREFIX)) {
            String token = authHeader.substring(TOKEN_PREFIX.length());
            if (StringUtils.hasText(token) && SecurityContextHolder.getContext().getAuthentication() == null) {
                try {
                    String username = jwtUtil.getUsername(token);
                    if (StringUtils.hasText(username)) {
                        LoginUser loginUser = (LoginUser) userDetailsServiceImpl.loadUserByUsername(username);
                        // 校验 token 归属 + 账号可用状态，任一不满足则视为未认证
                        if (jwtUtil.validateToken(token, loginUser.getUsername()) && loginUser.isEnabled()) {
                            UsernamePasswordAuthenticationToken authentication =
                                    new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
                            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                            SecurityContextHolder.getContext().setAuthentication(authentication);
                        }
                    }
                } catch (Exception e) {
                    // token 无效/过期/用户不存在，清除上下文按匿名处理，由 Security 入口返回 401
                    SecurityContextHolder.clearContext();
                }
            }
        }
        filterChain.doFilter(request, response);
    }
}
