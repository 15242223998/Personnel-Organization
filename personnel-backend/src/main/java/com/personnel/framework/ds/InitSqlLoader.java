package com.personnel.framework.ds;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 读取 classpath 基线脚本 resources/schema/init.sql（由仓库根 sql/init.sql 同步生成），
 * 提供：① CREATE TABLE 表名清单（结构比对/对齐预览）；② 按语句切分（对齐执行）。
 *
 * <p>切分策略：剥离 -- 行注释与 /* *​/ 块注释（字符串字面量内的内容受保护），
 * 按分号切分、忽略空串；对齐执行时会再过滤 CREATE DATABASE / USE 语句（连接已定位到目标库）。</p>
 */
@Slf4j
@Component
public class InitSqlLoader {

    private static final String RESOURCE = "schema/init.sql";

    /** 提取 CREATE TABLE [IF NOT EXISTS] `表名` */
    static final Pattern CREATE_TABLE_PATTERN = Pattern.compile(
            "(?is)CREATE\\s+TABLE\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?`?([a-zA-Z0-9_]+)`?");

    private volatile String rawSql;
    private volatile List<String> statements;
    private volatile List<String> tableNames;

    /** 基线表清单（按脚本出现顺序、去重） */
    public List<String> tableNames() {
        if (tableNames == null) {
            synchronized (this) {
                if (tableNames == null) {
                    String stripped = stripComments(raw());
                    Set<String> names = new LinkedHashSet<>();
                    Matcher m = CREATE_TABLE_PATTERN.matcher(stripped);
                    while (m.find()) {
                        names.add(m.group(1));
                    }
                    tableNames = new ArrayList<>(names);
                    log.info("解析基线脚本 schema/init.sql，共识别 CREATE TABLE {} 张", tableNames.size());
                }
            }
        }
        return tableNames;
    }

    /** 按语句切分后的全部语句（未过滤 CREATE DATABASE / USE） */
    public List<String> statements() {
        if (statements == null) {
            synchronized (this) {
                if (statements == null) {
                    statements = splitStatements(raw());
                }
            }
        }
        return statements;
    }

    public String raw() {
        if (rawSql == null) {
            synchronized (this) {
                if (rawSql == null) {
                    try (InputStream in = new ClassPathResource(RESOURCE).getInputStream()) {
                        rawSql = new String(in.readAllBytes(), StandardCharsets.UTF_8);
                    } catch (IOException e) {
                        throw new IllegalStateException("读取基线脚本 " + RESOURCE + " 失败：" + e.getMessage(), e);
                    }
                }
            }
        }
        return rawSql;
    }

    /** 剥离 SQL 注释，输出不含注释的文本（字符串字面量内不动） */
    static String stripComments(String sql) {
        StringBuilder out = new StringBuilder(sql.length());
        int i = 0, n = sql.length();
        char quote = 0;
        while (i < n) {
            char c = sql.charAt(i);
            char next = i + 1 < n ? sql.charAt(i + 1) : 0;
            if (quote != 0) {
                out.append(c);
                if (c == '\\' && i + 1 < n) {
                    out.append(next);
                    i += 2;
                    continue;
                }
                if (c == quote) {
                    if (next == quote) { // '' 转义
                        out.append(next);
                        i += 2;
                        continue;
                    }
                    quote = 0;
                }
                i++;
                continue;
            }
            if (c == '-' && next == '-') { // 行注释
                while (i < n && sql.charAt(i) != '\n') i++;
                out.append('\n');
                continue;
            }
            if (c == '/' && next == '*') { // 块注释
                i += 2;
                while (i + 1 < n && !(sql.charAt(i) == '*' && sql.charAt(i + 1) == '/')) i++;
                i = Math.min(i + 2, n);
                out.append(' ');
                continue;
            }
            if (c == '\'' || c == '"') {
                quote = c;
                out.append(c);
                i++;
                continue;
            }
            out.append(c);
            i++;
        }
        return out.toString();
    }

    /** 按分号切分（保护字符串字面量），忽略空串与纯注释段 */
    static List<String> splitStatements(String sql) {
        List<String> result = new ArrayList<>();
        StringBuilder cur = new StringBuilder();
        int i = 0, n = sql.length();
        char quote = 0;
        while (i < n) {
            char c = sql.charAt(i);
            char next = i + 1 < n ? sql.charAt(i + 1) : 0;
            if (quote != 0) {
                cur.append(c);
                if (c == '\\' && i + 1 < n) {
                    cur.append(next);
                    i += 2;
                    continue;
                }
                if (c == quote) {
                    if (next == quote) {
                        cur.append(next);
                        i += 2;
                        continue;
                    }
                    quote = 0;
                }
                i++;
                continue;
            }
            if (c == '-' && next == '-') {
                while (i < n && sql.charAt(i) != '\n') i++;
                continue;
            }
            if (c == '/' && next == '*') {
                i += 2;
                while (i + 1 < n && !(sql.charAt(i) == '*' && sql.charAt(i + 1) == '/')) i++;
                i = Math.min(i + 2, n);
                continue;
            }
            if (c == '\'' || c == '"') {
                quote = c;
                cur.append(c);
                i++;
                continue;
            }
            if (c == ';') {
                String stmt = cur.toString().trim();
                cur.setLength(0);
                if (StringUtils.hasText(stmt)) {
                    result.add(stmt);
                }
                i++;
                continue;
            }
            cur.append(c);
            i++;
        }
        String tail = cur.toString().trim();
        if (StringUtils.hasText(tail)) {
            result.add(tail);
        }
        return result;
    }
}
