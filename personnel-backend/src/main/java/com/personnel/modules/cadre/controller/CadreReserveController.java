package com.personnel.modules.cadre.controller;

import com.personnel.common.Result;
import com.personnel.modules.assessment.support.AnnualAssessmentSupport;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.entity.CadreReserve;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.cadre.service.CadreReserveService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 后备干部库：保留历史前缀 /api/cadre-reserve（前端既有调用不变量），
 * 同时别名暴露 /api/reserve（任务约定新增的批量考核核验接口路径）。
 */
@RestController
@RequestMapping({"/api/cadre-reserve", "/api/reserve"})
public class CadreReserveController {

    @Resource
    private CadreReserveService cadreReserveService;

    @Resource
    private CadreInfoService cadreInfoService;

    @GetMapping("/list")
    public Result<List<CadreReserve>> list() {
        return Result.success(cadreReserveService.list());
    }

    /**
     * 后备库批量考核核验：?cadreIds=1,2,3 → map[cadreId] = {qualified, reason}。
     * 供前端“可入库干部候选/已入库列表”展示考核 tag；内部统一走 AnnualAssessmentSupport
     * （口径：近三年考核称职以上，来源 cadre_info.annual_assessment）。不强制入库拦截，仅核验提示。
     */
    @GetMapping("/assessment-check")
    public Result<Map<Long, Map<String, Object>>> assessmentCheck(@RequestParam String cadreIds) {
        List<Long> ids = new ArrayList<>();
        if (cadreIds != null) {
            for (String s : cadreIds.split(",")) {
                String item = s == null ? "" : s.trim();
                if (item.isEmpty()) {
                    continue;
                }
                try {
                    ids.add(Long.valueOf(item));
                } catch (NumberFormatException ignored) {
                    // 非数字参数直接忽略
                }
            }
        }
        Map<Long, Map<String, Object>> result = new LinkedHashMap<>();
        if (!ids.isEmpty()) {
            List<CadreInfo> cadres = cadreInfoService.listByIds(ids);
            if (cadres != null) {
                for (CadreInfo cadre : cadres) {
                    if (cadre == null || cadre.getId() == null) {
                        continue;
                    }
                    Map<String, Object> item = new HashMap<>();
                    String raw = cadre.getAnnualAssessment();
                    boolean qualified = AnnualAssessmentSupport.qualified(raw);
                    List<String> reasons = AnnualAssessmentSupport.reasons(raw);
                    item.put("qualified", qualified);
                    item.put("reason", qualified || reasons.isEmpty() ? "" : reasons.get(0));
                    result.put(cadre.getId(), item);
                }
            }
        }
        return Result.success(result);
    }

    @PostMapping
    public Result<Void> create(@RequestBody CadreReserve cadreReserve) {
        cadreReserveService.save(cadreReserve);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody CadreReserve cadreReserve) {
        cadreReserveService.updateById(cadreReserve);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        cadreReserveService.removeById(id);
        return Result.success();
    }
}
