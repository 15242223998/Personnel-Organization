'use strict'
/**
 * 生成"项目本身"的三张图（SVG），事实全部来自代码扫描：
 *   1) docs/项目-领域实体关系图.svg   —— 依据 modules/**_/entity 与 system/entity 的 @TableName / 字段
 *   2) docs/项目-架构图.svg           —— 依据前端 views/api/layout/router/stores + 后端 framework/modules 目录
 *   3) docs/项目-模块调用链路图.svg   —— 依据每个模块 Controller/Service(+Impl)/Mapper/entity 文件配对
 *
 * 只用 Node 内置模块（fs/path），不联网、不依赖 mermaid/CDN。
 * 运行：node .tools-er/gen-project-diagrams.js
 */
const fs = require('fs')
const path = require('path')

const ROOT = path.resolve(__dirname, '..')
const BACKEND = path.join(ROOT, 'personnel-backend', 'src', 'main', 'java', 'com', 'personnel')
const FRONTEND_SRC = path.join(ROOT, 'personnel-frontend', 'src')
const DOCS = path.join(ROOT, 'docs')
const DIMS_FILE = path.join(__dirname, 'project-diagram-dims.json')

const FONT = 'Microsoft YaHei, PingFang SC, sans-serif'
const TITLE_COLOR = '#0D47A1'

/* ------------------------------------------------------------------ */
/* 扫描工具                                                             */
/* ------------------------------------------------------------------ */

function readdirSafe(dir) {
  try { return fs.readdirSync(dir, { withFileTypes: true }) } catch (e) { return [] }
}

function walk(dir, out) {
  out = out || []
  for (const ent of readdirSafe(dir)) {
    const p = path.join(dir, ent.name)
    if (ent.isDirectory()) walk(p, out)
    else out.push(p)
  }
  return out
}

function moduleOfBackendFile(file) {
  const rel = path.relative(BACKEND, file).split(path.sep)
  if (rel[0] === 'modules') return rel[1]
  if (rel[0] === 'system') return 'system'
  return 'other'
}

function cleanComment(s) {
  if (!s) return ''
  return String(s)
    .replace(/\r?\n/g, ' ')
    .replace(/^\s*\*+\s?/gm, '')
    .replace(/\s+/g, ' ')
    .trim()
}

/* ------------------------------------------------------------------ */
/* 1) 实体解析                                                          */
/* ------------------------------------------------------------------ */

const INHERITED_FIELDS = [
  { name: 'createTime', type: 'LocalDateTime', comment: 'BaseEntity 继承·创建时间', pk: false, inherited: true },
  { name: 'updateTime', type: 'LocalDateTime', comment: 'BaseEntity 继承·更新时间', pk: false, inherited: true },
  { name: 'createBy', type: 'Long', comment: 'BaseEntity 继承·创建人', pk: false, inherited: true },
  { name: 'updateBy', type: 'Long', comment: 'BaseEntity 继承·更新人', pk: false, inherited: true },
  { name: 'deleted', type: 'Integer', comment: 'BaseEntity 继承·逻辑删除', pk: false, inherited: true }
]

function parseEntityFile(file) {
  const src = fs.readFileSync(file, 'utf8')
  const className = (src.match(/public\s+class\s+(\w+)/) || [])[1] || path.basename(file, '.java')
  const tableMatch = src.match(/@TableName\s*\(\s*(?:value\s*=\s*)?"([^"]+)"/)
  const tableName = tableMatch ? tableMatch[1] : ''
  const extendsBase = /extends\s+BaseEntity\b/.test(src)

  const lines = src.split(/\r?\n/)
  const fields = []
  let pendingComments = []
  let annotations = []
  let inBlock = false
  let blockBuf = ''

  for (const raw of lines) {
    const line = raw.trim()

    if (inBlock) {
      const end = line.indexOf('*/')
      if (end >= 0) {
        blockBuf += ' ' + line.slice(0, end)
        pendingComments.push(cleanComment(blockBuf))
        blockBuf = ''
        inBlock = false
      } else {
        blockBuf += ' ' + line
      }
      continue
    }
    if (line.startsWith('/**') || line.startsWith('/*')) {
      const start = line.indexOf('/*')
      const body = line.slice(start + 2)
      const end = body.indexOf('*/')
      if (end >= 0) pendingComments.push(cleanComment(body.slice(0, end)))
      else { inBlock = true; blockBuf = body }
      continue
    }
    if (line.startsWith('//')) { pendingComments.push(cleanComment(line.slice(2))); continue }
    if (line.startsWith('@')) { annotations.push(line); continue }

    const m = /^private\s+(?:static\s+|final\s+)*([\w<>\[\]\.,\s]+?)\s+(\w+)\s*(?:=[^;]*)?;\s*$/.exec(line)
    if (m) {
      const ann = annotations.join(' ')
      fields.push({
        name: m[2],
        type: m[1].trim(),
        comment: pendingComments.join(' ').trim(),
        pk: /@TableId\b/.test(ann),
        transient: /exist\s*=\s*false/.test(ann),
        logicDelete: /@TableLogic/.test(ann)
      })
      pendingComments = []
      annotations = []
      continue
    }

    if (line === '') { annotations = []; continue }
    // 其余代码行（包声明/类声明/方法等）：清空挂起的状态，避免注释串到下个字段
    annotations = []
    pendingComments = []
  }

  if (extendsBase) {
    for (const f of INHERITED_FIELDS) fields.push(Object.assign({}, f))
  }

  return {
    className,
    tableName,
    module: moduleOfBackendFile(file),
    file,
    extendsBase,
    fields
  }
}

function scanEntities() {
  const files = walk(BACKEND).filter(f => /[\\/]entity[\\/][^\\/]+\.java$/.test(f))
  const entities = files.map(parseEntityFile)
  entities.sort((a, b) => (a.module === b.module ? a.className.localeCompare(b.className) : 0))
  return entities
}

/* ------------------------------------------------------------------ */
/* 2) 后端模块扫描                                                      */
/* ------------------------------------------------------------------ */

const MODULE_ORDER = ['cadre', 'transfer', 'appointment', 'assessment', 'daily', 'organization', 'supervision', 'system', 'statistics', 'notice']
const MODULE_LABEL = {
  cadre: 'cadre 干部档案',
  transfer: 'transfer 干部调配/职级晋升',
  appointment: 'appointment 干部任免',
  assessment: 'assessment 干部考核',
  daily: 'daily 日常事务',
  organization: 'organization 组织机构',
  supervision: 'supervision 干部监督',
  system: 'system 系统管理',
  statistics: 'statistics 统计分析',
  notice: 'notice 消息通知'
}
const MODULE_COLOR = {
  cadre: '#1565C0',
  transfer: '#00897B',
  appointment: '#6A1B9A',
  assessment: '#EF6C00',
  daily: '#2E7D32',
  organization: '#AD1457',
  supervision: '#C62828',
  system: '#455A64',
  statistics: '#0277BD',
  notice: '#5D4037',
  other: '#607D8B'
}

function classBaseOf(file, suffix) {
  return path.basename(file, '.java').replace(new RegExp(suffix + '$'), '')
}

