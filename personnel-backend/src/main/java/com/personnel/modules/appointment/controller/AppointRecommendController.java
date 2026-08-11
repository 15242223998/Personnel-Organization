package com.personnel.modules.appointment.controller;

import com.personnel.common.Result;
import com.personnel.modules.appointment.entity.AppointRecommend;
import com.personnel.modules.appointment.service.AppointRecommendService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/appoint-process/{processId}/recommend")
public class AppointRecommendController {

    @Resource
    private AppointRecommendService appointRecommendService;

    @GetMapping("/list")
    public Result<List<AppointRecommend>> list(@PathVariable Long processId) {
        return Result.success(appointRecommendService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AppointRecommend>()
                        .eq(AppointRecommend::getProcessId, processId)));
    }

    @PostMapping
    public Result<Void> create(@PathVariable Long processId, @RequestBody AppointRecommend recommend) {
        recommend.setProcessId(processId);
        appointRecommendService.save(recommend);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@PathVariable Long processId, @RequestBody AppointRecommend recommend) {
        recommend.setProcessId(processId);
        appointRecommendService.updateById(recommend);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long processId, @PathVariable Long id) {
        appointRecommendService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<AppointRecommend> getById(@PathVariable Long processId, @PathVariable Long id) {
        return Result.success(appointRecommendService.getById(id));
    }
}
