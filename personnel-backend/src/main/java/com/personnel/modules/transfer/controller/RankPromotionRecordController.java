package com.personnel.modules.transfer.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.transfer.entity.RankPromotionRecord;
import com.personnel.modules.transfer.service.RankPromotionRecordService;
import com.personnel.modules.transfer.vo.PromotionEligibleVO;
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

    /**
     * 晋升资格判定：在职干部中符合晋升条件的干部分页（fromRankId=拟晋升目标职级，可空；keyword=姓名模糊）
     */
    @GetMapping("/eligible")
    public Result<PageResult<PromotionEligibleVO>> eligible(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) Long fromRankId,
            @RequestParam(required = false) String keyword) {
        return Result.success(PageResult.of(
                rankPromotionRecordService.eligiblePage(current, size, fromRankId, keyword)));
    }

    @PostMapping
    public Result<Void> create(@RequestBody RankPromotionRecord record) {
        rankPromotionRecordService.save(record);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody RankPromotionRecord record) {
        rankPromotionRecordService.updateById(record);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        rankPromotionRecordService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<RankPromotionRecord> getById(@PathVariable Long id) {
        return Result.success(rankPromotionRecordService.getById(id));
    }
}
