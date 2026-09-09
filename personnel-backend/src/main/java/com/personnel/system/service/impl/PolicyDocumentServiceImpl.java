package com.personnel.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.system.entity.PolicyDocument;
import com.personnel.system.mapper.PolicyDocumentMapper;
import com.personnel.system.service.PolicyDocumentService;
import org.springframework.stereotype.Service;

@Service
public class PolicyDocumentServiceImpl extends ServiceImpl<PolicyDocumentMapper, PolicyDocument> implements PolicyDocumentService {
}
