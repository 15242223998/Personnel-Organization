package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.daily.entity.DailyCertificate;
import com.personnel.modules.daily.mapper.DailyCertificateMapper;
import com.personnel.modules.daily.service.DailyCertificateService;
import org.springframework.stereotype.Service;

@Service
public class DailyCertificateServiceImpl extends ServiceImpl<DailyCertificateMapper, DailyCertificate> implements DailyCertificateService {
}
