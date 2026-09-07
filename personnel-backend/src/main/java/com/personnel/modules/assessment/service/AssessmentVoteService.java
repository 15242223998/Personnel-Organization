package com.personnel.modules.assessment.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.assessment.entity.AssessmentVote;
import com.personnel.modules.assessment.vo.VoteResultItemVO;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface AssessmentVoteService extends IService<AssessmentVote> {

    /** 提交投票：对某个被评干部按指标逐项打分 */
    void submitVote(Long schemeId, Long targetCadreId, Long voterId, Map<Long, BigDecimal> scores);

    /** 计票：各被评对象维度均分与总分排名 */
    List<VoteResultItemVO> countResult(Long schemeId);

    /** 当前投票人是否已对某对象投过票 */
    boolean hasVoted(Long schemeId, Long targetCadreId, Long voterId);
}
