package com.personnel.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.SysUser;
import com.personnel.system.service.SysUserService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/api/user")
public class SysUserController {

    @Resource
    private SysUserService sysUserService;

    @PostMapping("/login")
    public Result<SysUser> login(@RequestBody SysUser user) {
        return Result.success(sysUserService.login(user.getUsername(), user.getPassword()));
    }

    @PostMapping("/register")
    public Result<Void> register(@RequestBody SysUser user) {
        sysUserService.register(user);
        return Result.success();
    }

    @PutMapping("/register/{id}/approve")
    public Result<Void> approve(@PathVariable Long id) {
        sysUserService.approve(id);
        return Result.success();
    }

    @PutMapping("/register/{id}/reject")
    public Result<Void> reject(@PathVariable Long id) {
        sysUserService.reject(id);
        return Result.success();
    }

    @GetMapping("/page")
    public Result<PageResult<SysUser>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Integer status) {
        Page<SysUser> page = new Page<>(current, size);
        return Result.success(PageResult.of(sysUserService.pageQuery(page, username, status)));
    }

    @PostMapping
    public Result<Void> create(@RequestBody SysUser user) {
        sysUserService.save(user);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SysUser user) {
        sysUserService.updateById(user);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        sysUserService.removeById(id);
        return Result.success();
    }

    @PutMapping("/{id}/reset-password")
    public Result<Void> resetPassword(@PathVariable Long id) {
        sysUserService.resetPassword(id);
        return Result.success();
    }

    @PutMapping("/{id}/bind-cadre/{cadreId}")
    public Result<Void> bindCadre(@PathVariable Long id, @PathVariable Long cadreId) {
        sysUserService.bindCadre(id, cadreId);
        return Result.success();
    }

    @PutMapping("/{id}/unbind-cadre")
    public Result<Void> unbindCadre(@PathVariable Long id) {
        sysUserService.unbindCadre(id);
        return Result.success();
    }

    @GetMapping("/profile")
    public Result<SysUser> profile() {
        com.personnel.framework.security.LoginUser loginUser =
                com.personnel.framework.security.SecurityUtils.getLoginUser();
        if (loginUser == null) {
            return Result.error(401, "未登录");
        }
        SysUser user = sysUserService.getById(loginUser.getUserId());
        if (user != null) {
            user.setPassword(null);
        }
        return Result.success(user);
    }
}
