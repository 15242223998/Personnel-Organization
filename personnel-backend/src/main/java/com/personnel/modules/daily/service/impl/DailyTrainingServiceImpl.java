package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.daily.entity.DailyTraining;
import com.personnel.modules.daily.mapper.DailyTrainingMapper;
import com.personnel.modules.daily.service.DailyTrainingService;
import org.springframework.stereotype.Service;

@Service
public class DailyTrainingServiceImpl extends ServiceImpl<DailyTrainingMapper, DailyTraining> implements DailyTrainingService {
}
