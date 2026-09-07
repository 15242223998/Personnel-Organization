package com.personnel.modules.assessment.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.assessment.entity.AssessmentTarget;

public interface AssessmentTargetService extends IService<AssessmentTarget> {

    /** 更新测评对象备注字段（materialTitle/materialText），禁止修改 schemeId/cadreId */
    void updateRemark(Long id, AssessmentTarget target);
}
