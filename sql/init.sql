-- ====================================================
-- 组织人事档案系统 - 数据库初始化脚本
-- ====================================================

CREATE DATABASE IF NOT EXISTS personnel_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE personnel_db;

-- =================== 系统管理 ====================

-- 用户表
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(64) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(128) NOT NULL COMMENT '密码',
    real_name VARCHAR(64) NOT NULL COMMENT '真实姓名',
    avatar VARCHAR(255) COMMENT '头像',
    email VARCHAR(128) COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    gender TINYINT DEFAULT 0 COMMENT '性别 0未知 1男 2女',
    user_type TINYINT NOT NULL COMMENT '用户类型 1系统管理员 2校级领导 3组织部部长 4组织员 5二级学院领导 6普通干部',
    status TINYINT DEFAULT 1 COMMENT '状态 0停用 1启用',
    dept_id BIGINT COMMENT '所属部门/学院ID',
    ip_bound VARCHAR(128) COMMENT 'IP绑定',
    login_fail_count INT DEFAULT 0 COMMENT '登录失败次数',
    lock_until DATETIME COMMENT '锁定截止时间',
    last_login_time DATETIME COMMENT '最后登录时间',
    last_login_ip VARCHAR(64) COMMENT '最后登录IP',
    create_by BIGINT COMMENT '创建人',
    update_by BIGINT COMMENT '更新人',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除 0未删 1已删',
    INDEX idx_status (status),
    INDEX idx_dept (dept_id)
) ENGINE=InnoDB COMMENT='系统用户表';

-- 角色表
DROP TABLE IF EXISTS sys_role;
CREATE TABLE sys_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(64) NOT NULL COMMENT '角色名称',
    role_code VARCHAR(64) NOT NULL UNIQUE COMMENT '角色编码',
    data_scope TINYINT DEFAULT 4 COMMENT '数据范围 1全部 2自定义 3本级及下级 4本级',
    status TINYINT DEFAULT 1 COMMENT '状态',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='角色表';

-- 用户角色关联
DROP TABLE IF EXISTS sys_user_role;
CREATE TABLE sys_user_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB COMMENT='用户角色关联表';

-- 字典类型
DROP TABLE IF EXISTS sys_dict_type;
CREATE TABLE sys_dict_type (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(64) NOT NULL COMMENT '字典名称',
    type_code VARCHAR(64) NOT NULL UNIQUE COMMENT '字典编码',
    status TINYINT DEFAULT 1,
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='字典类型表';

-- 字典数据
DROP TABLE IF EXISTS sys_dict_data;
CREATE TABLE sys_dict_data (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    type_code VARCHAR(64) NOT NULL COMMENT '字典编码',
    dict_label VARCHAR(128) NOT NULL COMMENT '字典标签',
    dict_value VARCHAR(128) NOT NULL COMMENT '字典值',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1,
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_type (type_code)
) ENGINE=InnoDB COMMENT='字典数据表';

-- 操作日志
DROP TABLE IF EXISTS sys_oper_log;
CREATE TABLE sys_oper_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT COMMENT '操作用户ID',
    username VARCHAR(64) COMMENT '操作用户名',
    oper_type VARCHAR(32) COMMENT '操作类型 INSERT/UPDATE/DELETE/QUERY/APPROVE',
    oper_module VARCHAR(64) COMMENT '操作模块',
    oper_desc VARCHAR(512) COMMENT '操作描述',
    oper_ip VARCHAR(64) COMMENT '操作IP',
    oper_time DATETIME COMMENT '操作时间',
    oper_params TEXT COMMENT '操作参数',
    oper_result VARCHAR(32) COMMENT '操作结果 SUCCESS/FAIL',
    index idx_user (user_id),
    index idx_time (oper_time),
    index idx_module (oper_module)
) ENGINE=InnoDB COMMENT='操作日志表';

-- 登录日志
DROP TABLE IF EXISTS sys_login_log;
CREATE TABLE sys_login_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    login_ip VARCHAR(64) COMMENT '登录IP',
    device_type VARCHAR(32) COMMENT '设备类型 PC/PHONE/PAD',
    browser VARCHAR(64) COMMENT '浏览器',
    os VARCHAR(64) COMMENT '操作系统',
    login_time DATETIME COMMENT '登录时间',
    login_result VARCHAR(32) COMMENT '登录结果 SUCCESS/FAIL',
    fail_reason VARCHAR(256) COMMENT '失败原因',
    index idx_user (user_id),
    index idx_time (login_time)
) ENGINE=InnoDB COMMENT='登录日志表';


