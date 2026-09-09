<template>
  <div>
    <div class="page-header">后备干部库</div>

    <div class="search-bar">
      <el-form :inline="true" :model="queryForm" size="default">
        <el-form-item label="姓名">
          <el-input v-model="queryForm.name" placeholder="请输入姓名" style="width:140px" clearable />
        </el-form-item>
        <el-form-item label="后备类型">
          <el-select v-model="queryForm.reserveType" placeholder="全部" style="width:130px" clearable>
            <el-option label="正职后备" value="正职" />
            <el-option label="副职后备" value="副职" />
          </el-select>
        </el-form-item>
        <el-form-item label="后备级别">
          <el-select v-model="queryForm.reserveLevel" placeholder="全部" style="width:130px" clearable>
            <el-option label="正厅级" value="正厅级" />
            <el-option label="副厅级" value="副厅级" />
            <el-option label="正处级" value="正处级" />
            <el-option label="副处级" value="副处级" />
            <el-option label="正科级" value="正科级" />
            <el-option label="副科级" value="副科级" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd"><el-icon><Plus /></el-icon> 添加后备干部</el-button>
      <el-button type="warning" :disabled="selectedRows.length === 0" @click="handleBatchRemove">
        <el-icon><Delete /></el-icon> 移出后备库
      </el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table
        :data="tableData"
        border
        size="small"
        v-loading="loading"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="45" align="center" />
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="genderText" label="性别" width="60" align="center" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="100" align="center" />
        <el-table-column prop="education" label="学历" width="110" align="center" />
        <el-table-column prop="position" label="现职务" min-width="160" show-overflow-tooltip />
        <el-table-column prop="rankName" label="现职级" width="120" align="center" />
        <el-table-column label="考核核验" width="190" align="center">
          <template #default="{ row }">
            <el-tag v-if="qualifiedOf(row.cadreId) === true" type="success" size="small">考核达标</el-tag>
            <el-tag v-else-if="checkOf(row.cadreId)" type="warning" size="small" effect="plain">{{ reasonOf(row.cadreId) }}</el-tag>
            <span v-else style="color:#bbb">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="reserveType" label="后备类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.reserveType === '正职' ? 'danger' : 'primary'" size="small">
              {{ row.reserveType }}后备
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reserveLevel" label="级别" width="90" align="center" />
        <el-table-column prop="enterDate" label="入库日期" width="110" align="center" />
        <el-table-column prop="status" label="状态" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '在库' : '已出库' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <span class="link-blue" style="margin:0 8px" @click="handleEdit(row)">编辑</span>
            <span class="link-blue" style="color:#E53935" @click="handleRemove(row)">移出</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        background
        small
        @current-change="fetchData"
        @size-change="handleSizeChange"
      />
    </div>

    <el-dialog
      :title="isEdit ? '编辑后备干部' : '添加后备干部'"
      v-model="dialogVisible"
      width="520px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px" size="default">
        <el-form-item label="选择干部" prop="cadreId">
          <el-select v-model="form.cadreId" filterable placeholder="请搜索选择干部" style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + ' - ' + (c.position || '')" :value="c.id" :disabled="c.inReserve && c.id !== form.cadreId" />
          </el-select>
        </el-form-item>
        <el-form-item label="后备类型" prop="reserveType">
          <el-radio-group v-model="form.reserveType">
            <el-radio value="正职">正职后备</el-radio>
            <el-radio value="副职">副职后备</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="后备级别" prop="reserveLevel">
          <el-select v-model="form.reserveLevel" placeholder="请选择后备级别" style="width:100%">
            <el-option label="正厅级" value="正厅级" />
            <el-option label="副厅级" value="副厅级" />
            <el-option label="正处级" value="正处级" />
            <el-option label="副处级" value="副处级" />
            <el-option label="正科级" value="正科级" />
            <el-option label="副科级" value="副科级" />
          </el-select>
        </el-form-item>
        <el-form-item label="入库日期" prop="enterDate">
          <el-date-picker v-model="form.enterDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择入库日期" />
        </el-form-item>
        <el-form-item label="在库状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">在库</el-radio>
            <el-radio :value="0">已出库</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, Delete, Download } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { getCadrePage } from '@/api/cadre'
import { showExportDialog } from '@/utils/export-store'

const router = useRouter()
const loading = ref(false)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)
const selectedRows = ref([])
const tableData = ref([])

// 真实字典：干部池 / 机构名 / 职级名
const cadreOptions = ref([])
const reserveIds = ref(new Set())
const cadreMap = ref({})
const deptNameMap = ref({})
const rankNameMap = ref({})

const queryForm = reactive({
  name: '',
  reserveType: '',
  reserveLevel: ''
})

