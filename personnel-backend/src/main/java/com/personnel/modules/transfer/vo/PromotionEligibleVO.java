package com.personnel.modules.transfer.vo;

import lombok.Data;

import java.util.List;

/**
 * 职级晋升资格判定结果 VO（/api/promotion/eligible）
 */
@Data
public class PromotionEligibleVO {

    /** 干部ID（cadre_info.id），前端“一键带入”晋升办理表单使用 */
    private Long cadreId;

    private String name;

    /** 性别 1男 2女 */
    private Integer gender;

    /** 所在机构ID */
    private Long deptId;

    /** 所在机构名称 */
    private String deptName;

    /** 现任职务 */
    private String position;

    /** 现职务层次（校级/处级/科级等，档案原样展示） */
    private String positionLevel;

    /** 当前职级ID（org_rank.id） */
    private Long currentRankId;

    /** 当前职级名称 */
    private String currentRankName;

    /**
     * 当前职级展示编码：org_rank 表未设 code 列（实体 OrganizationRank 亦无），
     * 为满足展示约定按 rankType+sortOrder 派生（管理岗=GL-xx / 专业技术岗=ZY-xx），仅作展示，不落库。
     */
    private String currentRankCode;

    /** 当前职级排序 */
    private Integer currentRankSortOrder;

    /** 当前职级晋升所需任满年限（org_rank.promotion_years，缺失按 3 年计） */
    private Integer requiredYears;

    /** 满足年限说明（任现职/上次晋升起始日期、已任月数与所需年限） */
    private String yearsText;

    /**
     * 近三年考核核验是否达标（“近三年考核称职以上”，口径见
     * com.personnel.modules.assessment.support.AnnualAssessmentSupport）。
     * 本接口已对未达标干部做剔除，故列表内恒为 true。
     */
    private Boolean assessmentQualified;

    /**
     * 近三年考核核验不达标原因（中文数组，达标为空）。当前接口仅返回达标干部，
     * 该字段保留用于接口调试/后续放宽过滤时展示原因。
     */
    private List<String> eligibleReason;
}
