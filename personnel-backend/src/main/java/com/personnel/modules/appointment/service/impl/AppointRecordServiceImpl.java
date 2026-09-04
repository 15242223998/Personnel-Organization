package com.personnel.modules.appointment.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.common.CadreStatus;
import com.personnel.modules.appointment.entity.AppointRecord;
import com.personnel.modules.appointment.mapper.AppointRecordMapper;
import com.personnel.modules.appointment.service.AppointRecordService;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class AppointRecordServiceImpl extends ServiceImpl<AppointRecordMapper, AppointRecord> implements AppointRecordService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    @Transactional
    public boolean save(AppointRecord record) {
        // 备案默认作为当前任职
        if (record.getIsCurrent() == null) {
            record.setIsCurrent(1);
        }
        boolean result = super.save(record);
        if (record.getIsCurrent() != null && record.getIsCurrent() == 1) {
            applyToCadre(record);
        }
        return result;
    }

    @Override
    @Transactional
    public boolean updateById(AppointRecord record) {
        Integer isCurrent = record.getIsCurrent();
        if (isCurrent == null && record.getId() != null) {
            AppointRecord old = getById(record.getId());
            if (old != null) {
                isCurrent = old.getIsCurrent();
            }
        }
        boolean result = super.updateById(record);
        if (isCurrent != null && isCurrent == 1) {
            applyToCadre(record);
        }
        return result;
    }

    /**
     * 任职备案生效后同步干部档案中的“现任职务/部门/职级”，并只保留一条现任记录
     */
    private void applyToCadre(AppointRecord record) {
        if (record.getCadreId() == null) {
            throw new BusinessException("任职备案缺少干部信息");
        }
        CadreInfo cadre = cadreInfoService.getById(record.getCadreId());
        if (cadre == null) {
            throw new BusinessException("任职备案对应的干部不存在");
        }
        // 将该干部其他现任备案置为历史
        LambdaUpdateWrapper<AppointRecord> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(AppointRecord::getCadreId, cadre.getId())
                .eq(AppointRecord::getIsCurrent, 1)
                .set(AppointRecord::getIsCurrent, 0);
        if (record.getId() != null) {
            wrapper.ne(AppointRecord::getId, record.getId());
        }
        update(null, wrapper);

        if (record.getDeptId() != null) {
            cadre.setDeptId(record.getDeptId());
        }
        if (StringUtils.hasText(record.getPosition())) {
            cadre.setPosition(record.getPosition());
        }
        if (StringUtils.hasText(record.getPositionLevel())) {
            cadre.setPositionLevel(record.getPositionLevel());
        }
        if (record.getAppointDate() != null) {
            cadre.setPositionStartDate(record.getAppointDate());
        }
        if (StringUtils.hasText(record.getAppointDocNo())) {
            cadre.setPositionDocNo(record.getAppointDocNo());
        }
        // 任职后视为在职干部
        cadre.setCadreStatus(CadreStatus.ON_JOB);
        cadreInfoService.updateById(cadre);
    }
}
