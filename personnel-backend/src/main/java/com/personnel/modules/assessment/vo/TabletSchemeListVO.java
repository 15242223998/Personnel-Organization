package com.personnel.modules.assessment.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 平板端进行中方案列表项 VO
 */
@Data
public class TabletSchemeListVO {

    private Long id;

    private String schemeName;

    private String schemeYear;

    /** SCORE评分式/BALLOT表决式 */
    private String voteMode;

    /** 是否需要签字确认 */
    private Integer needSign;

    private LocalDateTime voteStartTime;

    private LocalDateTime voteEndTime;

    /** 当前用户是否已签字 */
    private Boolean signed;

    /** 测评对象总数 */
    private Long targetTotal;

    /** 当前用户已投（评/表决）对象数 */
    private Long votedTargetCount;
}
