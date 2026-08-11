package com.personnel.modules.daily.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.daily.entity.DailyLeave;
import com.personnel.modules.daily.service.DailyLeaveService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/leave")
public class DailyLeaveController {

    @Resource
    private DailyLeaveService dailyLeaveService;

    @GetMapping("/page")
    public Result<PageResult<DailyLeave>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<DailyLeave> page = new Page<>(current, size);
        return Result.success(PageResult.of(dailyLeaveService.page(page,
                new LambdaQueryWrapper<DailyLeave>().orderByDesc(DailyLeave::getCreateTime))));
    }

    @GetMapping("/list")
    public Result<List<DailyLeave>> list() {
        return Result.success(dailyLeaveService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody DailyLeave leave) {
        dailyLeaveService.save(leave);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody DailyLeave leave) {
        dailyLeaveService.updateById(leave);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dailyLeaveService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<DailyLeave> getById(@PathVariable Long id) {
        return Result.success(dailyLeaveService.getById(id));
    }
}
