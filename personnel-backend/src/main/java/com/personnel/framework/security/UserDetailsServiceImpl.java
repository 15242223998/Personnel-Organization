package com.personnel.framework.security;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.personnel.system.entity.SysRole;
import com.personnel.system.entity.SysUser;
import com.personnel.system.entity.SysUserRole;
import com.personnel.system.mapper.SysRoleMapper;
import com.personnel.system.mapper.SysUserMapper;
import com.personnel.system.mapper.SysUserRoleMapper;
import jakarta.annotation.Resource;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 基于数据库加载登录用户及其角色权限
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Resource
    private SysUserMapper sysUserMapper;

    @Resource
    private SysUserRoleMapper sysUserRoleMapper;

    @Resource
    private SysRoleMapper sysRoleMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        SysUser user = sysUserMapper.selectOne(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, username));
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在：" + username);
        }
        List<GrantedAuthority> authorities = loadAuthorities(user.getId());
        return new LoginUser(user, authorities);
    }

    /**
     * 通过用户-角色关联表加载角色编码，转换为 ROLE_XXX 权限
     */
    private List<GrantedAuthority> loadAuthorities(Long userId) {
        List<SysUserRole> userRoles = sysUserRoleMapper.selectList(
                new LambdaQueryWrapper<SysUserRole>().eq(SysUserRole::getUserId, userId));
        if (userRoles == null || userRoles.isEmpty()) {
            return Collections.emptyList();
        }
        List<Long> roleIds = userRoles.stream()
                .map(SysUserRole::getRoleId)
                .filter(id -> id != null)
                .distinct()
                .collect(Collectors.toList());
        if (roleIds.isEmpty()) {
            return Collections.emptyList();
        }
        List<SysRole> roles = sysRoleMapper.selectBatchIds(roleIds);
        if (roles == null || roles.isEmpty()) {
            return Collections.emptyList();
        }
        return roles.stream()
                .filter(r -> r.getStatus() != null && r.getStatus() == 1)
                .filter(r -> r.getRoleCode() != null)
                .map(r -> new SimpleGrantedAuthority("ROLE_" + r.getRoleCode().toUpperCase()))
                .collect(Collectors.toList());
    }
}
