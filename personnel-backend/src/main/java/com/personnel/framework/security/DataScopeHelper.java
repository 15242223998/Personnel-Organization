package com.personnel.framework.security;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.mapper.OrganizationMapper;
import com.personnel.system.entity.SysRole;
import com.personnel.system.entity.SysUser;
import com.personnel.system.entity.SysUserRole;
import com.personnel.system.mapper.SysRoleMapper;
import com.personnel.system.mapper.SysUserRoleMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 数据权限助手：按当前用户角色的 dataScope 计算可访问部门范围
 * dataScope：1全部 2自定义(暂按下级处理) 3本级及下级 4本级
 * 返回 null 表示不限制；返回空集合表示无任何可见数据；否则为可见部门ID集合
 */
@Component
public class DataScopeHelper {

    @Resource
    private SysUserRoleMapper sysUserRoleMapper;

    @Resource
    private SysRoleMapper sysRoleMapper;

    @Resource
    private OrganizationMapper organizationMapper;

    public Set<Long> allowedDeptIds() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getUser() == null) {
            return null;
        }
        SysUser user = loginUser.getUser();
        Integer scope = resolveDataScope(user.getId());
        // 全部数据，不做限制
        if (scope == null || scope == 1) {
            return null;
        }
        Long deptId = user.getDeptId();
        Set<Long> result = new HashSet<>();
        if (deptId == null) {
            // 非“全部”范围却未归属部门，安全起见不返回任何数据
            return result;
        }
        if (scope == 4) {
            result.add(deptId);
            return result;
        }
        // scope 2/3：本级及下级机构
        collectSelfAndDescendants(deptId, result);
        return result;
    }

    private Integer resolveDataScope(Long userId) {
        List<SysUserRole> userRoles = sysUserRoleMapper.selectList(
                new LambdaQueryWrapper<SysUserRole>().eq(SysUserRole::getUserId, userId));
        if (userRoles == null || userRoles.isEmpty()) {
            return 4;
        }
        List<Long> roleIds = userRoles.stream()
                .map(SysUserRole::getRoleId)
                .filter(id -> id != null)
                .distinct()
                .toList();
        if (roleIds.isEmpty()) {
            return 4;
        }
        List<SysRole> roles = sysRoleMapper.selectBatchIds(roleIds);
        int scope = 4;
        if (roles != null) {
            for (SysRole role : roles) {
                if (role.getDataScope() != null && role.getDataScope() < scope) {
                    scope = role.getDataScope();
                }
            }
        }
        return scope;
    }

    private void collectSelfAndDescendants(Long rootId, Set<Long> out) {
        List<Organization> all = organizationMapper.selectList(null);
        Map<Long, List<Long>> childrenMap = new HashMap<>();
        if (all != null) {
            for (Organization org : all) {
                if (org.getId() == null) {
                    continue;
                }
                Long parentId = org.getParentId();
                if (parentId == null || parentId == 0) {
                    continue;
                }
                childrenMap.computeIfAbsent(parentId, k -> new ArrayList<>()).add(org.getId());
            }
        }
        Deque<Long> stack = new ArrayDeque<>();
        stack.push(rootId);
        while (!stack.isEmpty()) {
            Long current = stack.pop();
            if (!out.add(current)) {
                continue;
            }
            List<Long> children = childrenMap.get(current);
            if (children != null) {
                children.forEach(stack::push);
            }
        }
    }
}
