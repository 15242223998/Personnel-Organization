package com.personnel.modules.notice.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.service.AssessmentSchemeService;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.daily.entity.DailyAbroadRecord;
import com.personnel.modules.daily.entity.DailyCertificate;
import com.personnel.modules.daily.entity.DailyLeave;
import com.personnel.modules.daily.entity.DailySelfApplication;
import com.personnel.modules.daily.service.DailyAbroadRecordService;
import com.personnel.modules.daily.service.DailyCertificateService;
import com.personnel.modules.daily.service.DailyLeaveService;
import com.personnel.modules.daily.service.DailySelfApplicationService;
import com.personnel.modules.notice.vo.NoticeVO;
import com.personnel.modules.supervision.entity.SuperviseAlert;
import com.personnel.modules.supervision.service.SuperviseAlertService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 消息通知中心：实时汇总各业务模块的待办/提醒（时间取自真实业务记录）
 */
@RestController
@RequestMapping("/api/notice")
public class NoticeController {

    private static final String STATUS_PUBLISHED = "进行中";
    private static final String LEAVE_PENDING = "待审批";
    private static final String CERT_LENT = "在借";

    @Resource
    private AssessmentSchemeService schemeService;
    @Resource
    private DailyLeaveService leaveService;
    @Resource
    private DailyCertificateService certificateService;
    @Resource
    private DailyAbroadRecordService abroadService;
    @Resource
    private DailySelfApplicationService selfApplicationService;
    @Resource
    private CadreInfoService cadreInfoService;
    @Resource
    private com.personnel.system.service.SysUserService sysUserService;
    @Resource
    private SuperviseAlertService superviseAlertService;

    @GetMapping("/list")
    public Result<List<NoticeVO>> list() {
        List<NoticeVO> list = new ArrayList<>();
        com.personnel.framework.security.LoginUser loginUser =
                com.personnel.framework.security.SecurityUtils.getLoginUser();
        // 管理职能账号（系统管理员/校级领导/部长/组织员）才推送管理类待办通知；
        // 其余普通干部账号只推送与本人相关的三类真实结果（智能预警/本人申报审批结果/本人休假审批结果）
        if (isManagerUser()) {
            list.addAll(pendingRegistrations());
            list.addAll(ongoingSchemes());
            list.addAll(pendingLeaves());
            list.addAll(lentCertificates());
            list.addAll(overdueAbroad());
        } else if (loginUser != null && loginUser.getUser() != null) {
            Long cadreId = loginUser.getUser().getCadreId();
            list.addAll(personalAlerts(cadreId));
            list.addAll(selfApplicationResults(loginUser.getUser().getId()));
            if (cadreId != null) {
                list.addAll(selfLeaveResults(cadreId));
            }
            list = distinctNotices(list);
        }
        // 按时间倒序，最多返回 8 条
        list.sort(Comparator.comparing(NoticeVO::getTime,
                Comparator.nullsLast(Comparator.reverseOrder())));
        if (list.size() > 8) {
            list = list.subList(0, 8);
        }
        return Result.success(list);
    }

    /** 普通干部本人相关预警 → 通知（type=alert，跳转首页展示） */
    private List<NoticeVO> personalAlerts(Long cadreId) {
        if (cadreId == null) {
            return List.of();
        }
        List<SuperviseAlert> alerts = superviseAlertService.list(
                new LambdaQueryWrapper<SuperviseAlert>()
                        .eq(SuperviseAlert::getTargetCadreId, cadreId)
                        .orderByDesc(SuperviseAlert::getCreateTime)
                        .last("LIMIT 8"));
        List<NoticeVO> items = new ArrayList<>();
        for (SuperviseAlert alert : alerts) {
            NoticeVO vo = new NoticeVO();
            vo.setId("alert-" + alert.getId());
            vo.setType("alert");
            vo.setTitle(alert.getAlertTitle() == null ? "本人预警提醒" : alert.getAlertTitle());
            vo.setDesc(alert.getAlertContent());
            vo.setTime(alert.getCreateTime());
            vo.setPath("/dashboard");
            items.add(vo);
        }
        return items;
    }

    /** 本人创建的干部自助申报审批结果（type=application，跳转个人信息申报页） */
    private List<NoticeVO> selfApplicationResults(Long userId) {
        if (userId == null) {
            return List.of();
        }
        List<DailySelfApplication> apps = selfApplicationService.list(
                new LambdaQueryWrapper<DailySelfApplication>()
                        .eq(DailySelfApplication::getApplicantId, userId)
                        .in(DailySelfApplication::getApplyStatus, "APPROVED", "REJECTED")
                        .orderByDesc(DailySelfApplication::getUpdateTime)
                        .last("LIMIT 8"));
        List<NoticeVO> items = new ArrayList<>();
        for (DailySelfApplication app : apps) {
            boolean approved = "APPROVED".equals(app.getApplyStatus());
            NoticeVO vo = new NoticeVO();
            vo.setId("application-" + app.getId());
            vo.setType("application");
            String title = app.getApplicationTitle();
            vo.setTitle((approved ? "申报已通过" : "申报被驳回") + "：" + (title == null || title.isBlank()
                    ? (app.getApplicationType() == null ? "申报" : app.getApplicationType()) : title));
            String comment = app.getApproveComment();
            vo.setDesc((approved ? "审批通过" : "审批驳回")
                    + (comment == null || comment.isBlank() ? "，审批人未填写意见" : "，审批意见：" + comment));
            vo.setTime(app.getUpdateTime() == null ? app.getApproveTime() : app.getUpdateTime());
            vo.setPath("/cadre/declaration");
            items.add(vo);
        }
        return items;
    }