// ---------- 考核核验（近三年考核称职以上，批量接口 GET /reserve/assessment-check） ----------
const assessmentMap = ref({})
function checkOf(cadreId) {
  if (cadreId == null) return null
  const m = assessmentMap.value || {}
  return m[cadreId] || null // JSON 对象键为字符串，数字索引自动转换
}
function qualifiedOf(cadreId) {
  const ch = checkOf(cadreId)
  return ch ? !!ch.qualified : null
}
function reasonOf(cadreId) {
  const ch = checkOf(cadreId)
  return (ch && ch.reason) || '考核记录不足'
}
async function fetchAssessmentCheck(ids) {
  const uniq = [...new Set((ids || []).map(Number).filter(n => Number.isFinite(n)))]
  if (uniq.length === 0) {
    assessmentMap.value = {}
    return
  }
  const CHUNK = 150
  const tasks = []
  for (let i = 0; i < uniq.length; i += CHUNK) {
    const chunk = uniq.slice(i, i + CHUNK)
    tasks.push(request.get('/reserve/assessment-check', { params: { cadreIds: chunk.join(',') } })
      .then(r => r.data || {}).catch(() => ({})))
  }
  const merged = {}
  ;(await Promise.all(tasks)).forEach(m => Object.assign(merged, m || {}))
  assessmentMap.value = merged
}
function reloadAssessmentTags() {
  return fetchAssessmentCheck(Object.keys(cadreMap.value))
}

const page = reactive({ current: 1, size: 10, total: 0 })
const allRows = ref([])

const form = reactive({
  cadreId: null,
  reserveType: '副职',
  reserveLevel: '',
  enterDate: '',
  status: 1
})

const rules = {
  cadreId: [{ required: true, message: '请选择干部', trigger: 'change' }],
  reserveType: [{ required: true, message: '请选择后备类型', trigger: 'change' }],
  reserveLevel: [{ required: true, message: '请选择后备级别', trigger: 'change' }],
  enterDate: [{ required: true, message: '请选择入库日期', trigger: 'change' }]
}

function fmtDate(v) {
  if (!v) return ''
  return String(v).substring(0, 10)
}

async function loadDictAndCadrePool() {
  const [treeRes, rankRes, cadreRes] = await Promise.all([
    request.get('/organization/tree').catch(() => null),
    request.get('/rank/list').catch(() => null),
    getCadrePage({ current: 1, size: 2000 }).catch(() => null)
  ])
  const deptMap = {}
  const walk = nodes => {
    if (!Array.isArray(nodes)) return
    nodes.forEach(o => {
      if (o && o.id != null) deptMap[o.id] = o.deptName || o.shortName || ''
      walk(o.children)
    })
  }
  walk(treeRes && treeRes.data)
  deptNameMap.value = deptMap
  const rankMap = {}
  if (rankRes && Array.isArray(rankRes.data)) {
    rankRes.data.forEach(r => { if (r && r.id != null) rankMap[r.id] = r.rankName })
  }
  rankNameMap.value = rankMap
  const cadres = {}
  if (cadreRes && Array.isArray(cadreRes.data.records)) {
    cadreRes.data.records.forEach(c => { if (c && c.id != null) cadres[c.id] = c })
  }
  cadreMap.value = cadres
}

function refreshCadreOptions() {
  const ids = new Set(reserveIds.value)
  cadreOptions.value = Object.keys(cadreMap.value).map(id => {
    const c = cadreMap.value[Number(id)]
    return {
      id: c.id,
      name: c.name || '',
      position: c.position || '',
      inReserve: ids.has(c.id)
    }
  })
}

function decorateRow(r) {
  const c = cadreMap.value[r.cadreId] || {}
  return {
    id: r.id,
    cadreId: r.cadreId,
    name: c.name || '未知',
    genderText: c.gender === 1 ? '男' : c.gender === 2 ? '女' : '-',
    birthDate: fmtDate(c.birthDate),
    politicalStatus: c.politicalStatus || '',
    education: c.fullTimeEducation || '',
    deptId: c.deptId,
    position: c.position || '',
    rankName: c.rankId != null ? (rankNameMap.value[c.rankId] || '-') : '-',
    reserveType: r.reserveType || '',
    reserveLevel: r.reserveLevel || '',
    enterDate: fmtDate(r.enterDate),
    status: r.status === 0 ? 0 : 1
  }
}

async function fetchReserveRows() {
  try {
    const res = await request.get('/cadre-reserve/list')
    const list = Array.isArray(res.data) ? res.data : []
    reserveIds.value = new Set(list.map(r => r.cadreId).filter(id => id != null))
    allRows.value = list.map(decorateRow)
  } catch (e) {
    reserveIds.value = new Set()
    allRows.value = []
  }
}

