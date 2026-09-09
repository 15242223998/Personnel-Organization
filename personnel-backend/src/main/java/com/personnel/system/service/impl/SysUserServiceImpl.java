package com.personnel.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.framework.security.JwtUtil;
import com.personnel.system.UserTypePermTemplate;
import com.personnel.system.entity.SysUser;
import com.personnel.system.mapper.SysUserMapper;
import com.personnel.system.service.SysUserService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {

    @Resource
    private JwtUtil jwtUtil;

    @Override
    public SysUser login(String username, String password) {
        SysUser user = getOne(new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, username));
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        if (!user.getPassword().equals(password)) {
            throw new BusinessException("用户名或密码错误");
        }
        Integer status = user.getStatus();
        String info = buildUserInfo(user);
        if (status != null && status == 0) {
            throw new BusinessException(4001, info + "该账户还未审核，请联系系统管理员");
        }
        if (status != null && status == 2) {
            throw new BusinessException(4002, info + "该账号的申请已经被回绝");
        }
        if (status != null && status == 3) {
            throw new BusinessException(4003, info + "该账号已被禁用");
        }
        user.setLastLoginTime(LocalDateTime.now());
        updateById(user);
        // 登录成功签发 JWT
        user.setToken(jwtUtil.generateToken(user.getId(), user.getUsername()));
        // 不回传密码；permissions 返回"生效权限"（用户级覆盖优先，空则回退用户类型内置模板）
        user.setPassword(null);
        user.setPermissions(resolveEffectivePermissions(user));
        return user;
    }

    private String buildUserInfo(SysUser user) {
        return "账号：" + user.getUsername()
                + "，姓名：" + (user.getRealName() == null ? "" : user.getRealName())
                + "，手机号：" + (user.getPhone() == null ? "" : user.getPhone())
                + "。";
    }

    @Override
    public Page<SysUser> pageQuery(Page<SysUser> page, String username, Integer status) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(username)) {
            wrapper.like(SysUser::getUsername, username);
        }
        if (status != null) {
            wrapper.eq(SysUser::getStatus, status);
        }
        wrapper.orderByDesc(SysUser::getCreateTime);
        return page(page, wrapper);
    }

    @Override
    public void resetPassword(Long id) {
        SysUser user = getById(id);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setPassword("123456");
        updateById(user);
    }

    @Override
    public void register(SysUser user) {
        if (!StringUtils.hasText(user.getUsername()) || !StringUtils.hasText(user.getPassword())) {
            throw new BusinessException("用户名和密码不能为空");
        }
        long count = count(new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, user.getUsername()));
        if (count > 0) {
            throw new BusinessException("用户名已存在");
        }
        user.setId(null);
        user.setStatus(0);
        if (user.getUserType() == null) {
            user.setUserType(6);
        }
        save(user);
    }

    @Override
    public void approve(Long id) {
        SysUser user = getById(id);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setStatus(1);
        updateById(user);
    }

    @Override
    public void reject(Long id) {
        SysUser user = getById(id);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setStatus(2);
        updateById(user);
    }

    @Override
    public void bindCadre(Long userId, Long cadreId) {
        SysUser user = getById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        long bound = count(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getCadreId, cadreId)
                .ne(userId != null, SysUser::getId, userId));
        if (bound > 0) {
            throw new BusinessException("该干部档案已绑定其他用户");
        }
        user.setCadreId(cadreId);
        updateById(user);
    }

    @Override
    public void unbindCadre(Long userId) {
        SysUser user = getById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setCadreId(null);
        updateById(user);
    }

    @Override
    public void updateUserType(Long userId, Integer userType) {
        if (userType == null || userType < 1 || userType > 6) {
            throw new BusinessException("用户类型取值不合法");
        }
        SysUser user = getById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setUserType(userType);
        updateById(user);
    }

    @Override
    public String resolveEffectivePermissions(SysUser user) {
        if (user == null || user.getId() == null) {
            return "";
        }
        // 系统管理员全通（不落库，仅返回值）
        if (user.getUserType() != null && user.getUserType() == 1) {
            return UserTypePermTemplate.ALL;
        }
        // 用户级权限覆盖优先（非空即视为管理员已单独授权）
        if (StringUtils.hasText(user.getPermissions())) {
            return user.getPermissions();
        }
        // 回退：用户类型内置默认模板（不再读取 sys_user_role / sys_role）
        String template = UserTypePermTemplate.templateOf(user.getUserType());
        return template == null ? "" : template;
    }
}
