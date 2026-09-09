package com.personnel.modules.appointment.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.BusinessException;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.CadreInvestigation;
import com.personnel.modules.appointment.service.CadreInvestigationService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

/**
 * 干部考察登记
 */
@RestController
@RequestMapping("/api/investigation")
public class CadreInvestigationController {

    @Resource
    private CadreInvestigationService cadreInvestigationService;

    @GetMapping("/page")
    public Result<PageResult<CadreInvestigation>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) Long cadreId,
            @RequestParam(required = false) String investigationType) {
        LambdaQueryWrapper<CadreInvestigation> wrapper = new LambdaQueryWrapper<>();
        if (cadreId != null) {
            wrapper.eq(CadreInvestigation::getCadreId, cadreId);
        }
        if (StringUtils.hasText(investigationType)) {
            wrapper.eq(CadreInvestigation::getInvestigationType, investigationType.trim());
        }
        wrapper.orderByDesc(CadreInvestigation::getInvestigationTime).orderByDesc(CadreInvestigation::getCreateTime);
        Page<CadreInvestigation> page = new Page<>(current, size);
        return Result.success(PageResult.of(cadreInvestigationService.page(page, wrapper)));
    }

    @GetMapping("/list")
    public Result<List<CadreInvestigation>> list() {
        return Result.success(cadreInvestigationService.list(
                new LambdaQueryWrapper<CadreInvestigation>()
                        .orderByDesc(CadreInvestigation::getInvestigationTime)
                        .orderByDesc(CadreInvestigation::getCreateTime)));
    }

    @GetMapping("/{id}")
    public Result<CadreInvestigation> getById(@PathVariable Long id) {
        CadreInvestigation record = cadreInvestigationService.getById(id);
        if (record == null) {
            throw new BusinessException("考察登记记录不存在");
        }
        return Result.success(record);
    }

    @PostMapping
    public Result<Void> create(@RequestBody CadreInvestigation record) {
        validate(record);
        cadreInvestigationService.save(record);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody CadreInvestigation record) {
        if (record == null || record.getId() == null) {
            throw new BusinessException("缺少记录ID");
        }
        validate(record);
        cadreInvestigationService.updateById(record);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        cadreInvestigationService.removeById(id);
        return Result.success();
    }

    private void validate(CadreInvestigation record) {
        if (record == null || record.getCadreId() == null) {
            throw new BusinessException("请选择被考察干部");
        }
        if (!StringUtils.hasText(record.getInvestigationType())) {
            throw new BusinessException("考察类型不能为空");
        }
    }
}
