package com.personnel.modules.organization.controller;

import com.personnel.common.Result;
import com.personnel.modules.organization.entity.StaffingQuota;
import com.personnel.modules.organization.service.StaffingQuotaService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/staffing-quota")
public class StaffingQuotaController {

    @Resource
    private StaffingQuotaService staffingQuotaService;

    @GetMapping("/list")
    public Result<List<StaffingQuota>> list() {
        return Result.success(staffingQuotaService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody StaffingQuota staffingQuota) {
        staffingQuotaService.save(staffingQuota);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody StaffingQuota staffingQuota) {
        staffingQuotaService.updateById(staffingQuota);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        staffingQuotaService.removeById(id);
        return Result.success();
    }
}
