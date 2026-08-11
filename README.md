# 高校干部人事组织管理系统

高校干部人事组织管理系统，涵盖干部信息管理、组织机构、选拔任免、职级晋升、调配管理、年度考核、监督管理、日常事务、统计分析等核心模块，采用政务蓝风格界面。

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 后端框架 | Spring Boot | 3.2.5 |
| 编程语言 | Java | 17 |
| ORM | MyBatis-Plus | 3.5.5 |
| 数据库 | MySQL | — |
| 缓存 | Redis | — |
| 安全框架 | Spring Security + JWT | jjwt 0.12.5 |
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
- **干部信息管理** — 干部档案的增删改查、批量导入导出、排序筛选
- **后备干部库** — 后备干部入库、培养跟踪、出库管理

### 组织机构
- **组织机构管理** — 机构树形管理、编制数/实有人数维护
- **职务层次管理** — 职务层次的增删改查
- **职级管理** — 职级类型的统一管理

### 干部业务
- **干部任免管理** — 全流程管理（动议 → 民主推荐 → 考察 → 讨论决定 → 公示 → 任职），含完整的审批台账
- **干部调配管理** — 干部调动/转任记录管理
- **职级晋升管理** — 职级晋升申报、审批、批次管理

### 监督考核
- **干部考核管理** — 年度考核、考核维度、考核指标、考核方案、民主投票
- **干部监督管理** — 廉政意见、信访举报、个人事项报告、预警记录

### 日常事务
- 证照管理、出境记录、休假管理、教育培训、挂职锻炼、自助申报

### 统计分析
- 年龄/性别/学历/政治面貌/职务层次图表分析（ECharts）
- 机构干部统计表

### 系统管理
- 用户管理、角色管理、字典管理（国标）、操作日志/登录日志

## 快速开始

### 环境要求
- JDK 17+
- Maven 3.8+
- Node.js 18+
- MySQL 8.0+
- Redis 7.0+

### 后端启动

```bash
cd personnel-backend

# 先执行 sql/init.sql 初始化数据库，然后修改 application.yml 中的数据库连接信息

mvn spring-boot:run
```

后端默认运行在 `http://localhost:8080`，Knife4j API 文档地址：`http://localhost:8080/doc.html`

### 前端启动

```bash
cd personnel-frontend

npm install
npm run dev
```

前端默认运行在 `http://localhost:5173`，已配置 `/api` 代理到后端 `8080` 端口。

### 构建部署

```bash
cd personnel-frontend
npm run build
```

构建产物在 `dist/` 目录，可直接部署到 Nginx 等 Web 服务器。

## 项目结构

```
Personnel-Organization-Project/
├── personnel-backend/          # Spring Boot 后端
│   └── src/main/java/com/personnel/
│       ├── common/             # 公共类（Result、PageResult、BaseEntity等）
│       ├── framework/          # 框架配置（Security、CORS、MyBatis-Plus等）
│       ├── modules/            # 业务模块
│       │   ├── appointment/    # 干部任免
│       │   ├── assessment/     # 干部考核
│       │   ├── cadre/          # 干部信息
│       │   ├── daily/          # 日常事务
│       │   ├── organization/   # 组织机构
│       │   ├── statistics/     # 统计分析
│       │   ├── supervision/    # 监督管理
│       │   └── transfer/       # 调配晋升
│       └── system/             # 系统管理
├── personnel-frontend/         # Vue 3 前端
│   └── src/
│       ├── api/                # API 接口层
│       ├── components/         # 公共组件
│       ├── layout/             # 布局组件
│       ├── router/             # 路由配置
│       ├── stores/             # Pinia 状态管理
│       ├── styles/             # 全局样式
│       ├── utils/              # 工具函数
│       └── views/              # 业务页面
└── sql/
    └── init.sql                # 数据库初始化脚本
```

## 界面预览

系统采用蓝色政务风格设计，统一的顶部渐变导航栏、左侧菜单栏和标签页布局，所有业务页面保持一致的视觉风格。
