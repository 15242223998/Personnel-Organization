package com.personnel.modules.daily.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.daily.entity.DailyTrainingCadre;
import com.personnel.modules.daily.service.DailyTrainingCadreService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/training-cadre")
public class DailyTrainingCadreController {

    @Resource
    private DailyTrainingCadreService dailyTrainingCadreService;

    @GetMapping("/list")
    public Result<List<DailyTrainingCadre>> list(@RequestParam(required = false) Long trainingId) {
        LambdaQueryWrapper<DailyTrainingCadre> wrapper = new LambdaQueryWrapper<>();
        if (trainingId != null) {
            wrapper.eq(DailyTrainingCadre::getTrainingId, trainingId);
        }
        return Result.success(dailyTrainingCadreService.list(wrapper));
    }

    @PostMapping
    public Result<Void> create(@RequestBody DailyTrainingCadre trainingCadre) {
        dailyTrainingCadreService.save(trainingCadre);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody DailyTrainingCadre trainingCadre) {
        dailyTrainingCadreService.updateById(trainingCadre);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dailyTrainingCadreService.removeById(id);
        return Result.success();
    }
}
