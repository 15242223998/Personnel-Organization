package com.personnel.modules.assessment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentTarget;
import com.personnel.modules.assessment.service.AssessmentTargetService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/assessment-target")
public class AssessmentTargetController {

    @Resource
    private AssessmentTargetService assessmentTargetService;

    @GetMapping("/list")
    public Result<List<AssessmentTarget>> list(@RequestParam(required = false) Long schemeId) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AssessmentTarget> wrapper =
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        if (schemeId != null) {
            wrapper.eq(AssessmentTarget::getSchemeId, schemeId);
        }
        return Result.success(assessmentTargetService.list(wrapper));
    }

    @PostMapping
    public Result<Void> create(@RequestBody AssessmentTarget target) {
        assessmentTargetService.save(target);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody AssessmentTarget target) {
        assessmentTargetService.updateById(target);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        assessmentTargetService.removeById(id);
        return Result.success();
    }
}
