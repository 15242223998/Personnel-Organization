package com.personnel.modules.organization.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("org_position_level")
public class PositionLevel extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String levelName;

    private Integer minLowerYears;

    private Integer maxAge;

    private String minEducation;

    private String assessmentRequired;

    private Integer penaltyPeriodRestrict;

    private Integer sortOrder;

    private Integer status;
}
