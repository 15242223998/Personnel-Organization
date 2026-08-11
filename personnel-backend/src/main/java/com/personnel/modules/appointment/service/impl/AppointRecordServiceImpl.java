package com.personnel.modules.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.appointment.entity.AppointRecord;
import com.personnel.modules.appointment.mapper.AppointRecordMapper;
import com.personnel.modules.appointment.service.AppointRecordService;
import org.springframework.stereotype.Service;

@Service
public class AppointRecordServiceImpl extends ServiceImpl<AppointRecordMapper, AppointRecord> implements AppointRecordService {
}
