package com.personnel.common;

import cn.hutool.core.util.StrUtil;
import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.ExcelWriter;
import com.alibaba.excel.write.metadata.WriteSheet;
import com.alibaba.excel.write.style.column.LongestMatchColumnWidthStyleStrategy;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class ExcelService {

    /**
     * 导出Excel到HttpServletResponse
     * @param response HttpServletResponse
     * @param fileName 文件名(不含扩展名)
     * @param sheetName Sheet名称
     * @param head 表头Class
     * @param data 数据列表
     */
    public static <T> void export(HttpServletResponse response, String fileName, String sheetName,
                                   Class<T> head, List<T> data) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + encodedFileName + ".xlsx");

        EasyExcel.write(response.getOutputStream(), head)
                .registerWriteHandler(new LongestMatchColumnWidthStyleStrategy())
                .sheet(sheetName)
                .doWrite(data);
    }

    /**
     * 导出Excel到HttpServletResponse (多Sheet)
     */
    public static <T> void exportMultiSheet(HttpServletResponse response, String fileName,
                                             List<WriteSheet> writeSheets) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + encodedFileName + ".xlsx");

        ExcelWriter excelWriter = EasyExcel.write(response.getOutputStream()).build();
        for (WriteSheet writeSheet : writeSheets) {
            excelWriter.write(writeSheet.getData(), writeSheet);
        }
        excelWriter.finish();
    }
}
