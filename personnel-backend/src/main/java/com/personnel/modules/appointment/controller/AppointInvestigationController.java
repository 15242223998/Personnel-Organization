package com.personnel.modules.appointment.controller;

import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.AppointInvestigation;
import com.personnel.modules.appointment.service.AppointInvestigationService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/appoint-process/{processId}/investigation")
public class AppointInvestigationController {

    @Resource
    private AppointInvestigationService appointInvestigationService;

    @GetMapping("/list")
    public Result<List<AppointInvestigation>> list(@PathVariable Long processId) {
        return Result.success(appointInvestigationService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointInvestigation>()
                        .eq(AppointInvestigation::getProcessId, processId)));
    }

    @PostMapping
    public Result<Void> create(@PathVariable Long processId, @RequestBody AppointInvestigation investigation) {
        investigation.setProcessId(processId);
        appointInvestigationService.save(investigation);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@PathVariable Long processId, @RequestBody AppointInvestigation investigation) {
        investigation.setProcessId(processId);
        appointInvestigationService.updateById(investigation);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long processId, @PathVariable Long id) {
        appointInvestigationService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AppointInvestigation> getById(@PathVariable Long processId, @PathVariable Long id) {
        return Result.success(appointInvestigationService.getById(id));
    }
}
