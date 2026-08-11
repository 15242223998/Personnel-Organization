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
@TableName("daily_training")
public class DailyTraining extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String trainingName;
    private String trainingType;
    private LocalDate startDate;
    private LocalDate endDate;
    private String trainingLocation;
    private String organizer;
    private String description;
    private String status;
}
