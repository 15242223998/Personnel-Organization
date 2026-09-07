package com.personnel.modules.assessment.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.Map;

/**
 * 民主测评结果 VO：单个被评干部的维度得分与总分
 */
@Data
public class VoteResultItemVO {

    private Long targetCadreId;

    private String cadreName;

    private String deptName;

    /** 维度ID -> 平均得分 */
    private Map<Long, BigDecimal> dimensionScores;

    /** 总分（各维度平均分之和） */
    private BigDecimal totalScore;

    /** 该对象的参评人数（去重） */
    private Long voterCount;
}
