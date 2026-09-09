package com.personnel.system.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.system.entity.SysUser;

public interface SysUserService extends IService<SysUser> {

    SysUser login(String username, String password);

    Page<SysUser> pageQuery(Page<SysUser> page, String username, Integer status);

    void resetPassword(Long id);

    void register(SysUser user);

    void approve(Long id);

    void reject(Long id);

    void bindCadre(Long userId, Long cadreId);

    void unbindCadre(Long userId);

    /** 修改用户类型（1-6），校验类型合法性 */
    void updateUserType(Long userId, Integer userType);

    /**
     * 计算用户"生效模块权限"（不落库，仅用于返回给前端），全系统唯一口径：
     * 系统管理员(userType=1)返回 ALL；用户级 permissions 非空则取该覆盖；
     * 否则回退为用户类型内置默认模板（见 UserTypePermTemplate，不再读取 sys_user_role / sys_role）。
     */
    String resolveEffectivePermissions(SysUser user);
}
