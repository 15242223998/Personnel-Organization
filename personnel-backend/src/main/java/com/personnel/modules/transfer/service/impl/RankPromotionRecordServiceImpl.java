package com.personnel.modules.transfer.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.common.CadreStatus;
import com.personnel.framework.security.DataScopeHelper;
import com.personnel.modules.assessment.support.AnnualAssessmentSupport;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.entity.OrganizationRank;
import com.personnel.modules.organization.service.OrganizationRankService;
import com.personnel.modules.organization.service.OrganizationService;
import com.personnel.modules.transfer.entity.RankPromotionRecord;
import com.personnel.modules.transfer.mapper.RankPromotionRecordMapper;
import com.personnel.modules.transfer.service.RankPromotionRecordService;
import com.personnel.modules.transfer.vo.PromotionEligibleVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import jakarta.annotation.Resource;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class RankPromotionRecordServiceImpl extends ServiceImpl<RankPromotionRecordMapper, RankPromotionRecord> implements RankPromotionRecordService {

    /** 当前职级晋升所需任满年限缺省值（org_rank.promotion_years 为空时使用） */
    private static final int DEFAULT_REQUIRED_YEARS = 3;

    @Resource
    private CadreInfoService cadreInfoService;

    @Resource
    private OrganizationRankService organizationRankService;

    @Resource
    private OrganizationService organizationService;

    @Resource
    private DataScopeHelper dataScopeHelper;

    /**
     * 新增晋升记录：校验必填后落库，并联动干部档案职级。
     * 联动规则（新增/编辑/删除共用 resolveLatestPromotion + applyRankToCadre，见方法注释）：
     * 干部当前职级（cadre_info.rank_id）恒等于其名下剩余（未删除）晋升记录中
     * 最新一条（promotion_date DESC、同日 id DESC）的 to_rank_id。
     */
    @Override
    @Transactional
    public boolean save(RankPromotionRecord record) {
        validateRequired(record);
        CadreInfo cadre = cadreInfoService.getById(record.getCadreId());
        if (cadre == null) {
            throw new BusinessException("晋升对象不存在，请刷新后重试");
        }
        boolean result = super.save(record);
        // 职级晋升只更新职级ID（职务与职务层次由任免/调配维护，避免覆盖）。
        // 新记录通常即该干部最新晋升事件，重算后档案职级即本次 to_rank_id；
        // 若补录的是历史晋升记录，则按真正的最新一条回算，避免倒挂。
        RankPromotionRecord latest = resolveLatestPromotion(record.getCadreId(), null);
        applyRankToCadre(record.getCadreId(), latest != null ? latest.getToRankId() : record.getToRankId());
        return result;
    }

    /**
     * 编辑晋升记录：校验记录存在与必填字段后更新；保存后按该干部剩余晋升记录的最新一条重算档案职级；
     * 若把晋升记录改派到另一名干部，原干部与新干部都按各自剩余记录重算。
     */
    @Override
    @Transactional
    public boolean updateById(RankPromotionRecord record) {
        if (record == null || record.getId() == null) {
            throw new BusinessException("晋升记录ID不能为空");
        }
        RankPromotionRecord existing = getById(record.getId());
        if (existing == null) {
            throw new BusinessException("晋升记录不存在或已删除，请刷新后重试");
        }
        // 未传字段沿用原值后统一校验必填（与新增口径一致）
        Long cadreId = record.getCadreId() != null ? record.getCadreId() : existing.getCadreId();
        Long toRankId = record.getToRankId() != null ? record.getToRankId() : existing.getToRankId();
        LocalDate promotionDate = record.getPromotionDate() != null ? record.getPromotionDate() : existing.getPromotionDate();
        if (cadreId == null) {
            throw new BusinessException("晋升干部不能为空");
        }
        if (toRankId == null) {
            throw new BusinessException("晋升后职级不能为空");
        }
        if (promotionDate == null) {
            throw new BusinessException("晋升日期不能为空");
        }
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null) {
            throw new BusinessException("晋升对象不存在，请刷新后重试");
        }
        boolean updated = super.updateById(record);
        applyLatestRankToCadre(cadreId);
        // 改派到其它干部时，原干部档案按剩余记录重算（无剩余记录则保持现职级不动）
        if (!Objects.equals(existing.getCadreId(), cadreId)) {
            applyLatestRankToCadre(existing.getCadreId());
        }
        return updated;
    }

    /**
     * 删除晋升记录（沿用逻辑删除）后，按该干部剩余晋升记录重算档案职级：
     *  - 仍有剩余记录：档案职级 = 剩余记录最新一条的 to_rank_id；
     *  - 已无任何晋升记录：回退为该条被删记录的 from_rank_id（晋升前职级）；
     *    from_rank_id 为空时保持档案现职级不动（避免误清空——早期数据可能未录原职级）。
     */
    @Override
    @Transactional
    public boolean removeById(Serializable id) {
        RankPromotionRecord existing = getById(id);
        if (existing == null) {
            throw new BusinessException("晋升记录不存在或已删除，请刷新后重试");
        }
        if (existing.getCadreId() == null) {
            throw new BusinessException("晋升记录缺少关联干部，无法删除");
        }
        Long cadreId = existing.getCadreId();
        boolean removed = super.removeById(id);
        // 逻辑删除后该条已不再参与计算，取“剩余记录”的最新一条
        RankPromotionRecord latest = resolveLatestPromotion(cadreId, existing.getId());
        if (latest != null) {
            applyRankToCadre(cadreId, latest.getToRankId());
        } else if (existing.getFromRankId() != null) {
            // 无剩余记录 → 回退到晋升前职级
            applyRankToCadre(cadreId, existing.getFromRankId());
        }
        return removed;
    }

    /**
     * 晋升记录必填校验（与表 NOT NULL 列口径一致，新增/编辑共用）：
     * 干部、晋升后职级、晋升日期三项必填；原职级/文号非强制——
     * 原职级仅用于“删除后无剩余记录”时的回退，为空时按保持现职级处理。
     */
    private void validateRequired(RankPromotionRecord record) {
        if (record == null || record.getCadreId() == null) {
            throw new BusinessException("晋升干部不能为空");
        }
        if (record.getToRankId() == null) {
            throw new BusinessException("晋升后职级不能为空");
        }
        if (record.getPromotionDate() == null) {
            throw new BusinessException("晋升日期不能为空");
        }
    }

    /**
     * 联动核心查询（新增/编辑/删除共用，注释即规则）：
     * 取该干部名下剩余（未删除且排除 excludeRecordId，删除场景先排除被删记录）
     * 晋升记录中 promotion_date DESC、同日 id DESC 的最新一条；无则返回 null。
     */
    private RankPromotionRecord resolveLatestPromotion(Long cadreId, Long excludeRecordId) {
        if (cadreId == null) {
            return null;
        }
        return lambdaQuery()
                .eq(RankPromotionRecord::getCadreId, cadreId)
                .ne(excludeRecordId != null, RankPromotionRecord::getId, excludeRecordId)
                .orderByDesc(RankPromotionRecord::getPromotionDate)
                .orderByDesc(RankPromotionRecord::getId)
                .last("LIMIT 1")
                .one();
    }

    /** 按该干部剩余晋升记录的最新一条重算档案职级；无剩余记录时保持现职级不动（由删除方法显式回退）。 */
    private void applyLatestRankToCadre(Long cadreId) {
        RankPromotionRecord latest = resolveLatestPromotion(cadreId, null);
        if (latest == null) {
            return;
        }
        applyRankToCadre(cadreId, latest.getToRankId());
    }

    /** 将干部档案职级写为目标职级（相等则跳过；职级晋升不触碰职务/职务层次等字段）。 */
    private void applyRankToCadre(Long cadreId, Long targetRankId) {
        if (cadreId == null || targetRankId == null) {
            return;
        }
        CadreInfo cadre = cadreInfoService.getById(cadreId);
        if (cadre == null || Objects.equals(cadre.getRankId(), targetRankId)) {
            return;
        }
        cadre.setRankId(targetRankId);
        cadreInfoService.updateById(cadre);
    }

    /**
     * 晋升资格判定规则（依据现有表字段，注释即规则说明）：
     * 1. 仅干部状态为“在职”（cadre_info.cadre_status = ON_JOB）者参与判定；
     * 2. 必须有现任职务（cadre_info.position 非空），无职务者不参与职级晋升办理；
     * 3. 必须有当前职级（cadre_info.rank_id → org_rank），无职级无法判定年限与目标层级；
     * 4. 满足任职年限：按“最近一次职级晋升日期（rank_promotion_record.promotion_date）与任现职时间
     *    （cadre_info.position_start_date）孰晚”作为当前职级任职起始日，任满月数 ≥
     *    org_rank.promotion_years×12（字段为空按 3 年）方判定为年限符合；
     *    —— 职级晋升后通常按晋升日期重置“任现职级”计时，任现职也会重置，取两者较晚者保守计。
     * 5. 可选目标职级过滤（fromRankId）：目标职级存在时，要求干部当前职级不高于目标职级
     *    （org_rank.sort_order 数值 ≥ 目标 sort_order；数值越小级别越高，即不允许“高于目标职级”的干部出现），
     *    由于数据表中无“距上次晋升间隔”等额外字段，该层级关系仅作参考性过滤；
     * 6. keyword 支持干部姓名模糊匹配。
     * 7. 近三年考核核验（统一口径见 AnnualAssessmentSupport）：追加调用
     *    AnnualAssessmentSupport.qualified(cadre_info.annual_assessment)，未达标者直接剔除，
     *    不再出现在 eligible 列表；返回 VO 携带 assessmentQualified/eligibleReason 供前端展示与接口调试。
     */
    @Override
    public Page<PromotionEligibleVO> eligiblePage(long current, long size, Long fromRankId, String keyword) {
        // 目标职级存在性校验（参数语义：拟晋升目标职级）
        OrganizationRank targetRank = null;
        if (fromRankId != null) {
            targetRank = organizationRankService.getById(fromRankId);
            if (targetRank == null) {
                throw new BusinessException("目标职级不存在，请刷新后重试");
            }
        }

        // 在职 + 有现任职务 + 有当前职级
        LambdaQueryWrapper<CadreInfo> cadreWrapper = new LambdaQueryWrapper<>();
        cadreWrapper.eq(CadreInfo::getCadreStatus, CadreStatus.ON_JOB)
                .isNotNull(CadreInfo::getPosition)
                .ne(CadreInfo::getPosition, "")
                .isNotNull(CadreInfo::getRankId)
                .orderByAsc(CadreInfo::getId);
        if (StringUtils.hasText(keyword)) {
            cadreWrapper.like(CadreInfo::getName, keyword.trim());
        }
        Set<Long> allowedDeptIds = dataScopeHelper.allowedDeptIds();
        if (allowedDeptIds != null) {
            if (allowedDeptIds.isEmpty()) {
                Page<PromotionEligibleVO> empty = new Page<>(current, size, 0);
                empty.setRecords(Collections.emptyList());
                return empty;
            }
            cadreWrapper.in(CadreInfo::getDeptId, allowedDeptIds);
        }
        List<CadreInfo> cadres = cadreInfoService.list(cadreWrapper);
        if (cadres == null || cadres.isEmpty()) {
            Page<PromotionEligibleVO> empty = new Page<>(current, size, 0);
            empty.setRecords(Collections.emptyList());
            return empty;
        }

        // 职级/机构引用数据
        List<OrganizationRank> rankList = organizationRankService.list();
        Map<Long, OrganizationRank> rankMap = rankList == null ? Collections.emptyMap()
                : rankList.stream().filter(r -> r.getId() != null).collect(Collectors.toMap(OrganizationRank::getId, Function.identity()));
        List<Long> cadreIds = cadres.stream().map(CadreInfo::getId).filter(Objects::nonNull).collect(Collectors.toList());
        Map<Long, LocalDate> lastPromotionMap = loadLastPromotionDate(cadreIds);

        LocalDate today = LocalDate.now();
        List<PromotionEligibleVO> eligible = new ArrayList<>();
        for (CadreInfo c : cadres) {
            if (c.getId() == null || c.getRankId() == null) {
                continue;
            }
            OrganizationRank rank = rankMap.get(c.getRankId());
            if (rank == null) {
                // 当前职级在 org_rank 中已不存在（如演示库重复灌数导致的漂移），不参与判定
                continue;
            }
            // 规则5：目标职级过滤（当前职级不得高于目标职级）
            if (targetRank != null) {
                int curSort = rank.getSortOrder() == null ? Integer.MAX_VALUE : rank.getSortOrder();
                int targetSort = targetRank.getSortOrder() == null ? Integer.MAX_VALUE : targetRank.getSortOrder();
                if (curSort < targetSort) {
                    continue;
                }
            }
            // 规则4：任职年限判定
            LocalDate refDate = lastPromotionMap.get(c.getId());
            boolean fromPromotion = refDate != null;
            if (refDate == null || (c.getPositionStartDate() != null && c.getPositionStartDate().isAfter(refDate))) {
                refDate = c.getPositionStartDate();
                fromPromotion = false;
            }
            if (refDate == null) {
                // 既无晋升记录也无任现职时间，无法核算年限，不参与判定
                continue;
            }
            int requiredYears = rank.getPromotionYears() != null && rank.getPromotionYears() > 0
                    ? rank.getPromotionYears() : DEFAULT_REQUIRED_YEARS;
            long months = ChronoUnit.MONTHS.between(refDate, today);
            if (months < (long) requiredYears * 12) {
                continue;
            }
            long years = months / 12;
            long remainMonths = months % 12;
            String refText = fromPromotion
                    ? "上次晋升于" + refDate + "，至今已任满 " + years + " 年 " + remainMonths + " 个月"
                    : "任现职起始于 " + refDate + "，至今已任满 " + years + " 年 " + remainMonths + " 个月";

            // 规则7：近三年考核核验（统一口径见 AnnualAssessmentSupport，来源 cadre_info.annual_assessment）。
            // 未达标（含记录不足/关键年份缺失/基本称职及以下等次）直接从 eligible 剔除，不再出现在候选列表。
            if (!AnnualAssessmentSupport.qualified(c.getAnnualAssessment())) {
                continue;
            }

            PromotionEligibleVO vo = new PromotionEligibleVO();
            vo.setCadreId(c.getId());
            vo.setName(c.getName());
            vo.setGender(c.getGender());
            vo.setDeptId(c.getDeptId());
            vo.setPosition(c.getPosition());
            vo.setPositionLevel(c.getPositionLevel());
            vo.setCurrentRankId(rank.getId());
            vo.setCurrentRankName(rank.getRankName());
            vo.setCurrentRankCode(deriveRankCode(rank));
            vo.setCurrentRankSortOrder(rank.getSortOrder());
            vo.setRequiredYears(requiredYears);
            vo.setYearsText(refText + "，符合晋升所需年限要求（≥ " + requiredYears + " 年）");
            // 近三年考核核验结果：本接口仅返回达标干部（达标原因数组为空）
            vo.setAssessmentQualified(Boolean.TRUE);
            vo.setEligibleReason(Collections.emptyList());
            eligible.add(vo);
        }

        // 机构名称补全
        List<Long> deptIds = eligible.stream().map(PromotionEligibleVO::getDeptId).filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (!deptIds.isEmpty()) {
            List<Organization> depts = organizationService.listByIds(deptIds);
            if (depts != null) {
                Map<Long, String> deptNameMap = depts.stream().collect(Collectors.toMap(Organization::getId, Organization::getDeptName, (a, b) -> a));
                eligible.forEach(v -> v.setDeptName(deptNameMap.get(v.getDeptId())));
            }
        }

        // 手动分页返回
        int from = (int) Math.min((current - 1) * size, eligible.size());
        int to = (int) Math.min(from + size, eligible.size());
        Page<PromotionEligibleVO> page = new Page<>(current, size, eligible.size());
        page.setRecords(new ArrayList<>(eligible.subList(from, to)));
        return page;
    }

    /** 最近一次职级晋升日期（按 cadreId 分组取 promotion_date 最大值） */
    private Map<Long, LocalDate> loadLastPromotionDate(List<Long> cadreIds) {
        if (cadreIds == null || cadreIds.isEmpty()) {
            return Collections.emptyMap();
        }
        List<RankPromotionRecord> records = list(new LambdaQueryWrapper<RankPromotionRecord>()
                .in(RankPromotionRecord::getCadreId, cadreIds)
                .isNotNull(RankPromotionRecord::getPromotionDate)
                .select(RankPromotionRecord::getCadreId, RankPromotionRecord::getPromotionDate));
        Map<Long, LocalDate> result = new HashMap<>();
        if (records != null) {
            for (RankPromotionRecord r : records) {
                if (r.getCadreId() == null || r.getPromotionDate() == null) {
                    continue;
                }
                result.merge(r.getCadreId(), r.getPromotionDate(),
                        (a, b) -> a.isBefore(b) ? b : a);
            }
        }
        return result;
    }

    /**
     * org_rank 表/实体无 code 列：管理岗按 GL-xx、专业技术岗按 ZY-xx（xx 为补零 sortOrder）派生展示编码，不落库。
     */
    private String deriveRankCode(OrganizationRank rank) {
        if (rank.getRankType() == null || rank.getSortOrder() == null) {
            return null;
        }
        String prefix = "管理岗".equals(rank.getRankType()) ? "GL" : "ZY";
        return prefix + "-" + String.format("%02d", rank.getSortOrder());
    }
}
