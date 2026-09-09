package com.personnel.framework.security;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.personnel.system.entity.SysUser;
import com.personnel.system.mapper.SysUserMapper;
import jakarta.annotation.Resource;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

/**
 * 基于数据库加载登录用户。
 *
 * <p>权限来源已收敛为「用户类型内置模板 + 用户级覆盖」（见 com.personnel.system.UserTypePermTemplate），
 * 不再读取 sys_user_role / sys_role 计算权限；仅系统管理员(userType=1)映射 ROLE_ADMIN
 * 以兼容历史角色编码，其余账号不再持有 Spring 角色权限（当前后端鉴权只依赖 JWT 登录态，
 * 模块权限由前端按生效 permissions 拦截）。</p>
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Resource
    private SysUserMapper sysUserMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        SysUser user = sysUserMapper.selectOne(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, username));
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在：" + username);
        }
        List<GrantedAuthority> authorities = loadAuthorities(user);
        return new LoginUser(user, authorities);
    }

    private List<GrantedAuthority> loadAuthorities(SysUser user) {
        if (user.getUserType() != null && user.getUserType() == 1) {
            return Collections.singletonList(new SimpleGrantedAuthority("ROLE_ADMIN"));
        }
        return Collections.emptyList();
    }
}
