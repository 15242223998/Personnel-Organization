package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.assessment.entity.AssessmentDimension;
import com.personnel.modules.assessment.mapper.AssessmentDimensionMapper;
import com.personnel.modules.assessment.service.AssessmentDimensionService;
import org.springframework.stereotype.Service;

@Service
public class AssessmentDimensionServiceImpl extends ServiceImpl<AssessmentDimensionMapper, AssessmentDimension> implements AssessmentDimensionService {
}
