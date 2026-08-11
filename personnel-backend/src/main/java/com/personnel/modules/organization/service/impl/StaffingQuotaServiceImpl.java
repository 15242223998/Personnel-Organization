package com.personnel.modules.organization.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.organization.entity.StaffingQuota;
import com.personnel.modules.organization.mapper.StaffingQuotaMapper;
import com.personnel.modules.organization.service.StaffingQuotaService;
import org.springframework.stereotype.Service;

@Service
public class StaffingQuotaServiceImpl extends ServiceImpl<StaffingQuotaMapper, StaffingQuota> implements StaffingQuotaService {
}
