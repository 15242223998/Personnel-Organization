package com.personnel.modules.daily.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("daily_self_application")
public class DailySelfApplication extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long applicantId;
    private String applicationType;
    private String applicationTitle;
    private String applicationContent;
    /** 档案信息更正：申请变更字段 key（白名单见 com.personnel.modules.cadre.constant.CadreInfoMapperKeys） */
    private String applyField;
    /** 档案信息更正：变更前档案值（提交时按申请人绑定的干部档案读取真实值落库） */
    private String oldValue;
    /** 档案信息更正：变更后档案值 */
    private String newValue;
    private String applyStatus;
    private Long approverId;
    private LocalDateTime approveTime;
    private String approveComment;
}
