package com.personnel.modules.transfer.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.transfer.entity.RankPromotionRecord;
import com.personnel.modules.transfer.vo.PromotionEligibleVO;

public interface RankPromotionRecordService extends IService<RankPromotionRecord> {

    /**
     * 晋升资格判定：返回符合晋升条件的在职干部分页
     *
     * @param fromRankId 拟晋升目标职级ID（可空，空表示不限制目标职级）
     * @param keyword    姓名模糊关键字（可空）
     */
    Page<PromotionEligibleVO> eligiblePage(long current, long size, Long fromRankId, String keyword);
}
