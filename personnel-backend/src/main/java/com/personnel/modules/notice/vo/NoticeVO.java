package com.personnel.modules.notice.vo;

import lombok.Data;

import java.time.LocalDateTime;

/** 消息通知项 */
@Data
public class NoticeVO {
    /** 唯一标识（业务类型-记录ID） */
    private String id;
    /** 通知类型：alert预警 leave休假 cert证照 abroad出境 scheme测评 application申报审批结果 */
    private String type;
    private String title;
    private String desc;
    /** 通知时间（取自真实业务记录时间） */
    private LocalDateTime time;
    /** 点击跳转前端路径 */
    private String path;
}
