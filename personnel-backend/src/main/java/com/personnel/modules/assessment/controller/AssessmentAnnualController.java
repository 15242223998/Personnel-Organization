package com.personnel.modules.assessment.controller;

import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentAnnual;
import com.personnel.modules.assessment.service.AssessmentAnnualService;
import com.personnel.modules.assessment.vo.AnnualVO;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/annual")
public class AssessmentAnnualController {

    @Resource
    private AssessmentAnnualService assessmentAnnualService;

    @GetMapping("/page")
    public Result<com.personnel.common.PageResult<AnnualVO>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String year,
            @RequestParam(required = false) String result,
            @RequestParam(required = false) String name) {
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<AnnualVO> page =
                new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(current, size);
        return Result.success(com.personnel.common.PageResult.of(
                assessmentAnnualService.pageAnnual(page, year, result, name)));
    }

    @GetMapping("/list")
    public Result<List<AssessmentAnnual>> list() {
        return Result.success(assessmentAnnualService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody AssessmentAnnual annual) {
        assessmentAnnualService.saveAnnual(annual);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody AssessmentAnnual annual) {
        assessmentAnnualService.updateAnnual(annual);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        assessmentAnnualService.deleteAnnual(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AssessmentAnnual> getById(@PathVariable Long id) {
        return Result.success(assessmentAnnualService.getById(id));
    }

    /** 某年度各等次统计 */
    @GetMapping("/stats")
    public Result<Map<String, Object>> stats(@RequestParam(required = false) String year) {
        return Result.success(assessmentAnnualService.statsByYear(year));
    }

    /** 全部年度汇总统计 */
    @GetMapping("/stats-all")
    public Result<List<Map<String, Object>>> statsAll() {
        return Result.success(assessmentAnnualService.statsAllYears());
    }
}
