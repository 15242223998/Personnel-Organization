package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyTrainingCadre;
import com.personnel.modules.daily.mapper.DailyTrainingCadreMapper;
import com.personnel.modules.daily.service.DailyTrainingCadreService;
import com.personnel.modules.daily.service.DailyTrainingService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

/**
 * 培训参训干部：唯一性与有效性校验
 */
@Service
public class DailyTrainingCadreServiceImpl extends ServiceImpl<DailyTrainingCadreMapper, DailyTrainingCadre> implements DailyTrainingCadreService {

    @Resource
    private DailyTrainingService trainingService;

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    public boolean save(DailyTrainingCadre trainingCadre) {
        validate(trainingCadre);
        return super.save(trainingCadre);
    }

    @Override
    public boolean updateById(DailyTrainingCadre trainingCadre) {
        validate(trainingCadre);
        return super.updateById(trainingCadre);
    }

    private void validate(DailyTrainingCadre trainingCadre) {
        if (trainingCadre.getTrainingId() == null) {
            throw new BusinessException("培训计划不能为空");
        }
        if (trainingCadre.getCadreId() == null) {
            throw new BusinessException("参训干部不能为空");
        }
        if (trainingService.getById(trainingCadre.getTrainingId()) == null) {
            throw new BusinessException("培训计划不存在");
        }
        if (cadreInfoService.getById(trainingCadre.getCadreId()) == null) {
            throw new BusinessException("干部档案不存在");
        }
        if (trainingCadre.getId() == null) {
            long dup = count(new LambdaQueryWrapper<DailyTrainingCadre>()
                    .eq(DailyTrainingCadre::getTrainingId, trainingCadre.getTrainingId())
                    .eq(DailyTrainingCadre::getCadreId, trainingCadre.getCadreId()));
            if (dup > 0) {
                throw new BusinessException("该干部已参加此培训，请勿重复添加");
            }
        }
        if (trainingCadre.getIsCompleted() == null) {
            trainingCadre.setIsCompleted(0);
        }
    }
}
