package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyLeave;
import com.personnel.modules.daily.mapper.DailyLeaveMapper;
import com.personnel.modules.daily.service.DailyLeaveService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.temporal.ChronoUnit;

/**
 * 休假台账：规范校验
 */
@Service
public class DailyLeaveServiceImpl extends ServiceImpl<DailyLeaveMapper, DailyLeave> implements DailyLeaveService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    public boolean save(DailyLeave leave) {
        validate(leave);
        return super.save(leave);
    }

    @Override
    public boolean updateById(DailyLeave leave) {
        validate(leave);
        return super.updateById(leave);
    }

    private void validate(DailyLeave leave) {
        if (leave.getCadreId() == null) {
            throw new BusinessException("所属干部不能为空");
        }
        if (cadreInfoService.getById(leave.getCadreId()) == null) {
            throw new BusinessException("干部档案不存在");
        }
        if (!StringUtils.hasText(leave.getLeaveType())) {
            throw new BusinessException("休假类型不能为空");
        }
        if (leave.getStartDate() == null || leave.getEndDate() == null) {
            throw new BusinessException("休假开始与结束日期均不能为空");
        }
        if (leave.getEndDate().isBefore(leave.getStartDate())) {
            throw new BusinessException("休假结束日期不能早于开始日期");
        }
        if (!StringUtils.hasText(leave.getReason())) {
            throw new BusinessException("休假事由不能为空");
        }
        // 休假天数自动核算（自然日）
        if (leave.getLeaveDays() == null || leave.getLeaveDays().signum() <= 0) {
            long days = ChronoUnit.DAYS.between(leave.getStartDate(), leave.getEndDate()) + 1;
            leave.setLeaveDays(java.math.BigDecimal.valueOf(days));
        }
        if (!StringUtils.hasText(leave.getApproveStatus())) {
            leave.setApproveStatus("待审批");
        }
    }
}
