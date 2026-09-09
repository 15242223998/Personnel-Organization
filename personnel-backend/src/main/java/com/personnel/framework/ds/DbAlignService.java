package com.personnel.framework.ds;

import com.baomidou.dynamic.datasource.DynamicRoutingDataSource;
import com.baomidou.dynamic.datasource.creator.DataSourceProperty;
import com.baomidou.dynamic.datasource.creator.DefaultDataSourceCreator;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.personnel.common.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.Resource;
import javax.sql.DataSource;
import java.io.File;
import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 数据库结构探测 / 数据对齐 / 运行时热切换。
 *
 * <ul>
 *   <li>probe：连目标实例检查连通性、库是否存在、基线表差异；</li>
 *   <li>align：仅当库不存在（或无任何项目表）时建库并整份执行 schema/init.sql（防误清）；</li>
 *   <li>switchTo：创建 Hikari 数据源加入 DynamicRoutingDataSource 并切 primary，成功后写记忆文件；</li>
 *   <li>restoreFromFile：启动时按 run/db-conn.json 恢复上次热切换（失败仅告警）。</li>
 * </ul>
 */
@Slf4j
@Service
public class DbAlignService {

    /** 运行时热切换数据源名 */
    public static final String CONN_DATASOURCE = "user-conn";

    /** 默认主数据源名（application.yml dynamic.primary） */
    public static final String MASTER_DATASOURCE = "master";

    /** 目标 MySQL 实例 JDBC 前缀 */
    private static final String JDBC_PREFIX = "jdbc:mysql://";

    private static final Pattern URL_DB_PATTERN = Pattern.compile(
            "(?i)jdbc:mysql://[^/]+/([^?]+)");

    private static final Pattern HOST_PORT_PATTERN = Pattern.compile(
            "(?i)jdbc:mysql://([^:/]+)(?::(\\d+))?/");

    private static final Pattern DB_NAME = Pattern.compile("^[A-Za-z0-9_]+$");

    @Resource
    private DataSource dataSource;

    @Resource
    private DefaultDataSourceCreator dataSourceCreator;

    @Resource
    private InitSqlLoader initSqlLoader;

    @Resource
    private ObjectMapper objectMapper;

    @Value("${spring.datasource.dynamic.datasource.master.url:}")
    private String masterUrl;

    @Value("${spring.datasource.dynamic.datasource.master.username:root}")
    private String masterUsername;

    @Value("${spring.datasource.dynamic.datasource.master.password:666666}")
    private String masterPassword;

    /** 当前主数据源名（默认 master，切换后 user-conn） */
    private volatile String primaryName = MASTER_DATASOURCE;

    public String getPrimaryName() {
        return primaryName;
    }

    private DynamicRoutingDataSource routing() {
        return (DynamicRoutingDataSource) dataSource;
    }

    // ==================== 1. 结构探测 ====================

    public DbProbeVO probe(DbConnDTO dto) {
        DbConnDTO conn = normalize(dto);
        List<String> baseline = initSqlLoader.tableNames();

        DbProbeVO vo = new DbProbeVO();
        vo.setConnected(false);
        vo.setHasDb(false);
        vo.setHasProjectTables(false);
        vo.setCreateTables(new ArrayList<>(baseline));

        try (Connection c = DriverManager.getConnection(serverUrl(conn), conn.getUsername(), conn.getPassword())) {
            vo.setConnected(true);
            vo.setHasDb(schemaExists(c, conn.getDb()));
            Set<String> existing = new LinkedHashSet<>();
            if (vo.isHasDb()) {
                existing.addAll(listTables(c, conn.getDb()));
            }
            vo.setDbTableCount(existing.size());

            // 该库是否含项目表：与基线存在交集
            List<String> missing = new ArrayList<>();
            boolean hasProject = false;
            for (String t : baseline) {
                if (existing.contains(t.toLowerCase(Locale.ROOT)) || existing.contains(t)) {
                    hasProject = true;
                } else {
                    missing.add(t);
                }
            }
            vo.setHasProjectTables(hasProject);
            vo.setMissingTables(missing);
            log.info("probe 完成 host={} port={} db={} hasDb={} hasProjectTables={} missing={}",
                    conn.getHost(), conn.getPort(), conn.getDb(), vo.isHasDb(), hasProject, missing.size());
            return vo;
        } catch (SQLException e) {
            throw new BusinessException("数据库连接失败：" + friendlyMessage(e));
        }
    }

