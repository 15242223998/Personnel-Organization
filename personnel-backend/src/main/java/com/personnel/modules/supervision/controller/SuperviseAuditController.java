package com.personnel.modules.supervision.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.BusinessException;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.supervision.entity.SuperviseAudit;
import com.personnel.modules.supervision.service.SuperviseAuditService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

/**
 * 经济责任审计
 */
@RestController
@RequestMapping("/api/audit")
public class SuperviseAuditController {

    @Resource
    private SuperviseAuditService superviseAuditService;

    @GetMapping("/page")
    public Result<PageResult<SuperviseAudit>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<SuperviseAudit> page = new Page<>(current, size);
        LambdaQueryWrapper<SuperviseAudit> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(SuperviseAudit::getStartTime).orderByDesc(SuperviseAudit::getCreateTime);
        return Result.success(PageResult.of(superviseAuditService.page(page, wrapper)));
    }

    @GetMapping("/list")
    public Result<List<SuperviseAudit>> list() {
        return Result.success(superviseAuditService.list(
                new LambdaQueryWrapper<SuperviseAudit>()
                        .orderByDesc(SuperviseAudit::getStartTime)
                        .orderByDesc(SuperviseAudit::getCreateTime)));
    }

    @GetMapping("/{id}")
    public Result<SuperviseAudit> getById(@PathVariable Long id) {
        SuperviseAudit record = superviseAuditService.getById(id);
        if (record == null) {
            throw new BusinessException("审计记录不存在");
        }
        return Result.success(record);
    }

    @PostMapping
    public Result<Void> create(@RequestBody SuperviseAudit record) {
        validate(record);
        superviseAuditService.save(record);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SuperviseAudit record) {
        if (record == null || record.getId() == null) {
            throw new BusinessException("缺少记录ID");
        }
        validate(record);
        superviseAuditService.updateById(record);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        superviseAuditService.removeById(id);
        return Result.success();
    }

    private void validate(SuperviseAudit record) {
        if (record == null || record.getCadreId() == null) {
            throw new BusinessException("请选择被审计干部");
        }
        if (!StringUtils.hasText(record.getAuditScope())) {
            throw new BusinessException("审计范围不能为空");
        }
    }
}
