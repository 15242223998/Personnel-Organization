package com.personnel.modules.cadre.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.common.CadreStatus;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.entity.CadreReserve;
import com.personnel.modules.cadre.mapper.CadreReserveMapper;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.cadre.service.CadreReserveService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CadreReserveServiceImpl extends ServiceImpl<CadreReserveMapper, CadreReserve> implements CadreReserveService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    @Transactional
    public boolean save(CadreReserve entity) {
        validateCadre(entity.getCadreId());
        return super.save(entity);
    }

    @Override
    @Transactional
    public boolean updateById(CadreReserve entity) {
        if (entity.getCadreId() != null) {
            validateCadre(entity.getCadreId());
        }
        return super.updateById(entity);
    }

    /**
     * 校验后备对象必须是系统中存在的在职干部
     */
    private void validateCadre(Long cadreId) {
        if (cadreId == null) {
            throw new BusinessException("请选择要纳入后备库的干部");
        }
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            throw new BusinessException("所选干部不存在，无法纳入后备库");
        }
        if (cadre.getCadreStatus() != null && !CadreStatus.ON_JOB.equals(cadre.getCadreStatus())) {
            throw new BusinessException("仅在职干部可纳入后备库");
        }
    }
}
