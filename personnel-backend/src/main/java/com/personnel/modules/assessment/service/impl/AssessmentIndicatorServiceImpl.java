package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.assessment.entity.AssessmentIndicator;
import com.personnel.modules.assessment.mapper.AssessmentIndicatorMapper;
import com.personnel.modules.assessment.service.AssessmentIndicatorService;
import org.springframework.stereotype.Service;

@Service
public class AssessmentIndicatorServiceImpl extends ServiceImpl<AssessmentIndicatorMapper, AssessmentIndicator> implements AssessmentIndicatorService {
}
