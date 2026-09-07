package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.daily.entity.DailyTraining;
import com.personnel.modules.daily.mapper.DailyTrainingMapper;
import com.personnel.modules.daily.service.DailyTrainingService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 教育培训台账：规范校验
 */
@Service
public class DailyTrainingServiceImpl extends ServiceImpl<DailyTrainingMapper, DailyTraining> implements DailyTrainingService {

    @Override
    public boolean save(DailyTraining training) {
        validate(training);
        return super.save(training);
    }

    @Override
    public boolean updateById(DailyTraining training) {
        validate(training);
        return super.updateById(training);
    }

    private void validate(DailyTraining training) {
        if (!StringUtils.hasText(training.getTrainingName())) {
            throw new BusinessException("培训名称不能为空");
        }
        if (!StringUtils.hasText(training.getTrainingType())) {
            throw new BusinessException("培训类型不能为空");
        }
        if (!StringUtils.hasText(training.getOrganizer())) {
            throw new BusinessException("组织单位不能为空");
        }
        if (training.getStartDate() == null || training.getEndDate() == null) {
            throw new BusinessException("培训开始与结束日期均不能为空");
        }
        if (training.getEndDate().isBefore(training.getStartDate())) {
            throw new BusinessException("培训结束日期不能早于开始日期");
        }
        if (!StringUtils.hasText(training.getStatus())) {
            training.setStatus("未开始");
        }
    }
}
