package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.assessment.entity.AssessmentSignature;
import com.personnel.modules.assessment.mapper.AssessmentSignatureMapper;
import com.personnel.modules.assessment.service.AssessmentSignatureService;
import org.springframework.stereotype.Service;

@Service
public class AssessmentSignatureServiceImpl extends ServiceImpl<AssessmentSignatureMapper, AssessmentSignature> implements AssessmentSignatureService {
}
