package com.personnel.modules.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rank_promotion_record")
public class RankPromotionRecord extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;
    private Long fromRankId;
    private Long toRankId;
    private LocalDate promotionDate;
    private String docNo;
    private String remark;
}
