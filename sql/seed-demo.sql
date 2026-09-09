-- ============================================
-- 辽宁某某大学 · 干部人事系统 - 演示/示例数据
-- 机构树 + 编制 + 干部档案（可重复执行，先清空相关业务表）
-- 提示：以下姓名均为虚构，职位均为示例占位，不含真实人员信息
-- ============================================
USE POP;
SET FOREIGN_KEY_CHECKS=0;
DELETE FROM cadre_reserve; DELETE FROM cadre_attachment; DELETE FROM cadre_family_member;
DELETE FROM appoint_record; DELETE FROM appoint_process; DELETE FROM transfer_record; DELETE FROM rank_promotion_record;
DELETE FROM cadre_info; DELETE FROM org_staffing_quota; DELETE FROM org_rank; DELETE FROM org_department;

-- 职级显式 id（1-9），确保重复执行时 cadre_info.rank_id 引用稳定不漂移
INSERT INTO org_rank (id, rank_name, rank_type, promotion_years, sort_order, status, create_time, update_time) VALUES
(1, '管理岗-一级调研员', '管理岗', 3, 1, 1, NOW(), NOW()),
(2, '管理岗-正处级', '管理岗', 3, 2, 1, NOW(), NOW()),
(3, '管理岗-副处级', '管理岗', 3, 3, 1, NOW(), NOW()),
(4, '管理岗-正科级', '管理岗', 3, 4, 1, NOW(), NOW()),
(5, '管理岗-副科级', '管理岗', 3, 5, 1, NOW(), NOW()),
(6, '专业技术岗-正高级', '专业技术岗', 3, 6, 1, NOW(), NOW()),
(7, '专业技术岗-副高级', '专业技术岗', 3, 7, 1, NOW(), NOW()),
(8, '专业技术岗-中级', '专业技术岗', 3, 8, 1, NOW(), NOW()),
(9, '专业技术岗-初级', '专业技术岗', 3, 9, 1, NOW(), NOW());
ALTER TABLE org_rank AUTO_INCREMENT = 10;

INSERT INTO org_department (id, parent_id, dept_name, short_name, dept_level, leader_quota, dept_sort, status, create_time, update_time) VALUES
(1, 0, '辽宁某某大学', '学校机关', '校级', 11, 1, 1, NOW(), NOW()),
(2, 1, '党委组织部', '组织部', '处级', 3, 2, 1, NOW(), NOW()),
(3, 1, '人事处', '人事处', '处级', 4, 3, 1, NOW(), NOW()),
(4, 1, '党委宣传部', '宣传部', '处级', 3, 4, 1, NOW(), NOW()),
(5, 1, '纪委办公室', '纪委办', '处级', 3, 5, 1, NOW(), NOW()),
(6, 1, '审计处', '审计处', '处级', 2, 6, 1, NOW(), NOW()),
(7, 1, '教务处', '教务处', '处级', 4, 7, 1, NOW(), NOW()),
(8, 1, '科学技术处', '科研处', '处级', 3, 8, 1, NOW(), NOW()),
(9, 1, '学生工作部', '学工部', '处级', 3, 9, 1, NOW(), NOW()),
(10, 1, '计划财务处', '财务处', '处级', 3, 10, 1, NOW(), NOW()),
(11, 1, '招生就业处', '招就处', '处级', 3, 11, 1, NOW(), NOW()),
(12, 1, '保卫处', '保卫处', '处级', 3, 12, 1, NOW(), NOW()),
(13, 1, '团委', '团委', '处级', 2, 13, 1, NOW(), NOW()),
(14, 1, '校工会', '工会', '处级', 2, 14, 1, NOW(), NOW()),
(15, 1, '机械工程与自动化学院', '机械学院', '处级', 7, 15, 1, NOW(), NOW()),
(16, 1, '电气工程学院', '电气学院', '处级', 7, 16, 1, NOW(), NOW()),
(17, 1, '信息科学与工程学院', '信息学院', '处级', 7, 17, 1, NOW(), NOW()),
(18, 1, '计算机科学与技术学院', '计算机学院', '处级', 7, 18, 1, NOW(), NOW()),
(19, 1, '土木建筑工程学院', '土木学院', '处级', 7, 19, 1, NOW(), NOW()),
(20, 1, '材料科学与工程学院', '材料学院', '处级', 7, 20, 1, NOW(), NOW()),
(21, 1, '自动化与控制工程学院', '自动化学院', '处级', 7, 21, 1, NOW(), NOW()),
(22, 1, '外国语学院', '外语学院', '处级', 6, 22, 1, NOW(), NOW()),
(23, 1, '经济管理学院', '经管学院', '处级', 7, 23, 1, NOW(), NOW()),
(24, 1, '马克思主义学院', '马院', '处级', 5, 24, 1, NOW(), NOW()),
(25, 1, '理学院', '理学院', '处级', 6, 25, 1, NOW(), NOW()),
(26, 1, '后勤管理处', '后勤处', '处级', 3, 26, 1, NOW(), NOW()),
(27, 1, '国际交流合作处', '国际处', '处级', 2, 27, 1, NOW(), NOW());

INSERT INTO org_staffing_quota (dept_id, approved_quota, leader_quota) VALUES
(1, 24, 11),
(2, 14, 3),
(3, 18, 4),
(4, 13, 3),
(5, 9, 3),
(6, 8, 2),
(7, 22, 4),
(8, 14, 3),
(9, 16, 3),
(10, 17, 3),
(11, 11, 3),
(12, 16, 3),
(13, 8, 2),
(14, 7, 2),
(15, 62, 7),
(16, 58, 7),
(17, 50, 7),
(18, 56, 7),
(19, 52, 7),
(20, 48, 7),
(21, 46, 7),
(22, 34, 6),
(23, 44, 7),
(24, 28, 5),
(25, 40, 6),
(26, 20, 3),
(27, 9, 2);