    /** 本人（按档案 cadre_id）相关的休假审批结果 → 通知（type=leave） */
    private List<NoticeVO> selfLeaveResults(Long cadreId) {
        List<DailyLeave> leaves = leaveService.list(new LambdaQueryWrapper<DailyLeave>()
                .eq(DailyLeave::getCadreId, cadreId)
                .in(DailyLeave::getApproveStatus, "已批准", "已驳回")
                .orderByDesc(DailyLeave::getApproveTime)
                .last("LIMIT 8"));
        List<NoticeVO> items = new ArrayList<>();
        for (DailyLeave leave : leaves) {
            boolean approved = "已批准".equals(leave.getApproveStatus());
            NoticeVO vo = new NoticeVO();
            vo.setId("leave-" + leave.getId());
            vo.setType("leave");
            vo.setTitle(approved ? "休假申请已批准" : "休假申请被驳回");
            vo.setDesc((leave.getLeaveType() == null ? "休假" : leave.getLeaveType())
                    + (leave.getStartDate() == null ? "" : "（" + leave.getStartDate()
                    + (leave.getEndDate() == null ? "" : " 至 " + leave.getEndDate()) + "）")
                    + "，审批已办结" + (leave.getReason() == null || leave.getReason().isBlank()
                    ? "" : "，事由：" + leave.getReason()));
            vo.setTime(leave.getApproveTime() == null ? leave.getUpdateTime() : leave.getApproveTime());
            vo.setPath("/daily");
            items.add(vo);
        }
        return items;
    }

    /** 合并去重（按通知 id），保证同一业务记录不会重复推送 */
    private List<NoticeVO> distinctNotices(List<NoticeVO> items) {
        Map<String, NoticeVO> distinct = new java.util.LinkedHashMap<>();
        for (NoticeVO vo : items) {
            distinct.putIfAbsent(vo.getId(), vo);
        }
        return new ArrayList<>(distinct.values());
    }

