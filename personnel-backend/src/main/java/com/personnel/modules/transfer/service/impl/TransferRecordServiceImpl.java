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
import java.io.Serializable;
import java.time.LocalDate;
import java.util.Objects;

@Service
public class TransferRecordServiceImpl extends ServiceImpl<TransferRecordMapper, TransferRecord> implements TransferRecordService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    @Transactional
    public boolean save(TransferRecord record) {
        validateRequired(record);
        CadreInfo cadre = cadreInfoService.getById(record.getCadreId());
        if (cadre == null) {
            throw new BusinessException("调配对象不存在，请刷新后重试");
        }
        boolean result = super.save(record);
        // 新增调配后即时联动档案（与历史行为保持一致）
        applyRecordToCadre(record, cadre);
        return result;
    }

    /**
     * 编辑调配记录：校验记录存在与必填字段后更新；
     * 更新后按该干部剩余调配记录的最新一条重算档案状态。
     */
    @Override
    @Transactional
    public boolean updateById(TransferRecord record) {
        if (record == null || record.getId() == null) {
            throw new BusinessException("调配记录ID不能为空");
        }
        TransferRecord existing = getById(record.getId());
        if (existing == null) {
            throw new BusinessException("调配记录不存在或已删除，请刷新后重试");
        }
        // 未传字段沿用原值，据此校验必填（与实体 NOT NULL 列及新增校验口径一致）
        Long cadreId = record.getCadreId() != null ? record.getCadreId() : existing.getCadreId();
        String transferType = StringUtils.hasText(record.getTransferType()) ? record.getTransferType() : existing.getTransferType();
        LocalDate transferDate = record.getTransferDate() != null ? record.getTransferDate() : existing.getTransferDate();
        if (cadreId == null) {
            throw new BusinessException("调配干部不能为空");
        }
        if (!StringUtils.hasText(transferType)) {
            throw new BusinessException("调配类型不能为空");
        }
        if (transferDate == null) {
            throw new BusinessException("调配日期不能为空");
        }
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            throw new BusinessException("调配对象不存在，请刷新后重试");
        }
        boolean updated = super.updateById(record);
        recomputeCadreStatus(cadreId);
        // 若把记录改派到另一位干部，原干部档案也需按剩余记录重算
        if (!Objects.equals(existing.getCadreId(), cadreId)) {
            recomputeCadreStatus(existing.getCadreId());
        }
        return updated;
    }

    /**
     * 删除调配记录（沿用逻辑删除）：删除后按该干部剩余调配记录重算档案状态。
     */
    @Override
    @Transactional
    public boolean removeById(Serializable id) {
        TransferRecord existing = getById(id);
        if (existing == null) {
            throw new BusinessException("调配记录不存在或已删除，请刷新后重试");
        }
        boolean removed = super.removeById(id);
        recomputeCadreStatus(existing.getCadreId());
        return removed;
    }

    /** 新增/编辑公共必填校验：干部、调配类型、调配日期（与表 NOT NULL 约束一致） */
    private void validateRequired(TransferRecord record) {
        if (record == null || record.getCadreId() == null) {
            throw new BusinessException("调配干部不能为空");
        }
        if (!StringUtils.hasText(record.getTransferType())) {
            throw new BusinessException("调配类型不能为空");
        }
        if (record.getTransferDate() == null) {
            throw new BusinessException("调配日期不能为空");
        }
    }

    /**
     * 按该干部现存（未删除）调配记录重算档案状态。
     * 重算规则（取调配日期最新一条，同日取记录 id 较大者）：
     *  - type=退休                       → cadre_status=RETIRED
     *  - type=调出                       → cadre_status=TRANSFERRED
     *  - type=辞职/辞退/离职              → cadre_status=RESIGNED（与新增时的联动一致）
     *  - type=调入/录用/聘用/转入/轮岗及其它 → cadre_status=ON_JOB（在职）
     *  - 没有任何调配记录                  → 恢复 cadre_status=ON_JOB（在职）
     */
    private void recomputeCadreStatus(Long cadreId) {
        if (cadreId == null) {
            return;
        }
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            return;
        }
        TransferRecord latest = lambdaQuery()
                .eq(TransferRecord::getCadreId, cadreId)
                .orderByDesc(TransferRecord::getTransferDate)
                .orderByDesc(TransferRecord::getId)
                .last("LIMIT 1")
                .one();
        String status = CadreStatus.ON_JOB;
        if (latest != null && StringUtils.hasText(latest.getTransferType())) {
            status = resolveStatusByType(latest.getTransferType());
        }
        if (!Objects.equals(cadre.getCadreStatus(), status)) {
            cadre.setCadreStatus(status);
            cadreInfoService.updateById(cadre);
        }
    }

    /** 调配类型 → 干部状态映射（新增联动与重算共用同一规则） */
    private String resolveStatusByType(String transferType) {
        if ("退休".equals(transferType)) {
            return CadreStatus.RETIRED;
        }
        if ("调出".equals(transferType)) {
            return CadreStatus.TRANSFERRED;
        }
        if ("辞职".equals(transferType) || "辞退".equals(transferType) || "离职".equals(transferType)) {
            return CadreStatus.RESIGNED;
        }
        // 调入/录用/聘用/转入/轮岗及其它类型：保持/回到在职
        return CadreStatus.ON_JOB;
    }

    /** 新增调配时对档案的即时联动（保留原有行为：退休/离职/辞退落减员日期与原因，调出与内部调动同步目标机构/职务） */
    private void applyRecordToCadre(TransferRecord record, CadreInfo cadre) {
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
    }
}
