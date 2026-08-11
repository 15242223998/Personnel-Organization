package com.personnel.modules.transfer.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.transfer.entity.RankPromotionRecord;
import com.personnel.modules.transfer.service.RankPromotionRecordService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/api/promotion")
public class RankPromotionRecordController {

    @Resource
    private RankPromotionRecordService rankPromotionRecordService;

    @GetMapping("/page")
    public Result<PageResult<RankPromotionRecord>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<RankPromotionRecord> page = new Page<>(current, size);
        return Result.success(PageResult.of(rankPromotionRecordService.page(page)));
    }

    @PostMapping
    public Result<Void> create(@RequestBody RankPromotionRecord record) {
        rankPromotionRecordService.save(record);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<RankPromotionRecord> getById(@PathVariable Long id) {
        return Result.success(rankPromotionRecordService.getById(id));
    }
}
