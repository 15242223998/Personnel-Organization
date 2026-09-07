// 生成 sql/seed-demo.sql：机构树 + 编制 + 干部档案示例数据（辽宁工业大学背景）
const fs = require('fs')

// 简单 LCG 保证确定性
let seed = 20260904
function rnd() {
  seed = (seed * 1103515245 + 12345) % 2147483648
  return seed / 2147483648
}
function randInt(min, max) { return min + Math.floor(rnd() * (max - min + 1)) }
function pick(arr) { return arr[Math.floor(rnd() * arr.length)] }

const surnames = ['王','李','张','刘','陈','杨','黄','赵','周','吴','徐','孙','马','朱','胡','郭','何','高','林','罗','郑','梁','谢','宋','唐','许','韩','冯','邓','曹','彭','曾','萧','田','董','潘','袁','蔡','蒋','余','于','杜','叶','程','苏','魏','吕','丁','任','沈','姚','卢','姜','崔','钟','谭','陆','汪','范','金','石','廖','贾','夏','韦','付','方','白','邹','孟','熊','秦','邱','江','尹','薛','闫','段','雷','侯','龙','史','陶','黎','贺','顾','毛','郝','龚','邵','万','钱','严','覃','武','戴','莫','孔','向','汤']
const givens = ['伟','芳','娜','敏','静','丽','强','磊','军','洋','勇','艳','杰','娟','涛','明','超','秀兰','霞','平','刚','桂英','鑫','志强','志明','雪','婷','欣','健','波','斌','鑫磊','国栋','建国','文博','志远','晓东','海峰','明辉','玉芬','丽华','淑华','红梅','德明','永强','红','光辉','树','春生','海涛','文静','春雨','俊杰','丽娟','思远','嘉伟','雨桐','佳琪','子涵','浩然','一诺','晨曦','梓萱','欣怡','宇航','雨泽','诗涵','思琪','靖宇']
const nations = ['汉族','汉族','汉族','汉族','汉族','汉族','汉族','汉族','汉族','满族','蒙古族','回族','朝鲜族','锡伯族','达斡尔族']
const politics = ['中共党员','中共党员','中共党员','中共党员','中共党员','中共党员','民主党派','群众','群众']
const educs = ['博士研究生','博士研究生','博士研究生','硕士研究生','硕士研究生','本科','本科','大专']
const degrees = ['博士','博士','博士','硕士','硕士','学士','学士','大专']
const schools = ['清华大学','北京大学','哈尔滨工业大学','大连理工大学','东北大学','吉林大学','辽宁大学','东北财经大学','沈阳工业大学','辽宁工程技术大学','沈阳建筑大学','沈阳农业大学','辽宁师范大学','沈阳师范大学','大连海事大学','燕山大学','长春理工大学','北京航空航天大学','华中科技大学','西安交通大学']
const places = ['辽宁沈阳','辽宁大连','辽宁鞍山','辽宁抚顺','辽宁本溪','辽宁丹东','辽宁锦州','辽宁营口','辽宁阜新','辽宁辽阳','辽宁盘锦','辽宁铁岭','辽宁朝阳','辽宁葫芦岛','黑龙江哈尔滨','吉林长春','河北石家庄','山东青岛','江苏南京','河南郑州']