-- =================== 组织机构管理 ====================

-- 组织机构表
DROP TABLE IF EXISTS org_department;
CREATE TABLE org_department (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    parent_id BIGINT DEFAULT 0 COMMENT '上级机构ID',
    dept_name VARCHAR(128) NOT NULL COMMENT '机构全称',
    short_name VARCHAR(64) COMMENT '机构简称',
    dept_level VARCHAR(32) COMMENT '机构级别 校级/处级/科级',
    leader_quota INT DEFAULT 0 COMMENT '班子职数',
    established_date DATE COMMENT '成立时间',
    dept_sort INT DEFAULT 0 COMMENT '显示排序',
    status TINYINT DEFAULT 1 COMMENT '状态 0撤销 1正常',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_parent (parent_id)
) ENGINE=InnoDB COMMENT='组织机构表';

-- 职务层次表
DROP TABLE IF EXISTS org_position_level;
CREATE TABLE org_position_level (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    level_name VARCHAR(64) NOT NULL COMMENT '职务层次名称 校级/处级/科级',
    min_lower_years INT COMMENT '任低一级职务最低年限',
    max_age INT COMMENT '年龄上限',
    min_education VARCHAR(32) COMMENT '最低学历要求',
    assessment_required VARCHAR(64) COMMENT '年度考核要求',
    penalty_period_restrict INT COMMENT '处分影响期(月)内不得提拔',
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='职务层次表';

-- 职级管理表
DROP TABLE IF EXISTS org_rank;
CREATE TABLE org_rank (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    rank_name VARCHAR(64) NOT NULL COMMENT '职级名称',
    rank_type VARCHAR(32) COMMENT '职级类型 管理岗/专业技术岗',
    promotion_years INT COMMENT '晋升所需任满年限',
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='职级管理表';

-- 编制管理表
DROP TABLE IF EXISTS org_staffing_quota;
CREATE TABLE org_staffing_quota (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    dept_id BIGINT NOT NULL UNIQUE COMMENT '机构ID',
    approved_quota INT DEFAULT 0 COMMENT '核定编制数',
    leader_quota INT DEFAULT 0 COMMENT '核定领导职数',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='编制管理表';


-- =================== 干部信息管理（核心） ====================

-- 干部基本信息表
DROP TABLE IF EXISTS cadre_info;
CREATE TABLE cadre_info (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    -- 基础信息
    name VARCHAR(64) NOT NULL COMMENT '姓名',
    gender TINYINT COMMENT '性别 1男 2女',
    birth_date DATE COMMENT '出生年月',
    nation VARCHAR(32) COMMENT '民族',
    native_place VARCHAR(128) COMMENT '籍贯',
    political_status VARCHAR(32) COMMENT '政治面貌',
    party_join_date DATE COMMENT '入党时间',
    work_start_date DATE COMMENT '参加工作时间',
    id_card VARCHAR(18) COMMENT '身份证号',
    phone VARCHAR(20) COMMENT '联系电话',
    email VARCHAR(128) COMMENT '邮箱',
    photo_url VARCHAR(255) COMMENT '照片地址',
    -- 学历学位
    full_time_education VARCHAR(64) COMMENT '全日制教育学历',
    full_time_degree VARCHAR(64) COMMENT '全日制教育学位',
    full_time_school VARCHAR(128) COMMENT '全日制毕业院校及专业',
    part_time_education VARCHAR(64) COMMENT '在职教育学历',
    part_time_degree VARCHAR(64) COMMENT '在职教育学位',
    part_time_school VARCHAR(128) COMMENT '在职毕业院校及专业',
    -- 任职信息
    dept_id BIGINT COMMENT '所属机构ID',
    position VARCHAR(128) COMMENT '现任职务',
    position_level VARCHAR(32) COMMENT '现职务层次 校级/处级/科级',
    rank_id BIGINT COMMENT '职级ID',
    position_start_date DATE COMMENT '任现职时间',
    position_doc_no VARCHAR(64) COMMENT '任职文号',
    -- 扩展信息
    resume_text TEXT COMMENT '简历',
    reward_punishment TEXT COMMENT '奖惩情况',
    annual_assessment TEXT COMMENT '年度考核历史',
    -- 状态
    cadre_status VARCHAR(32) DEFAULT 'ON_JOB' COMMENT '干部状态 ON_JOB在职 RETIRED离退休 TRANSFERRED调出 RESIGNED辞职',
    retirement_date DATE COMMENT '退休日期',
    leave_date DATE COMMENT '减员日期',
    leave_reason VARCHAR(64) COMMENT '减员原因',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_name (name),
    INDEX idx_dept (dept_id),
    INDEX idx_status (cadre_status),
    INDEX idx_birth (birth_date),
    INDEX idx_retirement (retirement_date)
) ENGINE=InnoDB COMMENT='干部基本信息表';

-- 家庭成员及社会关系
DROP TABLE IF EXISTS cadre_family_member;
CREATE TABLE cadre_family_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    member_name VARCHAR(64) NOT NULL COMMENT '姓名',
    relation VARCHAR(32) COMMENT '关系',
    workplace VARCHAR(128) COMMENT '工作单位及职务',
    phone VARCHAR(20) COMMENT '联系电话',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='干部家庭成员表';

-- 佐证材料表
DROP TABLE IF EXISTS cadre_attachment;
CREATE TABLE cadre_attachment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    file_name VARCHAR(255) NOT NULL COMMENT '文件名',
    file_path VARCHAR(512) NOT NULL COMMENT '文件路径',
    file_type VARCHAR(64) COMMENT '文件类型',
    file_size BIGINT COMMENT '文件大小',
    attach_category VARCHAR(64) COMMENT '材料类别 出生年月/学历学位/其他',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='佐证材料表';

-- 后备干部库
DROP TABLE IF EXISTS cadre_reserve;
CREATE TABLE cadre_reserve (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL UNIQUE COMMENT '干部ID',
    reserve_type VARCHAR(64) COMMENT '后备类型 后备干部/优秀年轻干部',
    reserve_level VARCHAR(32) COMMENT '后备级别',
    enter_date DATE COMMENT '入库日期',
    status TINYINT DEFAULT 1 COMMENT '状态 1在库 0出库',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='后备干部库';


-- =================== 干部调配管理 ====================

-- 调配记录表
DROP TABLE IF EXISTS transfer_record;
CREATE TABLE transfer_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    transfer_type VARCHAR(32) NOT NULL COMMENT '调配类型 ADD增员 REDUCE减员 RETIRE退休 ROTATE轮岗',
    transfer_date DATE NOT NULL COMMENT '调配日期',
    transfer_reason VARCHAR(256) COMMENT '调配原因',
    from_dept_id BIGINT COMMENT '原机构ID',
    to_dept_id BIGINT COMMENT '目标机构ID',
    from_position VARCHAR(128) COMMENT '原职务',
    to_position VARCHAR(128) COMMENT '目标职务',
    doc_no VARCHAR(64) COMMENT '相关文号',
    remark VARCHAR(512) COMMENT '备注',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id),
    INDEX idx_type (transfer_type),
    INDEX idx_date (transfer_date)
) ENGINE=InnoDB COMMENT='干部调配记录表';

-- 职级晋升记录表
DROP TABLE IF EXISTS rank_promotion_record;
CREATE TABLE rank_promotion_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    from_rank_id BIGINT COMMENT '原职级ID',
    to_rank_id BIGINT NOT NULL COMMENT '晋升后职级ID',
    promotion_date DATE NOT NULL COMMENT '晋升日期',
    doc_no VARCHAR(64) COMMENT '晋升文号',
    remark VARCHAR(512) COMMENT '备注',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id),
    INDEX idx_date (promotion_date)
) ENGINE=InnoDB COMMENT='职级晋升记录表';


