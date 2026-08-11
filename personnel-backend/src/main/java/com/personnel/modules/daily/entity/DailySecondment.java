package com.personnel.modules.daily.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("daily_secondment")
public class DailySecondment extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;
    private String secondmentUnit;
    private String secondmentPosition;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private String remark;
}
