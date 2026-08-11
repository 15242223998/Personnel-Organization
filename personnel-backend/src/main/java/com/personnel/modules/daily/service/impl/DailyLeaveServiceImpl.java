package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.daily.entity.DailyLeave;
import com.personnel.modules.daily.mapper.DailyLeaveMapper;
import com.personnel.modules.daily.service.DailyLeaveService;
import org.springframework.stereotype.Service;

@Service
public class DailyLeaveServiceImpl extends ServiceImpl<DailyLeaveMapper, DailyLeave> implements DailyLeaveService {
}
