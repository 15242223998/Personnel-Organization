-- ============================================
-- 辽宁工业大学 · 干部人事系统 - 演示/示例数据
-- 机构树 + 编制 + 干部档案（可重复执行，先清空相关业务表）
-- 提示：以下姓名均为虚构，职位均为示例占位，不含真实人员信息
-- ============================================
USE POP;
SET FOREIGN_KEY_CHECKS=0;
DELETE FROM cadre_reserve; DELETE FROM cadre_attachment; DELETE FROM cadre_family_member;
DELETE FROM appoint_record; DELETE FROM appoint_process; DELETE FROM transfer_record; DELETE FROM rank_promotion_record;
DELETE FROM cadre_info; DELETE FROM org_staffing_quota; DELETE FROM org_rank; DELETE FROM org_department;

INSERT INTO org_rank (rank_name, rank_type, promotion_years, sort_order, status, create_time, update_time) VALUES
('管理岗-一级调研员', '管理岗', 3, 1, 1, NOW(), NOW()),
('管理岗-正处级', '管理岗', 3, 2, 1, NOW(), NOW()),
('管理岗-副处级', '管理岗', 3, 3, 1, NOW(), NOW()),
('管理岗-正科级', '管理岗', 3, 4, 1, NOW(), NOW()),
('管理岗-副科级', '管理岗', 3, 5, 1, NOW(), NOW()),
('专业技术岗-正高级', '专业技术岗', 3, 6, 1, NOW(), NOW()),
('专业技术岗-副高级', '专业技术岗', 3, 7, 1, NOW(), NOW()),
('专业技术岗-中级', '专业技术岗', 3, 8, 1, NOW(), NOW()),
('专业技术岗-初级', '专业技术岗', 3, 9, 1, NOW(), NOW());

INSERT INTO org_department (id, parent_id, dept_name, short_name, dept_level, leader_quota, dept_sort, status, create_time, update_time) VALUES
(1, 0, '辽宁工业大学', '学校机关', '校级', 11, 1, 1, NOW(), NOW()),
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

INSERT INTO sys_user (username, password, real_name, email, phone, user_type, status, dept_id, cadre_id, create_time, update_time)
SELECT 'qinxia', '123456', '秦霞', 'qinxia@demo.lnut.edu.cn', '13800000021', 6, 1, 2, @cadre_qin, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username = 'qinxia');

INSERT INTO sys_user (username, password, real_name, email, phone, user_type, status, dept_id, cadre_id, create_time, update_time)
SELECT 'caohaoran', '123456', '蔡浩然', 'caohaoran@demo.lnut.edu.cn', '13800000022', 3, 1, 2, @cadre_cao, NOW(), NOW()
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
(@c_lin, '港澳通行证', 'DEMO-W12345678', '在借',   '2026-08-20',  NULL,          '2026-09-20',  '因公赴港澳交流借用（示例）', @u_admin, NOW()),
(@c_qin, '护照',       'DEMO-E88005678', '已归还', '2026-05-10',  '2026-06-05',  '2026-06-10',  '已按期归还（示例）', @u_admin, NOW()),
(@c_gu,  '其他',       'DEMO-G00011122', '在库',   NULL,          NULL,          NULL,          '工作证件（示例）', @u_admin, NOW());

-- ---------- 出境记录 ----------
INSERT INTO daily_abroad_record (cadre_id, destination, purpose, depart_date, return_date, approved_days, actual_days, is_overdue, create_by, create_time) VALUES
(@c_gu,  '新加坡', '公务出访', '2026-05-10', '2026-05-17', 8,  8,  0, @u_admin, NOW()),
(@c_cao, '日本',   '学术交流', '2026-06-01', '2026-06-12', 10, 12, 1, @u_admin, NOW()),
(@c_lin, '中国香港', '探亲',   '2025-10-01', '2025-10-08', 7,  7,  0, @u_admin, NOW());

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
INSERT INTO daily_self_application (applicant_id, application_type, application_title, application_content, apply_status, approver_id, approve_time, approve_comment, create_by, create_time) VALUES
(@u_qin, 'INFO_UPDATE', '更新学历学位信息', '本人档案中在职学历已更新为硕士研究生，申请同步更新档案信息（示例）。', 'SUBMITTED', NULL, NULL, NULL, @u_qin, NOW()),
(@u_cao, 'LEAVE', '9月中旬年休假申请', '拟于9月14日至9月16日休年休假3天，期间工作已安排交接（示例）。', 'APPROVED', @u_admin, '2026-09-02 10:00:00', '同意，注意工作衔接（示例）', @u_cao, NOW()),
(@u_qin, 'PART_TIME', '校外学会兼职备案', '拟兼任省XX学会理事，按学校规定申请备案（示例）。', 'REJECTED', @u_admin, '2026-08-28 15:30:00', '按学校兼职管理暂行规定暂不予备案（示例）', @u_qin, NOW()),
(@u_cao, 'TRAINING', '报名参加高校干部专题培训班', '申请参加本期专题培训班，学习计划已列入年度安排（示例）。', 'DRAFT', NULL, NULL, NULL, @u_cao, NOW());

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
