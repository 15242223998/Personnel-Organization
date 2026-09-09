package com.personnel.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.SysUser;
import com.personnel.system.service.SysUserService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;

import java.util.Collection;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

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

    /** 修改用户类型（1系统管理员 ~ 6普通干部），禁止修改当前登录账号自身的类型 */
    @PutMapping("/{id}/type")
    public Result<Void> updateUserType(@PathVariable Long id, @RequestParam Integer userType) {
        com.personnel.framework.security.LoginUser loginUser =
                com.personnel.framework.security.SecurityUtils.getLoginUser();
        if (loginUser != null && Objects.equals(loginUser.getUserId(), id)) {
            return Result.error("不能修改当前登录账号自身的用户类型");
        }
        sysUserService.updateUserType(id, userType);
        return Result.success();
    }

    @PutMapping("/{id}/unbind-cadre")
    public Result<Void> unbindCadre(@PathVariable Long id) {
        sysUserService.unbindCadre(id);
        return Result.success();
    }

    /** 管理员快捷授权：body 传 { permissions: ["cadre", ...] }（或逗号串），保存为逗号分隔串 */
    @PutMapping("/{id}/permissions")
    public Result<Void> updatePermissions(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        SysUser user = sysUserService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        Object raw = body == null ? null : body.get("permissions");
        String joined = "";
        if (raw instanceof Collection<?> col) {
            joined = col.stream()
                    .filter(Objects::nonNull)
                    .map(String::valueOf)
                    .filter(s -> !s.isBlank())
                    .collect(Collectors.joining(","));
        } else if (raw != null) {
            joined = String.valueOf(raw).trim();
        }
        user.setPermissions(joined);
        sysUserService.updateById(user);
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
            // permissions 返回"生效权限"：用户级覆盖优先，空则回退用户类型内置模板；系统管理员为 ALL
            user.setPermissions(sysUserService.resolveEffectivePermissions(user));
        }
        return Result.success(user);
    }
}
