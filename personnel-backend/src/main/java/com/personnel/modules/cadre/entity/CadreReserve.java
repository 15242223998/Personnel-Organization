package com.personnel.modules.cadre.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cadre_reserve")
public class CadreReserve extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;

    private String reserveType;

    private String reserveLevel;

    private LocalDate enterDate;

    private Integer status;
}
