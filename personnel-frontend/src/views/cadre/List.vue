<template>
  <div>
    <!-- 功能标题栏 -->
    <div class="page-header">
      干部信息管理
      <router-link to="/statistics" class="header-stat-link"><el-icon><DataAnalysis /></el-icon> 数据统计分析</router-link>
    </div>
    <!-- 查询栏 -->
    <div class="search-bar">
      <el-form :inline="true" :model="queryForm" size="default">
        <el-form-item label="姓名">
          <el-input v-model="queryForm.name" placeholder="输入姓名" style="width:120px" clearable />
        </el-form-item>
        <el-form-item label="所在机构">
          <el-select v-model="queryForm.deptId" placeholder="请选择" style="width:170px" clearable>
            <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="干部状态">
          <el-select v-model="queryForm.cadreStatus" placeholder="全部" style="width:110px" clearable>
            <el-option label="在职" value="ON_JOB" />
            <el-option label="离退休" value="RETIRED" />
            <el-option label="已调出" value="TRANSFERRED" />
            <el-option label="已辞职" value="RESIGNED" />
          </el-select>
        </el-form-item>
        <el-form-item label="职务层次">
          <el-select v-model="queryForm.positionLevel" placeholder="全部" style="width:110px" clearable>
            <el-option label="校级" value="校级" />
            <el-option label="处级" value="处级" />
            <el-option label="科级" value="科级" />
          </el-select>
        </el-form-item>
        <el-form-item label="性别">
          <el-select v-model="queryForm.gender" placeholder="全部" style="width:90px" clearable>
            <el-option label="男" :value="1" />
            <el-option label="女" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="政治面貌">
          <el-select v-model="queryForm.politicalStatus" placeholder="全部" style="width:110px" clearable>
            <el-option label="中共党员" value="中共党员" />
            <el-option label="民主党派" value="民主党派" />
            <el-option label="群众" value="群众" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon> 新增干部</el-button>
      <el-button @click="importDialogVisible = true"><el-icon><Upload /></el-icon> Excel导入</el-button>
      <el-button type="success" @click="openSearchDialog"><el-icon><Search /></el-icon> 多模式查询</el-button>
      <el-dropdown @command="handleExportCommand" style="margin-left:8px">
        <el-button>
          <el-icon><Download /></el-icon> 文书导出 <el-icon style="margin-left:2px"><ArrowDown /></el-icon>
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="excel"><el-icon><Document /></el-icon> Excel格式导出</el-dropdown-item>
            <el-dropdown-item divided command="roster"><el-icon><Printer /></el-icon> 干部名册导出</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
      <el-button type="warning" @click="handleVerify"><el-icon><CircleCheck /></el-icon> 数据校核</el-button>
      <span v-if="verifyIssueCount > 0" class="verify-tip">
        <el-icon><Warning /></el-icon> 发现 {{ verifyIssueCount }} 处数据异常
      </span>
    </div>

    <!-- 表格 -->
    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading" @row-dblclick="handleView">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="80" align="center" />
        <el-table-column prop="genderText" label="性别" width="55" align="center" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="90" align="center" />
        <el-table-column prop="education" label="学历(全日制)" width="110" align="center" />
        <el-table-column prop="deptName" label="所属机构" min-width="150" show-overflow-tooltip />
        <el-table-column prop="position" label="职务" min-width="120" show-overflow-tooltip />
        <el-table-column prop="positionLevel" label="职务层次" width="85" align="center" />
        <el-table-column prop="rankName" label="职级" width="110" align="center" />
        <el-table-column prop="positionStartDate" label="任现职时间" width="100" align="center" />
        <el-table-column prop="cadreStatus" label="状态" width="80" align="center">
          <template #default="{row}">
            <el-tag :type="row.cadreStatus==='ON_JOB'?'success':(row.cadreStatus==='RETIRED'?'info':'danger')" size="small">
              {{ statusMap[row.cadreStatus] }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{row}">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <span class="link-blue" style="margin:0 8px" @click="handleEdit(row)">编辑</span>
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50, 100]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        background
        small
        @current-change="fetchData"
        @size-change="handleSizeChange"
      />
    </div>

    <!-- 数据校核对话框 -->
    <el-dialog v-model="verifyDialogVisible" title="数据智能校核" width="750px">
      <el-alert title="基于后端档案库当前查询结果校验（姓名/机构/职务/职级等关键字段）" type="info" :closable="false" show-icon style="margin-bottom:16px" />
      <div v-if="verifyIssues.length === 0" style="text-align:center;padding:40px;color:#43A047">
        <el-icon style="font-size:48px"><CircleCheckFilled /></el-icon>
        <p style="margin-top:12px;font-size:15px">全部数据校验通过，未发现异常</p>
      </div>
      <el-table v-else :data="verifyIssues" border size="small" max-height="400">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="deptName" label="所属机构" min-width="130" show-overflow-tooltip />
        <el-table-column prop="field" label="异常字段" width="120" align="center" />
        <el-table-column prop="currentValue" label="当前值" width="100" align="center">
          <template #default="{ row }">
            <span style="color:#E53935;font-weight:bold">{{ row.currentValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="issue" label="异常说明" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <span class="link-blue" @click="handleFixIssue(row)">修正</span>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="verifyDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="handleAutoFix" :disabled="verifyIssues.length === 0">一键自动修正</el-button>
      </template>
    </el-dialog>

    <!-- 智能名册对话框 -->
    <el-dialog v-model="printDialogVisible" title="智能名册配置" width="600px">
      <el-form label-width="100px">
        <el-form-item label="名册名称">
          <el-input v-model="rosterForm.name" placeholder="如：处级干部名册" />
        </el-form-item>
        <el-form-item label="显示列">
          <el-checkbox-group v-model="rosterForm.columns">
            <el-checkbox label="name">姓名</el-checkbox>
            <el-checkbox label="genderText">性别</el-checkbox>
            <el-checkbox label="birthDate">出生年月</el-checkbox>
            <el-checkbox label="politicalStatus">政治面貌</el-checkbox>
            <el-checkbox label="education">学历</el-checkbox>
            <el-checkbox label="deptName">所属机构</el-checkbox>
            <el-checkbox label="position">职务</el-checkbox>
            <el-checkbox label="positionLevel">职务层次</el-checkbox>
            <el-checkbox label="rankName">职级</el-checkbox>
            <el-checkbox label="positionStartDate">任现职时间</el-checkbox>
            <el-checkbox label="cadreStatus">状态</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="排序方式">
          <el-select v-model="rosterForm.sortBy" style="width:160px">
            <el-option label="按姓名" value="name" />
            <el-option label="按机构" value="deptName" />
            <el-option label="按职务层次" value="positionLevel" />
            <el-option label="按任现职时间" value="positionStartDate" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="printDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleGenerateRoster">一键生成名册</el-button>
      </template>
    </el-dialog>

    <!-- Excel 导入对话框 -->
    <el-dialog v-model="importDialogVisible" title="干部信息Excel导入" width="760px" destroy-on-close @closed="handleCancelImport">
      <el-alert title="支持 .xlsx/.xls 格式，第一行为表头，系统智能识别字段映射；确认导入后上传后端接口入库" type="info" :closable="false" show-icon style="margin-bottom:16px" />
      <el-upload
        ref="fileInputRef"
        :auto-upload="false"
        :limit="1"
        accept=".xlsx,.xls"
        :on-change="handleFileChange"
        :on-remove="() => { importPreviewData = [] }"
      >
        <el-button type="primary"><el-icon><Upload /></el-icon> 选择Excel文件</el-button>
        <template #tip>
          <div style="color:#888;font-size:12px;margin-top:4px">支持 .xlsx/.xls 格式，第一行为表头（姓名/性别/出生年月/政治面貌/学历(全日制)/所属机构/职务等）</div>
        </template>
      </el-upload>
      <div v-if="importPreviewData.length > 0" style="margin-top:12px;background:#f0f9eb;padding:10px;border-radius:4px;font-size:12px;color:#43A047">
        <el-icon><CircleCheckFilled /></el-icon> 本地预览识别完成：已匹配 {{ importPreviewData.length }} 条记录，请核对后确认导入
      </div>
      <el-table v-if="importPreviewData.length > 0" :data="importPreviewData" border size="small" style="margin-top:12px" max-height="350">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="genderText" label="性别" width="60" align="center" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="90" align="center" />
        <el-table-column prop="education" label="学历" width="110" align="center" />
        <el-table-column prop="deptName" label="所属机构" min-width="150" show-overflow-tooltip />
        <el-table-column prop="position" label="职务" min-width="120" show-overflow-tooltip />
      </el-table>
      <template #footer>
        <el-button @click="handleCancelImport">取消</el-button>
        <el-button type="primary" :disabled="importPreviewData.length === 0" :loading="importing" @click="confirmImport">
          确认导入
        </el-button>
      </template>
    </el-dialog>
    <SearchDialog v-model="searchDialogVisible" :all-data="searchAllData" :dept-list="deptOptions" @view-detail="(row) => handleView(row)" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, Upload, Download, Printer, DataAnalysis, CircleCheck, CircleCheckFilled, Warning, Document, ArrowDown } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { getCadrePage, deleteCadre } from '@/api/cadre'
import { importExcel, mapImportData } from '@/utils/excel'
import { showExportDialog } from '@/utils/export-store'
import SearchDialog from './SearchDialog.vue'

const router = useRouter()
const route = useRoute()

const tabRouteMap = {
  '/cadre/onjob': 'onJob',
  '/cadre/former': 'former',
  '/cadre/retired': 'retired',
  '/cadre/young': 'young'
}

const loading = ref(false)
const tableData = ref([])
const importDialogVisible = ref(false)
const importFile = ref(null)
const importPreviewData = ref([])
const importing = ref(false)
const fileInputRef = ref(null)
const searchDialogVisible = ref(false)
const searchAllData = ref([])
const cadreTab = ref(tabRouteMap[route.path] || 'onJob')
const verifyDialogVisible = ref(false)
const verifyIssues = ref([])
const verifyIssueCount = ref(0)
const printDialogVisible = ref(false)
const rosterForm = reactive({ name: '干部名册', columns: ['name','genderText','deptName','position','positionLevel','cadreStatus'], sortBy: 'deptName' })

const deptOptions = ref([])
const rankMap = ref({})

const queryForm = reactive({
  name: '', deptId: null, cadreStatus: '', positionLevel: '', gender: null, politicalStatus: ''
})
const page = reactive({ current: 1, size: 10, total: 0 })

const statusMap = { ON_JOB: '在职', RETIRED: '离退休', TRANSFERRED: '已调出', RESIGNED: '已辞职' }

const labelMap = {
  name: '姓名', genderText: '性别', birthDate: '出生年月', politicalStatus: '政治面貌',
  education: '学历', deptName: '所属机构', position: '职务', positionLevel: '职务层次',
  rankName: '职级', positionStartDate: '任现职时间', cadreStatus: '状态'
}

function fmtDate(v) {
  if (!v) return ''
  return String(v).substring(0, 10)
}

// 机构与职级映射：真实字典数据（组织树/职级列表）
async function loadDict() {
  const [treeRes, rankRes] = await Promise.all([
    request.get('/organization/tree').catch(() => null),
    request.get('/rank/list').catch(() => null)
  ])
  const list = []
  const walk = nodes => {
    if (!Array.isArray(nodes)) return
    nodes.forEach(o => {
      if (o && o.id != null) list.push({ id: o.id, deptName: o.deptName || o.shortName || '' })
      walk(o.children)
    })
  }
  walk(treeRes && treeRes.data)
  deptOptions.value = list
  const ranks = {}
  if (rankRes && Array.isArray(rankRes.data)) {
    rankRes.data.forEach(r => { if (r && r.id != null) ranks[r.id] = r.rankName })
  }
  rankMap.value = ranks
}

function formatRow(raw) {
  return {
    id: raw.id,
    name: raw.name || '',
    gender: raw.gender,
    genderText: raw.gender === 1 ? '男' : raw.gender === 2 ? '女' : '-',
    birthDate: fmtDate(raw.birthDate),
    politicalStatus: raw.politicalStatus || '',
    education: raw.fullTimeEducation || '',
    deptId: raw.deptId,
    deptName: (deptOptions.value.find(d => d.id === raw.deptId) || {}).deptName || '-',
    position: raw.position || '',
    positionLevel: raw.positionLevel || '',
    rankId: raw.rankId,
    rankName: raw.rankId != null ? (rankMap.value[raw.rankId] || '-') : '-',
    positionStartDate: fmtDate(raw.positionStartDate),
    positionDocNo: raw.positionDocNo || '',
    resumeText: raw.resumeText || '',
    cadreStatus: raw.cadreStatus || ''
  }
}

function buildQueryBody() {
  const body = {}
  if (queryForm.name) body.name = queryForm.name
  if (queryForm.deptId) body.deptId = queryForm.deptId
  if (queryForm.cadreStatus) body.cadreStatus = queryForm.cadreStatus
  if (queryForm.positionLevel) body.positionLevel = queryForm.positionLevel
  if (queryForm.gender) body.gender = queryForm.gender
  if (queryForm.politicalStatus) body.politicalStatus = queryForm.politicalStatus
  return body
}

function tabDefaultStatus(tab) {
  if (tab === 'former') return 'TRANSFERRED'
  if (tab === 'retired') return 'RETIRED'
  if (tab === 'young') return 'ON_JOB'
  return 'ON_JOB'
}

// 拉取符合当前查询的全部真实行（供名册/校核/多模式查询等派生用途）
async function fetchFullRows() {
  try {
    const body = { current: 1, size: 2000, ...buildQueryBody() }
    if (cadreTab.value === 'young' && !body.cadreStatus) body.cadreStatus = 'ON_JOB'
    const res = await getCadrePage(body)
    let rows = (res.data && res.data.records) || []
    if (cadreTab.value === 'young') {
      const cutoffYear = new Date().getFullYear() - 40
      rows = rows.filter(r => r.birthDate && parseInt(String(r.birthDate).substring(0, 4), 10) >= cutoffYear)
    }
    return rows.map(formatRow)
  } catch (e) {
    return []
  }
}

async function fetchData() {
  loading.value = true
  try {
    // 年轻干部库：后端无年龄参数，先取真实在职数据后本地按年龄派生
    if (cadreTab.value === 'young') {
      const res = await getCadrePage({ current: 1, size: 2000, cadreStatus: 'ON_JOB', ...buildQueryBody() })
      const cutoffYear = new Date().getFullYear() - 40
      let rows = (res.data && res.data.records || []).filter(r => r.birthDate && parseInt(String(r.birthDate).substring(0, 4), 10) >= cutoffYear)
      rows = rows.map(formatRow)
      page.total = rows.length
      const start = (page.current - 1) * page.size
      tableData.value = rows.slice(start, start + page.size)
    } else {
      const body = { current: page.current, size: page.size, ...buildQueryBody() }
      const res = await getCadrePage(body)
      const rows = (res.data && res.data.records) || []
      tableData.value = rows.map(formatRow)
      page.total = (res.data && res.data.total) || 0
    }
  } catch (e) {
    tableData.value = []
    page.total = 0
  } finally {
    loading.value = false
  }
}

function handleSizeChange() {
  page.current = 1
  fetchData()
}
function handleSearch() { page.current = 1; fetchData() }
function handleReset() {
  Object.assign(queryForm, { name: '', deptId: null, cadreStatus: '', positionLevel: '', gender: null, politicalStatus: '' })
  page.current = 1
  syncTabFromRoute()
  fetchData()
}

function handleAdd() { router.push('/cadre/new') }
function handleView(row) { router.push(`/cadre/${row.id}`) }
function handleEdit(row) { router.push(`/cadre/${row.id}?edit=1`) }

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(`确定要删除干部"${row.name}"吗？`, '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await deleteCadre(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

// 根据路由同步当前干部库标签及状态筛选
function syncTabFromRoute() {
  cadreTab.value = tabRouteMap[route.path] || 'onJob'
  if (!queryForm.cadreStatus) {
    queryForm.cadreStatus = tabDefaultStatus(cadreTab.value)
  }
}

watch(() => route.path, () => {
  queryForm.cadreStatus = ''
  syncTabFromRoute()
  page.current = 1
  fetchData()
})

// ============ 导出（后端真实导出接口 / 当前真实查询结果名册） ============

function handleExportCommand(cmd) {
  switch (cmd) {
    case 'excel': handleExcelExport(); break
    case 'roster': printDialogVisible.value = true; break
  }
}

async function handleExcelExport() {
  const token = localStorage.getItem('token') || ''
  try {
    const resp = await fetch('/api/cadre/export', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify(buildQueryBody())
    })
    if (!resp.ok) {
      ElMessage.error('导出失败')
      return
    }
    const blob = await resp.blob()
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = '干部信息.xlsx'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    ElMessage.success('Excel导出成功')
  } catch (e) {
    ElMessage.error('导出失败：后端未连接')
  }
}

async function handleGenerateRoster() {
  if (rosterForm.columns.length === 0) {
    ElMessage.warning('请至少选择一列')
    return
  }
  const rows = await fetchFullRows()
  if (rows.length === 0) {
    ElMessage.warning('当前查询条件下没有干部数据可导出')
    return
  }
  rows.sort((a, b) => {
    const va = a[rosterForm.sortBy] || ''
    const vb = b[rosterForm.sortBy] || ''
    return String(va).localeCompare(String(vb), 'zh-CN')
  })
  printDialogVisible.value = false
  const columns = rosterForm.columns.map(c => ({ prop: c, label: labelMap[c] || c }))
  showExportDialog(rows, columns, rosterForm.name)
}

// ============ Excel 导入（后端 /cadre/import） ============

async function handleFileChange(file) {
  importFile.value = file
  try {
    const raw = await importExcel(file.raw)
    const mapped = mapImportData(raw, {
      '姓名': 'name',
      '性别': 'genderText',
      '出生年月': 'birthDate',
      '政治面貌': 'politicalStatus',
      '学历(全日制)': 'education',
      '所属机构': 'deptName',
      '职务': 'position',
      '职务层次': 'positionLevel',
      '职级': 'rankName'
    })
    importPreviewData.value = mapped
  } catch (e) {
    ElMessage.error(e.message || '文件解析失败')
    importPreviewData.value = []
  }
}

async function confirmImport() {
  if (!importFile.value || !importFile.value.raw) {
    ElMessage.warning('没有可导入的文件')
    return
  }
  importing.value = true
  try {
    const fd = new FormData()
    fd.append('file', importFile.value.raw)
    const res = await request.post('/cadre/import', fd, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    ElMessage.success(`导入成功${res.data != null ? '：' + res.data + ' 条' : ''}`)
    importDialogVisible.value = false
    importPreviewData.value = []
    importFile.value = null
    fetchData()
  } catch (e) {
    ElMessage.error(e.message || '导入失败')
  } finally {
    importing.value = false
  }
}

function handleCancelImport() {
  importDialogVisible.value = false
  importPreviewData.value = []
  importFile.value = null
}

// ============ 数据校核（基于后端真实查询结果） ============

async function handleVerify() {
  const rows = await fetchFullRows()
  const issues = []
  rows.forEach(d => {
    if (!d.name || d.name.length < 2) issues.push({ ...d, field: '姓名', currentValue: d.name || '(空)', issue: '姓名不完整，需2个字符以上' })
    if (!d.birthDate || d.birthDate.length < 7) issues.push({ ...d, field: '出生年月', currentValue: d.birthDate || '(空)', issue: '出生年月缺失或格式异常' })
    if (d.deptId == null) issues.push({ ...d, field: '所属机构', currentValue: '(空)', issue: '所属机构为空，需关联机构信息' })
    if (!d.position) issues.push({ ...d, field: '职务', currentValue: '(空)', issue: '职务信息缺失' })
    if (d.rankId == null) issues.push({ ...d, field: '职级', currentValue: '(空)', issue: '职级信息缺失' })
  })
  verifyIssues.value = issues
  verifyIssueCount.value = issues.length
  verifyDialogVisible.value = true
}

async function fixOne(row) {
  const payload = { id: row.id }
  if (row.field === '所属机构') {
    if (deptOptions.value.length === 0) return false
    payload.deptId = deptOptions.value[0].id
  } else if (row.field === '职务') {
    payload.position = '待补充'
  } else if (row.field === '职级') {
    return false
  } else {
    return false
  }
  try {
    await request.put('/cadre', payload)
    return true
  } catch (e) {
    return false
  }
}

async function handleFixIssue(row) {
  const ok = await fixOne(row)
  if (!ok) {
    ElMessage.warning(`${row.field} 无法自动修正，请通过「编辑」完善档案`)
    return
  }
  verifyIssues.value = verifyIssues.value.filter(d => d.id !== row.id)
  verifyIssueCount.value = verifyIssues.value.length
  ElMessage.success(`${row.name} 的${row.field}已修正`)
  fetchData()
}

async function handleAutoFix() {
  let count = 0
  const failed = []
  for (const row of verifyIssues.value) {
    const ok = await fixOne(row)
    if (ok) count++
    else failed.push(row)
  }
  verifyIssues.value = failed
  verifyIssueCount.value = failed.length
  ElMessage.success(`自动修正完成：成功 ${count} 条` + (failed.length ? `，${failed.length} 条需人工处理` : ''))
  fetchData()
}

// ============ 多模式查询（SearchDialog，数据源为后端真实查询结果） ============
async function openSearchDialog() {
  if (searchAllData.value.length === 0) {
    searchAllData.value = await fetchFullRows()
  }
  searchDialogVisible.value = true
}

onMounted(async () => {
  await loadDict()
  syncTabFromRoute()
  fetchData()
})
</script>

<style scoped>
.header-stat-link {
  float: right;
  font-size: 13px;
  font-weight: normal;
  color: #fff;
  background: rgba(255,255,255,0.15);
  padding: 4px 12px;
  border-radius: 4px;
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: -2px;
}
.header-stat-link:hover { background: rgba(255,255,255,0.25); }
.verify-tip {
  color: #E53935;
  font-size: 12px;
  font-weight: bold;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  margin-left: 12px;
}
@media (max-width: 768px) {
  .header-stat-link { float: none; display: inline-flex; margin-top: 6px; }
}
</style>
