package com.personnel.modules.organization.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.mapper.OrganizationMapper;
import com.personnel.modules.organization.service.OrganizationService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrganizationServiceImpl extends ServiceImpl<OrganizationMapper, Organization> implements OrganizationService {

    @Override
    public List<Organization> getTree() {
        List<Organization> all = list(new LambdaQueryWrapper<Organization>().orderByAsc(Organization::getDeptSort));
        return buildTree(all, 0L);
    }

    private List<Organization> buildTree(List<Organization> all, Long parentId) {
        return all.stream()
                .filter(org -> (parentId == 0L && org.getParentId() == null) || java.util.Objects.equals(org.getParentId(), parentId))
                .peek(org -> org.setChildren(buildTree(all, org.getId())))
                .collect(Collectors.toList());
    }
}
