package com.personnel.modules.assessment.vo;

import com.personnel.modules.assessment.entity.AssessmentScheme;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 平板端方案详情 VO：方案 + 当前用户进度 + 测评对象 + 维度指标
 */
@Data
public class TabletSchemeDetailVO {

    /** 方案全量字段（含 voteMode/needSign） */
    private AssessmentScheme scheme;

    /** 投票方式 SCORE评分式/BALLOT表决式（冗余，便于平板端直接取用） */
    private String voteMode;

    /** 是否需要签字确认（冗余，便于平板端直接取用） */
    private Integer needSign;

    /** 是否已签字确认 */
    private Boolean signed;

    /** 测评对象列表 */
    private List<TargetItem> targets;

    /** 维度/指标树（表决式方案可为空） */
    private List<DimensionNode> dimensions;

    @Data
    public static class TargetItem {
        private Long cadreId;
        private String cadreName;
        private String deptName;
        private String position;
        private String materialTitle;
        private String materialText;

        /** 本人是否已对该对象投票/表决 */
        private Boolean voted;

        /** 本人表决意见（BALLOT）：APPROVE/DISAPPROVE/ABSTAIN */
        private String choice;

        /** 本人已打分数（SCORE）：指标ID -> 分数 */
        private Map<Long, BigDecimal> scores;
    }

    @Data
    public static class DimensionNode {
        private Long id;
        private String dimensionName;
        private BigDecimal dimensionWeight;
        private List<IndicatorItem> indicators;
    }

    @Data
    public static class IndicatorItem {
        private Long id;
        private String indicatorName;
        private BigDecimal maxScore;
    }
}
