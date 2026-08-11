package com.personnel.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.SysOperLog;
import com.personnel.system.service.SysOperLogService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@RestController
@RequestMapping("/api/oper-log")
public class SysOperLogController {

    @Resource
    private SysOperLogService sysOperLogService;

    @GetMapping("/page")
    public Result<PageResult<SysOperLog>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String operType,
            @RequestParam(required = false) String operModule,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {
        Page<SysOperLog> page = new Page<>(current, size);
        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        if (username != null && !username.isEmpty()) {
            wrapper.like(SysOperLog::getUsername, username);
        }
        if (operType != null && !operType.isEmpty()) {
            wrapper.eq(SysOperLog::getOperType, operType);
        }
        if (operModule != null && !operModule.isEmpty()) {
            wrapper.like(SysOperLog::getOperModule, operModule);
        }
        if (startTime != null && !startTime.isEmpty()) {
            wrapper.ge(SysOperLog::getOperTime, LocalDate.parse(startTime).atStartOfDay());
        }
        if (endTime != null && !endTime.isEmpty()) {
            wrapper.le(SysOperLog::getOperTime, LocalDate.parse(endTime).atTime(LocalTime.MAX));
        }
        wrapper.orderByDesc(SysOperLog::getOperTime);
        return Result.success(PageResult.of(sysOperLogService.page(page, wrapper)));
    }

    @GetMapping("/{id}")
    public Result<SysOperLog> getById(@PathVariable Long id) {
        return Result.success(sysOperLogService.getById(id));
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteById(@PathVariable Long id) {
        sysOperLogService.removeById(id);
        return Result.success();
    }

    @DeleteMapping("/clean")
    public Result<Void> clean() {
        sysOperLogService.remove(new LambdaQueryWrapper<>());
        return Result.success();
    }
}
