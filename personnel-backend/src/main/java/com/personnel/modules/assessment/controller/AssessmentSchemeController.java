package com.personnel.modules.assessment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.service.AssessmentSchemeService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/assessment-scheme")
public class AssessmentSchemeController {

    @Resource
    private AssessmentSchemeService assessmentSchemeService;

    @GetMapping("/page")
    public Result<PageResult<AssessmentScheme>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<AssessmentScheme> page = new Page<>(current, size);
        return Result.success(PageResult.of(assessmentSchemeService.page(page)));
    }

    @GetMapping("/list")
    public Result<List<AssessmentScheme>> list() {
        return Result.success(assessmentSchemeService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody AssessmentScheme scheme) {
        assessmentSchemeService.save(scheme);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody AssessmentScheme scheme) {
        assessmentSchemeService.updateById(scheme);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        assessmentSchemeService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AssessmentScheme> getById(@PathVariable Long id) {
        return Result.success(assessmentSchemeService.getById(id));
    }

    @PutMapping("/{id}/publish")
    public Result<Void> publish(@PathVariable Long id) {
        AssessmentScheme scheme = assessmentSchemeService.getById(id);
        if (scheme != null) {
            scheme.setStatus("已发布");
            assessmentSchemeService.updateById(scheme);
        }
        return Result.success();
    }

    @PutMapping("/{id}/close")
    public Result<Void> close(@PathVariable Long id) {
        AssessmentScheme scheme = assessmentSchemeService.getById(id);
        if (scheme != null) {
            scheme.setStatus("已关闭");
            assessmentSchemeService.updateById(scheme);
        }
        return Result.success();
    }
}
