package com.personnel.modules.cadre.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cadre_family_member")
public class CadreFamilyMember extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;

    private String memberName;

    private String relation;

    private String workplace;

    private String phone;
}
