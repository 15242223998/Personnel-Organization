package com.personnel.modules.cadre.controller;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.read.listener.ReadListener;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.personnel.common.ExcelService;
import com.personnel.common.PageResult;
import com.personnel.common.Result;
import com.personnel.modules.cadre.entity.CadreInfo;
import com.personnel.modules.cadre.service.CadreInfoService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/cadre")
public class CadreInfoController {

    @Resource
    private CadreInfoService cadreInfoService;

    @PostMapping("/page")
    public Result<PageResult<CadreInfo>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestBody(required = false) CadreInfo query) {
        Page<CadreInfo> page = new Page<>(current, size);
        return Result.success(PageResult.of(cadreInfoService.pageQuery(page, query)));
    }

    @PostMapping
    public Result<Void> create(@RequestBody CadreInfo cadreInfo) {
        cadreInfoService.save(cadreInfo);
        return Result.success();
    }

    @PutMapping
    public Result<Void> update(@RequestBody CadreInfo cadreInfo) {
        cadreInfoService.updateById(cadreInfo);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        cadreInfoService.removeById(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<CadreInfo> getById(@PathVariable Long id) {
        return Result.success(cadreInfoService.getDetailById(id));
    }

    @PostMapping("/import")
    public Result<Integer> importData(@RequestParam("file") MultipartFile file) throws IOException {
        List<CadreInfo> list = new ArrayList<>();
        EasyExcel.read(file.getInputStream(), CadreInfo.class, new ReadListener<CadreInfo>() {
            @Override
            public void invoke(CadreInfo data, AnalysisContext context) {
                list.add(data);
            }
            @Override
            public void doAfterAllAnalysed(AnalysisContext context) {}
        }).sheet().doRead();
        if (!list.isEmpty()) {
            cadreInfoService.saveBatch(list);
        }
        return Result.success("导入成功", list.size());
    }

    @PostMapping("/export")
    public void exportData(@RequestBody(required = false) CadreInfo query, HttpServletResponse response) throws IOException {
        List<CadreInfo> list = cadreInfoService.exportList(query);
        ExcelService.export(response, "干部信息", "干部信息", CadreInfo.class, list);
    }
}