    /** 是否为管理职能账号：系统管理员/校级领导/组织部部长/组织员 */
    private boolean isManagerUser() {
        com.personnel.framework.security.LoginUser loginUser =
                com.personnel.framework.security.SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getUser() == null
                || loginUser.getUser().getUserType() == null) {
            return false;
        }
        int type = loginUser.getUser().getUserType();
        return type >= 1 && type <= 4;
    }

    /** 新账号注册待审批（仅系统管理员可见） */
    private List<NoticeVO> pendingRegistrations() {
        List<NoticeVO> items = new ArrayList<>();
        com.personnel.framework.security.LoginUser loginUser =
                com.personnel.framework.security.SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getUser() == null
                || loginUser.getUser().getUserType() == null
                || loginUser.getUser().getUserType() != 1) {
            return items;
        }
        List<com.personnel.system.entity.SysUser> pending = sysUserService.list(
                new LambdaQueryWrapper<com.personnel.system.entity.SysUser>()
                        .eq(com.personnel.system.entity.SysUser::getStatus, 0)
                        .orderByAsc(com.personnel.system.entity.SysUser::getCreateTime)
                        .last("LIMIT 3"));
        for (com.personnel.system.entity.SysUser u : pending) {
            NoticeVO vo = new NoticeVO();
            vo.setId("register-" + u.getId());
            vo.setType("register");
            vo.setTitle("新账号待注册审批");
            vo.setDesc((u.getRealName() == null || u.getRealName().isBlank()
                    ? u.getUsername() : u.getRealName()) + "（" + u.getUsername() + "）申请注册，请审批");
            vo.setTime(u.getCreateTime());
            vo.setPath("/system/register-approval");
            items.add(vo);
        }
        return items;
    }

    /** 进行中的民主测评（按投票截止时间提醒） */
    private List<NoticeVO> ongoingSchemes() {
        List<NoticeVO> items = new ArrayList<>();
        List<AssessmentScheme> schemes = schemeService.list(
                new LambdaQueryWrapper<AssessmentScheme>()
                        .eq(AssessmentScheme::getStatus, STATUS_PUBLISHED)
                        .orderByDesc(AssessmentScheme::getVoteEndTime));
        for (AssessmentScheme scheme : schemes) {
            NoticeVO vo = new NoticeVO();
            vo.setId("scheme-" + scheme.getId());
            vo.setType("scheme");
            vo.setTitle("民主测评进行中");
            vo.setDesc(scheme.getSchemeName() + "（" + scheme.getSchemeYear() + "），投票截止 "
                    + (scheme.getVoteEndTime() == null ? "待定" : scheme.getVoteEndTime().toLocalDate()));
            vo.setTime(scheme.getVoteEndTime() == null ? scheme.getCreateTime() : scheme.getVoteEndTime());
            vo.setPath("/assessment");
            items.add(vo);
        }
        return items;
    }

    /** 待审批休假 */
    private List<NoticeVO> pendingLeaves() {
        List<DailyLeave> leaves = leaveService.list(new LambdaQueryWrapper<DailyLeave>()
                .eq(DailyLeave::getApproveStatus, LEAVE_PENDING)
                .orderByDesc(DailyLeave::getCreateTime));
        if (leaves.isEmpty()) {
            return List.of();
        }
        Map<Long, CadreInfo> cadres = cadreMap(leaves.stream()
                .map(DailyLeave::getCadreId).toList());
        List<NoticeVO> items = new ArrayList<>();
        for (DailyLeave leave : leaves) {
            CadreInfo cadre = cadres.get(leave.getCadreId());
            NoticeVO vo = new NoticeVO();
            vo.setId("leave-" + leave.getId());
            vo.setType("leave");
            vo.setTitle("休假申请待审批");
            vo.setDesc((cadre == null ? "干部" : cadre.getName()) + "申请" + leave.getLeaveType()
                    + "（" + leave.getStartDate() + " 至 " + leave.getEndDate() + "），请及时审批");
            vo.setTime(leave.getCreateTime());
            vo.setPath("/daily");
            items.add(vo);
        }
        return items;
    }

    /** 借用中的证照（临近/逾期应还） */
    private List<NoticeVO> lentCertificates() {
        List<DailyCertificate> certs = certificateService.list(new LambdaQueryWrapper<DailyCertificate>()
                .eq(DailyCertificate::getCertStatus, CERT_LENT)
                .orderByAsc(DailyCertificate::getExpectedReturnDate));
        if (certs.isEmpty()) {
            return List.of();
        }
        Map<Long, CadreInfo> cadres = cadreMap(certs.stream()
                .map(DailyCertificate::getCadreId).toList());
        List<NoticeVO> items = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (DailyCertificate cert : certs) {
            LocalDate expected = cert.getExpectedReturnDate();
            if (expected == null) {
                continue;
            }
            boolean overdue = expected.isBefore(today);
            CadreInfo cadre = cadres.get(cert.getCadreId());
            NoticeVO vo = new NoticeVO();
            vo.setId("cert-" + cert.getId());
            vo.setType("cert");
            vo.setTitle(overdue ? "证照借用已逾期" : "证照借用临近应还");
            vo.setDesc((cadre == null ? "干部" : cadre.getName()) + "借用的" + cert.getCertType()
                    + "（" + cert.getCertNumber() + "）应还日期 " + expected + "，请督促归还");
            vo.setTime(expected.atStartOfDay());
            vo.setPath("/daily");
            items.add(vo);
        }
        return items;
    }

    /** 出境超期记录 */
    private List<NoticeVO> overdueAbroad() {
        List<DailyAbroadRecord> records = abroadService.list(new LambdaQueryWrapper<DailyAbroadRecord>()
                .eq(DailyAbroadRecord::getIsOverdue, 1)
                .orderByDesc(DailyAbroadRecord::getCreateTime));
        if (records.isEmpty()) {
            return List.of();
        }
        Map<Long, CadreInfo> cadres = cadreMap(records.stream()
                .map(DailyAbroadRecord::getCadreId).toList());
        List<NoticeVO> items = new ArrayList<>();
        for (DailyAbroadRecord record : records) {
            CadreInfo cadre = cadres.get(record.getCadreId());
            NoticeVO vo = new NoticeVO();
            vo.setId("abroad-" + record.getId());
            vo.setType("abroad");
            vo.setTitle("出境超期提醒");
            vo.setDesc((cadre == null ? "干部" : cadre.getName()) + "出访" + record.getDestination()
                    + "存在超期记录（" + record.getDepartDate() + " 至 " + record.getReturnDate() + "），请核查处理");
            vo.setTime(record.getCreateTime());
            vo.setPath("/daily");
            items.add(vo);
        }
        return items;
    }

    private Map<Long, CadreInfo> cadreMap(List<Long> cadreIds) {
        List<Long> distinct = cadreIds.stream().filter(Objects::nonNull).distinct().toList();
        if (distinct.isEmpty()) {
            return Map.of();
        }
        return cadreInfoService.listByIds(distinct).stream()
                .collect(Collectors.toMap(CadreInfo::getId, Function.identity()));
    }
}
