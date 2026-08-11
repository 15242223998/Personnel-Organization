package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("assessment_scheme")
public class AssessmentScheme extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String schemeName;
    private String schemeYear;
    private LocalDateTime voteStartTime;
    private LocalDateTime voteEndTime;
    private Integer allowAnonymous;
    private BigDecimal excellentMaxRatio;
    private Integer forbidAllExcellent;
    private String status;
}
