package com.personnel.modules.organization.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

/**
 * 班子成员登记表
 * 以机构为维度手工维护的“班子”成员（党委/行政班子），
 * 与干部档案（cadre_info）中按职务层次派生的“参考班子”互相独立。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("org_team_member")
public class OrgTeamMember extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 机构ID（org_department.id） */
    private Long deptId;

    /** 干部ID（cadre_info.id） */
    private Long cadreId;

    /** 班子职务：党委书记/院长/副院长/党委副书记/纪委书记/部长/处长等 */
    private String leaderPost;

    /** 排序（越小越靠前） */
    private Integer sortOrder;

    /** 是否主要负责人 0否 1是 */
    private Integer isLeader;

    /** 任职开始日期（可空） */
    private LocalDate startDate;

    /** 任职结束日期（可空，空表示现任） */
    private LocalDate endDate;

    // ---------- 以下为列表/详情联表展示字段（非表字段） ----------
    /** 机构名称 */
    @TableField(exist = false)
    private String deptName;

    /** 干部姓名 */
    @TableField(exist = false)
    private String cadreName;

    /** 干部现任职务 */
    @TableField(exist = false)
    private String cadrePosition;

    /** 干部所在机构名称 */
    @TableField(exist = false)
    private String cadreDeptName;

    /** 干部档案状态 */
    @TableField(exist = false)
    private String cadreStatus;
}
