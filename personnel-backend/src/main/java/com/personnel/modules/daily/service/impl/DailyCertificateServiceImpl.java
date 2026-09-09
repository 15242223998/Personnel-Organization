package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyAbroadRecord;
import com.personnel.modules.daily.entity.DailyCertificate;
import com.personnel.modules.daily.mapper.DailyCertificateMapper;
import com.personnel.modules.daily.service.DailyAbroadRecordService;
import com.personnel.modules.daily.service.DailyCertificateService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;

/**
 * 证照台账：规范校验 + 出境记录联动（领用须关联已批准出国(境)）
 */
@Service
public class DailyCertificateServiceImpl extends ServiceImpl<DailyCertificateMapper, DailyCertificate> implements DailyCertificateService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Resource
    private DailyAbroadRecordService abroadRecordService;

    @Override
    public boolean save(DailyCertificate certificate) {
        validate(certificate);
        return super.save(certificate);
    }

    @Override
    public boolean updateById(DailyCertificate certificate) {
        validate(certificate);
        return super.updateById(certificate);
    }

    private void validate(DailyCertificate certificate) {
        if (certificate.getCadreId() == null) {
            throw new BusinessException("所属干部不能为空");
        }
        CadreInfo cadre = cadreInfoService.getById(certificate.getCadreId());
        if (cadre == null) {
            throw new BusinessException("干部档案不存在");
        }
        if (!StringUtils.hasText(certificate.getCertType())) {
            throw new BusinessException("证照类型不能为空");
        }
        if (!StringUtils.hasText(certificate.getCertNumber())) {
            throw new BusinessException("证照编号不能为空");
        }
        boolean borrowed = certificate.getBorrowDate() != null
                || (certificate.getCertStatus() != null && certificate.getCertStatus().contains("借"));
        if (borrowed && certificate.getBorrowDate() == null) {
            throw new BusinessException("领用证照必须填写领用日期");
        }
        LocalDate borrow = certificate.getBorrowDate();
        if (borrow != null && certificate.getReturnDate() != null
                && certificate.getReturnDate().isBefore(borrow)) {
            throw new BusinessException("交回日期不能早于领用日期");
        }
        if (borrow != null && borrow.isAfter(LocalDate.now())) {
            throw new BusinessException("领用日期不能是未来日期");
        }
        // 证照集中保管：领用须关联一条已批准出国(境)记录（出境记录 → 证照领用）
        boolean openingLend = certificate.getCertStatus() != null
                && certificate.getCertStatus().contains("借")
                && certificate.getReturnDate() == null;
        if (openingLend) {
            if (certificate.getAbroadId() == null) {
                throw new BusinessException("证照领用须关联一条已批准的出国(境)记录");
            }
            DailyAbroadRecord trip = abroadRecordService.getById(certificate.getAbroadId());
            if (trip == null || trip.getCadreId() == null
                    || !trip.getCadreId().equals(certificate.getCadreId())
                    || trip.getIsApproved() == null || trip.getIsApproved() != 1
                    || trip.getDepartDate() == null) {
                throw new BusinessException("关联的出国(境)记录无效或未获批准，不能领用证照");
            }
            if (trip.getDepartDate().isBefore(borrow)) {
                throw new BusinessException("所选出国(境)记录已过期，不能作为本次领用依据");
            }
            // 预计交回日期按行程返回日期自动生成
            if (certificate.getExpectedReturnDate() == null) {
                certificate.setExpectedReturnDate(trip.getReturnDate());
            }
            if (certificate.getExpectedReturnDate() == null
                    || certificate.getExpectedReturnDate().isBefore(borrow)) {
                throw new BusinessException("预计交回日期必须不早于领用日期");
            }
        }
    }
}
