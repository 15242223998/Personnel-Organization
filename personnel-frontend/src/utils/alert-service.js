// 智能预警数据共享模块：按事件结束时间(deadline)生成预警，并按临近程度升序排序
function fmtDate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function daysFromNow(days) {
  const d = new Date()
  d.setDate(d.getDate() + days)
  return fmtDate(d)
}

const deptList = ['党委办公室','机械工程学院','电气工程学院','信息科学与工程学院','经济管理学院','人事处','学生工作处','教务处','科研处','财务处','组织部','宣传部','土木工程学院','材料科学与工程学院']

// 预警规则默认配置（可在"预警规则管理"页面修改并持久化到 localStorage）
export const RULE_DEFAULTS = {
  retire:     { name: '到龄退休',     level: '红色', enabled: true, threshold: 12, thresholdLabel: '提前预警（月）', desc: '干部距法定退休年龄不足 N 个月时预警' },
  probation:  { name: '试用期将满',   level: '黄色', enabled: true, threshold: 3,  thresholdLabel: '提前预警（月）', desc: '任职试用期剩余不足 N 个月时预警' },
  overStaff:  { name: '三超问题',     level: '红色', enabled: true, threshold: 0,  thresholdLabel: '—',              desc: '超编制、超职数、超规格配置情况' },
  tenure:     { name: '任职年限',     level: '黄色', enabled: true, threshold: 5,  thresholdLabel: '任职年限（年）', desc: '现岗位任职满 N 年建议轮岗交流' },
  grassroots: { name: '基层履历不足', level: '黄色', enabled: true, threshold: 2,  thresholdLabel: '基层经历（年）', desc: '基层工作经历不足 N 年时预警' },
  discipline: { name: '处分影响期',   level: '黄色', enabled: true, threshold: 3,  thresholdLabel: '提前预警（月）', desc: '处分影响期剩余不足 N 个月时预警' }
}

const CONFIG_KEY = 'alert_rule_config'

// 读取规则配置（优先 localStorage，否则用默认值）
export function getRuleConfig() {
  try {
    const saved = JSON.parse(localStorage.getItem(CONFIG_KEY))
    if (saved && typeof saved === 'object') {
      // 合并默认值，防止新增字段缺失
      const merged = {}
      Object.keys(RULE_DEFAULTS).forEach(k => {
        merged[k] = { ...RULE_DEFAULTS[k], ...(saved[k] || {}) }
      })
      return merged
    }
  } catch (e) { /* ignore */ }
  return JSON.parse(JSON.stringify(RULE_DEFAULTS))
}

// 保存规则配置
export function saveRuleConfig(config) {
  localStorage.setItem(CONFIG_KEY, JSON.stringify(config))
}

/**
 * 生成智能预警数据
 * @param {object} options
 * @param {string[]} options.rules 启用的规则 key 列表（运行时勾选，默认全部）
 * @param {string} options.timeFilter 时间筛选：'all' | '3m' | '6m' | '1y'
 * @returns 按 deadline 升序排序（无截止时间的排最后）的预警数组
 */
