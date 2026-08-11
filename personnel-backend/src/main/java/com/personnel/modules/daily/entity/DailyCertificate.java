package com.personnel.modules.daily.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("daily_certificate")
public class DailyCertificate extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;
    private String certType;
    private String certNumber;
    private String certStatus;
    private LocalDate borrowDate;
    private LocalDate returnDate;
    private LocalDate expectedReturnDate;
    private String remark;
}
