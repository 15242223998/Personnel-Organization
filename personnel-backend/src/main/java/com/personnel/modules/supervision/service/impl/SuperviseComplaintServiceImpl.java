package com.personnel.modules.supervision.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.supervision.entity.SuperviseComplaint;
import com.personnel.modules.supervision.mapper.SuperviseComplaintMapper;
import com.personnel.modules.supervision.service.SuperviseComplaintService;
import org.springframework.stereotype.Service;

@Service
public class SuperviseComplaintServiceImpl extends ServiceImpl<SuperviseComplaintMapper, SuperviseComplaint> implements SuperviseComplaintService {
}
