package com.personnel.framework.ds;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import jakarta.annotation.Resource;

/**
 * 启动后尝试按 run/db-conn.json 恢复上次的数据库热切换。
 * 读取失败/连接失败仅告警，不阻断应用启动（保持 yml 默认 master 库）。
 */
@Slf4j
@Component
@Order(1000)
public class DbConnRestorer implements ApplicationRunner {

    @Resource
    private DbAlignService dbAlignService;

    @Override
    public void run(ApplicationArguments args) {
        try {
            dbAlignService.restoreFromFile();
        } catch (Exception e) {
            log.warn("数据库热切换记忆恢复流程异常（忽略）：{}", e.getMessage());
        }
    }
}
