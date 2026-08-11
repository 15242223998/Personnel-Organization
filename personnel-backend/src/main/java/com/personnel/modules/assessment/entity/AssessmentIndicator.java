package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("assessment_indicator")
public class AssessmentIndicator {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long dimensionId;
    private String indicatorName;
    private BigDecimal maxScore;
    private Integer sortOrder;

    @TableLogic
    private Integer deleted;
}
