package com.personnel.modules.transfer.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.transfer.entity.TransferRecord;
import com.personnel.modules.transfer.mapper.TransferRecordMapper;
import com.personnel.modules.transfer.service.TransferRecordService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
        if (cadre != null) {
            String transferType = record.getTransferType();
            if ("调出".equals(transferType) || "退休".equals(transferType) || "离职".equals(transferType) || "辞退".equals(transferType)) {
                cadre.setCadreStatus("离退状态");
                cadre.setLeaveDate(record.getTransferDate());
                if ("退休".equals(transferType)) {
                    cadre.setLeaveReason("退休");
                } else if ("离职".equals(transferType)) {
                    cadre.setLeaveReason("离职");
                } else {
                    cadre.setLeaveReason(record.getTransferReason());
                }
            }
            cadre.setDeptId(record.getToDeptId());
            cadre.setPosition(record.getToPosition());
            cadreInfoService.updateById(cadre);
        }
        return result;
    }
}