export function generateAlerts({ rules = Object.keys(RULE_DEFAULTS), timeFilter = 'all' } = {}) {
  const config = getRuleConfig()
  const alerts = []
  const now = new Date()
  const triggerDate = fmtDate(now)

  if (rules.includes('retire') && config.retire.enabled) {
    const cfg = config.retire
    const names = ['张建国','李秀英','王志强','赵国栋','孙红梅']
    names.forEach((name, i) => {
      const months = 1 + Math.floor(Math.random() * cfg.threshold)
      alerts.push({
        category: cfg.name,
        level: cfg.level,
        title: `${name}将于${months}个月内达到退休年龄（${60 + Math.floor(Math.random() * 5)}岁），请及时办理退休手续`,
        relatedCadre: name,
        deptName: deptList[i],
        triggerDate,
        deadline: daysFromNow(30 + months * 30)
      })
    })
  }

  if (rules.includes('probation') && config.probation.enabled) {
    const cfg = config.probation
    const names = ['刘洋','陈晓红','赵伟','马丽']
    names.forEach((name, i) => {
      const months = 1 + Math.floor(Math.random() * cfg.threshold)
      alerts.push({
        category: cfg.name,
        level: cfg.level,
        title: `${name}任职试用期将于${months}个月内到期，请准备转正考核`,
        relatedCadre: name,
        deptName: deptList[i + 5],
        triggerDate,
        deadline: daysFromNow(10 + months * 30)
      })
    })
  }

  if (rules.includes('overStaff') && config.overStaff.enabled) {
    const cfg = config.overStaff
    alerts.push(
      { category: '超编制', level: cfg.level, title: '机械工程学院实有43人，核定编制40人，超编3人', relatedCadre: '-', deptName: '机械工程学院', triggerDate, deadline: null },
      { category: '超职数', level: cfg.level, title: '经济管理学院处级领导职数7人，已配备8人，超职数1人', relatedCadre: '-', deptName: '经济管理学院', triggerDate, deadline: null },
      { category: '超规格', level: cfg.level, title: '信息科学与工程学院自行增设学术副主任岗位，超出机构规格核定范围', relatedCadre: '-', deptName: '信息科学与工程学院', triggerDate, deadline: null }
    )
  }

  if (rules.includes('tenure') && config.tenure.enabled) {
    const cfg = config.tenure
    const names = ['黄永强','林芳','何明']
    const years = [cfg.threshold, cfg.threshold + 2, cfg.threshold + 5]
    names.forEach((name, i) => {
      alerts.push({
        category: cfg.name,
        level: years[i] >= 10 ? '红色' : cfg.level,
        title: `${name}在现岗位任职已满${years[i]}年，达到干部轮岗交流标准，建议启动轮岗程序`,
        relatedCadre: name,
        deptName: deptList[i + 8],
        triggerDate,
        deadline: daysFromNow(20 + i * 40)
      })
    })
  }

  if (rules.includes('grassroots') && config.grassroots.enabled) {
    const cfg = config.grassroots
    const names = ['郑文轩','杨雪']
    const depts = ['组织部','宣传部']
    alerts.push(
      { category: cfg.name, level: cfg.level, title: `${names[0]}基层工作经历不足${cfg.threshold}年（实际1年），不符合《干部任用条例》推荐条件`, relatedCadre: names[0], deptName: depts[0], triggerDate, deadline: null },
      { category: cfg.name, level: '蓝色', title: `${names[1]}无基层工作经历，影响处级干部推荐资格`, relatedCadre: names[1], deptName: depts[1], triggerDate, deadline: null }
    )
  }

  if (rules.includes('discipline') && config.discipline.enabled) {
    const cfg = config.discipline
    const names = ['赵刚','孙伟','钱峰']
    const depts = ['学生工作处','教务处','财务处']
    const monthsLeft = [cfg.threshold * 2, cfg.threshold, cfg.threshold * 4]
    const reasons = ['违规收受礼品（诫勉）','工作失职（警告）','学术不端（记过）']
    names.forEach((name, i) => {
      alerts.push({
        category: cfg.name,
        level: monthsLeft[i] <= cfg.threshold ? cfg.level : '蓝色',
        title: `${name}因"${reasons[i]}"处于处分影响期内（剩余${monthsLeft[i]}个月），暂不可参与选拔任用`,
        relatedCadre: name,
        deptName: depts[i],
        triggerDate,
        deadline: daysFromNow(monthsLeft[i] * 30)
      })
    })
  }

  // 时间范围过滤
  let result = alerts
  if (timeFilter !== 'all') {
    const months = timeFilter === '3m' ? 3 : timeFilter === '6m' ? 6 : 12
    const cutoff = new Date()
    cutoff.setMonth(cutoff.getMonth() + months)
    result = alerts.filter(a => {
      if (!a.deadline) return false
      return new Date(a.deadline) <= cutoff
    })
  }

  // 按截止时间升序排序（最临近的在前），无截止时间的排最后
  result.sort((a, b) => {
    if (!a.deadline && !b.deadline) return 0
    if (!a.deadline) return 1
    if (!b.deadline) return -1
    return new Date(a.deadline) - new Date(b.deadline)
  })

  return result
}
