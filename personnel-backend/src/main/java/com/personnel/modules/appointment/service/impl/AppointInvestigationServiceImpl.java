package com.personnel.modules.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.appointment.entity.AppointInvestigation;
import com.personnel.modules.appointment.mapper.AppointInvestigationMapper;
import com.personnel.modules.appointment.service.AppointInvestigationService;
import org.springframework.stereotype.Service;

@Service
public class AppointInvestigationServiceImpl extends ServiceImpl<AppointInvestigationMapper, AppointInvestigation> implements AppointInvestigationService {
}
