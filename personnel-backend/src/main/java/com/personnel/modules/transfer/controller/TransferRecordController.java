package com.personnel.modules.transfer.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.transfer.entity.TransferRecord;
import com.personnel.modules.transfer.service.TransferRecordService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/api/transfer")
public class TransferRecordController {

    @Resource
    private TransferRecordService transferRecordService;

    @GetMapping("/page")
    public Result<PageResult<TransferRecord>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<TransferRecord> page = new Page<>(current, size);
        return Result.success(PageResult.of(transferRecordService.page(page)));
    }

    @PostMapping
    public Result<Void> create(@RequestBody TransferRecord transferRecord) {
        transferRecordService.save(transferRecord);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody TransferRecord transferRecord) {
        transferRecordService.updateById(transferRecord);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        transferRecordService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<TransferRecord> getById(@PathVariable Long id) {
        return Result.success(transferRecordService.getById(id));
    }
}
