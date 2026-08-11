package com.personnel.modules.supervision.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.supervision.entity.SuperviseComplaint;
import com.personnel.modules.supervision.service.SuperviseComplaintService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/complaint")
public class SuperviseComplaintController {

    @Resource
    private SuperviseComplaintService superviseComplaintService;

    @GetMapping("/page")
    public Result<PageResult<SuperviseComplaint>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<SuperviseComplaint> page = new Page<>(current, size);
        return Result.success(PageResult.of(superviseComplaintService.page(page)));
    }

    @GetMapping("/list")
    public Result<List<SuperviseComplaint>> list() {
        return Result.success(superviseComplaintService.list());
    }

    @PostMapping
    public Result<Void> create(@RequestBody SuperviseComplaint complaint) {
        superviseComplaintService.save(complaint);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SuperviseComplaint complaint) {
        superviseComplaintService.updateById(complaint);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        superviseComplaintService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<SuperviseComplaint> getById(@PathVariable Long id) {
        return Result.success(superviseComplaintService.getById(id));
    }
}
