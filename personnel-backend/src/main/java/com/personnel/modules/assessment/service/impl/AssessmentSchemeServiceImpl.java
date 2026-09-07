package com.personnel.modules.assessment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.personnel.common.BusinessException;
import com.personnel.modules.assessment.dto.AssessmentSchemeDTO;
import com.personnel.modules.assessment.entity.AssessmentDimension;
import com.personnel.modules.assessment.entity.AssessmentIndicator;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.entity.AssessmentTarget;
import com.personnel.modules.assessment.entity.AssessmentVote;
import com.personnel.modules.assessment.mapper.AssessmentSchemeMapper;
import com.personnel.modules.assessment.mapper.AssessmentVoteMapper;
import com.personnel.modules.assessment.service.AssessmentDimensionService;
import com.personnel.modules.assessment.service.AssessmentIndicatorService;
import com.personnel.modules.assessment.service.AssessmentSchemeService;
import com.personnel.modules.assessment.service.AssessmentTargetService;
import com.personnel.modules.assessment.vo.SchemeDetailVO;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class AssessmentSchemeServiceImpl extends ServiceImpl<AssessmentSchemeMapper, AssessmentScheme> implements AssessmentSchemeService {

    @Resource
    private AssessmentDimensionService dimensionService;

    @Resource
    private AssessmentIndicatorService indicatorService;

    @Resource
    private AssessmentTargetService targetService;

    // 直接使用 Mapper，避免与 AssessmentVoteServiceImpl 形成循环依赖
    @Resource
    private AssessmentVoteMapper voteMapper;

    @Resource
    private CadreInfoService cadreInfoService;

    private static final String STATUS_DRAFT = "草稿";
    private static final String STATUS_PUBLISHED = "进行中";
    private static final String STATUS_CLOSED = "已关闭";

    @Override
    @Transactional
    public Long createSchemeWithDetails(AssessmentSchemeDTO dto) {
        if (dto == null || dto.getScheme() == null) {
            throw new BusinessException("方案信息不能为空");
        }
        AssessmentScheme scheme = dto.getScheme();
        if (!StringUtils.hasText(scheme.getSchemeName())) {
            throw new BusinessException("方案名称不能为空");
        }
        if (!StringUtils.hasText(scheme.getSchemeYear())) {
            throw new BusinessException("测评年度不能为空");
        }
        scheme.setId(null);
        if (!StringUtils.hasText(scheme.getStatus())) {
            scheme.setStatus(STATUS_DRAFT);
        }
        save(scheme);

        List<AssessmentSchemeDTO.DimensionDTO> dimensions = dto.getDimensions();
        if (dimensions == null || dimensions.isEmpty()) {
            // 表决式(BALLOT)方案不做指标打分，允许不配置维度/指标；评分式沿用默认模板
            dimensions = "BALLOT".equals(scheme.getVoteMode()) ? List.of() : defaultTemplate();
        }
        saveDimensions(scheme.getId(), dimensions);
        return scheme.getId();
    }

    @Override
    @Transactional
    public void updateScheme(AssessmentScheme scheme) {
        AssessmentScheme db = getById(scheme.getId());
        if (db == null) {
            throw new BusinessException("方案不存在");
        }
        if (!STATUS_DRAFT.equals(db.getStatus())) {
            throw new BusinessException("仅草稿状态可编辑方案");
        }
        updateById(scheme);
    }

    @Override
    @Transactional
    public void deleteScheme(Long id) {
        if (getById(id) == null) {
            throw new BusinessException("方案不存在");
        }
        removeById(id);
        // 维度与指标（逻辑删除）
        List<AssessmentDimension> dims = dimensionService.list(new LambdaQueryWrapper<AssessmentDimension>()
                .eq(AssessmentDimension::getSchemeId, id));
        for (AssessmentDimension dim : dims) {
            List<AssessmentIndicator> inds = indicatorService.list(new LambdaQueryWrapper<AssessmentIndicator>()
                    .eq(AssessmentIndicator::getDimensionId, dim.getId()));
            for (AssessmentIndicator ind : inds) {
                indicatorService.removeById(ind.getId());
            }
            dimensionService.removeById(dim.getId());
        }
        // 对象与投票（物理清理投票，逻辑删对象）
        voteMapper.delete(new LambdaQueryWrapper<AssessmentVote>().eq(AssessmentVote::getSchemeId, id));
        targetService.remove(new LambdaQueryWrapper<AssessmentTarget>().eq(AssessmentTarget::getSchemeId, id));
    }

    @Override
    public SchemeDetailVO getDetail(Long id) {
        AssessmentScheme scheme = getById(id);
        if (scheme == null) {
            throw new BusinessException("方案不存在");
        }
        SchemeDetailVO vo = new SchemeDetailVO();
        vo.setScheme(scheme);

        List<SchemeDetailVO.DimensionNode> nodes = new ArrayList<>();
        List<AssessmentDimension> dims = dimensionService.list(new LambdaQueryWrapper<AssessmentDimension>()
                .eq(AssessmentDimension::getSchemeId, id)
                .orderByAsc(AssessmentDimension::getSortOrder));
        for (AssessmentDimension dim : dims) {
            SchemeDetailVO.DimensionNode node = new SchemeDetailVO.DimensionNode();
            node.setDimension(dim);
            node.setIndicators(indicatorService.list(new LambdaQueryWrapper<AssessmentIndicator>()
                    .eq(AssessmentIndicator::getDimensionId, dim.getId())
                    .orderByAsc(AssessmentIndicator::getSortOrder)));
            nodes.add(node);
        }
        vo.setDimensions(nodes);

        List<AssessmentTarget> targets = targetService.list(new LambdaQueryWrapper<AssessmentTarget>()
                .eq(AssessmentTarget::getSchemeId, id));
        vo.setTargetCount((long) targets.size());
        List<AssessmentVote> votes = voteMapper.selectList(new LambdaQueryWrapper<AssessmentVote>()
                .eq(AssessmentVote::getSchemeId, id));
        vo.setVoteCount((long) votes.size());
        vo.setVoterCount(votes.stream().map(AssessmentVote::getVoterId).distinct().count());
        return vo;
    }

    @Override
    @Transactional
    public void publish(Long id) {
        AssessmentScheme scheme = getById(id);
        if (scheme == null) {
            throw new BusinessException("方案不存在");
        }
        if (!STATUS_DRAFT.equals(scheme.getStatus())) {
            throw new BusinessException("仅草稿状态可发布");
        }
        // 表决式(BALLOT)方案不要求维度/指标；评分式(SCORE)仍要求维度/指标齐备
        if (!"BALLOT".equals(scheme.getVoteMode())) {
            long dimCount = dimensionService.count(new LambdaQueryWrapper<AssessmentDimension>()
                    .eq(AssessmentDimension::getSchemeId, id));
            if (dimCount == 0) {
                throw new BusinessException("请先配置维度/指标模板");
            }
        }
        long targetCount = targetService.count(new LambdaQueryWrapper<AssessmentTarget>()
                .eq(AssessmentTarget::getSchemeId, id));
        if (targetCount == 0) {
            throw new BusinessException("请先生成测评对象");
        }
        if (scheme.getVoteStartTime() == null || scheme.getVoteEndTime() == null) {
            throw new BusinessException("请先设置投票起止时间");
        }
        scheme.setStatus(STATUS_PUBLISHED);
        updateById(scheme);
    }

    @Override
    @Transactional
    public void close(Long id) {
        AssessmentScheme scheme = getById(id);
        if (scheme == null) {
            throw new BusinessException("方案不存在");
        }
        if (!STATUS_PUBLISHED.equals(scheme.getStatus())) {
            throw new BusinessException("仅进行中的方案可关闭");
        }
        scheme.setStatus(STATUS_CLOSED);
        updateById(scheme);
    }

    @Override
    @Transactional
    public void generateTargets(Long schemeId, List<Long> cadreIds) {
        AssessmentScheme scheme = getById(schemeId);
        if (scheme == null) {
            throw new BusinessException("方案不存在");
        }
        if (!STATUS_DRAFT.equals(scheme.getStatus())) {
            throw new BusinessException("仅草稿状态可生成测评对象");
        }
        if (cadreIds == null || cadreIds.isEmpty()) {
            throw new BusinessException("请选择测评对象干部");
        }
        // 去重
        List<Long> distinct = cadreIds.stream().distinct().toList();
        // 校验干部存在
        List<CadreInfo> cadres = cadreInfoService.listByIds(distinct);
        if (cadres.size() != distinct.size()) {
            throw new BusinessException("存在无效的干部，请重新选择");
        }
        // 覆盖式重建
        targetService.remove(new LambdaQueryWrapper<AssessmentTarget>().eq(AssessmentTarget::getSchemeId, schemeId));
        for (Long cadreId : distinct) {
            AssessmentTarget target = new AssessmentTarget();
            target.setSchemeId(schemeId);
            target.setCadreId(cadreId);
            targetService.save(target);
        }
    }

    /** 默认"德能勤绩廉"模板，总分100 */
    private List<AssessmentSchemeDTO.DimensionDTO> defaultTemplate() {
        List<AssessmentSchemeDTO.DimensionDTO> list = new ArrayList<>();
        list.add(buildDimension("德", new BigDecimal("25"), 1,
                new String[]{"政治品质", "职业道德"}, new String[]{"12.5", "12.5"}));
        list.add(buildDimension("能", new BigDecimal("25"), 2,
                new String[]{"业务能力", "组织协调能力"}, new String[]{"12.5", "12.5"}));
        list.add(buildDimension("勤", new BigDecimal("20"), 3,
                new String[]{"工作态度", "敬业精神"}, new String[]{"10", "10"}));
        list.add(buildDimension("绩", new BigDecimal("20"), 4,
                new String[]{"工作实绩", "工作效能"}, new String[]{"10", "10"}));
        list.add(buildDimension("廉", new BigDecimal("10"), 5,
                new String[]{"廉洁自律"}, new String[]{"10"}));
        return list;
    }

    private AssessmentSchemeDTO.DimensionDTO buildDimension(String name, BigDecimal weight, int order,
                                                            String[] indicatorNames, String[] maxScores) {
        AssessmentSchemeDTO.DimensionDTO dto = new AssessmentSchemeDTO.DimensionDTO();
        dto.setDimensionName(name);
        dto.setDimensionWeight(weight);
        dto.setSortOrder(order);
        List<AssessmentSchemeDTO.IndicatorDTO> indicators = new ArrayList<>();
        for (int i = 0; i < indicatorNames.length; i++) {
            AssessmentSchemeDTO.IndicatorDTO ind = new AssessmentSchemeDTO.IndicatorDTO();
            ind.setIndicatorName(indicatorNames[i]);
            ind.setMaxScore(new BigDecimal(maxScores[i]));
            ind.setSortOrder(i + 1);
            indicators.add(ind);
        }
        dto.setIndicators(indicators);
        return dto;
    }

    private void saveDimensions(Long schemeId, List<AssessmentSchemeDTO.DimensionDTO> dimensions) {
        int dimOrder = 1;
        for (AssessmentSchemeDTO.DimensionDTO dimDto : dimensions) {
            if (!StringUtils.hasText(dimDto.getDimensionName())) {
                throw new BusinessException("维度名称不能为空");
            }
            AssessmentDimension dim = new AssessmentDimension();
            dim.setSchemeId(schemeId);
            dim.setDimensionName(dimDto.getDimensionName());
            dim.setDimensionWeight(dimDto.getDimensionWeight());
            dim.setSortOrder(dimDto.getSortOrder() != null ? dimDto.getSortOrder() : dimOrder);
            dimensionService.save(dim);
            dimOrder++;

            if (dimDto.getIndicators() != null) {
                int indOrder = 1;
                for (AssessmentSchemeDTO.IndicatorDTO indDto : dimDto.getIndicators()) {
                    if (!StringUtils.hasText(indDto.getIndicatorName())) {
                        throw new BusinessException("指标名称不能为空");
                    }
                    AssessmentIndicator ind = new AssessmentIndicator();
                    ind.setDimensionId(dim.getId());
                    ind.setIndicatorName(indDto.getIndicatorName());
                    ind.setMaxScore(indDto.getMaxScore());
                    ind.setSortOrder(indDto.getSortOrder() != null ? indDto.getSortOrder() : indOrder);
                    indicatorService.save(ind);
                    indOrder++;
                }
            }
        }
    }
}
