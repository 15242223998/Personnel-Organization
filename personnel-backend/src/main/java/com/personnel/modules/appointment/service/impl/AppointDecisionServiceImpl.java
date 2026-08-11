package com.personnel.modules.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.appointment.entity.AppointDecision;
import com.personnel.modules.appointment.mapper.AppointDecisionMapper;
import com.personnel.modules.appointment.service.AppointDecisionService;
import org.springframework.stereotype.Service;

@Service
public class AppointDecisionServiceImpl extends ServiceImpl<AppointDecisionMapper, AppointDecision> implements AppointDecisionService {
}
