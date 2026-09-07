package com.personnel.modules.daily.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyCertificate;
import com.personnel.modules.daily.mapper.DailyCertificateMapper;
import com.personnel.modules.daily.service.DailyCertificateService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;

/**
 * 证照台账：规范校验
 */
@Service
public class DailyCertificateServiceImpl extends ServiceImpl<DailyCertificateMapper, DailyCertificate> implements DailyCertificateService {

    @Resource
    private CadreInfoService cadreInfoService;

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
        // 借出必须有借出日期；归还日期不得早于借出日期
        boolean borrowed = certificate.getBorrowDate() != null
                || (certificate.getCertStatus() != null && certificate.getCertStatus().contains("借"));
        if (borrowed && certificate.getBorrowDate() == null) {
            throw new BusinessException("借出证照必须填写借出日期");
        }
        LocalDate borrow = certificate.getBorrowDate();
        if (borrow != null && certificate.getReturnDate() != null
                && certificate.getReturnDate().isBefore(borrow)) {
            throw new BusinessException("归还日期不能早于借出日期");
        }
        if (borrow != null && borrow.isAfter(LocalDate.now())) {
            throw new BusinessException("借出日期不能是未来日期");
        }
    }
}
