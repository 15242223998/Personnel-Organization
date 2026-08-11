package com.personnel.modules.organization.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.organization.entity.OrganizationRank;
import com.personnel.modules.organization.mapper.OrganizationRankMapper;
import com.personnel.modules.organization.service.OrganizationRankService;
import org.springframework.stereotype.Service;

@Service
public class OrganizationRankServiceImpl extends ServiceImpl<OrganizationRankMapper, OrganizationRank> implements OrganizationRankService {
}
