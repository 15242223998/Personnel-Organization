package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.mapper.AssessmentSchemeMapper;
import com.personnel.modules.assessment.service.AssessmentSchemeService;
import org.springframework.stereotype.Service;

@Service
public class AssessmentSchemeServiceImpl extends ServiceImpl<AssessmentSchemeMapper, AssessmentScheme> implements AssessmentSchemeService {
}
