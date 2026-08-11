package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("assessment_dimension")
public class AssessmentDimension {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long schemeId;
    private String dimensionName;
    private BigDecimal dimensionWeight;
    private Integer sortOrder;

    @TableLogic
    private Integer deleted;
}
