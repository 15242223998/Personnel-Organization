package com.personnel.modules.assessment.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 签字留证 VO
 */
@Data
public class SignatureVO {

    private Long voterId;

    private String voterName;

    private LocalDateTime signTime;

    private String deviceIp;

    private String signMd5;

    /** 签字图片 base64 数据（不含 dataURL 前缀） */
    private String imageData;
}
