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
@TableName("daily_abroad_record")
public class DailyAbroadRecord extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cadreId;
    private String destination;
    private String purpose;
    private LocalDate departDate;
    private LocalDate returnDate;
    private Integer approvedDays;
    private Integer actualDays;
    private Integer isOverdue;
    /** 是否经批准出国(境)：1已批准（可凭证照临时领用）0未批准 */
    private Integer isApproved;
}
