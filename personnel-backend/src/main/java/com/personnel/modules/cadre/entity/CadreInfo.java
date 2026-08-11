package com.personnel.modules.cadre.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.personnel.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cadre_info")
public class CadreInfo extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private Integer gender;

    private LocalDate birthDate;

    private String nation;

    private String nativePlace;

    private String politicalStatus;

    private LocalDate partyJoinDate;

    private LocalDate workStartDate;

    private String idCard;

    private String phone;

    private String email;

    private String photoUrl;

    private String fullTimeEducation;

    private String fullTimeDegree;

    private String fullTimeSchool;

    private String partTimeEducation;

    private String partTimeDegree;

    private String partTimeSchool;

    private Long deptId;

    private String position;

    private String positionLevel;

    private Long rankId;

    private LocalDate positionStartDate;

    private String positionDocNo;

    private String resumeText;

    private String rewardPunishment;

    private String annualAssessment;

    private String cadreStatus;

    private LocalDate retirementDate;

    private LocalDate leaveDate;

    private String leaveReason;

    @TableField(exist = false)
    private List<CadreFamilyMember> familyMembers;
}
