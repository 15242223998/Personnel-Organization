package com.personnel.modules.supervision.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 预警规则配置（持久化）；预警生成逻辑可基于 threshold 后续实现
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("supervise_alert_rule")
public class SuperviseAlertRule extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 规则名称 */
    private String ruleName;

    /** 预警类型：证件到期/出国超期/休假超时/任职超期/到龄退休 等 */
    private String ruleType;

    /** 预警级别：红色/橙色/黄色 */
    private String level;

    /** 触发阈值（天数或数值） */
    private Integer threshold;

    /** 是否启用 1启用 0停用（默认 1） */
    private Integer isEnabled;

    /** 备注 */
    private String remark;
}
