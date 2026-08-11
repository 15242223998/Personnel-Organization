package com.personnel.modules.supervision.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.supervision.entity.SuperviseAlert;
import com.personnel.modules.supervision.mapper.SuperviseAlertMapper;
import com.personnel.modules.supervision.service.SuperviseAlertService;
import org.springframework.stereotype.Service;

@Service
public class SuperviseAlertServiceImpl extends ServiceImpl<SuperviseAlertMapper, SuperviseAlert> implements SuperviseAlertService {
}
