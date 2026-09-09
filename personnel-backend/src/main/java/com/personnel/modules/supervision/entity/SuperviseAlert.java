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

    /** 来源预警规则ID（supervise_alert_rule.id）；规则引擎生成时写入，手工录入可为空 */
    private Long ruleId;

    /** 规则扫描幂等引用（业务类型-业务主键，如 CERT-1 / ABROAD-2 / LEAVE-3 / TEAM-4 / RETIRE-5） */
    private String refId;

    @TableLogic
    private Integer deleted;
}
