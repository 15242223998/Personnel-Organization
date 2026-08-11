package com.personnel.modules.organization.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("org_rank")
public class OrganizationRank extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String rankName;

    private String rankType;

    private Integer promotionYears;

    private Integer sortOrder;

    private Integer status;
}
