package com.personnel.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.SysRole;
import com.personnel.system.service.SysRoleService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/role")
public class SysRoleController {

    @Resource
    private SysRoleService sysRoleService;

    /** 可用模块权限清单（10 项，key 与前端 PERM_KEYS / sys_user.permissions 语义一致） */
    private static final List<Map<String, String>> PERMISSION_OPTIONS = buildPermissionOptions();

    private static List<Map<String, String>> buildPermissionOptions() {
        String[][] items = {
                { "organization", "组织机构管理" },
                { "cadre", "干部信息管理" },
                { "transfer", "干部调配管理" },
                { "promotion", "职级晋升管理" },
                { "appointment", "干部任免管理" },
                { "evaluation", "干部考察评价管理" },
                { "supervision", "干部监督管理" },
                { "assessment", "干部考核管理" },
                { "daily", "日常事务管理" },
                { "system", "系统管理" }
        };
        List<Map<String, String>> list = new ArrayList<>();
        for (String[] item : items) {
            Map<String, String> map = new LinkedHashMap<>();
            map.put("key", item[0]);
            map.put("label", item[1]);
            list.add(map);
        }
        return list;
    }

    /** 返回可用的模块权限清单（key+label） */
    @GetMapping("/permission-options")
    public Result<List<Map<String, String>>> permissionOptions() {
        return Result.success(PERMISSION_OPTIONS);
    }

    /** 保存角色模块权限：请求体为权限key列表（可含按钮级如 organization:add） */
    @PutMapping("/{id}/permissions")
    public Result<Void> updatePermissions(@PathVariable Long id, @RequestBody List<String> permissions) {
        SysRole role = sysRoleService.getById(id);
        if (role == null) {
            return Result.error("角色不存在");
        }
        String joined = (permissions == null ? new ArrayList<String>() : permissions).stream()
                .filter(p -> p != null && !p.isBlank())
                .map(String::trim)
                .distinct()
                .collect(Collectors.joining(","));
        role.setPermissions(joined);
        sysRoleService.updateById(role);
        return Result.success();
    }

    @GetMapping("/list")
    public Result<List<SysRole>> list() {
        return Result.success(sysRoleService.list());
    }

    @GetMapping("/page")
    public Result<PageResult<SysRole>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<SysRole> page = new Page<>(current, size);
        return Result.success(PageResult.of(sysRoleService.page(page)));
    }

    @PostMapping
    public Result<Void> create(@RequestBody SysRole role) {
        sysRoleService.save(role);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SysRole role) {
        sysRoleService.updateById(role);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        sysRoleService.removeById(id);
        return Result.success();
    }
}
