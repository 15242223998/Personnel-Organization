package com.personnel.modules.assessment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentAnnual;
import com.personnel.modules.assessment.service.AssessmentAnnualService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/annual")
public class AssessmentAnnualController {

    @Resource
    private AssessmentAnnualService assessmentAnnualService;

    @GetMapping("/page")
    public Result<PageResult<AssessmentAnnual>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<AssessmentAnnual> page = new Page<>(current, size);
        return Result.success(PageResult.of(assessmentAnnualService.page(page)));
    }

    @GetMapping("/list")
    public Result<List<AssessmentAnnual>> list() {
        return Result.success(assessmentAnnualService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody AssessmentAnnual annual) {
        assessmentAnnualService.save(annual);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody AssessmentAnnual annual) {
        assessmentAnnualService.updateById(annual);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        assessmentAnnualService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AssessmentAnnual> getById(@PathVariable Long id) {
        return Result.success(assessmentAnnualService.getById(id));
    }
}
