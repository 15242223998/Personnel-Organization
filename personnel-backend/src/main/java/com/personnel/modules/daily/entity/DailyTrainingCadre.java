package com.personnel.modules.daily.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("daily_training_cadre")
public class DailyTrainingCadre {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long trainingId;
    private Long cadreId;
    private Integer isCompleted;
    private String certificateUrl;
}
