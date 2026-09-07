package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.assessment.entity.AssessmentDimension;
import com.personnel.modules.assessment.entity.AssessmentIndicator;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.entity.AssessmentTarget;
import com.personnel.modules.assessment.entity.AssessmentVote;
import com.personnel.modules.assessment.mapper.AssessmentVoteMapper;
import com.personnel.modules.assessment.service.AssessmentDimensionService;
import com.personnel.modules.assessment.service.AssessmentIndicatorService;
import com.personnel.modules.assessment.service.AssessmentSchemeService;
import com.personnel.modules.assessment.service.AssessmentTargetService;
import com.personnel.modules.assessment.service.AssessmentVoteService;
import com.personnel.modules.assessment.vo.VoteResultItemVO;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import com.personnel.modules.organization.entity.Organization;
import com.personnel.modules.organization.service.OrganizationService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class AssessmentVoteServiceImpl extends ServiceImpl<AssessmentVoteMapper, AssessmentVote> implements AssessmentVoteService {

    @Resource
    private AssessmentSchemeService schemeService;

    @Resource
    private AssessmentDimensionService dimensionService;

    @Resource
    private AssessmentIndicatorService indicatorService;

    @Resource
    private AssessmentTargetService targetService;

    @Resource
    private CadreInfoService cadreInfoService;

    @Resource
    private OrganizationService organizationService;

    private static final String STATUS_PUBLISHED = "进行中";

    @Override
    @Transactional
    public void submitVote(Long schemeId, Long targetCadreId, Long voterId, Map<Long, BigDecimal> scores) {
        if (voterId == null) {
            throw new BusinessException("未获取到投票人身份，请重新登录");
        }
        AssessmentScheme scheme = schemeService.getById(schemeId);
        if (scheme == null) {
            throw new BusinessException("测评方案不存在");
        }
        if (!STATUS_PUBLISHED.equals(scheme.getStatus())) {
            throw new BusinessException("测评未在进行中，无法投票");
        }
        LocalDateTime now = LocalDateTime.now();
        if (scheme.getVoteStartTime() != null && now.isBefore(scheme.getVoteStartTime())) {
            throw new BusinessException("测评尚未开始");
        }
        if (scheme.getVoteEndTime() != null && now.isAfter(scheme.getVoteEndTime())) {
            throw new BusinessException("测评已结束");
        }
        long targetCount = targetService.count(new LambdaQueryWrapper<AssessmentTarget>()
                .eq(AssessmentTarget::getSchemeId, schemeId)
                .eq(AssessmentTarget::getCadreId, targetCadreId));
        if (targetCount == 0) {
            throw new BusinessException("该干部不属于本方案测评对象");
        }
        if (scores == null || scores.isEmpty()) {
            throw new BusinessException("请填写评分");
        }

        // 方案下全部指标
        List<AssessmentIndicator> schemeIndicators = listSchemeIndicators(schemeId);
        Map<Long, AssessmentIndicator> indicatorMap = schemeIndicators.stream()
                .collect(Collectors.toMap(AssessmentIndicator::getId, Function.identity()));

        // 防止重复投票
        List<AssessmentVote> existVotes = list(new LambdaQueryWrapper<AssessmentVote>()
                .eq(AssessmentVote::getSchemeId, schemeId)
                .eq(AssessmentVote::getVoterId, voterId)
                .eq(AssessmentVote::getTargetCadreId, targetCadreId));
        if (!existVotes.isEmpty()) {
            throw new BusinessException("您已对该干部投过票，请勿重复提交");
        }

        List<AssessmentVote> votes = new ArrayList<>();
        for (Map.Entry<Long, BigDecimal> entry : scores.entrySet()) {
            AssessmentIndicator indicator = indicatorMap.get(entry.getKey());
            if (indicator == null) {
                throw new BusinessException("评分指标不属于本方案");
            }
            BigDecimal score = entry.getValue();
            if (score == null || score.compareTo(BigDecimal.ZERO) < 0) {
                throw new BusinessException("指标【" + indicator.getIndicatorName() + "】评分不能为空或为负数");
            }
            if (indicator.getMaxScore() != null && score.compareTo(indicator.getMaxScore()) > 0) {
                throw new BusinessException("指标【" + indicator.getIndicatorName() + "】评分不能超过最高分 "
                        + indicator.getMaxScore().stripTrailingZeros().toPlainString());
            }
            AssessmentVote vote = new AssessmentVote();
            vote.setSchemeId(schemeId);
            vote.setVoterId(voterId);
            vote.setTargetCadreId(targetCadreId);
            vote.setIndicatorId(indicator.getId());
            vote.setScore(score);
            vote.setVoteTime(now);
            votes.add(vote);
        }
        saveBatch(votes);
    }

    @Override
    public List<VoteResultItemVO> countResult(Long schemeId) {
        AssessmentScheme scheme = schemeService.getById(schemeId);
        if (scheme == null) {
            throw new BusinessException("测评方案不存在");
        }

        // 维度 -> 指标集合
        List<AssessmentDimension> dims = dimensionService.list(new LambdaQueryWrapper<AssessmentDimension>()
                .eq(AssessmentDimension::getSchemeId, schemeId)
                .orderByAsc(AssessmentDimension::getSortOrder));
        List<AssessmentIndicator> indicators = listSchemeIndicators(schemeId);
        Map<Long, List<Long>> dimIndicatorIds = new HashMap<>();
        Map<Long, Long> indicatorDim = new HashMap<>();
        for (AssessmentIndicator ind : indicators) {
            dimIndicatorIds.computeIfAbsent(ind.getDimensionId(), k -> new ArrayList<>()).add(ind.getId());
            indicatorDim.put(ind.getId(), ind.getDimensionId());
        }

        List<AssessmentVote> votes = list(new LambdaQueryWrapper<AssessmentVote>()
                .eq(AssessmentVote::getSchemeId, schemeId));
        Map<Long, List<AssessmentVote>> votesByTarget = votes.stream()
                .collect(Collectors.groupingBy(AssessmentVote::getTargetCadreId));

        List<AssessmentTarget> targets = targetService.list(new LambdaQueryWrapper<AssessmentTarget>()
                .eq(AssessmentTarget::getSchemeId, schemeId));

        List<Long> cadreIds = targets.stream().map(AssessmentTarget::getCadreId).distinct().toList();
        Map<Long, CadreInfo> cadreMap = cadreIds.isEmpty() ? Map.of()
                : cadreInfoService.listByIds(cadreIds).stream()
                        .collect(Collectors.toMap(CadreInfo::getId, Function.identity()));
        List<Long> deptIds = cadreMap.values().stream().map(CadreInfo::getDeptId)
                .filter(java.util.Objects::nonNull).distinct().toList();
        Map<Long, String> deptNameMap = deptIds.isEmpty() ? Map.of()
                : organizationService.listByIds(deptIds).stream()
                        .collect(Collectors.toMap(Organization::getId, Organization::getDeptName));

        List<VoteResultItemVO> result = new ArrayList<>();
        for (AssessmentTarget target : targets) {
            List<AssessmentVote> targetVotes = votesByTarget.getOrDefault(target.getCadreId(), List.of());
            VoteResultItemVO item = new VoteResultItemVO();
            item.setTargetCadreId(target.getCadreId());

            CadreInfo cadre = cadreMap.get(target.getCadreId());
            if (cadre != null) {
                item.setCadreName(cadre.getName());
                item.setDeptName(deptNameMap.get(cadre.getDeptId()));
            }

            Map<Long, BigDecimal> dimScores = new HashMap<>();
            BigDecimal total = BigDecimal.ZERO;
            for (AssessmentDimension dim : dims) {
                List<Long> indIds = dimIndicatorIds.getOrDefault(dim.getId(), List.of());
                List<BigDecimal> dimVoteScores = targetVotes.stream()
                        .filter(v -> indIds.contains(v.getIndicatorId()))
                        .map(AssessmentVote::getScore)
                        .filter(java.util.Objects::nonNull)
                        .toList();
                if (!dimVoteScores.isEmpty()) {
                    BigDecimal avg = dimVoteScores.stream()
                            .reduce(BigDecimal.ZERO, BigDecimal::add)
                            .divide(BigDecimal.valueOf(dimVoteScores.size()), 2, RoundingMode.HALF_UP);
                    dimScores.put(dim.getId(), avg);
                    total = total.add(avg);
                }
            }
            item.setDimensionScores(dimScores);
            item.setTotalScore(total.setScale(2, RoundingMode.HALF_UP));
            item.setVoterCount(targetVotes.stream().map(AssessmentVote::getVoterId).distinct().count());
            result.add(item);
        }
        result.sort(Comparator.comparing(VoteResultItemVO::getTotalScore).reversed());
        return result;
    }

    @Override
    public boolean hasVoted(Long schemeId, Long targetCadreId, Long voterId) {
        if (voterId == null) {
            return false;
        }
        return count(new LambdaQueryWrapper<AssessmentVote>()
                .eq(AssessmentVote::getSchemeId, schemeId)
                .eq(AssessmentVote::getTargetCadreId, targetCadreId)
                .eq(AssessmentVote::getVoterId, voterId)) > 0;
    }

    private List<AssessmentIndicator> listSchemeIndicators(Long schemeId) {
        List<AssessmentDimension> dims = dimensionService.list(new LambdaQueryWrapper<AssessmentDimension>()
                .eq(AssessmentDimension::getSchemeId, schemeId));
        if (dims.isEmpty()) {
            return List.of();
        }
        return indicatorService.list(new LambdaQueryWrapper<AssessmentIndicator>()
                .in(AssessmentIndicator::getDimensionId, dims.stream().map(AssessmentDimension::getId).toList())
                .orderByAsc(AssessmentIndicator::getSortOrder));
    }
}
