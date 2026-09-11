// 生成 personnal-frontend/public/er_diagram.html
// 纯生成脚本：读取仓库根 sql/init.sql，解析所有 CREATE TABLE，输出 Mermaid ER 静态页面。
// 无第三方依赖，仅使用 Node 内置 fs/path。
'use strict'

const fs = require('fs')
const path = require('path')

const ROOT = path.resolve(__dirname, '..')
const SQL_FILE = path.join(ROOT, 'sql', 'init.sql')
const OUT_FILE = path.join(ROOT, 'personnel-frontend', 'public', 'er_diagram.html')
const MODEL_FILE = path.join(__dirname, 'er-model.json')

/* ------------------------------ 解析工具 ------------------------------ */

// 从索引 i（指向起始引号）开始，返回字符串结束引号的下标
function endOfString(s, i) {
  let j = i + 1
  while (j < s.length) {
    const c = s[j]
    if (c === '\\') { j += 2; continue }
    if (c === "'") {
      if (s[j + 1] === "'") { j += 2; continue } // 转义的单引号 ''
      return j
    }
    j++
  }
  return s.length - 1
}

// 删除行注释（-- ...），但保留单引号字符串内部的内容
function stripLineComments(s) {
  let out = ''
  let i = 0
  while (i < s.length) {
    const c = s[i]
    if (c === "'") { const e = endOfString(s, i); out += s.slice(i, e + 1); i = e + 1; continue }
    if (c === '-' && s[i + 1] === '-') {
      let e = s.indexOf('\n', i)
      if (e === -1) e = s.length
      i = e
      continue
    }
    out += c
    i++
  }
  return out
}

// 按顶层逗号拆分（忽略引号内与括号内的逗号）
function splitTopLevel(s) {
  const parts = []
  let depth = 0
  let cur = ''
  let i = 0
  while (i < s.length) {
    const c = s[i]
    if (c === "'") { const e = endOfString(s, i); cur += s.slice(i, e + 1); i = e + 1; continue }
    if (c === '(') { depth++; cur += c; i++; continue }
    if (c === ')') { depth--; cur += c; i++; continue }
    if (c === ',' && depth === 0) { parts.push(cur); cur = ''; i++; continue }
    cur += c
    i++
  }
  parts.push(cur)
  return parts
}

function unescapeSqlString(v) {
  return v.replace(/''/g, "'")
}

// 先去掉 /* ... */ 块注释（本文件无，但保持健壮）
function stripBlockComments(s) {
  return s.replace(/\/\*[\s\S]*?\*\//g, ' ')
}

// 找到所有 CREATE TABLE 块：表名、括号体、表级 COMMENT
function parseCreateTables(sql) {
  const result = []
  const seen = new Set()
  const re = /CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?`?([A-Za-z0-9_]+)`?\s*\(/gi
  let m
  while ((m = re.exec(sql)) !== null) {
    const name = m[1]
    const open = re.lastIndex - 1 // 指向 '('
    let depth = 0
    let j = open
    for (; j < sql.length; j++) {
      const c = sql[j]
      if (c === "'") { j = endOfString(sql, j); continue }
      if (c === '(') depth++
      else if (c === ')') { depth--; if (depth === 0) break }
    }
    const body = sql.slice(open + 1, j)
    const tail = sql.slice(j + 1, j + 600)
    const cm = /COMMENT\s*=\s*'((?:[^']|'')*)'/i.exec(tail)
    if (!seen.has(name)) {
      seen.add(name)
      result.push({ name, body, comment: cm ? unescapeSqlString(cm[1]) : '' })
    }
    re.lastIndex = j + 1
  }
  return result
}

