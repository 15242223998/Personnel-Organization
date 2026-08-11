package com.personnel.modules.organization.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("org_staffing_quota")
public class StaffingQuota extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long deptId;

    private Integer approvedQuota;

    private Integer leaderQuota;
}
