package com.personnel.modules.transfer.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.common.CadreStatus;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.transfer.entity.TransferRecord;
import com.personnel.modules.transfer.mapper.TransferRecordMapper;
import com.personnel.modules.transfer.service.TransferRecordService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import jakarta.annotation.Resource;

@Service
public class TransferRecordServiceImpl extends ServiceImpl<TransferRecordMapper, TransferRecord> implements TransferRecordService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    @Transactional
    public boolean save(TransferRecord record) {
        boolean result = super.save(record);
        CadreInfo cadre = cadreInfoService.getById(record.getCadreId());
        if (cadre == null) {
            throw new BusinessException("调配对象不存在，请刷新后重试");
        }
        String transferType = record.getTransferType();
        if ("退休".equals(transferType)) {
            cadre.setCadreStatus(CadreStatus.RETIRED);
            cadre.setLeaveDate(record.getTransferDate());
            cadre.setLeaveReason("退休");
        } else if ("离职".equals(transferType)) {
            cadre.setCadreStatus(CadreStatus.RESIGNED);
            cadre.setLeaveDate(record.getTransferDate());
            cadre.setLeaveReason("离职");
        } else if ("辞退".equals(transferType)) {
            cadre.setCadreStatus(CadreStatus.RESIGNED);
            cadre.setLeaveDate(record.getTransferDate());
            cadre.setLeaveReason("辞退");
        } else {
            // 调出或内部调动等：仅同步目标机构与职务
            if (record.getToDeptId() != null) {
                cadre.setDeptId(record.getToDeptId());
            }
            if (StringUtils.hasText(record.getToPosition())) {
                cadre.setPosition(record.getToPosition());
            }
            if ("调出".equals(transferType)) {
                cadre.setCadreStatus(CadreStatus.TRANSFERRED);
            } else if (cadre.getCadreStatus() == null) {
                cadre.setCadreStatus(CadreStatus.ON_JOB);
            }
        }
        cadreInfoService.updateById(cadre);
        return result;
    }
}
