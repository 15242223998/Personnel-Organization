package com.personnel.modules.appointment.controller;

import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.AppointPublicity;
import com.personnel.modules.appointment.service.AppointPublicityService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/appoint-process/{processId}/publicity")
public class AppointPublicityController {

    @Resource
    private AppointPublicityService appointPublicityService;

    @GetMapping("/list")
    public Result<List<AppointPublicity>> list(@PathVariable Long processId) {
        return Result.success(appointPublicityService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointPublicity>()
                        .eq(AppointPublicity::getProcessId, processId)));
    }

    @PostMapping
    public Result<Void> create(@PathVariable Long processId, @RequestBody AppointPublicity publicity) {
        publicity.setProcessId(processId);
        appointPublicityService.save(publicity);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@PathVariable Long processId, @RequestBody AppointPublicity publicity) {
        publicity.setProcessId(processId);
        appointPublicityService.updateById(publicity);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long processId, @PathVariable Long id) {
        appointPublicityService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AppointPublicity> getById(@PathVariable Long processId, @PathVariable Long id) {
        return Result.success(appointPublicityService.getById(id));
    }
}
