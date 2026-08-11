package com.personnel.modules.organization.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.organization.entity.PositionLevel;
import com.personnel.modules.organization.mapper.PositionLevelMapper;
import com.personnel.modules.organization.service.PositionLevelService;
import org.springframework.stereotype.Service;

@Service
public class PositionLevelServiceImpl extends ServiceImpl<PositionLevelMapper, PositionLevel> implements PositionLevelService {
}
