package com.personnel.modules.assessment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentIndicator;
import com.personnel.modules.assessment.service.AssessmentIndicatorService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/indicator")
public class AssessmentIndicatorController {

    @Resource
    private AssessmentIndicatorService assessmentIndicatorService;

    @GetMapping("/list")
    public Result<List<AssessmentIndicator>> list(@RequestParam(required = false) Long dimensionId) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AssessmentIndicator> wrapper =
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        if (dimensionId != null) {
            wrapper.eq(AssessmentIndicator::getDimensionId, dimensionId);
        }
        wrapper.orderByAsc(AssessmentIndicator::getSortOrder);
        return Result.success(assessmentIndicatorService.list(wrapper));
    }

    @PostMapping
    public Result<Void> create(@RequestBody AssessmentIndicator indicator) {
        assessmentIndicatorService.save(indicator);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody AssessmentIndicator indicator) {
        assessmentIndicatorService.updateById(indicator);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        assessmentIndicatorService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AssessmentIndicator> getById(@PathVariable Long id) {
        return Result.success(assessmentIndicatorService.getById(id));
    }
}
