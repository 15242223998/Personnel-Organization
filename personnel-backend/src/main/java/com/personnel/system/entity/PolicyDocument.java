package com.personnel.system.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

/**
 * 政策法规文档
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("policy_document")
public class PolicyDocument extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 标题 */
    private String title;
    /** 文号 */
    private String docNo;
    /** 发布单位 */
    private String publishUnit;
    /** 发布日期 */
    private LocalDate issueDate;
    /** 施行日期 */
    private LocalDate effectiveDate;
    /** 分类 党内法规/干部选拔/干部监督/教育培训/其他 */
    private String category;
    /** 正文 */
    private String content;
    /** 附件名称 */
    private String attachmentName;
    /** 附件地址 */
    private String attachmentUrl;
}
