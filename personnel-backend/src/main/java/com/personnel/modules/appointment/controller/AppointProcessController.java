package com.personnel.modules.appointment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.AppointProcess;
import com.personnel.modules.appointment.service.AppointProcessService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/api/appoint-process")
public class AppointProcessController {

    @Resource
    private AppointProcessService appointProcessService;

    @PostMapping
    public Result<Void> start(@RequestBody AppointProcess process) {
        appointProcessService.save(process);
        return Result.success();
    }

    @PutMapping
    public Result<Void> updateStep(@RequestBody AppointProcess process) {
        appointProcessService.updateById(process);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AppointProcess> getById(@PathVariable Long id) {
        return Result.success(appointProcessService.getFullProcess(id));
    }

    @GetMapping("/page")
    public Result<PageResult<AppointProcess>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<AppointProcess> page = new Page<>(current, size);
        return Result.success(PageResult.of(appointProcessService.page(page)));
    }
}
