package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyAbroadRecord;
import com.personnel.modules.daily.entity.DailyCertificate;
import com.personnel.modules.daily.mapper.DailyAbroadRecordMapper;
import com.personnel.modules.daily.mapper.DailyCertificateMapper;
import com.personnel.modules.daily.service.DailyAbroadRecordService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;

/**
 * 出境记录台账：规范校验 + 证照联动（回国自动交回临时领用的证照）
 */
@Service
public class DailyAbroadRecordServiceImpl extends ServiceImpl<DailyAbroadRecordMapper, DailyAbroadRecord> implements DailyAbroadRecordService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Resource
    private DailyCertificateMapper certificateMapper;

    @Override
    public boolean save(DailyAbroadRecord record) {
        validate(record);
        return super.save(record);
    }

    @Override
    public boolean updateById(DailyAbroadRecord record) {
        validate(record);
        boolean updated = super.updateById(record);
        // 出境记录 → 证照管理：行程有返回日期后，将关联的"在借"证照自动交回
        if (updated && record.getReturnDate() != null && record.getId() != null) {
            certificateMapper.update(null, new UpdateWrapper<DailyCertificate>()
                    .eq("abroad_id", record.getId())
                    .eq("cert_status", "在借")
                    .set("cert_status", "已归还")
                    .set("return_date", record.getReturnDate()));
        }
        return updated;
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
