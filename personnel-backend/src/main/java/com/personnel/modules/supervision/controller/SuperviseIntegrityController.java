package com.personnel.modules.supervision.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.supervision.entity.SuperviseIntegrity;
import com.personnel.modules.supervision.service.SuperviseIntegrityService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/integrity")
public class SuperviseIntegrityController {

    @Resource
    private SuperviseIntegrityService superviseIntegrityService;

    @GetMapping("/page")
    public Result<PageResult<SuperviseIntegrity>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<SuperviseIntegrity> page = new Page<>(current, size);
        return Result.success(PageResult.of(superviseIntegrityService.page(page)));
    }

    @GetMapping("/list")
    public Result<List<SuperviseIntegrity>> list() {
        return Result.success(superviseIntegrityService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody SuperviseIntegrity integrity) {
        superviseIntegrityService.save(integrity);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SuperviseIntegrity integrity) {
        superviseIntegrityService.updateById(integrity);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        superviseIntegrityService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<SuperviseIntegrity> getById(@PathVariable Long id) {
        return Result.success(superviseIntegrityService.getById(id));
    }
}
