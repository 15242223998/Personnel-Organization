package com.personnel.modules.appointment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

/**
 * 干部考察登记（独立于任免流程的组织考察记录）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cadre_investigation")
public class CadreInvestigation extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 干部ID */
    private Long cadreId;
    /** 考察类型 任前考察/年度考核考察/专项考察/换届考察 */
    private String investigationType;
    /** 考察时间 */
    private LocalDate investigationTime;
    /** 考察组成员 */
    private String investigator;
    /** 考察结论 优秀/称职/基本称职/其他 */
    private String result;
    /** 考察材料 */
    private String content;
    /** 组织单位 */
    private String orgUnit;
}
