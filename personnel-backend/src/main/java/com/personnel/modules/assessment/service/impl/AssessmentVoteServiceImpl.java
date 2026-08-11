package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.assessment.entity.AssessmentVote;
import com.personnel.modules.assessment.mapper.AssessmentVoteMapper;
import com.personnel.modules.assessment.service.AssessmentVoteService;
import org.springframework.stereotype.Service;

@Service
public class AssessmentVoteServiceImpl extends ServiceImpl<AssessmentVoteMapper, AssessmentVote> implements AssessmentVoteService {
}
