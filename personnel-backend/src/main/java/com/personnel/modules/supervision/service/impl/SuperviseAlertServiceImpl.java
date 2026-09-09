package com.personnel.modules.supervision.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyAbroadRecord;
import com.personnel.modules.daily.entity.DailyCertificate;
import com.personnel.modules.daily.entity.DailyLeave;
import com.personnel.modules.daily.service.DailyAbroadRecordService;
import com.personnel.modules.daily.service.DailyCertificateService;
import com.personnel.modules.daily.service.DailyLeaveService;
import com.personnel.modules.organization.entity.OrgTeamMember;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.service.OrgTeamMemberService;
import com.personnel.modules.organization.service.OrganizationService;
import com.personnel.modules.supervision.entity.SuperviseAlert;
import com.personnel.modules.supervision.entity.SuperviseAlertRule;
import com.personnel.modules.supervision.mapper.SuperviseAlertMapper;
import com.personnel.modules.supervision.service.SuperviseAlertRuleService;
import com.personnel.modules.supervision.service.SuperviseAlertService;
import org.springframework.stereotype.Service;

import jakarta.annotation.Resource;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 预警生成引擎：按 supervise_alert_rule（启用规则）扫描真实台账数据生成 supervise_alert。
 *
 * <p>幂等与失效清理策略说明（supervise_alert 无独立“处置状态”列，以 is_read 作为状态判据）：
 * <ul>
 *   <li>“未处理预警” = is_read=0（未读）。同一规则(rule_id)+同一业务引用(ref_id)已存在未读预警时不重复插入；
 *       若历史记录已读（视为已处理），重新扫描仍命中时允许再生成一条未读预警。</li>
 *   <li>每次扫描后，将该规则下 is_read=0 且 ref_id 不在本次扫描命中集合中的预警删除（视为已失效自动清理）；
 *       已读记录保留作为历史不清理。</li>
 * </ul>
 */
