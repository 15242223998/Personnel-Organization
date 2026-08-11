package com.personnel.modules.statistics.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.personnel.common.Result;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {

    @Resource
    private CadreInfoService cadreInfoService;

    @GetMapping("/age-distribution")
    public Result<List<Map<String, Object>>> ageDistribution() {
        List<CadreInfo> all = cadreInfoService.list();
        Map<String, Long> distribution = new LinkedHashMap<>();
        distribution.put("30岁以下", 0L);
        distribution.put("31-35岁", 0L);
        distribution.put("36-40岁", 0L);
        distribution.put("41-45岁", 0L);
        distribution.put("46-50岁", 0L);
        distribution.put("51-55岁", 0L);
        distribution.put("56岁以上", 0L);
        int currentYear = java.time.Year.now().getValue();
        for (CadreInfo c : all) {
            if (c.getBirthDate() == null) continue;
            int age = currentYear - c.getBirthDate().getYear();
            String group = getAgeGroup(age);
            distribution.merge(group, 1L, Long::sum);
        }
        return Result.success(distribution.entrySet().stream()
                .map(e -> { Map<String, Object> m = new HashMap<>(); m.put("name", e.getKey()); m.put("value", e.getValue()); return m; })
                .collect(Collectors.toList()));
    }

    @GetMapping("/gender-distribution")
    public Result<List<Map<String, Object>>> genderDistribution() {
        List<CadreInfo> all = cadreInfoService.list();
        Map<Integer, Long> group = all.stream()
                .filter(c -> c.getGender() != null)
                .collect(Collectors.groupingBy(CadreInfo::getGender, Collectors.counting()));
        List<Map<String, Object>> result = new ArrayList<>();
        result.add(buildItem("男", group.getOrDefault(1, 0L)));
        result.add(buildItem("女", group.getOrDefault(2, 0L)));
        return Result.success(result);
    }

    @GetMapping("/nation-distribution")
    public Result<List<Map<String, Object>>> nationDistribution() {
        List<CadreInfo> all = cadreInfoService.list();
        Map<String, Long> group = all.stream()
                .filter(c -> c.getNation() != null)
                .collect(Collectors.groupingBy(CadreInfo::getNation, Collectors.counting()));
        return Result.success(toList(group));
    }

    @GetMapping("/education-distribution")
    public Result<List<Map<String, Object>>> educationDistribution() {
        List<CadreInfo> all = cadreInfoService.list();
        Map<String, Long> group = all.stream()
                .filter(c -> c.getFullTimeEducation() != null)
                .collect(Collectors.groupingBy(CadreInfo::getFullTimeEducation, Collectors.counting()));
        return Result.success(toList(group));
    }

    @GetMapping("/political-distribution")
    public Result<List<Map<String, Object>>> politicalDistribution() {
        List<CadreInfo> all = cadreInfoService.list();
        Map<String, Long> group = all.stream()
                .filter(c -> c.getPoliticalStatus() != null)
                .collect(Collectors.groupingBy(CadreInfo::getPoliticalStatus, Collectors.counting()));
        return Result.success(toList(group));
    }

    @GetMapping("/position-level-distribution")
    public Result<List<Map<String, Object>>> positionLevelDistribution() {
        List<CadreInfo> all = cadreInfoService.list();
        Map<String, Long> group = all.stream()
                .filter(c -> c.getPositionLevel() != null)
                .collect(Collectors.groupingBy(CadreInfo::getPositionLevel, Collectors.counting()));
        return Result.success(toList(group));
    }

    @GetMapping("/dept-summary")
    public Result<List<Map<String, Object>>> deptSummary() {
        List<CadreInfo> all = cadreInfoService.list();
        Map<Long, Long> group = all.stream()
                .filter(c -> c.getDeptId() != null)
                .collect(Collectors.groupingBy(CadreInfo::getDeptId, Collectors.counting()));
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, Long> e : group.entrySet()) {
            Map<String, Object> m = new HashMap<>();
            m.put("deptId", e.getKey());
            m.put("count", e.getValue());
            result.add(m);
        }
        return Result.success(result);
    }

    private String getAgeGroup(int age) {
        if (age <= 30) return "30岁以下";
        if (age <= 35) return "31-35岁";
        if (age <= 40) return "36-40岁";
        if (age <= 45) return "41-45岁";
        if (age <= 50) return "46-50岁";
        if (age <= 55) return "51-55岁";
        return "56岁以上";
    }

    private Map<String, Object> buildItem(String name, Long value) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", name);
        m.put("value", value);
        return m;
    }

    private List<Map<String, Object>> toList(Map<String, Long> group) {
        return group.entrySet().stream()
                .map(e -> buildItem(e.getKey(), e.getValue()))
                .collect(Collectors.toList());
    }
}