const depts = [
  { id: 1, name: '辽宁工业大学', short: '学校机关', level: '校级', parent: 0, quota: 24, lq: 11, type: 'root' },
  { id: 2, name: '党委组织部', short: '组织部', level: '处级', parent: 1, quota: 14, lq: 3, type: 'office' },
  { id: 3, name: '人事处', short: '人事处', level: '处级', parent: 1, quota: 18, lq: 4, type: 'office' },
  { id: 4, name: '党委宣传部', short: '宣传部', level: '处级', parent: 1, quota: 13, lq: 3, type: 'office' },
  { id: 5, name: '纪委办公室', short: '纪委办', level: '处级', parent: 1, quota: 9, lq: 3, type: 'office' },
  { id: 6, name: '审计处', short: '审计处', level: '处级', parent: 1, quota: 8, lq: 2, type: 'office' },
  { id: 7, name: '教务处', short: '教务处', level: '处级', parent: 1, quota: 22, lq: 4, type: 'office' },
  { id: 8, name: '科学技术处', short: '科研处', level: '处级', parent: 1, quota: 14, lq: 3, type: 'office' },
  { id: 9, name: '学生工作部', short: '学工部', level: '处级', parent: 1, quota: 16, lq: 3, type: 'office' },
  { id: 10, name: '计划财务处', short: '财务处', level: '处级', parent: 1, quota: 17, lq: 3, type: 'office' },
  { id: 11, name: '招生就业处', short: '招就处', level: '处级', parent: 1, quota: 11, lq: 3, type: 'office' },
  { id: 12, name: '保卫处', short: '保卫处', level: '处级', parent: 1, quota: 16, lq: 3, type: 'office' },
  { id: 13, name: '团委', short: '团委', level: '处级', parent: 1, quota: 8, lq: 2, type: 'office' },
  { id: 14, name: '校工会', short: '工会', level: '处级', parent: 1, quota: 7, lq: 2, type: 'office' },
  { id: 15, name: '机械工程与自动化学院', short: '机械学院', level: '处级', parent: 1, quota: 62, lq: 7, type: 'college' },
  { id: 16, name: '电气工程学院', short: '电气学院', level: '处级', parent: 1, quota: 58, lq: 7, type: 'college' },
  { id: 17, name: '信息科学与工程学院', short: '信息学院', level: '处级', parent: 1, quota: 50, lq: 7, type: 'college' },
  { id: 18, name: '计算机科学与技术学院', short: '计算机学院', level: '处级', parent: 1, quota: 56, lq: 7, type: 'college' },
  { id: 19, name: '土木建筑工程学院', short: '土木学院', level: '处级', parent: 1, quota: 52, lq: 7, type: 'college' },
  { id: 20, name: '材料科学与工程学院', short: '材料学院', level: '处级', parent: 1, quota: 48, lq: 7, type: 'college' },
  { id: 21, name: '自动化与控制工程学院', short: '自动化学院', level: '处级', parent: 1, quota: 46, lq: 7, type: 'college' },
  { id: 22, name: '外国语学院', short: '外语学院', level: '处级', parent: 1, quota: 34, lq: 6, type: 'college' },
  { id: 23, name: '经济管理学院', short: '经管学院', level: '处级', parent: 1, quota: 44, lq: 7, type: 'college' },
  { id: 24, name: '马克思主义学院', short: '马院', level: '处级', parent: 1, quota: 28, lq: 5, type: 'college' },
  { id: 25, name: '理学院', short: '理学院', level: '处级', parent: 1, quota: 40, lq: 6, type: 'college' },
  { id: 26, name: '后勤管理处', short: '后勤处', level: '处级', parent: 1, quota: 20, lq: 3, type: 'office' },
  { id: 27, name: '国际交流合作处', short: '国际处', level: '处级', parent: 1, quota: 9, lq: 2, type: 'office' }
]

// 干部角色池
const officeRoles = ['部门负责人','部门副职','部门副职','科室负责人','科室负责人','科室副职','科室副职','管理员','管理员','管理员','管理员','管理员']
const collegeRoles = ['学院负责人','学院党组织负责人','学院副职','学院副职','学院副职','学院办公室主任','系/教研室主任','系/教研室主任','系/教研室副主任','系/教研室副主任','实验室负责人','教务干事','专职教师','专职教师','专职教师','专职教师','专职教师','专职教师','专职教师','专职教师']

const out = []
out.push('-- ============================================')
out.push('-- 辽宁工业大学 · 干部人事系统 - 演示/示例数据')
out.push('-- 机构树 + 编制 + 干部档案（可重复执行，先清空相关业务表）')
out.push('-- 提示：以下姓名均为虚构，职位均为示例占位，不含真实人员信息')
out.push('-- ============================================')
out.push('USE POP;')
out.push('SET FOREIGN_KEY_CHECKS=0;')
out.push('DELETE FROM cadre_reserve; DELETE FROM cadre_attachment; DELETE FROM cadre_family_member;')
out.push('DELETE FROM appoint_record; DELETE FROM appoint_process; DELETE FROM transfer_record; DELETE FROM rank_promotion_record;')
out.push('DELETE FROM cadre_info; DELETE FROM org_staffing_quota; DELETE FROM org_rank; DELETE FROM org_department;')
out.push('')

// 职级
const ranks = ['管理岗-一级调研员','管理岗-正处级','管理岗-副处级','管理岗-正科级','管理岗-副科级','专业技术岗-正高级','专业技术岗-副高级','专业技术岗-中级','专业技术岗-初级']
out.push('INSERT INTO org_rank (rank_name, rank_type, promotion_years, sort_order, status, create_time, update_time) VALUES')
out.push(ranks.map((r, i) => `('${r}', '${r.startsWith('专业') ? '专业技术岗' : '管理岗'}', ${r.includes('级') ? 3 : 2}, ${i + 1}, 1, NOW(), NOW())`).join(',\n') + ';')
out.push('')

// 机构
out.push('INSERT INTO org_department (id, parent_id, dept_name, short_name, dept_level, leader_quota, dept_sort, status, create_time, update_time) VALUES')
out.push(depts.map((d) => `(${d.id}, ${d.parent}, '${d.name}', '${d.short}', '${d.level}', ${d.lq}, ${d.id}, 1, NOW(), NOW())`).join(',\n') + ';')
out.push('')

