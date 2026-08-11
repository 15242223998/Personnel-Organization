package com.personnel.modules.daily.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("daily_self_application")
public class DailySelfApplication extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long applicantId;
    private String applicationType;
    private String applicationTitle;
    private String applicationContent;
    private String applyStatus;
    private Long approverId;
    private LocalDateTime approveTime;
    private String approveComment;
}