function scanModules(entities) {
  const modulesDir = path.join(BACKEND, 'modules')
  const names = readdirSafe(modulesDir).filter(d => d.isDirectory()).map(d => d.name)
  if (fs.existsSync(path.join(BACKEND, 'system'))) names.push('system')

  const modules = []
  for (const name of names) {
    const dir = name === 'system' ? path.join(BACKEND, 'system') : path.join(modulesDir, name)
    const files = walk(dir).filter(f => f.endsWith('.java'))
    const mod = {
      name,
      label: MODULE_LABEL[name] || name,
      color: MODULE_COLOR[name] || MODULE_COLOR.other,
      controllers: [],
      serviceImpls: [],
      services: [],
      mappers: [],
      entities: entities.filter(e => e.module === name)
    }
    for (const f of files) {
      const cls = path.basename(f, '.java')
      if (/ServiceImpl$/.test(cls)) mod.serviceImpls.push(cls)
      else if (/Service$/.test(cls)) mod.services.push(cls)
      else if (/Mapper$/.test(cls)) mod.mappers.push(cls)
      else if (/Controller$/.test(cls)) mod.controllers.push(cls)
    }
    mod.controllers.sort()
    mod.services.sort()
    mod.serviceImpls.sort()
    mod.mappers.sort()
    if (!mod.controllers.length && !mod.services.length && !mod.serviceImpls.length && !mod.mappers.length && !mod.entities.length) continue
    modules.push(mod)
  }
  modules.sort((a, b) => {
    const ia = MODULE_ORDER.indexOf(a.name), ib = MODULE_ORDER.indexOf(b.name)
    return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib)
  })
  return modules
}

/* ------------------------------------------------------------------ */
/* 3) 前端扫描                                                          */
/* ------------------------------------------------------------------ */

function scanFrontend() {
  const viewsDir = path.join(FRONTEND_SRC, 'views')
  const groups = []
  const rootPages = []
  for (const ent of readdirSafe(viewsDir)) {
    if (ent.isDirectory()) {
      const files = readdirSafe(path.join(viewsDir, ent.name))
        .filter(f => f.isFile() && f.name.endsWith('.vue'))
        .map(f => f.name.replace(/\.vue$/, ''))
        .sort()
      groups.push({ name: ent.name, pages: files })
    } else if (ent.isFile() && ent.name.endsWith('.vue')) {
      rootPages.push(ent.name.replace(/\.vue$/, ''))
    }
  }
  groups.sort((a, b) => {
    const ia = MODULE_ORDER.indexOf(a.name), ib = MODULE_ORDER.indexOf(b.name)
    return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib)
  })
  const pageTotal = groups.reduce((n, g) => n + g.pages.length, 0) + rootPages.length

  const apiDir = path.join(FRONTEND_SRC, 'api')
  const apiFiles = readdirSafe(apiDir).filter(f => f.isFile() && f.name.endsWith('.js')).map(f => f.name).sort()

  const storesDir = path.join(FRONTEND_SRC, 'stores')
  const storeFiles = readdirSafe(storesDir).filter(f => f.isFile()).map(f => f.name).sort()

  const utilsDir = path.join(FRONTEND_SRC, 'utils')
  const utilFiles = readdirSafe(utilsDir).filter(f => f.isFile()).map(f => f.name).sort()

  return {
    groups,
    rootPages: rootPages.sort(),
    pageTotal,
    apiFiles,
    storeFiles,
    utilFiles,
    hasLayout: fs.existsSync(path.join(FRONTEND_SRC, 'layout', 'Layout.vue')),
    hasRouter: fs.existsSync(path.join(FRONTEND_SRC, 'router', 'index.js')),
    hasWatermark: fs.existsSync(path.join(FRONTEND_SRC, 'App.vue')) && /app-watermark/.test(fs.readFileSync(path.join(FRONTEND_SRC, 'App.vue'), 'utf8'))
  }
}

/* ------------------------------------------------------------------ */
/* 4) 调用链路                                                          */
/* ------------------------------------------------------------------ */

function stripSuffix(cls, suffix) {
  return cls.endsWith(suffix) ? cls.slice(0, cls.length - suffix.length) : cls
}

function fuzzyMatch(list, suffix, base) {
  let hit = list.find(x => stripSuffix(x.className, suffix) === base)
  if (hit) return hit
  hit = list.find(x => {
    const b = stripSuffix(x.className, suffix)
    return b.startsWith(base) || base.startsWith(b)
  })
  return hit || null
}

function buildChains(entities, modules) {
  const chains = []
  for (const mod of modules) {
    const entityObjs = mod.entities.map(e => ({ className: e.className, entity: e }))
    const svcObjs = mod.services.map(s => ({ className: s })).concat(mod.serviceImpls.map(s => ({ className: s })))
    const mapperObjs = mod.mappers.map(m => ({ className: m }))
    for (const ctrl of mod.controllers) {
      const base = stripSuffix(ctrl, 'Controller')
      const svc = fuzzyMatch(svcObjs, 'Service', base) || fuzzyMatch(mod.serviceImpls.map(s => ({ className: s })), 'ServiceImpl', base)
      const mapper = fuzzyMatch(mapperObjs, 'Mapper', base)
      const entity = entityObjs.find(e => e.className === base)
        || entityObjs.find(e => e.className.startsWith(base) || base.startsWith(e.className))
        || null
      chains.push({
        module: mod.name,
        moduleLabel: mod.label,
        color: mod.color,
        controller: ctrl,
        service: svc ? svc.className : '',
        mapper: mapper ? mapper.className : '',
        table: entity && entity.entity.tableName ? entity.entity.tableName : '',
        entityClass: entity ? entity.entity.className : ''
      })
    }
  }
  return chains
}

/* ------------------------------------------------------------------ */
/* 关系推断（实体字段 -> 目标实体类）                                    */
/* ------------------------------------------------------------------ */

const FIELD_TARGET = {
  dept: 'Organization',
  department: 'Organization',
  organization: 'Organization',
  parent: 'Organization',
  user: 'SysUser',
  create: 'SysUser',
  update: 'SysUser',
  approver: 'SysUser',
  approve: 'SysUser',
  applicant: 'SysUser',
  voter: 'SysUser',
  targetuser: 'SysUser',
  role: 'SysRole',
  cadre: 'CadreInfo',
  targetcadre: 'CadreInfo',
  scheme: 'AssessmentScheme',
  indicator: 'AssessmentIndicator',
  dimension: 'AssessmentDimension',
  target: 'AssessmentTarget',
  annual: 'AssessmentAnnual',
  rule: 'SuperviseAlertRule',
  alert: 'SuperviseAlert',
  audit: 'SuperviseAudit',
  complaint: 'SuperviseComplaint',
  integrity: 'SuperviseIntegrity',
  admonish: 'SuperviseAdmonish',
  personalreport: 'SupervisePersonalReport',
  process: 'AppointProcess',
  motion: 'AppointMotion',
  decision: 'AppointDecision',
  publicity: 'AppointPublicity',
  recommend: 'AppointRecommend',
  record: 'AppointRecord',
  investigation: 'AppointInvestigation',
  rank: 'OrganizationRank',
  position: 'PositionLevel',
  quota: 'StaffingQuota',
  policy: 'PolicyDocument',
  dict: 'SysDictType',
  template: 'SysRosterTemplate',
  training: 'DailyTraining'
}

