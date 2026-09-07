package com.personnel.modules.assessment.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.assessment.dto.AssessmentSchemeDTO;
import com.personnel.modules.assessment.entity.AssessmentScheme;
import com.personnel.modules.assessment.vo.SchemeDetailVO;

import java.util.List;

public interface AssessmentSchemeService extends IService<AssessmentScheme> {

    /** 创建方案（含维度/指标模板，为空时自动套用"德能勤绩廉"默认模板） */
    Long createSchemeWithDetails(AssessmentSchemeDTO dto);

    /** 更新方案基本信息 */
    void updateScheme(AssessmentScheme scheme);

    /** 删除方案（连同维度/指标/对象/投票） */
    void deleteScheme(Long id);

    /** 方案详情（维度/指标树 + 统计） */
    SchemeDetailVO getDetail(Long id);

    /** 发布方案：校验模板与对象齐备 */
    void publish(Long id);

    /** 关闭方案 */
    void close(Long id);

    /** 生成测评对象 */
    void generateTargets(Long schemeId, List<Long> cadreIds);
}
