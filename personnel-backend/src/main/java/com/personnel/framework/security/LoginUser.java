package com.personnel.framework.security;

import com.personnel.system.entity.SysUser;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

/**
 * Spring Security 登录用户主体：封装系统用户与角色权限
 */
public class LoginUser implements UserDetails {

    private final SysUser user;

    private final Collection<? extends GrantedAuthority> authorities;

    public LoginUser(SysUser user, Collection<? extends GrantedAuthority> authorities) {
        this.user = user;
        this.authorities = authorities;
    }

    public SysUser getUser() {
        return user;
    }

    public Long getUserId() {
        return user.getId();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        return user.getUsername();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        // 仅"已批准(1)"状态可访问
        return user.getStatus() != null && user.getStatus() == 1;
    }
}
