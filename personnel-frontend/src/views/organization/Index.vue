<template>
  <div>
    <div class="page-header">组织机构管理</div>

    <div class="table-wrap">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="机构列表" name="tree">
          <div class="search-bar">
            <span class="label">机构名称：</span>
            <el-input v-model="searchForm.deptName" placeholder="请输入机构名称" clearable style="width:200px" />
            <span class="label">机构级别：</span>
            <el-select v-model="searchForm.deptLevel" placeholder="请选择级别" clearable style="width:150px">
              <el-option label="校级" value="校级" />
              <el-option label="处级" value="处级" />
              <el-option label="科级" value="科级" />
            </el-select>
            <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </div>
          <div class="toolbar">
            <el-button type="primary" @click="openAdd(null)"><el-icon><Plus /></el-icon> 新增机构</el-button>
            <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
          </div>
          <el-table :data="filteredTreeData" row-key="id" border size="small" v-loading="loading" :tree-props="{children:'children'}" default-expand-all>
            <el-table-column prop="deptName" label="机构名称" min-width="200" />
            <el-table-column prop="shortName" label="简称" min-width="110" />
            <el-table-column prop="deptLevel" label="级别" width="100" />
            <el-table-column prop="leaderQuota" label="班子职数" width="100" />
            <el-table-column prop="establishedDateText" label="成立时间" width="120" />
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="deptSort" label="排序" width="70" />
            <el-table-column label="操作" width="220" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openAdd(row)" style="margin-right:10px">新增子级</span>
                <span class="link-blue" @click="openEdit(row)" style="margin-right:10px">编辑</span>
                <span class="link-blue" style="color:#f56c6c" @click="handleDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="编制管理" name="quota">
          <div class="search-bar">
            <span class="label">机构名称：</span>
            <el-input v-model="quotaSearchName" placeholder="请输入机构名称" clearable style="width:220px" />
            <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
            <el-button @click="handleReset">重置</el-button>
            <span style="margin-left:16px;color:#999;font-size:12px">
              数据来源：编制 /staffing-quota/list，实有人数、实际配备按 /cadre/page 在职干部实时统计
            </span>
          </div>
          <el-table :data="quotaTableData" border size="small" v-loading="quotaLoading">
            <el-table-column prop="deptName" label="机构" min-width="200" sortable />
            <el-table-column prop="approvedQuotaText" label="核定编制" width="100" sortable />
            <el-table-column prop="actualCountText" label="实有人数" width="100" sortable />
            <el-table-column prop="vacantCountText" label="空编数" width="100" sortable />
            <el-table-column prop="leaderQuotaText" label="领导职数" width="100" sortable />
            <el-table-column prop="actualLeadersText" label="实际配备" width="100" sortable />
            <el-table-column prop="leaderVacancyText" label="空缺" width="100" sortable />
            <el-table-column label="操作" width="80" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openQuotaEdit(row)">编辑</span>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="quotaPage.current"
            v-model:page-size="quotaPage.size"
            :total="quotaPageTotal"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            background
            small
            @current-change="handleQuotaPageChange"
            @size-change="handleQuotaSizeChange"
          />
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="上级机构" prop="parentId">
          <el-tree-select v-model="form.parentId" :data="orgTreeSelect" :props="{ label:'deptName', value:'id', children:'children' }" placeholder="请选择上级机构" check-strictly clearable style="width:100%" />
        </el-form-item>
        <el-form-item label="机构名称" prop="deptName">
          <el-input v-model="form.deptName" placeholder="请输入机构名称" />
        </el-form-item>
        <el-form-item label="简称" prop="shortName">
          <el-input v-model="form.shortName" placeholder="请输入简称" />
        </el-form-item>
        <el-form-item label="级别" prop="deptLevel">
          <el-select v-model="form.deptLevel" placeholder="请选择级别" style="width:100%">
            <el-option label="校级" value="校级" />
            <el-option label="处级" value="处级" />
            <el-option label="科级" value="科级" />
          </el-select>
        </el-form-item>
        <el-form-item label="班子职数" prop="leaderQuota">
          <el-input-number v-model="form.leaderQuota" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="成立时间" prop="establishedDate">
          <el-date-picker v-model="form.establishedDate" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="排序" prop="deptSort">
          <el-input-number v-model="form.deptSort" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="编辑编制" v-model="quotaDialogVisible" width="500px" @close="resetQuotaForm">
      <el-form ref="quotaFormRef" :model="quotaForm" :rules="quotaRules" label-width="100px">
        <el-form-item label="机构名称">
          <el-input :model-value="quotaForm.deptName" disabled />
        </el-form-item>
        <el-form-item label="核定编制" prop="approvedQuota">
          <el-input-number v-model="quotaForm.approvedQuota" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="领导职数" prop="leaderQuota">
          <el-input-number v-model="quotaForm.leaderQuota" :min="0" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="quotaDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="quotaSubmitLoading" @click="handleQuotaSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'

