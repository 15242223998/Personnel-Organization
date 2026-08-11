package com.personnel.system.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_roster_template")
public class SysRosterTemplate extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String templateName;

    private String templateFields;

    private Integer isSystem;
}
