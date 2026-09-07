package com.personnel.modules.assessment.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.assessment.entity.AssessmentAnnual;
import com.personnel.modules.assessment.vo.AnnualVO;

import java.util.Map;

public interface AssessmentAnnualService extends IService<AssessmentAnnual> {

    /** 新增年度考核（校验并回写干部档案） */
    void saveAnnual(AssessmentAnnual annual);

    /** 更新年度考核（校验并回写干部档案） */
    void updateAnnual(AssessmentAnnual annual);

    /** 删除年度考核并同步干部档案 */
    void deleteAnnual(Long id);

    /** 分页查询（带干部姓名/部门/职务） */
    Page<AnnualVO> pageAnnual(Page<AnnualVO> page, String year, String result, String name);

    /** 年度统计：各等次人数 */
    Map<String, Object> statsByYear(String year);

    /** 全部年度汇总 */
    java.util.List<Map<String, Object>> statsAllYears();
}
