package com.personnel.modules.supervision.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("supervise_alert")
public class SuperviseAlert {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String alertType;
    private String alertCategory;
    private String alertTitle;
    private String alertContent;
    private Long targetUserId;
    private Long targetCadreId;
    private Integer isRead;
    private LocalDateTime readTime;
    private LocalDateTime createTime;

    @TableLogic
    private Integer deleted;
}
