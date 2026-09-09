package com.personnel.modules.supervision.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.BusinessException;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.supervision.entity.SuperviseAlertRule;
import com.personnel.modules.supervision.service.SuperviseAlertRuleService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

/**
 * 预警规则配置：/api/supervise/alert-rule
 * 提供 page/list/POST/PUT/DELETE 完整 CRUD；预警生成逻辑可基于 threshold 后续扩展
 */
@RestController
@RequestMapping("/api/supervise/alert-rule")
public class SuperviseAlertRuleController {

    @Resource
    private SuperviseAlertRuleService superviseAlertRuleService;

    @GetMapping("/page")
    public Result<PageResult<SuperviseAlertRule>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String ruleName,
            @RequestParam(required = false) String ruleType,
            @RequestParam(required = false) Integer isEnabled) {
        LambdaQueryWrapper<SuperviseAlertRule> wrapper = buildWrapper(ruleName, ruleType, isEnabled);
        Page<SuperviseAlertRule> page = new Page<>(current, size);
        return Result.success(PageResult.of(superviseAlertRuleService.page(page, wrapper)));
    }

    @GetMapping("/list")
    public Result<List<SuperviseAlertRule>> list(
            @RequestParam(required = false) String ruleName,
            @RequestParam(required = false) String ruleType,
            @RequestParam(required = false) Integer isEnabled) {
        LambdaQueryWrapper<SuperviseAlertRule> wrapper = buildWrapper(ruleName, ruleType, isEnabled);
        wrapper.orderByAsc(SuperviseAlertRule::getId);
        return Result.success(superviseAlertRuleService.list(wrapper));
    }

    @PostMapping
    public Result<Void> create(@RequestBody SuperviseAlertRule rule) {
        validate(rule);
        rule.setId(null);
        if (rule.getIsEnabled() == null) {
            rule.setIsEnabled(1);
        }
        superviseAlertRuleService.save(rule);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SuperviseAlertRule rule) {
        if (rule == null || rule.getId() == null) {
            throw new BusinessException("缺少规则ID");
        }
        validate(rule);
        superviseAlertRuleService.updateById(rule);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        superviseAlertRuleService.removeById(id);
        return Result.success();
    }

    private LambdaQueryWrapper<SuperviseAlertRule> buildWrapper(String ruleName, String ruleType, Integer isEnabled) {
        LambdaQueryWrapper<SuperviseAlertRule> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(ruleName)) {
            wrapper.like(SuperviseAlertRule::getRuleName, ruleName.trim());
        }
        if (StringUtils.hasText(ruleType)) {
            wrapper.eq(SuperviseAlertRule::getRuleType, ruleType.trim());
        }
        if (isEnabled != null) {
            wrapper.eq(SuperviseAlertRule::getIsEnabled, isEnabled);
        }
        wrapper.orderByDesc(SuperviseAlertRule::getUpdateTime);
        return wrapper;
    }

    private void validate(SuperviseAlertRule rule) {
        if (rule == null || !StringUtils.hasText(rule.getRuleName())) {
            throw new BusinessException("规则名称不能为空");
        }
        if (!StringUtils.hasText(rule.getRuleType())) {
            throw new BusinessException("预警类型不能为空");
        }
        if (!StringUtils.hasText(rule.getLevel())) {
            throw new BusinessException("预警级别不能为空");
        }
    }
}