INSERT INTO cadre_info (name, gender, birth_date, nation, native_place, political_status, party_join_date, work_start_date, id_card, phone, email, photo_url, resume_text, full_time_education, full_time_degree, full_time_school, part_time_education, part_time_degree, part_time_school, dept_id, position, position_level, rank_id, position_start_date, position_doc_no, reward_punishment, annual_assessment, cadre_status, retirement_date, leave_date, leave_reason, create_time, update_time) VALUES
('顾晓东', 1, '1969-07-07', '汉族', '江苏南京', '中共党员', '1991-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '2005-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓秀兰', 1, '1965-11-13', '汉族', '江苏南京', '中共党员', '1984-06-01', '1986-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '1996-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('胡红', 1, '1972-06-03', '汉族', '辽宁铁岭', '中共党员', '1991-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '2006-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('万娟', 1, '1967-02-05', '汉族', '辽宁本溪', '中共党员', '1993-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '1999-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黎志明', 1, '1965-05-01', '回族', '辽宁营口', '中共党员', '1985-06-01', '1985-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '1987-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆志强', 1, '1968-12-07', '汉族', '山东青岛', '中共党员', '1989-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '1997-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('许红', 1, '1965-01-06', '朝鲜族', '辽宁大连', '中共党员', '1986-06-01', '1986-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '1988-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('朱伟', 1, '1972-07-23', '汉族', '江苏南京', '中共党员', '1992-06-01', '1992-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '2002-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝春生', 1, '1969-11-03', '汉族', '辽宁沈阳', '中共党员', '1989-06-01', '1992-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 1, '校级领导', '校级', 1, '2001-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('蔡浩然', 1, '1975-02-07', '汉族', '辽宁锦州', '中共党员', '1997-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁大学', NULL, NULL, NULL, 2, '部门负责人', '处级', 3, '2006-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('林雨桐', 2, '1970-07-24', '蒙古族', '辽宁本溪', '中共党员', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 2, '部门副职', '处级', 7, '2000-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('秦霞', 1, '1974-03-06', '朝鲜族', '辽宁辽阳', '中共党员', '1995-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳工业大学', NULL, NULL, NULL, 2, '部门副职', '科级', 9, '2005-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钱海涛', 1, '1975-03-06', '锡伯族', '河南郑州', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连海事大学', NULL, NULL, NULL, 2, '科室负责人', '科级', 4, '2010-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓军', 1, '1966-07-20', '蒙古族', '吉林长春', '中共党员', '1987-06-01', '1987-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 2, '科室负责人', '科级', 8, '1993-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曾志强', 2, '1968-11-08', '汉族', '辽宁大连', '中共党员', '1988-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 2, '科室副职', '科级', 1, '1993-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('于晨曦', 2, '1992-08-16', '汉族', '辽宁盘锦', '中共党员', '2017-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 2, '科室副职', '科级', 4, '2021-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('崔平', 1, '1985-12-03', '汉族', '江苏南京', '中共党员', '2010-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁师范大学', NULL, NULL, NULL, 2, '管理员', '科级', 1, '2015-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('毛磊', 1, '1985-05-27', '汉族', '辽宁抚顺', '民主党派', '2003-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 2, '管理员', '科级', 1, '2019-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('毛芳', 2, '1992-02-25', '汉族', '吉林长春', '中共党员', '2013-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 2, '管理员', '科级', 7, '2024-05-01', NULL, NULL, NULL, 'TRANSFERRED', NULL, NULL, NULL, NOW(), NOW()),
('宋梓萱', 1, '1974-04-06', '汉族', '河南郑州', '中共党员', '1999-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '清华大学', NULL, NULL, NULL, 3, '部门负责人', '处级', 7, '2009-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('史娜', 1, '1973-03-27', '汉族', '辽宁沈阳', '中共党员', '1995-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 3, '部门副职', '处级', 8, '1996-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('毛伟', 1, '1969-03-05', '汉族', '辽宁营口', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 3, '部门副职', '科级', 5, '1998-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钱俊杰', 1, '1973-03-20', '朝鲜族', '辽宁锦州', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 3, '科室负责人', '科级', 8, '2008-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黎玉芬', 2, '1970-08-10', '蒙古族', '辽宁铁岭', '中共党员', '1991-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 3, '科室负责人', '科级', 2, '2005-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郭雪', 1, '1975-11-13', '汉族', '山东青岛', '中共党员', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁工程技术大学', NULL, NULL, NULL, 3, '科室副职', '科级', 2, '2013-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('向明辉', 2, '1990-05-18', '汉族', '辽宁锦州', '中共党员', '2008-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 3, '科室副职', '科级', 8, '2025-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('沈桂英', 1, '1991-05-02', '满族', '辽宁阜新', '中共党员', '2011-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 3, '管理员', '科级', 2, '2018-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭强', 2, '1983-04-25', '蒙古族', '辽宁阜新', '中共党员', '2010-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 3, '管理员', '科级', 7, '2011-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吴建国', 2, '1992-07-22', '汉族', '吉林长春', '民主党派', '2015-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '华中科技大学', NULL, NULL, NULL, 3, '管理员', '科级', 7, '2025-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杜树', 1, '1987-04-24', '汉族', '辽宁大连', '群众', '2009-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳工业大学', NULL, NULL, NULL, 3, '管理员', '科级', 6, '2013-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('田秀兰', 1, '1985-06-10', '汉族', '辽宁朝阳', '群众', '2005-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 3, '管理员', '科级', 6, '2009-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杨强', 1, '1980-09-04', '汉族', '辽宁阜新', '民主党派', '2004-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 3, '管理员', '科级', 2, '2013-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('唐明辉', 1, '1995-03-08', '汉族', '江苏南京', '中共党员', '2017-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁师范大学', NULL, NULL, NULL, 3, '管理员', '科级', 7, '2025-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('雷晨曦', 2, '1966-05-26', '汉族', '辽宁朝阳', '中共党员', '1988-06-01', '1988-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 4, '部门负责人', '处级', 9, '1992-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('梁俊杰', 2, '1969-09-17', '汉族', '辽宁锦州', '中共党员', '1993-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 4, '部门副职', '处级', 3, '1996-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭波', 2, '1973-11-03', '汉族', '吉林长春', '中共党员', '1994-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳工业大学', NULL, NULL, NULL, 4, '部门副职', '科级', 8, '2003-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邵永强', 1, '1972-12-03', '蒙古族', '辽宁辽阳', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 4, '科室负责人', '科级', 3, '2001-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('许婷', 2, '1973-07-21', '汉族', '河南郑州', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北大学', NULL, NULL, NULL, 4, '科室负责人', '科级', 7, '2008-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('毛文博', 1, '1970-08-17', '回族', '辽宁阜新', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北大学', NULL, NULL, NULL, 4, '科室副职', '科级', 4, '1997-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚明', 2, '1975-10-10', '达斡尔族', '辽宁大连', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 4, '科室副职', '科级', 7, '2004-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('向玉芬', 1, '1979-11-09', '汉族', '辽宁葫芦岛', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 4, '管理员', '科级', 4, '2010-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('万刚', 1, '1978-02-27', '达斡尔族', '山东青岛', '中共党员', '2002-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 4, '管理员', '科级', 8, '2014-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('彭波', 1, '1963-06-10', '汉族', '辽宁营口', '中共党员', '1985-06-01', '1985-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 4, '管理员', '科级', 7, '1990-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贺欣怡', 1, '1982-04-28', '汉族', '辽宁朝阳', '中共党员', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 4, '管理员', '科级', 2, '2011-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杨一诺', 2, '1972-07-10', '汉族', '辽宁鞍山', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 5, '部门负责人', '处级', 8, '2000-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('胡光辉', 1, '1966-12-03', '汉族', '辽宁葫芦岛', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 5, '部门副职', '处级', 8, '1992-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('魏俊杰', 2, '1971-04-06', '朝鲜族', '辽宁丹东', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 5, '部门副职', '科级', 7, '2007-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('龚健', 2, '1966-11-09', '满族', '辽宁沈阳', '中共党员', '1986-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 5, '科室负责人', '科级', 3, '1998-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曾子涵', 1, '1967-02-23', '回族', '辽宁阜新', '中共党员', '1987-06-01', '1987-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 5, '科室负责人', '科级', 6, '1994-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖明', 2, '1969-11-28', '汉族', '辽宁锦州', '中共党员', '1990-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连理工大学', NULL, NULL, NULL, 5, '科室副职', '科级', 7, '1998-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('潘春生', 1, '1978-04-27', '汉族', '辽宁辽阳', '中共党员', '2000-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳师范大学', NULL, NULL, NULL, 5, '科室副职', '科级', 4, '2014-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('王桂英', 1, '1996-12-26', '汉族', '山东青岛', '群众', '2016-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳师范大学', NULL, NULL, NULL, 5, '管理员', '科级', 5, '2025-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹诗涵', 2, '1973-12-18', '锡伯族', '辽宁盘锦', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 6, '部门负责人', '处级', 4, '2005-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('向德明', 1, '1971-04-22', '汉族', '辽宁阜新', '中共党员', '1989-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 6, '部门副职', '处级', 9, '2005-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姜斌', 1, '1968-02-18', '回族', '辽宁营口', '中共党员', '1995-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁大学', NULL, NULL, NULL, 6, '部门副职', '科级', 7, '2001-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('叶佳琪', 1, '1976-07-28', '汉族', '辽宁鞍山', '中共党员', '1998-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京大学', NULL, NULL, NULL, 6, '科室负责人', '科级', 5, '2004-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹海涛', 1, '1973-08-14', '达斡尔族', '辽宁阜新', '中共党员', '1991-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 6, '科室负责人', '科级', 9, '2005-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贺一诺', 2, '1971-06-14', '汉族', '辽宁丹东', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 6, '科室副职', '科级', 9, '2001-08-01', NULL, NULL, NULL, 'TRANSFERRED', NULL, NULL, NULL, NOW(), NOW()),
('孙晓东', 1, '1976-09-16', '汉族', '辽宁锦州', '群众', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 6, '科室副职', '科级', 3, '2003-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹丽华', 2, '1976-11-03', '锡伯族', '辽宁葫芦岛', '民主党派', '1994-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '清华大学', NULL, NULL, NULL, 6, '管理员', '科级', 5, '2002-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('段艳', 2, '1975-08-15', '汉族', '河北石家庄', '中共党员', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '清华大学', NULL, NULL, NULL, 7, '部门负责人', '处级', 6, '2007-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆海涛', 2, '1973-07-04', '汉族', '辽宁沈阳', '中共党员', '1992-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北大学', NULL, NULL, NULL, 7, '部门副职', '处级', 5, '2002-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黄丽', 1, '1970-01-21', '汉族', '辽宁丹东', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 7, '部门副职', '科级', 7, '2002-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('张刚', 2, '1971-12-12', '汉族', '辽宁沈阳', '中共党员', '1992-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 7, '科室负责人', '科级', 8, '2001-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邵秀兰', 1, '1976-05-19', '朝鲜族', '辽宁沈阳', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 7, '科室负责人', '科级', 2, '2000-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('彭宇航', 2, '1976-11-19', '汉族', '辽宁沈阳', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连海事大学', NULL, NULL, NULL, 7, '科室副职', '科级', 7, '2007-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('龙玉芬', 1, '1995-10-19', '汉族', '辽宁抚顺', '中共党员', '2020-06-01', '2023-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 7, '科室副职', '科级', 7, '2025-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孙晓东', 1, '1980-04-15', '汉族', '辽宁沈阳', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 7, '管理员', '科级', 2, '2001-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('付波', 1, '1996-10-02', '满族', '辽宁丹东', '民主党派', '2017-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京大学', NULL, NULL, NULL, 7, '管理员', '科级', 7, '2025-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('胡玉芬', 2, '1989-12-23', '汉族', '吉林长春', '群众', '2009-06-01', '2012-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁师范大学', NULL, NULL, NULL, 7, '管理员', '科级', 6, '2013-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫诗涵', 2, '1973-06-15', '汉族', '辽宁朝阳', '群众', '1991-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '西安交通大学', NULL, NULL, NULL, 7, '管理员', '科级', 6, '1996-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('白红梅', 1, '1990-11-18', '汉族', '河北石家庄', '中共党员', '2013-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北大学', NULL, NULL, NULL, 7, '管理员', '科级', 4, '2018-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('张淑华', 1, '1985-07-15', '回族', '辽宁辽阳', '群众', '2008-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 7, '管理员', '科级', 8, '2015-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('严志明', 1, '1995-04-15', '回族', '吉林长春', '中共党员', '2020-06-01', '2022-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 7, '管理员', '科级', 6, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓磊', 1, '1994-11-18', '汉族', '江苏南京', '中共党员', '2021-06-01', '2021-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 7, '管理员', '科级', 3, '2025-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('熊健', 1, '1993-03-24', '汉族', '辽宁营口', '中共党员', '2016-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '华中科技大学', NULL, NULL, NULL, 7, '管理员', '科级', 1, '2022-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姜丽', 1, '1973-01-16', '回族', '辽宁辽阳', '中共党员', '1994-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳师范大学', NULL, NULL, NULL, 7, '管理员', '科级', 3, '2001-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谢志明', 1, '1976-06-09', '汉族', '吉林长春', '中共党员', '1999-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 8, '部门负责人', '处级', 9, '2009-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('高军', 1, '1973-08-13', '汉族', '辽宁抚顺', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京大学', NULL, NULL, NULL, 8, '部门副职', '处级', 8, '2005-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韦诗涵', 1, '1970-05-13', '汉族', '辽宁大连', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 8, '部门副职', '科级', 9, '2003-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邵欣怡', 1, '1976-12-07', '汉族', '辽宁盘锦', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁大学', NULL, NULL, NULL, 8, '科室负责人', '科级', 1, '2007-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('潘娜', 1, '1968-01-03', '回族', '辽宁沈阳', '民主党派', '1989-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 8, '科室负责人', '科级', 1, '1998-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钱嘉伟', 2, '1966-04-10', '汉族', '辽宁抚顺', '中共党员', '1986-06-01', '1986-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '吉林大学', NULL, NULL, NULL, 8, '科室副职', '科级', 7, '1998-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('沈国栋', 2, '1974-10-09', '汉族', '辽宁沈阳', '中共党员', '1992-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北大学', NULL, NULL, NULL, 8, '科室副职', '科级', 1, '2010-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫霞', 1, '1964-06-15', '回族', '辽宁辽阳', '中共党员', '1985-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁师范大学', NULL, NULL, NULL, 8, '管理员', '科级', 8, '2000-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('魏娜', 2, '1994-11-22', '回族', '辽宁大连', '中共党员', '2017-06-01', '2021-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连理工大学', NULL, NULL, NULL, 8, '管理员', '科级', 2, '2022-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('雷勇', 1, '1958-10-05', '汉族', '辽宁大连', '民主党派', '1982-06-01', '1980-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁师范大学', NULL, NULL, NULL, 8, '管理员', '科级', 8, '1985-09-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('丁杰', 1, '1976-06-13', '汉族', '辽宁鞍山', '中共党员', '1994-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁工程技术大学', NULL, NULL, NULL, 9, '部门负责人', '处级', 5, '2006-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('蒋建国', 1, '1971-11-28', '汉族', '辽宁沈阳', '中共党员', '1993-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '燕山大学', NULL, NULL, NULL, 9, '部门副职', '处级', 8, '1995-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('严海峰', 2, '1975-09-03', '汉族', '黑龙江哈尔滨', '中共党员', '1997-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 9, '部门副职', '科级', 9, '2015-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('尹春生', 1, '1969-04-19', '汉族', '辽宁大连', '群众', '1989-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 9, '科室负责人', '科级', 5, '1994-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('于玉芬', 1, '1967-02-19', '汉族', '辽宁大连', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '哈尔滨工业大学', NULL, NULL, NULL, 9, '科室负责人', '科级', 9, '2002-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('武杰', 1, '1975-08-20', '汉族', '吉林长春', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 9, '科室副职', '科级', 1, '2001-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('毛雪', 1, '1972-11-12', '朝鲜族', '黑龙江哈尔滨', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 9, '科室副职', '科级', 7, '2005-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('任春生', 1, '1975-05-26', '回族', '黑龙江哈尔滨', '民主党派', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 9, '管理员', '科级', 5, '2012-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('程超', 1, '1994-05-25', '达斡尔族', '吉林长春', '民主党派', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 9, '管理员', '科级', 6, '2019-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韩芳', 1, '1974-10-04', '汉族', '辽宁葫芦岛', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 9, '管理员', '科级', 8, '1999-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('石志明', 2, '1994-06-18', '蒙古族', '辽宁丹东', '民主党派', '2016-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 9, '管理员', '科级', 4, '2021-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('蔡梓萱', 2, '1991-04-20', '回族', '辽宁本溪', '中共党员', '2010-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁师范大学', NULL, NULL, NULL, 9, '管理员', '科级', 2, '2019-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('冯红梅', 1, '1969-05-19', '汉族', '辽宁抚顺', '中共党员', '1989-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '吉林大学', NULL, NULL, NULL, 10, '部门负责人', '处级', 9, '1992-07-01', NULL, NULL, NULL, 'RESIGNED', NULL, NULL, NULL, NOW(), NOW()),
('冯明辉', 2, '1969-10-13', '汉族', '辽宁本溪', '群众', '1989-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 10, '部门副职', '处级', 7, '2000-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝鑫', 1, '1966-02-21', '汉族', '辽宁鞍山', '群众', '1988-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 10, '部门副职', '科级', 3, '1991-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杨洋', 2, '1974-02-19', '汉族', '辽宁营口', '中共党员', '1995-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 10, '科室负责人', '科级', 8, '2005-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('尹晨曦', 1, '1972-08-01', '达斡尔族', '辽宁鞍山', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京大学', NULL, NULL, NULL, 10, '科室负责人', '科级', 9, '1999-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('胡平', 2, '1973-10-01', '汉族', '河南郑州', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 10, '科室副职', '科级', 6, '2009-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('马刚', 1, '1993-06-24', '蒙古族', '辽宁丹东', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳师范大学', NULL, NULL, NULL, 10, '科室副职', '科级', 5, '2020-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陶诗涵', 2, '1995-01-20', '达斡尔族', '辽宁鞍山', '中共党员', '2016-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '华中科技大学', NULL, NULL, NULL, 10, '管理员', '科级', 9, '2022-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓静', 2, '1976-01-25', '达斡尔族', '黑龙江哈尔滨', '中共党员', '1999-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 10, '管理员', '科级', 2, '2001-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('任佳琪', 1, '1974-05-03', '朝鲜族', '辽宁阜新', '群众', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 10, '管理员', '科级', 6, '1995-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('刘一诺', 1, '1984-08-27', '蒙古族', '辽宁盘锦', '中共党员', '2005-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 10, '管理员', '科级', 7, '2017-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹诗涵', 2, '1996-09-08', '汉族', '辽宁抚顺', '中共党员', '2017-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 10, '管理员', '科级', 4, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('熊平', 2, '1985-02-04', '汉族', '辽宁鞍山', '群众', '2007-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 10, '管理员', '科级', 8, '2018-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖芳', 2, '1995-05-04', '汉族', '山东青岛', '中共党员', '2017-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 10, '管理员', '科级', 9, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('江芳', 1, '1966-07-10', '汉族', '辽宁朝阳', '中共党员', '1986-06-01', '1986-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 11, '部门负责人', '处级', 6, '1989-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邱子涵', 1, '1972-07-07', '汉族', '辽宁铁岭', '中共党员', '1990-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '清华大学', NULL, NULL, NULL, 11, '部门副职', '处级', 2, '2003-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('李刚', 1, '1969-04-21', '达斡尔族', '河南郑州', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 11, '部门副职', '科级', 9, '1999-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('夏秀兰', 2, '1975-06-15', '达斡尔族', '辽宁本溪', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 11, '科室负责人', '科级', 8, '2007-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('付子涵', 1, '1971-01-04', '汉族', '辽宁抚顺', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 11, '科室负责人', '科级', 7, '2004-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('胡鑫', 2, '1973-08-07', '回族', '辽宁丹东', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳工业大学', NULL, NULL, NULL, 11, '科室副职', '科级', 5, '1999-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邵浩然', 1, '1993-10-10', '回族', '辽宁盘锦', '群众', '2017-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 11, '科室副职', '科级', 8, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('张一诺', 1, '1983-09-15', '汉族', '辽宁辽阳', '中共党员', '2006-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 11, '管理员', '科级', 5, '2015-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杜文博', 1, '1993-05-05', '汉族', '辽宁铁岭', '中共党员', '2020-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '西安交通大学', NULL, NULL, NULL, 11, '管理员', '科级', 3, '2023-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汤晨曦', 2, '1969-12-01', '满族', '辽宁大连', '中共党员', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '清华大学', NULL, NULL, NULL, 12, '部门负责人', '处级', 4, '1997-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贺树', 1, '1974-02-24', '汉族', '辽宁丹东', '中共党员', '1993-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 12, '部门副职', '处级', 2, '2005-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('白永强', 1, '1969-11-20', '朝鲜族', '辽宁鞍山', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 12, '部门副职', '科级', 6, '1991-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('熊红梅', 2, '1975-10-10', '蒙古族', '山东青岛', '中共党员', '2000-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 12, '科室负责人', '科级', 5, '2011-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钟明辉', 2, '1970-10-12', '汉族', '辽宁抚顺', '中共党员', '1992-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京大学', NULL, NULL, NULL, 12, '科室负责人', '科级', 1, '2003-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谢霞', 1, '1975-02-16', '汉族', '辽宁丹东', '中共党员', '1999-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '哈尔滨工业大学', NULL, NULL, NULL, 12, '科室副职', '科级', 3, '2005-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周丽娟', 1, '1959-12-24', '回族', '山东青岛', '中共党员', '1982-06-01', '1983-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 12, '科室副职', '科级', 4, '1985-05-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('陶强', 2, '1980-12-22', '汉族', '山东青岛', '群众', '2006-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 12, '管理员', '科级', 8, '2015-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汤德明', 2, '1982-10-06', '回族', '辽宁丹东', '中共党员', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 12, '管理员', '科级', 6, '2009-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('卢靖宇', 1, '1960-09-01', '满族', '辽宁铁岭', '中共党员', '1983-06-01', '1984-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 12, '管理员', '科级', 9, '1996-06-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('吴永强', 1, '1993-09-22', '汉族', '辽宁本溪', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 12, '管理员', '科级', 7, '2025-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('付永强', 2, '1989-07-28', '汉族', '辽宁丹东', '民主党派', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北大学', NULL, NULL, NULL, 12, '管理员', '科级', 3, '2017-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆伟', 1, '1969-01-27', '朝鲜族', '辽宁大连', '中共党员', '1992-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连理工大学', NULL, NULL, NULL, 13, '部门负责人', '处级', 5, '1997-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('向丽', 2, '1972-02-24', '汉族', '辽宁朝阳', '中共党员', '1994-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 13, '部门副职', '处级', 3, '2002-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孙浩然', 2, '1970-12-26', '满族', '辽宁鞍山', '中共党员', '1994-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁大学', NULL, NULL, NULL, 13, '部门副职', '科级', 2, '2006-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('戴雨桐', 1, '1969-05-25', '蒙古族', '辽宁沈阳', '中共党员', '1987-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 13, '科室负责人', '科级', 1, '2002-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('薛海峰', 2, '1970-03-16', '汉族', '辽宁朝阳', '群众', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 13, '科室负责人', '科级', 2, '1998-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹德明', 2, '1970-04-15', '汉族', '辽宁鞍山', '中共党员', '1988-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '清华大学', NULL, NULL, NULL, 13, '科室副职', '科级', 3, '2004-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黎丽', 1, '1988-12-04', '汉族', '辽宁抚顺', '民主党派', '2009-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '清华大学', NULL, NULL, NULL, 13, '科室副职', '科级', 8, '2018-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周平', 2, '1962-12-27', '汉族', '辽宁营口', '中共党员', '1988-06-01', '1988-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北财经大学', NULL, NULL, NULL, 13, '管理员', '科级', 8, '1990-02-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('周静', 1, '1974-06-10', '蒙古族', '黑龙江哈尔滨', '中共党员', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁师范大学', NULL, NULL, NULL, 14, '部门负责人', '处级', 7, '2013-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫海涛', 2, '1971-01-26', '汉族', '辽宁阜新', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 14, '部门副职', '处级', 4, '2006-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('冯磊', 2, '1972-03-25', '汉族', '辽宁大连', '中共党员', '1992-06-01', '1992-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 14, '部门副职', '科级', 1, '2003-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫靖宇', 1, '1974-12-20', '汉族', '江苏南京', '中共党员', '1993-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 14, '科室负责人', '科级', 8, '2007-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邱艳', 2, '1976-07-14', '回族', '吉林长春', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 14, '科室负责人', '科级', 1, '2008-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钟梓萱', 1, '1973-04-05', '汉族', '辽宁盘锦', '中共党员', '1997-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 14, '科室副职', '科级', 8, '2006-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孙文博', 2, '1989-03-08', '汉族', '江苏南京', '民主党派', '2013-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 14, '科室副职', '科级', 5, '2025-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('唐文博', 1, '1996-12-28', '汉族', '辽宁朝阳', '群众', '2020-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 14, '管理员', '科级', 8, '2023-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('许霞', 1, '1975-11-27', '蒙古族', '吉林长春', '中共党员', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '西安交通大学', NULL, NULL, NULL, 15, '学院负责人', '处级', 4, '2009-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚晨曦', 2, '1971-11-12', '达斡尔族', '辽宁营口', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 15, '学院党组织负责人', '处级', 1, '2008-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('马强', 2, '1976-02-26', '汉族', '河南郑州', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 15, '学院副职', '处级', 6, '2001-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('余思远', 2, '1974-02-03', '汉族', '辽宁丹东', '中共党员', '1995-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北大学', NULL, NULL, NULL, 15, '学院副职', '处级', 3, '2003-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('白雨泽', 1, '1974-02-25', '满族', '辽宁铁岭', '中共党员', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 15, '学院副职', '科级', 8, '2008-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('何欣怡', 2, '1968-11-13', '朝鲜族', '辽宁朝阳', '中共党员', '1987-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 15, '学院办公室主任', '科级', 5, '2001-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('许晨曦', 2, '1976-02-23', '达斡尔族', '辽宁营口', '中共党员', '1999-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 15, '系/教研室主任', '科级', 6, '2005-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫海峰', 1, '1985-06-11', '回族', '山东青岛', '民主党派', '2006-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 15, '系/教研室主任', '科级', 9, '2018-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周春生', 2, '1998-08-25', '达斡尔族', '辽宁朝阳', '中共党员', '2020-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '华中科技大学', NULL, NULL, NULL, 15, '系/教研室副主任', '科级', 5, '2022-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭丽', 1, '1991-09-09', '达斡尔族', '辽宁营口', '中共党员', '2013-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 15, '系/教研室副主任', '科级', 5, '2018-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('夏芳', 2, '1996-03-25', '汉族', '辽宁朝阳', '中共党员', '2017-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 15, '实验室负责人', '科级', 4, '2025-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆春生', 1, '1993-06-24', '回族', '江苏南京', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 15, '教务干事', '科级', 1, '2020-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('雷思远', 2, '1976-09-17', '汉族', '辽宁抚顺', '民主党派', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 15, '专职教师', '科级', 2, '2005-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曾雪', 1, '1991-04-25', '达斡尔族', '辽宁营口', '中共党员', '2011-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 15, '专职教师', '科级', 1, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('薛红梅', 1, '1978-12-01', '汉族', '辽宁朝阳', '群众', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 15, '专职教师', '科级', 8, '2001-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('龙雨泽', 2, '1975-12-22', '达斡尔族', '山东青岛', '中共党员', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 15, '专职教师', '科级', 2, '2006-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('崔秀兰', 1, '1985-12-05', '汉族', '辽宁本溪', '中共党员', '2004-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 15, '专职教师', '科级', 6, '2017-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('何娟', 2, '1995-08-08', '达斡尔族', '辽宁葫芦岛', '中共党员', '2020-06-01', '2023-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 15, '专职教师', '科级', 9, '2025-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('赵鑫磊', 1, '1990-05-24', '汉族', '吉林长春', '民主党派', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁师范大学', NULL, NULL, NULL, 15, '专职教师', '科级', 8, '2016-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('程军', 2, '1998-09-27', '满族', '辽宁本溪', '中共党员', '2022-06-01', '2023-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 15, '专职教师', '科级', 6, '2025-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('尹欣', 2, '1983-06-05', '回族', '辽宁沈阳', '中共党员', '2008-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 15, '专职教师', '科级', 5, '2016-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孔艳', 1, '1986-12-01', '达斡尔族', '辽宁沈阳', '中共党员', '2009-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 15, '专职教师', '科级', 3, '2023-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('许斌', 1, '1963-02-15', '汉族', '黑龙江哈尔滨', '中共党员', '1985-06-01', '1985-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连海事大学', NULL, NULL, NULL, 15, '专职教师', '科级', 4, '1986-03-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('杜丽华', 1, '1987-02-28', '达斡尔族', '辽宁大连', '中共党员', '2009-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连理工大学', NULL, NULL, NULL, 15, '专职教师', '科级', 5, '2014-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邹雨桐', 1, '1988-05-27', '锡伯族', '辽宁盘锦', '民主党派', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 15, '专职教师', '科级', 9, '2019-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹浩然', 1, '1986-09-06', '汉族', '辽宁锦州', '民主党派', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 15, '专职教师', '科级', 7, '2019-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('于丽娟', 1, '1976-01-06', '汉族', '江苏南京', '民主党派', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 15, '专职教师', '科级', 7, '2003-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('罗军', 2, '1981-10-17', '汉族', '辽宁盘锦', '民主党派', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '吉林大学', NULL, NULL, NULL, 15, '专职教师', '科级', 2, '2011-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭雨泽', 1, '1975-08-28', '达斡尔族', '辽宁盘锦', '中共党员', '1998-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁大学', NULL, NULL, NULL, 15, '专职教师', '科级', 5, '2011-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('江鑫', 2, '1997-04-09', '汉族', '辽宁丹东', '群众', '2017-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 15, '专职教师', '科级', 5, '2022-07-01', NULL, NULL, NULL, 'TRANSFERRED', NULL, NULL, NULL, NOW(), NOW()),
('严梓萱', 2, '1988-05-19', '汉族', '吉林长春', '中共党员', '2007-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 15, '专职教师', '科级', 6, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('马雨泽', 2, '1990-10-02', '达斡尔族', '辽宁阜新', '中共党员', '2009-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 15, '专职教师', '科级', 2, '2025-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('王红', 1, '1958-11-02', '锡伯族', '辽宁辽阳', '中共党员', '1982-06-01', '1980-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 15, '专职教师', '科级', 5, '1984-06-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('何静', 2, '1976-02-05', '汉族', '辽宁丹东', '中共党员', '2003-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北大学', NULL, NULL, NULL, 15, '专职教师', '科级', 7, '2012-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谢霞', 2, '1994-03-20', '汉族', '辽宁朝阳', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 15, '专职教师', '科级', 9, '2025-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('林雨泽', 2, '1987-04-09', '锡伯族', '辽宁葫芦岛', '中共党员', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北大学', NULL, NULL, NULL, 15, '专职教师', '科级', 6, '2021-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('尹秀兰', 2, '1992-02-16', '达斡尔族', '山东青岛', '民主党派', '2017-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 15, '专职教师', '科级', 5, '2019-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚晨曦', 1, '1979-02-21', '满族', '辽宁鞍山', '中共党员', '1997-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 15, '专职教师', '科级', 9, '2012-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('冯淑华', 2, '1983-05-16', '朝鲜族', '江苏南京', '群众', '2004-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连理工大学', NULL, NULL, NULL, 15, '专职教师', '科级', 9, '2006-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓明', 1, '1969-01-06', '汉族', '辽宁营口', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 16, '学院负责人', '处级', 9, '2001-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吕敏', 1, '1977-06-08', '汉族', '河南郑州', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 16, '学院党组织负责人', '处级', 7, '2001-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('付欣', 2, '1972-11-19', '汉族', '辽宁沈阳', '中共党员', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 16, '学院副职', '处级', 8, '1998-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('萧秀兰', 2, '1977-07-17', '汉族', '辽宁葫芦岛', '群众', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 16, '学院副职', '处级', 2, '2013-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('赵晨曦', 2, '1970-07-12', '锡伯族', '黑龙江哈尔滨', '中共党员', '1991-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 16, '学院副职', '科级', 5, '2007-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('袁娜', 2, '1978-11-04', '汉族', '辽宁抚顺', '中共党员', '2002-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 16, '学院办公室主任', '科级', 5, '2017-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('萧娜', 1, '1984-09-14', '汉族', '辽宁葫芦岛', '中共党员', '2012-06-01', '2012-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 16, '系/教研室主任', '科级', 5, '2013-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('毛敏', 1, '1987-04-26', '汉族', '辽宁大连', '群众', '2012-06-01', '2012-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳建筑大学', NULL, NULL, NULL, 16, '系/教研室主任', '科级', 2, '2016-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹志明', 2, '1983-04-05', '汉族', '辽宁沈阳', '民主党派', '2004-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 16, '系/教研室副主任', '科级', 9, '2018-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓春雨', 1, '1991-12-04', '汉族', '辽宁丹东', '中共党员', '2010-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 16, '系/教研室副主任', '科级', 7, '2023-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贾海涛', 1, '1985-11-04', '汉族', '辽宁丹东', '中共党员', '2006-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '燕山大学', NULL, NULL, NULL, 16, '实验室负责人', '科级', 5, '2011-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('罗玉芬', 2, '1997-03-18', '汉族', '江苏南京', '中共党员', '2017-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 16, '教务干事', '科级', 8, '2024-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('程涛', 2, '1992-07-03', '汉族', '辽宁铁岭', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 16, '专职教师', '科级', 9, '2025-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杨勇', 1, '1998-07-08', '汉族', '辽宁沈阳', '中共党员', '2021-06-01', '2025-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 16, '专职教师', '科级', 9, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('朱超', 1, '1960-12-17', '朝鲜族', '辽宁盘锦', '民主党派', '1987-06-01', '1987-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁师范大学', NULL, NULL, NULL, 16, '专职教师', '科级', 9, '1999-07-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('孔雨桐', 2, '1978-02-16', '汉族', '辽宁大连', '中共党员', '2000-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 16, '专职教师', '科级', 1, '2014-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曹俊杰', 1, '1998-08-07', '达斡尔族', '辽宁葫芦岛', '民主党派', '2018-06-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 16, '专职教师', '科级', 3, '2025-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('赵艳', 1, '1991-03-09', '达斡尔族', '河南郑州', '中共党员', '2016-06-01', '2019-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁师范大学', NULL, NULL, NULL, 16, '专职教师', '科级', 7, '2025-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('田志远', 2, '1982-02-12', '汉族', '辽宁丹东', '中共党员', '2006-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 16, '专职教师', '科级', 6, '2008-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('万斌', 2, '1985-09-02', '汉族', '辽宁朝阳', '中共党员', '2003-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 16, '专职教师', '科级', 3, '2015-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('彭磊', 2, '1977-01-26', '蒙古族', '辽宁锦州', '中共党员', '2005-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 16, '专职教师', '科级', 8, '2014-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('余娟', 2, '1987-04-18', '汉族', '河南郑州', '民主党派', '2005-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 16, '专职教师', '科级', 2, '2024-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('唐海峰', 1, '1976-11-22', '汉族', '辽宁丹东', '中共党员', '1994-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 16, '专职教师', '科级', 4, '2013-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('蔡玉芬', 2, '1990-09-20', '满族', '辽宁辽阳', '中共党员', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 16, '专职教师', '科级', 6, '2022-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('何超', 1, '1960-11-04', '满族', '辽宁沈阳', '中共党员', '1983-06-01', '1987-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 16, '专职教师', '科级', 4, '1999-06-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('严淑华', 1, '1981-11-05', '满族', '河北石家庄', '民主党派', '2001-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 16, '专职教师', '科级', 2, '2012-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钟桂英', 2, '1961-11-22', '汉族', '辽宁沈阳', '中共党员', '1982-06-01', '1982-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连理工大学', NULL, NULL, NULL, 16, '专职教师', '科级', 5, '1993-01-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('萧嘉伟', 1, '1988-07-06', '汉族', '辽宁抚顺', '中共党员', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 16, '专职教师', '科级', 9, '2014-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('史强', 2, '1982-09-02', '汉族', '江苏南京', '中共党员', '2005-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '长春理工大学', NULL, NULL, NULL, 16, '专职教师', '科级', 3, '2017-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('赵浩然', 1, '1987-12-09', '汉族', '辽宁鞍山', '群众', '2013-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 16, '专职教师', '科级', 2, '2014-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('蒋佳琪', 1, '1971-08-12', '朝鲜族', '辽宁朝阳', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 17, '学院负责人', '处级', 6, '1999-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('武雪', 1, '1974-02-10', '汉族', '辽宁铁岭', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 17, '学院党组织负责人', '处级', 3, '2006-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('林文静', 2, '1976-07-04', '朝鲜族', '辽宁营口', '中共党员', '1998-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 17, '学院副职', '处级', 1, '2009-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谢健', 1, '1972-01-25', '蒙古族', '辽宁本溪', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北大学', NULL, NULL, NULL, 17, '学院副职', '处级', 3, '2005-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('武洋', 2, '1972-01-12', '汉族', '辽宁大连', '中共党员', '1992-06-01', '1992-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 17, '学院副职', '科级', 2, '2003-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('罗玉芬', 1, '1973-05-23', '汉族', '辽宁本溪', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '华中科技大学', NULL, NULL, NULL, 17, '学院办公室主任', '科级', 9, '2000-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('任一诺', 2, '1992-02-17', '蒙古族', '辽宁抚顺', '中共党员', '2010-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳师范大学', NULL, NULL, NULL, 17, '系/教研室主任', '科级', 2, '2017-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('何国栋', 1, '1975-05-01', '朝鲜族', '江苏南京', '群众', '1995-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 17, '系/教研室主任', '科级', 4, '2011-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('石靖宇', 2, '1994-08-10', '回族', '吉林长春', '中共党员', '2018-06-01', '2022-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 17, '系/教研室副主任', '科级', 2, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('刘波', 1, '1997-01-14', '汉族', '辽宁锦州', '群众', '2015-06-01', '2025-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连理工大学', NULL, NULL, NULL, 17, '系/教研室副主任', '科级', 8, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('侯健', 1, '1985-02-07', '汉族', '辽宁鞍山', '民主党派', '2004-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连理工大学', NULL, NULL, NULL, 17, '实验室负责人', '科级', 7, '2010-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陶浩然', 2, '1990-08-17', '汉族', '辽宁锦州', '中共党员', '2010-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 17, '教务干事', '科级', 8, '2019-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('石德明', 2, '1981-07-19', '锡伯族', '辽宁大连', '中共党员', '2007-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '燕山大学', NULL, NULL, NULL, 17, '专职教师', '科级', 1, '2019-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韦霞', 1, '1982-12-27', '汉族', '辽宁朝阳', '中共党员', '2006-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 17, '专职教师', '科级', 9, '2013-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('王海峰', 1, '1991-05-12', '汉族', '辽宁大连', '中共党员', '2013-06-01', '2019-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 17, '专职教师', '科级', 1, '2021-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('闫平', 1, '1991-04-14', '汉族', '山东青岛', '群众', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '长春理工大学', NULL, NULL, NULL, 17, '专职教师', '科级', 5, '2022-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖俊杰', 2, '1995-01-20', '锡伯族', '江苏南京', '中共党员', '2020-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 17, '专职教师', '科级', 7, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陶嘉伟', 1, '1959-10-01', '汉族', '辽宁辽阳', '民主党派', '1982-06-01', '1981-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '西安交通大学', NULL, NULL, NULL, 17, '专职教师', '科级', 5, '1988-08-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('曾明', 1, '1964-04-20', '蒙古族', '辽宁营口', '中共党员', '1984-06-01', '1984-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 17, '专职教师', '科级', 9, '1996-07-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('汤静', 1, '1977-05-08', '蒙古族', '辽宁大连', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 17, '专职教师', '科级', 6, '2006-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('宋娟', 2, '1977-05-27', '汉族', '黑龙江哈尔滨', '中共党员', '2004-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '哈尔滨工业大学', NULL, NULL, NULL, 17, '专职教师', '科级', 5, '2011-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('罗光辉', 1, '1996-06-24', '汉族', '黑龙江哈尔滨', '中共党员', '2019-06-01', '2019-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 17, '专职教师', '科级', 7, '2021-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邱秀兰', 1, '1983-12-27', '满族', '辽宁营口', '中共党员', '2002-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳工业大学', NULL, NULL, NULL, 17, '专职教师', '科级', 7, '2013-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贾娟', 2, '1975-09-22', '汉族', '辽宁抚顺', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '长春理工大学', NULL, NULL, NULL, 17, '专职教师', '科级', 8, '2004-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('龚志远', 1, '1985-01-20', '汉族', '辽宁丹东', '中共党员', '2008-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁工程技术大学', NULL, NULL, NULL, 17, '专职教师', '科级', 9, '2017-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('范浩然', 1, '1964-03-12', '汉族', '辽宁盘锦', '中共党员', '1989-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 17, '专职教师', '科级', 5, '1998-02-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('周雪', 1, '1976-09-08', '汉族', '辽宁营口', '民主党派', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 17, '专职教师', '科级', 9, '2002-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('龚红', 1, '1992-10-02', '汉族', '辽宁丹东', '民主党派', '2012-06-01', '2012-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 17, '专职教师', '科级', 1, '2019-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('董斌', 1, '1975-08-25', '满族', '辽宁抚顺', '群众', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 18, '学院负责人', '处级', 7, '1998-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钟桂英', 1, '1968-11-23', '汉族', '黑龙江哈尔滨', '中共党员', '1991-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 18, '学院党组织负责人', '处级', 1, '1997-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黄斌', 2, '1969-12-22', '朝鲜族', '辽宁丹东', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 18, '学院副职', '处级', 6, '1995-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('熊建国', 2, '1972-01-01', '汉族', '辽宁锦州', '中共党员', '1995-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '华中科技大学', NULL, NULL, NULL, 18, '学院副职', '处级', 8, '2000-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('高宇航', 1, '1977-10-06', '汉族', '辽宁辽阳', '中共党员', '1999-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 18, '学院副职', '科级', 7, '2002-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('张勇', 1, '1974-12-16', '汉族', '辽宁辽阳', '中共党员', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 18, '学院办公室主任', '科级', 8, '1997-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吕丽', 1, '1979-04-18', '汉族', '辽宁盘锦', '中共党员', '1998-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳师范大学', NULL, NULL, NULL, 18, '系/教研室主任', '科级', 3, '2008-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭秀兰', 1, '1997-01-26', '汉族', '辽宁本溪', '中共党员', '2023-06-01', '2023-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '燕山大学', NULL, NULL, NULL, 18, '系/教研室主任', '科级', 8, '2024-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭超', 2, '1996-12-09', '汉族', '辽宁锦州', '中共党员', '2018-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 18, '系/教研室副主任', '科级', 7, '2021-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓思琪', 1, '1989-12-20', '朝鲜族', '辽宁大连', '中共党员', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 18, '系/教研室副主任', '科级', 6, '2012-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖强', 1, '1993-04-27', '汉族', '吉林长春', '中共党员', '2014-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 18, '实验室负责人', '科级', 8, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('江杰', 1, '1984-06-23', '汉族', '辽宁盘锦', '中共党员', '2009-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 18, '教务干事', '科级', 3, '2018-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆敏', 1, '1983-10-27', '汉族', '辽宁鞍山', '中共党员', '2009-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '清华大学', NULL, NULL, NULL, 18, '专职教师', '科级', 8, '2010-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('李鑫磊', 1, '1985-11-17', '汉族', '辽宁葫芦岛', '民主党派', '2008-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '长春理工大学', NULL, NULL, NULL, 18, '专职教师', '科级', 8, '2021-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('彭红梅', 1, '1979-05-17', '朝鲜族', '辽宁本溪', '中共党员', '1997-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 18, '专职教师', '科级', 9, '2014-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贺志远', 2, '1984-03-21', '汉族', '辽宁盘锦', '群众', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 18, '专职教师', '科级', 6, '2013-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('宋玉芬', 1, '1960-01-14', '达斡尔族', '江苏南京', '中共党员', '1986-06-01', '1987-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北大学', NULL, NULL, NULL, 18, '专职教师', '科级', 3, '1995-02-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('秦丽娟', 1, '1993-03-20', '蒙古族', '辽宁锦州', '群众', '2011-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连海事大学', NULL, NULL, NULL, 18, '专职教师', '科级', 4, '2025-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('白浩然', 1, '1975-10-03', '汉族', '江苏南京', '群众', '1994-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 18, '专职教师', '科级', 3, '2011-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('王子涵', 1, '1997-01-01', '朝鲜族', '辽宁锦州', '群众', '2021-06-01', '2025-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京大学', NULL, NULL, NULL, 18, '专职教师', '科级', 8, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('闫娜', 1, '1998-12-21', '汉族', '辽宁本溪', '中共党员', '2016-06-01', '2024-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 18, '专职教师', '科级', 1, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谢丽', 1, '1964-06-26', '满族', '辽宁葫芦岛', '群众', '1983-06-01', '1984-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 18, '专职教师', '科级', 6, '1990-05-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('邹淑华', 2, '1976-07-22', '锡伯族', '辽宁营口', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 18, '专职教师', '科级', 7, '2004-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孟春生', 1, '1992-12-04', '汉族', '辽宁本溪', '群众', '2010-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 18, '专职教师', '科级', 8, '2025-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝永强', 1, '1981-04-05', '汉族', '辽宁鞍山', '群众', '2007-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳师范大学', NULL, NULL, NULL, 18, '专职教师', '科级', 4, '2018-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曾芳', 1, '1977-11-25', '达斡尔族', '山东青岛', '民主党派', '1999-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '清华大学', NULL, NULL, NULL, 18, '专职教师', '科级', 5, '2003-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('梁志明', 1, '1998-04-12', '达斡尔族', '辽宁盘锦', '群众', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 18, '专职教师', '科级', 5, '2023-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曾晓东', 2, '1985-03-14', '汉族', '辽宁辽阳', '中共党员', '2007-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 18, '专职教师', '科级', 3, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吴晓东', 2, '1982-08-23', '汉族', '河北石家庄', '中共党员', '2003-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 18, '专职教师', '科级', 6, '2022-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('蒋涛', 2, '1979-01-15', '汉族', '江苏南京', '群众', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 18, '专职教师', '科级', 9, '2014-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭鑫磊', 1, '1963-06-28', '锡伯族', '辽宁盘锦', '中共党员', '1982-06-01', '1986-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 18, '专职教师', '科级', 3, '1989-09-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('段一诺', 2, '1968-11-02', '汉族', '辽宁沈阳', '中共党员', '1988-06-01', '1988-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 19, '学院负责人', '处级', 6, '1999-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韩德明', 1, '1969-10-19', '回族', '辽宁盘锦', '民主党派', '1993-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京大学', NULL, NULL, NULL, 19, '学院党组织负责人', '处级', 8, '2000-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆敏', 1, '1975-07-04', '汉族', '黑龙江哈尔滨', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 19, '学院副职', '处级', 2, '2010-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('石欣', 1, '1974-10-14', '汉族', '辽宁鞍山', '群众', '1992-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁大学', NULL, NULL, NULL, 19, '学院副职', '处级', 6, '2007-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('秦佳琪', 2, '1975-05-19', '汉族', '辽宁铁岭', '中共党员', '1999-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北大学', NULL, NULL, NULL, 19, '学院副职', '科级', 3, '2006-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汪雨桐', 1, '1978-08-20', '蒙古族', '辽宁丹东', '中共党员', '1998-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 19, '学院办公室主任', '科级', 2, '2007-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汤红梅', 1, '1988-09-23', '汉族', '河南郑州', '中共党员', '2006-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 19, '系/教研室主任', '科级', 5, '2018-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚海涛', 1, '1987-10-17', '满族', '辽宁沈阳', '中共党员', '2008-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 19, '系/教研室主任', '科级', 8, '2011-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杜鑫', 1, '1987-11-09', '汉族', '辽宁葫芦岛', '民主党派', '2012-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 19, '系/教研室副主任', '科级', 1, '2016-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('向梓萱', 2, '1984-01-05', '回族', '吉林长春', '中共党员', '2004-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 19, '系/教研室副主任', '科级', 1, '2008-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('苏春雨', 2, '1993-04-17', '朝鲜族', '辽宁丹东', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 19, '实验室负责人', '科级', 1, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('方鑫', 1, '1994-04-02', '蒙古族', '辽宁阜新', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 19, '教务干事', '科级', 2, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('张志远', 1, '1982-08-20', '蒙古族', '辽宁辽阳', '中共党员', '2003-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连理工大学', NULL, NULL, NULL, 19, '专职教师', '科级', 6, '2014-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('万俊杰', 1, '1975-12-05', '汉族', '河北石家庄', '中共党员', '1993-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 19, '专职教师', '科级', 9, '2007-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('李思远', 1, '1992-01-10', '锡伯族', '辽宁葫芦岛', '中共党员', '2019-06-01', '2019-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 19, '专职教师', '科级', 6, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫桂英', 2, '1987-03-08', '汉族', '江苏南京', '群众', '2005-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 19, '专职教师', '科级', 4, '2014-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('赵军', 2, '1980-01-06', '汉族', '辽宁葫芦岛', '中共党员', '2002-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 19, '专职教师', '科级', 1, '2014-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖梓萱', 1, '1980-02-18', '锡伯族', '辽宁朝阳', '民主党派', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 19, '专职教师', '科级', 8, '2006-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汪洋', 2, '1980-12-17', '汉族', '江苏南京', '中共党员', '1999-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 19, '专职教师', '科级', 6, '2002-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('刘丽华', 1, '1997-04-03', '朝鲜族', '辽宁锦州', '群众', '2021-06-01', '2021-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 19, '专职教师', '科级', 6, '2025-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('方佳琪', 1, '1984-11-23', '汉族', '河北石家庄', '民主党派', '2007-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁师范大学', NULL, NULL, NULL, 19, '专职教师', '科级', 2, '2018-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('史娜', 1, '1991-01-21', '汉族', '辽宁营口', '民主党派', '2009-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 19, '专职教师', '科级', 2, '2021-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吴志远', 1, '1978-08-26', '达斡尔族', '辽宁铁岭', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 19, '专职教师', '科级', 4, '2004-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('许勇', 2, '1977-04-24', '蒙古族', '山东青岛', '中共党员', '1999-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 19, '专职教师', '科级', 2, '2009-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('何娜', 1, '1989-02-24', '达斡尔族', '吉林长春', '中共党员', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 19, '专职教师', '科级', 3, '2023-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('苏平', 1, '1998-09-16', '达斡尔族', '辽宁鞍山', '中共党员', '2021-06-01', '2021-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北财经大学', NULL, NULL, NULL, 19, '专职教师', '科级', 2, '2025-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('唐子涵', 2, '1962-12-02', '汉族', '辽宁丹东', '中共党员', '1983-06-01', '1986-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 19, '专职教师', '科级', 5, '1994-03-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('贺思琪', 2, '1977-04-19', '回族', '吉林长春', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 19, '专职教师', '科级', 6, '2001-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('潘欣', 1, '1989-10-06', '汉族', '辽宁锦州', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 19, '专职教师', '科级', 7, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('熊雪', 1, '1986-01-20', '朝鲜族', '辽宁朝阳', '中共党员', '2007-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 19, '专职教师', '科级', 5, '2010-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周宇航', 2, '1980-09-18', '汉族', '辽宁丹东', '群众', '2002-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 19, '专职教师', '科级', 7, '2012-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('朱雨泽', 1, '1995-01-26', '汉族', '辽宁盘锦', '中共党员', '2013-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 19, '专职教师', '科级', 5, '2019-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('金伟', 2, '1981-01-10', '回族', '辽宁本溪', '中共党员', '2002-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 19, '专职教师', '科级', 9, '2011-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('潘雪', 2, '1972-09-02', '朝鲜族', '辽宁葫芦岛', '中共党员', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 20, '学院负责人', '处级', 2, '1996-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('何超', 1, '1973-07-27', '汉族', '河南郑州', '中共党员', '1993-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 20, '学院党组织负责人', '处级', 7, '1996-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('唐霞', 1, '1974-02-28', '汉族', '辽宁抚顺', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京大学', NULL, NULL, NULL, 20, '学院副职', '处级', 3, '2007-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孙明辉', 1, '1970-08-02', '汉族', '辽宁阜新', '中共党员', '1993-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 20, '学院副职', '处级', 1, '2005-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谭建国', 1, '1971-05-11', '汉族', '江苏南京', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 20, '学院副职', '科级', 1, '2002-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钱晨曦', 1, '1971-08-20', '回族', '辽宁本溪', '中共党员', '1992-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '燕山大学', NULL, NULL, NULL, 20, '学院办公室主任', '科级', 8, '2005-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('萧靖宇', 1, '1979-08-22', '达斡尔族', '辽宁本溪', '群众', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 20, '系/教研室主任', '科级', 6, '2012-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邹淑华', 2, '1988-09-16', '汉族', '山东青岛', '中共党员', '2007-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 20, '系/教研室主任', '科级', 6, '2017-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('彭明', 1, '1987-01-10', '蒙古族', '辽宁盘锦', '中共党员', '2009-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 20, '系/教研室副主任', '科级', 9, '2013-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('夏桂英', 1, '1975-01-06', '汉族', '辽宁朝阳', '中共党员', '1998-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '长春理工大学', NULL, NULL, NULL, 20, '系/教研室副主任', '科级', 4, '2002-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陶静', 1, '1988-08-08', '锡伯族', '吉林长春', '民主党派', '2007-06-01', '2012-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '长春理工大学', NULL, NULL, NULL, 20, '实验室负责人', '科级', 3, '2020-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('龚晓东', 1, '1986-12-26', '汉族', '辽宁锦州', '民主党派', '2008-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 20, '教务干事', '科级', 2, '2017-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('罗国栋', 1, '1997-10-11', '汉族', '辽宁辽阳', '中共党员', '2025-06-01', '2025-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 20, '专职教师', '科级', 4, '2025-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('熊磊', 2, '1978-03-03', '汉族', '河南郑州', '民主党派', '1999-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 20, '专职教师', '科级', 1, '2015-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贾晨曦', 1, '1981-07-12', '汉族', '江苏南京', '中共党员', '2001-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 20, '专职教师', '科级', 7, '2016-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('付欣', 1, '1975-07-26', '回族', '辽宁鞍山', '群众', '1995-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 20, '专职教师', '科级', 8, '2007-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('武涛', 1, '1979-09-07', '蒙古族', '辽宁朝阳', '中共党员', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁工程技术大学', NULL, NULL, NULL, 20, '专职教师', '科级', 6, '2007-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝娟', 1, '1963-12-28', '达斡尔族', '辽宁辽阳', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '长春理工大学', NULL, NULL, NULL, 20, '专职教师', '科级', 6, '1995-08-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('蔡涛', 1, '1996-10-14', '锡伯族', '辽宁大连', '中共党员', '2020-06-01', '2022-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 20, '专职教师', '科级', 2, '2025-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韩志强', 2, '1979-12-10', '蒙古族', '辽宁鞍山', '中共党员', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 20, '专职教师', '科级', 2, '2005-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黄诗涵', 1, '1978-09-23', '汉族', '辽宁抚顺', '民主党派', '1996-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 20, '专职教师', '科级', 9, '2016-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周文博', 1, '1992-06-01', '汉族', '辽宁本溪', '中共党员', '2010-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 20, '专职教师', '科级', 5, '2020-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黄玉芬', 1, '1995-04-07', '满族', '辽宁鞍山', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁师范大学', NULL, NULL, NULL, 20, '专职教师', '科级', 6, '2025-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝桂英', 2, '1984-04-03', '锡伯族', '河北石家庄', '中共党员', '2010-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁师范大学', NULL, NULL, NULL, 20, '专职教师', '科级', 2, '2011-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周雨泽', 1, '1979-02-02', '汉族', '辽宁鞍山', '民主党派', '1998-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '华中科技大学', NULL, NULL, NULL, 20, '专职教师', '科级', 2, '2010-08-01', NULL, NULL, NULL, 'TRANSFERRED', NULL, NULL, NULL, NOW(), NOW()),
('覃秀兰', 1, '1977-01-09', '蒙古族', '河北石家庄', '民主党派', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 20, '专职教师', '科级', 8, '2000-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('张子涵', 1, '1975-01-27', '汉族', '辽宁本溪', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '西安交通大学', NULL, NULL, NULL, 20, '专职教师', '科级', 3, '2004-07-01', NULL, NULL, NULL, 'TRANSFERRED', NULL, NULL, NULL, NOW(), NOW()),
('武雨泽', 2, '1964-05-11', '回族', '辽宁本溪', '中共党员', '1985-06-01', '1988-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连理工大学', NULL, NULL, NULL, 20, '专职教师', '科级', 9, '1996-04-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('董娟', 1, '1995-07-03', '汉族', '辽宁朝阳', '中共党员', '2018-06-01', '2022-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 20, '专职教师', '科级', 8, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('胡娟', 1, '1974-11-04', '蒙古族', '辽宁盘锦', '中共党员', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 21, '学院负责人', '处级', 5, '1997-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孟雪', 1, '1978-09-08', '达斡尔族', '辽宁铁岭', '中共党员', '1998-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 21, '学院党组织负责人', '处级', 2, '2006-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('崔海涛', 1, '1969-06-07', '汉族', '辽宁鞍山', '中共党员', '1987-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 21, '学院副职', '处级', 8, '2005-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('徐洋', 1, '1978-05-21', '汉族', '辽宁阜新', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '华中科技大学', NULL, NULL, NULL, 21, '学院副职', '处级', 3, '2008-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('向玉芬', 2, '1977-10-05', '朝鲜族', '辽宁鞍山', '群众', '2005-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 21, '学院副职', '科级', 3, '2008-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝树', 1, '1968-06-19', '蒙古族', '吉林长春', '中共党员', '1993-06-01', '1993-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '华中科技大学', NULL, NULL, NULL, 21, '学院办公室主任', '科级', 9, '2002-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钱娜', 2, '1992-07-09', '汉族', '辽宁辽阳', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 21, '系/教研室主任', '科级', 7, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫子涵', 2, '1993-09-10', '汉族', '辽宁辽阳', '中共党员', '2019-06-01', '2021-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京大学', NULL, NULL, NULL, 21, '系/教研室主任', '科级', 2, '2025-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('潘雨桐', 1, '1985-12-23', '汉族', '江苏南京', '群众', '2005-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁工程技术大学', NULL, NULL, NULL, 21, '系/教研室副主任', '科级', 9, '2016-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陈鑫磊', 1, '1982-09-04', '汉族', '辽宁大连', '群众', '2006-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳师范大学', NULL, NULL, NULL, 21, '系/教研室副主任', '科级', 3, '2009-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('任芳', 2, '1997-09-09', '汉族', '辽宁盘锦', '中共党员', '2020-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '哈尔滨工业大学', NULL, NULL, NULL, 21, '实验室负责人', '科级', 2, '2023-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('朱文博', 1, '1987-02-06', '蒙古族', '辽宁丹东', '中共党员', '2008-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 21, '教务干事', '科级', 4, '2011-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('胡丽', 1, '1982-11-10', '汉族', '江苏南京', '中共党员', '2000-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 21, '专职教师', '科级', 8, '2010-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周鑫磊', 1, '1981-10-03', '汉族', '辽宁朝阳', '民主党派', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 21, '专职教师', '科级', 4, '2007-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚欣', 1, '1996-06-13', '达斡尔族', '辽宁丹东', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '吉林大学', NULL, NULL, NULL, 21, '专职教师', '科级', 9, '2025-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('魏俊杰', 2, '1984-07-08', '锡伯族', '辽宁大连', '中共党员', '2002-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '清华大学', NULL, NULL, NULL, 21, '专职教师', '科级', 1, '2020-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('薛刚', 2, '1990-04-06', '朝鲜族', '辽宁大连', '中共党员', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连理工大学', NULL, NULL, NULL, 21, '专职教师', '科级', 9, '2012-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吴浩然', 2, '1997-08-18', '汉族', '辽宁营口', '中共党员', '2019-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 21, '专职教师', '科级', 5, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姜志明', 1, '1988-05-05', '汉族', '吉林长春', '中共党员', '2008-06-01', '2012-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳农业大学', NULL, NULL, NULL, 21, '专职教师', '科级', 8, '2023-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖一诺', 1, '1980-02-23', '汉族', '辽宁辽阳', '中共党员', '2005-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁大学', NULL, NULL, NULL, 21, '专职教师', '科级', 7, '2014-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('黎靖宇', 2, '1983-08-02', '汉族', '河南郑州', '中共党员', '2008-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 21, '专职教师', '科级', 7, '2017-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝文静', 1, '1958-06-16', '汉族', '黑龙江哈尔滨', '中共党员', '1982-06-01', '1984-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 21, '专职教师', '科级', 6, '1988-02-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('陶子涵', 2, '1988-12-28', '汉族', '黑龙江哈尔滨', '民主党派', '2006-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 21, '专职教师', '科级', 4, '2015-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('段桂英', 1, '1978-07-26', '汉族', '辽宁锦州', '群众', '1998-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 21, '专职教师', '科级', 3, '2000-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('朱明辉', 1, '1985-05-26', '汉族', '辽宁辽阳', '中共党员', '2010-06-01', '2010-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连理工大学', NULL, NULL, NULL, 21, '专职教师', '科级', 6, '2021-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('江娟', 1, '1960-01-17', '汉族', '辽宁丹东', '中共党员', '1982-06-01', '1981-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 21, '专职教师', '科级', 6, '1987-06-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('李丽', 1, '1976-04-03', '汉族', '辽宁辽阳', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 21, '专职教师', '科级', 2, '2000-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('董健', 1, '1978-08-04', '满族', '吉林长春', '中共党员', '1999-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 21, '专职教师', '科级', 3, '2010-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('梁靖宇', 1, '1976-03-13', '蒙古族', '河北石家庄', '中共党员', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 22, '学院负责人', '处级', 3, '2009-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('闫超', 2, '1973-02-19', '汉族', '辽宁沈阳', '中共党员', '1995-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连理工大学', NULL, NULL, NULL, 22, '学院党组织负责人', '处级', 3, '2001-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('沈敏', 1, '1969-01-14', '汉族', '辽宁朝阳', '中共党员', '1992-06-01', '1992-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 22, '学院副职', '处级', 8, '2003-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('尹光辉', 1, '1974-03-26', '朝鲜族', '辽宁盘锦', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 22, '学院副职', '处级', 2, '2000-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('宋波', 2, '1972-05-07', '锡伯族', '吉林长春', '中共党员', '1995-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '长春理工大学', NULL, NULL, NULL, 22, '学院副职', '科级', 2, '2001-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姜丽华', 1, '1969-02-13', '汉族', '江苏南京', '民主党派', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连理工大学', NULL, NULL, NULL, 22, '学院办公室主任', '科级', 6, '1995-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫子涵', 1, '1958-08-24', '汉族', '辽宁朝阳', '中共党员', '1985-06-01', '1985-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '华中科技大学', NULL, NULL, NULL, 22, '系/教研室主任', '科级', 4, '1996-07-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('林敏', 2, '1976-12-26', '汉族', '辽宁营口', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 22, '系/教研室主任', '科级', 7, '2006-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚丽娟', 2, '1998-09-05', '朝鲜族', '辽宁锦州', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京大学', NULL, NULL, NULL, 22, '系/教研室副主任', '科级', 3, '2022-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('卢涛', 1, '1981-04-15', '汉族', '辽宁阜新', '中共党员', '2001-06-01', '2001-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '华中科技大学', NULL, NULL, NULL, 22, '系/教研室副主任', '科级', 7, '2006-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('段梓萱', 1, '1988-09-11', '汉族', '辽宁抚顺', '中共党员', '2009-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁工程技术大学', NULL, NULL, NULL, 22, '实验室负责人', '科级', 8, '2011-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('萧建国', 2, '1978-06-28', '汉族', '辽宁丹东', '群众', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 22, '教务干事', '科级', 4, '2003-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('赵刚', 2, '1989-05-22', '汉族', '辽宁阜新', '群众', '2008-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连理工大学', NULL, NULL, NULL, 22, '专职教师', '科级', 5, '2018-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('朱欣', 1, '1958-03-28', '满族', '辽宁朝阳', '民主党派', '1982-06-01', '1982-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '哈尔滨工业大学', NULL, NULL, NULL, 22, '专职教师', '科级', 5, '1986-08-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('夏雪', 2, '1998-06-04', '蒙古族', '辽宁抚顺', '中共党员', '2020-06-01', '2021-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '北京航空航天大学', NULL, NULL, NULL, 22, '专职教师', '科级', 1, '2025-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邹平', 1, '1991-09-16', '汉族', '辽宁本溪', '中共党员', '2011-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 22, '专职教师', '科级', 2, '2025-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('范红', 2, '1993-03-11', '蒙古族', '辽宁大连', '中共党员', '2014-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 22, '专职教师', '科级', 4, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杜丽华', 1, '1973-10-27', '锡伯族', '辽宁锦州', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁师范大学', NULL, NULL, NULL, 23, '学院负责人', '处级', 5, '2005-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汪俊杰', 2, '1977-08-25', '汉族', '河南郑州', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '长春理工大学', NULL, NULL, NULL, 23, '学院党组织负责人', '处级', 1, '2012-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韦思远', 1, '1969-06-24', '达斡尔族', '辽宁沈阳', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '哈尔滨工业大学', NULL, NULL, NULL, 23, '学院副职', '处级', 4, '1998-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贾军', 1, '1974-12-27', '锡伯族', '辽宁葫芦岛', '中共党员', '1995-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 23, '学院副职', '处级', 5, '2004-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('魏波', 1, '1972-08-02', '汉族', '辽宁鞍山', '中共党员', '1995-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 23, '学院副职', '科级', 3, '2007-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('何涛', 2, '1970-12-11', '汉族', '江苏南京', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '清华大学', NULL, NULL, NULL, 23, '学院办公室主任', '科级', 3, '2000-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吕波', 2, '1991-01-16', '回族', '辽宁营口', '中共党员', '2014-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 23, '系/教研室主任', '科级', 8, '2024-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('贺明', 1, '1976-07-04', '汉族', '辽宁锦州', '中共党员', '1995-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '长春理工大学', NULL, NULL, NULL, 23, '系/教研室主任', '科级', 7, '2001-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('莫娜', 2, '1986-10-28', '汉族', '辽宁本溪', '中共党员', '2009-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 23, '系/教研室副主任', '科级', 3, '2024-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('杜平', 1, '1998-10-08', '朝鲜族', '辽宁丹东', '民主党派', '2021-06-01', '2025-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 23, '系/教研室副主任', '科级', 3, '2025-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('张涛', 1, '1990-03-03', '汉族', '辽宁大连', '中共党员', '2012-06-01', '2012-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北大学', NULL, NULL, NULL, 23, '实验室负责人', '科级', 5, '2019-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周雨泽', 2, '1983-02-05', '汉族', '辽宁锦州', '中共党员', '2005-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 23, '教务干事', '科级', 9, '2012-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('闫晓东', 1, '1982-03-01', '汉族', '河南郑州', '中共党员', '2000-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京大学', NULL, NULL, NULL, 23, '专职教师', '科级', 3, '2014-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钟志强', 2, '1985-04-21', '蒙古族', '河南郑州', '中共党员', '2003-06-01', '2009-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 23, '专职教师', '科级', 9, '2012-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('范秀兰', 2, '1988-02-05', '达斡尔族', '辽宁葫芦岛', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 23, '专职教师', '科级', 5, '2018-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郭鑫磊', 1, '1985-05-02', '汉族', '山东青岛', '中共党员', '2004-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '吉林大学', NULL, NULL, NULL, 23, '专职教师', '科级', 3, '2015-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汪淑华', 1, '1991-01-25', '汉族', '辽宁葫芦岛', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 23, '专职教师', '科级', 3, '2018-09-01', NULL, NULL, NULL, 'TRANSFERRED', NULL, NULL, NULL, NOW(), NOW()),
('史桂英', 1, '1979-07-02', '汉族', '辽宁大连', '群众', '1997-06-01', '2006-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 23, '专职教师', '科级', 6, '2016-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('龙涛', 2, '1991-10-06', '汉族', '江苏南京', '中共党员', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '东北财经大学', NULL, NULL, NULL, 23, '专职教师', '科级', 6, '2024-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韩刚', 2, '1988-10-03', '汉族', '辽宁鞍山', '民主党派', '2012-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 23, '专职教师', '科级', 8, '2022-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郑丽华', 2, '1991-10-12', '汉族', '江苏南京', '中共党员', '2011-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 23, '专职教师', '科级', 9, '2021-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('林子涵', 1, '1991-12-10', '汉族', '吉林长春', '中共党员', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 23, '专职教师', '科级', 4, '2015-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('汪永强', 1, '1985-10-02', '汉族', '河北石家庄', '中共党员', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 23, '专职教师', '科级', 5, '2023-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('宋斌', 1, '1990-12-19', '汉族', '辽宁葫芦岛', '群众', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '燕山大学', NULL, NULL, NULL, 23, '专职教师', '科级', 2, '2019-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('金洋', 2, '1972-08-26', '满族', '辽宁阜新', '中共党员', '1995-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 24, '学院负责人', '处级', 5, '2010-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('叶伟', 2, '1972-02-05', '汉族', '辽宁葫芦岛', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 24, '学院党组织负责人', '处级', 8, '2005-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('宋雨桐', 1, '1973-10-19', '汉族', '辽宁朝阳', '中共党员', '1991-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '燕山大学', NULL, NULL, NULL, 24, '学院副职', '处级', 5, '2009-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('石超', 2, '1974-07-13', '汉族', '辽宁辽阳', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 24, '学院副职', '处级', 9, '2003-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚鑫磊', 2, '1977-08-19', '汉族', '辽宁铁岭', '民主党派', '1997-06-01', '1997-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京大学', NULL, NULL, NULL, 24, '学院副职', '科级', 4, '2001-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('江军', 2, '1974-05-13', '朝鲜族', '辽宁铁岭', '中共党员', '1999-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁师范大学', NULL, NULL, NULL, 24, '学院办公室主任', '科级', 9, '2009-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆艳', 1, '1992-09-24', '汉族', '山东青岛', '群众', '2016-06-01', '2020-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '华中科技大学', NULL, NULL, NULL, 24, '系/教研室主任', '科级', 2, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('潘娜', 1, '1976-03-15', '汉族', '辽宁葫芦岛', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '大连理工大学', NULL, NULL, NULL, 24, '系/教研室主任', '科级', 7, '2000-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('武明辉', 1, '1982-03-27', '汉族', '辽宁本溪', '民主党派', '2003-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '哈尔滨工业大学', NULL, NULL, NULL, 24, '系/教研室副主任', '科级', 4, '2013-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('钱丽华', 1, '1977-01-13', '汉族', '辽宁锦州', '中共党员', '2005-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 24, '系/教研室副主任', '科级', 3, '2013-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('叶子涵', 1, '1992-07-01', '朝鲜族', '辽宁大连', '中共党员', '2010-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 24, '实验室负责人', '科级', 8, '2019-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('余明辉', 2, '1993-09-14', '汉族', '河北石家庄', '群众', '2018-06-01', '2019-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连理工大学', NULL, NULL, NULL, 24, '教务干事', '科级', 1, '2025-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('田诗涵', 1, '1985-03-27', '蒙古族', '辽宁锦州', '中共党员', '2009-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁大学', NULL, NULL, NULL, 24, '专职教师', '科级', 8, '2017-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郝志远', 2, '1989-05-22', '汉族', '辽宁丹东', '群众', '2011-06-01', '2011-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '长春理工大学', NULL, NULL, NULL, 24, '专职教师', '科级', 3, '2023-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('高晨曦', 2, '1994-01-17', '回族', '辽宁沈阳', '中共党员', '2018-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '吉林大学', NULL, NULL, NULL, 24, '专职教师', '科级', 5, '2025-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('向建国', 2, '1968-12-25', '汉族', '辽宁辽阳', '中共党员', '1990-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳师范大学', NULL, NULL, NULL, 25, '学院负责人', '处级', 8, '2007-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('梁春生', 2, '1978-08-09', '汉族', '辽宁鞍山', '中共党员', '2003-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '长春理工大学', NULL, NULL, NULL, 25, '学院党组织负责人', '处级', 6, '2006-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('萧明', 1, '1971-04-23', '汉族', '辽宁辽阳', '中共党员', '1996-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁师范大学', NULL, NULL, NULL, 25, '学院副职', '处级', 7, '2000-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邱勇', 2, '1975-11-28', '汉族', '辽宁铁岭', '中共党员', '2000-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 25, '学院副职', '处级', 3, '2003-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('卢欣怡', 1, '1977-11-23', '达斡尔族', '辽宁沈阳', '中共党员', '1999-06-01', '2005-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '燕山大学', NULL, NULL, NULL, 25, '学院副职', '科级', 3, '2010-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('罗明辉', 1, '1968-06-25', '锡伯族', '辽宁抚顺', '中共党员', '1988-06-01', '1996-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁大学', NULL, NULL, NULL, 25, '学院办公室主任', '科级', 8, '2003-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('曾红', 2, '1993-07-26', '汉族', '辽宁大连', '中共党员', '2014-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁工程技术大学', NULL, NULL, NULL, 25, '系/教研室主任', '科级', 2, '2021-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周敏', 2, '1994-06-12', '汉族', '辽宁本溪', '中共党员', '2016-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳建筑大学', NULL, NULL, NULL, 25, '系/教研室主任', '科级', 6, '2025-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孔树', 2, '1959-07-07', '汉族', '江苏南京', '民主党派', '1982-06-01', '1980-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 25, '系/教研室副主任', '科级', 1, '1981-08-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('石国栋', 1, '1991-03-15', '汉族', '辽宁锦州', '中共党员', '2015-06-01', '2019-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁大学', NULL, NULL, NULL, 25, '系/教研室副主任', '科级', 2, '2022-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('范娜', 1, '1998-04-03', '汉族', '辽宁抚顺', '中共党员', '2016-06-01', '2024-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 25, '实验室负责人', '科级', 2, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('薛伟', 1, '1993-03-08', '汉族', '辽宁抚顺', '中共党员', '2016-06-01', '2016-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '清华大学', NULL, NULL, NULL, 25, '教务干事', '科级', 7, '2024-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('郑娜', 2, '1992-09-01', '汉族', '河南郑州', '群众', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '哈尔滨工业大学', NULL, NULL, NULL, 25, '专职教师', '科级', 4, '2025-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('韩丽娟', 1, '1988-06-26', '锡伯族', '辽宁鞍山', '中共党员', '2015-06-01', '2015-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '西安交通大学', NULL, NULL, NULL, 25, '专职教师', '科级', 5, '2023-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖晓东', 1, '1986-12-17', '汉族', '辽宁大连', '中共党员', '2007-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳工业大学', NULL, NULL, NULL, 25, '专职教师', '科级', 1, '2015-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邱春雨', 2, '1990-10-13', '汉族', '辽宁阜新', '中共党员', '2013-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳工业大学', NULL, NULL, NULL, 25, '专职教师', '科级', 6, '2025-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陈波', 1, '1978-05-05', '汉族', '辽宁本溪', '群众', '1996-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 25, '专职教师', '科级', 6, '2010-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('吕红', 1, '1983-05-24', '锡伯族', '河北石家庄', '中共党员', '2008-06-01', '2008-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳师范大学', NULL, NULL, NULL, 25, '专职教师', '科级', 7, '2009-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('魏丽', 1, '1986-06-22', '达斡尔族', '辽宁本溪', '中共党员', '2006-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '大连海事大学', NULL, NULL, NULL, 25, '专职教师', '科级', 9, '2025-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姜勇', 2, '1991-11-16', '朝鲜族', '辽宁辽阳', '中共党员', '2014-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '吉林大学', NULL, NULL, NULL, 25, '专职教师', '科级', 3, '2025-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邵洋', 1, '1976-05-13', '汉族', '辽宁朝阳', '中共党员', '1996-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '西安交通大学', NULL, NULL, NULL, 25, '专职教师', '科级', 5, '2011-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('姚杰', 1, '1997-07-27', '汉族', '辽宁丹东', '中共党员', '2019-06-01', '2019-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北财经大学', NULL, NULL, NULL, 25, '专职教师', '科级', 6, '2022-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('孔芳', 2, '1981-12-20', '锡伯族', '辽宁丹东', '中共党员', '2002-06-01', '2002-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 25, '专职教师', '科级', 4, '2013-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('王文静', 1, '1975-03-26', '汉族', '黑龙江哈尔滨', '民主党派', '1999-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '沈阳农业大学', NULL, NULL, NULL, 25, '专职教师', '科级', 5, '2003-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陆洋', 2, '1967-12-10', '蒙古族', '吉林长春', '中共党员', '1992-06-01', '1992-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '辽宁大学', NULL, NULL, NULL, 26, '部门负责人', '处级', 8, '1999-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('袁艳', 2, '1967-09-09', '汉族', '辽宁锦州', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 26, '部门副职', '处级', 2, '1996-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周红', 2, '1973-08-15', '锡伯族', '辽宁营口', '中共党员', '1994-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳建筑大学', NULL, NULL, NULL, 26, '部门副职', '科级', 3, '2006-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('薛洋', 2, '1974-05-11', '达斡尔族', '吉林长春', '中共党员', '1994-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '沈阳建筑大学', NULL, NULL, NULL, 26, '科室负责人', '科级', 5, '2003-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('万佳琪', 2, '1970-12-16', '满族', '黑龙江哈尔滨', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '北京航空航天大学', NULL, NULL, NULL, 26, '科室负责人', '科级', 3, '1999-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('廖光辉', 1, '1970-11-22', '汉族', '吉林长春', '中共党员', '1990-06-01', '1990-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '燕山大学', NULL, NULL, NULL, 26, '科室副职', '科级', 1, '1991-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('余春雨', 1, '1986-02-01', '汉族', '河北石家庄', '群众', '2013-06-01', '2013-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 26, '科室副职', '科级', 8, '2024-05-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('马明辉', 2, '1973-05-05', '蒙古族', '辽宁铁岭', '中共党员', '1999-06-01', '1999-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '西安交通大学', NULL, NULL, NULL, 26, '管理员', '科级', 5, '2011-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('谢勇', 1, '1983-05-20', '达斡尔族', '河南郑州', '民主党派', '2004-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京大学', NULL, NULL, NULL, 26, '管理员', '科级', 6, '2016-05-01', NULL, NULL, NULL, 'TRANSFERRED', NULL, NULL, NULL, NOW(), NOW()),
('廖梓萱', 1, '1988-11-16', '达斡尔族', '辽宁铁岭', '群众', '2006-06-01', '2014-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '东北大学', NULL, NULL, NULL, 26, '管理员', '科级', 7, '2016-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('李玉芬', 2, '1958-11-01', '达斡尔族', '吉林长春', '中共党员', '1982-06-01', '1980-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 26, '管理员', '科级', 7, '1984-08-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW()),
('江娜', 2, '1978-06-09', '蒙古族', '辽宁抚顺', '中共党员', '1998-06-01', '1998-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁大学', NULL, NULL, NULL, 26, '管理员', '科级', 2, '2003-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('周勇', 1, '1995-06-11', '汉族', '辽宁辽阳', '中共党员', '2017-06-01', '2018-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '东北财经大学', NULL, NULL, NULL, 26, '管理员', '科级', 2, '2024-03-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('陶刚', 2, '1994-12-22', '汉族', '江苏南京', '中共党员', '2015-06-01', '2017-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '哈尔滨工业大学', NULL, NULL, NULL, 26, '管理员', '科级', 9, '2025-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('金健', 1, '1983-08-15', '锡伯族', '辽宁大连', '中共党员', '2007-06-01', '2007-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '长春理工大学', NULL, NULL, NULL, 26, '管理员', '科级', 8, '2019-04-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('宋秀兰', 2, '1969-06-07', '汉族', '辽宁阜新', '中共党员', '1989-06-01', '1989-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '吉林大学', NULL, NULL, NULL, 27, '部门负责人', '处级', 9, '2000-02-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('李思琪', 1, '1970-06-20', '汉族', '辽宁锦州', '中共党员', '1991-06-01', '1991-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳农业大学', NULL, NULL, NULL, 27, '部门副职', '处级', 9, '1992-08-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('雷志远', 2, '1974-05-11', '汉族', '辽宁丹东', '群众', '1993-06-01', '1995-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连理工大学', NULL, NULL, NULL, 27, '部门副职', '科级', 2, '2001-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('沈波', 2, '1969-05-02', '达斡尔族', '黑龙江哈尔滨', '民主党派', '1987-06-01', '1994-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '沈阳工业大学', NULL, NULL, NULL, 27, '科室负责人', '科级', 2, '1997-07-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('侯丽娟', 1, '1975-04-05', '汉族', '辽宁阜新', '中共党员', '1996-06-01', '2003-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '华中科技大学', NULL, NULL, NULL, 27, '科室负责人', '科级', 7, '2013-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('马平', 1, '1973-04-25', '汉族', '辽宁葫芦岛', '中共党员', '1996-06-01', '2000-07-01', NULL, NULL, NULL, NULL, NULL, '硕士研究生', '硕士', '辽宁大学', NULL, NULL, NULL, 27, '科室副职', '科级', 8, '2009-06-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('邓子涵', 1, '1977-01-13', '朝鲜族', '辽宁阜新', '中共党员', '1995-06-01', '2004-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '辽宁工程技术大学', NULL, NULL, NULL, 27, '科室副职', '科级', 1, '2008-01-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW()),
('尹佳琪', 1, '1960-12-05', '汉族', '山东青岛', '中共党员', '1987-06-01', '1988-07-01', NULL, NULL, NULL, NULL, NULL, '博士研究生', '博士', '大连海事大学', NULL, NULL, NULL, 27, '管理员', '科级', 1, '1993-07-01', NULL, NULL, NULL, 'RETIRED', NULL, NULL, NULL, NOW(), NOW());

SET FOREIGN_KEY_CHECKS=1;
-- 干部数：480


-- ============================================================
-- 考核管理与日常事务演示数据（全部虚构，可重复执行）
-- 状态值与后端服务保持一致：
--   方案 草稿/进行中/已关闭；休假 待审批/已批准/已驳回；
--   证照 在库/在借/已归还；培训 未开始/进行中/已完成；
--   挂职 未开始/挂职中/已结束；自助申报 DRAFT/SUBMITTED/APPROVED/REJECTED
-- ============================================================
USE POP;

-- 清理旧演示数据（幂等）
DELETE FROM assessment_signature; DELETE FROM assessment_ballot; DELETE FROM assessment_vote;
DELETE FROM assessment_target; DELETE FROM assessment_indicator;
DELETE FROM assessment_dimension; DELETE FROM assessment_scheme; DELETE FROM assessment_annual;
DELETE FROM daily_training_cadre; DELETE FROM daily_training; DELETE FROM daily_certificate;
DELETE FROM daily_abroad_record; DELETE FROM daily_leave; DELETE FROM daily_secondment;
DELETE FROM daily_self_application;

-- ---------- 演示用户（用于 sys_user↔cadre_info 绑定 / 投票 / 自助申报） ----------
SET @cadre_qin := (SELECT id FROM cadre_info WHERE name = '秦霞' LIMIT 1);
SET @cadre_cao := (SELECT id FROM cadre_info WHERE name = '蔡浩然' LIMIT 1);

INSERT INTO sys_user (username, password, real_name, email, phone, user_type, status, dept_id, cadre_id, permissions, create_time, update_time)
SELECT 'qinxia', '123456', '秦霞', 'qinxia@demo.lnut.edu.cn', '13800000021', 6, 1, 2, @cadre_qin, '', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username = 'qinxia');

INSERT INTO sys_user (username, password, real_name, email, phone, user_type, status, dept_id, cadre_id, permissions, create_time, update_time)
SELECT 'caohaoran', '123456', '蔡浩然', 'caohaoran@demo.lnut.edu.cn', '13800000022', 3, 1, 2, @cadre_cao, 'organization,cadre,transfer,promotion,appointment,evaluation,supervision,assessment,daily', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username = 'caohaoran');

SET @u_admin := (SELECT id FROM sys_user WHERE username = 'admin' LIMIT 1);
SET @u_qin   := (SELECT id FROM sys_user WHERE username = 'qinxia' LIMIT 1);
SET @u_cao   := (SELECT id FROM sys_user WHERE username = 'caohaoran' LIMIT 1);

-- 干部数据重灌后 ID 会变化，同步修正演示用户绑定
UPDATE sys_user SET cadre_id = @cadre_qin WHERE username = 'qinxia';
UPDATE sys_user SET cadre_id = @cadre_cao WHERE username = 'caohaoran';

-- ---------- 干部档案引用 ----------
SET @c_gu   := (SELECT id FROM cadre_info WHERE name = '顾晓东' LIMIT 1);
SET @c_deng := (SELECT id FROM cadre_info WHERE name = '邓秀兰' LIMIT 1);
SET @c_hu   := (SELECT id FROM cadre_info WHERE name = '胡红' LIMIT 1);
SET @c_wan  := (SELECT id FROM cadre_info WHERE name = '万娟' LIMIT 1);
SET @c_li   := (SELECT id FROM cadre_info WHERE name = '黎志明' LIMIT 1);
SET @c_cao  := (SELECT id FROM cadre_info WHERE name = '蔡浩然' LIMIT 1);
SET @c_lin  := (SELECT id FROM cadre_info WHERE name = '林雨桐' LIMIT 1);
SET @c_qin  := (SELECT id FROM cadre_info WHERE name = '秦霞' LIMIT 1);

-- ---------- 年度考核记录（档案考核记录来源） ----------
INSERT INTO assessment_annual (cadre_id, assessment_year, assessment_result, assessment_comment, create_by, create_time) VALUES
(@c_cao, '2024', '优秀',   '工作实绩突出，群众公认度高（示例）', @u_admin, NOW()),
(@c_cao, '2025', '称职',   '履职总体良好（示例）', @u_admin, NOW()),
(@c_lin, '2024', '称职',   '按期完成各项工作任务（示例）', @u_admin, NOW()),
(@c_lin, '2025', '优秀',   '牵头的重点工作成效明显（示例）', @u_admin, NOW()),
(@c_qin, '2025', '称职',   '业务能力扎实（示例）', @u_admin, NOW()),
(@c_gu,  '2025', '优秀',   '统筹谋划能力强（示例）', @u_admin, NOW()),
(@c_deng,'2025', '基本称职', '年度重点工作推进不够有力（示例）', @u_admin, NOW()),
(@c_hu,  '2024', '称职',   '工作作风务实（示例）', @u_admin, NOW()),
(@c_wan, '2025', '不称职', '存在履职不到位情形（示例）', @u_admin, NOW());

-- 档案 annual_assessment 回写镜像（与后端“年度考核保存时回写”一致，供晋升/任免/后备等考核核验使用）
UPDATE cadre_info c JOIN (
  SELECT cadre_id, GROUP_CONCAT(CONCAT(assessment_year, ':', assessment_result) ORDER BY assessment_year SEPARATOR ';') v
  FROM assessment_annual GROUP BY cadre_id
) a ON a.cadre_id = c.id
SET c.annual_assessment = a.v;

-- ---------- 测评方案 ----------
INSERT INTO assessment_scheme (scheme_name, scheme_year, vote_start_time, vote_end_time, allow_anonymous, excellent_max_ratio, forbid_all_excellent, status, create_by, create_time) VALUES
('2025年度中层干部民主测评', '2025', '2025-12-01 08:00:00', '2025-12-20 18:00:00', 1, 30.00, 1, '已关闭', @u_admin, NOW()),
('2026年中层干部民主测评',   '2026', '2026-09-01 08:00:00', '2026-09-30 18:00:00', 1, 30.00, 1, '进行中', @u_admin, NOW()),
('2026年新提拔干部试用期满测评', '2026', NULL, NULL, 1, 30.00, 1, '草稿', @u_admin, NOW());

SET @sch_done := (SELECT id FROM assessment_scheme WHERE scheme_name = '2025年度中层干部民主测评' LIMIT 1);
SET @sch_now  := (SELECT id FROM assessment_scheme WHERE scheme_name = '2026年中层干部民主测评' LIMIT 1);
SET @sch_draft:= (SELECT id FROM assessment_scheme WHERE scheme_name = '2026年新提拔干部试用期满测评' LIMIT 1);

-- ---------- 维度/指标模板（德能勤绩廉，满分100） ----------
INSERT INTO assessment_dimension (scheme_id, dimension_name, dimension_weight, sort_order) VALUES
(@sch_done, '德', 25.00, 1), (@sch_done, '能', 25.00, 2), (@sch_done, '勤', 20.00, 3),
(@sch_done, '绩', 20.00, 4), (@sch_done, '廉', 10.00, 5),
(@sch_now,  '德', 25.00, 1), (@sch_now,  '能', 25.00, 2), (@sch_now,  '勤', 20.00, 3),
(@sch_now,  '绩', 20.00, 4), (@sch_now,  '廉', 10.00, 5);

SET @dim_d_de  := (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_done AND dimension_name = '德' LIMIT 1);
SET @dim_d_neng:= (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_done AND dimension_name = '能' LIMIT 1);
SET @dim_d_qin := (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_done AND dimension_name = '勤' LIMIT 1);
SET @dim_d_ji  := (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_done AND dimension_name = '绩' LIMIT 1);
SET @dim_d_lian:= (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_done AND dimension_name = '廉' LIMIT 1);

INSERT INTO assessment_indicator (dimension_id, indicator_name, max_score, sort_order) VALUES
(@dim_d_de,   '政治品质', 12.50, 1), (@dim_d_de,   '职业道德', 12.50, 2),
(@dim_d_neng, '业务能力', 12.50, 1), (@dim_d_neng, '组织协调能力', 12.50, 2),
(@dim_d_qin,  '工作态度', 10.00, 1), (@dim_d_qin,  '敬业精神', 10.00, 2),
(@dim_d_ji,   '工作实绩', 10.00, 1), (@dim_d_ji,   '工作效能', 10.00, 2),
(@dim_d_lian, '廉洁自律', 10.00, 1);

SET @dim_n_de  := (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_now AND dimension_name = '德' LIMIT 1);
SET @dim_n_neng:= (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_now AND dimension_name = '能' LIMIT 1);
SET @dim_n_qin := (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_now AND dimension_name = '勤' LIMIT 1);
SET @dim_n_ji  := (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_now AND dimension_name = '绩' LIMIT 1);
SET @dim_n_lian:= (SELECT id FROM assessment_dimension WHERE scheme_id = @sch_now AND dimension_name = '廉' LIMIT 1);

INSERT INTO assessment_indicator (dimension_id, indicator_name, max_score, sort_order) VALUES
(@dim_n_de,   '政治品质', 12.50, 1), (@dim_n_de,   '职业道德', 12.50, 2),
(@dim_n_neng, '业务能力', 12.50, 1), (@dim_n_neng, '组织协调能力', 12.50, 2),
(@dim_n_qin,  '工作态度', 10.00, 1), (@dim_n_qin,  '敬业精神', 10.00, 2),
(@dim_n_ji,   '工作实绩', 10.00, 1), (@dim_n_ji,   '工作效能', 10.00, 2),
(@dim_n_lian, '廉洁自律', 10.00, 1);

-- ---------- 测评对象 ----------
INSERT INTO assessment_target (scheme_id, cadre_id) VALUES
(@sch_done, @c_cao), (@sch_done, @c_lin), (@sch_done, @c_qin),
(@sch_now,  @c_cao), (@sch_now,  @c_lin), (@sch_now,  @c_gu);

-- ---------- 投票计票（已关闭方案的投票记录，评分不超各指标满分） ----------
INSERT INTO assessment_vote (scheme_id, voter_id, target_cadre_id, indicator_id, score, vote_time)
SELECT s.id, u.id, t.cadre_id, i.id,
       CASE WHEN i.max_score >= 12 THEN 11.00 ELSE 9.00 END,
       '2025-12-15 10:00:00'
FROM (SELECT @sch_done AS id) s
CROSS JOIN (SELECT @u_admin AS id UNION ALL SELECT @u_qin UNION ALL SELECT @u_cao) u
CROSS JOIN (SELECT cadre_id FROM assessment_target WHERE scheme_id = @sch_done) t
CROSS JOIN (SELECT i.id, i.max_score FROM assessment_indicator i
            JOIN assessment_dimension d ON i.dimension_id = d.id
            WHERE d.scheme_id = @sch_done) i;

-- ---------- 证照管理 ----------
INSERT INTO daily_certificate (cadre_id, cert_type, cert_number, cert_status, borrow_date, return_date, expected_return_date, remark, create_by, create_time) VALUES
(@c_cao, '护照',       'DEMO-E88001234', '在库',   NULL,          NULL,          NULL,          '集中保管（示例）', @u_admin, NOW()),
(@c_lin, '港澳通行证', 'DEMO-W12345678', '在借',   '2026-09-08',  NULL,          '2026-09-15',  '因公赴香港学术交流获批，行程期间临时领用（示例）', @u_admin, NOW()),
(@c_qin, '护照',       'DEMO-E88005678', '已归还', '2026-05-10',  '2026-06-05',  '2026-06-10',  '已按期归还（示例）', @u_admin, NOW()),
(@c_gu,  '其他',       'DEMO-G00011122', '在库',   NULL,          NULL,          NULL,          '工作证件（示例）', @u_admin, NOW());

-- ---------- 出境记录 ----------
INSERT INTO daily_abroad_record (cadre_id, destination, purpose, depart_date, return_date, approved_days, actual_days, is_overdue, create_by, create_time) VALUES
(@c_gu,  '新加坡', '公务出访', '2026-05-10', '2026-05-17', 8,  8,  0, @u_admin, NOW()),
(@c_cao, '日本',   '学术交流', '2026-06-01', '2026-06-12', 10, 12, 1, @u_admin, NOW()),
(@c_lin, '中国香港', '学术交流', '2026-09-10', '2026-09-14', 5,  NULL, 0, @u_admin, NOW()),
(@c_lin, '中国香港', '探亲',   '2025-10-01', '2025-10-08', 7,  7,  0, @u_admin, NOW());

-- 在借证照关联其对应的已批准出境记录（出境记录 → 证照领用 联动）
UPDATE daily_certificate c
JOIN daily_abroad_record r ON r.cadre_id = c.cadre_id AND r.is_approved = 1
   AND r.depart_date >= c.borrow_date AND c.borrow_date IS NOT NULL
SET c.abroad_id = r.id
WHERE c.cert_status = '在借' AND c.abroad_id IS NULL;

-- ---------- 休假台账 ----------
INSERT INTO daily_leave (cadre_id, leave_type, start_date, end_date, leave_days, reason, approve_status, approve_id, approve_time, create_by, create_time) VALUES
(@c_qin, '年休假', '2026-07-06', '2026-07-10', 5.0, '暑期休整（示例）', '已批准', @u_admin, '2026-07-01 09:30:00', @u_admin, NOW()),
(@c_cao, '病假',   '2026-08-12', '2026-08-14', 3.0, '身体不适就医（示例）', '待审批', NULL, NULL, @u_admin, NOW()),
(@c_lin, '事假',   '2026-09-03', '2026-09-04', 2.0, '家庭事务（示例）', '待审批', NULL, NULL, @u_admin, NOW()),
(@c_hu,  '年休假', '2026-08-20', '2026-08-24', 5.0, '与学校暑期重合（示例）', '已驳回', @u_admin, '2026-08-15 14:00:00', @u_admin, NOW());

-- ---------- 教育培训 ----------
INSERT INTO daily_training (training_name, training_type, start_date, end_date, training_location, organizer, description, status, create_by, create_time) VALUES
('全校中层干部专题培训班', '党校培训', '2026-04-13', '2026-04-17', '校党校教室', '党委组织部', '政治理论与履职能力专题学习（示例）', '已完成', @u_admin, NOW()),
('新任职干部履职能力提升班', '业务培训', '2026-09-14', '2026-09-18', '校内报告厅', '人事处', '新任职干部岗位适应与业务规范培训（示例）', '未开始', @u_admin, NOW()),
('干部网络专题学习', '在线学习', '2026-06-01', '2026-08-31', '线上', '党委组织部', '专题网络课程学习（示例）', '进行中', @u_admin, NOW());

SET @tr_done := (SELECT id FROM daily_training WHERE training_name = '全校中层干部专题培训班' LIMIT 1);
SET @tr_new  := (SELECT id FROM daily_training WHERE training_name = '新任职干部履职能力提升班' LIMIT 1);
SET @tr_on   := (SELECT id FROM daily_training WHERE training_name = '干部网络专题学习' LIMIT 1);

INSERT INTO daily_training_cadre (training_id, cadre_id, is_completed, certificate_url) VALUES
(@tr_done, @c_gu,  1, NULL), (@tr_done, @c_cao, 1, NULL), (@tr_done, @c_lin, 1, NULL), (@tr_done, @c_qin, 1, NULL),
(@tr_new,  @c_cao, 0, NULL), (@tr_new,  @c_lin, 0, NULL),
(@tr_on,   @c_qin, 0, NULL), (@tr_on,   @c_hu,  0, NULL);

-- ---------- 挂职锻炼 ----------
INSERT INTO daily_secondment (cadre_id, secondment_unit, secondment_position, start_date, end_date, status, remark, create_by, create_time) VALUES
(@c_qin, '省属高校组织部门（示例）', '挂职干部（示例）', '2026-03-01', '2027-02-28', '挂职中', '组织系统挂职锻炼（示例）', @u_admin, NOW()),
(@c_cao, '地方政府部门（示例）',     '挂职干部（示例）', '2024-03-01', '2025-02-28', '已结束', '期满考核合格（示例）', @u_admin, NOW()),
(@c_lin, '上级机关业务处室（示例）', '跟班学习（示例）', '2026-10-01', '2027-03-31', '未开始', '待报到（示例）', @u_admin, NOW());

-- ---------- 干部自助申报 ----------
-- 首条为「档案信息更正」结构化申报：apply_field 白名单(education=最高学历/full_time_education)，
-- old_value 取干部档案真实值(本科)，new_value 硕士研究生；审批通过后由后端自动回写 cadre_info
INSERT INTO daily_self_application (applicant_id, application_type, application_title, application_content, apply_field, old_value, new_value, apply_status, approver_id, approve_time, approve_comment, create_by, create_time) VALUES
(@u_qin, 'INFO_UPDATE', '档案信息更正-最高学历', '【档案信息更正】最高学历：本科 → 硕士研究生（示例，审批通过后自动更新档案）。', 'education', '本科', '硕士研究生', 'SUBMITTED', NULL, NULL, NULL, @u_qin, NOW()),
(@u_cao, 'LEAVE', '9月中旬年休假申请', '拟于9月14日至9月16日休年休假3天，期间工作已安排交接（示例）。', NULL, NULL, NULL, 'APPROVED', @u_admin, '2026-09-02 10:00:00', '同意，注意工作衔接（示例）', @u_cao, NOW()),
(@u_qin, 'PART_TIME', '校外学会兼职备案', '拟兼任省XX学会理事，按学校规定申请备案（示例）。', NULL, NULL, NULL, 'REJECTED', @u_admin, '2026-08-28 15:30:00', '按学校兼职管理暂行规定暂不予备案（示例）', @u_qin, NOW()),
(@u_cao, 'TRAINING', '报名参加高校干部专题培训班', '申请参加本期专题培训班，学习计划已列入年度安排（示例）。', NULL, NULL, NULL, 'DRAFT', NULL, NULL, NULL, @u_cao, NOW());

-- 考核与日常事务演示数据：方案3、维度10、指标18、对象6、投票若干、年度考核9、
-- 证照4、出境3、休假4、培训3（学员8）、挂职3、自助申报4

-- ============================================================
-- 平板评审：表决式(BALLOT)投票 + 签字留证 演示数据
-- 说明：新增的表决式方案无需维度/指标（BALLOT 不做打分），测评对象挂载
--       任职表决材料（material_title/material_text，全部为虚构内容示例）
-- ============================================================

-- 既有评分式方案补充标记：默认评分式(SCORE)且需签字
UPDATE assessment_scheme SET vote_mode = 'SCORE', need_sign = 1 WHERE vote_mode IS NULL OR vote_mode = '';

-- 表决式演示方案涉及的干部（与上面干部档案重复引用时保持一致）
SET @c_szx := (SELECT id FROM cadre_info WHERE name = '宋梓萱' LIMIT 1);
SET @c_lht := (SELECT id FROM cadre_info WHERE name = '陆海涛' LIMIT 1);
SET @c_qjw := (SELECT id FROM cadre_info WHERE name = '钱嘉伟' LIMIT 1);

-- 幂等：重复执行时先清理表决式演示方案及其数据
DELETE FROM assessment_ballot WHERE scheme_id = (SELECT id FROM assessment_scheme WHERE scheme_name = '2026年第二批处级岗位民主表决' LIMIT 1);
DELETE FROM assessment_target WHERE scheme_id = (SELECT id FROM assessment_scheme WHERE scheme_name = '2026年第二批处级岗位民主表决' LIMIT 1);
DELETE FROM assessment_signature WHERE scheme_id = (SELECT id FROM assessment_scheme WHERE scheme_name = '2026年第二批处级岗位民主表决' LIMIT 1);
DELETE FROM assessment_scheme WHERE scheme_name = '2026年第二批处级岗位民主表决';

-- 表决式"进行中"演示方案
INSERT INTO assessment_scheme (scheme_name, scheme_year, vote_start_time, vote_end_time, allow_anonymous, excellent_max_ratio, forbid_all_excellent, vote_mode, need_sign, status, create_by, create_time) VALUES
('2026年第二批处级岗位民主表决', '2026', '2026-09-01 08:00:00', '2026-09-30 18:00:00', 1, 30.00, 1, 'BALLOT', 1, '进行中', @u_admin, NOW());

SET @sch_ballot := (SELECT id FROM assessment_scheme WHERE scheme_name = '2026年第二批处级岗位民主表决' LIMIT 1);

-- 测评对象 + 任职表决材料（均为虚构示例）
INSERT INTO assessment_target (scheme_id, cadre_id, material_title, material_text) VALUES
(@sch_ballot, @c_szx, '宋梓萱同志任职情况简介（示例）', '宋梓萱，现任人事处部门负责人，主持部门全面工作。近年来牵头完成岗位设置与聘用管理制度修订，组织年度干部考核与民主测评工作，推进人事信息管理系统建设，部门年度重点任务完成情况良好（本材料为虚构示例，仅用于功能演示）。'),
(@sch_ballot, @c_lht, '陆海涛同志任职情况简介（示例）', '陆海涛，现任教务处部门副职，分管教学运行与质量管理。参与组织新一轮本科教育教学审核评估，推动一流课程与教学团队建设，完善学籍管理与考试制度，所负责工作平稳有序（本材料为虚构示例，仅用于功能演示）。'),
(@sch_ballot, @c_qjw, '钱嘉伟同志任职情况简介（示例）', '钱嘉伟，现任科学技术处科室副职，负责纵向科研项目申报组织与横向合同管理。组织多轮国家级、省级项目申报辅导，完善合同签订与经费到账流程，助力学校科研到账经费稳步增长（本材料为虚构示例，仅用于功能演示）。');

-- 演示表决票（3 名测评对象 × 3 位演示投票人，便于验证按人按对象计票统计）
INSERT INTO assessment_ballot (scheme_id, voter_id, target_cadre_id, choice, create_time) VALUES
(@sch_ballot, @u_admin, @c_szx, 'APPROVE', NOW()),
(@sch_ballot, @u_admin, @c_lht, 'APPROVE', NOW()),
(@sch_ballot, @u_admin, @c_qjw, 'APPROVE', NOW()),
(@sch_ballot, @u_qin,  @c_szx, 'APPROVE', NOW()),
(@sch_ballot, @u_qin,  @c_lht, 'ABSTAIN', NOW()),
(@sch_ballot, @u_qin,  @c_qjw, 'APPROVE', NOW()),
(@sch_ballot, @u_cao,  @c_szx, 'DISAPPROVE', NOW()),
(@sch_ballot, @u_cao,  @c_lht, 'APPROVE', NOW()),
(@sch_ballot, @u_cao,  @c_qjw, 'ABSTAIN', NOW());

-- ============================================================
-- 政策法规 / 干部考察登记 / 提醒函询诫勉 / 经济责任审计 演示种子
-- 说明：全部为虚构示例数据（姓名取自上方 cadre_info 演示档案，
--       正文与结论均标注“示例”），可重复执行（先删后插）。
-- ============================================================
USE POP;
SET FOREIGN_KEY_CHECKS=0;

DELETE FROM policy_document;
DELETE FROM cadre_investigation;
DELETE FROM supervise_admonish;
DELETE FROM supervise_audit;

SET @u_admin := (SELECT id FROM sys_user WHERE username = 'admin' LIMIT 1);

-- ---------- 干部引用（按姓名关联 cadre_info 演示档案） ----------
SET @c_linyt  := (SELECT id FROM cadre_info WHERE name = '林雨桐' LIMIT 1);
SET @c_qin    := (SELECT id FROM cadre_info WHERE name = '秦霞' LIMIT 1);
SET @c_caohr  := (SELECT id FROM cadre_info WHERE name = '蔡浩然' LIMIT 1);
SET @c_qianht := (SELECT id FROM cadre_info WHERE name = '钱海涛' LIMIT 1);
SET @c_deng   := (SELECT id FROM cadre_info WHERE name = '邓军' LIMIT 1);
SET @c_songzx := (SELECT id FROM cadre_info WHERE name = '宋梓萱' LIMIT 1);
SET @c_luht   := (SELECT id FROM cadre_info WHERE name = '陆海涛' LIMIT 1);
SET @c_duan   := (SELECT id FROM cadre_info WHERE name = '段艳' LIMIT 1);
SET @c_luyang := (SELECT id FROM cadre_info WHERE name = '陆洋' LIMIT 1);
SET @c_xiezm  := (SELECT id FROM cadre_info WHERE name = '谢志明' LIMIT 1);
SET @c_caosh  := (SELECT id FROM cadre_info WHERE name = '曹诗涵' LIMIT 1);
SET @c_yangyn := (SELECT id FROM cadre_info WHERE name = '杨一诺' LIMIT 1);

-- ---------- 干部考察登记（7 条） ----------
INSERT INTO cadre_investigation (cadre_id, investigation_type, investigation_time, investigator, result, content, org_unit, create_by, create_time) VALUES
(@c_linyt, '任前考察', '2026-03-16', '考察组（示例）', '优秀', '林雨桐同志政治素质好，组织协调能力强，群众基础扎实。经民主推荐、个别谈话与延伸了解，符合提任条件，建议作为组织部副职岗位人选（考察材料为虚构示例）。', '党委组织部', @u_admin, NOW()),
(@c_qin, '年度考核考察', '2026-06-18', '考核组（示例）', '称职', '秦霞同志年度内较好地完成了干部信息管理与档案审核等各项工作，履职情况总体良好，个别工作推进效率有待提升（考察材料为虚构示例）。', '党委组织部', @u_admin, NOW()),
(@c_caohr, '专项考察', '2026-05-11', '专项考察组（示例）', '优秀', '结合优秀年轻干部调研对蔡浩然同志开展专项考察，其统筹部门工作实绩突出，干部群众认可度较高（考察材料为虚构示例）。', '党委组织部', @u_admin, NOW()),
(@c_qianht, '任前考察', '2026-07-06', '考察组（示例）', '称职', '钱海涛同志业务熟练、作风正派，经考察符合拟任岗位要求，建议按规定程序任用（考察材料为虚构示例）。', '党委组织部', @u_admin, NOW()),
(@c_deng, '换届考察', '2026-08-12', '换届考察组（示例）', '称职', '邓军同志在换届考察中谈话评价总体良好，未发现影响使用的问题（考察材料为虚构示例）。', '党委组织部', @u_admin, NOW()),
(@c_songzx, '年度考核考察', '2026-06-24', '考核组（示例）', '优秀', '宋梓萱同志年度考核综合评定为优秀，民主测评得分名列前茅（考察材料为虚构示例）。', '人事处', @u_admin, NOW()),
(@c_luht, '任前考察', '2026-09-03', '考察组（示例）', '称职', '陆海涛同志教学管理经验丰富，考察期间反映良好，建议按程序提交讨论决定（考察材料为虚构示例）。', '党委组织部', @u_admin, NOW());

-- ---------- 提醒函询诫勉（6 条） ----------
INSERT INTO supervise_admonish (cadre_id, admonish_type, trigger_type, content, result, discipline, handle_status, handle_user, handle_time, create_by, create_time) VALUES
(@c_qianht, '提醒谈话', '换届启动前收到反映其存在请托拉票倾向的问题线索（示例）', '提醒其严守换届纪律，如实说明相关情况，自觉接受组织监督（示例）。', NULL, '无', '待处理', NULL, NULL, @u_admin, NOW()),
(@c_qin, '提醒谈话', '年度考核民主测评中个别项目满意度偏低（示例）', '就工作作风与统筹协调方面的问题进行提醒，要求改进不足（示例）。', '本人已作表态并提交整改打算，组织予以关注（示例）。', '无', '已办结', '杨一诺', '2026-03-05 15:20:00', @u_admin, NOW()),
(@c_deng, '函询', '审计及信访反映其在评优评先中存在说情打招呼问题（示例）', '请其就反映问题作出书面说明并提供佐证材料（示例）。', '经函询并组织核查，反映问题部分属实，按程序给予党内警告处分（示例）。', '党内警告（示例）', '已办结', '杨一诺', '2026-05-18 10:00:00', @u_admin, NOW()),
(@c_caohr, '函询', '信访反映其在岗位聘用工作中程序不够规范（示例）', '要求其说明岗位聘用组织程序及相关情况（示例）。', NULL, '无', '待处理', NULL, NULL, @u_admin, NOW()),
(@c_linyt, '诫勉', '个人有关事项报告与核实结果存在出入（示例）', '经核实后对其进行诫勉，责令作出深刻书面检查（示例）。', '本人已提交书面检查，相关事项已按规定纠正（示例）。', '无', '已办结', '杨一诺', '2026-08-27 09:40:00', @u_admin, NOW()),
(@c_songzx, '诫勉', '所负责工作出现一般性失职失责情形（示例）', '对其进行诫勉谈话，指出问题并提出整改要求（示例）。', NULL, '无', '待处理', NULL, NULL, @u_admin, NOW());

-- ---------- 经济责任审计（6 条） ----------
INSERT INTO supervise_audit (cadre_id, audit_scope, audit_period_start, audit_period_end, audit_org, start_time, end_time, audit_result, issue, rectify_status, audit_report_url, create_by, create_time) VALUES
(@c_duan, '任期经济责任审计', '2021-09-01', '2026-08-31', '学校审计处', '2026-05-06', '2026-07-10', '存在需整改问题', '部分教学专项经费预算执行进度与申报用途存在差异，相关审批台账需补充完善（示例）。', '整改中', NULL, @u_admin, NOW()),
(@c_songzx, '任期经济责任审计', '2022-01-01', '2026-06-30', '学校审计处', '2026-07-13', '2026-08-21', '基本正常', '总体预算执行规范，个别科目核算口径建议进一步统一（示例）。', '已整改', NULL, @u_admin, NOW()),
(@c_luyang, '任期经济责任审计', '2021-06-01', '2026-05-31', '学校审计处', '2026-06-02', '2026-07-31', '存在需整改问题', '部分修缮工程变更签证资料不完整，需限期补齐并完善内控流程（示例）。', '待整改', NULL, @u_admin, NOW()),
(@c_xiezm, '专项审计', '2024-01-01', '2025-12-31', '学校审计处', '2026-08-10', '2026-08-28', '无重大问题', NULL, NULL, NULL, @u_admin, NOW()),
(@c_caosh, '离任审计', '2018-09-01', '2026-06-30', '上级审计部门委托第三方机构（示例）', '2026-07-06', '2026-08-14', '无重大问题', NULL, NULL, NULL, @u_admin, NOW()),
(@c_yangyn, '任期经济责任审计', '2020-09-01', '2026-05-31', '学校审计处', '2026-06-15', '2026-08-05', '基本正常', '部门经费使用总体合规，建议进一步规范公务接待审批记录（示例）。', '已整改', NULL, @u_admin, NOW());

-- ---------- 政策法规（6 条，正文为虚构示例） ----------
INSERT INTO policy_document (title, doc_no, publish_unit, issue_date, effective_date, category, content, attachment_name, attachment_url, create_by, create_time) VALUES
('辽宁某某大学中层领导人员选拔任用工作办法（2026年修订）', '辽工大党发〔2026〕4号', '中共辽宁某某大学委员会', '2026-02-26', '2026-03-05', '干部选拔', '第一条 为规范中层领导人员选拔任用工作，坚持党管干部原则，落实新时代好干部标准，根据上级有关规定，结合学校实际制定本办法（示例正文，仅作功能演示）。\n第二条 选拔任用工作坚持德才兼备、以德为先，注重实绩、群众公认，坚持事业为上、依事择人。\n第三条 选拔任用一般经过动议、民主推荐、考察、讨论决定、任职等环节（示例）。', '办法全文（示例）.pdf', '/demo/policy/2026-4.pdf', @u_admin, NOW()),
('关于加强干部日常监督管理的若干措施（试行）', '辽工大党发〔2026〕11号', '中共辽宁某某大学委员会', '2026-03-18', '2026-04-01', '干部监督', '一、强化政治监督，把牢正确政治方向（示例正文）。\n二、坚持抓早抓小，综合运用提醒谈话、函询、诫勉等方式加强日常监督。\n三、贯通审计、信访、巡察等监督资源，提升监督合力（示例）。', NULL, NULL, @u_admin, NOW()),
('2026年度干部教育培训工作计划', '辽工大党发〔2026〕7号', '中共辽宁某某大学委员会', '2026-01-20', '2026-02-01', '教育培训', '一、总体要求：以提升干部政治能力与履职本领为重点（示例正文）。\n二、重点班次：中层干部专题培训班、新任职干部履职能力提升班、青年干部理论学习班等。\n三、组织保障：由党委组织部统筹实施，各部门协同配合（示例）。', NULL, NULL, @u_admin, NOW()),
('基层党委（党总支）党建工作责任清单（2026年）', '辽工大党发〔2026〕15号', '中共辽宁某某大学委员会', '2026-05-06', '2026-05-06', '党内法规', '一、政治建设责任：落实“第一议题”制度，及时传达学习上级精神（示例正文）。\n二、组织建设责任：规范党内组织生活，做好发展党员与党员教育管理。\n三、纪律建设责任：落实全面从严治党要求，配合开展监督执纪问责（示例）。', NULL, NULL, @u_admin, NOW()),
('领导干部报告个人有关事项工作指引（2026年版）', '辽工大组字〔2026〕3号', '党委组织部', '2026-04-15', '2026-04-20', '干部监督', '一、报告对象范围、报告事项与填报要求以有关规定为准（示例正文）。\n二、实行报告材料专人管理、严格保密。\n三、按要求开展随机抽查与重点核实，发现瞒报漏报依规处理（示例）。', '填报说明（示例）.pdf', '/demo/policy/zzb-2026-3.pdf', @u_admin, NOW()),
('关于严肃暑期干部调整交流期间纪律要求的通知', '辽工大纪发〔2026〕6号', '学校纪委', '2026-06-20', '2026-06-20', '其他', '一、严禁在干部调整交流期间跑官要官、说情打招呼（示例正文）。\n二、严禁突击提拔调整干部、违规用人。\n三、对违反纪律要求的问题线索，一经查实严肃处理（示例）。', NULL, NULL, @u_admin, NOW());

SET FOREIGN_KEY_CHECKS=1;
-- 演示种子合计：政策法规6 / 干部考察登记7 / 提醒函询诫勉6 / 经济责任审计6

-- ============================================================
-- 角色级模块权限 + 预警规则配置 演示种子（可重复执行）
-- 说明：姓名/内容均为虚构示例；sys_role 仅补缺行 + 更新权限，
--       不清空/删除已有角色，避免破坏运行库的用户-角色绑定。
-- ============================================================
USE POP;
SET FOREIGN_KEY_CHECKS=0;

-- 1) 补充演示角色行（不存在才插入，避免破坏 sys_role 既有数据）
INSERT INTO sys_role (role_name, role_code, data_scope, status, permissions, create_time, update_time)
SELECT '组织部长(处级)', 'org_leader', 3, 1,
       'organization,cadre,transfer,promotion,appointment,evaluation,supervision,assessment,daily',
       NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE role_code = 'org_leader');

-- 2) 按 role_code 给既有角色行赋予合理模块权限（可重复执行，幂等覆盖）
--    admin 系统管理员：全模块；org_leader 组织部长：除系统管理外全部业务模块
UPDATE sys_role SET permissions = 'ALL' WHERE role_code = 'admin';
UPDATE sys_role SET permissions = 'organization,cadre,transfer,promotion,appointment,evaluation,supervision,assessment,daily'
WHERE role_code = 'org_leader';

-- 3) 演示用户与角色权限打通：caohaoran(组织部部长,user_type=3) 已显式授权则不动；
--    若其用户级权限被清空，将自动回退 org_leader 角色权限（后端 resolveEffectivePermissions 逻辑）。

-- 4) 预警规则配置（5 条，先删后插可重复执行；阈值单位：天）
DELETE FROM supervise_alert_rule;
INSERT INTO supervise_alert_rule (rule_name, rule_type, level, threshold, is_enabled, remark, create_by, create_time, update_time) VALUES
('证件到期预警', '证件到期', '黄色', 90,  1, '干部证件（护照/通行证）有效期剩余不足 N 天时提醒换领/续期（示例）', @u_admin, NOW(), NOW()),
('出国(境)超期预警', '出国超期', '红色', 30,  1, '经批准出国(境)逾期未归超过 N 天自动告警（示例）', @u_admin, NOW(), NOW()),
('休假超时预警', '休假超时', '黄色', 5,   1, '休假/请假到期未销假超过 N 天提醒补办销假手续（示例）', @u_admin, NOW(), NOW()),
('任职年限预警', '任职超期', '橙色', 60,  1, '现岗位距最长任职年限不足 N 天提示启动轮岗交流（示例）', @u_admin, NOW(), NOW()),
('到龄退休提醒', '到龄退休', '橙色', 365, 1, '距法定退休年龄不足 N 天提醒办理退休手续（示例）', @u_admin, NOW(), NOW());

SET FOREIGN_KEY_CHECKS=1;
-- 角色权限种子：admin=ALL / org_leader=9业务模块；预警规则配置种子：5 条

-- ============================================================
-- 班子登记表(org_team_member)演示种子 + 职务层次/系统字典 种子
-- 说明：全部为虚构示例数据，均可重复执行（先删后插）。
--   org_team_member 用 CREATE TABLE IF NOT EXISTS 幂等建表（兼容只执行本脚本场景），
--   干部按姓名关联 cadre_info 演示档案（上方已重灌），不依赖固定自增 id。
-- ============================================================
USE POP;
SET FOREIGN_KEY_CHECKS=0;

-- 0) 班子成员登记表 DDL（与 init.sql 一致；幂等）
CREATE TABLE IF NOT EXISTS org_team_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    dept_id BIGINT NOT NULL COMMENT '机构ID',
    cadre_id BIGINT NOT NULL COMMENT '干部ID',
    leader_post VARCHAR(64) COMMENT '班子职务 党委书记/院长/副院长/党委副书记/纪委书记/部长/处长等',
    sort_order INT DEFAULT 0 COMMENT '排序',
    is_leader TINYINT DEFAULT 0 COMMENT '是否主要负责人 0否 1是',
    start_date DATE COMMENT '任职开始日期',
    end_date DATE COMMENT '任职结束日期(空表示现任)',
    create_by BIGINT,
    update_by BIGINT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_dept (dept_id),
    INDEX idx_cadre (cadre_id)
) ENGINE=InnoDB COMMENT='班子成员登记表';

SET @u_admin := (SELECT id FROM sys_user WHERE username = 'admin' LIMIT 1);

-- 1) 职务层次（空表→9 条常用层次示例，先删后插）
DELETE FROM org_position_level;
INSERT INTO org_position_level (level_name, min_lower_years, max_age, min_education, assessment_required, penalty_period_restrict, sort_order, status, create_time, update_time) VALUES
('国家级正职', 5, 70, '本科', '近五年年度考核称职及以上（示例）', 24, 1, 1, NOW(), NOW()),
('国家级副职', 4, 65, '本科', '近五年年度考核称职及以上（示例）', 24, 2, 1, NOW(), NOW()),
('省部级正职', 4, 63, '本科', '近五年年度考核称职及以上（示例）', 18, 3, 1, NOW(), NOW()),
('省部级副职', 3, 60, '本科', '近五年年度考核称职及以上（示例）', 18, 4, 1, NOW(), NOW()),
('厅局级正职', 3, 58, '本科', '近三年年度考核称职及以上（示例）', 12, 5, 1, NOW(), NOW()),
('厅局级副职', 3, 55, '本科', '近三年年度考核称职及以上（示例）', 12, 6, 1, NOW(), NOW()),
('县处级正职', 3, 52, '本科', '近三年年度考核称职及以上（示例）', 6, 7, 1, NOW(), NOW()),
('县处级副职', 3, 50, '本科', '近三年年度考核称职及以上（示例）', 6, 8, 1, NOW(), NOW()),
('乡科级正职', 3, 48, '专科', '近三年年度考核称职及以上（示例）', 6, 9, 1, NOW(), NOW());

-- 2) 系统字典：类型（6 类）+ 数据（先删后插）
DELETE FROM sys_dict_data;
DELETE FROM sys_dict_type;
INSERT INTO sys_dict_type (type_name, type_code, status, create_time, update_time) VALUES
('干部状态', 'cadre_status', 1, NOW(), NOW()),
('民族', 'nation', 1, NOW(), NOW()),
('政治面貌', 'political_status', 1, NOW(), NOW()),
('学历层次', 'education', 1, NOW(), NOW()),
('婚姻状况', 'marriage', 1, NOW(), NOW()),
('考核结果', 'assessment_result', 1, NOW(), NOW());
INSERT INTO sys_dict_data (type_code, dict_label, dict_value, sort_order, status, create_time, update_time) VALUES
-- 干部状态（value 与 cadre_info.cadre_status 存储一致）
('cadre_status', '在职', 'ON_JOB', 1, 1, NOW(), NOW()),
('cadre_status', '离退休', 'RETIRED', 2, 1, NOW(), NOW()),
('cadre_status', '调出', 'TRANSFERRED', 3, 1, NOW(), NOW()),
('cadre_status', '辞职', 'RESIGNED', 4, 1, NOW(), NOW()),
-- 民族（label/value 与 cadre_info.nation 存储的中文一致）
('nation', '汉族', '汉族', 1, 1, NOW(), NOW()),
('nation', '蒙古族', '蒙古族', 2, 1, NOW(), NOW()),
('nation', '回族', '回族', 3, 1, NOW(), NOW()),
('nation', '朝鲜族', '朝鲜族', 4, 1, NOW(), NOW()),
('nation', '满族', '满族', 5, 1, NOW(), NOW()),
('nation', '锡伯族', '锡伯族', 6, 1, NOW(), NOW()),
('nation', '达斡尔族', '达斡尔族', 7, 1, NOW(), NOW()),
-- 政治面貌（label/value 与 cadre_info.political_status 存储中文一致）
('political_status', '中共党员', '中共党员', 1, 1, NOW(), NOW()),
('political_status', '中共预备党员', '中共预备党员', 2, 1, NOW(), NOW()),
('political_status', '共青团员', '共青团员', 3, 1, NOW(), NOW()),
('political_status', '民主党派', '民主党派', 4, 1, NOW(), NOW()),
('political_status', '无党派人士', '无党派人士', 5, 1, NOW(), NOW()),
('political_status', '群众', '群众', 6, 1, NOW(), NOW()),
-- 学历层次（label/value 与 cadre_info.full_time_education 存储中文一致）
('education', '博士研究生', '博士研究生', 1, 1, NOW(), NOW()),
('education', '硕士研究生', '硕士研究生', 2, 1, NOW(), NOW()),
('education', '本科', '本科', 3, 1, NOW(), NOW()),
('education', '专科', '专科', 4, 1, NOW(), NOW()),
('education', '高中及以下', '高中及以下', 5, 1, NOW(), NOW()),
-- 婚姻状况
('marriage', '未婚', '未婚', 1, 1, NOW(), NOW()),
('marriage', '已婚', '已婚', 2, 1, NOW(), NOW()),
('marriage', '离异', '离异', 3, 1, NOW(), NOW()),
('marriage', '丧偶', '丧偶', 4, 1, NOW(), NOW()),
-- 考核结果（label/value 与 assessment_annual.assessment_result 存储中文一致）
('assessment_result', '优秀', '优秀', 1, 1, NOW(), NOW()),
('assessment_result', '称职', '称职', 2, 1, NOW(), NOW()),
('assessment_result', '基本称职', '基本称职', 3, 1, NOW(), NOW()),
('assessment_result', '不称职', '不称职', 4, 1, NOW(), NOW());

-- 3) 班子演示成员（8 条：校级班子 4 + 组织部 2 + 人事处 2，干部按姓名关联）
DELETE FROM org_team_member;
INSERT INTO org_team_member (dept_id, cadre_id, leader_post, sort_order, is_leader, start_date, end_date, create_by, create_time, update_time) VALUES
(1, (SELECT id FROM cadre_info WHERE name = '顾晓东' LIMIT 1), '党委书记', 1, 1, '2021-06-01', NULL, @u_admin, NOW(), NOW()),
(1, (SELECT id FROM cadre_info WHERE name = '邓秀兰' LIMIT 1), '校长', 2, 0, '2021-06-01', NULL, @u_admin, NOW(), NOW()),
(1, (SELECT id FROM cadre_info WHERE name = '万娟' LIMIT 1), '党委副书记', 3, 0, '2021-06-01', NULL, @u_admin, NOW(), NOW()),
(1, (SELECT id FROM cadre_info WHERE name = '黎志明' LIMIT 1), '纪委书记', 4, 0, '2021-06-01', NULL, @u_admin, NOW(), NOW()),
(2, (SELECT id FROM cadre_info WHERE name = '蔡浩然' LIMIT 1), '部长', 1, 1, '2022-09-01', NULL, @u_admin, NOW(), NOW()),
(2, (SELECT id FROM cadre_info WHERE name = '林雨桐' LIMIT 1), '副部长', 2, 0, '2023-03-01', NULL, @u_admin, NOW(), NOW()),
(3, (SELECT id FROM cadre_info WHERE name = '宋梓萱' LIMIT 1), '处长', 1, 1, '2022-09-01', NULL, @u_admin, NOW(), NOW()),
(3, (SELECT id FROM cadre_info WHERE name = '史娜' LIMIT 1), '副处长', 2, 0, '2023-03-01', NULL, @u_admin, NOW(), NOW());

SET FOREIGN_KEY_CHECKS=1;
-- 本段种子合计：班子登记 8 / 职务层次 9 / 字典类型 6 / 字典数据 30

-- ============================================================
-- 预警规则驱动演示触发点（supervise_alert 由后端“按规则生成”产生，本段只造台账触发条件）
-- 说明：全部关联既有虚构干部；均“先 DELETE 该行再 INSERT”保证可重复执行；
--       日期采用 CURDATE() 相对计算，任意时间重跑 seed 后执行“一键生成”都能命中各规则。
-- 触发点：1)在借证照逾期未交回 2)已批准休假结束早于今天 3)班子任职多年超期 4)在职干部到龄退休
-- ============================================================
USE POP;
SET FOREIGN_KEY_CHECKS=0;

-- 0) 清空历史预警：预警由接口按规则生成，此处重置演示现场（可重复执行）
DELETE FROM supervise_alert;

SET @u_admin  := (SELECT id FROM sys_user WHERE username = 'admin' LIMIT 1);
SET @c_lin    := (SELECT id FROM cadre_info WHERE name = '林雨桐' LIMIT 1);
SET @c_qin    := (SELECT id FROM cadre_info WHERE name = '秦霞' LIMIT 1);
SET @c_dengxl := (SELECT id FROM cadre_info WHERE name = '邓秀兰' LIMIT 1);
SET @c_pengb  := (SELECT id FROM cadre_info WHERE name = '彭波' LIMIT 1);

-- 1) 触发点：在借证照 expected_return_date 设为过去日期（逾期未交回）—— 证件到期规则
DELETE FROM daily_certificate WHERE cadre_id = @c_lin AND cert_status = '在借' AND cert_type = '港澳通行证';
INSERT INTO daily_certificate (cadre_id, cert_type, cert_number, cert_status, borrow_date, return_date, expected_return_date, remark, create_by, create_time) VALUES
(@c_lin, '港澳通行证', 'DEMO-W12345678', '在借', DATE_SUB(CURDATE(), INTERVAL 40 DAY), NULL, DATE_SUB(CURDATE(), INTERVAL 20 DAY), '演示触发点：在借证照逾期未交回（示例）', @u_admin, NOW());

-- 2) 触发点：已批准休假 end_date 早于今天（超期未销假）—— 休假超时规则
DELETE FROM daily_leave WHERE cadre_id = @c_qin AND approve_status = '已批准' AND leave_type = '年休假';
INSERT INTO daily_leave (cadre_id, leave_type, start_date, end_date, leave_days, reason, approve_status, approve_id, approve_time, create_by, create_time) VALUES
(@c_qin, '年休假', DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_SUB(CURDATE(), INTERVAL 30 DAY), 6.0, '演示触发点：休假结束超期未销假（示例）', '已批准', @u_admin, NOW(), @u_admin, NOW());

-- 3) 触发点：班子 org_team_member start_date 设为多年前（任职超期）—— 任职超期规则
DELETE FROM org_team_member WHERE cadre_id = @c_dengxl AND leader_post = '校长';
INSERT INTO org_team_member (dept_id, cadre_id, leader_post, sort_order, is_leader, start_date, end_date, create_by, create_time, update_time) VALUES
(1, @c_dengxl, '校长', 2, 0, '2015-01-01', NULL, @u_admin, NOW(), NOW());

-- 4) 触发点：在职干部出生年设为 1966（男，2026-02 已届 60 周岁仍 ON_JOB）—— 到龄退休规则
DELETE FROM cadre_info WHERE name = '彭波' AND cadre_status = 'ON_JOB';
INSERT INTO cadre_info (name, gender, birth_date, nation, native_place, political_status, party_join_date, work_start_date, id_card, phone, email, photo_url, resume_text, full_time_education, full_time_degree, full_time_school, part_time_education, part_time_degree, part_time_school, dept_id, position, position_level, rank_id, position_start_date, position_doc_no, reward_punishment, annual_assessment, cadre_status, retirement_date, leave_date, leave_reason, create_time, update_time) VALUES
('彭波', 1, '1966-02-15', '汉族', '辽宁营口', '中共党员', '1985-06-01', '1985-07-01', NULL, NULL, NULL, NULL, NULL, '本科', '学士', '北京航空航天大学', NULL, NULL, NULL, 4, '管理员', '科级', 7, '1990-09-01', NULL, NULL, NULL, 'ON_JOB', NULL, NULL, NULL, NOW(), NOW());

SET FOREIGN_KEY_CHECKS=1;
-- 本段触发点合计：证照 1 / 休假 1 / 班子任职 1 / 到龄退休 1（执行后端“按规则生成预警”后可产生对应预警）
