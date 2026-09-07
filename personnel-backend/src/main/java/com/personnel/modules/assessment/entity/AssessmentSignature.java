package com.personnel.modules.assessment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 投票签字留证（平板评审签字图片 + MD5 + 设备IP）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("assessment_signature")
public class AssessmentSignature extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long schemeId;
    private Long voterId;

    /** 签字图片二进制(PNG) */
    private byte[] signImage;

    /** 签字图片MD5（防篡改留证） */
    private String signMd5;

    /** 设备IP */
    private String deviceIp;

    /** 签字时间 */
    private LocalDateTime signTime;
}
