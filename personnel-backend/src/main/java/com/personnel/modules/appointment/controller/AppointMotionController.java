package com.personnel.modules.appointment.controller;

import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.AppointMotion;
import com.personnel.modules.appointment.service.AppointMotionService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/appoint-process/{processId}/motion")
public class AppointMotionController {

    @Resource
    private AppointMotionService appointMotionService;

    @GetMapping("/list")
    public Result<List<AppointMotion>> list(@PathVariable Long processId) {
        return Result.success(appointMotionService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointMotion>()
                        .eq(AppointMotion::getProcessId, processId)));
    }

    @PostMapping
    public Result<Void> create(@PathVariable Long processId, @RequestBody AppointMotion motion) {
        motion.setProcessId(processId);
        appointMotionService.save(motion);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@PathVariable Long processId, @RequestBody AppointMotion motion) {
        motion.setProcessId(processId);
        appointMotionService.updateById(motion);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long processId, @PathVariable Long id) {
        appointMotionService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AppointMotion> getById(@PathVariable Long processId, @PathVariable Long id) {
        return Result.success(appointMotionService.getById(id));
    }
}
