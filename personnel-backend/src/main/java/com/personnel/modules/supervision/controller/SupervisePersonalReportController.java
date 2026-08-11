package com.personnel.modules.supervision.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.supervision.entity.SupervisePersonalReport;
import com.personnel.modules.supervision.service.SupervisePersonalReportService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/personal-report")
public class SupervisePersonalReportController {

    @Resource
    private SupervisePersonalReportService supervisePersonalReportService;

    @GetMapping("/page")
    public Result<PageResult<SupervisePersonalReport>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<SupervisePersonalReport> page = new Page<>(current, size);
        return Result.success(PageResult.of(supervisePersonalReportService.page(page)));
    }

    @GetMapping("/list")
    public Result<List<SupervisePersonalReport>> list() {
        return Result.success(supervisePersonalReportService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody SupervisePersonalReport report) {
        supervisePersonalReportService.save(report);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SupervisePersonalReport report) {
        supervisePersonalReportService.updateById(report);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        supervisePersonalReportService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<SupervisePersonalReport> getById(@PathVariable Long id) {
        return Result.success(supervisePersonalReportService.getById(id));
    }
}
