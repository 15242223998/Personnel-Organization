package com.personnel.modules.cadre.controller;

import com.personnel.common.Result;
import com.personnel.modules.cadre.entity.CadreReserve;
import com.personnel.modules.cadre.service.CadreReserveService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/cadre-reserve")
public class CadreReserveController {

    @Resource
    private CadreReserveService cadreReserveService;

    @GetMapping("/list")
    public Result<List<CadreReserve>> list() {
        return Result.success(cadreReserveService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody CadreReserve cadreReserve) {
        cadreReserveService.save(cadreReserve);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody CadreReserve cadreReserve) {
        cadreReserveService.updateById(cadreReserve);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        cadreReserveService.removeById(id);
        return Result.success();
    }
}
