package com.personnel.modules.transfer.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.transfer.entity.RankPromotionRecord;
import com.personnel.modules.transfer.mapper.RankPromotionRecordMapper;
import com.personnel.modules.transfer.service.RankPromotionRecordService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.Resource;
import java.time.LocalDate;

@Service
public class RankPromotionRecordServiceImpl extends ServiceImpl<RankPromotionRecordMapper, RankPromotionRecord> implements RankPromotionRecordService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    @Transactional
    public boolean save(RankPromotionRecord record) {
        boolean result = super.save(record);
        CadreInfo cadre = cadreInfoService.getById(record.getCadreId());
        if (cadre != null) {
            if (record.getToRankId() != null) {
                cadre.setRankId(record.getToRankId());
            }
            cadre.setPositionStartDate(LocalDate.now());
            cadreInfoService.updateById(cadre);
        }
        return result;
    }
}
