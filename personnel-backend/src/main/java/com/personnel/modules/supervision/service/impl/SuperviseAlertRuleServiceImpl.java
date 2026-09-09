package com.personnel.modules.supervision.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.supervision.entity.SuperviseAlertRule;
import com.personnel.modules.supervision.mapper.SuperviseAlertRuleMapper;
import com.personnel.modules.supervision.service.SuperviseAlertRuleService;
import org.springframework.stereotype.Service;

@Service
public class SuperviseAlertRuleServiceImpl
        extends ServiceImpl<SuperviseAlertRuleMapper, SuperviseAlertRule>
        implements SuperviseAlertRuleService {
}
