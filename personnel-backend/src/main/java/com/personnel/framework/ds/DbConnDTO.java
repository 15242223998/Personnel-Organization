package com.personnel.framework.ds;

import lombok.Data;

/**
 * 数据库连接参数（登录页"数据库热切换"）。
 * host/port 指后端可达的 MySQL 实例；db 为要连接/对齐的库名。
 */
@Data
public class DbConnDTO {

    /** MySQL 主机地址，如 localhost / 192.168.1.100 */
    private String host;

    /** MySQL 端口，缺省 3306 */
    private Integer port;

    /** 数据库名，缺省 POP */
    private String db;

    /** 账号 */
    private String username;

    /** 密码 */
    private String password;
}
