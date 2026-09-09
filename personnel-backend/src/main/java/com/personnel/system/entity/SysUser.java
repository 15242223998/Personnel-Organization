package com.personnel.system.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_user")
public class SysUser {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String password;

    private String realName;

    private String avatar;

    private String email;

    private String phone;

    private Integer gender;

    private Integer userType;

    private Integer status;

    private Long deptId;

    /** 关联干部档案ID（干部自助申报归属） */
    private Long cadreId;

    /** 模块级权限，逗号分隔多个key；userType=1系统管理员不受限 */
    private String permissions;

    private String ipBound;

    private Integer loginFailCount;

    private LocalDateTime lockUntil;

    private LocalDateTime lastLoginTime;

    private String lastLoginIp;

    private Long createBy;

    private Long updateBy;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;

    /** 登录返回的 JWT 令牌，非数据库字段 */
    @TableField(exist = false)
    private String token;
}
