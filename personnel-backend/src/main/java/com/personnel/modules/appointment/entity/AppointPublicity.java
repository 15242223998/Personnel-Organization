package com.personnel.modules.appointment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("appoint_publicity")
public class AppointPublicity extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long processId;
    private LocalDate publicityStart;
    private LocalDate publicityEnd;
    private String publicityContent;
    private String reportInfo;
    private String publicityResult;
    private String remark;
}
