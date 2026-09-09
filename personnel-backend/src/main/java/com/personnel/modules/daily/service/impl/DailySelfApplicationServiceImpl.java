package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.framework.security.SecurityUtils;
import com.personnel.modules.cadre.constant.CadreInfoMapperKeys;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
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

    /** 档案信息更正申报类型（application_type，兼容历史“信息修改”语义） */
    private static final String TYPE_INFO_UPDATE = "INFO_UPDATE";

    @Resource
    private SysUserService sysUserService;

    @Resource
    private CadreInfoService cadreInfoService;

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
        // 档案信息更正：仅在草稿/待审批阶段做白名单校验、旧值快照与格式校验；
        // 已办结（APPROVED/REJECTED）记录的状态流转（approve/reject 内部 updateById）不再重新校验
        if (TYPE_INFO_UPDATE.equals(application.getApplicationType())
                && StringUtils.hasText(application.getApplyField())
                && !"APPROVED".equals(application.getApplyStatus())
                && !"REJECTED".equals(application.getApplyStatus())) {
            fillCorrectionSnapshot(application, user.getCadreId());
        }
    }

    /**
     * 档案信息更正校验与旧值快照：
     * 1) apply_field 必须在白名单内，否则拒绝（BusinessException「该字段不支持档案更正」）；
     * 2) 新值非空、格式粗校验（联系电话/邮箱）；
     * 3) 按申请人绑定的 cadre_info 读取对应列真实当前值存入 old_value（仅首次落库，不覆盖已有快照）；
     * 4) 新值不得与档案当前值相同。
     */
    private void fillCorrectionSnapshot(DailySelfApplication app, Long cadreId) {
        String fieldKey = app.getApplyField();
        if (!CadreInfoMapperKeys.supports(fieldKey)) {
            throw new BusinessException("该字段不支持档案更正");
        }
        String newValue = app.getNewValue() == null ? null : app.getNewValue().trim();
        if (!StringUtils.hasText(newValue)) {
            throw new BusinessException("档案信息更正的新值不能为空");
        }
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            throw new BusinessException("干部档案不存在，无法发起信息更正");
        }
        String oldValue = CadreInfoMapperKeys.readValue(cadre, fieldKey);
        if (!StringUtils.hasText(app.getOldValue())) {
            // 按当前登录人绑定的干部档案读取真实列值，供审批展示「旧值 → 新值」
            app.setOldValue(oldValue);
        }
        app.setNewValue(newValue);
        if (oldValue != null && oldValue.equals(newValue)) {
            throw new BusinessException("新值与档案当前值相同，无需更正");
        }
        checkValueFormat(fieldKey, newValue);
    }

    /** 手机/邮箱粗校验 */
    private void checkValueFormat(String fieldKey, String newValue) {
        if ("phone".equals(fieldKey)) {
            if (!newValue.matches("^[0-9+\\-\\s()]{6,20}$")) {
                throw new BusinessException("联系电话格式不正确");
            }
        } else if ("email".equals(fieldKey)) {
            int at = newValue.indexOf('@');
            if (newValue.length() > 128 || at <= 0 || newValue.indexOf('.', at) < 0) {
                throw new BusinessException("邮箱格式不正确");
            }
        }
    }

    @Override
    public void submit(Long id) {
        DailySelfApplication app = getById(id);
        if (app == null) {
            throw new BusinessException("申请不存在");
        }
        // 历史遗留/草稿补充：若为档案信息更正但尚未落 old_value 快照，提交时补齐并复核
        if (TYPE_INFO_UPDATE.equals(app.getApplicationType())
                && StringUtils.hasText(app.getApplyField())
                && "DRAFT".equals(app.getApplyStatus())) {
            SysUser user = sysUserService.getById(app.getApplicantId());
            if (user != null && user.getCadreId() != null) {
                fillCorrectionSnapshot(app, user.getCadreId());
            }
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
        // 档案信息更正：通过且 apply_field 白名单命中时，回写 cadre_info 对应列（new_value）
        String fieldKey = app.getApplyField();
        if (StringUtils.hasText(fieldKey)) {
            String column = CadreInfoMapperKeys.columnOf(fieldKey);
            if (column == null) {
                // 非白名单字段一律拒绝（正常流程在提交时已被拦截，此处为兜底）
                throw new BusinessException("该字段不支持档案更正");
            }
            if (!StringUtils.hasText(app.getNewValue())) {
                throw new BusinessException("档案信息更正的新值不能为空，无法回写");
            }
            SysUser user = sysUserService.getById(app.getApplicantId());
            if (user == null || user.getCadreId() == null) {
                throw new BusinessException("申请人账号未绑定干部档案，无法回写档案");
            }
            CadreInfo cadre = cadreInfoService.getById(user.getCadreId());
            if (cadre == null) {
                throw new BusinessException("该干部档案不存在或已删除，无法回写档案信息");
            }
            // 用白名单映射出的列名构造 UpdateWrapper（禁止拼接任意字段名）
            boolean written = cadreInfoService.update(new UpdateWrapper<CadreInfo>()
                    .eq("id", cadre.getId())
                    .set(column, app.getNewValue()));
            if (!written) {
                throw new BusinessException("档案信息回写失败，请联系管理员");
            }
        }
        // 其它类型（如出国类申请）沿用原审批：仅置 APPROVED 状态
        app.setApplyStatus("APPROVED");
        app.setApproverId(approverId);
        app.setApproveTime(LocalDateTime.now());
        app.setApproveComment(comment);
        updateById(app);
    }

    @Override
    public void reject(Long id, Long approverId, String comment) {
        // 驳回不触发档案回写，仅记录状态与审批意见（comment 一并落库 approve_comment）
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
