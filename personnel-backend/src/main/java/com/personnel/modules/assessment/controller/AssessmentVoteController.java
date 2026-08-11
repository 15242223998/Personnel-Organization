package com.personnel.modules.assessment.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.assessment.entity.AssessmentVote;
import com.personnel.modules.assessment.service.AssessmentVoteService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/api/vote")
public class AssessmentVoteController {

    @Resource
    private AssessmentVoteService assessmentVoteService;

    @PostMapping("/submit")
    public Result<Void> submitVote(@RequestBody AssessmentVote vote) {
        vote.setVoterId(null);
        assessmentVoteService.save(vote);
        return Result.success();
    }

    @GetMapping("/page")
    public Result<PageResult<AssessmentVote>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size) {
        Page<AssessmentVote> page = new Page<>(current, size);
        return Result.success(PageResult.of(assessmentVoteService.page(page)));
    }

    @GetMapping("/result/{schemeId}")
    public Result<?> voteResult(@PathVariable Long schemeId) {
        return Result.success(assessmentVoteService.list(
                new LambdaQueryWrapper<AssessmentVote>().eq(AssessmentVote::getSchemeId, schemeId)));
    }
}
