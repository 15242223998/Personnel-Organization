package com.personnel.modules.supervision.controller;

import com.personnel.common.Result;
import com.personnel.modules.supervision.service.SuperviseAlertService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import java.util.Map;

/**
 * 智能预警-规则生成：POST /api/supervise/alert/generate
 * 一键按启用规则扫描真实台账生成/刷新预警（幂等），返回各规则新增条数与提示文案。
 * 分页/列表等既有 CRUD 仍走 /api/alert（SuperviseAlertController），此处仅提供生成动作。
 */
@RestController
@RequestMapping("/api/supervise/alert")
public class SuperviseAlertGenerateController {

    @Resource
    private SuperviseAlertService superviseAlertService;

    @PostMapping("/generate")
    public Result<Map<String, Object>> generate() {
        return Result.success(superviseAlertService.generateByRules());
    }
}
