package com.personnel.modules.cadre.controller;

import com.personnel.common.Result;
import com.personnel.modules.cadre.entity.CadreAttachment;
import com.personnel.modules.cadre.service.CadreAttachmentService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/cadre/{cadreId}/attachment")
public class CadreAttachmentController {

    @Resource
    private CadreAttachmentService cadreAttachmentService;

    @GetMapping("/list")
    public Result<List<CadreAttachment>> list(@PathVariable Long cadreId) {
        return Result.success(cadreAttachmentService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<CadreAttachment>()
                        .eq(CadreAttachment::getCadreId, cadreId)));
    }

    @PostMapping("/upload")
    public Result<Void> upload(@PathVariable Long cadreId, @RequestBody CadreAttachment attachment) {
        attachment.setCadreId(cadreId);
        cadreAttachmentService.save(attachment);
        return Result.success();
    }

    @DeleteMapping("/{attachId}")
    public Result<Void> delete(@PathVariable Long cadreId, @PathVariable Long attachId) {
        cadreAttachmentService.removeById(attachId);
        return Result.success();
    }
}
