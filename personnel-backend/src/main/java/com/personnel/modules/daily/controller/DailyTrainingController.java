package com.personnel.modules.daily.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.daily.entity.DailyTraining;
import com.personnel.modules.daily.service.DailyTrainingService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/training")
public class DailyTrainingController {

    @Resource
    private DailyTrainingService dailyTrainingService;

    @GetMapping("/page")
    public Result<PageResult<DailyTraining>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<DailyTraining> page = new Page<>(current, size);
        return Result.success(PageResult.of(dailyTrainingService.page(page,
                new LambdaQueryWrapper<DailyTraining>().orderByDesc(DailyTraining::getCreateTime))));
    }

    @GetMapping("/list")
    public Result<List<DailyTraining>> list() {
        return Result.success(dailyTrainingService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody DailyTraining training) {
        dailyTrainingService.save(training);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody DailyTraining training) {
        dailyTrainingService.updateById(training);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dailyTrainingService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<DailyTraining> getById(@PathVariable Long id) {
        return Result.success(dailyTrainingService.getById(id));
    }
}
