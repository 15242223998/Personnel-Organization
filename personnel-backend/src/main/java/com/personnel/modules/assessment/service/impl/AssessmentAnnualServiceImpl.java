package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.assessment.entity.AssessmentAnnual;
import com.personnel.modules.assessment.mapper.AssessmentAnnualMapper;
import com.personnel.modules.assessment.service.AssessmentAnnualService;
import com.personnel.modules.assessment.vo.AnnualVO;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.service.OrganizationService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class AssessmentAnnualServiceImpl extends ServiceImpl<AssessmentAnnualMapper, AssessmentAnnual> implements AssessmentAnnualService {

    @Resource
    private CadreInfoService cadreInfoService;

    @Resource
    private OrganizationService organizationService;

    private static final Set<String> VALID_RESULTS = Set.of("优秀", "称职", "基本称职", "不称职");

    @Override
    @Transactional
    public void saveAnnual(AssessmentAnnual annual) {
        validate(annual, null);
        save(annual);
        writeBackToCadre(annual.getCadreId(), annual.getAssessmentYear(), annual.getAssessmentResult());
    }

    @Override
    @Transactional
    public void updateAnnual(AssessmentAnnual annual) {
        AssessmentAnnual db = getById(annual.getId());
        if (db == null) {
            throw new BusinessException("考核记录不存在");
        }
        validate(annual, annual.getId());
        updateById(annual);
        // 档案中先移除旧记录再写入新值
        removeFromCadreHistory(db.getCadreId(), db.getAssessmentYear());
        writeBackToCadre(annual.getCadreId(), annual.getAssessmentYear(), annual.getAssessmentResult());
    }

    @Override
    @Transactional
    public void deleteAnnual(Long id) {
        AssessmentAnnual db = getById(id);
        if (db == null) {
            throw new BusinessException("考核记录不存在");
        }
        removeById(id);
        removeFromCadreHistory(db.getCadreId(), db.getAssessmentYear());
    }

    @Override
    public Page<AnnualVO> pageAnnual(Page<AnnualVO> page, String year, String result, String name) {
        LambdaQueryWrapper<AssessmentAnnual> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(year)) {
            wrapper.eq(AssessmentAnnual::getAssessmentYear, year);
        }
        if (StringUtils.hasText(result)) {
            wrapper.eq(AssessmentAnnual::getAssessmentResult, result);
        }
        if (StringUtils.hasText(name)) {
            List<Long> cadreIds = cadreInfoService.list(new LambdaQueryWrapper<CadreInfo>()
                            .like(CadreInfo::getName, name))
                    .stream().map(CadreInfo::getId).toList();
            if (cadreIds.isEmpty()) {
                page.setRecords(List.of());
                page.setTotal(0);
                return page;
            }
            wrapper.in(AssessmentAnnual::getCadreId, cadreIds);
        }
        wrapper.orderByDesc(AssessmentAnnual::getAssessmentYear);

        Page<AssessmentAnnual> entityPage = new Page<>(page.getCurrent(), page.getSize());
        Page<AssessmentAnnual> dataPage = page(entityPage, wrapper);

        Map<Long, CadreInfo> cadreMap = loadCadreMap(
                dataPage.getRecords().stream().map(AssessmentAnnual::getCadreId).toList());
        Map<Long, String> deptNameMap = loadDeptNameMap(cadreMap.values());

        List<AnnualVO> vos = new ArrayList<>();
        for (AssessmentAnnual annual : dataPage.getRecords()) {
            AnnualVO vo = new AnnualVO();
            vo.setId(annual.getId());
            vo.setCadreId(annual.getCadreId());
            vo.setAssessmentYear(annual.getAssessmentYear());
            vo.setAssessmentResult(annual.getAssessmentResult());
            vo.setAssessmentComment(annual.getAssessmentComment());
            CadreInfo cadre = cadreMap.get(annual.getCadreId());
            if (cadre != null) {
                vo.setCadreName(cadre.getName());
                vo.setPosition(cadre.getPosition());
                vo.setDeptName(deptNameMap.get(cadre.getDeptId()));
            }
            vos.add(vo);
        }
        page.setRecords(vos);
        page.setTotal(dataPage.getTotal());
        return page;
    }

    @Override
    public Map<String, Object> statsByYear(String year) {
        LambdaQueryWrapper<AssessmentAnnual> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(year)) {
            wrapper.eq(AssessmentAnnual::getAssessmentYear, year);
        }
        List<AssessmentAnnual> list = list(wrapper);
        return buildStats(list, year);
    }

    @Override
    public List<Map<String, Object>> statsAllYears() {
        Map<String, List<AssessmentAnnual>> byYear = list().stream()
                .collect(Collectors.groupingBy(AssessmentAnnual::getAssessmentYear));
        return byYear.entrySet().stream()
                .sorted(Map.Entry.<String, List<AssessmentAnnual>>comparingByKey().reversed())
                .map(e -> buildStats(e.getValue(), e.getKey()))
                .toList();
    }

    private Map<String, Object> buildStats(List<AssessmentAnnual> list, String year) {
        Map<String, Long> byResult = list.stream()
                .filter(a -> a.getAssessmentResult() != null)
                .collect(Collectors.groupingBy(AssessmentAnnual::getAssessmentResult, Collectors.counting()));
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("year", year);
        stats.put("total", (long) list.size());
        stats.put("excellent", byResult.getOrDefault("优秀", 0L));
        stats.put("qualified", byResult.getOrDefault("称职", 0L));
        stats.put("basic", byResult.getOrDefault("基本称职", 0L));
        stats.put("unqualified", byResult.getOrDefault("不称职", 0L));
        return stats;
    }

    private void validate(AssessmentAnnual annual, Long excludeId) {
        if (annual.getCadreId() == null) {
            throw new BusinessException("被考核干部不能为空");
        }
        if (cadreInfoService.getById(annual.getCadreId()) == null) {
            throw new BusinessException("干部档案不存在");
        }
        if (!StringUtils.hasText(annual.getAssessmentYear()) || !annual.getAssessmentYear().matches("\\d{4}")) {
            throw new BusinessException("考核年度格式应为4位年份，如2025");
        }
        if (!VALID_RESULTS.contains(annual.getAssessmentResult())) {
            throw new BusinessException("考核结果仅限：优秀/称职/基本称职/不称职");
        }
        long dup = count(new LambdaQueryWrapper<AssessmentAnnual>()
                .eq(AssessmentAnnual::getCadreId, annual.getCadreId())
                .eq(AssessmentAnnual::getAssessmentYear, annual.getAssessmentYear())
                .ne(excludeId != null, AssessmentAnnual::getId, excludeId));
        if (dup > 0) {
            throw new BusinessException("该干部在" + annual.getAssessmentYear() + "年度已有考核记录");
        }
    }

    /** 回写干部档案：annual_assessment 形如 "2024:称职;2025:优秀" */
    private void writeBackToCadre(Long cadreId, String year, String result) {
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            return;
        }
        String history = removeFromHistory(cadre.getAnnualAssessment(), year);
        String updated = (history.isEmpty() ? "" : history + ";") + year + ":" + result;
        cadre.setAnnualAssessment(updated);
        cadreInfoService.updateById(cadre);
    }

    /** 从干部档案考核记录中移除某年度条目 */
    private void removeFromCadreHistory(Long cadreId, String year) {
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            return;
        }
        String history = removeFromHistory(cadre.getAnnualAssessment(), year);
        cadre.setAnnualAssessment(history);
        cadreInfoService.updateById(cadre);
    }

    private String removeFromHistory(String history, String year) {
        if (!StringUtils.hasText(history)) {
            return "";
        }
        String prefix1 = year + ":";
        String prefix2 = year + "：";
        List<String> kept = new ArrayList<>();
        for (String part : history.split(";")) {
            String item = part.trim();
            if (item.isEmpty() || item.startsWith(prefix1) || item.startsWith(prefix2)) {
                continue;
            }
            kept.add(item);
        }
        return String.join(";", kept);
    }

    private Map<Long, CadreInfo> loadCadreMap(List<Long> cadreIds) {
        List<Long> distinct = cadreIds.stream().filter(java.util.Objects::nonNull).distinct().toList();
        if (distinct.isEmpty()) {
            return Map.of();
        }
        return cadreInfoService.listByIds(distinct).stream()
                .collect(Collectors.toMap(CadreInfo::getId, Function.identity()));
    }

    private Map<Long, String> loadDeptNameMap(java.util.Collection<CadreInfo> cadres) {
        List<Long> deptIds = cadres.stream().map(CadreInfo::getDeptId)
                .filter(java.util.Objects::nonNull).distinct().toList();
        if (deptIds.isEmpty()) {
            return Map.of();
        }
        Map<Long, String> map = new HashMap<>();
        for (Organization org : organizationService.listByIds(deptIds)) {
            map.put(org.getId(), org.getDeptName());
        }
        return map;
    }
}