@Service
public class SuperviseAlertServiceImpl
        extends ServiceImpl<SuperviseAlertMapper, SuperviseAlert>
        implements SuperviseAlertService {

    /** 证照状态-在借 */
    private static final String CERT_LENT = "在借";
    /** 休假审批状态-已批准 */
    private static final String LEAVE_APPROVED = "已批准";
    /** 干部状态-在职 */
    private static final String CADRE_ON_JOB = "ON_JOB";
    /** 预警级别编码（规则级别 红/橙/黄 → RED/ORANGE/YELLOW） */
    private static final String LEVEL_RED = "RED";
    private static final String LEVEL_ORANGE = "ORANGE";
    private static final String LEVEL_YELLOW = "YELLOW";

    @Resource
    private SuperviseAlertRuleService superviseAlertRuleService;
    @Resource
    private DailyCertificateService dailyCertificateService;
    @Resource
    private DailyAbroadRecordService dailyAbroadRecordService;
    @Resource
    private DailyLeaveService dailyLeaveService;
    @Resource
    private OrgTeamMemberService orgTeamMemberService;
    @Resource
    private CadreInfoService cadreInfoService;
    @Resource
    private OrganizationService organizationService;

    @Override
    public Map<String, Object> generateByRules() {
        LocalDate today = LocalDate.now();
        List<SuperviseAlertRule> rules = superviseAlertRuleService.list(
                new LambdaQueryWrapper<SuperviseAlertRule>()
                        .eq(SuperviseAlertRule::getIsEnabled, 1)
                        .orderByAsc(SuperviseAlertRule::getId));

        List<Map<String, Object>> ruleStats = new ArrayList<>();
        int totalAdded = 0;
        for (SuperviseAlertRule rule : rules) {
            int added = scanByRule(rule, today);
            totalAdded += added;
            Map<String, Object> stat = new LinkedHashMap<>();
            stat.put("ruleId", rule.getId());
            stat.put("ruleType", rule.getRuleType());
            stat.put("ruleName", rule.getRuleName());
            stat.put("added", added);
            ruleStats.add(stat);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("added", totalAdded);
        result.put("rules", ruleStats);
        if (totalAdded > 0) {
            String detail = ruleStats.stream()
                    .filter(s -> (Integer) s.get("added") > 0)
                    .map(s -> s.get("ruleType") + " " + s.get("added") + "条")
                    .collect(Collectors.joining("、"));
            result.put("message", "扫描完成，共新增预警 " + totalAdded + " 条（" + detail + "）");
        } else {
            result.put("message", "扫描完成，无新增预警（当前台账无触发记录）");
        }
        return result;
    }

    /** 按单条启用规则扫描对应台账并落库，返回本次新增条数 */
    private int scanByRule(SuperviseAlertRule rule, LocalDate today) {
        if (rule == null || rule.getRuleType() == null) {
            return 0;
        }
        String ruleType = rule.getRuleType();
        List<SuperviseAlert> candidates;
        switch (ruleType) {
            case "证件到期":
                candidates = scanCertificates(rule, today);
                break;
            case "出国超期":
                candidates = scanAbroad(rule, today);
                break;
            case "休假超时":
                candidates = scanLeave(rule, today);
                break;
            case "任职超期":
                candidates = scanTeamTenure(rule, today);
                break;
            case "到龄退休":
                candidates = scanRetirement(rule, today);
                break;
            default:
                return 0;
        }

        // 幂等去重：同一规则 + 同一 ref 已存在“未处理(is_read=0)”预警则不再插入
        List<String> validRefs = candidates.stream()
                .map(SuperviseAlert::getRefId)
                .filter(Objects::nonNull)
                .distinct()
                .toList();
        Set<String> existingUnreadRefs = validRefs.isEmpty() ? Set.of()
                : list(new LambdaQueryWrapper<SuperviseAlert>()
                        .eq(SuperviseAlert::getRuleId, rule.getId())
                        .eq(SuperviseAlert::getIsRead, 0)
                        .in(SuperviseAlert::getRefId, validRefs))
                .stream()
                .map(SuperviseAlert::getRefId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        List<SuperviseAlert> toAdd = new ArrayList<>();
        for (SuperviseAlert candidate : candidates) {
            if (candidate.getRefId() != null && existingUnreadRefs.contains(candidate.getRefId())) {
                continue;
            }
            toAdd.add(candidate);
        }
        if (!toAdd.isEmpty()) {
            saveBatch(toAdd);
        }

        // 失效清理：同规则下未处理预警若本次扫描不再命中（台账已化解/失效），删除之；已读历史保留
        List<SuperviseAlert> unreadAlerts = list(new LambdaQueryWrapper<SuperviseAlert>()
                .eq(SuperviseAlert::getRuleId, rule.getId())
                .eq(SuperviseAlert::getIsRead, 0));
        List<Long> staleIds = unreadAlerts.stream()
                .filter(a -> a.getRefId() == null || !validRefs.contains(a.getRefId()))
                .map(SuperviseAlert::getId)
                .toList();
        if (!staleIds.isEmpty()) {
            removeByIds(staleIds);
        }
        return toAdd.size();
    }

    // ---------- 规则1：证件到期（daily_certificate 在借且 expected_return_date ≤ 今天+threshold，逾期亦命中） ----------
    private List<SuperviseAlert> scanCertificates(SuperviseAlertRule rule, LocalDate today) {
        List<DailyCertificate> certs = dailyCertificateService.list(
                new LambdaQueryWrapper<DailyCertificate>().eq(DailyCertificate::getCertStatus, CERT_LENT));
        if (certs.isEmpty()) {
            return List.of();
        }
        Map<Long, CadreInfo> cadreMap = cadreMapOf(certs.stream()
                .map(DailyCertificate::getCadreId).toList());
        Map<Long, String> deptMap = deptNameMapOf(cadreMap.values());
        int threshold = rule.getThreshold() == null ? 30 : rule.getThreshold();

        List<SuperviseAlert> alerts = new ArrayList<>();
        for (DailyCertificate cert : certs) {
            if (cert.getExpectedReturnDate() == null) {
                continue;
            }
            LocalDate expected = cert.getExpectedReturnDate();
            // 距今 ≤ threshold 天 或 已逾期（expected <= today+threshold）
            if (expected.isAfter(today.plusDays(threshold))) {
                continue;
            }
            CadreInfo cadre = cadreMap.get(cert.getCadreId());
            String name = cadre == null ? "干部#" + cert.getCadreId() : cadre.getName();
            String dept = cadre == null ? "" : deptMap.getOrDefault(cadre.getDeptId(), "");
            boolean overdue = expected.isBefore(today);
            long days = Math.abs(ChronoUnit.DAYS.between(expected, today));
            SuperviseAlert alert = new SuperviseAlert();
            alert.setAlertType(levelToCode(rule.getLevel()));
            alert.setAlertCategory(rule.getRuleType());
            alert.setTargetCadreId(cert.getCadreId());
            alert.setTargetUserId(null);
            alert.setIsRead(0);
            alert.setRuleId(rule.getId());
            alert.setRefId("CERT-" + cert.getId());
            alert.setAlertTitle(overdue ? "证照借用逾期未归还" : "证照借用临近应还");
            alert.setAlertContent("干部" + name + (dept.isEmpty() ? "" : "（" + dept + "）")
                    + "借用的" + nvl(cert.getCertType())
                    + "（证号" + nvl(cert.getCertNumber()) + "）应还日期 " + expected
                    + (overdue ? "，已逾期 " + days + " 天，请督促交回归档" : "，仅剩 " + days + " 天，请提醒按期归还"));
            alerts.add(alert);
        }
        return alerts;
    }

    // ---------- 规则2：出国超期（daily_abroad_record 已批准且超期未归/应返未登记回国） ----------
    private List<SuperviseAlert> scanAbroad(SuperviseAlertRule rule, LocalDate today) {
        List<DailyAbroadRecord> records = dailyAbroadRecordService.list(
                new LambdaQueryWrapper<DailyAbroadRecord>().eq(DailyAbroadRecord::getIsApproved, 1));
        if (records.isEmpty()) {
            return List.of();
        }
        Map<Long, CadreInfo> cadreMap = cadreMapOf(records.stream()
                .map(DailyAbroadRecord::getCadreId).toList());
        Map<Long, String> deptMap = deptNameMapOf(cadreMap.values());

        List<SuperviseAlert> alerts = new ArrayList<>();
        for (DailyAbroadRecord record : records) {
            if (record.getDepartDate() == null || record.getApprovedDays() == null) {
                continue;
            }
            LocalDate expectedReturn = record.getDepartDate().plusDays(record.getApprovedDays());
            boolean alreadyOverdue = record.getIsOverdue() != null && record.getIsOverdue() == 1;
            boolean returnBeyondApproved = record.getReturnDate() != null
                    && record.getReturnDate().isAfter(expectedReturn);
            boolean overdueNotRegistered = record.getReturnDate() == null
                    && expectedReturn.isBefore(today);
            if (!alreadyOverdue && !returnBeyondApproved && !overdueNotRegistered) {
                continue;
            }
            CadreInfo cadre = cadreMap.get(record.getCadreId());
            String name = cadre == null ? "干部#" + record.getCadreId() : cadre.getName();
            String dept = cadre == null ? "" : deptMap.getOrDefault(cadre.getDeptId(), "");
            long overdueDays = record.getReturnDate() == null
                    ? ChronoUnit.DAYS.between(expectedReturn, today)
                    : ChronoUnit.DAYS.between(expectedReturn, record.getReturnDate());
            SuperviseAlert alert = new SuperviseAlert();
            alert.setAlertType(levelToCode(rule.getLevel()));
            alert.setAlertCategory(rule.getRuleType());
            alert.setTargetCadreId(record.getCadreId());
            alert.setTargetUserId(null);
            alert.setIsRead(0);
            alert.setRuleId(rule.getId());
            alert.setRefId("ABROAD-" + record.getId());
            alert.setAlertTitle("出国(境)超期预警");
            alert.setAlertContent("干部" + name + (dept.isEmpty() ? "" : "（" + dept + "）")
                    + "经批准赴" + nvl(record.getDestination())
                    + "（批准" + record.getApprovedDays() + "天，应于 " + expectedReturn + " 前返回）"
                    + (record.getReturnDate() == null
                    ? "，至今未登记回国，已超期 " + overdueDays + " 天，请核查处理"
                    : "，已于 " + record.getReturnDate() + " 返回但超期 " + overdueDays + " 天，请核查处理"));
            alerts.add(alert);
        }
        return alerts;
    }

    // ---------- 规则3：休假超时（已批准且 end_date 早于今天 = 超期未销假/未返岗） ----------
    private List<SuperviseAlert> scanLeave(SuperviseAlertRule rule, LocalDate today) {
        List<DailyLeave> leaves = dailyLeaveService.list(
                new LambdaQueryWrapper<DailyLeave>().eq(DailyLeave::getApproveStatus, LEAVE_APPROVED));
        if (leaves.isEmpty()) {
            return List.of();
        }
        Map<Long, CadreInfo> cadreMap = cadreMapOf(leaves.stream()
                .map(DailyLeave::getCadreId).toList());
        Map<Long, String> deptMap = deptNameMapOf(cadreMap.values());

        List<SuperviseAlert> alerts = new ArrayList<>();
        for (DailyLeave leave : leaves) {
            if (leave.getEndDate() == null || !leave.getEndDate().isBefore(today)) {
                continue;
            }
            CadreInfo cadre = cadreMap.get(leave.getCadreId());
            String name = cadre == null ? "干部#" + leave.getCadreId() : cadre.getName();
            String dept = cadre == null ? "" : deptMap.getOrDefault(cadre.getDeptId(), "");
            long overdueDays = ChronoUnit.DAYS.between(leave.getEndDate(), today);
            SuperviseAlert alert = new SuperviseAlert();
            alert.setAlertType(levelToCode(rule.getLevel()));
            alert.setAlertCategory(rule.getRuleType());
            alert.setTargetCadreId(leave.getCadreId());
            alert.setTargetUserId(null);
            alert.setIsRead(0);
            alert.setRuleId(rule.getId());
            alert.setRefId("LEAVE-" + leave.getId());
            alert.setAlertTitle("休假结束超期未销假");
            alert.setAlertContent("干部" + name + (dept.isEmpty() ? "" : "（" + dept + "）")
                    + "的" + nvl(leave.getLeaveType()) + "（" + leave.getStartDate() + " 至 "
                    + leave.getEndDate() + "）已结束超期 " + overdueDays + " 天，未见销假/返岗登记，请提醒补办销假手续");
            alerts.add(alert);
        }
        return alerts;
    }

    // ---------- 规则4：任职超期（现任班子 start_date 任职时长超过阈值；阈值按天存，换算年时除以365） ----------
    private List<SuperviseAlert> scanTeamTenure(SuperviseAlertRule rule, LocalDate today) {
        List<OrgTeamMember> members = orgTeamMemberService.list(
                new LambdaQueryWrapper<OrgTeamMember>().isNull(OrgTeamMember::getEndDate));
        if (members.isEmpty()) {
            return List.of();
        }
        Map<Long, CadreInfo> cadreMap = cadreMapOf(members.stream()
                .map(OrgTeamMember::getCadreId).toList());
        Map<Long, String> deptMap = deptNameMapOf(cadreMap.values());
        int thresholdDays = rule.getThreshold() == null ? 365 : rule.getThreshold();

        List<SuperviseAlert> alerts = new ArrayList<>();
        for (OrgTeamMember member : members) {
            if (member.getStartDate() == null) {
                continue;
            }
            long tenureDays = ChronoUnit.DAYS.between(member.getStartDate(), today);
            // 任职时长(天)超过阈值(天)，等效于超过 threshold/365 年
            if (tenureDays <= thresholdDays) {
                continue;
            }
            CadreInfo cadre = cadreMap.get(member.getCadreId());
            String name = cadre == null ? "干部#" + member.getCadreId() : cadre.getName();
            String dept = cadre == null ? "" : deptMap.getOrDefault(cadre.getDeptId(), "");
            double years = tenureDays / 365.0;
            double thresholdYears = thresholdDays / 365.0;
            SuperviseAlert alert = new SuperviseAlert();
            alert.setAlertType(levelToCode(rule.getLevel()));
            alert.setAlertCategory(rule.getRuleType());
            alert.setTargetCadreId(member.getCadreId());
            alert.setTargetUserId(null);
            alert.setIsRead(0);
            alert.setRuleId(rule.getId());
            alert.setRefId("TEAM-" + member.getId());
            alert.setAlertTitle("班子任职超期");
            alert.setAlertContent("干部" + name + (dept.isEmpty() ? "" : "（" + dept + "）")
                    + "担任" + nvl(member.getLeaderPost()) + "自 " + member.getStartDate()
                    + " 至今已任职约 " + String.format("%.1f", years) + " 年，超过最长任职年限阈值"
                    + "（" + thresholdDays + " 天 ≈ " + String.format("%.2f", thresholdYears) + " 年），建议启动轮岗交流");
            alerts.add(alert);
        }
        return alerts;
    }

    // ---------- 规则5：到龄退休（在职干部达法定退休年龄男60/女55，且距退休 ≤ threshold 天或已到龄仍在职） ----------
    private List<SuperviseAlert> scanRetirement(SuperviseAlertRule rule, LocalDate today) {
        List<CadreInfo> cadres = cadreInfoService.list(
                new LambdaQueryWrapper<CadreInfo>().eq(CadreInfo::getCadreStatus, CADRE_ON_JOB));
        if (cadres.isEmpty()) {
            return List.of();
        }
        Map<Long, String> deptMap = deptNameMapOf(cadres);
        int threshold = rule.getThreshold() == null ? 365 : rule.getThreshold();

        List<SuperviseAlert> alerts = new ArrayList<>();
        for (CadreInfo cadre : cadres) {
            if (cadre.getGender() == null || cadre.getBirthDate() == null) {
                continue;
            }
            boolean female = cadre.getGender() == 2;
            int retireAge = female ? 55 : 60;
            LocalDate retireDate = cadre.getBirthDate().plusYears(retireAge);
            // 已到龄(retireDate<=today) 或 距退休 ≤ threshold 天
            if (retireDate.isAfter(today.plusDays(threshold))) {
                continue;
            }
            String genderText = female ? "女" : "男";
            String name = cadre.getName() == null ? "干部#" + cadre.getId() : cadre.getName();
            String dept = deptMap.getOrDefault(cadre.getDeptId(), "");
            boolean reached = !retireDate.isAfter(today);
            long days = Math.abs(ChronoUnit.DAYS.between(retireDate, today));
            SuperviseAlert alert = new SuperviseAlert();
            alert.setAlertType(levelToCode(rule.getLevel()));
            alert.setAlertCategory(rule.getRuleType());
            alert.setTargetCadreId(cadre.getId());
            alert.setTargetUserId(null);
            alert.setIsRead(0);
            alert.setRuleId(rule.getId());
            alert.setRefId("RETIRE-" + cadre.getId());
            alert.setAlertTitle(reached ? "到龄应退仍未办理退休" : "临近法定退休年龄");
            alert.setAlertContent("干部" + name + (dept.isEmpty() ? "" : "（" + dept + "）")
                    + "（" + genderText + "）出生 " + cadre.getBirthDate() + "，法定退休日期为 "
                    + retireDate + (reached
                    ? "，已到龄仍在职，请及时办理退休手续"
                    : "，距退休仅剩 " + days + " 天，请提前准备办理退休手续"));
            alerts.add(alert);
        }
        return alerts;
    }

    // ---------- 辅助 ----------

    /** 规则级别(红/橙/黄) → 预警记录 alert_type 编码（前端按 RED/ORANGE/YELLOW 展示颜色级别） */
    private String levelToCode(String level) {
        if (level == null) {
            return LEVEL_YELLOW;
        }
        switch (level) {
            case "红色":
                return LEVEL_RED;
            case "橙色":
                return LEVEL_ORANGE;
            case "黄色":
                return LEVEL_YELLOW;
            default:
                return level;
        }
    }

    private String nvl(String s) {
        return s == null || s.isBlank() ? "-" : s;
    }

    /** 按 ID 批量取干部档案（过滤空 id） */
    private Map<Long, CadreInfo> cadreMapOf(List<Long> cadreIds) {
        List<Long> distinct = cadreIds.stream().filter(Objects::nonNull).distinct().toList();
        if (distinct.isEmpty()) {
            return Map.of();
        }
        return cadreInfoService.listByIds(distinct).stream()
                .collect(Collectors.toMap(CadreInfo::getId, Function.identity()));
    }

    /** 干部档案所属机构 deptId → 机构名称 */
    private Map<Long, String> deptNameMapOf(Iterable<CadreInfo> cadres) {
        List<Long> deptIds = new ArrayList<>();
        for (CadreInfo cadre : cadres) {
            if (cadre != null && cadre.getDeptId() != null) {
                deptIds.add(cadre.getDeptId());
            }
        }
        List<Long> distinct = deptIds.stream().distinct().toList();
        if (distinct.isEmpty()) {
            return Map.of();
        }
        Map<Long, String> map = new HashMap<>();
        for (Organization org : organizationService.listByIds(distinct)) {
            if (org != null && org.getId() != null) {
                map.put(org.getId(), org.getDeptName() == null ? String.valueOf(org.getId()) : org.getDeptName());
            }
        }
        return map;
    }
}