-- =================== 干部任免管理 ====================

-- 任免流程主表
DROP TABLE IF EXISTS appoint_process;
CREATE TABLE appoint_process (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    position_info VARCHAR(256) NOT NULL COMMENT '选拔任用职位信息',
    current_step VARCHAR(32) NOT NULL COMMENT '当前环节 MOTION动议 RECOMMEND推荐 INVESTIGATE考察 DECIDE讨论决定 PUBLICITY公示 APPOINT任职 CANCELLED终止',
    process_status VARCHAR(32) NOT NULL COMMENT '流程状态 IN_PROGRESS进行中 PASSED通过 CANCELLED终止 COMPLETED完成',
    cadre_id BIGINT COMMENT '最终确定人选ID',
    start_time DATETIME COMMENT '启动时间',
    end_time DATETIME COMMENT '结束时间',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_status (process_status),
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='任免流程主表';

-- 任免动议记录
DROP TABLE IF EXISTS appoint_motion;
CREATE TABLE appoint_motion (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    process_id BIGINT NOT NULL COMMENT '流程ID',
    position_condition TEXT COMMENT '职位条件/范围/方式/程序/人选意向',
    candidate_ids VARCHAR(1024) COMMENT '候选干部ID列表',
    selected_cadre_id BIGINT COMMENT '动议确定人选ID',
    motion_status VARCHAR(32) COMMENT '动议状态 DRAFT草稿 ACTIVE进行中 CANCELLED终止 COMPLETED完成',
    meeting_file_url VARCHAR(255) COMMENT '会议文件扫描件',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    UNIQUE INDEX idx_process (process_id)
) ENGINE=InnoDB COMMENT='任免动议记录表';

-- 民主推荐记录
DROP TABLE IF EXISTS appoint_recommend;
CREATE TABLE appoint_recommend (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    process_id BIGINT NOT NULL COMMENT '流程ID',
    recommend_type VARCHAR(32) COMMENT '推荐方式 谈话调研/会议推荐',
    recommend_date DATE COMMENT '推荐日期',
    recommend_location VARCHAR(128) COMMENT '推荐地点',
    expected_count INT COMMENT '应到人数',
    actual_count INT COMMENT '实到人数',
    vote_count INT COMMENT '得票数',
    is_passed TINYINT COMMENT '是否通过 0未通过 1通过',
    meeting_file_url VARCHAR(255) COMMENT '推荐会议文件扫描件',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    UNIQUE INDEX idx_process (process_id)
) ENGINE=InnoDB COMMENT='民主推荐记录表';

-- 组织考察记录
DROP TABLE IF EXISTS appoint_investigation;
CREATE TABLE appoint_investigation (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    process_id BIGINT NOT NULL COMMENT '流程ID',
    archive_check TINYINT COMMENT '档案审核 0未通过 1通过 -- 三龄两历一身份',
    archive_issue VARCHAR(512) COMMENT '档案审核问题描述',
    personal_report_check TINYINT COMMENT '个人事项核查 0未通过 1通过',
    personal_report_issue VARCHAR(512) COMMENT '个人事项核查问题',
    discipline_check TINYINT COMMENT '纪检意见 0未通过 1通过',
    discipline_issue VARCHAR(512) COMMENT '纪检问题描述',
    complaint_check TINYINT COMMENT '信访核查 0未通过 1通过',
    complaint_issue VARCHAR(512) COMMENT '信访问题描述',
    is_passed TINYINT COMMENT '考察是否通过 0未通过 1通过',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    UNIQUE INDEX idx_process (process_id)
) ENGINE=InnoDB COMMENT='组织考察记录表';

-- 讨论决定记录
DROP TABLE IF EXISTS appoint_decision;
CREATE TABLE appoint_decision (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    process_id BIGINT NOT NULL COMMENT '流程ID',
    meeting_date DATE COMMENT '上会日期',
    approve_count INT COMMENT '赞成票',
    oppose_count INT COMMENT '反对票',
    abstain_count INT COMMENT '弃权票',
    is_passed TINYINT COMMENT '是否通过 0未通过 1通过',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    UNIQUE INDEX idx_process (process_id)
) ENGINE=InnoDB COMMENT='讨论决定记录表';

-- 任前公示记录
DROP TABLE IF EXISTS appoint_publicity;
CREATE TABLE appoint_publicity (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    process_id BIGINT NOT NULL COMMENT '流程ID',
    publicity_start DATE COMMENT '公示开始日期',
    publicity_end DATE COMMENT '公示结束日期',
    publicity_content TEXT COMMENT '公示信息',
    report_info TEXT COMMENT '反映信息',
    publicity_result VARCHAR(32) COMMENT '公示结果 PASSED通过 FAILED未通过',
    remark VARCHAR(512) COMMENT '备注',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    UNIQUE INDEX idx_process (process_id)
) ENGINE=InnoDB COMMENT='任前公示记录表';

-- 任职记录表
DROP TABLE IF EXISTS appoint_record;
CREATE TABLE appoint_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    process_id BIGINT COMMENT '关联任免流程ID',
    position VARCHAR(128) NOT NULL COMMENT '职务',
    dept_id BIGINT COMMENT '所属机构ID',
    position_level VARCHAR(32) COMMENT '职务层次',
    appoint_date DATE NOT NULL COMMENT '任职日期',
    appoint_doc_no VARCHAR(64) COMMENT '任命文号',
    is_current TINYINT DEFAULT 0 COMMENT '是否现任 0否 1是',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id),
    INDEX idx_process (process_id),
    INDEX idx_date (appoint_date)
) ENGINE=InnoDB COMMENT='干部任职记录表';


