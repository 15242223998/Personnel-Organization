package com.personnel.modules.assessment.vo;

import com.personnel.modules.assessment.entity.AssessmentDimension;
import com.personnel.modules.assessment.entity.AssessmentIndicator;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import lombok.Data;

import java.util.List;

/**
 * 考核方案详情：方案 + 维度指标树 + 统计
 */
@Data
public class SchemeDetailVO {

    private AssessmentScheme scheme;

    private List<DimensionNode> dimensions;

    /** 测评对象数量 */
    private Long targetCount;

    /** 已参评人数（去重） */
    private Long voterCount;

    /** 已提交投票条数 */
    private Long voteCount;

    @Data
    public static class DimensionNode {
        private AssessmentDimension dimension;
        private List<AssessmentIndicator> indicators;
    }
}
