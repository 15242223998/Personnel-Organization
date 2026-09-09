package com.personnel.modules.daily.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.daily.entity.DailyAbroadRecord;
import com.personnel.modules.daily.service.DailyAbroadRecordService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/abroad")
public class DailyAbroadRecordController {

    @Resource
    private DailyAbroadRecordService dailyAbroadRecordService;

    @GetMapping("/page")
    public Result<PageResult<DailyAbroadRecord>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<DailyAbroadRecord> page = new Page<>(current, size);
        return Result.success(PageResult.of(dailyAbroadRecordService.page(page,
                new LambdaQueryWrapper<DailyAbroadRecord>().orderByDesc(DailyAbroadRecord::getCreateTime))));
    }

    @GetMapping("/list")
    public Result<List<DailyAbroadRecord>> list() {
        return Result.success(dailyAbroadRecordService.list());
    }

    /** 供证照领用选择：某干部已批准且尚未出发（或进行中）的出国(境)记录 */
    @GetMapping("/approved")
    public Result<List<DailyAbroadRecord>> approvedOptions(@RequestParam Long cadreId) {
        List<DailyAbroadRecord> all = dailyAbroadRecordService.list(
                new LambdaQueryWrapper<DailyAbroadRecord>()
                        .eq(DailyAbroadRecord::getCadreId, cadreId)
                        .eq(DailyAbroadRecord::getIsApproved, 1)
                        .orderByAsc(DailyAbroadRecord::getDepartDate));
        java.time.LocalDate today = java.time.LocalDate.now();
        List<DailyAbroadRecord> result = new java.util.ArrayList<>();
        for (DailyAbroadRecord r : all) {
            if (r.getDepartDate() != null && !r.getDepartDate().isBefore(today)) {
                result.add(r);
            }
        }
        return Result.success(result);
    }

    @PostMapping
    public Result<Void> create(@RequestBody DailyAbroadRecord record) {
        dailyAbroadRecordService.save(record);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody DailyAbroadRecord record) {
        dailyAbroadRecordService.updateById(record);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dailyAbroadRecordService.removeById(id);
        return Result.success();
    }
}
