package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("assessment_annual")
public class AssessmentAnnual extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;
    private String assessmentYear;
    private String assessmentResult;
    private String assessmentComment;
}
