package com.personnel.modules.daily.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.daily.entity.DailyCertificate;
import com.personnel.modules.daily.service.DailyCertificateService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/certificate")
public class DailyCertificateController {

    @Resource
    private DailyCertificateService dailyCertificateService;

    @GetMapping("/page")
    public Result<PageResult<DailyCertificate>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<DailyCertificate> page = new Page<>(current, size);
        return Result.success(PageResult.of(dailyCertificateService.page(page,
                new LambdaQueryWrapper<DailyCertificate>().orderByDesc(DailyCertificate::getCreateTime))));
    }

    @GetMapping("/list")
    public Result<List<DailyCertificate>> list() {
        return Result.success(dailyCertificateService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody DailyCertificate certificate) {
        dailyCertificateService.save(certificate);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody DailyCertificate certificate) {
        dailyCertificateService.updateById(certificate);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dailyCertificateService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<DailyCertificate> getById(@PathVariable Long id) {
        return Result.success(dailyCertificateService.getById(id));
    }
}
