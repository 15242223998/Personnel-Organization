package com.personnel.modules.organization.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.organization.entity.OrgTeamMember;
import com.personnel.modules.organization.service.OrgTeamMemberService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

/**
 * 班子成员登记：以真实组织树/机构为维度维护班子（org_team_member）
 */
@RestController
@RequestMapping("/api/org-team")
public class OrgTeamMemberController {

    @Resource
    private OrgTeamMemberService orgTeamMemberService;

    /**
     * 机构成员列表（deptId 可空，空则返回全部，便于按机构聚合展示）
     */
    @GetMapping("/list")
    public Result<List<OrgTeamMember>> list(@RequestParam(required = false) Long deptId) {
        return Result.success(orgTeamMemberService.listTeam(deptId));
    }

    /**
     * 分页（可按机构 deptId、班子职务 leaderPost 筛选）
     */
    @GetMapping("/page")
    public Result<PageResult<OrgTeamMember>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) Long deptId,
            @RequestParam(required = false) String leaderPost) {
        Page<OrgTeamMember> page = new Page<>(current, size);
        return Result.success(PageResult.of(orgTeamMemberService.pageTeam(page, deptId, leaderPost)));
    }

    @PostMapping
    public Result<OrgTeamMember> create(@RequestBody OrgTeamMember member) {
        return Result.success(orgTeamMemberService.createTeam(member));
    }

    @PutMapping
    public Result<OrgTeamMember> update(@RequestBody OrgTeamMember member) {
        return Result.success(orgTeamMemberService.updateTeam(member));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        orgTeamMemberService.removeById(id);
        return Result.success();
    }
}
