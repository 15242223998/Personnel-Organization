package com.personnel.modules.assessment.controller;

import com.personnel.common.Result;
import com.personnel.framework.security.SecurityUtils;
import com.personnel.modules.assessment.dto.VoteSubmitDTO;
import com.personnel.modules.assessment.service.AssessmentVoteService;
import com.personnel.modules.assessment.vo.VoteResultItemVO;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/vote")
public class AssessmentVoteController {

    @Resource
    private AssessmentVoteService assessmentVoteService;

    /** 提交投票（投票人为当前登录用户） */
    @PostMapping("/submit")
    public Result<Void> submitVote(@RequestBody VoteSubmitDTO dto) {
        assessmentVoteService.submitVote(dto.getSchemeId(), dto.getTargetCadreId(),
                SecurityUtils.getUserId(), dto.getScores());
        return Result.success();
    }

    /** 计票：各被评对象维度均分与总分排名 */
    @GetMapping("/result/{schemeId}")
    public Result<List<VoteResultItemVO>> voteResult(@PathVariable Long schemeId) {
        return Result.success(assessmentVoteService.countResult(schemeId));
    }

    /** 当前用户是否已对某对象投票 */
    @GetMapping("/my")
    public Result<Boolean> myVote(@RequestParam Long schemeId, @RequestParam Long targetCadreId) {
        return Result.success(assessmentVoteService.hasVoted(schemeId, targetCadreId, SecurityUtils.getUserId()));
    }
}
