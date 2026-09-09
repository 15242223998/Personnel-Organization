<template>
  <div>
    <div class="page-header">干部调配管理</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <el-tab-pane v-for="tab in tabs" :key="tab.key" :label="tab.label" :name="tab.key">
        <div class="search-bar">
          <el-form :inline="true" size="default">
            <el-form-item label="姓名">
              <el-input v-model="tabQuery[tab.key].name" placeholder="输入姓名" style="width:130px" clearable />
            </el-form-item>
            <el-form-item label="调配类型">
              <el-select v-model="tabQuery[tab.key].type" placeholder="全部" style="width:130px" clearable>
                <el-option v-for="t in tab.typeOptions" :key="t" :label="t" :value="t" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
              <el-button @click="resetQuery(tab.key)"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
            </el-form-item>
          </el-form>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openCreate(tab.key)"><el-icon><Plus /></el-icon> {{ tab.createLabel }}</el-button>
          <el-button @click="handleExport(tab.key)"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="currentTableData" border size="small" v-loading="loading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="90" align="center" sortable />
            <el-table-column prop="transferType" label="调配类型" width="100" align="center" sortable />
            <el-table-column prop="fromDeptName" label="原机构" min-width="150" show-overflow-tooltip sortable />
            <el-table-column prop="fromPosition" label="原职务" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="toDeptName" label="目标机构" min-width="150" show-overflow-tooltip sortable />
            <el-table-column prop="toPosition" label="新职务" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="transferDateText" label="调配日期" width="110" align="center" sortable />
            <el-table-column prop="docNo" label="文号" min-width="130" show-overflow-tooltip />
            <el-table-column prop="transferReason" label="原因/备注" min-width="170" show-overflow-tooltip />
            <el-table-column label="操作" width="130" align="center" fixed="right">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="openEdit(row)">编辑</el-button>
                <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="pager.current"
            v-model:page-size="pager.size"
            :page-sizes="[10, 20, 50]"
            :total="pagerTotal"
            layout="total, sizes, prev, pager, next"
            background
            small
            @size-change="handleSizeChange"
          />
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 新增/编辑调配记录对话框（新增 POST /transfer，编辑 PUT /transfer，删除 DELETE /transfer/{id}） -->
    <el-dialog v-model="createVisible" :title="createTitle" width="640px" destroy-on-close>
      <el-form :model="createForm" label-width="100px" size="default" :rules="createRules" ref="createFormRef">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="干部" prop="cadreId">
              <el-select v-model="createForm.cadreId" placeholder="请选择在职干部" filterable style="width:100%" @change="handleCadreChange">
                <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + '（' + (c.deptName || '-') + '）'" :value="c.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="调配类型" prop="transferType">
              <el-select v-model="createForm.transferType" placeholder="请选择" style="width:100%">
                <el-option v-for="t in currentTab.typeOptions" :key="t" :label="t" :value="t" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-descriptions :column="2" border size="small" style="margin-bottom:10px">
          <el-descriptions-item label="原机构">{{ createForm.fromDeptName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="原职务">{{ createForm.fromPosition || '-' }}</el-descriptions-item>
        </el-descriptions>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="目标机构">
              <el-select v-model="createForm.toDeptId" placeholder="请选择（调出/离职可不选）" clearable filterable style="width:100%">
                <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="拟任职务">
              <el-input v-model="createForm.toPosition" placeholder="请填写新职务" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="调配日期" prop="transferDate">
              <el-date-picker v-model="createForm.transferDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文号">
              <el-input v-model="createForm.docNo" placeholder="发文文号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="原因/备注">
          <el-input v-model="createForm.transferReason" type="textarea" :rows="2" placeholder="调配原因或备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createVisible=false">取消</el-button>
        <el-button type="primary" :loading="creating" @click="handleCreateSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'

const tabs = [
  { key: 'in', label: '调入', typeOptions: ['调入', '录用', '聘用', '转入'], createLabel: '新增调入记录', types: ['调入', '录用', '聘用', '转入'] },
  { key: 'out', label: '调出', typeOptions: ['调出', '辞职', '辞退', '离职'], createLabel: '新增调出记录', types: ['调出', '辞职', '辞退', '离职'] },
  { key: 'retire', label: '退休', typeOptions: ['退休'], createLabel: '办理退休', types: ['退休'] },
  { key: 'rotate', label: '轮岗', typeOptions: ['轮岗'], createLabel: '新增轮岗记录', types: ['轮岗'] }
]
const tabMap = {}
tabs.forEach(t => { tabMap[t.key] = t })

const activeTab = ref('in')
const currentTab = computed(() => tabMap[activeTab.value])

const loading = ref(false)
const createVisible = ref(false)
const creating = ref(false)
const editingId = ref(null)
const createFormRef = ref(null)
const createTitle = ref('')

const deptOptions = ref([])
const cadreOptions = ref([])
let deptNameMap = {}

const allRecords = ref([])
const tabQuery = reactive({
  in: { name: '', type: '' },
  out: { name: '', type: '' },
  retire: { name: '', type: '' },
  rotate: { name: '', type: '' }
})
const pager = reactive({ current: 1, size: 10 })

function fmtDate(v) {
  if (v === null || v === undefined || v === '') return '-'
  return String(v).slice(0, 10)
}

function cadreNameById(id) {
  if (id == null) return '-'
  const c = cadreOptions.value.find(x => x.id === id)
  if (c) return c.name
  const raw = cadreAllMap.value[id]
  return raw ? raw.name : ('#' + id)
}
const cadreAllMap = ref({})

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
    deptNameMap = {}
    depts.forEach(d => { deptNameMap[d.id] = d.deptName })
    const cadres = (cadreRes.data && cadreRes.data.records) || []
    const all = {}
    cadres.forEach(c => { all[c.id] = c })
    cadreAllMap.value = all
    cadreOptions.value = cadres.filter(c => c.cadreStatus === 'ON_JOB').map(c => ({ id: c.id, name: c.name, deptName: deptNameMap[c.deptId] || '-', deptId: c.deptId, position: c.position || '' }))
  } catch (e) {
    deptOptions.value = []
    cadreOptions.value = []
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
      const res = await request({ url: '/transfer/page', method: 'get', params: { current, size } })
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

function decorate(r) {
  return {
    ...r,
    name: cadreNameById(r.cadreId),
    fromDeptName: r.fromDeptId != null ? (deptNameMap[r.fromDeptId] || '#' + r.fromDeptId) : '-',
    toDeptName: r.toDeptId != null ? (deptNameMap[r.toDeptId] || '#' + r.toDeptId) : '-',
    transferDateText: fmtDate(r.transferDate)
  }
}

const filteredRecords = computed(() => {
  const tab = currentTab.value
  const q = tabQuery[activeTab.value]
  let list = allRecords.value.filter(r => tab.types.includes(r.transferType))
  if (q.name) {
    const ids = []
    Object.values(cadreAllMap.value).forEach(c => {
      if (c && c.name && c.name.includes(q.name)) ids.push(c.id)
    })
    list = list.filter(r => ids.includes(r.cadreId))
  }
  if (q.type) list = list.filter(r => r.transferType === q.type)
  return list.map(decorate).sort((a, b) => String(b.transferDate || '').localeCompare(String(a.transferDate || '')))
})

const pagerTotal = computed(() => filteredRecords.value.length)

const currentTableData = computed(() => {
  const start = (pager.current - 1) * pager.size
  return filteredRecords.value.slice(start, start + pager.size)
})

function handleSearch() { pager.current = 1 }
function resetQuery(key) {
  Object.assign(tabQuery[key], { name: '', type: '' })
  pager.current = 1
}
function handleSizeChange() { pager.current = 1 }

// ---------- 新增（真实提交） ----------
const createForm = reactive({
  cadreId: null,
  transferType: '',
  fromDeptId: null,
  fromPosition: '',
  fromDeptName: '',
  toDeptId: null,
  toPosition: '',
  transferDate: '',
  docNo: '',
  transferReason: ''
})

const createRules = {
  cadreId: [{ required: true, message: '请选择干部', trigger: 'change' }],
  transferType: [{ required: true, message: '请选择调配类型', trigger: 'change' }],
  transferDate: [{ required: true, message: '请选择调配日期', trigger: 'change' }]
}

function openCreate(key) {
  editingId.value = null
  createTitle.value = '新增' + tabMap[key].label + '记录'
  Object.assign(createForm, {
    cadreId: null,
    transferType: tabMap[key].typeOptions[0],
    fromDeptId: null,
    fromPosition: '',
    fromDeptName: '',
    toDeptId: null,
    toPosition: '',
    transferDate: '',
    docNo: '',
    transferReason: key === 'retire' ? '退休' : ''
  })
  createVisible.value = true
}

// 编辑弹窗复用新增表单：回填该行记录，未在职（如退休/调出）干部也允许作为档案展示与再保存
function ensureCadreOption(id) {
  if (id == null || cadreOptions.value.some(c => c.id === id)) return
  const c = cadreAllMap.value[id]
  if (c) {
    cadreOptions.value.push({
      id: c.id,
      name: c.name,
      deptName: deptNameMap[c.deptId] || '-',
      deptId: c.deptId,
      position: c.position || ''
    })
  }
}

function openEdit(row) {
  editingId.value = row.id
  createTitle.value = '编辑调配记录'
  ensureCadreOption(row.cadreId)
  Object.assign(createForm, {
    cadreId: row.cadreId,
    transferType: row.transferType,
    fromDeptId: row.fromDeptId != null ? row.fromDeptId : null,
    fromPosition: row.fromPosition || '',
    fromDeptName: row.fromDeptId != null ? (deptNameMap[row.fromDeptId] || '-') : '-',
    toDeptId: row.toDeptId != null ? row.toDeptId : null,
    toPosition: row.toPosition || '',
    transferDate: row.transferDate || '',
    docNo: row.docNo || '',
    transferReason: row.transferReason || row.remark || ''
  })
  createVisible.value = true
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(
      `确认删除「${row.name}」的「${row.transferType}」调配记录吗？删除后将按该干部剩余调配记录重算其档案状态。`,
      '删除确认',
      { type: 'warning', confirmButtonText: '删除', cancelButtonText: '取消' }
    )
  } catch (e) {
    return
  }
  try {
    await request({ url: '/transfer/' + row.id, method: 'delete' })
    ElMessage.success('调配记录已删除')
    await refreshList()
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

function handleCadreChange(id) {
  const c = cadreOptions.value.find(x => x.id === id)
  if (c) {
    createForm.fromDeptId = c.deptId || null
    createForm.fromDeptName = c.deptName || '-'
    createForm.fromPosition = c.position || ''
  }
}

async function handleCreateSubmit() {
  createFormRef.value.validate(async (valid) => {
    if (!valid) return
    creating.value = true
    try {
      const tab = currentTab.value
      const payload = {
        cadreId: createForm.cadreId,
        transferType: createForm.transferType,
        transferDate: createForm.transferDate,
        transferReason: createForm.transferReason || '',
        fromDeptId: tab.key === 'out' ? (createForm.fromDeptId || null) : null,
        fromPosition: tab.key === 'out' ? (createForm.fromPosition || '') : '',
        toDeptId: (tab.key === 'in' || tab.key === 'rotate') ? createForm.toDeptId : null,
        toPosition: (tab.key === 'in' || tab.key === 'rotate') ? (createForm.toPosition || '') : '',
        docNo: createForm.docNo || '',
        remark: ''
      }
      if (editingId.value) {
        payload.id = editingId.value
        await request({ url: '/transfer', method: 'put', data: payload })
        ElMessage.success('调配记录已更新')
      } else {
        await request({ url: '/transfer', method: 'post', data: payload })
        ElMessage.success('调配记录保存成功')
      }
      createVisible.value = false
      await refreshList()
    } catch (e) {
      ElMessage.error(editingId.value ? '更新失败' : '保存失败')
    } finally {
      creating.value = false
    }
  })
}

// 数据操作后刷新当前页签列表；若当前页已被删空则回到最后一页（页码回退到 1）
async function refreshList() {
  await fetchAll()
  if (pager.current > 1 && filteredRecords.value.length <= (pager.current - 1) * pager.size) {
    pager.current = 1
  }
}

function handleExport(key) {
  showExportDialog(filteredRecords.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'transferType', label: '调配类型' },
    { prop: 'fromDeptName', label: '原机构' },
    { prop: 'fromPosition', label: '原职务' },
    { prop: 'toDeptName', label: '目标机构' },
    { prop: 'toPosition', label: '新职务' },
    { prop: 'transferDateText', label: '调配日期' },
    { prop: 'docNo', label: '文号' },
    { prop: 'transferReason', label: '原因/备注' }
  ], '干部调配-' + tabMap[key].label)
}

async function init() {
  await loadDicts()
  await fetchAll()
}
init()
</script>

<style scoped>
.gov-tabs :deep(.el-tabs__header) {
  background: #fff;
  margin: 0;
  padding: 0 14px;
  border: 1px solid #e0e0e0;
  border-bottom: 2px solid #1976D2;
}
.gov-tabs :deep(.el-tabs__nav-wrap::after) {
  display: none;
}
.gov-tabs :deep(.el-tabs__content) {
  padding-top: 0;
}
</style>
