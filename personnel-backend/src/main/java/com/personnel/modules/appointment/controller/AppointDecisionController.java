package com.personnel.modules.appointment.controller;

import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.AppointDecision;
import com.personnel.modules.appointment.service.AppointDecisionService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/appoint-process/{processId}/decision")
public class AppointDecisionController {

    @Resource
    private AppointDecisionService appointDecisionService;

    @GetMapping("/list")
    public Result<List<AppointDecision>> list(@PathVariable Long processId) {
        return Result.success(appointDecisionService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointDecision>()
                        .eq(AppointDecision::getProcessId, processId)));
    }

    @PostMapping
    public Result<Void> create(@PathVariable Long processId, @RequestBody AppointDecision decision) {
        decision.setProcessId(processId);
        appointDecisionService.save(decision);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@PathVariable Long processId, @RequestBody AppointDecision decision) {
        decision.setProcessId(processId);
        appointDecisionService.updateById(decision);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long processId, @PathVariable Long id) {
        appointDecisionService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AppointDecision> getById(@PathVariable Long processId, @PathVariable Long id) {
        return Result.success(appointDecisionService.getById(id));
    }
}
