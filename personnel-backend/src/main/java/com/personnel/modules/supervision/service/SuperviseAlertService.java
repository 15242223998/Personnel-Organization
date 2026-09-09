package com.personnel.modules.supervision.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.supervision.entity.SuperviseAlert;

import java.util.Map;

public interface SuperviseAlertService extends IService<SuperviseAlert> {

    /**
     * 一键按启用规则扫描真实台账生成/刷新预警（幂等）：
     * 遍历 supervise_alert_rule 中 is_enabled=1 的规则，分别扫描对应真实业务表，
     * 命中则生成 supervise_alert 记录（含 rule_id/ref_id 便于去重与失效清理）。
     *
     * @return 统计结果：{added 新增总数, rules [{ruleType,ruleName,added}], message 提示文案}
     */
    Map<String, Object> generateByRules();
}
