package com.personnel.modules.appointment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("appoint_recommend")
public class AppointRecommend extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long processId;
    private String recommendType;
    private LocalDate recommendDate;
    private String recommendLocation;
    private Integer expectedCount;
    private Integer actualCount;
    private Integer voteCount;
    private Integer isPassed;
    private String meetingFileUrl;
}
