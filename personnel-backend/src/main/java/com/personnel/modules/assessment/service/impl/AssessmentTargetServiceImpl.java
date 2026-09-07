package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.assessment.entity.AssessmentTarget;
import com.personnel.modules.assessment.mapper.AssessmentTargetMapper;
import com.personnel.modules.assessment.service.AssessmentTargetService;
import org.springframework.stereotype.Service;

@Service
public class AssessmentTargetServiceImpl extends ServiceImpl<AssessmentTargetMapper, AssessmentTarget> implements AssessmentTargetService {

    @Override
    public void updateRemark(Long id, AssessmentTarget target) {
        if (getById(id) == null) {
            throw new BusinessException("测评对象不存在");
        }
        // 仅更新测评材料等备注字段；schemeId/cadreId 为业务归属字段，一律不允许通过该接口改动
        AssessmentTarget update = new AssessmentTarget();
        update.setId(id);
        update.setMaterialTitle(target.getMaterialTitle());
        update.setMaterialText(target.getMaterialText());
        updateById(update);
    }
}
