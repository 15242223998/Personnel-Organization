# 高校干部人事组织管理系统

高校干部人事组织管理系统，涵盖干部信息管理、组织机构、选拔任免、职级晋升、调配管理、年度考核、监督管理、日常事务、统计分析等核心模块，采用政务蓝风格界面。

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 后端框架 | Spring Boot | 3.2.5 |
| 编程语言 | Java | 17 |
| ORM | MyBatis-Plus | 3.5.5 |
| 数据库 | MySQL | 8.0 |
| 缓存 | Redis | 7.0（当前代码未实际依赖，可暂不部署） |
| 认证授权 | Spring Security + JWT | jjwt 0.12.5（已实现令牌签发/校验/数据权限） |
| 工具库 | Hutool | 5.8.25 |
| Excel | EasyExcel + Apache POI | 3.3.3 / 5.2.5 |
| API文档 | Knife4j (Swagger) | 4.3.0 |
| 前端框架 | Vue 3 + Vite | 3.4 / 5.4 |
| UI组件库 | Element Plus | 2.7 |
| 图表 | ECharts | 5.5 |
| 状态管理 | Pinia | 2.1 |
| 路由 | Vue Router | 4.3 |
| 导出 | xlsx | 0.18.5 |

## 功能模块

### 干部管理
- **干部信息管理** — 干部档案的增删改查、批量导入导出、排序筛选、在职/离退休/调出/辞职分库
- **后备干部库** — 后备干部入库（仅限在职干部）、培养跟踪、出库管理

### 组织机构
- **组织机构管理** — 机构树形管理、编制数/实有人数维护
- **职务层次管理** — 职务层次的增删改查
- **职级管理** — 职级类型的统一管理

### 干部业务
- **干部任免管理** — 全流程管理（动议 → 民主推荐 → 考察 → 讨论决定 → 公示 → 任职），任职备案自动回写干部档案现任信息
- **干部调配管理** — 干部调动/转任记录管理，自动同步档案状态（在职/离退/调出）
- **职级晋升管理** — 职级晋升记录管理，自动同步干部职级

### 监督考核
- **干部考核管理** — 年度考核、考核维度、考核指标、考核方案、民主投票
- **干部监督管理** — 廉政意见、信访举报、个人事项报告、预警记录

### 日常事务
- 证照管理、出境记录、休假管理、教育培训、挂职锻炼、自助申报

### 统计分析
- 年龄/性别/学历/政治面貌/职务层次图表分析（ECharts）
- 机构干部统计表

### 系统管理
- 用户管理、角色管理、字典管理（国标）、操作日志/登录日志、数据权限

## 认证与安全（已启用）

- 登录成功签发 JWT（HS256，默认有效期 24 小时），前端 `Authorization: Bearer <token>` 携带
- Spring Security 统一鉴权：登录/注册/接口文档外，其余接口须携带有效令牌，未登录返回 401、越权返回 403（JSON）
- 角色权限：用户经 `sys_role` 映射为 `ROLE_XXX` 权限，可按需加 `@PreAuthorize` 细化接口权限
- 数据权限：干部档案分页/详情/导出按当前用户角色的 `data_scope`（1全部 / 3本级及下级 / 4本级）自动过滤，admin 角色不受限
- 干部状态、调配/任免/晋升均与干部档案联动，保证档案“现任职务/部门/职级/状态”一致

> 初始账号：`admin / 123456`（系统管理员，data_scope=1 全量数据）

## 快速开始

### 环境要求
- JDK 17+
- Maven 3.8+（若未安装，项目内置便携版于 `.tools-maven`，启动脚本会自动探测）
- Node.js 18+
- MySQL 8.0+
- Redis 7.0+（可选，当前代码未实际使用）

### 一键启动（推荐）

Windows 下直接双击项目根目录的 `启动系统.bat`：
1. 自动探测 JDK 17 与 Maven
2. 启动后端（`mvn spring-boot:run`，端口 8080）
3. 启动前端（`npm run dev`，端口 5173）
4. 自动打开浏览器 http://localhost:5173

也可以分别双击 `personnel-backend/启动后端.cmd` 或手动运行：

```bash
# 1. 初始化数据库（先按需修改 application.yml 中数据源）
#    默认：jdbc:mysql://localhost:3306/POP，root / 666666
mysql -uroot -p666666 < sql/init.sql

# 2. 后端
cd personnel-backend
mvn spring-boot:run        # http://localhost:8080，API文档 /doc.html

# 3. 前端
cd personnel-frontend
npm install
npm run dev                # http://localhost:5173（已代理 /api 到 8080）
```

### 构建部署

```bash
cd personnel-frontend
npm run build
```

构建产物在 `dist/` 目录，可直接部署到 Nginx 等 Web 服务器。

## 项目结构

```
Personnel-Organization-Project/
├── 启动系统.bat               # Windows 一键启动（后端 + 前端）
├── personnel-backend/        # Spring Boot 后端
│   └── src/main/java/com/personnel/
│       ├── common/           # 公共类（Result、PageResult、BaseEntity、CadreStatus等）
│       ├── framework/        # 框架配置
│       │   ├── config/       # Security、CORS、MyBatis-Plus 等
│       │   └── security/     # JwtUtil、JWT过滤器、LoginUser、数据权限等
│       ├── modules/          # 业务模块
│       │   ├── appointment/  # 干部任免
│       │   ├── assessment/   # 干部考核
│       │   ├── cadre/        # 干部信息
│       │   ├── daily/        # 日常事务
│       │   ├── organization/ # 组织机构
│       │   ├── statistics/   # 统计分析
│       │   ├── supervision/  # 监督管理
│       │   └── transfer/     # 调配晋升
│       └── system/           # 系统管理（用户/角色/字典/日志）
├── personnel-frontend/       # Vue 3 前端
│   └── src/
│       ├── api/              # API 接口层
│       ├── components/       # 公共组件
│       ├── layout/           # 布局组件
│       ├── router/           # 路由配置
│       ├── stores/           # Pinia 状态管理
│       ├── styles/           # 全局样式（政务蓝）
│       ├── utils/            # 工具函数
│       └── views/            # 业务页面
└── sql/
    └── init.sql              # 数据库初始化脚本（建库建表 + 种子账号/角色）
```

## 界面预览

系统采用蓝色政务风格设计，统一的顶部渐变导航栏、左侧菜单栏和标签页布局，所有业务页面保持一致的视觉风格。

## 说明与已知事项

- 部分页面目前使用前端内置演示数据（尚未对接后端接口），已接入真实接口的包括：登录认证、干部档案相关接口（后端能力已具备）、用户/角色/日志/注册审批等，其余页面可基于后端 `/api/**` 逐步接入。
- 干部档案等数据会按“数据权限”过滤；以 `admin/123456` 登录可查看全量数据。
- `.tools-maven/` 为 Maven 便携版（启动脚本依赖，正式安装 Maven 后可删除）。
