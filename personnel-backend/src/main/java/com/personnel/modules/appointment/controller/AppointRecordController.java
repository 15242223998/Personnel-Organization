package com.personnel.modules.appointment.controller;

import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.AppointRecord;
import com.personnel.modules.appointment.service.AppointRecordService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/appoint-process/{processId}/record")
public class AppointRecordController {

    @Resource
    private AppointRecordService appointRecordService;

    @GetMapping("/list")
    public Result<List<AppointRecord>> list(@PathVariable Long processId) {
        return Result.success(appointRecordService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointRecord>()
                        .eq(AppointRecord::getProcessId, processId)));
    }

    @PostMapping
    public Result<Void> create(@PathVariable Long processId, @RequestBody AppointRecord record) {
        record.setProcessId(processId);
        appointRecordService.save(record);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@PathVariable Long processId, @RequestBody AppointRecord record) {
        record.setProcessId(processId);
        appointRecordService.updateById(record);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long processId, @PathVariable Long id) {
        appointRecordService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AppointRecord> getById(@PathVariable Long processId, @PathVariable Long id) {
        return Result.success(appointRecordService.getById(id));
    }
}
