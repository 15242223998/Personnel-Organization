package com.personnel.modules.appointment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("appoint_motion")
public class AppointMotion extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long processId;
    private String positionCondition;
    private String candidateIds;
    private Long selectedCadreId;
    private String motionStatus;
    private String meetingFileUrl;
}
