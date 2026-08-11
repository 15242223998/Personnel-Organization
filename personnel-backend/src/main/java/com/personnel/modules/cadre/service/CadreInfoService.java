package com.personnel.modules.cadre.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.cadre.entity.CadreInfo;

import java.util.List;

public interface CadreInfoService extends IService<CadreInfo> {

    Page<CadreInfo> pageQuery(Page<CadreInfo> page, CadreInfo query);

    CadreInfo getDetailById(Long id);

    List<CadreInfo> exportList(CadreInfo query);
}
