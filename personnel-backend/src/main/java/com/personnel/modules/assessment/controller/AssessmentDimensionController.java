package com.personnel.modules.assessment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentDimension;
import com.personnel.modules.assessment.service.AssessmentDimensionService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/dimension")
public class AssessmentDimensionController {

    @Resource
    private AssessmentDimensionService assessmentDimensionService;

    @GetMapping("/list")
    public Result<List<AssessmentDimension>> list(@RequestParam(required = false) Long schemeId) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AssessmentDimension> wrapper =
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        if (schemeId != null) {
            wrapper.eq(AssessmentDimension::getSchemeId, schemeId);
        }
        wrapper.orderByAsc(AssessmentDimension::getSortOrder);
        return Result.success(assessmentDimensionService.list(wrapper));
    }

    @PostMapping
    public Result<Void> create(@RequestBody AssessmentDimension dimension) {
        assessmentDimensionService.save(dimension);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody AssessmentDimension dimension) {
        assessmentDimensionService.updateById(dimension);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        assessmentDimensionService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AssessmentDimension> getById(@PathVariable Long id) {
        return Result.success(assessmentDimensionService.getById(id));
    }
}
