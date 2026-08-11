package com.personnel.modules.organization.controller;

import com.personnel.common.Result;
import com.personnel.modules.organization.entity.OrganizationRank;
import com.personnel.modules.organization.service.OrganizationRankService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/rank")
public class OrganizationRankController {

    @Resource
    private OrganizationRankService organizationRankService;

    @GetMapping("/list")
    public Result<List<OrganizationRank>> list() {
        return Result.success(organizationRankService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody OrganizationRank organizationRank) {
        organizationRankService.save(organizationRank);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody OrganizationRank organizationRank) {
        organizationRankService.updateById(organizationRank);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        organizationRankService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<OrganizationRank> getById(@PathVariable Long id) {
        return Result.success(organizationRankService.getById(id));
    }
}