function buildRelations(entities) {
  const byClass = new Map(entities.map(e => [e.className, e]))
  const classNames = entities.map(e => e.className)
  const dedupe = new Map() // key: source|target -> {fields:Set}
  let matchedFields = 0
  let candidateFields = 0

  const STRIP_PREFIX = ['from', 'to', 'old', 'new', 'selected', 'source', 'target', 'related', 'ref', 'parent']

  function exactByClass(b) {
    return entities.find(e => e.className.toLowerCase() === b) || null
  }
  function fixedByKey(b) {
    const cls = FIELD_TARGET[b]
    return cls && byClass.has(cls) ? byClass.get(cls) : null
  }

  function resolveTarget(base, fromModule) {
    const b = base.toLowerCase()
    // 1) 固定映射（最可信）
    let hit = fixedByKey(b)
    if (hit) return hit
    // 2) 与实体类名完全一致
    hit = exactByClass(b)
    if (hit) return hit
    // 3) 去掉 from_/to_/old_/new_/selected_ 等前缀后，再走固定映射 / 完全一致
    for (const p of STRIP_PREFIX) {
      if (b.startsWith(p) && b.length > p.length) {
        const b2 = b.slice(p.length)
        hit = fixedByKey(b2) || exactByClass(b2)
        if (hit) return hit
        break
      }
    }
    // 4) 兜底：类名以该字段基名开头（取最短，优先同模块）
    let cands = entities.filter(e => e.className.toLowerCase().startsWith(b) && e.className.length <= b.length + 12)
    if (!cands.length) return null
    if (cands.length > 1) {
      const same = cands.filter(e => e.module === fromModule)
      if (same.length === 1) return same[0]
      cands = cands.slice().sort((x, y) => x.className.length - y.className.length)
    }
    return cands[0]
  }

  for (const ent of entities) {
    for (const f of ent.fields) {
      if (f.pk) continue
      const m = /^(.*?)(Id|By)$/.exec(f.name)
      if (!m) continue
      const base = m[1]
      if (!base || base.toLowerCase() === 'id') continue
      candidateFields++
      const target = resolveTarget(base, ent.module)
      if (!target || target.className === ent.className) continue
      matchedFields++
      const key = ent.className + '|' + target.className
      if (!dedupe.has(key)) dedupe.set(key, { source: ent.className, target: target.className, fields: new Set() })
      dedupe.get(key).fields.add(f.name)
    }
  }
  const relations = Array.from(dedupe.values()).map(r => ({
    source: r.source,
    target: r.target,
    fields: Array.from(r.fields).sort()
  }))
  return { relations, candidateFields, matchedFields }
}

/* ------------------------------------------------------------------ */
/* SVG 基础工具                                                         */
/* ------------------------------------------------------------------ */

