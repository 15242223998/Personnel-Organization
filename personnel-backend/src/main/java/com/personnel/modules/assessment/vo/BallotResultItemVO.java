package com.personnel.modules.assessment.vo;

import lombok.Data;

/**
 * 表决结果计票 VO（按测评对象汇总赞成/反对/弃权）
 */
@Data
public class BallotResultItemVO {

    private Long cadreId;

    private String cadreName;

    private Long approve;

    private Long disapprove;

    private Long abstain;
}
