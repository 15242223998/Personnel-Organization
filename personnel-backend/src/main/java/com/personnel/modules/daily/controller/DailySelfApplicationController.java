package com.personnel.modules.daily.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.daily.entity.DailySelfApplication;
import com.personnel.modules.daily.service.DailySelfApplicationService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/self-application")
public class DailySelfApplicationController {

    @Resource
    private DailySelfApplicationService dailySelfApplicationService;

    @GetMapping("/page")
    public Result<PageResult<DailySelfApplication>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<DailySelfApplication> page = new Page<>(current, size);
        return Result.success(PageResult.of(dailySelfApplicationService.page(page,
                new LambdaQueryWrapper<DailySelfApplication>().orderByDesc(DailySelfApplication::getCreateTime))));
    }

    @GetMapping("/list")
    public Result<List<DailySelfApplication>> list() {
        return Result.success(dailySelfApplicationService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody DailySelfApplication application) {
        dailySelfApplicationService.save(application);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody DailySelfApplication application) {
        dailySelfApplicationService.updateById(application);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dailySelfApplicationService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<DailySelfApplication> getById(@PathVariable Long id) {
        return Result.success(dailySelfApplicationService.getById(id));
    }

    @PutMapping("/{id}/submit")
    public Result<Void> submit(@PathVariable Long id) {
        dailySelfApplicationService.submit(id);
        return Result.success();
    }

    @PutMapping("/{id}/approve")
    public Result<Void> approve(@PathVariable Long id,
                                @RequestParam Long approverId,
                                @RequestParam(required = false) String comment) {
        dailySelfApplicationService.approve(id, approverId, comment);
        return Result.success();
    }

    @PutMapping("/{id}/reject")
    public Result<Void> reject(@PathVariable Long id,
                               @RequestParam Long approverId,
                               @RequestParam(required = false) String comment) {
        dailySelfApplicationService.reject(id, approverId, comment);
        return Result.success();
    }
}
