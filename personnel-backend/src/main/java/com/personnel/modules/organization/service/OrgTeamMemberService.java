package com.personnel.modules.organization.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.organization.entity.OrgTeamMember;

import java.util.List;

public interface OrgTeamMemberService extends IService<OrgTeamMember> {

    /**
     * 机构班子成员列表（deptId 为空返回全部，便于前端一次性构建机构-班子映射）
     */
    List<OrgTeamMember> listTeam(Long deptId);

    /**
     * 分页查询，可按机构/班子职务筛选
     */
    Page<OrgTeamMember> pageTeam(Page<OrgTeamMember> page, Long deptId, String leaderPost);

    /**
     * 登记班子成员：校验机构/干部存在、同一机构下干部不可重复录入
     */
    OrgTeamMember createTeam(OrgTeamMember member);

    /**
     * 编辑班子成员：同样做存在性与重复校验
     */
    OrgTeamMember updateTeam(OrgTeamMember member);
}