    // ==================== 2. 数据对齐 ====================

    public DbAlignVO align(DbConnDTO dto) {
        DbConnDTO conn = normalize(dto);
        List<String> baseline = initSqlLoader.tableNames();

        // 防误清：目标库若已存在项目表则拒绝（避免 DROP+CREATE 破坏线上数据）
        try (Connection c = DriverManager.getConnection(serverUrl(conn), conn.getUsername(), conn.getPassword())) {
            boolean exists = schemaExists(c, conn.getDb());
            if (exists) {
                Set<String> existing = new LinkedHashSet<>(listTables(c, conn.getDb()));
                boolean hasProject = baseline.stream()
                        .anyMatch(t -> existing.contains(t) || existing.contains(t.toLowerCase(Locale.ROOT)));
                if (hasProject) {
                    throw new BusinessException("数据库 " + conn.getDb() + " 已存在项目表，请先人工确认，禁止自动重建（数据对齐仅适用于全新/空库）");
                }
            }
        } catch (SQLException e) {
            throw new BusinessException("数据库连接失败：" + friendlyMessage(e));
        }

        // 建库（utf8mb4）
        String createDb = "CREATE DATABASE IF NOT EXISTS `" + conn.getDb()
                + "` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
        try (Connection admin = DriverManager.getConnection(serverUrl(conn), conn.getUsername(), conn.getPassword());
             Statement st = admin.createStatement()) {
            st.execute(createDb);
        } catch (SQLException e) {
            throw new BusinessException("创建数据库 " + conn.getDb() + " 失败：" + friendlyMessage(e));
        }

        // 连接目标库，逐条执行基线脚本（过滤 CREATE DATABASE / USE，连接已定位到该库）
        DbAlignVO vo = new DbAlignVO();
        vo.setDb(conn.getDb());
        List<String> executedTables = new ArrayList<>();
        int executed = 0;
        try (Connection target = DriverManager.getConnection(dbUrl(conn), conn.getUsername(), conn.getPassword());
             Statement st = target.createStatement()) {
            List<String> statements = initSqlLoader.statements();
            for (String stmt : statements) {
                if (isSchemaRoutingStatement(stmt)) {
                    continue;
                }
                st.execute(stmt);
                executed++;
                String table = matchCreateTable(stmt);
                if (table != null) {
                    executedTables.add(table);
                }
            }
            vo.setCreatedTableCount(executedTables.size());
            vo.setCreatedTables(executedTables);
            vo.setExecutedStatementCount(executed);
            log.info("align 完成 db={} 执行语句 {} 条，建表 {} 张", conn.getDb(), executed, executedTables.size());
            return vo;
        } catch (SQLException e) {
            throw new BusinessException("在数据库 " + conn.getDb() + " 上执行初始化脚本失败：" + friendlyMessage(e));
        }
    }

    // ==================== 3. 运行时热切换 ====================

    public DbCurrentVO switchTo(DbConnDTO dto) {
        DbConnDTO conn = normalize(dto);
        String url = dbUrl(conn);

        // 先试连：失败则保持原库不变
        try (Connection c = DriverManager.getConnection(url, conn.getUsername(), conn.getPassword())) {
            // 连通即视为可用
        } catch (SQLException e) {
            throw new BusinessException("无法连接到数据库 " + conn.getDb() + "：" + friendlyMessage(e));
        }

        DataSourceProperty property = new DataSourceProperty();
        property.setUrl(url);
        property.setUsername(conn.getUsername());
        property.setPassword(conn.getPassword());
        property.setDriverClassName("com.mysql.cj.jdbc.Driver");
        try {
            DataSource created = dataSourceCreator.createDataSource(property);
            DynamicRoutingDataSource routing = routing();
            // 同库名重复切换：先移除旧的，避免连接池泄漏。
            // 注意：dynamic-datasource 不允许直接移除"当前 primary"，故先临时切回 master 再移除。
            if (routing.getDataSource(CONN_DATASOURCE) != null) {
                routing.setPrimary(MASTER_DATASOURCE);
                primaryName = MASTER_DATASOURCE;
                routing.removeDataSource(CONN_DATASOURCE);
            }
            routing.addDataSource(CONN_DATASOURCE, created);
            routing.setPrimary(CONN_DATASOURCE);
            primaryName = CONN_DATASOURCE;
            persistConn(conn);
            log.info("数据库热切换成功：primary={} 库={} @{}:{}", CONN_DATASOURCE, conn.getDb(), conn.getHost(), conn.getPort());
            return current();
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw new BusinessException("切换数据源失败（已保持原数据库不变）：" + e.getMessage());
        }
    }

