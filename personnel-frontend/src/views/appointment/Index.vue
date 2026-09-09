<template>
  <div>
    <div class="page-header">干部任免管理</div>

    <div class="search-bar">
      <el-form :inline="true" :model="searchForm" size="default">
        <el-form-item label="职位信息">
          <el-input v-model="searchForm.positionInfo" placeholder="输入职位关键词" style="width:180px" clearable />
        </el-form-item>
        <el-form-item label="当前环节">
          <el-input v-model="searchForm.currentStep" placeholder="如：动议/考察/公示" style="width:150px" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" style="width:110px" clearable>
            <el-option label="进行中" value="进行中" />
            <el-option label="已完成" value="已完成" />
            <el-option label="已终止" value="已终止" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openStartDialog"><el-icon><Plus /></el-icon> 启动任免流程</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
      <span style="margin-left:12px;color:#999;font-size:12px">六环节统一任免流程：动议 → 民主推荐 → 考察 → 讨论决定 → 公示 → 任职（各环节办理记录均随流程留痕）</span>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="positionInfo" label="选拔职位信息" min-width="240" show-overflow-tooltip sortable />
        <el-table-column prop="currentStep" label="当前环节" width="120" align="center">
          <template #default="{row}">
            <el-tag :type="getStepTagType(row.currentStep)" size="small">{{ row.currentStep || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="cadreName" label="关联人选" min-width="100" show-overflow-tooltip />
        <el-table-column prop="startTimeText" label="启动时间" width="120" align="center" />
        <el-table-column prop="endTimeText" label="结束时间" width="120" align="center" />
        <el-table-column prop="processStatus" label="状态" width="90" align="center">
          <template #default="{row}">
            <el-tag :type="getStatusType(row.processStatus)" size="small">{{ row.processStatus || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center" fixed="right">
          <template #default="{row}">
            <span class="link-blue" @click="handleDetail(row)">详情</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50]"
        :total="pageTotal"
        layout="total, sizes, prev, pager, next"
        background
        small
        @size-change="handleSizeChange"
      />
    </div>

    <!-- 启动任免流程对话框 -->
    <el-dialog v-model="startDialogVisible" title="启动任免流程" width="560px" destroy-on-close>
      <el-alert type="info" :closable="false" style="margin-bottom:12px" show-icon
        title="流程环节固定为：动议→民主推荐→考察→讨论决定→公示→任职，启动后可在详情中逐环节登记办理并推进。" />
      <el-form :model="startForm" label-width="90px" size="default" :rules="startRules" ref="startFormRef">
        <el-form-item label="职位信息" prop="positionInfo">
          <el-input v-model="startForm.positionInfo" placeholder="如：机械工程学院院长（正处级）" />
        </el-form-item>
        <el-form-item label="关联干部">
          <el-select v-model="startForm.cadreId" placeholder="可不选，后续环节再关联" clearable filterable style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + '（' + (c.deptName || '-') + '）'" :value="c.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="startDialogVisible=false">取消</el-button>
        <el-button type="primary" :loading="startSubmitting" @click="handleStart">启动流程</el-button>
      </template>
    </el-dialog>

    <!-- 流程详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="任免流程详情" width="860px" destroy-on-close top="5vh">
      <div v-if="currentProcess" class="process-detail">
        <el-descriptions :column="3" border size="small">
          <el-descriptions-item label="选拔职位">{{ currentProcess.positionInfo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="关联干部">{{ currentProcess.cadreName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusType(currentProcess.processStatus)" size="small">{{ currentProcess.processStatus || '-' }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="启动时间">{{ currentProcess.startTimeText || '-' }}</el-descriptions-item>
          <el-descriptions-item label="结束时间">{{ currentProcess.endTimeText || '-' }}</el-descriptions-item>
          <el-descriptions-item label="流程环节">动议→民主推荐→考察→讨论决定→公示→任职</el-descriptions-item>
        </el-descriptions>

        <el-steps :active="activeStepIndex" finish-status="success" align-center style="margin:20px 0">
          <el-step v-for="s in STEP_FLOW" :key="s" :title="s" />
        </el-steps>

        <!-- 各环节真实登记数据 -->
        <template v-for="(seg, idx) in stepSegments" :key="seg.key">
          <div v-if="activeStepIndex === idx" class="step-panel">
            <div class="step-title">{{ (idx + 1) + '、' + seg.name }}</div>
            <el-table v-if="seg.rows && seg.rows.length" :data="seg.rows" border size="small">
              <el-table-column prop="label" label="数据项" width="180" align="center" />
              <el-table-column prop="value" label="内容" min-width="300" />
            </el-table>
            <el-empty v-else :image-size="60" description="该环节尚未登记数据，可点击下方“办理当前环节”登记" />
            <div style="margin-top:12px;display:flex;align-items:center;gap:8px">
              <span style="font-size:12px;color:#666">环节操作：</span>
              <el-button v-if="currentProcess.processStatus === '进行中' && seg.key === currentProcess.currentStep" type="primary" size="small" @click="openRegister(seg.key)">办理当前环节</el-button>
              <el-tag v-else-if="currentProcess.processStatus === '进行中'" type="info" size="small">非当前环节</el-tag>
            </div>
          </div>
        </template>

        <div v-if="currentProcess.processStatus === '进行中'" class="step-nav" style="margin-top:16px;text-align:center">
          <el-button @click="prevStep" :disabled="activeStepIndex <= 0">上一步</el-button>
          <el-button @click="nextStep" :disabled="activeStepIndex >= STEP_FLOW.length - 1">下一步</el-button>
          <el-button type="primary" :disabled="!canAdvance" :loading="advancing" @click="handleAdvance">推进至下一步</el-button>
          <el-button type="danger" plain :loading="terminating" @click="handleTerminate">终止流程</el-button>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible=false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 办理登记对话框（真实提交对应环节接口） -->
    <el-dialog v-model="registerVisible" :title="'办理当前环节：' + getStepName(registerStep)" width="640px" destroy-on-close top="8vh">
      <el-form :model="registerForm" label-width="130px" size="default">
        <template v-for="f in registerFields" :key="f.key">
          <el-form-item :label="f.label">
            <el-input v-if="f.type === 'text'" v-model="registerForm[f.key]" :placeholder="f.placeholder || ''" clearable />
            <el-input v-else-if="f.type === 'textarea'" v-model="registerForm[f.key]" type="textarea" :rows="3" :placeholder="f.placeholder || ''" />
            <el-date-picker v-else-if="f.type === 'date'" v-model="registerForm[f.key]" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
            <el-input-number v-else-if="f.type === 'number'" v-model="registerForm[f.key]" :min="0" style="width:100%" />
            <el-radio-group v-else-if="f.type === 'yesno'" v-model="registerForm[f.key]">
              <el-radio :value="1">通过/是</el-radio>
              <el-radio :value="0">未通过/否</el-radio>
            </el-radio-group>
            <el-select v-else-if="f.type === 'cadre'" v-model="registerForm[f.key]" placeholder="请选择干部" clearable filterable style="width:100%">
              <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + '（' + (c.deptName || '-') + '）'" :value="c.id" />
            </el-select>
            <el-select v-else-if="f.type === 'dept'" v-model="registerForm[f.key]" placeholder="请选择机构" clearable filterable style="width:100%">
              <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.id" />
            </el-select>
            <el-select v-else-if="f.type === 'select'" v-model="registerForm[f.key]" placeholder="请选择" clearable style="width:100%">
              <el-option v-for="opt in (f.options || [])" :key="opt" :label="opt" :value="opt" />
            </el-select>
          </el-form-item>
        </template>
      </el-form>
      <template #footer>
        <el-button @click="registerVisible=false">取消</el-button>
        <el-button type="primary" :loading="registerSubmitting" @click="handleRegisterSubmit">保存登记</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Download, Search, RefreshLeft } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'

// 后端 appoint_process 未提供可配置的流程类型，统一为六环节任免流程
const STEP_FLOW = ['动议', '民主推荐', '考察', '讨论决定', '公示', '任职']

const loading = ref(false)
const startDialogVisible = ref(false)
const startSubmitting = ref(false)
const startFormRef = ref(null)
const detailDialogVisible = ref(false)
const currentProcess = ref(null)
const activeStepIndex = ref(0)
const advancing = ref(false)
const terminating = ref(false)
const registerVisible = ref(false)
const registerSubmitting = ref(false)
const registerStep = ref('')
const registerForm = reactive({})

const searchForm = reactive({ positionInfo: '', currentStep: '', status: '' })
const page = reactive({ current: 1, size: 10 })

// ---------- 共享字典 ----------
const deptOptions = ref([])
const cadreAllOptions = ref([])
const cadreOptions = ref([])

const canAdvance = computed(() => {
  if (!currentProcess.value || currentProcess.value.processStatus !== '进行中') return false
  const idx = STEP_FLOW.indexOf(currentProcess.value.currentStep)
  return idx >= 0 && idx < STEP_FLOW.length
})

// ---------- 字典加载 ----------
async function loadDicts() {
  try {
    const [orgRes, cadreRes] = await Promise.all([
      request({ url: '/organization/tree', method: 'get' }),
      request({ url: '/cadre/page', method: 'post', params: { current: 1, size: 2000 } })
    ])
    const depts = []
    const walk = (list) => {
      ;(list || []).forEach(n => {
        depts.push(n)
        if (n.children && n.children.length) walk(n.children)
      })
    }
    walk(orgRes.data || [])
    deptOptions.value = depts.map(d => ({ id: d.id, deptName: d.deptName }))
    const cadres = (cadreRes.data && cadreRes.data.records) || []
    const deptNameMap = {}
    depts.forEach(d => { deptNameMap[d.id] = d.deptName })
    cadreAllOptions.value = cadres.map(c => ({ id: c.id, name: c.name, deptName: deptNameMap[c.deptId] || '-', status: c.cadreStatus }))
    cadreOptions.value = cadreAllOptions.value.filter(c => c.status === 'ON_JOB')
  } catch (e) {
    deptOptions.value = []
    cadreOptions.value = []
  }
}

// ---------- 流程列表 ----------
const allData = ref([])

function fmtDate(v) {
  if (v === null || v === undefined || v === '') return '-'
  return String(v).replace('T', ' ').slice(0, 16)
}

async function fetchAll() {
  loading.value = true
  try {
    const all = []
    let current = 1
    let total = null
    const size = 50
    while (true) {
      const res = await request({ url: '/appoint-process/page', method: 'get', params: { current, size } })
      const data = (res && res.data) || {}
      const records = data.records || []
      records.forEach(r => all.push(r))
      total = data.total != null ? data.total : all.length
      if (all.length >= total || records.length === 0) break
      current++
      if (current > 100) break
    }
    allData.value = all
  } catch (e) {
    allData.value = []
  } finally {
    loading.value = false
  }
}

const filteredData = computed(() => {
  let list = allData.value
  if (searchForm.positionInfo) list = list.filter(d => (d.positionInfo || '').includes(searchForm.positionInfo))
  if (searchForm.currentStep) list = list.filter(d => (d.currentStep || '') === searchForm.currentStep)
  if (searchForm.status) list = list.filter(d => d.processStatus === searchForm.status)
  return list
})

const pageTotal = computed(() => filteredData.value.length)

const tableData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size).map(decorateRow)
})

function cadreNameById(id) {
  if (id == null) return '-'
  const c = cadreAllOptions.value.find(x => x.id === id)
  return c ? c.name : ('#' + id)
}
function deptNameById(id) {
  if (id == null) return '-'
  const d = deptOptions.value.find(x => x.id === id)
  return d ? d.deptName : ('#' + id)
}

function decorateRow(r) {
  return {
    ...r,
    cadreName: cadreNameById(r.cadreId),
    startTimeText: fmtDate(r.startTime),
    endTimeText: fmtDate(r.endTime)
  }
}

function handleSearch() { page.current = 1 }
function resetSearch() {
  Object.assign(searchForm, { positionInfo: '', currentStep: '', status: '' })
  page.current = 1
}
function handleSizeChange() { page.current = 1 }

function getStepTagType(step) {
  const map = { '动议': 'info', '民主推荐': '', '考察': 'warning', '讨论决定': '', '公示': '', '任职': 'success' }
  return map[step] || 'info'
}
function getStatusType(s) {
  if (s === '进行中') return 'warning'
  if (s === '已完成') return 'success'
  if (s === '已终止') return 'info'
  return 'info'
}

// ---------- 启动流程 ----------
const startForm = reactive({ positionInfo: '', cadreId: null })
const startRules = {
  positionInfo: [{ required: true, message: '请输入职位信息', trigger: 'blur' }]
}

function openStartDialog() {
  Object.assign(startForm, { positionInfo: '', cadreId: null })
  startDialogVisible.value = true
}

async function handleStart() {
  startFormRef.value.validate(async (valid) => {
    if (!valid) return
    startSubmitting.value = true
    try {
      await request({
        url: '/appoint-process',
        method: 'post',
        data: {
          positionInfo: startForm.positionInfo,
          cadreId: startForm.cadreId || null,
          currentStep: STEP_FLOW[0],
          processStatus: '进行中',
          startTime: new Date().toISOString().slice(0, 19).replace('T', ' ')
        }
      })
      ElMessage.success('任免流程已启动（当前环节：动议）')
      startDialogVisible.value = false
      await fetchAll()
    } catch (e) {
      ElMessage.error('流程启动失败')
    } finally {
      startSubmitting.value = false
    }
  })
}

// ---------- 详情（真实字段展示 + 真实推进/终止） ----------
const stepSegments = computed(() => {
  if (!currentProcess.value) return []
  const p = currentProcess.value
  return STEP_FLOW.map(name => {
    let rows = []
    if (name === '动议' && p.motion) rows = buildRows(p.motion, [
      ['positionCondition', '任职条件'], ['candidateIds', '候选干部ID'], ['selectedCadreId', '已定人选ID'],
      ['motionStatus', '动议状态'], ['meetingFileUrl', '会议纪要材料URL']
    ], { selectedCadreId: v => cadreNameById(v) })
    if (name === '民主推荐' && p.recommend) rows = buildRows(p.recommend, [
      ['recommendType', '推荐方式'], ['recommendDate', '推荐日期'], ['recommendLocation', '推荐地点'],
      ['expectedCount', '应到人数'], ['actualCount', '实到人数'], ['voteCount', '得票数'],
      ['isPassed', '是否通过'], ['meetingFileUrl', '会议材料URL']
    ], { isPassed: v => (v === 1 ? '通过' : v === 0 ? '未通过' : '-') })
    if (name === '考察' && p.investigation) rows = buildRows(p.investigation, [
      ['archiveCheck', '干部档案审核'], ['archiveIssue', '档案审核问题'], ['personalReportCheck', '个人事项报告核查'],
      ['personalReportIssue', '个人事项问题'], ['disciplineCheck', '纪检监察机关意见'], ['disciplineIssue', '纪委意见问题'],
      ['complaintCheck', '信访举报核查'], ['complaintIssue', '信访问题'], ['isPassed', '是否通过']
    ], {
      archiveCheck: v => (v === 1 ? '通过' : v === 0 ? '不通过' : '-'),
      personalReportCheck: v => (v === 1 ? '通过' : v === 0 ? '不通过' : '-'),
      disciplineCheck: v => (v === 1 ? '通过' : v === 0 ? '不通过' : '-'),
      complaintCheck: v => (v === 1 ? '通过' : v === 0 ? '不通过' : '-'),
      isPassed: v => (v === 1 ? '通过' : v === 0 ? '未通过' : '-')
    })
    if (name === '讨论决定' && p.decision) rows = buildRows(p.decision, [
      ['meetingDate', '会议日期'], ['approveCount', '同意票'], ['opposeCount', '不同意票'],
      ['abstainCount', '弃权票'], ['isPassed', '表决结果']
    ], { isPassed: v => (v === 1 ? '通过' : v === 0 ? '未通过' : '-') })
    if (name === '公示' && p.publicity) rows = buildRows(p.publicity, [
      ['publicityStart', '公示开始日期'], ['publicityEnd', '公示结束日期'], ['publicityContent', '公示内容'],
      ['reportInfo', '反映情况'], ['publicityResult', '公示结果'], ['remark', '备注']
    ])
    if (name === '任职' && p.record) {
      const r = p.record
      rows = [
        { label: '任职干部', value: cadreNameById(r.cadreId) },
        { label: '任职机构', value: deptNameById(r.deptId) },
        { label: '任职职务', value: r.position || '-' },
        { label: '职务层次', value: r.positionLevel || '-' },
        { label: '任职日期', value: fmtDate(r.appointDate) },
        { label: '任职文号', value: r.appointDocNo || '-' },
        { label: '是否现任', value: r.isCurrent === 1 ? '是' : r.isCurrent === 0 ? '否' : '-' }
      ]
    }
    return { key: name, name, rows }
  })
})

function buildRows(obj, fields, formatters) {
  return fields.map(([key, label]) => {
    let v = obj[key]
    if (formatters && formatters[key]) v = formatters[key](v)
    return { label, value: v === null || v === undefined || v === '' ? '-' : v }
  })
}

async function handleDetail(row) {
  try {
    const res = await request({ url: `/appoint-process/${row.id}`, method: 'get' })
    const p = res.data || row
    currentProcess.value = decorateRow(p)
    currentProcess.value._id = p.id
    const idx = STEP_FLOW.indexOf(currentProcess.value.currentStep)
    activeStepIndex.value = idx >= 0 ? idx : 0
    detailDialogVisible.value = true
  } catch (e) {
    ElMessage.error('加载流程详情失败')
  }
}

function prevStep() { if (activeStepIndex.value > 0) activeStepIndex.value-- }
function nextStep() { if (activeStepIndex.value < STEP_FLOW.length - 1) activeStepIndex.value++ }

async function handleAdvance() {
  const p = currentProcess.value
  const idx = STEP_FLOW.indexOf(p.currentStep)
  if (idx < 0 || idx >= STEP_FLOW.length) {
    ElMessage.warning('当前环节不在流程步骤中，无法自动推进')
    return
  }
  const next = STEP_FLOW[idx + 1]
  try {
    await ElMessageBox.confirm(`确定将流程从“${p.currentStep}”推进至“${next}”吗？将真实更新后端流程记录。`, '推进流程', { type: 'warning' })
  } catch (e) {
    return
  }
  advancing.value = true
  try {
    const isLast = idx + 1 === STEP_FLOW.length - 1
    const body = {
      id: p._id,
      positionInfo: p.positionInfo,
      cadreId: p.cadreId || null,
      currentStep: next,
      processStatus: isLast ? '已完成' : '进行中',
      endTime: isLast ? new Date().toISOString().slice(0, 19).replace('T', ' ') : null
    }
    await request({ url: '/appoint-process', method: 'put', data: body })
    ElMessage.success(isLast ? '流程已完成' : '已推进至“' + next + '”')
    detailDialogVisible.value = false
    await fetchAll()
  } catch (e) {
    ElMessage.error('推进失败')
  } finally {
    advancing.value = false
  }
}

async function handleTerminate() {
  const p = currentProcess.value
  try {
    await ElMessageBox.confirm(`确定终止"${p.positionInfo}"的任免流程吗？终止后不可恢复。`, '终止流程', {
      type: 'warning', confirmButtonText: '确定终止', cancelButtonText: '取消'
    })
  } catch (e) {
    return
  }
  terminating.value = true
  try {
    await request({
      url: '/appoint-process',
      method: 'put',
      data: {
        id: p._id,
        positionInfo: p.positionInfo,
        cadreId: p.cadreId || null,
        currentStep: p.currentStep,
        processStatus: '已终止',
        endTime: new Date().toISOString().slice(0, 19).replace('T', ' ')
      }
    })
    ElMessage.success('流程已终止')
    detailDialogVisible.value = false
    await fetchAll()
  } catch (e) {
    ElMessage.error('终止失败')
  } finally {
    terminating.value = false
  }
}

// ---------- 办理登记（真实提交到对应环节接口） ----------
const stepFieldDefs = {
  '动议': [
    { key: 'positionCondition', label: '任职条件', type: 'textarea' },
    { key: 'candidateIds', label: '候选干部ID（逗号分隔）', type: 'text' },
    { key: 'selectedCadreId', label: '已定人选（干部）', type: 'cadre' },
    { key: 'motionStatus', label: '动议状态', type: 'select', options: ['进行中', '已通过', '已退回'] },
    { key: 'meetingFileUrl', label: '会议纪要材料URL', type: 'text' }
  ],
  '民主推荐': [
    { key: 'recommendType', label: '推荐方式', type: 'select', options: ['会议推荐', '谈话调研推荐', '个人自荐'] },
    { key: 'recommendDate', label: '推荐日期', type: 'date' },
    { key: 'recommendLocation', label: '推荐地点', type: 'text' },
    { key: 'expectedCount', label: '应到人数', type: 'number' },
    { key: 'actualCount', label: '实到人数', type: 'number' },
    { key: 'voteCount', label: '得票数', type: 'number' },
    { key: 'isPassed', label: '是否通过', type: 'yesno' },
    { key: 'meetingFileUrl', label: '会议材料URL', type: 'text' }
  ],
  '考察': [
    { key: 'archiveCheck', label: '干部档案审核是否通过', type: 'yesno' },
    { key: 'archiveIssue', label: '档案审核发现问题', type: 'textarea' },
    { key: 'personalReportCheck', label: '个人事项报告核查是否通过', type: 'yesno' },
    { key: 'personalReportIssue', label: '个人事项核查问题', type: 'textarea' },
    { key: 'disciplineCheck', label: '纪检监察机关意见是否通过', type: 'yesno' },
    { key: 'disciplineIssue', label: '纪委意见问题', type: 'textarea' },
    { key: 'complaintCheck', label: '信访举报核查是否通过', type: 'yesno' },
    { key: 'complaintIssue', label: '信访核查问题', type: 'textarea' },
    { key: 'isPassed', label: '考察总体是否通过', type: 'yesno' }
  ],
  '讨论决定': [
    { key: 'meetingDate', label: '会议日期', type: 'date' },
    { key: 'approveCount', label: '同意票', type: 'number' },
    { key: 'opposeCount', label: '不同意票', type: 'number' },
    { key: 'abstainCount', label: '弃权票', type: 'number' },
    { key: 'isPassed', label: '表决是否通过', type: 'yesno' }
  ],
  '公示': [
    { key: 'publicityStart', label: '公示开始日期', type: 'date' },
    { key: 'publicityEnd', label: '公示结束日期', type: 'date' },
    { key: 'publicityContent', label: '公示内容', type: 'textarea' },
    { key: 'reportInfo', label: '公示期间反映情况', type: 'textarea' },
    { key: 'publicityResult', label: '公示结果', type: 'select', options: ['无异议', '有异议待核实', '已核实不影响任职'] },
    { key: 'remark', label: '备注', type: 'textarea' }
  ],
  '任职': [
    { key: 'cadreId', label: '任职干部', type: 'cadre' },
    { key: 'deptId', label: '任职机构', type: 'dept' },
    { key: 'position', label: '任职职务', type: 'text' },
    { key: 'positionLevel', label: '职务层次', type: 'select', options: ['校级', '处级', '科级'] },
    { key: 'appointDate', label: '任职日期', type: 'date' },
    { key: 'appointDocNo', label: '任职文号', type: 'text' },
    { key: 'isCurrent', label: '是否现任', type: 'yesno' }
  ]
}

const registerFields = computed(() => stepFieldDefs[registerStep.value] || [])
const registerResource = computed(() => {
  const map = {
    '动议': 'motion',
    '民主推荐': 'recommend',
    '考察': 'investigation',
    '讨论决定': 'decision',
    '公示': 'publicity',
    '任职': 'record'
  }
  return map[registerStep.value] || ''
})

function getStepName(key) {
  const seg = stepSegments.value.find(s => s.key === key)
  return seg ? seg.name : key
}

function initRegisterForm(existing) {
  for (const k of Object.keys(registerForm)) delete registerForm[k]
  const empty = {}
  registerFields.value.forEach(f => {
    let v = existing ? existing[f.key] : null
    if (f.type === 'number') v = v == null ? 0 : v
    empty[f.key] = v
  })
  Object.assign(registerForm, empty)
}

function openRegister(step) {
  registerStep.value = step
  const p = currentProcess.value
  const exist = p && (p[registerResource.value] || null)
  initRegisterForm(exist)
  registerVisible.value = true
}

async function handleRegisterSubmit() {
  const p = currentProcess.value
  const resource = registerResource.value
  if (!resource) return
  registerSubmitting.value = true
  try {
    const payload = {}
    registerFields.value.forEach(f => {
      const v = registerForm[f.key]
      if (v !== null && v !== undefined && v !== '') payload[f.key] = v
    })
    const existing = p[resource] || null
    const url = `/appoint-process/${p._id}/${resource}`
    if (existing && existing.id != null) {
      await request({ url, method: 'put', data: { id: existing.id, ...payload } })
      ElMessage.success('环节登记已更新')
    } else {
      await request({ url, method: 'post', data: payload })
      ElMessage.success('环节登记已保存')
    }
    registerVisible.value = false
    const res = await request({ url: `/appoint-process/${p._id}`, method: 'get' })
    currentProcess.value = decorateRow(res.data)
    currentProcess.value._id = res.data.id
  } catch (e) {
    ElMessage.error('登记保存失败')
  } finally {
    registerSubmitting.value = false
  }
}

function handleExport() {
  showExportDialog(filteredData.value.map(decorateRow), [
    { prop: 'positionInfo', label: '选拔职位信息' },
    { prop: 'currentStep', label: '当前环节' },
    { prop: 'cadreName', label: '关联人选' },
    { prop: 'processStatus', label: '状态' },
    { prop: 'startTimeText', label: '启动时间' },
    { prop: 'endTimeText', label: '结束时间' }
  ], '干部任免流程')
}

onMounted(async () => {
  await loadDicts()
  await fetchAll()
})
</script>

<style scoped>
.process-detail { font-size: 13px; }
.step-title { font-size: 14px; font-weight: bold; color: #1976D2; margin-bottom: 10px; padding-left: 8px; border-left: 3px solid #1976D2; }
.step-panel { max-height: 430px; overflow-y: auto; padding-right: 8px; }
</style>
