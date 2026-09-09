package com.personnel.modules.supervision.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.BusinessException;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.supervision.entity.SuperviseAdmonish;
import com.personnel.modules.supervision.service.SuperviseAdmonishService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

/**
 * 提醒函询诫勉
 */
@RestController
@RequestMapping("/api/admonish")
public class SuperviseAdmonishController {

    @Resource
    private SuperviseAdmonishService superviseAdmonishService;

    @GetMapping("/page")
    public Result<PageResult<SuperviseAdmonish>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<SuperviseAdmonish> page = new Page<>(current, size);
        LambdaQueryWrapper<SuperviseAdmonish> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(SuperviseAdmonish::getCreateTime);
        return Result.success(PageResult.of(superviseAdmonishService.page(page, wrapper)));
    }

    @GetMapping("/list")
    public Result<List<SuperviseAdmonish>> list() {
        return Result.success(superviseAdmonishService.list(
                new LambdaQueryWrapper<SuperviseAdmonish>().orderByDesc(SuperviseAdmonish::getCreateTime)));
    }

    @GetMapping("/{id}")
    public Result<SuperviseAdmonish> getById(@PathVariable Long id) {
        SuperviseAdmonish record = superviseAdmonishService.getById(id);
        if (record == null) {
            throw new BusinessException("记录不存在");
        }
        return Result.success(record);
    }

    @PostMapping
    public Result<Void> create(@RequestBody SuperviseAdmonish record) {
        validate(record);
        if (!StringUtils.hasText(record.getHandleStatus())) {
            record.setHandleStatus("待处理");
        }
        superviseAdmonishService.save(record);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody SuperviseAdmonish record) {
        if (record == null || record.getId() == null) {
            throw new BusinessException("缺少记录ID");
        }
        validate(record);
        superviseAdmonishService.updateById(record);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        superviseAdmonishService.removeById(id);
        return Result.success();
    }

    private void validate(SuperviseAdmonish record) {
        if (record == null || record.getCadreId() == null) {
            throw new BusinessException("请选择关联干部");
        }
        if (!StringUtils.hasText(record.getAdmonishType())) {
            throw new BusinessException("提醒函询诫勉类型不能为空");
        }
    }
}
