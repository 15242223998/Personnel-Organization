package com.personnel.modules.organization.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.organization.entity.Organization;

import java.util.List;

public interface OrganizationService extends IService<Organization> {

    List<Organization> getTree();
}
