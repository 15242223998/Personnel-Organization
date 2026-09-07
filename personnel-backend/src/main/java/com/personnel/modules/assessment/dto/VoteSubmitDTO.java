package com.personnel.modules.assessment.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.Map;

/**
 * 投票提交 DTO
 */
@Data
public class VoteSubmitDTO {

    private Long schemeId;

    private Long targetCadreId;

    /** 指标ID -> 分数 */
    private Map<Long, BigDecimal> scores;
}
