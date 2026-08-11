package com.personnel.modules.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.appointment.entity.AppointMotion;
import com.personnel.modules.appointment.mapper.AppointMotionMapper;
import com.personnel.modules.appointment.service.AppointMotionService;
import org.springframework.stereotype.Service;

@Service
public class AppointMotionServiceImpl extends ServiceImpl<AppointMotionMapper, AppointMotion> implements AppointMotionService {
}
