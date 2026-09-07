package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 表决式投票记录（平板评审 APPROVE赞成/DISAPPROVE反对/ABSTAIN弃权）
 */
@Data
@TableName("assessment_ballot")
public class AssessmentBallot {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long schemeId;
    private Long voterId;
    private Long targetCadreId;

    /** 表决意见 APPROVE赞成/DISAPPROVE反对/ABSTAIN弃权 */
    private String choice;

    private LocalDateTime createTime;

    @TableLogic
    private Integer deleted;
}
