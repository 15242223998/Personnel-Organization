package com.personnel.framework.security;

import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.mapper.OrganizationMapper;
import com.personnel.system.entity.SysUser;
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
 * 数据权限助手：按当前用户的 userType 计算可访问部门范围（全系统唯一口径）。
 *
 * <p>权限收敛决策：不再读取 sys_user_role / sys_role 的 data_scope，改为用户类型常量映射：</p>
 * <ul>
 *   <li>userType=1 系统管理员 / 2 校级领导 / 3 组织部部长 / 4 组织员 → 全部（全校范围，不限制）；</li>
 *   <li>userType=5 二级学院领导 → 本级及下级（以其本人所属部门为锚）；</li>
 *   <li>userType=6 普通干部（及非法/缺省类型兜底）→ 仅本部门本级。</li>
 * </ul>
 *
 * <p>返回 null 表示不限制；返回空集合表示无任何可见数据；否则为可见部门ID集合。</p>
 */
@Component
public class DataScopeHelper {

    /** 全部：不做任何部门限制 */
    private static final int SCOPE_ALL = 1;

    /** 本级及下级（以本人部门为锚，含本人部门及其子孙机构） */
    private static final int SCOPE_SELF_AND_CHILDREN = 3;

    /** 仅本部门本级 */
    private static final int SCOPE_SELF = 4;

    @Resource
    private OrganizationMapper organizationMapper;

    public Set<Long> allowedDeptIds() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getUser() == null) {
            return null;
        }
        SysUser user = loginUser.getUser();
        Integer scope = resolveDataScope(user);
        // 全部数据，不做限制
        if (scope == null || scope == SCOPE_ALL) {
            return null;
        }
        Long deptId = user.getDeptId();
        Set<Long> result = new HashSet<>();
        if (deptId == null) {
            // 非“全部”范围却未归属部门，安全起见不返回任何数据
            return result;
        }
        if (scope == SCOPE_SELF) {
            result.add(deptId);
            return result;
        }
        // SCOPE_SELF_AND_CHILDREN：本级及下级机构
        collectSelfAndDescendants(deptId, result);
        return result;
    }

    /**
     * 由用户类型映射数据范围：
     * 系统管理员/校级领导/组织部部长/组织员为全校(全部)；二级学院领导为本人部门及下级；普通干部仅本部门。
     */
    private Integer resolveDataScope(SysUser user) {
        Integer userType = user.getUserType();
        if (userType == null) {
            return SCOPE_SELF;
        }
        return switch (userType) {
            case 1, 2, 3, 4 -> SCOPE_ALL;
            case 5 -> SCOPE_SELF_AND_CHILDREN;
            case 6 -> SCOPE_SELF;
            // 低于1/大于6视为非法，安全兜底为仅本部门
            default -> SCOPE_SELF;
        };
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
