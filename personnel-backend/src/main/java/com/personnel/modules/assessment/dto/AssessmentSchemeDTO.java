package com.personnel.modules.assessment.dto;

import com.personnel.modules.assessment.entity.AssessmentScheme;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * 考核方案创建/编辑 DTO：方案 + 维度/指标模板
 */
@Data
public class AssessmentSchemeDTO {

    private AssessmentScheme scheme;

    private List<DimensionDTO> dimensions;

    @Data
    public static class DimensionDTO {
        private String dimensionName;
        private BigDecimal dimensionWeight;
        private Integer sortOrder;
        private List<IndicatorDTO> indicators;
    }

    @Data
    public static class IndicatorDTO {
        private String indicatorName;
        private BigDecimal maxScore;
        private Integer sortOrder;
    }
}
