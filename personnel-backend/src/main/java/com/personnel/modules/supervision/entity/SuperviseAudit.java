package com.personnel.modules.supervision.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

/**
 * 经济责任审计记录
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("supervise_audit")
public class SuperviseAudit extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 干部ID */
    private Long cadreId;
    /** 审计范围 任期经济责任审计/离任审计/专项审计 */
    private String auditScope;
    /** 审计期间开始 */
    private LocalDate auditPeriodStart;
    /** 审计期间结束 */
    private LocalDate auditPeriodEnd;
    /** 审计机构 */
    private String auditOrg;
    /** 实施开始时间 */
    private LocalDate startTime;
    /** 实施结束时间 */
    private LocalDate endTime;
    /** 审计结论 无重大问题/基本正常/存在需整改问题/重大问题 */
    private String auditResult;
    /** 发现问题 */
    private String issue;
    /** 整改状态 待整改/整改中/已整改 */
    private String rectifyStatus;
    /** 报告附件地址 */
    private String auditReportUrl;
}
