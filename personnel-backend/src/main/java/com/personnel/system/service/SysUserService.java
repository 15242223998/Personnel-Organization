package com.personnel.system.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.system.entity.SysUser;

public interface SysUserService extends IService<SysUser> {

    SysUser login(String username, String password);

    Page<SysUser> pageQuery(Page<SysUser> page, String username, Integer status);

    void resetPassword(Long id);
}
