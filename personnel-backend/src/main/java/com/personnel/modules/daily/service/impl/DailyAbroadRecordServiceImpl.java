package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyAbroadRecord;
import com.personnel.modules.daily.mapper.DailyAbroadRecordMapper;
import com.personnel.modules.daily.service.DailyAbroadRecordService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 出境记录台账：规范校验
 */
@Service
public class DailyAbroadRecordServiceImpl extends ServiceImpl<DailyAbroadRecordMapper, DailyAbroadRecord> implements DailyAbroadRecordService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    public boolean save(DailyAbroadRecord record) {
        validate(record);
        return super.save(record);
    }

    @Override
    public boolean updateById(DailyAbroadRecord record) {
        validate(record);
        return super.updateById(record);
    }

    private void validate(DailyAbroadRecord record) {
        if (record.getCadreId() == null) {
            throw new BusinessException("所属干部不能为空");
        }
        if (cadreInfoService.getById(record.getCadreId()) == null) {
            throw new BusinessException("干部档案不存在");
        }
        if (!StringUtils.hasText(record.getDestination())) {
            throw new BusinessException("前往国家/地区不能为空");
        }
        if (record.getDepartDate() == null || record.getReturnDate() == null) {
            throw new BusinessException("出境日期和返回日期均不能为空");
        }
        if (record.getReturnDate().isBefore(record.getDepartDate())) {
            throw new BusinessException("返回日期不能早于出境日期");
        }
        if (record.getApprovedDays() == null || record.getApprovedDays() <= 0) {
            throw new BusinessException("批准天数必须大于0");
        }
        // 实际天数与超期自动核算
        if (record.getActualDays() != null && record.getActualDays() > 0) {
            record.setIsOverdue(record.getActualDays() > record.getApprovedDays() ? 1 : 0);
        } else {
            long actual = record.getDepartDate().until(record.getReturnDate()).getDays() + 1;
            record.setActualDays((int) actual);
            record.setIsOverdue(actual > record.getApprovedDays() ? 1 : 0);
        }
    }
}
