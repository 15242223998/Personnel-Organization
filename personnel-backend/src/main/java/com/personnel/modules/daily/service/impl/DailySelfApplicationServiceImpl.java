package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.framework.security.SecurityUtils;
import com.personnel.modules.daily.entity.DailySelfApplication;
import com.personnel.modules.daily.mapper.DailySelfApplicationMapper;
import com.personnel.modules.daily.service.DailySelfApplicationService;
import com.personnel.system.entity.SysUser;
import com.personnel.system.service.SysUserService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
public class DailySelfApplicationServiceImpl extends ServiceImpl<DailySelfApplicationMapper, DailySelfApplication> implements DailySelfApplicationService {

    @Resource
    private SysUserService sysUserService;

    @Override
    public boolean save(DailySelfApplication application) {
        validate(application);
        return super.save(application);
    }

    @Override
    public boolean updateById(DailySelfApplication application) {
        validate(application);
        return super.updateById(application);
    }

    private void validate(DailySelfApplication application) {
        // 申请人归属：默认取当前登录用户，且必须绑定干部档案
        if (application.getId() == null
                && (application.getApplicantId() == null || application.getApplicantId() <= 0)) {
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                throw new BusinessException("未获取到登录用户，请重新登录");
            }
            application.setApplicantId(userId);
        }
        Long applicantId = application.getApplicantId();
        SysUser user = applicantId == null ? null : sysUserService.getById(applicantId);
        if (user == null) {
            throw new BusinessException("申请人账号不存在");
        }
        if (user.getCadreId() == null) {
            throw new BusinessException("当前用户未绑定干部档案，无法自助申报，请联系管理员在【用户管理】中绑定");
        }
        if (!StringUtils.hasText(application.getApplicationType())) {
            throw new BusinessException("申报类型不能为空");
        }
        if (!StringUtils.hasText(application.getApplicationTitle())) {
            application.setApplicationTitle(application.getApplicationType());
        }
        if (!StringUtils.hasText(application.getApplicationContent())) {
            throw new BusinessException("申报内容不能为空");
        }
        if (application.getId() == null && !StringUtils.hasText(application.getApplyStatus())) {
            application.setApplyStatus("DRAFT");
        }
    }

    @Override
    public void submit(Long id) {
        DailySelfApplication app = getById(id);
        if (app == null) {
            throw new BusinessException("申请不存在");
        }
        app.setApplyStatus("SUBMITTED");
        updateById(app);
    }

    @Override
    public void approve(Long id, Long approverId, String comment) {
        DailySelfApplication app = getById(id);
        if (app == null) {
            throw new BusinessException("申请不存在");
        }
        if (!"SUBMITTED".equals(app.getApplyStatus())) {
            throw new BusinessException("仅已提交状态可审批");
        }
        app.setApplyStatus("APPROVED");
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
        if (!"SUBMITTED".equals(app.getApplyStatus())) {
            throw new BusinessException("仅已提交状态可审批");
        }
        app.setApplyStatus("REJECTED");
        app.setApproverId(approverId);
        app.setApproveTime(LocalDateTime.now());
        app.setApproveComment(comment);
        updateById(app);
    }
}
