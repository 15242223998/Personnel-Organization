package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailySecondment;
import com.personnel.modules.daily.mapper.DailySecondmentMapper;
import com.personnel.modules.daily.service.DailySecondmentService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;

/**
 * 挂职锻炼台账：规范校验
 */
@Service
public class DailySecondmentServiceImpl extends ServiceImpl<DailySecondmentMapper, DailySecondment> implements DailySecondmentService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    public boolean save(DailySecondment secondment) {
        validate(secondment);
        return super.save(secondment);
    }

    @Override
    public boolean updateById(DailySecondment secondment) {
        validate(secondment);
        return super.updateById(secondment);
    }

    private void validate(DailySecondment secondment) {
        if (secondment.getCadreId() == null) {
            throw new BusinessException("挂职干部不能为空");
        }
        CadreInfo cadre = cadreInfoService.getById(secondment.getCadreId());
        if (cadre == null) {
            throw new BusinessException("干部档案不存在");
        }
        if (!StringUtils.hasText(secondment.getSecondmentUnit())) {
            throw new BusinessException("挂职单位不能为空");
        }
        if (!StringUtils.hasText(secondment.getSecondmentPosition())) {
            throw new BusinessException("挂职职务不能为空");
        }
        if (secondment.getStartDate() == null || secondment.getEndDate() == null) {
            throw new BusinessException("挂职开始与结束日期均不能为空");
        }
        if (secondment.getEndDate().isBefore(secondment.getStartDate())) {
            throw new BusinessException("挂职结束日期不能早于开始日期");
        }
        long months = secondment.getStartDate().until(secondment.getEndDate()).toTotalMonths();
        if (months < 3) {
            throw new BusinessException("挂职锻炼期限一般不少于3个月");
        }
        // 状态自动维护
        if (!StringUtils.hasText(secondment.getStatus())) {
            LocalDate today = LocalDate.now();
            if (today.isBefore(secondment.getStartDate())) {
                secondment.setStatus("未开始");
            } else if (today.isAfter(secondment.getEndDate())) {
                secondment.setStatus("已结束");
            } else {
                secondment.setStatus("挂职中");
            }
        }
    }
}