const activeTab = ref('tree')
const loading = ref(false)
const quotaLoading = ref(false)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)

const searchForm = reactive({
  deptName: '',
  deptLevel: ''
})
const quotaSearchName = ref('')

function fmtDate(v) {
  if (v === null || v === undefined || v === '') return '-'
  const s = String(v)
  return s.length >= 10 ? s.slice(0, 10) : s
}
function fmtInt(v) {
  if (v === null || v === undefined || v === '') return '-'
  return v
}

const treeData = ref([])
const quotaList = ref([])

// 在职干部按部门汇总（实有人数 / 实际配备：校级+处级职务层次）
const deptActualCount = ref({})
const deptLeaderCount = ref({})

// ---------------- 机构树 ----------------
async function fetchTree() {
  loading.value = true
  try {
    const res = await request({ url: '/organization/tree', method: 'get' })
    treeData.value = (res.data || []).map(decorateTree)
  } catch (e) {
    treeData.value = []
  } finally {
    loading.value = false
  }
}

function decorateTree(list) {
  return (list || []).map(item => ({
    ...item,
    establishedDateText: fmtDate(item.establishedDate),
    children: item.children && item.children.length ? decorateTree(item.children) : []
  }))
}

const orgTreeSelect = computed(() => {
  const wrap = (list) => (list || []).map(item => ({
    ...item,
    children: item.children && item.children.length ? wrap(item.children) : []
  }))
  return wrap(treeData.value)
})

const filteredTreeData = computed(() => {
  if (!searchForm.deptName && !searchForm.deptLevel) return treeData.value
  const filter = (list) => {
    return (list || []).filter(item => {
      const matchName = !searchForm.deptName || (item.deptName || '').includes(searchForm.deptName)
      const matchLevel = !searchForm.deptLevel || item.deptLevel === searchForm.deptLevel
      const childList = item.children && item.children.length ? filter(item.children) : []
      if (item.children && item.children.length > 0) {
        return matchName || matchLevel || childList.length > 0
      }
      return matchName && matchLevel
    })
  }
  return filter(JSON.parse(JSON.stringify(treeData.value)))
})