-- =================== 干部监督管理 ====================

-- 廉政意见表
DROP TABLE IF EXISTS supervise_integrity;
CREATE TABLE supervise_integrity (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    opinion_type VARCHAR(64) COMMENT '意见类型 选拔任用/职级晋升/其他',
    opinion_content TEXT COMMENT '廉政意见内容',
    opinion_source VARCHAR(64) COMMENT '意见来源单位',
    opinion_date DATE COMMENT '出具日期',
    opinion_result VARCHAR(32) COMMENT '意见结果',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='廉政意见表';

-- 信访举报表
DROP TABLE IF EXISTS supervise_complaint;
CREATE TABLE supervise_complaint (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '被举报干部ID',
    complaint_source VARCHAR(64) COMMENT '举报来源',
    complaint_type VARCHAR(64) COMMENT '举报类型',
    complaint_content TEXT COMMENT '举报内容',
    complaint_date DATE COMMENT '举报日期',
    handle_status VARCHAR(32) COMMENT '处理状态 PENDING待处理 INVESTIGATING查核中 CLOSED已办结',
    handle_result TEXT COMMENT '处理结果',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id),
    INDEX idx_status (handle_status)
) ENGINE=InnoDB COMMENT='信访举报表';

-- 个人事项报告表
DROP TABLE IF EXISTS supervise_personal_report;
CREATE TABLE supervise_personal_report (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    report_year VARCHAR(8) NOT NULL COMMENT '报告年度',
    report_content TEXT COMMENT '报告内容',
    check_result VARCHAR(32) COMMENT '核查结果 NORMAL正常 ABNORMAL异常',
    check_issue TEXT COMMENT '核查问题描述',
    submit_date DATE COMMENT '提交日期',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id),
    INDEX idx_year (report_year)
) ENGINE=InnoDB COMMENT='个人事项报告表';

