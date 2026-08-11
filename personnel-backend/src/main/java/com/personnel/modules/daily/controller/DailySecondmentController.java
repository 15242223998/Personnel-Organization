package com.personnel.modules.daily.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.daily.entity.DailySecondment;
import com.personnel.modules.daily.service.DailySecondmentService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/secondment")
public class DailySecondmentController {

    @Resource
    private DailySecondmentService dailySecondmentService;

    @GetMapping("/page")
    public Result<PageResult<DailySecondment>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<DailySecondment> page = new Page<>(current, size);
        return Result.success(PageResult.of(dailySecondmentService.page(page,
                new LambdaQueryWrapper<DailySecondment>().orderByDesc(DailySecondment::getCreateTime))));
    }

    @GetMapping("/list")
    public Result<List<DailySecondment>> list() {
        return Result.success(dailySecondmentService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody DailySecondment secondment) {
        dailySecondmentService.save(secondment);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody DailySecondment secondment) {
        dailySecondmentService.updateById(secondment);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dailySecondmentService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<DailySecondment> getById(@PathVariable Long id) {
        return Result.success(dailySecondmentService.getById(id));
    }
}