function esc(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

function tw(s, fs) {
  let w = 0
  for (const ch of String(s)) w += /[\u2e80-\u9fff\uff00-\uffef\u3000-\u303f]/.test(ch) ? fs : fs * 0.55
  return w
}

function truncate(s, maxW, fs) {
  s = String(s == null ? '' : s)
  if (tw(s, fs) <= maxW) return s
  let out = ''
  for (const ch of s) {
    if (tw(out + ch + '…', fs) > maxW) break
    out += ch
  }
  return out + '…'
}

function wrapText(s, maxW, fs) {
  s = String(s == null ? '' : s)
  if (!s) return ['']
  const lines = []
  let cur = ''
  for (const ch of s) {
    if (tw(cur + ch, fs) > maxW && cur) { lines.push(cur); cur = ch }
    else cur += ch
  }
  lines.push(cur)
  return lines
}

function txt(x, y, s, opt) {
  opt = opt || {}
  const size = opt.size || 13
  return '<text x="' + x + '" y="' + y + '" font-size="' + size
    + '" fill="' + (opt.fill || '#1F2937')
    + '"' + (opt.weight ? ' font-weight="' + opt.weight + '"' : '')
    + (opt.anchor ? ' text-anchor="' + opt.anchor + '"' : '')
    + (opt.opacity != null ? ' opacity="' + opt.opacity + '"' : '')
    + (opt.stroke ? ' stroke="' + opt.stroke + '" stroke-width="' + (opt.strokeWidth || 3) + '" paint-order="stroke" stroke-linejoin="round"' : '')
    + '>' + esc(s) + '</text>'
}

function rect(x, y, w, h, opt) {
  opt = opt || {}
  return '<rect x="' + x + '" y="' + y + '" width="' + w + '" height="' + h
    + '" rx="' + (opt.rx != null ? opt.rx : 8) + '"'
    + ' fill="' + (opt.fill || '#FFFFFF') + '"'
    + (opt.stroke ? ' stroke="' + opt.stroke + '" stroke-width="' + (opt.sw || 1.5) + '"' : ' stroke="none"')
    + (opt.opacity != null ? ' opacity="' + opt.opacity + '"' : '')
    + (opt.dash ? ' stroke-dasharray="' + opt.dash + '"' : '')
    + '/>'
}

function line(x1, y1, x2, y2, opt) {
  opt = opt || {}
  return '<line x1="' + x1 + '" y1="' + y1 + '" x2="' + x2 + '" y2="' + y2
    + '" stroke="' + (opt.stroke || '#94A3B8') + '" stroke-width="' + (opt.sw || 1.6) + '"'
    + (opt.marker ? ' marker-end="url(#' + opt.marker + ')"' : '')
    + (opt.opacity != null ? ' opacity="' + opt.opacity + '"' : '')
    + '/>'
}

function svgOpen(w, h) {
  return '<?xml version="1.0" encoding="UTF-8"?>\n'
    + '<svg xmlns="http://www.w3.org/2000/svg" width="' + w + '" height="' + h
    + '" viewBox="0 0 ' + w + ' ' + h + '" font-family="' + FONT + '">\n'
}

function defsMarkers() {
  const mk = (id, color) => '<marker id="' + id + '" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
    + '<path d="M 0 0 L 10 5 L 0 10 z" fill="' + color + '"/></marker>'
  return '<defs>' + mk('arrowGray', '#94A3B8') + mk('arrowBlue', '#1565C0') + mk('arrowDark', '#37474F')
    + mk('arrowOrange', '#EF6C00') + '</defs>\n'
}

function pageTitle(w, title, subtitle) {
  let s = rect(0, 0, w, 118, { fill: '#FFFFFF', rx: 0 })
  s += rect(0, 0, w, 8, { fill: TITLE_COLOR, rx: 0 })
  s += txt(w / 2, 58, title, { size: 30, weight: 700, fill: TITLE_COLOR, anchor: 'middle' })
  s += txt(w / 2, 92, subtitle, { size: 15, fill: '#546E7A', anchor: 'middle' })
  return s
}

function footer(w, h, lines) {
  let s = line(60, h - 84, w - 60, h - 84, { stroke: '#CFD8DC', sw: 1.2 })
  lines.forEach((t, i) => {
    s += txt(w / 2, h - 84 + 30 + i * 24, t, { size: 13.5, fill: i === 0 ? '#37474F' : '#607D8B', anchor: 'middle' })
  })
  return s
}

/* ------------------------------------------------------------------ */
/* 图 A：领域实体关系图                                                  */
/* ------------------------------------------------------------------ */

const A_COLS = 6
const A_BOX_W = 440
const A_GAP_X = 30
const A_ROW_H = 20
const A_HEAD_H = 34
const A_CAP = 30

function buildEntityDiagram(entities, relations) {
  const CANVAS_W = 2960
  const contentW = A_COLS * A_BOX_W + (A_COLS - 1) * A_GAP_X
  const blockW = contentW + 40
  const blockX = (CANVAS_W - blockW) / 2

  const modules = MODULE_ORDER.filter(m => entities.some(e => e.module === m))
  const boxMap = new Map()
  const blocks = []

  let cursorY = 118 + 24
  for (const modName of modules) {
    const list = entities.filter(e => e.module === modName).sort((a, b) => a.className.localeCompare(b.className))
    const cols = Math.min(A_COLS, list.length)
    const rowCount = Math.ceil(list.length / cols)
    const rowHeights = []
    for (let r = 0; r < rowCount; r++) {
      const slice = list.slice(r * cols, (r + 1) * cols)
      const heights = slice.map(e => A_HEAD_H + Math.min(e.fields.length, A_CAP + 1) * A_ROW_H + 10)
      rowHeights.push(Math.max.apply(null, heights))
    }
    const rowsTotal = rowHeights.reduce((a, b) => a + b, 0) + (rowCount - 1) * 26
    const blockH = 48 + 16 + rowsTotal + 16
    const block = {
      module: modName,
      label: MODULE_LABEL[modName] || modName,
      color: MODULE_COLOR[modName] || MODULE_COLOR.other,
      x: blockX, y: cursorY, w: blockW, h: blockH,
      count: list.length
    }
    blocks.push(block)

    let rowY = cursorY + 48 + 16
    for (let r = 0; r < rowCount; r++) {
      const slice = list.slice(r * cols, (r + 1) * cols)
      const n = slice.length
      const rowContentW = n * A_BOX_W + (n - 1) * A_GAP_X
      const startX = blockX + (blockW - rowContentW) / 2
      slice.forEach((e, i) => {
        const x = startX + i * (A_BOX_W + A_GAP_X)
        const h = A_HEAD_H + Math.min(e.fields.length, A_CAP + 1) * A_ROW_H + 10
        boxMap.set(e.className, { x, y: rowY, w: A_BOX_W, h, entity: e })
      })
      rowY += rowHeights[r] + 26
    }
    cursorY += blockH + 22
  }

  const CANVAS_H = Math.round(cursorY - 22 + 110)

  let s = svgOpen(CANVAS_W, CANVAS_H)
  s += defsMarkers()
  s += rect(0, 0, CANVAS_W, CANVAS_H, { fill: '#FFFFFF', rx: 0 })
  s += pageTitle(CANVAS_W, '项目-领域实体关系图（依据后端实体类源码自动梳理）',
    '数据来源：personnel-backend/src/main/java/com/personnel/**/entity/*.java 的 @TableName 与字段声明；非数据库 ER 图，不引用 SQL DDL')

  // 模块区块背景
  for (const b of blocks) {
    s += rect(b.x, b.y, b.w, b.h, { fill: '#F7F9FC', stroke: '#E0E6ED', rx: 12, sw: 1.4 })
    s += rect(b.x, b.y, b.w, 48, { fill: b.color, rx: 12, opacity: 0.12 })
    s += rect(b.x, b.y + 36, b.w, 12, { fill: b.color, rx: 0, opacity: 0.12 })
    s += txt(b.x + 18, b.y + 32, '模块：' + b.label, { size: 19, weight: 700, fill: b.color })
    s += txt(b.x + b.w - 18, b.y + 32, '实体 ' + b.count + ' 个', { size: 14, fill: '#546E7A', anchor: 'end' })
  }

  // 关系曲线（画在实体框下方，避免盖住文字）
  for (const rel of relations) {
    const a = boxMap.get(rel.source)
    const b = boxMap.get(rel.target)
    if (!a || !b) continue
    const p1 = edgePoint(a, b)
    const p2 = edgePoint(b, a)
    const dx = p2.x - p1.x, dy = p2.y - p1.y
    const dist = Math.max(1, Math.sqrt(dx * dx + dy * dy))
    const nx = -dy / dist, ny = dx / dist
    const bow = Math.min(70, dist * 0.12)
    const c1x = p1.x + dx * 0.33 + nx * bow, c1y = p1.y + dy * 0.33 + ny * bow
    const c2x = p1.x + dx * 0.66 + nx * bow, c2y = p1.y + dy * 0.66 + ny * bow
    s += '<path d="M ' + r3(p1.x) + ' ' + r3(p1.y) + ' C ' + r3(c1x) + ' ' + r3(c1y) + ' ' + r3(c2x) + ' ' + r3(c2y)
      + ' ' + r3(p2.x) + ' ' + r3(p2.y) + '" fill="none" stroke="#90A4AE" stroke-width="1.2" opacity="0.42" marker-end="url(#arrowGray)"/>'
    const mx = (p1.x + p2.x) / 2 + nx * bow * 0.5
    const my = (p1.y + p2.y) / 2 + ny * bow * 0.5
    if (dist > 120) {
      s += txt(r3(mx), r3(my), truncate(rel.fields.join('/'), 150, 12), { size: 12, fill: '#607D8B', anchor: 'middle', stroke: '#FFFFFF', strokeWidth: 3.4 })
    }
  }

  // 实体框
  for (const e of entities) {
    const box = boxMap.get(e.className)
    if (!box) continue
    const color = MODULE_COLOR[e.module] || MODULE_COLOR.other
    const shown = Math.min(e.fields.length, A_CAP)
    const extra = e.fields.length - shown
    const h = box.h
    s += rect(box.x, box.y, box.w, h, { fill: '#FFFFFF', stroke: color, rx: 8, sw: 1.4 })
    s += rect(box.x, box.y, box.w, A_HEAD_H, { fill: color, rx: 8 })
    s += rect(box.x, box.y + A_HEAD_H - 10, box.w, 10, { fill: color, rx: 0 })
    const header = e.className + (e.tableName ? '（@TableName ' + e.tableName + '）' : '（未标注 @TableName）')
    s += txt(box.x + 12, box.y + 23, truncate(header, box.w - 24, 14.5), { size: 14.5, weight: 700, fill: '#FFFFFF' })

    let fy = box.y + A_HEAD_H + 15
    for (let i = 0; i < shown; i++) {
      const f = e.fields[i]
      const pkColor = '#0D47A1'
      let x = box.x + 12
      if (f.pk) {
        s += txt(x, fy, 'PK', { size: 12, weight: 700, fill: '#C62828' })
        x += 26
      } else {
        x += 26
      }
      const nameStr = f.name
      s += txt(x, fy, nameStr, { size: 13, weight: f.pk ? 700 : 400, fill: f.pk ? pkColor : '#1F2937' })
      const nameW = tw(nameStr, 13)
      const typeX = x + nameW + 10
      s += txt(typeX, fy, truncate(f.type, 118, 11.5), { size: 11.5, fill: '#0277BD' })
      const typeW = Math.min(tw(f.type, 11.5), 118)
      const commentX = typeX + typeW + 12
      const roomW = box.x + box.w - 12 - commentX
      if (f.comment && roomW > 30) {
        s += txt(commentX, fy, truncate(f.comment, roomW, 13), { size: 13, fill: '#90A4AE' })
      }
      fy += A_ROW_H
    }
    if (extra > 0) {
      s += txt(box.x + 12, fy, '…… 其余 ' + extra + ' 个字段（详见实体源码）', { size: 13, fill: '#B0BEC5' })
    }
  }

  const tableCount = entities.filter(e => e.tableName).length
  const fieldCount = entities.reduce((n, e) => n + e.fields.length, 0)
  const root = relations.filter(r => boxMap.get(r.source) && boxMap.get(r.target)).length

  s += footer(CANVAS_W, CANVAS_H, [
    '统计：实体 ' + entities.length + ' 个（其中标注 @TableName 的 ' + tableCount + ' 个）　|　模块 ' + blocks.length + ' 个　|　字段 ' + fieldCount + ' 条　|　实体关系 ' + root + ' 条',
    '主键以 PK 标识并加粗深蓝；灰色带箭头曲线表示由字段名推断的引用（箭头指向被引用实体），仅当目标实体类真实存在时绘制；非数据库迁移外键，不照抄 SQL DDL。',
    '生成脚本：.tools-er/gen-project-diagrams.js（Node 内置模块，扫描源码自动生成）'
  ])

  s += '</svg>\n'
  return { svg: s, width: CANVAS_W, height: CANVAS_H }
}

function r3(n) { return Math.round(n * 10) / 10 }

function edgePoint(box, towards) {
  const cx = box.x + box.w / 2, cy = box.y + box.h / 2
  const tx = towards.x + towards.w / 2, ty = towards.y + towards.h / 2
  let dx = tx - cx, dy = ty - cy
  if (dx === 0 && dy === 0) return { x: cx, y: cy }
  const sx = dx === 0 ? Infinity : (box.w / 2) / Math.abs(dx)
  const sy = dy === 0 ? Infinity : (box.h / 2) / Math.abs(dy)
  const t = Math.min(sx, sy)
  return { x: cx + dx * t, y: cy + dy * t }
}

/* ------------------------------------------------------------------ */
/* 图 B：项目架构图                                                     */
/* ------------------------------------------------------------------ */

function buildArchitectureDiagram(ctx) {
  const CANVAS_W = 3200
  const parts = []

  const y0 = 150
  const colHeaderH = 54

  // ---- 前端列 ----
  const fx = 360, fw = 1080
  const fe = []
  let fy = y0 + colHeaderH + 14
  const innerW = fw - 40
  function subBox(title, body, h) {
    fe.push({ title, body, y: fy, h })
    fy += h + 12
  }
  subBox('Layout 布局框架（src/layout/Layout.vue）',
    '顶部蓝色导航 + 侧栏菜单 + 消息通知中心；App.vue 全局斜向浅色水印层（不拦截鼠标/键盘事件）', 74)
  subBox('router 路由与守卫（src/router/index.js）',
    'createWebHistory；beforeEach 校验 localStorage.token，未登录跳 /login；/tablet 免登录平板投票页', 74)
  subBox('stores 状态管理（Pinia · src/stores/' + ctx.front.storeFiles.join(', ') + '）',
    '登录用户 / 权限 / 菜单状态；token 与 serverConn（服务器地址）持久化在 localStorage', 74)
  subBox('api 接口层（src/api 共 ' + ctx.front.apiFiles.length + ' 个文件）',
    ctx.front.apiFiles.join('、'), 74)
  subBox('utils 工具层（src/utils）',
    'request.js（axios 拦截器：Bearer 注入 / 服务器基址 / 401 跳登录）、excel.js、export-store.js、perms.js', 74)

  const viewLines = []
  const viewGroups = ctx.front.groups.map(g => ({ name: g.name, pages: g.pages }))
  if (ctx.front.rootPages.length) viewGroups.unshift({ name: '公共入口', pages: ctx.front.rootPages })
  for (const g of viewGroups) {
    const seg = g.name + '（' + g.pages.length + ' 页）：' + g.pages.join('、')
    for (const l of wrapText(seg, innerW - 24, 13)) viewLines.push(l)
  }
  const viewsH = 42 + viewLines.length * 21 + 14

  const frontContentH = fy - (y0 + colHeaderH + 14) - 12 + viewsH
  const frontColH = colHeaderH + 14 + frontContentH + 16

  // ---- 业务模块列（后端 modules） ----
  const bx = 2360, bw = 800
  const modRows = ctx.backendModules.map(m => ({
    name: m.name,
    label: m.label,
    ctrl: m.controllers.length,
    svc: m.services.length + m.serviceImpls.length,
    mapper: m.mappers.length,
    ent: m.entities.length,
    color: m.color
  }))
  const bizContentH = modRows.length * 78 + 4
  const bizColH = colHeaderH + 14 + bizContentH + 16

  // ---- 后端框架列的卡片 ----
  const fwx = 1800, fww = 520
  const fwCards = [
    ['Spring Security 过滤器链', 'SecurityConfig：无状态会话，/api/user/login、/api/db/probe 等放行，其余需 JWT'],
    ['JwtAuthenticationFilter / JwtUtil', '解析 Authorization: Bearer，构建 LoginUser 写入 SecurityContext'],
    ['DataScopeHelper 数据权限', '按 SysUser.userType 收敛部门可见范围（1~4 全量 / 5 本级及下级 / 6 本部门）'],
    ['CacheStore 缓存门面', 'app.cache.backend=auto：优先 Redis，连接失败自动降级进程内存（登录失败计数 auth:fail:*）'],
    ['DbAlignService / DbConnController', 'dynamic-datasource 运行时热切换数据源，持久化到 run/db-conn.json，启动时自动恢复'],
    ['GlobalExceptionHandler / MybatisPlusConfig', '统一 Result 返回、MyMetaObjectHandler 自动填充 createBy/createTime、逻辑删除']
  ]
  const fwContentH = fwCards.length * 106
  const fwColH = colHeaderH + 14 + fwContentH + 16

  const mainH = Math.max(frontColH, bizColH, fwColH, 700)

  // ---- 基础设施带 ----
  const infraY = y0 + mainH + 46
  const infraH = 300

  const mechY = infraY + infraH + 46
  const mechH = 260

  const CANVAS_H = Math.round(mechY + mechH + 120)

  let s = svgOpen(CANVAS_W, CANVAS_H)
  s += defsMarkers()
  s += rect(0, 0, CANVAS_W, CANVAS_H, { fill: '#FFFFFF', rx: 0 })
  s += pageTitle(CANVAS_W, '项目-架构图（依据项目源码目录与技术栈自动梳理）',
    '技术栈取自 personnel-backend/pom.xml、application.yml 与 personnel-frontend/package.json；页面/类数量为源码扫描结果')

  function column(x, w, h, title, color) {
    let o = rect(x, y0, w, h, { fill: '#FBFCFE', stroke: '#DCE3EA', rx: 14, sw: 1.5 })
    o += rect(x, y0, w, colHeaderH, { fill: color, opacity: 0.14, rx: 14 })
    o += rect(x, y0 + colHeaderH - 14, w, 14, { fill: color, opacity: 0.14, rx: 0 })
    o += txt(x + 18, y0 + 35, title, { size: 18, weight: 700, fill: color })
    return o
  }

  // 终端列
  s += column(40, 280, mainH, '终端层', '#455A64')
  s += rect(60, y0 + colHeaderH + 16, 240, 150, { fill: '#FFFFFF', stroke: '#90A4AE', rx: 10, sw: 1.4 })
  s += txt(180, y0 + colHeaderH + 48, '浏览器', { size: 16, weight: 700, fill: '#37474F', anchor: 'middle' })
  s += txt(180, y0 + colHeaderH + 74, '桌面端 / 平板端', { size: 13, fill: '#607D8B', anchor: 'middle' })
  s += txt(180, y0 + colHeaderH + 104, '桌面：Layout 全功能', { size: 13, fill: '#607D8B', anchor: 'middle' })
  s += txt(180, y0 + colHeaderH + 128, '平板：/tablet 投票页', { size: 13, fill: '#607D8B', anchor: 'middle' })
  s += rect(60, y0 + colHeaderH + 190, 240, 190, { fill: '#FFFFFF', stroke: '#B0BEC5', rx: 10, sw: 1.2, dash: '5 4' })
  s += txt(180, y0 + colHeaderH + 220, '关键机制标签', { size: 14, weight: 700, fill: '#37474F', anchor: 'middle' })
  const termTags = ['JWT 鉴权', '模块权限', '数据权限', '登录失败节流']
  termTags.forEach((t, i) => {
    s += rect(80, y0 + colHeaderH + 238 + i * 34, 200, 28, { fill: '#ECEFF1', rx: 14 })
    s += txt(180, y0 + colHeaderH + 257 + i * 34, t, { size: 13, fill: '#455A64', anchor: 'middle' })
  })

  // 前端列
  s += column(fx, fw, mainH, '前端层 Vue 3（Vue 3.4 + Vite 5 + Element Plus 2.7 + ECharts 5.5 + Pinia 2 + axios）', '#1565C0')
  let fyy = y0 + colHeaderH + 14
  for (const b of fe) {
    s += rect(fx + 20, b.y, innerW, b.h, { fill: '#FFFFFF', stroke: '#BBDEFB', rx: 10, sw: 1.3 })
    s += txt(fx + 34, b.y + 26, b.title, { size: 14.5, weight: 700, fill: '#0D47A1' })
    s += txt(fx + 34, b.y + 50, truncate(b.body, innerW - 28, 13), { size: 13, fill: '#546E7A' })
    fyy = b.y + b.h + 12
  }
  s += rect(fx + 20, fyy, innerW, viewsH, { fill: '#FFFFFF', stroke: '#BBDEFB', rx: 10, sw: 1.3 })
  s += txt(fx + 34, fyy + 26, 'views 业务页面清单（共 ' + ctx.front.pageTotal + ' 个 .vue 页面，按模块分组）', { size: 14.5, weight: 700, fill: '#0D47A1' })
  viewLines.forEach((l, i) => {
    s += txt(fx + 34, fyy + 50 + i * 21, l, { size: 13, fill: '#37474F' })
  })

  // 接入列
  const ctx1x = 1480, ctx1w = 280
  s += column(ctx1x, ctx1w, mainH, '接入层', '#00695C')
  s += rect(ctx1x + 20, y0 + colHeaderH + 16, ctx1w - 40, 190, { fill: '#FFFFFF', stroke: '#80CBC4', rx: 10, sw: 1.4 })
  s += txt(ctx1x + ctx1w / 2, y0 + colHeaderH + 48, 'HTTP /api', { size: 16, weight: 700, fill: '#00695C', anchor: 'middle' })
  ;['axios 实例 baseURL=/api', 'Authorization: Bearer <JWT>', '默认 30s 超时', '401 → 清除 token 跳登录', '登录页可自定义服务器地址'].forEach((t, i) => {
    s += txt(ctx1x + 32, y0 + colHeaderH + 78 + i * 26, '· ' + t, { size: 13, fill: '#546E7A' })
  })

  // 后端框架列
  s += column(fwx, fww, mainH, '后端框架层 framework/*（Spring Boot 3.2.5 · Java 17 · MyBatis-Plus 3.5.5）', '#37474F')
  fwCards.forEach((c, i) => {
    const cy = y0 + colHeaderH + 14 + i * 106
    s += rect(fwx + 20, cy, fww - 40, 92, { fill: '#FFFFFF', stroke: '#CFD8DC', rx: 10, sw: 1.3 })
    s += txt(fwx + 34, cy + 26, c[0], { size: 14, weight: 700, fill: '#263238' })
    wrapText(c[1], fww - 68, 13).slice(0, 3).forEach((l, j) => {
      s += txt(fwx + 34, cy + 48 + j * 19, l, { size: 13, fill: '#607D8B' })
    })
  })

  // 业务模块列
  s += column(bx, bw, mainH, '业务模块层 modules/* 与 system/*（Controller → Service → Mapper → Entity）', '#0D47A1')
  modRows.forEach((m, i) => {
    const cy = y0 + colHeaderH + 14 + i * 78
    s += rect(bx + 20, cy, bw - 40, 66, { fill: '#FFFFFF', stroke: '#B0BEC5', rx: 10, sw: 1.3 })
    s += rect(bx + 20, cy, 8, 66, { fill: m.color, rx: 4 })
    s += txt(bx + 42, cy + 27, m.label, { size: 14.5, weight: 700, fill: m.color })
    const pages = ctx.pageCountByModule[m.name]
    s += txt(bx + 42, cy + 52, 'Controller ' + m.ctrl + ' · Service ' + m.svc + ' · Mapper ' + m.mapper + ' · Entity ' + m.ent
      + (pages ? ' · 前端页面 ' + pages : ''), { size: 13, fill: '#546E7A' })
  })

  // 层间箭头
  const arrowY = y0 + 300
  s += line(320, arrowY, fx - 2, arrowY, { stroke: '#546E7A', sw: 2.4, marker: 'arrowDark' })
  s += txt(330, arrowY - 12, '访问页面', { size: 13, fill: '#546E7A' })
  const arrowY2 = y0 + 620
  s += line(fx + fw + 2, arrowY2, ctx1x - 2, arrowY2, { stroke: '#00695C', sw: 2.4, marker: 'arrowDark' })
  s += txt(fx + fw + 8, arrowY2 - 12, 'axios 请求', { size: 13, fill: '#00695C' })
  const arrowY3 = y0 + 380
  s += line(ctx1x + ctx1w + 2, arrowY3, fwx - 2, arrowY3, { stroke: '#37474F', sw: 2.4, marker: 'arrowDark' })
  s += txt(ctx1x + ctx1w + 8, arrowY3 - 12, 'JWT 鉴权 /api/**', { size: 13, fill: '#37474F' })
  const arrowY4 = y0 + 500
  s += line(fwx + fww + 2, arrowY4, bx - 2, arrowY4, { stroke: '#0D47A1', sw: 2.4, marker: 'arrowBlue' })
  s += txt(fwx + fww + 8, arrowY4 - 12, '调用业务 Service', { size: 13, fill: '#0D47A1' })

  // 基础设施带
  s += rect(40, infraY, CANVAS_W - 80, infraH, { fill: '#F4F7FA', stroke: '#CFD8DC', rx: 14, sw: 1.5 })
  s += txt(66, infraY + 36, '基础设施与数据层', { size: 19, weight: 700, fill: '#263238' })
  const infra = [
    ['MySQL 8（POP 库）', 'driver: com.mysql.cj.jdbc.Driver，HikariCP master-pool（max 10 / min 2）；schema/init.sql 建表脚本；实体对应业务表 ' + ctx.entities.filter(e => e.tableName).length + ' 张'],
    ['Redis（可选增强）', 'spring.data.redis；CacheStore backend=auto，无 Redis 自动降级进程内存；登录失败节流 key auth:fail:{username}'],
    ['本地文件 run/db-conn.json', 'DbAlignService 持久化数据源热切换信息，启动时按文件自动恢复；/api/db/probe、/api/db/current 免鉴权'],
    ['文件与导出', 'EasyExcel 3.3.3 / Apache POI 5.2.5 导出 Excel·Word；multipart 上传 max-file-size 50MB、max-request-size 100MB'],
    ['API 文档', 'knife4j-openapi3 4.3.0：/doc.html、/swagger-ui.html、/v3/api-docs（白名单放行）']
  ]
  const iw = (CANVAS_W - 80 - 40 - 4 * 16) / 5
  infra.forEach((c, i) => {
    const ix = 60 + i * (iw + 16)
    s += rect(ix, infraY + 56, iw, 218, { fill: '#FFFFFF', stroke: '#B0BEC5', rx: 10, sw: 1.3 })
    s += txt(ix + 16, infraY + 86, c[0], { size: 14.5, weight: 700, fill: '#00695C' })
    wrapText(c[1], iw - 32, 13).slice(0, 8).forEach((l, j) => {
      s += txt(ix + 16, infraY + 112 + j * 20, l, { size: 13, fill: '#546E7A' })
    })
  })
  s += line(fwx + fww / 2, y0 + mainH + 4, fwx + fww / 2, infraY - 2, { stroke: '#37474F', sw: 2.4, marker: 'arrowDark' })
  s += line(bx + bw / 2, y0 + mainH + 4, bx + bw / 2, infraY - 2, { stroke: '#0D47A1', sw: 2.4, marker: 'arrowBlue' })

  // 关键机制带
  s += rect(40, mechY, CANVAS_W - 80, mechH, { fill: '#FFFDF5', stroke: '#FFE0B2', rx: 14, sw: 1.5 })
  s += txt(66, mechY + 36, '关键机制与横切能力（源码事实标注）', { size: 19, weight: 700, fill: '#E65100' })
  const mech = [
    ['JWT 鉴权', 'JwtAuthenticationFilter 解析 Bearer；SecurityConfig 白名单：/api/user/login、/api/user/register、/api/db/probe、/api/db/current、/v3/api-docs、/doc.html'],
    ['模块权限（用户类型内置模板 + 单独授权）', 'UserTypePermTemplate 内置 userType=1~6 模板；sys_user.permissions 逗号分隔模块 key；权限授予页（PermissionGrant.vue）单独授权'],
    ['数据权限', 'DataScopeHelper 按 userType 收敛：1 系统管理员/2 校级领导/3 组织部部长/4 组织员=全量；5 二级学院领导=本级及下级；6 普通干部=本部门'],
    ['登录失败节流', 'SysUserServiceImpl 使用 CacheStore 计数 auth:fail:{username}，超限锁定（sys_user.loginFailCount / lockUntil）'],
    ['预警规则生成', 'SuperviseAlertGenerateController POST /api/supervise/alert/generate 按启用规则扫描真实台账，幂等生成/刷新预警'],
    ['考核结果回写与晋升/任免前置核验', 'AssessmentAnnual 保存时回写 cadre_info.annual_assessment（"2024:称职;2025:优秀"）；AnnualAssessmentSupport 供 CadreReserve 候选、AppointProcess 任免、职级晋升做前置核验']
  ]
  const mw = (CANVAS_W - 80 - 40 - 2 * 18) / 3
  mech.forEach((c, i) => {
    const col = i % 3, row = Math.floor(i / 3)
    const mx = 60 + col * (mw + 18)
    const my = mechY + 56 + row * 100
    s += rect(mx, my, mw, 86, { fill: '#FFFFFF', stroke: '#FFCC80', rx: 10, sw: 1.3 })
    s += txt(mx + 16, my + 28, '● ' + c[0], { size: 14, weight: 700, fill: '#E65100' })
    wrapText(c[1], mw - 32, 13).slice(0, 3).forEach((l, j) => {
      s += txt(mx + 16, my + 50 + j * 19, l, { size: 13, fill: '#6D4C41' })
    })
  })

  s += footer(CANVAS_W, CANVAS_H, [
    '统计：后端模块 ' + ctx.backendModules.length + ' 个　|　实体 ' + ctx.entities.length + ' 个（业务表 ' + ctx.entities.filter(e => e.tableName).length + ' 张）　|　Controller/Service/Mapper 见「业务模块层」标签'
    + '　|　前端 .vue 页面 ' + ctx.front.pageTotal + ' 个 / api 文件 ' + ctx.front.apiFiles.length + ' 个',
    '箭头表示主要调用与依赖方向（浏览器→前端→/api→后端框架→业务模块→基础设施）；所有数量与清单均由 .tools-er/gen-project-diagrams.js 扫描源码得到。',
    '生成脚本：.tools-er/gen-project-diagrams.js'
  ])

  s += '</svg>\n'
  return { svg: s, width: CANVAS_W, height: CANVAS_H }
}

/* ------------------------------------------------------------------ */
/* 图 C：模块调用链路图                                                  */
/* ------------------------------------------------------------------ */

function buildChainDiagram(chains, entities, modules) {
  const CANVAS_W = 2450
  const X_CTRL = 60, W_CTRL = 520
  const X_SVC = 650, W_SVC = 520
  const X_MAP = 1240, W_MAP = 460
  const X_TBL = 1770, W_TBL = 620
  const ROW_H = 64
  const SEC_HEAD = 50
  const SEC_PAD = 16

  const byModule = []
  for (const m of modules) {
    const list = chains.filter(c => c.module === m.name)
    if (list.length) byModule.push({ module: m, chains: list })
  }
  const secGaps = 18
  const rows = byModule.reduce((n, s) => n + s.chains.length, 0)
  const secTotal = byModule.reduce((n, s) => n + SEC_HEAD + SEC_PAD * 2 + s.chains.length * ROW_H, 0)
  const CANVAS_H = Math.round(150 + secTotal + (byModule.length - 1) * secGaps + 130)

  let s = svgOpen(CANVAS_W, CANVAS_H)
  s += defsMarkers()
  s += rect(0, 0, CANVAS_W, CANVAS_H, { fill: '#FFFFFF', rx: 0 })
  s += pageTitle(CANVAS_W, '项目-模块调用链路图（Controller → Service → Mapper → 表）',
    '依据各模块 controller / service(+impl) / mapper / entity 源码文件配对梳理；表名取实体类 @TableName，缺失时以「未标注表名」占位')

  // 列说明
  const hdrY = 126
  const captions = [
    [X_CTRL, W_CTRL, 'Controller 层'],
    [X_SVC, W_SVC, 'Service / ServiceImpl 层'],
    [X_MAP, W_MAP, 'Mapper 层'],
    [X_TBL, W_TBL, '数据表（实体 @TableName）']
  ]
  for (const c of captions) {
    s += rect(c[0], hdrY, c[1], 30, { fill: '#E3F2FD', rx: 6 })
    s += txt(c[0] + c[1] / 2, hdrY + 21, c[2], { size: 14, weight: 700, fill: '#0D47A1', anchor: 'middle' })
  }

  let y = hdrY + 30 + 22
  for (let si = 0; si < byModule.length; si++) {
    const sec = byModule[si]
    const color = sec.module.color
    const secH = SEC_HEAD + SEC_PAD * 2 + sec.chains.length * ROW_H
    s += rect(40, y, CANVAS_W - 80, secH, { fill: '#F7F9FC', stroke: '#E0E6ED', rx: 12, sw: 1.4 })
    s += rect(40, y, CANVAS_W - 80, SEC_HEAD, { fill: color, opacity: 0.13, rx: 12 })
    s += rect(40, y + SEC_HEAD - 14, CANVAS_W - 80, 14, { fill: color, opacity: 0.13, rx: 0 })
    s += txt(62, y + 33, sec.module.label, { size: 18, weight: 700, fill: color })
    s += txt(CANVAS_W - 62, y + 33, '链路 ' + sec.chains.length + ' 条　|　Controller ' + sec.module.controllers.length
      + ' · Service ' + (sec.module.services.length + sec.module.serviceImpls.length)
      + ' · Mapper ' + sec.module.mappers.length
      + ' · Entity ' + sec.module.entities.length, { size: 13.5, fill: '#546E7A', anchor: 'end' })

    let ry = y + SEC_HEAD + SEC_PAD
    for (const c of sec.chains) {
      const cy = ry + ROW_H / 2 - 14
      // Controller
      s += rect(X_CTRL, ry + 6, W_CTRL, ROW_H - 12, { fill: '#FFFFFF', stroke: '#90CAF9', rx: 8, sw: 1.3 })
      s += txt(X_CTRL + 14, ry + ROW_H / 2 + 5, truncate(c.controller, W_CTRL - 28, 14), { size: 14, weight: 700, fill: '#0D47A1' })
      // Service
      s += rect(X_SVC, ry + 6, W_SVC, ROW_H - 12, { fill: '#FFFFFF', stroke: c.service ? '#A5D6A7' : '#CFD8DC', rx: 8, sw: 1.3, dash: c.service ? '' : '5 4' })
      s += txt(X_SVC + 14, ry + ROW_H / 2 + 5, truncate(c.service || '（无独立 Service，逻辑内聚在 Controller）', W_SVC - 28, 14),
        { size: 14, fill: c.service ? '#1B5E20' : '#90A4AE' })
      // Mapper
      s += rect(X_MAP, ry + 6, W_MAP, ROW_H - 12, { fill: '#FFFFFF', stroke: c.mapper ? '#FFCC80' : '#CFD8DC', rx: 8, sw: 1.3, dash: c.mapper ? '' : '5 4' })
      s += txt(X_MAP + 14, ry + ROW_H / 2 + 5, truncate(c.mapper || '（未匹配到同名 Mapper）', W_MAP - 28, 14),
        { size: 14, fill: c.mapper ? '#E65100' : '#90A4AE' })
      // Table
      const tblText = c.table ? '@TableName ' + c.table + (c.entityClass ? '（' + c.entityClass + '）' : '') : '未标注表名'
      s += rect(X_TBL, ry + 6, W_TBL, ROW_H - 12, { fill: c.table ? '#F1F8E9' : '#FAFAFA', stroke: c.table ? '#AED581' : '#CFD8DC', rx: 8, sw: 1.3 })
      s += txt(X_TBL + 14, ry + ROW_H / 2 + 5, truncate(tblText, W_TBL - 28, 14), { size: 14, weight: c.table ? 700 : 400, fill: c.table ? '#33691E' : '#90A4AE' })

      // 箭头
      const ay = ry + ROW_H / 2
      s += line(X_CTRL + W_CTRL + 4, ay, X_SVC - 6, ay, { stroke: '#90A4AE', sw: 1.8, marker: 'arrowGray' })
      s += line(X_SVC + W_SVC + 4, ay, X_MAP - 6, ay, { stroke: '#90A4AE', sw: 1.8, marker: 'arrowGray' })
      s += line(X_MAP + W_MAP + 4, ay, X_TBL - 6, ay, { stroke: '#90A4AE', sw: 1.8, marker: 'arrowGray' })
      s += txt((X_CTRL + W_CTRL + X_SVC) / 2 + 10, ay - 8, '调用', { size: 12, fill: '#78909C', anchor: 'middle' })
      s += txt((X_SVC + W_SVC + X_MAP) / 2 + 10, ay - 8, '查询', { size: 12, fill: '#78909C', anchor: 'middle' })
      s += txt((X_MAP + W_MAP + X_TBL) / 2 + 10, ay - 8, '读写', { size: 12, fill: '#78909C', anchor: 'middle' })

      ry += ROW_H
    }
    y += secH + secGaps
  }

  const withTable = chains.filter(c => c.table).length
  const withMapper = chains.filter(c => c.mapper).length
  const withService = chains.filter(c => c.service).length

  s += footer(CANVAS_W, CANVAS_H, [
    '统计：链路 ' + chains.length + ' 条　|　涉及模块 ' + byModule.length + ' 个（' + byModule.map(x => x.module.name).join('、') + '）',
    '其中：匹配到 Service ' + withService + ' 条、匹配到 Mapper ' + withMapper + ' 条、解析到 @TableName 表名 ' + withTable + ' 条；未匹配项按源码实际情况以灰字占位，未凭空补全。',
    '生成脚本：.tools-er/gen-project-diagrams.js（同模块多个 Controller 并列，每行一条完整链路）'
  ])

  s += '</svg>\n'
  return { svg: s, width: CANVAS_W, height: CANVAS_H, byModuleCount: byModule.length }
}

/* ------------------------------------------------------------------ */
/* 主流程                                                              */
/* ------------------------------------------------------------------ */

function main() {
  if (!fs.existsSync(BACKEND)) {
    console.error('[gen-project-diagrams] 未找到后端源码目录: ' + BACKEND)
    process.exit(1)
  }
  const entities = scanEntities()
  const modules = scanModules(entities)
  const front = scanFrontend()
  const chains = buildChains(entities, modules)
  const { relations, candidateFields, matchedFields } = buildRelations(entities)

  const pageCountByModule = {}
  for (const g of front.groups) pageCountByModule[g.name] = g.pages.length

  const backendModules = modules.filter(m => m.name !== 'statistics' && m.name !== 'notice')

  const dA = buildEntityDiagram(entities, relations)
  const dB = buildArchitectureDiagram({ entities, backendModules, front, pageCountByModule })
  const dC = buildChainDiagram(chains, entities, modules)

  fs.mkdirSync(DOCS, { recursive: true })
  const outA = path.join(DOCS, '项目-领域实体关系图.svg')
  const outB = path.join(DOCS, '项目-架构图.svg')
  const outC = path.join(DOCS, '项目-模块调用链路图.svg')
  fs.writeFileSync(outA, dA.svg, 'utf8')
  fs.writeFileSync(outB, dB.svg, 'utf8')
  fs.writeFileSync(outC, dC.svg, 'utf8')

  const dims = {
    files: [
      { name: '项目-领域实体关系图.svg', width: dA.width, height: dA.height },
      { name: '项目-架构图.svg', width: dB.width, height: dB.height },
      { name: '项目-模块调用链路图.svg', width: dC.width, height: dC.height }
    ],
    stats: {
      entityCount: entities.length,
      entityWithTableName: entities.filter(e => e.tableName).length,
      moduleCount: backendModules.length,
      frontPageCount: front.pageTotal,
      apiFileCount: front.apiFiles.length,
      fieldCount: entities.reduce((n, e) => n + e.fields.length, 0),
      relationCount: relations.length,
      relationCandidateFields: candidateFields,
      relationMatchedFields: matchedFields,
      chainCount: chains.length,
      chainModuleCount: dC.byModuleCount
    }
  }
  fs.writeFileSync(DIMS_FILE, JSON.stringify(dims, null, 2), 'utf8')

  console.log('[gen-project-diagrams] 后端实体数量        : ' + dims.stats.entityCount + '（标注 @TableName 的 ' + dims.stats.entityWithTableName + '）')
  console.log('[gen-project-diagrams] 后端实体字段总数    : ' + dims.stats.fieldCount)
  console.log('[gen-project-diagrams] 后端模块数量        : ' + dims.stats.moduleCount + '（' + backendModules.map(m => m.name).join(', ') + '）')
  console.log('[gen-project-diagrams] 前端 .vue 页面数量   : ' + dims.stats.frontPageCount + '（api 文件 ' + dims.stats.apiFileCount + ' 个）')
  console.log('[gen-project-diagrams] 实体关系数量        : ' + dims.stats.relationCount + '（字段级候选 ' + candidateFields + ' / 命中 ' + matchedFields + '）')
  console.log('[gen-project-diagrams] 调用链路数量        : ' + dims.stats.chainCount + '（模块 ' + dims.stats.chainModuleCount + ' 个）')
  for (const m of backendModules) {
    console.log('    - ' + m.name.padEnd(13) + ' Controller ' + String(m.controllers.length).padStart(2)
      + ' / Service ' + String(m.services.length + m.serviceImpls.length).padStart(2)
      + ' / Mapper ' + String(m.mappers.length).padStart(2)
      + ' / Entity ' + String(m.entities.length).padStart(2)
      + ' / 前端页面 ' + (pageCountByModule[m.name] || 0))
  }
  for (const f of dims.files) {
    console.log('DIM\t' + f.name + '\t' + f.width + '\t' + f.height)
  }
  console.log('[gen-project-diagrams] 输出目录: ' + DOCS)
  console.log('[gen-project-diagrams] 尺寸清单: ' + DIMS_FILE)
}

main()
