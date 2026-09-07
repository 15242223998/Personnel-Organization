package com.personnel.modules.assessment.vo;

import com.personnel.modules.assessment.entity.AssessmentAnnual;
import lombok.Data;

/**
 * 年度考核列表 VO：带干部姓名/部门/职务
 */
@Data
public class AnnualVO {

    private Long id;

    private Long cadreId;

    private String cadreName;

    private String deptName;

    private String position;

    private String assessmentYear;

    private String assessmentResult;

    private String assessmentComment;
}
