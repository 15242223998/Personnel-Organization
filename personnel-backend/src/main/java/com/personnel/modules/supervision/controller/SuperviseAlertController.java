package com.personnel.modules.supervision.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.supervision.entity.SuperviseAlert;
import com.personnel.modules.supervision.service.SuperviseAlertService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/alert")
public class SuperviseAlertController {

    @Resource
    private SuperviseAlertService superviseAlertService;

    @GetMapping("/page")
    public Result<PageResult<SuperviseAlert>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<SuperviseAlert> page = new Page<>(current, size);
        return Result.success(PageResult.of(superviseAlertService.page(page)));
    }

    @GetMapping("/list")
    public Result<List<SuperviseAlert>> list() {
        return Result.success(superviseAlertService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody SuperviseAlert alert) {
        superviseAlertService.save(alert);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SuperviseAlert alert) {
        superviseAlertService.updateById(alert);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        superviseAlertService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<SuperviseAlert> getById(@PathVariable Long id) {
        return Result.success(superviseAlertService.getById(id));
    }
}
