package com.personnel.framework.ds;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 数据对齐（align）结果：在目标实例上建库并整份执行 init.sql（DROP+CREATE+种子）。
 */
@Data
public class DbAlignVO {

    /** 对齐的库名 */
    private String db;

    /** 实际执行的 CREATE TABLE 数量（基线表数） */
    private int createdTableCount;

    /** 对齐过程中执行的建表清单 */
    private List<String> createdTables = new ArrayList<>();

    /** 执行的总语句数 */
    private int executedStatementCount;
}