// 类型简化
function simplifyType(raw) {
  const base = String(raw).toLowerCase().replace(/\s*\(.*$/, '').replace(/\s+.*$/, '').trim()
  if (/^(varchar|char|text|longtext|mediumtext|tinytext|blob|longblob|mediumblob|tinyblob|json|enum|set)$/.test(base)) return 'string'
  if (/^(int|bigint|tinyint|smallint|mediumint|integer)$/.test(base)) return 'int'
  if (/^(decimal|numeric|float|double)$/.test(base)) return 'decimal'
  if (/^(datetime|date|timestamp)$/.test(base)) return 'datetime'
  return 'string'
}

function parseColumns(body) {
  const columns = []
  const pkCols = new Set()
  const raw = splitTopLevel(stripLineComments(body))
  for (const chunk of raw) {
    const t = chunk.trim()
    if (!t) continue
    if (/^(PRIMARY\s+KEY|UNIQUE|KEY|INDEX|CONSTRAINT|FOREIGN\s+KEY|CHECK|FULLTEXT|SPATIAL)\b/i.test(t)) {
      const pk = /^PRIMARY\s+KEY\s*\(\s*`?([A-Za-z0-9_]+)`?/i.exec(t)
      if (pk) pkCols.add(pk[1])
      continue
    }
    const nm = /^`?([A-Za-z0-9_]+)`?\s+([A-Za-z]+(?:\s*\([^)]*\))?)/.exec(t)
    if (!nm) continue
    const name = nm[1]
    const rawType = nm[2]
    const cm = /COMMENT\s+'((?:[^']|'')*)'/i.exec(t)
    columns.push({
      name,
      type: simplifyType(rawType),
      isPk: /\bPRIMARY\s+KEY\b/i.test(t) || pkCols.has(name),
      notNull: /\bNOT\s+NULL\b/i.test(t),
      comment: cm ? unescapeSqlString(cm[1]).replace(/\s+/g, ' ').trim() : ''
    })
  }
  return columns
}

/* ------------------------------ 关系推断 ------------------------------ */

// 固定映射优先（值会在存在性校验 + 兜底中再解析一次）
const FIXED_MAP = {
  cadre_id: 'cadre_info',
  dept_id: 'org_department',
  organization_id: 'org_department',
  user_id: 'sys_user',
  approver_id: 'sys_user',
  create_by: 'sys_user',
  update_by: 'sys_user',
  role_id: 'sys_role',
  position_id: 'position_level',
  rank_id: 'rank',
  scheme_id: 'assessment_scheme',
  indicator_id: 'assessment_indicator',
  target_id: 'assessment_target',
  annual_id: 'assessment_annual',
  record_id: 'transfer_record',
  process_id: 'appoint_process',
  rule_id: 'alert_rule'
}

const PREFIXES = ['', 'sys_', 'org_', 'cadre_', 'daily_', 'assessment_', 'supervise_', 'appoint_', 'transfer_', 'policy_']
const SUFFIXES = ['', '_info', '_record', '_config', '_type', '_data', '_level', '_list', '_template', '_detail', 's']

function makeResolver(tableNames) {
  const set = new Set(tableNames)
  return function resolve(candidate) {
    if (!candidate) return null
    if (set.has(candidate)) return candidate
    for (const p of PREFIXES) {
      for (const s of SUFFIXES) {
        if (p === '' && s === '') continue
        const name = p + candidate + s
        if (set.has(name)) return name
      }
    }
    return null
  }
}

const STRIP_PREFIXES = ['from_', 'to_', 'target_', 'selected_', 'source_', 'old_', 'new_', 'related_', 'ref_']

function resolveField(field, resolve) {
  if (FIXED_MAP[field]) {
    const hit = resolve(FIXED_MAP[field])
    if (hit) return hit
  }
  const m = /^(.+)_id$/.exec(field)
  if (m) {
    let base = m[1]
    let hit = resolve(base)
    if (!hit) {
      for (const sp of STRIP_PREFIXES) {
        if (base.startsWith(sp) && base.length > sp.length) {
          hit = resolve(base.slice(sp.length))
          if (hit) break
        }
      }
    }
    return hit
  }
  // create_by / update_by 等固定映射之外的非 _id 字段：仅走固定映射，已在上方处理
  return null
}

/* ------------------------------ 主流程 ------------------------------ */

