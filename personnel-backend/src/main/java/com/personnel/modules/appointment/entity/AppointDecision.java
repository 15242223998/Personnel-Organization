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
@TableName("appoint_decision")
public class AppointDecision extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long processId;
    private LocalDate meetingDate;
    private Integer approveCount;
    private Integer opposeCount;
    private Integer abstainCount;
    private Integer isPassed;
}
