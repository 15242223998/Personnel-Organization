package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

@Data
@TableName("assessment_target")
public class AssessmentTarget {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long schemeId;
    private Long cadreId;

    @TableLogic
    private Integer deleted;
}
