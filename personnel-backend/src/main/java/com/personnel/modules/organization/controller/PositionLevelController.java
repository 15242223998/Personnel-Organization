package com.personnel.modules.organization.controller;

import com.personnel.common.Result;
import com.personnel.modules.organization.entity.PositionLevel;
import com.personnel.modules.organization.service.PositionLevelService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/position-level")
public class PositionLevelController {

    @Resource
    private PositionLevelService positionLevelService;

    @GetMapping("/list")
    public Result<List<PositionLevel>> list() {
        return Result.success(positionLevelService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody PositionLevel positionLevel) {
        positionLevelService.save(positionLevel);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody PositionLevel positionLevel) {
        positionLevelService.updateById(positionLevel);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        positionLevelService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<PositionLevel> getById(@PathVariable Long id) {
        return Result.success(positionLevelService.getById(id));
    }
}
