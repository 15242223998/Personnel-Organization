package com.personnel.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.BusinessException;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.system.entity.PolicyDocument;
import com.personnel.system.service.PolicyDocumentService;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/policy-document")
public class PolicyDocumentController {

    @Resource
    private PolicyDocumentService policyDocumentService;

    @GetMapping("/page")
    public Result<PageResult<PolicyDocument>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String category) {
        LambdaQueryWrapper<PolicyDocument> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(title)) {
            wrapper.like(PolicyDocument::getTitle, title.trim());
        }
        if (StringUtils.hasText(category)) {
            wrapper.eq(PolicyDocument::getCategory, category.trim());
        }
        wrapper.orderByDesc(PolicyDocument::getIssueDate).orderByDesc(PolicyDocument::getCreateTime);
        Page<PolicyDocument> page = new Page<>(current, size);
        return Result.success(PageResult.of(policyDocumentService.page(page, wrapper)));
    }

    @GetMapping("/list")
    public Result<List<PolicyDocument>> list() {
        return Result.success(policyDocumentService.list(
                new LambdaQueryWrapper<PolicyDocument>()
                        .orderByDesc(PolicyDocument::getIssueDate)
                        .orderByDesc(PolicyDocument::getCreateTime)));
    }

    @GetMapping("/{id}")
    public Result<PolicyDocument> getById(@PathVariable Long id) {
        PolicyDocument doc = policyDocumentService.getById(id);
        if (doc == null) {
            throw new BusinessException("政策文档不存在");
        }
        return Result.success(doc);
    }

    @PostMapping
    public Result<Void> create(@RequestBody PolicyDocument doc) {
        validate(doc);
        policyDocumentService.save(doc);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody PolicyDocument doc) {
        if (doc == null || doc.getId() == null) {
            throw new BusinessException("缺少文档ID");
        }
        validate(doc);
        policyDocumentService.updateById(doc);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        policyDocumentService.removeById(id);
        return Result.success();
    }

    private void validate(PolicyDocument doc) {
        if (doc == null || !StringUtils.hasText(doc.getTitle())) {
            throw new BusinessException("文档标题不能为空");
        }
    }
}
