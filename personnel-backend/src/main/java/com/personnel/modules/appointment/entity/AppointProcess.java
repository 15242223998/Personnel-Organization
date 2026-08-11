package com.personnel.modules.appointment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("appoint_process")
public class AppointProcess extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String positionInfo;
    private String currentStep;
    private String processStatus;
    private Long cadreId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;

    @TableField(exist = false)
    private AppointMotion motion;
    @TableField(exist = false)
    private AppointRecommend recommend;
    @TableField(exist = false)
    private AppointInvestigation investigation;
    @TableField(exist = false)
    private AppointDecision decision;
    @TableField(exist = false)
    private AppointPublicity publicity;
    @TableField(exist = false)
    private AppointRecord record;
}