function main() {
  if (!fs.existsSync(SQL_FILE)) {
    console.error('[gen-er] 未找到 SQL 文件: ' + SQL_FILE)
    process.exit(1)
  }
  const sql = stripBlockComments(fs.readFileSync(SQL_FILE, 'utf8'))
  const rawTables = parseCreateTables(sql)

  const tables = rawTables.map(t => ({ name: t.name, comment: t.comment, columns: parseColumns(t.body) }))
  const tableNames = tables.map(t => t.name)
  const resolve = makeResolver(tableNames)

  // ---- Mermaid 文本 ----
  const lines = ['erDiagram']
  let fieldCount = 0
  for (const tb of tables) {
    lines.push('    ' + tb.name + ' {')
    for (const c of tb.columns) {
      fieldCount++
      let line = '        ' + c.type + ' ' + c.name
      if (c.isPk) line += ' PK'
      if (c.comment) line += ' "' + c.comment.replace(/"/g, '#quot;') + '"'
      lines.push(line)
    }
    lines.push('    }')
  }

  // ---- 关系 ----
  const relObjs = []
  const relSeen = new Set()
  for (const tb of tables) {
    for (const c of tb.columns) {
      if (!/_id$/.test(c.name) && !FIXED_MAP[c.name]) continue
      if (c.isPk) continue // 主键 id 自身不建关系
      const target = resolveField(c.name, resolve)
      if (!target) continue
      if (target === tb.name) continue // 跳过自引用
      const key = target + '|' + tb.name + '|' + c.name
      if (relSeen.has(key)) continue
      relSeen.add(key)
      relObjs.push({ from: tb.name, to: target, field: c.name })
    }
  }
  const rels = relObjs.map(r => '    ' + r.to + ' ||--o{ ' + r.from + ' : "' + r.field + '"')
  const mermaidText = lines.concat(rels).join('\n')

  const tableCount = tables.length
  const relCount = relObjs.length
  const title = '辽宁某某大学干部人事系统 ER 实体图（表数量：' + tableCount + '）'
  const footer = '统计：表 ' + tableCount + ' 张 / 字段 ' + fieldCount + ' 个 / 关系 ' + relCount + ' 条'

  const html = buildHtml({ title, footer, mermaidText })

  fs.mkdirSync(path.dirname(OUT_FILE), { recursive: true })
  fs.writeFileSync(OUT_FILE, html, 'utf8')

  // ---- 供 PNG 导出脚本使用的结构化模型 ----
  const model = {
    tableCount,
    fieldCount,
    relationCount: relCount,
    tables: tables.map(tb => ({
      name: tb.name,
      comment: tb.comment,
      fields: tb.columns.map(c => ({
        name: c.name,
        type: c.type,
        pk: !!c.isPk,
        nullable: !(c.notNull || c.isPk),
        comment: c.comment
      }))
    })),
    relations: relObjs
  }
  // 带 BOM 写出，便于 PowerShell 5.1 的 Get-Content -Raw -Encoding UTF8 正确识别
  fs.writeFileSync(MODEL_FILE, '\ufeff' + JSON.stringify(model, null, 2), 'utf8')

  console.log('[gen-er] SQL 来源: ' + SQL_FILE)
  console.log('[gen-er] 输出文件: ' + OUT_FILE)
  console.log('[gen-er] 模型文件: ' + MODEL_FILE)
  console.log('[gen-er] 解析到表数量: ' + tableCount)
  console.log('[gen-er] 字段总数: ' + fieldCount)
  console.log('[gen-er] 生成关系条数: ' + relCount)
  console.log('[gen-er] 实体列表: ' + tableNames.join(', '))
}

function buildHtml({ title, footer, mermaidText }) {
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>${title}</title>
<style>
  html, body {
    margin: 0;
    padding: 0;
    background: #ffffff;
    color: #1f2937;
    font-family: "Microsoft YaHei", "PingFang SC", "Helvetica Neue", Arial, sans-serif;
    font-size: 16px;
  }
  .wrap {
    max-width: 1800px;
    margin: 0 auto;
    padding: 28px 24px 60px;
    box-sizing: border-box;
  }
  h1 {
    font-size: 26px;
    line-height: 1.5;
    text-align: center;
    margin: 8px 0 6px;
    color: #111827;
  }
  .subtitle {
    text-align: center;
    font-size: 15px;
    color: #6b7280;
    margin-bottom: 22px;
  }
  pre.mermaid {
    background: #ffffff;
    margin: 0;
    padding: 8px 0 24px;
    font-size: 16px;
    line-height: 1.7;
    overflow-x: auto;
  }
  .mermaid svg {
    max-width: 100%;
    height: auto;
  }
  .footer {
    margin-top: 26px;
    padding-top: 14px;
    border-top: 1px solid #e5e7eb;
    text-align: center;
    font-size: 15px;
    color: #4b5563;
  }
</style>
</head>
<body>
<div class="wrap">
  <h1>${title}</h1>
  <div class="subtitle">数据来源：sql/init.sql（自动解析生成，仅示意表结构与外键关系）</div>
  <pre class="mermaid">
${mermaidText}
  </pre>
  <div class="footer">${footer}　|　生成脚本：.tools-er/gen-er.js</div>
</div>
<script type="module">
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs'
mermaid.initialize({
  startOnLoad: true,
  theme: 'default',
  er: { layoutDirection: 'TB', entityPadding: 12 },
  fontSize: 16
})
</script>
</body>
</html>
`
}

main()
