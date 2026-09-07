package com.personnel.modules.assessment.controller;

import com.personnel.common.Result;
import com.personnel.framework.security.SecurityUtils;
import com.personnel.modules.assessment.dto.BallotSubmitDTO;
import com.personnel.modules.assessment.dto.VoteSignDTO;
import com.personnel.modules.assessment.service.TabletVoteService;
import com.personnel.modules.assessment.vo.BallotResultItemVO;
import com.personnel.modules.assessment.vo.SignatureVO;
import com.personnel.modules.assessment.vo.TabletSchemeDetailVO;
import com.personnel.modules.assessment.vo.TabletSchemeListVO;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 平板评审投票控制器：进行中方案列表/详情、表决式投票、签字留证
 */
@RestController
@RequestMapping("/api/vote")
public class TabletVoteController {

    @Resource
    private TabletVoteService tabletVoteService;

    /** 平板端进行中方案列表 */
    @GetMapping("/tablet/list")
    public Result<List<TabletSchemeListVO>> tabletList() {
        return Result.success(tabletVoteService.listOngoingSchemes(SecurityUtils.getUserId()));
    }

    /** 平板端方案详情 */
    @GetMapping("/tablet/detail/{schemeId}")
    public Result<TabletSchemeDetailVO> tabletDetail(@PathVariable Long schemeId) {
        return Result.success(tabletVoteService.getSchemeDetail(schemeId, SecurityUtils.getUserId()));
    }

    /** 表决式投票（覆盖式提交） */
    @PostMapping("/ballot")
    public Result<Void> submitBallot(@RequestBody BallotSubmitDTO dto) {
        tabletVoteService.submitBallot(dto, SecurityUtils.getUserId());
        return Result.success();
    }

    /** 投票签字留证 */
    @PostMapping("/sign")
    public Result<Void> sign(@RequestBody VoteSignDTO dto, HttpServletRequest request) {
        tabletVoteService.sign(dto.getSchemeId(), SecurityUtils.getUserId(),
                dto.getSignImage(), resolveClientIp(request));
        return Result.success();
    }

    /** 方案签字留证列表 */
    @GetMapping("/tablet/signatures/{schemeId}")
    public Result<List<SignatureVO>> signatures(@PathVariable Long schemeId) {
        return Result.success(tabletVoteService.listSignatures(schemeId));
    }

    /** 表决结果计票 */
    @GetMapping("/ballot-result/{schemeId}")
    public Result<List<BallotResultItemVO>> ballotResult(@PathVariable Long schemeId) {
        return Result.success(tabletVoteService.countBallotResult(schemeId));
    }

    /** 客户端IP：优先取 X-Forwarded-For 首段，否则取远端地址 */
    private String resolveClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (StringUtils.hasText(forwarded) && !"unknown".equalsIgnoreCase(forwarded)) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
