package com.personnel.modules.appointment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("appoint_investigation")
public class AppointInvestigation extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long processId;
    private Integer archiveCheck;
    private String archiveIssue;
    private Integer personalReportCheck;
    private String personalReportIssue;
    private Integer disciplineCheck;
    private String disciplineIssue;
    private Integer complaintCheck;
    private String complaintIssue;
    private Integer isPassed;
}
