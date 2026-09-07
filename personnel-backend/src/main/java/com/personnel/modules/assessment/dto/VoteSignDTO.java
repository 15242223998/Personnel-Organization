package com.personnel.modules.assessment.dto;

import lombok.Data;

/**
 * 投票签字留证提交 DTO
 */
@Data
public class VoteSignDTO {

    private Long schemeId;

    /** 签字图片 dataURL(png)，形如 data:image/png;base64,xxxx */
    private String signImage;
}
