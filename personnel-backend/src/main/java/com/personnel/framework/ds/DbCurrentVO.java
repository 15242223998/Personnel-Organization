package com.personnel.framework.ds;

import lombok.Data;

/**
 * 当前生效数据源信息（/api/db/current）。
 */
@Data
public class DbCurrentVO {

    /** 当前主数据源名：master=yml 默认；user-conn=运行时热切换 */
    private String primary;

    /** 当前主数据源实际连接的库名（SELECT DATABASE()） */
    private String database;
}