// 编制
out.push('INSERT INTO org_staffing_quota (dept_id, approved_quota, leader_quota) VALUES')
out.push(depts.map((d) => `(${d.id}, ${d.quota}, ${d.lq})`).join(',\n') + ';')
out.push('')

// 干部
const rows = []
function addCadre(deptId, name, gender, birthYear, pol, edu, pos, posLevel, rankIdx, status, extra) {
  const birthMonth = String(randInt(1, 12)).padStart(2, '0')
  const birthDay = String(randInt(1, 28)).padStart(2, '0')
  const workYear = Math.max(1980, birthYear + randInt(20, 28))
  const partyYear = Math.max(1982, Math.min(birthYear + randInt(18, 30), workYear))
  const nation = pick(nations)
  const school = pick(schools)
  const posStartYear = Math.min(2025, workYear + randInt(1, 12))
  rows.push(`('${name}', ${gender}, '${birthYear}-${birthMonth}-${birthDay}', '${nation}', '${pick(places)}', '${pol}', '${partyYear}-06-01', '${workYear}-07-01', NULL, NULL, NULL, NULL, NULL, '${edu}', '${degrees[Math.max(0, educs.indexOf(edu))] || pick(degrees)}', '${school}', NULL, NULL, NULL, ${deptId}, '${pos}', '${posLevel}', ${rankIdx}, '${posStartYear}-0${randInt(1, 9)}-01', NULL, NULL, NULL, '${status}', NULL, NULL, NULL, NOW(), NOW())`)
}

// 校级领导（机关，职务仅作占位，不指向具体校领导岗位）
const topLeaders = ['校级领导','校级领导','校级领导','校级领导','校级领导','校级领导','校级领导','校级领导','校级领导']
topLeaders.forEach((role, i) => {
  addCadre(1, pick(surnames) + pick(givens), 1, randInt(1963, 1972), '中共党员', '博士研究生', role, '校级', 1, 'ON_JOB')
})

depts.slice(1).forEach((d) => {
  const target = d.type === 'college'
    ? Math.round(d.quota * (0.5 + rnd() * 0.15))
    : Math.round(d.quota * (0.72 + rnd() * 0.12))
  const roles = d.type === 'college' ? collegeRoles : officeRoles
  const count = Math.max(8, Math.min(target, d.quota - 1))
  for (let i = 0; i < count; i++) {
    const name = pick(surnames) + pick(givens)
    const gender = rnd() < 0.62 ? 1 : 2
    // 领导岗偏年长
    const isLeader = i < 6
    let birthYear = d.type === 'college'
      ? (isLeader ? randInt(1968, 1978) : randInt(1975, 1998))
      : (isLeader ? randInt(1966, 1976) : randInt(1972, 1996))
    // 少量接近退休的人员，让“离退休”状态分布更真实
    if (!isLeader && rnd() < 0.07) birthYear = randInt(1958, 1964)
    // 政治面貌
    const pol = rnd() < (isLeader ? 0.92 : 0.7) ? '中共党员' : pick(['群众', '民主党派'])
    // 学历：学院教师博士比例高
    const edu = d.type === 'college'
      ? pick(['博士研究生', '博士研究生', '博士研究生', '硕士研究生', '硕士研究生', '本科'])
      : pick(['博士研究生', '硕士研究生', '硕士研究生', '本科', '本科', '本科'])
    const role = roles[Math.min(i, roles.length - 1)]
    // 每单位前若干名为负责人/副职，职务层次取“处级”，其余为“科级”
    const leaderCount = d.type === 'office' ? 2 : 4
    const posLevel = i < leaderCount ? '处级' : pick(['科级', '科级', '科级', '科级'])
    // 职级
    const rankIdx = randInt(1, ranks.length)
    // 状态
    let status = 'ON_JOB'
    if (birthYear <= 1964 && rnd() < 0.8) status = 'RETIRED'
    else if (status === 'ON_JOB' && rnd() < 0.02) status = pick(['TRANSFERRED', 'RESIGNED'])
    addCadre(d.id, name, gender, birthYear, pol, edu, role, posLevel, rankIdx, status)
  }
})

out.push('INSERT INTO cadre_info (name, gender, birth_date, nation, native_place, political_status, party_join_date, work_start_date, id_card, phone, email, photo_url, resume_text, full_time_education, full_time_degree, full_time_school, part_time_education, part_time_degree, part_time_school, dept_id, position, position_level, rank_id, position_start_date, position_doc_no, reward_punishment, annual_assessment, cadre_status, retirement_date, leave_date, leave_reason, create_time, update_time) VALUES')
out.push(rows.join(',\n') + ';')
out.push('')
out.push('SET FOREIGN_KEY_CHECKS=1;')
out.push('-- 干部数：' + (rows.length + topLeaders.length))

const sql = out.join('\n')
fs.writeFileSync('sql/seed-demo.sql', sql, 'utf8')
console.log('seed rows =', rows.length + topLeaders.length)
