package com.personnel.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.SysDictData;
import com.personnel.system.service.SysDictDataService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/dict-data")
public class SysDictDataController {

    @Resource
    private SysDictDataService sysDictDataService;

    @GetMapping("/list")
    public Result<List<SysDictData>> list(@RequestParam(required = false) String typeCode) {
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<SysDictData> wrapper =
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        if (typeCode != null) {
            wrapper.eq(SysDictData::getTypeCode, typeCode);
        }
        wrapper.orderByAsc(SysDictData::getSortOrder);
        return Result.success(sysDictDataService.list(wrapper));
    }

    @PostMapping
    public Result<Void> create(@RequestBody SysDictData dictData) {
        sysDictDataService.save(dictData);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SysDictData dictData) {
        sysDictDataService.updateById(dictData);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        sysDictDataService.removeById(id);
        return Result.success();
    }
}
