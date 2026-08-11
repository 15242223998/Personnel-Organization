package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("assessment_vote")
public class AssessmentVote {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long schemeId;
    private Long voterId;
    private Long targetCadreId;
    private Long indicatorId;
    private BigDecimal score;
    private LocalDateTime voteTime;
}
