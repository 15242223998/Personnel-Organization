package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.daily.entity.DailySelfApplication;
import com.personnel.modules.daily.mapper.DailySelfApplicationMapper;
import com.personnel.modules.daily.service.DailySelfApplicationService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class DailySelfApplicationServiceImpl extends ServiceImpl<DailySelfApplicationMapper, DailySelfApplication> implements DailySelfApplicationService {

    @Override
    public void submit(Long id) {
        DailySelfApplication app = getById(id);
        if (app == null) {
            throw new BusinessException("申请不存在");
        }
        app.setApplyStatus("待审批");
        updateById(app);
    }

    @Override
    public void approve(Long id, Long approverId, String comment) {
        DailySelfApplication app = getById(id);
        if (app == null) {
            throw new BusinessException("申请不存在");
        }
        app.setApplyStatus("已通过");
        app.setApproverId(approverId);
        app.setApproveTime(LocalDateTime.now());
        app.setApproveComment(comment);
        updateById(app);
    }

    @Override
    public void reject(Long id, Long approverId, String comment) {
        DailySelfApplication app = getById(id);
        if (app == null) {
            throw new BusinessException("申请不存在");
        }
        app.setApplyStatus("已驳回");
        app.setApproverId(approverId);
        app.setApproveTime(LocalDateTime.now());
        app.setApproveComment(comment);
        updateById(app);
    }
}
