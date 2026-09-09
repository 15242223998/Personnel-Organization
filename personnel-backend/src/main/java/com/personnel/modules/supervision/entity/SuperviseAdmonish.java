package com.personnel.modules.supervision.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 提醒函询诫勉记录
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("supervise_admonish")
public class SuperviseAdmonish extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 干部ID */
    private Long cadreId;
    /** 类型 提醒谈话/函询/诫勉 */
    private String admonishType;
    /** 触发事由 */
    private String triggerType;
    /** 内容 */
    private String content;
    /** 处理结果 */
    private String result;
    /** 纪律处分类别 */
    private String discipline;
    /** 处理状态 待处理/已办结 */
    private String handleStatus;
    /** 处理人 */
    private String handleUser;
    /** 处理时间 */
    private LocalDateTime handleTime;
}
