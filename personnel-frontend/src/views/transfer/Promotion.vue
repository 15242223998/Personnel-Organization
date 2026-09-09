<template>
  <div>
    <div class="page-header">职级晋升管理</div>

    <div class="search-bar">
      <el-form :inline="true" :model="queryForm" size="default">
        <el-form-item label="姓名">
          <el-input v-model="queryForm.name" placeholder="输入姓名" style="width:120px" clearable />
        </el-form-item>
        <el-form-item label="原职级">
          <el-select v-model="queryForm.origRankId" placeholder="全部" style="width:180px" clearable filterable>
            <el-option v-for="r in rankOptions" :key="r.id" :label="r.rankName" :value="r.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="新职级">
          <el-select v-model="queryForm.newRankId" placeholder="全部" style="width:180px" clearable filterable>
            <el-option v-for="r in rankOptions" :key="r.id" :label="r.rankName" :value="r.id" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAddDialog"><el-icon><Plus /></el-icon> 新增晋升</el-button>
      <el-button type="success" @click="showEligible"><el-icon><User /></el-icon> 在职干部候选</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" sortable />
        <el-table-column prop="genderText" label="性别" width="60" align="center" sortable />
        <el-table-column prop="deptName" label="现机构" min-width="160" show-overflow-tooltip sortable />
        <el-table-column prop="origRankName" label="原职级" min-width="150" align="center" sortable />
        <el-table-column prop="newRankName" label="新职级" min-width="150" align="center" sortable>
          <template #default="{row}">
            <el-tag type="primary" size="small">{{ row.newRankName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="promotionDateText" label="晋升日期" width="110" align="center" sortable />
        <el-table-column prop="docNo" label="文号" min-width="140" show-overflow-tooltip sortable />
        <el-table-column prop="remark" label="备注" min-width="160" show-overflow-tooltip />
        <el-table-column label="操作" width="130" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openEditDialog(row)">编辑</span>
            <span class="link-blue" style="margin-left:8px;color:#E53935" @click="handleDelete(row)">删除</span>
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

    <!-- 新增/编辑晋升对话框（新增 POST /promotion、编辑 PUT /promotion） -->
    <el-dialog v-model="addDialogVisible" :title="editingId ? '编辑职级晋升' : '新增职级晋升'" width="580px" destroy-on-close>
      <el-form :model="addForm" label-width="90px" size="default" :rules="addRules" ref="addFormRef">
        <el-form-item label="选择干部" prop="cadreId">
          <el-select v-model="addForm.cadreId" placeholder="请选择在职干部" style="width:100%" filterable @change="handleCadreChange">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + '（' + (c.deptName || '-') + '）'" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="原职级">
          <el-input :model-value="origRankNameText" disabled style="width:100%" />
        </el-form-item>
        <el-form-item label="新职级" prop="toRankId">
          <el-select v-model="addForm.toRankId" placeholder="请选择新职级" style="width:100%" filterable>
            <el-option v-for="r in rankOptions" :key="r.id" :label="r.rankName" :value="r.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="晋升日期" prop="promotionDate">
          <el-date-picker v-model="addForm.promotionDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择晋升日期" />
        </el-form-item>
        <el-form-item label="文号">
          <el-input v-model="addForm.docNo" placeholder="请输入发文文号（须与实际发文一致）" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="addForm.remark" type="textarea" :rows="2" placeholder="请输入备注信息" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible=false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSave">确定</el-button>
      </template>
    </el-dialog>

    <!-- 符合晋升条件干部对话框（真实资格判定 /promotion/eligible） -->
    <el-dialog v-model="eligibleDialogVisible" title="符合晋升条件干部（资格判定）" width="880px" destroy-on-close>
      <el-alert type="success" :closable="false" show-icon style="margin-bottom:10px"
        title="资格判定由后端 /api/promotion/eligible 实时计算：仅在职干部、有现任职务、有当前职级，且任现职级年限（按最近晋升/任现职孰晚）满足 org_rank 晋升年限要求；可选“拟晋升职级”做层级过滤。" />
      <div class="search-bar" style="margin-bottom:10px">
        <span class="label">姓名：</span>
        <el-input v-model="eligibleQuery.keyword" placeholder="姓名模糊" clearable size="small" style="width:150px" @keyup.enter="handleEligibleSearch" />
        <span class="label" style="margin-left:10px">拟晋升职级：</span>
        <el-select v-model="eligibleQuery.fromRankId" placeholder="不限" clearable filterable size="small" style="width:180px">
          <el-option v-for="r in rankOptions" :key="r.id" :label="r.rankName" :value="r.id" />
        </el-select>
        <el-button type="primary" size="small" style="margin-left:10px" @click="handleEligibleSearch"><el-icon><Search /></el-icon> 查询</el-button>
        <el-button size="small" @click="handleEligibleReset">重置</el-button>
      </div>
      <el-table :data="eligibleRecords" border size="small" max-height="360" v-loading="eligibleLoading">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="deptName" label="所在机构" min-width="150" show-overflow-tooltip />
        <el-table-column prop="position" label="现任职务" min-width="140" show-overflow-tooltip />
        <el-table-column label="现职级" min-width="170" align="center">
          <template #default="{ row }">
            {{ row.currentRankName || '-' }}
            <el-tag v-if="row.currentRankCode" type="info" size="small" effect="plain" style="margin-left:4px">{{ row.currentRankCode }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="yearsText" label="满足年限说明" min-width="230" show-overflow-tooltip />
        <el-table-column label="考核核验" width="150" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.assessmentQualified" type="success" size="small">考核达标(近三年)</el-tag>
            <el-tag v-else type="danger" size="small">考核未达标</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="70" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="selectEligible(row)">选择</span>
          </template>
        </el-table-column>
        <template #empty>
          <span style="color:#999">暂无可晋升干部：可能为当前筛选条件下无符合条件记录，或存在未通过近三年考核核验的干部</span>
        </template>
      </el-table>
      <div style="margin-top:8px;text-align:right">
        <el-pagination
          v-model:current-page="eligibleQuery.current"
          v-model:page-size="eligibleQuery.size"
          :page-sizes="[10, 20, 50]"
          :total="eligibleTotal"
          layout="total, sizes, prev, pager, next"
          background
          small
          @size-change="loadEligible"
          @current-change="loadEligible"
        />
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, User, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'

const loading = ref(false)
const addDialogVisible = ref(false)
const editingId = ref(null)
const eligibleDialogVisible = ref(false)
const eligibleLoading = ref(false)
const eligibleRecords = ref([])
const eligibleTotal = ref(0)
const eligibleQuery = reactive({ current: 1, size: 10, fromRankId: null, keyword: '' })
const addFormRef = ref(null)
const saving = ref(false)

const queryForm = reactive({ name: '', origRankId: null, newRankId: null })
const page = reactive({ current: 1, size: 10 })

const rankOptions = ref([])
const onJobCadreOptions = ref([])
const cadreMap = ref({})
const deptNameMap = ref({})

const allRecords = ref([])

function fmtDate(v) {
  if (v === null || v === undefined || v === '') return '-'
  return String(v).slice(0, 10)
}

async function loadDicts() {
  try {
    const [rankRes, orgRes, cadreRes] = await Promise.all([
      request({ url: '/rank/list', method: 'get' }),
      request({ url: '/organization/tree', method: 'get' }),
      request({ url: '/cadre/page', method: 'post', params: { current: 1, size: 2000 } })
    ])
    rankOptions.value = (rankRes.data || []).slice().sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
    const depts = []
    const walk = (list) => {
      ;(list || []).forEach(n => {
        depts.push(n)
        if (n.children && n.children.length) walk(n.children)
      })
    }
    walk(orgRes.data || [])
    const dmap = {}
    depts.forEach(d => { dmap[d.id] = d.deptName })
    deptNameMap.value = dmap
    const cadres = (cadreRes.data && cadreRes.data.records) || []
    const cmap = {}
    cadres.forEach(c => { cmap[c.id] = c })
    cadreMap.value = cmap
    onJobCadreOptions.value = cadres.filter(c => c.cadreStatus === 'ON_JOB').map(c => ({
      id: c.id,
      name: c.name,
      deptId: c.deptId,
      deptName: dmap[c.deptId] || '-',
      rankId: c.rankId,
      positionLevel: c.positionLevel || '-',
      positionStartDate: c.positionStartDate || ''
    }))
  } catch (e) {
    rankOptions.value = []
    onJobCadreOptions.value = []
  }
}

async function fetchAll() {
  loading.value = true
  try {
    const all = []
    let current = 1
    let total = null
    const size = 50
    while (true) {
      const res = await request({ url: '/promotion/page', method: 'get', params: { current, size } })
      const data = (res && res.data) || {}
      const records = data.records || []
      records.forEach(r => all.push(r))
      total = data.total != null ? data.total : all.length
      if (all.length >= total || records.length === 0) break
      current++
      if (current > 100) break
    }
    allRecords.value = all
  } catch (e) {
    allRecords.value = []
  } finally {
    loading.value = false
  }
}

function rankNameById(id) {
  if (id == null) return '-'
  const r = rankOptions.value.find(x => x.id === id)
  return r ? r.rankName : ('#' + id)
}

function genderTextOf(c) {
  if (!c) return '-'
  if (c.gender === 1) return '男'
  if (c.gender === 2) return '女'
  return '-'
}

function decorate(r) {
  const c = cadreMap.value[r.cadreId] || null
  return {
    ...r,
    name: c ? c.name : ('#' + r.cadreId),
    genderText: genderTextOf(c),
    deptName: c ? (deptNameMap.value[c.deptId] || '-') : '-',
    origRankName: rankNameById(r.fromRankId),
    newRankName: rankNameById(r.toRankId),
    promotionDateText: fmtDate(r.promotionDate)
  }
}

const filteredRecords = computed(() => {
  let list = allRecords.value
  if (queryForm.origRankId) list = list.filter(r => r.fromRankId === queryForm.origRankId)
  if (queryForm.newRankId) list = list.filter(r => r.toRankId === queryForm.newRankId)
  if (queryForm.name) {
    const ids = []
    Object.values(cadreMap.value).forEach(c => {
      if (c && c.name && c.name.includes(queryForm.name)) ids.push(c.id)
    })
    list = list.filter(r => ids.includes(r.cadreId))
  }
  return list.map(decorate).sort((a, b) => String(b.promotionDate || '').localeCompare(String(a.promotionDate || '')))
})

const pageTotal = computed(() => filteredRecords.value.length)

const tableData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredRecords.value.slice(start, start + page.size)
})

function handleSearch() { page.current = 1 }
function handleReset() {
  Object.assign(queryForm, { name: '', origRankId: null, newRankId: null })
  page.current = 1
}
function handleSizeChange() { page.current = 1 }

// ---------- 新增/编辑晋升（真实提交 POST /promotion、PUT /promotion） ----------
const addForm = reactive({
  cadreId: null,
  fromRankId: null,
  toRankId: null,
  promotionDate: '',
  docNo: '',
  remark: ''
})

const addRules = {
  cadreId: [{ required: true, message: '请选择干部', trigger: 'change' }],
  toRankId: [{ required: true, message: '请选择新职级', trigger: 'change' }],
  promotionDate: [{ required: true, message: '请选择晋升日期', trigger: 'change' }]
}

const origRankNameText = computed(() => {
  if (!addForm.fromRankId) return '-'
  return rankNameById(addForm.fromRankId)
})

// 干部候选：新增只列在职干部；编辑时若原记录干部已非在职，临时并入以便回填展示（不污染新增候选）
const cadreOptions = computed(() => {
  const list = onJobCadreOptions.value.slice()
  if (editingId.value && addForm.cadreId != null && !list.some(x => x.id === addForm.cadreId)) {
    const c = cadreMap.value[addForm.cadreId]
    if (c) {
      list.push({
        id: c.id,
        name: c.name,
        deptId: c.deptId,
        deptName: deptNameMap.value[c.deptId] || '-',
        rankId: c.rankId,
        positionLevel: c.positionLevel || '-',
        positionStartDate: c.positionStartDate || ''
      })
    }
  }
  return list
})

function openAddDialog() {
  editingId.value = null
  Object.assign(addForm, { cadreId: null, fromRankId: null, toRankId: null, promotionDate: '', docNo: '', remark: '' })
  addDialogVisible.value = true
}

function openEditDialog(row) {
  editingId.value = row.id
  Object.assign(addForm, {
    cadreId: row.cadreId,
    // 原职级沿用该条记录自身 from_rank_id（不随档案现职级漂移）
    fromRankId: row.fromRankId != null ? row.fromRankId : null,
    toRankId: row.toRankId,
    promotionDate: row.promotionDate ? String(row.promotionDate).slice(0, 10) : '',
    docNo: row.docNo || '',
    remark: row.remark || ''
  })
  addDialogVisible.value = true
}

function handleCadreChange(id) {
  const c = cadreOptions.value.find(x => x.id === id)
  addForm.fromRankId = c ? (c.rankId || null) : null
}

function handleDelete(row) {
  ElMessageBox.confirm(
    `确定删除「${row.name}」${fmtDate(row.promotionDate)} 由「${row.origRankName}」晋升至「${row.newRankName}」的这条记录吗？删除后将按该干部剩余晋升记录联动其档案职级（无剩余记录则回退为晋升前职级）。`,
    '删除确认',
    { type: 'warning', confirmButtonText: '删除', cancelButtonText: '取消' }
  ).then(async () => {
    try {
      await request({ url: `/promotion/${row.id}`, method: 'delete' })
      ElMessage.success('删除成功，该干部职级已联动更新')
      await fetchAll()
    } catch (e) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// ---------- 符合晋升条件干部（真实资格判定 /promotion/eligible，服务端分页） ----------
async function loadEligible() {
  eligibleLoading.value = true
  try {
    const params = {
      current: eligibleQuery.current,
      size: eligibleQuery.size,
      fromRankId: eligibleQuery.fromRankId || null,
      keyword: eligibleQuery.keyword || ''
    }
    const res = await request({ url: '/promotion/eligible', method: 'get', params })
    const data = (res && res.data) || {}
    eligibleRecords.value = data.records || []
    eligibleTotal.value = data.total != null ? data.total : 0
  } catch (e) {
    eligibleRecords.value = []
    eligibleTotal.value = 0
  } finally {
    eligibleLoading.value = false
  }
}

function handleEligibleSearch() {
  eligibleQuery.current = 1
  loadEligible()
}

function handleEligibleReset() {
  Object.assign(eligibleQuery, { current: 1, fromRankId: null, keyword: '' })
  loadEligible()
}

function showEligible() {
  eligibleQuery.current = 1
  eligibleDialogVisible.value = true
  loadEligible()
}

// 选中候选人 → 一键带入“新增晋升办理”表单（cadreId + 原职级=其当前职级）
function selectEligible(row) {
  eligibleDialogVisible.value = false
  editingId.value = null
  addForm.cadreId = row.cadreId
  addForm.fromRankId = row.currentRankId || null
  addDialogVisible.value = true
}

async function handleSave() {
  addFormRef.value.validate(async (valid) => {
    if (!valid) return
    saving.value = true
    try {
      const payload = {
        cadreId: addForm.cadreId,
        fromRankId: addForm.fromRankId || null,
        toRankId: addForm.toRankId,
        promotionDate: addForm.promotionDate,
        docNo: addForm.docNo || '',
        remark: addForm.remark || ''
      }
      if (editingId.value) {
        payload.id = editingId.value
        await request({ url: '/promotion', method: 'put', data: payload })
        ElMessage.success('晋升记录更新成功，该干部职级已联动更新')
      } else {
        await request({ url: '/promotion', method: 'post', data: payload })
        ElMessage.success('晋升记录保存成功')
      }
      addDialogVisible.value = false
      await fetchAll()
    } catch (e) {
      ElMessage.error(editingId.value ? '更新失败' : '保存失败')
    } finally {
      saving.value = false
    }
  })
}

function handleExport() {
  showExportDialog(filteredRecords.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'genderText', label: '性别' },
    { prop: 'deptName', label: '现机构' },
    { prop: 'origRankName', label: '原职级' },
    { prop: 'newRankName', label: '新职级' },
    { prop: 'promotionDateText', label: '晋升日期' },
    { prop: 'docNo', label: '文号' },
    { prop: 'remark', label: '备注' }
  ], '职级晋升')
}

async function init() {
  await loadDicts()
  await fetchAll()
}
init()
</script>
