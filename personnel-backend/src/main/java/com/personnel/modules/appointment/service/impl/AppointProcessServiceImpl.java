package com.personnel.modules.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.appointment.entity.*;
import com.personnel.modules.appointment.mapper.*;
import com.personnel.modules.appointment.service.AppointProcessService;
import org.springframework.stereotype.Service;

import jakarta.annotation.Resource;

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