function applyFilter() {
  let data = [...allRows.value]
  if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
  if (queryForm.reserveType) data = data.filter(d => d.reserveType === queryForm.reserveType)
  if (queryForm.reserveLevel) data = data.filter(d => d.reserveLevel === queryForm.reserveLevel)
  return data
}

async function fetchData() {
  loading.value = true
  try {
    await fetchReserveRows()
    const data = applyFilter()
    page.total = data.length
    const start = (page.current - 1) * page.size
    tableData.value = data.slice(start, start + page.size)
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
  Object.assign(queryForm, { name: '', reserveType: '', reserveLevel: '' })
  page.current = 1
  fetchData()
}

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { cadreId: null, reserveType: '副职', reserveLevel: '', enterDate: '', status: 1 })
}

function openAdd() {
  resetForm()
  dialogVisible.value = true
}

function handleView(row) {
  if (row.cadreId != null) router.push(`/cadre/${row.cadreId}`)
}

function handleEdit(row) {
  resetForm()
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    cadreId: row.cadreId,
    reserveType: row.reserveType,
    reserveLevel: row.reserveLevel,
    enterDate: row.enterDate,
    status: row.status
  })
  dialogVisible.value = true
}

function handleSubmit() {
  formRef.value?.validate(async (valid) => {
    if (!valid) return
    submitLoading.value = true
    try {
      const payload = {
        cadreId: form.cadreId,
        reserveType: form.reserveType,
        reserveLevel: form.reserveLevel,
        enterDate: form.enterDate || null,
        status: form.status === 0 ? 0 : 1
      }
      if (isEdit.value) {
        payload.id = editId.value
        await request.put('/cadre-reserve', payload)
        ElMessage.success('更新成功')
      } else {
        await request.post('/cadre-reserve', payload)
        ElMessage.success('添加成功')
      }
      dialogVisible.value = false
      await loadDictAndCadrePool()
      await fetchData()
      refreshCadreOptions()
      await reloadAssessmentTags()
    } catch (e) {
      ElMessage.error(e.message || '保存失败')
    } finally {
      submitLoading.value = false
    }
  })
}

async function handleRemove(row) {
  try {
    await ElMessageBox.confirm(`确定将"${row.name}"移出后备干部库吗？`, '移出确认', {
      type: 'warning',
      confirmButtonText: '确定移出',
      cancelButtonText: '取消'
    })
  } catch (e) {
    return
  }
  try {
    await request.delete(`/cadre-reserve/${row.id}`)
    ElMessage.success('已移出后备库')
    await loadDictAndCadrePool()
    await fetchData()
    refreshCadreOptions()
  } catch (e) {
    ElMessage.error(e.message || '移出失败')
  }
}

async function handleBatchRemove() {
  if (selectedRows.value.length === 0) return
  const names = selectedRows.value.map(r => r.name).join('、')
  try {
    await ElMessageBox.confirm(`确定将选中的 ${selectedRows.value.length} 名干部（${names}）移出后备干部库吗？`, '批量移出确认', {
      type: 'warning',
      confirmButtonText: '确定移出',
      cancelButtonText: '取消'
    })
  } catch (e) {
    return
  }
  try {
    for (const row of selectedRows.value) {
      await request.delete(`/cadre-reserve/${row.id}`)
    }
    ElMessage.success('批量移出成功')
    selectedRows.value = []
    await loadDictAndCadrePool()
    await fetchData()
    refreshCadreOptions()
  } catch (e) {
    ElMessage.error(e.message || '批量移出失败')
  }
}

function handleSelectionChange(rows) {
  selectedRows.value = rows.filter(r => r.status === 1)
}

function handleExport() {
  const data = applyFilter()
  if (data.length === 0) {
    ElMessage.warning('当前条件下没有可导出的数据')
    return
  }
  showExportDialog(data, [
    { prop: 'name', label: '姓名' },
    { prop: 'genderText', label: '性别' },
    { prop: 'birthDate', label: '出生年月' },
    { prop: 'politicalStatus', label: '政治面貌' },
    { prop: 'education', label: '学历' },
    { prop: 'position', label: '现职务' },
    { prop: 'rankName', label: '现职级' },
    { prop: 'reserveType', label: '后备类型' },
    { prop: 'reserveLevel', label: '级别' },
    { prop: 'enterDate', label: '入库日期' },
    { prop: 'status', label: '状态' }
  ], '后备干部库')
}

onMounted(async () => {
  await loadDictAndCadrePool()
  await fetchData()
  refreshCadreOptions()
  // 已入库列表/候选池的考核核验 tag（批量核验接口 /reserve/assessment-check）
  reloadAssessmentTags()
})
</script>

<style scoped>
</style>
