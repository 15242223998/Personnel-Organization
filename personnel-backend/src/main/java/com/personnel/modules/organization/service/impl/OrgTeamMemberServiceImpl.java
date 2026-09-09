package com.personnel.modules.organization.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.organization.entity.OrgTeamMember;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.mapper.OrgTeamMemberMapper;
import com.personnel.modules.organization.service.OrgTeamMemberService;
import com.personnel.modules.organization.service.OrganizationService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jakarta.annotation.Resource;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class OrgTeamMemberServiceImpl extends ServiceImpl<OrgTeamMemberMapper, OrgTeamMember> implements OrgTeamMemberService {

    @Resource
    private OrganizationService organizationService;

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    public List<OrgTeamMember> listTeam(Long deptId) {
        LambdaQueryWrapper<OrgTeamMember> wrapper = new LambdaQueryWrapper<>();
        if (deptId != null) {
            wrapper.eq(OrgTeamMember::getDeptId, deptId);
        }
        wrapper.orderByAsc(OrgTeamMember::getSortOrder).orderByAsc(OrgTeamMember::getId);
        List<OrgTeamMember> list = list(wrapper);
        if (list == null || list.isEmpty()) {
            return Collections.emptyList();
        }
        decorate(list);
        return list;
    }

    @Override
    public Page<OrgTeamMember> pageTeam(Page<OrgTeamMember> page, Long deptId, String leaderPost) {
        LambdaQueryWrapper<OrgTeamMember> wrapper = new LambdaQueryWrapper<>();
        if (deptId != null) {
            wrapper.eq(OrgTeamMember::getDeptId, deptId);
        }
        if (StringUtils.hasText(leaderPost)) {
            wrapper.eq(OrgTeamMember::getLeaderPost, leaderPost);
        }
        wrapper.orderByAsc(OrgTeamMember::getDeptId).orderByAsc(OrgTeamMember::getSortOrder).orderByAsc(OrgTeamMember::getId);
        page(page, wrapper);
        if (page.getRecords() != null && !page.getRecords().isEmpty()) {
            decorate(page.getRecords());
        }
        return page;
    }

    @Override
    public OrgTeamMember createTeam(OrgTeamMember member) {
        if (member.getDeptId() == null || member.getCadreId() == null) {
            throw new BusinessException("机构和干部均必填");
        }
        validateDeptAndCadre(member.getDeptId(), member.getCadreId());
        long dup = count(new LambdaQueryWrapper<OrgTeamMember>()
                .eq(OrgTeamMember::getDeptId, member.getDeptId())
                .eq(OrgTeamMember::getCadreId, member.getCadreId()));
        if (dup > 0) {
            throw new BusinessException("该干部已登记为该机构班子成员，请勿重复录入");
        }
        if (member.getIsLeader() == null) {
            member.setIsLeader(0);
        }
        if (member.getSortOrder() == null) {
            member.setSortOrder(0);
        }
        save(member);
        return member;
    }

    @Override
    public OrgTeamMember updateTeam(OrgTeamMember member) {
        if (member.getId() == null) {
            throw new BusinessException("缺少记录ID");
        }
        OrgTeamMember existed = getById(member.getId());
        if (existed == null) {
            throw new BusinessException("班子记录不存在或已删除");
        }
        Long deptId = member.getDeptId() != null ? member.getDeptId() : existed.getDeptId();
        Long cadreId = member.getCadreId() != null ? member.getCadreId() : existed.getCadreId();
        validateDeptAndCadre(deptId, cadreId);
        long dup = count(new LambdaQueryWrapper<OrgTeamMember>()
                .eq(OrgTeamMember::getDeptId, deptId)
                .eq(OrgTeamMember::getCadreId, cadreId)
                .ne(OrgTeamMember::getId, member.getId()));
        if (dup > 0) {
            throw new BusinessException("该干部已登记为该机构班子成员，请勿重复录入");
        }
        member.setDeptId(deptId);
        member.setCadreId(cadreId);
        updateById(member);
        return getById(member.getId());
    }

    private void validateDeptAndCadre(Long deptId, Long cadreId) {
        Organization dept = organizationService.getById(deptId);
        if (dept == null) {
            throw new BusinessException("所选机构不存在，请刷新后重试");
        }
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            throw new BusinessException("所选干部不存在，请刷新后重试");
        }
    }

    /** 补充机构名称、干部姓名/现任职务等展示字段 */
    private void decorate(List<OrgTeamMember> list) {
        List<Long> deptIds = list.stream().map(OrgTeamMember::getDeptId).filter(Objects::nonNull).distinct().collect(Collectors.toList());
        List<Long> cadreIds = list.stream().map(OrgTeamMember::getCadreId).filter(Objects::nonNull).distinct().collect(Collectors.toList());
        Map<Long, Organization> deptMap = deptIds.isEmpty() ? Collections.emptyMap()
                : organizationService.listByIds(deptIds).stream().collect(Collectors.toMap(Organization::getId, Function.identity()));
        Map<Long, CadreInfo> cadreMap = cadreIds.isEmpty() ? Collections.emptyMap()
                : cadreInfoService.listByIds(cadreIds).stream().collect(Collectors.toMap(CadreInfo::getId, Function.identity()));
        List<Organization> deptsForCadre = new ArrayList<>();
        if (!cadreMap.isEmpty()) {
            List<Long> cadreDeptIds = cadreMap.values().stream().map(CadreInfo::getDeptId).filter(Objects::nonNull).distinct().collect(Collectors.toList());
            if (!cadreDeptIds.isEmpty()) {
                deptsForCadre = organizationService.listByIds(cadreDeptIds);
            }
        }
        Map<Long, String> deptNameById = deptsForCadre.stream()
                .collect(Collectors.toMap(Organization::getId, Organization::getDeptName, (a, b) -> a));
        for (OrgTeamMember m : list) {
            Organization dept = deptMap.get(m.getDeptId());
            m.setDeptName(dept != null ? dept.getDeptName() : null);
            CadreInfo c = cadreMap.get(m.getCadreId());
            if (c != null) {
                m.setCadreName(c.getName());
                m.setCadrePosition(c.getPosition());
                m.setCadreDeptName(deptNameById.get(c.getDeptId()));
                m.setCadreStatus(c.getCadreStatus());
            }
        }
    }
}