// ---------------- 编制 ----------------
async function fetchQuota() {
  quotaLoading.value = true
  try {
    // 编制数据
    let quotaRes = []
    try {
      const q = await request({ url: '/staffing-quota/list', method: 'get' })
      quotaRes = (q.data || []).filter(x => x && x.deptId != null)
    } catch (e) {
      quotaRes = []
    }
    // 在职干部汇总（真实统计）
    try {
      const c = await request({ url: '/cadre/page', method: 'post', params: { current: 1, size: 2000 }, data: { cadreStatus: 'ON_JOB' } })
      const rows = (c.data && c.data.records) || []
      const actual = {}
      const leaders = {}
      rows.forEach(r => {
        const did = r.deptId
        if (did == null) return
        actual[did] = (actual[did] || 0) + 1
        if (r.positionLevel === '校级' || r.positionLevel === '处级') {
          leaders[did] = (leaders[did] || 0) + 1
        }
      })
      deptActualCount.value = actual
      deptLeaderCount.value = leaders
    } catch (e) {
      deptActualCount.value = {}
      deptLeaderCount.value = {}
    }
    // 机构 id -> 名称
    const nameMap = {}
    const walk = (list) => {
      ;(list || []).forEach(n => {
        nameMap[n.id] = n.deptName
        if (n.children && n.children.length) walk(n.children)
      })
    }
    walk(treeData.value)
    quotaList.value = quotaRes.map(q => {
      const actualCount = deptActualCount.value[q.deptId] || 0
      const actualLeaders = deptLeaderCount.value[q.deptId] || 0
      return {
        ...q,
        deptId: q.deptId,
        deptName: nameMap[q.deptId] || '-',
        actualCount,
        actualLeaders,
        vacantCount: Math.max(0, (q.approvedQuota || 0) - actualCount),
        leaderVacancy: Math.max(0, (q.leaderQuota || 0) - actualLeaders),
        approvedQuotaText: fmtInt(q.approvedQuota),
        leaderQuotaText: fmtInt(q.leaderQuota),
        actualCountText: actualCount,
        vacantCountText: Math.max(0, (q.approvedQuota || 0) - actualCount),
        actualLeadersText: actualLeaders,
        leaderVacancyText: Math.max(0, (q.leaderQuota || 0) - actualLeaders)
      }
    }).sort((a, b) => String(a.deptName).localeCompare(String(b.deptName), 'zh-CN'))
  } catch (e) {
    quotaList.value = []
  } finally {
    quotaLoading.value = false
  }
}

const filteredQuota = computed(() => {
  let list = quotaList.value
  if (quotaSearchName.value) list = list.filter(d => (d.deptName || '').includes(quotaSearchName.value))
  return list
})

const quotaPage = reactive({ current: 1, size: 10 })

const quotaTableData = computed(() => {
  const start = (quotaPage.current - 1) * quotaPage.size
  return filteredQuota.value.slice(start, start + quotaPage.size)
})

const quotaPageTotal = computed(() => filteredQuota.value.length)

function handleQuotaPageChange() {
  if (quotaPage.current > Math.ceil(filteredQuota.value.length / quotaPage.size) && filteredQuota.value.length) {
    quotaPage.current = 1
  }
}
function handleQuotaSizeChange() {
  quotaPage.current = 1
}

function handleSearch() {
  quotaPage.current = 1
}
function handleReset() {
  searchForm.deptName = ''
  searchForm.deptLevel = ''
  quotaSearchName.value = ''
  quotaPage.current = 1
}

// ---------------- 机构增删改 ----------------
const form = reactive({
  parentId: null,
  deptName: '',
  shortName: '',
  deptLevel: '',
  leaderQuota: 0,
  establishedDate: '',
  deptSort: 0,
  status: 1
})

const rules = {
  deptName: [{ required: true, message: '请输入机构名称', trigger: 'blur' }],
  deptLevel: [{ required: true, message: '请选择级别', trigger: 'change' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑机构' : '新增机构')

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { id: null, parentId: null, deptName: '', shortName: '', deptLevel: '', leaderQuota: 0, establishedDate: '', deptSort: 0, status: 1 })
}

function openAdd(parent) {
  resetForm()
  if (parent) form.parentId = parent.id
  dialogVisible.value = true
}

function openEdit(row) {
  resetForm()
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    parentId: row.parentId || null,
    deptName: row.deptName,
    shortName: row.shortName || '',
    deptLevel: row.deptLevel,
    leaderQuota: row.leaderQuota || 0,
    establishedDate: row.establishedDate || '',
    deptSort: row.deptSort || 0,
    status: row.status === 0 ? 0 : 1
  })
  dialogVisible.value = true
}

