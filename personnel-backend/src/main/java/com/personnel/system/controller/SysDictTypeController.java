package com.personnel.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.SysDictType;
import com.personnel.system.service.SysDictTypeService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/dict-type")
public class SysDictTypeController {

    @Resource
    private SysDictTypeService sysDictTypeService;

    @GetMapping("/list")
    public Result<List<SysDictType>> list() {
        return Result.success(sysDictTypeService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody SysDictType dictType) {
        sysDictTypeService.save(dictType);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SysDictType dictType) {
        sysDictTypeService.updateById(dictType);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        sysDictTypeService.removeById(id);
        return Result.success();
    }
}
