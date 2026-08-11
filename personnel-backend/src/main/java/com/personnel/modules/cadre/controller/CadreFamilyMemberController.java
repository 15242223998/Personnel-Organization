package com.personnel.modules.cadre.controller;

import com.personnel.common.Result;
import com.personnel.modules.cadre.entity.CadreFamilyMember;
import com.personnel.modules.cadre.service.CadreFamilyMemberService;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/cadre/{cadreId}/family")
public class CadreFamilyMemberController {

    @Resource
    private CadreFamilyMemberService cadreFamilyMemberService;

    @GetMapping("/list")
    public Result<List<CadreFamilyMember>> list(@PathVariable Long cadreId) {
        return Result.success(cadreFamilyMemberService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<CadreFamilyMember>()
                        .eq(CadreFamilyMember::getCadreId, cadreId)));
    }

    @PostMapping
    public Result<Void> create(@PathVariable Long cadreId, @RequestBody CadreFamilyMember member) {
        member.setCadreId(cadreId);
        cadreFamilyMemberService.save(member);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@PathVariable Long cadreId, @RequestBody CadreFamilyMember member) {
        member.setCadreId(cadreId);
        cadreFamilyMemberService.updateById(member);
        return Result.success();
    }

    @DeleteMapping("/{memberId}")
    public Result<Void> delete(@PathVariable Long cadreId, @PathVariable Long memberId) {
        cadreFamilyMemberService.removeById(memberId);
        return Result.success();
    }
}
