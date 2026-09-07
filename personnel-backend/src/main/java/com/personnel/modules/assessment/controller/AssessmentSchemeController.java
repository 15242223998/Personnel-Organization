package com.personnel.modules.assessment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.assessment.dto.AssessmentSchemeDTO;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.service.AssessmentSchemeService;
import com.personnel.modules.assessment.vo.SchemeDetailVO;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/assessment-scheme")
public class AssessmentSchemeController {

    @Resource
    private AssessmentSchemeService assessmentSchemeService;

    @GetMapping("/page")
    public Result<PageResult<AssessmentScheme>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<AssessmentScheme> page = new Page<>(current, size);
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AssessmentScheme> wrapper =
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        wrapper.orderByDesc(AssessmentScheme::getCreateTime);
        return Result.success(PageResult.of(assessmentSchemeService.page(page, wrapper)));
    }

    @GetMapping("/list")
    public Result<List<AssessmentScheme>> list() {
        return Result.success(assessmentSchemeService.list());
    }

    /** 创建方案（含维度/指标模板） */
    @PostMapping
    public Result<Long> create(@RequestBody AssessmentSchemeDTO dto) {
        return Result.success(assessmentSchemeService.createSchemeWithDetails(dto));
    }

    @PutMapping
    public Result<Void> update(@RequestBody AssessmentScheme scheme) {
        assessmentSchemeService.updateScheme(scheme);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        assessmentSchemeService.deleteScheme(id);
        return Result.success();
    }

    @GetMapping("/{id}/detail")
    public Result<SchemeDetailVO> detail(@PathVariable Long id) {
        return Result.success(assessmentSchemeService.getDetail(id));
    }

    @GetMapping("/{id}")
    public Result<AssessmentScheme> getById(@PathVariable Long id) {
        return Result.success(assessmentSchemeService.getById(id));
    }

    /** 生成测评对象（覆盖式） */
    @PutMapping("/{id}/targets")
    public Result<Void> generateTargets(@PathVariable Long id, @RequestBody List<Long> cadreIds) {
        assessmentSchemeService.generateTargets(id, cadreIds);
        return Result.success();
    }

    @PutMapping("/{id}/publish")
    public Result<Void> publish(@PathVariable Long id) {
        assessmentSchemeService.publish(id);
        return Result.success();
    }

    @PutMapping("/{id}/close")
    public Result<Void> close(@PathVariable Long id) {
        assessmentSchemeService.close(id);
        return Result.success();
    }

    /** 测评时间范围便捷设置：{startTime: "yyyy-MM-dd HH:mm:ss", endTime: ...} */
    @PutMapping("/{id}/vote-time")
    public Result<Void> setVoteTime(@PathVariable Long id, @RequestBody Map<String, String> body) {
        AssessmentScheme scheme = assessmentSchemeService.getById(id);
        if (scheme == null) {
            return Result.error("方案不存在");
        }
        if (body.get("startTime") != null && !body.get("startTime").isBlank()) {
            scheme.setVoteStartTime(LocalDateTime.parse(body.get("startTime").replace(" ", "T"),
                    java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        }
        if (body.get("endTime") != null && !body.get("endTime").isBlank()) {
            scheme.setVoteEndTime(LocalDateTime.parse(body.get("endTime").replace(" ", "T"),
                    java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        }
        assessmentSchemeService.updateById(scheme);
        return Result.success();
    }
}
