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

@Service
public class RankPromotionRecordServiceImpl extends ServiceImpl<RankPromotionRecordMapper, RankPromotionRecord> implements RankPromotionRecordService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Override
    @Transactional
    public boolean save(RankPromotionRecord record) {
        boolean result = super.save(record);
        CadreInfo cadre = cadreInfoService.getById(record.getCadreId());
        if (cadre == null) {
            throw new BusinessException("晋升对象不存在，请刷新后重试");
        }
        // 职级晋升只更新职级ID（职务与职务层次由任免/调配维护，避免覆盖）
        if (record.getToRankId() != null) {
            cadre.setRankId(record.getToRankId());
            cadreInfoService.updateById(cadre);
        }
        return result;
    }
}