-- 预警记录表
DROP TABLE IF EXISTS supervise_alert;
CREATE TABLE supervise_alert (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    alert_type VARCHAR(64) NOT NULL COMMENT '预警类型 RED红 YELLOW黄 BLUE蓝',
    alert_category VARCHAR(64) NOT NULL COMMENT '预警类别',
    alert_title VARCHAR(256) NOT NULL COMMENT '预警标题',
    alert_content TEXT COMMENT '预警内容',
    target_user_id BIGINT COMMENT '提醒对象用户ID',
    target_cadre_id BIGINT COMMENT '关联干部ID',
    is_read TINYINT DEFAULT 0 COMMENT '是否已读',
    read_time DATETIME COMMENT '阅读时间',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_user (target_user_id),
    INDEX idx_read (is_read)
) ENGINE=InnoDB COMMENT='预警记录表';


-- =================== 干部考核测评 ====================

-- 年度考核记录表
DROP TABLE IF EXISTS assessment_annual;
CREATE TABLE assessment_annual (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    assessment_year VARCHAR(8) NOT NULL COMMENT '考核年度',
    assessment_result VARCHAR(32) COMMENT '考核结果 优秀/称职/基本称职/不称职',
    assessment_comment TEXT COMMENT '考核评语',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id),
    INDEX idx_year (assessment_year)
) ENGINE=InnoDB COMMENT='年度考核记录表';

