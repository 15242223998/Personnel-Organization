package com.personnel.framework.ds;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 结构探测结果：
 * connected=true 说明目标 MySQL 实例与账号可用；
 * hasDb=false 或 hasProjectTables=false → 前端走"数据对齐"分支(c)；
 * hasProjectTables=true 且 missingTables 为空 → 结构完全一致(a)；
 * hasProjectTables=true 且 missingTables 非空 → 差异清单(b)。
 */
@Data
public class DbProbeVO {

    /** 目标实例连通性（含账号鉴权） */
    private boolean connected;

    /** 目标实例上是否存在该库 */
    private boolean hasDb;

    /** 该库中是否存在项目基线表（与基线任意交集） */
    private boolean hasProjectTables;

    /** 基线有但该库没有的表（差异清单） */
    private List<String> missingTables = new ArrayList<>();

    /** 基线全部表清单（数据对齐即将创建，供前端弹窗展示） */
    private List<String> createTables = new ArrayList<>();

    /** 该库当前实际表数量 */
    private int dbTableCount;
}
