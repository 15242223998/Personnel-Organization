package com.personnel.modules.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("transfer_record")
public class TransferRecord extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;
    private String transferType;
    private LocalDate transferDate;
    private String transferReason;
    private Long fromDeptId;
    private Long toDeptId;
    private String fromPosition;
    private String toPosition;
    private String docNo;
    private String remark;
}