-- 民主测评方案表
DROP TABLE IF EXISTS assessment_scheme;
CREATE TABLE assessment_scheme (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    scheme_name VARCHAR(128) NOT NULL COMMENT '方案名称',
    scheme_year VARCHAR(8) COMMENT '方案年度',
    vote_start_time DATETIME COMMENT '投票开始时间',
    vote_end_time DATETIME COMMENT '投票结束时间',
    allow_anonymous TINYINT DEFAULT 1 COMMENT '允许匿名投票',
    excellent_max_ratio DECIMAL(5,2) COMMENT '优秀占比上限',
    forbid_all_excellent TINYINT DEFAULT 1 COMMENT '禁止全优评价',
    status VARCHAR(32) COMMENT '状态 DRAFT草稿 ACTIVE进行中 FINISHED已结束',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='民主测评方案表';

-- 测评维度表
DROP TABLE IF EXISTS assessment_dimension;
CREATE TABLE assessment_dimension (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    scheme_id BIGINT NOT NULL COMMENT '方案ID',
    dimension_name VARCHAR(64) NOT NULL COMMENT '维度名称 德/能/勤/绩/廉',
    dimension_weight DECIMAL(5,2) COMMENT '权重',
    sort_order INT DEFAULT 0,
    deleted TINYINT DEFAULT 0,
    INDEX idx_scheme (scheme_id)
) ENGINE=InnoDB COMMENT='测评维度表';

-- 测评指标项
DROP TABLE IF EXISTS assessment_indicator;
CREATE TABLE assessment_indicator (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    dimension_id BIGINT NOT NULL COMMENT '维度ID',
    indicator_name VARCHAR(128) NOT NULL COMMENT '指标名称',
    max_score DECIMAL(5,2) DEFAULT 100 COMMENT '最高分',
    sort_order INT DEFAULT 0,
    deleted TINYINT DEFAULT 0,
    INDEX idx_dimension (dimension_id)
) ENGINE=InnoDB COMMENT='测评指标项';

-- 测评被评对象
DROP TABLE IF EXISTS assessment_target;
CREATE TABLE assessment_target (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    scheme_id BIGINT NOT NULL COMMENT '方案ID',
    cadre_id BIGINT NOT NULL COMMENT '被评干部ID',
    deleted TINYINT DEFAULT 0,
    INDEX idx_scheme (scheme_id)
) ENGINE=InnoDB COMMENT='测评被评对象';

-- 测评投票记录
DROP TABLE IF EXISTS assessment_vote;
CREATE TABLE assessment_vote (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    scheme_id BIGINT NOT NULL COMMENT '方案ID',
    voter_id BIGINT NOT NULL COMMENT '投票人ID',
    target_cadre_id BIGINT NOT NULL COMMENT '被评干部ID',
    indicator_id BIGINT NOT NULL COMMENT '指标ID',
    score DECIMAL(5,2) NOT NULL COMMENT '评分',
    vote_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_scheme_voter (scheme_id, voter_id),
    INDEX idx_target (target_cadre_id)
) ENGINE=InnoDB COMMENT='测评投票记录';


-- =================== 干部日常事务管理 ====================

-- 证照管理表
DROP TABLE IF EXISTS daily_certificate;
CREATE TABLE daily_certificate (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    cert_type VARCHAR(64) COMMENT '证件类型 PASSPORT护照 ENTRY_PERMIT通行证',
    cert_number VARCHAR(64) COMMENT '证件号码',
    cert_status VARCHAR(32) COMMENT '证件状态 STORED存放中 LENT借出 RETURNED已归还 OVERDUE逾期',
    borrow_date DATE COMMENT '借出日期',
    return_date DATE COMMENT '归还日期',
    expected_return_date DATE COMMENT '预计归还日期',
    remark VARCHAR(256) COMMENT '备注',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='证照管理表';

-- 出境登记表
DROP TABLE IF EXISTS daily_abroad_record;
CREATE TABLE daily_abroad_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    destination VARCHAR(128) COMMENT '目的地',
    purpose VARCHAR(256) COMMENT '事由',
    depart_date DATE COMMENT '出境日期',
    return_date DATE COMMENT '入境日期',
    approved_days INT COMMENT '批准天数',
    actual_days INT COMMENT '实际天数',
    is_overdue TINYINT DEFAULT 0 COMMENT '是否超期',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='出境登记表';

-- 休假管理表
DROP TABLE IF EXISTS daily_leave;
CREATE TABLE daily_leave (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    leave_type VARCHAR(32) COMMENT '假别 ANNUAL年假 PERSONAL事假 SICK病假',
    start_date DATE COMMENT '开始日期',
    end_date DATE COMMENT '结束日期',
    leave_days DECIMAL(5,1) COMMENT '请假天数',
    reason VARCHAR(512) COMMENT '请假事由',
    approve_status VARCHAR(32) COMMENT '审批状态 DRAFT草稿 SUBMITTED已提交 APPROVED已通过 REJECTED已驳回',
    approve_id BIGINT COMMENT '审批人ID',
    approve_time DATETIME COMMENT '审批时间',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id),
    INDEX idx_status (approve_status)
) ENGINE=InnoDB COMMENT='休假管理表';

-- 教育培训表
DROP TABLE IF EXISTS daily_training;
CREATE TABLE daily_training (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    training_name VARCHAR(128) NOT NULL COMMENT '培训班名称',
    training_type VARCHAR(64) COMMENT '培训类型',
    start_date DATE COMMENT '开始日期',
    end_date DATE COMMENT '结束日期',
    training_location VARCHAR(128) COMMENT '培训地点',
    organizer VARCHAR(128) COMMENT '主办单位',
    description TEXT COMMENT '培训内容描述',
    status VARCHAR(32) COMMENT '状态 ACTIVE进行中 FINISHED已结束',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='教育培训表';

-- 培训学员关联
DROP TABLE IF EXISTS daily_training_cadre;
CREATE TABLE daily_training_cadre (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    training_id BIGINT NOT NULL COMMENT '培训ID',
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    is_completed TINYINT DEFAULT 0 COMMENT '是否完成',
    certificate_url VARCHAR(255) COMMENT '证书地址',
    UNIQUE KEY uk_training_cadre (training_id, cadre_id)
) ENGINE=InnoDB COMMENT='培训学员关联表';

-- 挂职锻炼表
DROP TABLE IF EXISTS daily_secondment;
CREATE TABLE daily_secondment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    secondment_unit VARCHAR(128) COMMENT '挂职单位',
    secondment_position VARCHAR(128) COMMENT '挂职职务',
    start_date DATE COMMENT '开始日期',
    end_date DATE COMMENT '结束日期',
    status VARCHAR(32) COMMENT '状态 ACTIVE在岗 FINISHED已结束',
    remark VARCHAR(512) COMMENT '备注',
    create_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='挂职锻炼表';

-- 自助申报表（通用）
DROP TABLE IF EXISTS daily_self_application;
CREATE TABLE daily_self_application (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    applicant_id BIGINT NOT NULL COMMENT '申请人ID',
    application_type VARCHAR(64) NOT NULL COMMENT '申报类型 INFO_UPDATE信息修改 LEAVE请假 PART_TIME兼职 TRAINING培训 ABROAD出国',
    application_title VARCHAR(256) COMMENT '申报标题',
    application_content TEXT COMMENT '申报内容',
    apply_status VARCHAR(32) DEFAULT 'DRAFT' COMMENT '申报状态 DRAFT草稿 SUBMITTED已提交 APPROVED已通过 REJECTED已驳回',
    approver_id BIGINT COMMENT '审批人ID',
    approve_time DATETIME COMMENT '审批时间',
    approve_comment VARCHAR(512) COMMENT '审批意见',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_applicant (applicant_id),
    INDEX idx_status (apply_status)
) ENGINE=InnoDB COMMENT='自助申报表';


-- =================== 名册/打印模板 ====================

-- 名册模板
DROP TABLE IF EXISTS sys_roster_template;
CREATE TABLE sys_roster_template (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    template_name VARCHAR(128) NOT NULL COMMENT '模板名称',
    template_fields TEXT COMMENT '模板包含字段(JSON)',
    is_system TINYINT DEFAULT 0 COMMENT '是否系统预设',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='名册模板表';

-- 打印模板
DROP TABLE IF EXISTS sys_print_template;
CREATE TABLE sys_print_template (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    template_name VARCHAR(128) NOT NULL COMMENT '模板名称',
    template_type VARCHAR(64) COMMENT '模板类型 APPOINTMENT任免表 ARCHIVE档案 EXPORT导出',
    template_content LONGTEXT COMMENT '模板内容(HTML/Word)',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
) ENGINE=InnoDB COMMENT='打印模板表';
