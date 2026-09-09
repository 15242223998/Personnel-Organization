package com.personnel.modules.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.appointment.entity.*;
import com.personnel.modules.appointment.mapper.*;
import com.personnel.modules.appointment.service.AppointProcessService;
import com.personnel.modules.assessment.support.AnnualAssessmentSupport;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import org.springframework.stereotype.Service;

import jakarta.annotation.Resource;
import java.util.List;

@Service
public class AppointProcessServiceImpl extends ServiceImpl<AppointProcessMapper, AppointProcess> implements AppointProcessService {

    @Resource
    private AppointMotionMapper appointMotionMapper;
    @Resource
    private AppointRecommendMapper appointRecommendMapper;
    @Resource
    private AppointInvestigationMapper appointInvestigationMapper;
    @Resource
    private AppointDecisionMapper appointDecisionMapper;
    @Resource
    private AppointPublicityMapper appointPublicityMapper;
    @Resource
    private AppointRecordMapper appointRecordMapper;
    @Resource
    private CadreInfoService cadreInfoService;

    /**
     * 启动/新建任免流程（POST /appoint-process，AppointProcessController#start 落库入口）：
     * 当流程已关联目标干部（cadreId）时，先做“近三年考核核验”（统一口径见
     * AnnualAssessmentSupport，来源 cadre_info.annual_assessment）；未达标抛 BusinessException，
     * 文案附具体原因（如：该干部未通过近三年考核核验：2024 年度考核记录缺失，请先在干部考核管理补录后重试）。
     * 启动弹窗未选择干部（cadreId 为空）时不校验，允许后续环节再关联。
     */
    @Override
    @org.springframework.transaction.annotation.Transactional
    public boolean save(AppointProcess process) {
        checkCadreAssessmentBeforeStart(process);
        return super.save(process);
    }

    private void checkCadreAssessmentBeforeStart(AppointProcess process) {
        if (process == null || process.getCadreId() == null) {
            return;
        }
        CadreInfo cadre = cadreInfoService.getById(process.getCadreId());
        if (cadre == null) {
            throw new BusinessException("关联干部不存在，请刷新后重试");
        }
        String raw = cadre.getAnnualAssessment();
        if (!AnnualAssessmentSupport.qualified(raw)) {
            List<String> reasons = AnnualAssessmentSupport.reasons(raw);
            String summary = reasons.isEmpty() ? "近三年考核记录不足" : String.join("；", reasons);
            throw new BusinessException("该干部未通过近三年考核核验：" + summary + "，请先在干部考核管理补录后重试");
        }
    }

    @Override
    public AppointProcess getFullProcess(Long id) {
        AppointProcess process = getById(id);
        if (process == null) {
            throw new BusinessException("任命流程不存在");
        }
        process.setMotion(appointMotionMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointMotion>()
                        .eq(AppointMotion::getProcessId, id)));
        process.setRecommend(appointRecommendMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointRecommend>()
                        .eq(AppointRecommend::getProcessId, id)));
        process.setInvestigation(appointInvestigationMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointInvestigation>()
                        .eq(AppointInvestigation::getProcessId, id)));
        process.setDecision(appointDecisionMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointDecision>()
                        .eq(AppointDecision::getProcessId, id)));
        process.setPublicity(appointPublicityMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointPublicity>()
                        .eq(AppointPublicity::getProcessId, id)));
        process.setRecord(appointRecordMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointRecord>()
                        .eq(AppointRecord::getProcessId, id)));
        return process;
    }
}
