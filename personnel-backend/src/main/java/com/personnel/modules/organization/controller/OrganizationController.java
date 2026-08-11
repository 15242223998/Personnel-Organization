package com.personnel.modules.organization.controller;

import com.personnel.common.Result;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.service.OrganizationService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/organization")
public class OrganizationController {

    @Resource
    private OrganizationService organizationService;

    @GetMapping("/tree")
    public Result<List<Organization>> getTree() {
        return Result.success(organizationService.getTree());
    }

    @PostMapping
    public Result<Void> create(@RequestBody Organization organization) {
        organizationService.save(organization);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody Organization organization) {
        organizationService.updateById(organization);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        organizationService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<Organization> getById(@PathVariable Long id) {
        return Result.success(organizationService.getById(id));
    }
}