async function handleSubmit() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    submitLoading.value = true
    try {
      const body = {
        parentId: form.parentId || 0,
        deptName: form.deptName,
        shortName: form.shortName || '',
        deptLevel: form.deptLevel,
        leaderQuota: form.leaderQuota || 0,
        establishedDate: form.establishedDate || null,
        deptSort: form.deptSort || 0,
        status: form.status === 0 ? 0 : 1
      }
      if (isEdit.value) {
        await request({ url: '/organization', method: 'put', data: { ...body, id: editId.value } })
        ElMessage.success('更新成功')
      } else {
        await request({ url: '/organization', method: 'post', data: body })
        ElMessage.success('添加成功')
      }
      dialogVisible.value = false
      await fetchTree()
      await fetchQuota()
    } catch (e) {
      // 错误提示已由拦截器统一处理
    } finally {
      submitLoading.value = false
    }
  })
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该机构吗？删除前请确认其下不存在子机构。', '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await request({ url: `/organization/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    await fetchTree()
    await fetchQuota()
  } catch (e) {
    ElMessage.error('删除失败，请检查是否存在下级机构或相关业务数据')
  }
}

// ---------------- 编制编辑 ----------------
const quotaDialogVisible = ref(false)
const quotaSubmitLoading = ref(false)
const quotaFormRef = ref(null)
const quotaEditId = ref(null)

const quotaForm = reactive({
  deptName: '',
  approvedQuota: 0,
  leaderQuota: 0
})

const quotaRules = {
  approvedQuota: [{ required: true, message: '请输入核定编制', trigger: 'blur' }],
  leaderQuota: [{ required: true, message: '请输入领导职数', trigger: 'blur' }]
}

function resetQuotaForm() {
  quotaFormRef.value?.resetFields()
  quotaEditId.value = null
  Object.assign(quotaForm, { deptName: '', approvedQuota: 0, leaderQuota: 0 })
}

function openQuotaEdit(row) {
  quotaEditId.value = row.id
  quotaForm.deptName = row.deptName
  quotaForm.approvedQuota = row.approvedQuota
  quotaForm.leaderQuota = row.leaderQuota
  quotaDialogVisible.value = true
}

async function handleQuotaSubmit() {
  quotaFormRef.value.validate(async (valid) => {
    if (!valid) return
    quotaSubmitLoading.value = true
    try {
      const raw = quotaList.value.find(q => q.id === quotaEditId.value)
      await request({
        url: '/staffing-quota',
        method: 'put',
        data: { id: quotaEditId.value, deptId: raw ? raw.deptId : null, approvedQuota: quotaForm.approvedQuota, leaderQuota: quotaForm.leaderQuota }
      })
      ElMessage.success('编制更新成功')
      quotaDialogVisible.value = false
      await fetchQuota()
    } catch (e) {
      ElMessage.error('编制更新失败')
    } finally {
      quotaSubmitLoading.value = false
    }
  })
}

// ---------------- 导出（基于当前真实展示数据） ----------------
function handleExport() {
  const list = activeTab.value === 'quota' ? filteredQuota.value : flatten(treeData.value)
  if (activeTab.value === 'quota') {
    showExportDialog(list, [
      { prop: 'deptName', label: '机构' },
      { prop: 'approvedQuota', label: '核定编制' },
      { prop: 'actualCount', label: '实有人数' },
      { prop: 'vacantCount', label: '空编数' },
      { prop: 'leaderQuota', label: '领导职数' },
      { prop: 'actualLeaders', label: '实际配备' },
      { prop: 'leaderVacancy', label: '空缺' }
    ], '编制管理')
  } else {
    showExportDialog(list, [
      { prop: 'deptName', label: '机构名称' },
      { prop: 'deptLevel', label: '级别' },
      { prop: 'leaderQuota', label: '班子职数' },
      { prop: 'deptSort', label: '排序' },
      { prop: 'status', label: '状态' }
    ], '组织机构')
  }
}

function flatten(list) {
  const out = []
  ;(list || []).forEach(n => {
    out.push(n)
    if (n.children && n.children.length) out.push(...flatten(n.children))
  })
  return out
}

onMounted(async () => {
  await fetchTree()
  await fetchQuota()
})
</script>
