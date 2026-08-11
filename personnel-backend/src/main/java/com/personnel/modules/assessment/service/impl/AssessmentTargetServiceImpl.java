package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.assessment.entity.AssessmentTarget;
import com.personnel.modules.assessment.mapper.AssessmentTargetMapper;
import com.personnel.modules.assessment.service.AssessmentTargetService;
import org.springframework.stereotype.Service;

@Service
public class AssessmentTargetServiceImpl extends ServiceImpl<AssessmentTargetMapper, AssessmentTarget> implements AssessmentTargetService {
}
