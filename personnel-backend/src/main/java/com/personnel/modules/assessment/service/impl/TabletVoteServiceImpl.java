package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.personnel.common.BusinessException;
import com.personnel.modules.assessment.dto.BallotSubmitDTO;
import com.personnel.modules.assessment.entity.AssessmentBallot;
import com.personnel.modules.assessment.entity.AssessmentDimension;
import com.personnel.modules.assessment.entity.AssessmentIndicator;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.entity.AssessmentSignature;
import com.personnel.modules.assessment.entity.AssessmentTarget;
import com.personnel.modules.assessment.entity.AssessmentVote;
import com.personnel.modules.assessment.service.AssessmentBallotService;
import com.personnel.modules.assessment.service.AssessmentDimensionService;
import com.personnel.modules.assessment.service.AssessmentIndicatorService;
import com.personnel.modules.assessment.service.AssessmentSchemeService;
import com.personnel.modules.assessment.service.AssessmentSignatureService;
import com.personnel.modules.assessment.service.AssessmentTargetService;
import com.personnel.modules.assessment.service.AssessmentVoteService;
import com.personnel.modules.assessment.service.TabletVoteService;
import com.personnel.modules.assessment.vo.BallotResultItemVO;
import com.personnel.modules.assessment.vo.SignatureVO;
import com.personnel.modules.assessment.vo.TabletSchemeDetailVO;
import com.personnel.modules.assessment.vo.TabletSchemeListVO;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.service.OrganizationService;
import com.personnel.system.entity.SysUser;
import com.personnel.system.service.SysUserService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class TabletVoteServiceImpl implements TabletVoteService {

    @Resource
    private AssessmentSchemeService schemeService;

    @Resource
    private AssessmentTargetService targetService;

    @Resource
    private AssessmentVoteService voteService;

    @Resource
    private AssessmentBallotService ballotService;

    @Resource
    private AssessmentSignatureService signatureService;

    @Resource
    private AssessmentDimensionService dimensionService;

    @Resource
    private AssessmentIndicatorService indicatorService;

    @Resource
    private CadreInfoService cadreInfoService;

    @Resource
    private OrganizationService organizationService;

    @Resource
    private SysUserService sysUserService;

    private static final String MODE_BALLOT = "BALLOT";
    private static final String STATUS_PUBLISHED = "进行中";
    private static final Set<String> VALID_CHOICES = Set.of("APPROVE", "DISAPPROVE", "ABSTAIN");

    @Override
    public List<TabletSchemeListVO> listOngoingSchemes(Long voterId) {
        List<AssessmentScheme> schemes = schemeService.list(new LambdaQueryWrapper<AssessmentScheme>()
                .eq(AssessmentScheme::getStatus, STATUS_PUBLISHED)
                .orderByAsc(AssessmentScheme::getVoteStartTime));
        List<TabletSchemeListVO> result = new ArrayList<>();
        for (AssessmentScheme scheme : schemes) {
            TabletSchemeListVO vo = new TabletSchemeListVO();
            vo.setId(scheme.getId());
            vo.setSchemeName(scheme.getSchemeName());
            vo.setSchemeYear(scheme.getSchemeYear());
            vo.setVoteMode(modeOf(scheme));
            vo.setNeedSign(scheme.getNeedSign());
            vo.setVoteStartTime(scheme.getVoteStartTime());
            vo.setVoteEndTime(scheme.getVoteEndTime());
            boolean authed = voterId != null;
            vo.setSigned(authed && hasSigned(scheme.getId(), voterId));
            vo.setTargetTotal(targetService.count(new LambdaQueryWrapper<AssessmentTarget>()
                    .eq(AssessmentTarget::getSchemeId, scheme.getId())));
            vo.setVotedTargetCount(authed ? votedTargetCount(scheme, voterId) : 0L);
            result.add(vo);
        }
        return result;
    }

    @Override
    public TabletSchemeDetailVO getSchemeDetail(Long schemeId, Long voterId) {
        AssessmentScheme scheme = requireScheme(schemeId);
        boolean ballot = isBallot(scheme);
        TabletSchemeDetailVO vo = new TabletSchemeDetailVO();
        vo.setScheme(scheme);
        vo.setVoteMode(modeOf(scheme));
        vo.setNeedSign(scheme.getNeedSign());
        vo.setSigned(voterId != null && hasSigned(schemeId, voterId));

        List<AssessmentTarget> targets = targetService.list(new LambdaQueryWrapper<AssessmentTarget>()
                .eq(AssessmentTarget::getSchemeId, schemeId)
                .orderByAsc(AssessmentTarget::getId));
        Map<Long, CadreInfo> cadreMap = loadCadreMap(targets.stream()
                .map(AssessmentTarget::getCadreId).toList());
        Map<Long, String> deptNameMap = loadDeptNameMap(cadreMap.values());

        Map<Long, Map<Long, BigDecimal>> scoreByTarget = Map.of();
        Map<Long, String> choiceByTarget = Map.of();
        if (voterId != null) {
            if (ballot) {
                choiceByTarget = ballotService.list(new LambdaQueryWrapper<AssessmentBallot>()
                                .eq(AssessmentBallot::getSchemeId, schemeId)
                                .eq(AssessmentBallot::getVoterId, voterId))
                        .stream()
                        .collect(Collectors.toMap(AssessmentBallot::getTargetCadreId,
                                AssessmentBallot::getChoice, (a, b) -> b));
            } else {
                List<AssessmentVote> myVotes = voteService.list(new LambdaQueryWrapper<AssessmentVote>()
                        .eq(AssessmentVote::getSchemeId, schemeId)
                        .eq(AssessmentVote::getVoterId, voterId));
                Map<Long, List<AssessmentVote>> byTarget = myVotes.stream()
                        .collect(Collectors.groupingBy(AssessmentVote::getTargetCadreId));
                Map<Long, Map<Long, BigDecimal>> map = new HashMap<>();
                byTarget.forEach((targetId, votes) -> map.put(targetId, votes.stream()
                        .collect(Collectors.toMap(AssessmentVote::getIndicatorId,
                                v -> v.getScore() == null ? BigDecimal.ZERO : v.getScore(),
                                (a, b) -> b, LinkedHashMap::new))));
                scoreByTarget = map;
            }
        }

        List<TabletSchemeDetailVO.TargetItem> items = new ArrayList<>();
        for (AssessmentTarget target : targets) {
            TabletSchemeDetailVO.TargetItem item = new TabletSchemeDetailVO.TargetItem();
            item.setCadreId(target.getCadreId());
            CadreInfo cadre = cadreMap.get(target.getCadreId());
            if (cadre != null) {
                item.setCadreName(cadre.getName());
                item.setDeptName(deptNameMap.get(cadre.getDeptId()));
                item.setPosition(cadre.getPosition());
            }
            item.setMaterialTitle(target.getMaterialTitle());
            item.setMaterialText(target.getMaterialText());
            if (ballot) {
                item.setChoice(choiceByTarget.get(target.getCadreId()));
                item.setVoted(choiceByTarget.containsKey(target.getCadreId()));
                item.setScores(Map.of());
            } else {
                item.setScores(scoreByTarget.getOrDefault(target.getCadreId(), Map.of()));
                item.setVoted(!scoreByTarget.getOrDefault(target.getCadreId(), Map.of()).isEmpty());
            }
            items.add(item);
        }
        vo.setTargets(items);
        vo.setDimensions(buildDimensions(schemeId));
        return vo;
    }

    @Override
    @Transactional
    public void submitBallot(BallotSubmitDTO dto, Long voterId) {
        if (voterId == null) {
            throw new BusinessException("未获取到投票人身份，请重新登录");
        }
        if (dto == null || dto.getSchemeId() == null) {
            throw new BusinessException("方案不能为空");
        }
        AssessmentScheme scheme = requireScheme(dto.getSchemeId());
        if (!isBallot(scheme)) {
            throw new BusinessException("该方案为评分式，请通过评分方式投票");
        }
        checkPublishing(scheme);
        checkVoteWindow(scheme);
        if (hasSigned(dto.getSchemeId(), voterId)) {
            throw new BusinessException("您已完成签字确认，表决结果不可更改");
        }
        List<BallotSubmitDTO.BallotChoiceDTO> choices = dto.getChoices();
        if (choices == null || choices.isEmpty()) {
            throw new BusinessException("请选择至少一名对象的表决意见");
        }
        Set<Long> validTargets = targetService.list(new LambdaQueryWrapper<AssessmentTarget>()
                        .eq(AssessmentTarget::getSchemeId, dto.getSchemeId()))
                .stream().map(AssessmentTarget::getCadreId).collect(Collectors.toSet());
        Set<Long> seen = new HashSet<>();
        List<AssessmentBallot> ballots = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        for (BallotSubmitDTO.BallotChoiceDTO choiceDto : choices) {
            if (choiceDto.getTargetCadreId() == null || !validTargets.contains(choiceDto.getTargetCadreId())) {
                throw new BusinessException("存在不属于本方案的表决对象，请刷新后重试");
            }
            if (!seen.add(choiceDto.getTargetCadreId())) {
                throw new BusinessException("同一测评对象请勿重复提交表决");
            }
            if (!StringUtils.hasText(choiceDto.getChoice()) || !VALID_CHOICES.contains(choiceDto.getChoice())) {
                throw new BusinessException("表决意见仅支持：APPROVE赞成/DISAPPROVE反对/ABSTAIN弃权");
            }
            AssessmentBallot ballot = new AssessmentBallot();
            ballot.setSchemeId(dto.getSchemeId());
            ballot.setVoterId(voterId);
            ballot.setTargetCadreId(choiceDto.getTargetCadreId());
            ballot.setChoice(choiceDto.getChoice());
            ballot.setCreateTime(now);
            ballots.add(ballot);
        }
        // 覆盖式提交：逻辑删除旧行后插入本次全部表决
        ballotService.remove(new LambdaQueryWrapper<AssessmentBallot>()
                .eq(AssessmentBallot::getSchemeId, dto.getSchemeId())
                .eq(AssessmentBallot::getVoterId, voterId));
        ballotService.saveBatch(ballots);
    }

    @Override
    @Transactional
    public void sign(Long schemeId, Long voterId, String signImage, String deviceIp) {
        if (voterId == null) {
            throw new BusinessException("未获取到投票人身份，请重新登录");
        }
        AssessmentScheme scheme = requireScheme(schemeId);
        if (!STATUS_PUBLISHED.equals(scheme.getStatus())) {
            throw new BusinessException("测评未在进行中，无法签字");
        }
        if (hasSigned(schemeId, voterId)) {
            throw new BusinessException("您已完成签字确认，请勿重复签字");
        }
        List<AssessmentTarget> targets = targetService.list(new LambdaQueryWrapper<AssessmentTarget>()
                .eq(AssessmentTarget::getSchemeId, schemeId));
        if (targets.isEmpty()) {
            throw new BusinessException("方案暂无测评对象，无法签字");
        }
        boolean ballot = isBallot(scheme);
        for (AssessmentTarget target : targets) {
            if (ballot) {
                long count = ballotService.count(new LambdaQueryWrapper<AssessmentBallot>()
                        .eq(AssessmentBallot::getSchemeId, schemeId)
                        .eq(AssessmentBallot::getVoterId, voterId)
                        .eq(AssessmentBallot::getTargetCadreId, target.getCadreId()));
                if (count == 0) {
                    throw new BusinessException("存在尚未表决的测评对象，请先完成全部表决后再签字");
                }
            } else {
                long count = voteService.count(new LambdaQueryWrapper<AssessmentVote>()
                        .eq(AssessmentVote::getSchemeId, schemeId)
                        .eq(AssessmentVote::getVoterId, voterId)
                        .eq(AssessmentVote::getTargetCadreId, target.getCadreId()));
                if (count == 0) {
                    throw new BusinessException("存在尚未完成评分的测评对象，请先完成全部评分后再签字");
                }
            }
        }
        byte[] imageBytes = decodeImage(signImage);
        AssessmentSignature signature = new AssessmentSignature();
        signature.setSchemeId(schemeId);
        signature.setVoterId(voterId);
        signature.setSignImage(imageBytes);
        signature.setSignMd5(md5Hex(imageBytes));
        signature.setDeviceIp(deviceIp);
        signature.setSignTime(LocalDateTime.now());
        signature.setCreateBy(voterId);
        signature.setUpdateBy(voterId);
        signatureService.save(signature);
    }

    @Override
    public List<SignatureVO> listSignatures(Long schemeId) {
        requireScheme(schemeId);
        List<AssessmentSignature> signatures = signatureService.list(new LambdaQueryWrapper<AssessmentSignature>()
                .eq(AssessmentSignature::getSchemeId, schemeId)
                .orderByDesc(AssessmentSignature::getSignTime));
        List<Long> voterIds = signatures.stream().map(AssessmentSignature::getVoterId)
                .filter(Objects::nonNull).distinct().toList();
        Map<Long, SysUser> userMap = voterIds.isEmpty() ? Map.of()
                : sysUserService.listByIds(voterIds).stream()
                        .collect(Collectors.toMap(SysUser::getId, Function.identity()));
        List<SignatureVO> result = new ArrayList<>();
        for (AssessmentSignature signature : signatures) {
            SignatureVO vo = new SignatureVO();
            vo.setVoterId(signature.getVoterId());
            SysUser user = userMap.get(signature.getVoterId());
            if (user != null) {
                vo.setVoterName(user.getRealName());
            }
            vo.setSignTime(signature.getSignTime());
            vo.setDeviceIp(signature.getDeviceIp());
            vo.setSignMd5(signature.getSignMd5());
            vo.setImageData(signature.getSignImage() == null ? null
                    : Base64.getEncoder().encodeToString(signature.getSignImage()));
            result.add(vo);
        }
        return result;
    }

    @Override
    public List<BallotResultItemVO> countBallotResult(Long schemeId) {
        requireScheme(schemeId);
        List<AssessmentTarget> targets = targetService.list(new LambdaQueryWrapper<AssessmentTarget>()
                .eq(AssessmentTarget::getSchemeId, schemeId)
                .orderByAsc(AssessmentTarget::getId));
        List<AssessmentBallot> ballots = ballotService.list(new LambdaQueryWrapper<AssessmentBallot>()
                .eq(AssessmentBallot::getSchemeId, schemeId));
        Map<Long, List<AssessmentBallot>> byTarget = ballots.stream()
                .collect(Collectors.groupingBy(AssessmentBallot::getTargetCadreId));
        Map<Long, CadreInfo> cadreMap = loadCadreMap(targets.stream()
                .map(AssessmentTarget::getCadreId).toList());

        List<BallotResultItemVO> result = new ArrayList<>();
        for (AssessmentTarget target : targets) {
            List<AssessmentBallot> targetBallots = byTarget.getOrDefault(target.getCadreId(), List.of());
            BallotResultItemVO item = new BallotResultItemVO();
            item.setCadreId(target.getCadreId());
            CadreInfo cadre = cadreMap.get(target.getCadreId());
            if (cadre != null) {
                item.setCadreName(cadre.getName());
            }
            item.setApprove(countChoice(targetBallots, "APPROVE"));
            item.setDisapprove(countChoice(targetBallots, "DISAPPROVE"));
            item.setAbstain(countChoice(targetBallots, "ABSTAIN"));
            result.add(item);
        }
        return result;
    }

    private long countChoice(List<AssessmentBallot> ballots, String choice) {
        return ballots.stream().filter(b -> choice.equals(b.getChoice())).count();
    }

    private AssessmentScheme requireScheme(Long schemeId) {
        AssessmentScheme scheme = schemeService.getById(schemeId);
        if (scheme == null) {
            throw new BusinessException("测评方案不存在");
        }
        return scheme;
    }

    private boolean hasSigned(Long schemeId, Long voterId) {
        return signatureService.count(new LambdaQueryWrapper<AssessmentSignature>()
                .eq(AssessmentSignature::getSchemeId, schemeId)
                .eq(AssessmentSignature::getVoterId, voterId)) > 0;
    }

    private long votedTargetCount(AssessmentScheme scheme, Long voterId) {
        if (isBallot(scheme)) {
            return ballotService.list(new LambdaQueryWrapper<AssessmentBallot>()
                            .eq(AssessmentBallot::getSchemeId, scheme.getId())
                            .eq(AssessmentBallot::getVoterId, voterId))
                    .stream().map(AssessmentBallot::getTargetCadreId).distinct().count();
        }
        return voteService.list(new LambdaQueryWrapper<AssessmentVote>()
                        .eq(AssessmentVote::getSchemeId, scheme.getId())
                        .eq(AssessmentVote::getVoterId, voterId))
                .stream().map(AssessmentVote::getTargetCadreId).distinct().count();
    }

    private void checkPublishing(AssessmentScheme scheme) {
        if (!STATUS_PUBLISHED.equals(scheme.getStatus())) {
            throw new BusinessException("测评未在进行中，无法表决");
        }
    }

    private void checkVoteWindow(AssessmentScheme scheme) {
        LocalDateTime now = LocalDateTime.now();
        if (scheme.getVoteStartTime() != null && now.isBefore(scheme.getVoteStartTime())) {
            throw new BusinessException("测评尚未开始");
        }
        if (scheme.getVoteEndTime() != null && now.isAfter(scheme.getVoteEndTime())) {
            throw new BusinessException("测评已结束");
        }
    }

    private boolean isBallot(AssessmentScheme scheme) {
        return MODE_BALLOT.equals(scheme.getVoteMode());
    }

    private String modeOf(AssessmentScheme scheme) {
        return isBallot(scheme) ? MODE_BALLOT : "SCORE";
    }

    private List<TabletSchemeDetailVO.DimensionNode> buildDimensions(Long schemeId) {
        List<AssessmentDimension> dims = dimensionService.list(new LambdaQueryWrapper<AssessmentDimension>()
                .eq(AssessmentDimension::getSchemeId, schemeId)
                .orderByAsc(AssessmentDimension::getSortOrder));
        List<Long> dimIds = dims.stream().map(AssessmentDimension::getId).toList();
        Map<Long, List<AssessmentIndicator>> indicatorsByDim = dimIds.isEmpty() ? Map.of()
                : indicatorService.list(new LambdaQueryWrapper<AssessmentIndicator>()
                        .in(AssessmentIndicator::getDimensionId, dimIds)
                        .orderByAsc(AssessmentIndicator::getSortOrder))
                        .stream().collect(Collectors.groupingBy(AssessmentIndicator::getDimensionId));
        List<TabletSchemeDetailVO.DimensionNode> nodes = new ArrayList<>();
        for (AssessmentDimension dim : dims) {
            TabletSchemeDetailVO.DimensionNode node = new TabletSchemeDetailVO.DimensionNode();
            node.setId(dim.getId());
            node.setDimensionName(dim.getDimensionName());
            node.setDimensionWeight(dim.getDimensionWeight());
            List<TabletSchemeDetailVO.IndicatorItem> items = new ArrayList<>();
            for (AssessmentIndicator indicator : indicatorsByDim.getOrDefault(dim.getId(), List.of())) {
                TabletSchemeDetailVO.IndicatorItem item = new TabletSchemeDetailVO.IndicatorItem();
                item.setId(indicator.getId());
                item.setIndicatorName(indicator.getIndicatorName());
                item.setMaxScore(indicator.getMaxScore());
                items.add(item);
            }
            node.setIndicators(items);
            nodes.add(node);
        }
        return nodes;
    }

    private Map<Long, CadreInfo> loadCadreMap(List<Long> cadreIds) {
        List<Long> distinct = cadreIds.stream().filter(Objects::nonNull).distinct().toList();
        if (distinct.isEmpty()) {
            return Map.of();
        }
        return cadreInfoService.listByIds(distinct).stream()
                .collect(Collectors.toMap(CadreInfo::getId, Function.identity()));
    }

    private Map<Long, String> loadDeptNameMap(java.util.Collection<CadreInfo> cadres) {
        List<Long> deptIds = cadres.stream().map(CadreInfo::getDeptId)
                .filter(Objects::nonNull).distinct().toList();
        if (deptIds.isEmpty()) {
            return Map.of();
        }
        Map<Long, String> map = new HashMap<>();
        for (Organization org : organizationService.listByIds(deptIds)) {
            map.put(org.getId(), org.getDeptName());
        }
        return map;
    }

    /** 解析 dataURL(png) 的 base64 部分 */
    private byte[] decodeImage(String signImage) {
        if (!StringUtils.hasText(signImage)) {
            throw new BusinessException("签字图片不能为空");
        }
        String lower = signImage.toLowerCase();
        int idx = signImage.indexOf(",");
        if (!lower.startsWith("data:image/") || idx < 0
                || !lower.substring(0, idx).contains("base64")) {
            throw new BusinessException("签字图片格式不正确，须为PNG的base64 dataURL");
        }
        try {
            byte[] bytes = Base64.getMimeDecoder().decode(signImage.substring(idx + 1));
            if (bytes.length == 0) {
                throw new BusinessException("签字图片内容为空");
            }
            return bytes;
        } catch (IllegalArgumentException e) {
            throw new BusinessException("签字图片base64数据无效");
        }
    }

    private String md5Hex(byte[] bytes) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("MD5").digest(bytes));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("当前JDK不支持MD5算法", e);
        }
    }
}