    public DbCurrentVO current() {
        DbCurrentVO vo = new DbCurrentVO();
        vo.setPrimary(primaryName);
        String db = null;
        try (Connection c = dataSource.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT DATABASE()");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                db = rs.getString(1);
            }
        } catch (SQLException e) {
            log.warn("获取当前库名失败：{}", e.getMessage());
        }
        vo.setDatabase(db);
        return vo;
    }

    // ==================== 4. 启动恢复 ====================

    /** 启动后调用：db-conn.json 非空且与 yml 默认不同则尝试恢复（失败仅告警，不阻断启动） */
    public void restoreFromFile() {
        try {
            File file = connFile();
            if (file == null || !file.exists()) {
                return;
            }
            DbConnDTO dto = objectMapper.readValue(file, DbConnDTO.class);
            if (dto == null || isBlank(dto.getHost()) || isBlank(dto.getDb()) || isBlank(dto.getUsername())) {
                log.warn("db-conn.json 内容不完整，忽略自动恢复");
                return;
            }
            if (isYmlDefault(dto)) {
                log.info("db-conn.json 与 yml 默认数据源一致（{}），无需恢复", dto.getDb());
                return;
            }
            DbCurrentVO vo = switchTo(dto);
            log.info("已按 db-conn.json 恢复数据库连接：primary={} 库={}", vo.getPrimary(), vo.getDatabase());
        } catch (BusinessException e) {
            log.warn("按 db-conn.json 恢复数据库连接失败（继续使用默认库启动）：{}", e.getMessage());
        } catch (Exception e) {
            log.warn("读取 db-conn.json 失败（继续使用默认库启动）：{}", e.getMessage());
        }
    }

    // ==================== 内部工具 ====================

    private DbConnDTO normalize(DbConnDTO dto) {
        if (dto == null) {
            throw new BusinessException("数据库连接参数不能为空");
        }
        if (isBlank(dto.getHost())) {
            throw new BusinessException("服务器地址(host)不能为空");
        }
        String host = dto.getHost().trim();
        if (host.endsWith("/")) {
            host = host.substring(0, host.length() - 1);
        }
        dto.setHost(host);
        if (dto.getPort() == null || dto.getPort() <= 0) {
            dto.setPort(3306);
        }
        if (isBlank(dto.getDb())) {
            dto.setDb("POP");
        }
        dto.setDb(dto.getDb().trim());
        if (!DB_NAME.matcher(dto.getDb()).matches()) {
            throw new BusinessException("数据库名不合法（仅允许字母/数字/下划线）：" + dto.getDb());
        }
        if (isBlank(dto.getUsername())) {
            throw new BusinessException("数据库账号不能为空");
        }
        dto.setUsername(dto.getUsername().trim());
        if (dto.getPassword() == null) {
            dto.setPassword("");
        }
        return dto;
    }

    /** 连实例（不指定库） */
    private String serverUrl(DbConnDTO dto) {
        return JDBC_PREFIX + dto.getHost() + ":" + dto.getPort() + "/" + urlParams();
    }

    /** 连指定库 */
    private String dbUrl(DbConnDTO dto) {
        return JDBC_PREFIX + dto.getHost() + ":" + dto.getPort() + "/" + dto.getDb() + urlParams();
    }

    private static String urlParams() {
        return "?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&useSSL=false"
                + "&allowPublicKeyRetrieval=true&connectTimeout=5000&socketTimeout=15000";
    }

    private boolean schemaExists(Connection c, String db) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = ?")) {
            ps.setString(1, db);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private List<String> listTables(Connection c, String db) throws SQLException {
        List<String> tables = new ArrayList<>();
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = ?")) {
            ps.setString(1, db);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tables.add(rs.getString(1));
                }
            }
        }
        return tables;
    }

    /** CREATE DATABASE / USE 语句：连接已定位到目标库，跳过 */
    private static boolean isSchemaRoutingStatement(String stmt) {
        String s = stmt.trim();
        String up = s.toUpperCase(Locale.ROOT);
        return up.startsWith("CREATE DATABASE") || up.startsWith("USE ") || up.equals("USE");
    }

    private static String matchCreateTable(String stmt) {
        Matcher m = InitSqlLoader.CREATE_TABLE_PATTERN.matcher(stmt);
        return m.find() ? m.group(1) : null;
    }

    // ==================== 记忆文件 ====================

    private void persistConn(DbConnDTO dto) {
        try {
            File dir = runDir();
            if (dir == null) {
                return;
            }
            if (!dir.exists() && !dir.mkdirs()) {
                log.warn("创建 run 目录失败：{}", dir.getAbsolutePath());
                return;
            }
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(new File(dir, "db-conn.json"), dto);
        } catch (Exception e) {
            log.warn("写入数据库连接记忆文件失败：{}", e.getMessage());
        }
    }

    private File connFile() {
        File dir = runDir();
        return dir == null ? null : new File(dir, "db-conn.json");
    }

    /** run 目录：personnel-backend/run/db-conn.json（相对 classes/jar 上溯两级，即工程根） */
    private File runDir() {
        String custom = System.getProperty("personnel.dbconn.runDir");
        if (!isBlank(custom)) {
            return new File(custom);
        }
        try {
            URI uri = DbAlignService.class.getProtectionDomain().getCodeSource().getLocation().toURI();
            File loc = new File(uri);
            File project = loc.getParentFile() == null ? null : loc.getParentFile().getParentFile();
            if (project != null) {
                return new File(project, "run");
            }
        } catch (Exception ignored) {
            // fallback
        }
        return new File(System.getProperty("user.dir"), "run");
    }

    private boolean isYmlDefault(DbConnDTO dto) {
        String defaultDb = "POP";
        String defaultHost = "localhost";
        int defaultPort = 3306;
        try {
            if (isBlank(masterUrl)) {
                return false;
            }
            Matcher dbM = URL_DB_PATTERN.matcher(masterUrl);
            if (dbM.find()) {
                defaultDb = dbM.group(1);
            }
            Matcher hostM = HOST_PORT_PATTERN.matcher(masterUrl);
            if (hostM.find()) {
                defaultHost = hostM.group(1);
                if (hostM.group(2) != null) {
                    defaultPort = Integer.parseInt(hostM.group(2));
                }
            }
        } catch (Exception e) {
            log.debug("解析 yml master url 失败，使用默认比较值：{}", e.getMessage());
        }
        boolean sameDb = dto.getDb().equalsIgnoreCase(defaultDb);
        boolean sameHost = dto.getHost().equalsIgnoreCase(defaultHost)
                || (dto.getHost().equalsIgnoreCase("127.0.0.1") && defaultHost.equalsIgnoreCase("localhost"))
                || (dto.getHost().equalsIgnoreCase("localhost") && defaultHost.equalsIgnoreCase("127.0.0.1"));
        boolean sameCred = masterUsername.equals(dto.getUsername()) && masterPassword.equals(dto.getPassword());
        boolean samePort = dto.getPort() != null && dto.getPort() == defaultPort;
        return sameDb && sameHost && samePort && sameCred;
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String friendlyMessage(SQLException e) {
        String msg = e.getMessage();
        if (msg == null || msg.isBlank()) {
            return e.getClass().getSimpleName();
        }
        // 截取第一行，避免一长串堆栈信息
        int idx = msg.indexOf('\n');
        String first = idx > 0 ? msg.substring(0, idx) : msg;
        return first.length() > 180 ? first.substring(0, 180) : first;
    }
}
