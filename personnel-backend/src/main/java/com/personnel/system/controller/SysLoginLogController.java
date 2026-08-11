package com.personnel.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.SysLoginLog;
import com.personnel.system.service.SysLoginLogService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.time.LocalDate;
import java.time.LocalTime;

@RestController
@RequestMapping("/api/login-log")
public class SysLoginLogController {

    @Resource
    private SysLoginLogService sysLoginLogService;

    @GetMapping("/page")
    public Result<PageResult<SysLoginLog>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String loginResult,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {
        Page<SysLoginLog> page = new Page<>(current, size);
        LambdaQueryWrapper<SysLoginLog> wrapper = new LambdaQueryWrapper<>();
        if (username != null && !username.isEmpty()) {
            wrapper.like(SysLoginLog::getUsername, username);
        }
        if (loginResult != null && !loginResult.isEmpty()) {
            wrapper.eq(SysLoginLog::getLoginResult, loginResult);
        }
        if (startTime != null && !startTime.isEmpty()) {
            wrapper.ge(SysLoginLog::getLoginTime, LocalDate.parse(startTime).atStartOfDay());
        }
        if (endTime != null && !endTime.isEmpty()) {
            wrapper.le(SysLoginLog::getLoginTime, LocalDate.parse(endTime).atTime(LocalTime.MAX));
        }
        wrapper.orderByDesc(SysLoginLog::getLoginTime);
        return Result.success(PageResult.of(sysLoginLogService.page(page, wrapper)));
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteById(@PathVariable Long id) {
        sysLoginLogService.removeById(id);
        return Result.success();
    }

    @DeleteMapping("/clean")
    public Result<Void> clean() {
        sysLoginLogService.remove(new LambdaQueryWrapper<>());
        return Result.success();
    }
}
