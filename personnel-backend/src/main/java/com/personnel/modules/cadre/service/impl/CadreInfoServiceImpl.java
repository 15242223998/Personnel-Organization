package com.personnel.modules.cadre.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreFamilyMember;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.mapper.CadreInfoMapper;
import com.personnel.modules.cadre.service.CadreFamilyMemberService;
import com.personnel.modules.cadre.service.CadreInfoService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jakarta.annotation.Resource;
import java.util.List;

@Service
public class CadreInfoServiceImpl extends ServiceImpl<CadreInfoMapper, CadreInfo> implements CadreInfoService {

    @Resource
    private CadreFamilyMemberService cadreFamilyMemberService;

    @Override
    public Page<CadreInfo> pageQuery(Page<CadreInfo> page, CadreInfo query) {
        LambdaQueryWrapper<CadreInfo> wrapper = new LambdaQueryWrapper<>();
        if (query != null) {
            if (StringUtils.hasText(query.getName())) {
                wrapper.like(CadreInfo::getName, query.getName());
            }
            if (query.getDeptId() != null) {
                wrapper.eq(CadreInfo::getDeptId, query.getDeptId());
            }
            if (StringUtils.hasText(query.getCadreStatus())) {
                wrapper.eq(CadreInfo::getCadreStatus, query.getCadreStatus());
            }
            if (StringUtils.hasText(query.getPositionLevel())) {
                wrapper.eq(CadreInfo::getPositionLevel, query.getPositionLevel());
            }
            if (query.getGender() != null) {
                wrapper.eq(CadreInfo::getGender, query.getGender());
            }
            if (StringUtils.hasText(query.getPoliticalStatus())) {
                wrapper.eq(CadreInfo::getPoliticalStatus, query.getPoliticalStatus());
            }
        }
        wrapper.orderByDesc(CadreInfo::getCreateTime);
        return page(page, wrapper);
    }

    @Override
    public CadreInfo getDetailById(Long id) {
        CadreInfo cadreInfo = getById(id);
        if (cadreInfo == null) {
            throw new BusinessException("干部信息不存在");
        }
        List<CadreFamilyMember> members = cadreFamilyMemberService.list(
                new LambdaQueryWrapper<CadreFamilyMember>().eq(CadreFamilyMember::getCadreId, id));
        cadreInfo.setFamilyMembers(members);
        return cadreInfo;
    }

    @Override
    public List<CadreInfo> exportList(CadreInfo query) {
        LambdaQueryWrapper<CadreInfo> wrapper = new LambdaQueryWrapper<>();
        if (query != null) {
            if (StringUtils.hasText(query.getName())) {
                wrapper.like(CadreInfo::getName, query.getName());
            }
            if (query.getDeptId() != null) {
                wrapper.eq(CadreInfo::getDeptId, query.getDeptId());
            }
            if (StringUtils.hasText(query.getCadreStatus())) {
                wrapper.eq(CadreInfo::getCadreStatus, query.getCadreStatus());
            }
            if (StringUtils.hasText(query.getPositionLevel())) {
                wrapper.eq(CadreInfo::getPositionLevel, query.getPositionLevel());
            }
            if (query.getGender() != null) {
                wrapper.eq(CadreInfo::getGender, query.getGender());
            }
        }
        wrapper.orderByDesc(CadreInfo::getCreateTime);
        return list(wrapper);
    }
}
