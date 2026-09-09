<template>
  <div>
    <div class="page-header">干部考察登记</div>

    <div class="search-bar">
      <span class="label">姓名：</span>
      <el-input v-model="search.name" placeholder="请输入干部姓名" size="default" style="width:160px" clearable />
      <span class="label">考察类型：</span>
      <el-select v-model="search.investigationType" placeholder="请选择" size="default" style="width:150px" clearable>
        <el-option v-for="t in typeOptions" :key="t" :label="t" :value="t" />
      </el-select>
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="resetSearch">重置</el-button>
      <span style="margin-left:12px;font-size:12px;color:#999">数据来源：干部考察登记（/api/investigation）</span>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openDialog(null)"><el-icon><Plus /></el-icon> 新增考察登记</el-button>
      <el-button @click="exportList"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table v-loading="loading" :data="pagedList" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column label="姓名" width="90" align="center" sortable>
          <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
        </el-table-column>
        <el-table-column label="所属部门" min-width="130" show-overflow-tooltip sortable>
          <template #default="{ row }">{{ cadreDeptName(row.cadreId) }}</template>
        </el-table-column>
        <el-table-column label="职务层次" width="80" align="center" sortable>
          <template #default="{ row }">{{ cadreLevel(row.cadreId) }}</template>
        </el-table-column>
        <el-table-column prop="investigationType" label="考察类型" width="110" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="typeTag(row.investigationType)" size="small">{{ row.investigationType || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="考察时间" width="110" align="center">
          <template #default="{ row }">{{ row.investigationTime || '-' }}</template>
        </el-table-column>
        <el-table-column prop="investigator" label="考察组成员" min-width="110" show-overflow-tooltip />
        <el-table-column label="结论" width="90" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.result" :type="resultTag(row.result)" size="small">{{ row.result }}</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="orgUnit" label="组织单位" min-width="100" show-overflow-tooltip />
        <el-table-column prop="content" label="考察材料摘要" min-width="180" show-overflow-tooltip />
        <el-table-column label="操作" width="170" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openView(row)">查看</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="openDialog(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.current"
          v-model:page-size="page.size"
          :page-sizes="[10, 20, 50]"
          :total="page.total"
          layout="total, sizes, prev, pager, next, jumper"
          background small
          @size-change="page.current = 1"
        />
      </div>
    </div>

    <!-- ============ 查看弹窗 ============ -->
    <el-dialog v-model="view.visible" title="考察登记详情" width="680px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.row">
        <el-descriptions-item label="姓名">{{ cadreName(view.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="所属部门">{{ cadreDeptName(view.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="职务层次">{{ cadreLevel(view.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="考察类型">{{ view.row.investigationType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="考察时间">{{ view.row.investigationTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="考察结论">{{ view.row.result || '-' }}</el-descriptions-item>
        <el-descriptions-item label="组织单位">{{ view.row.orgUnit || '-' }}</el-descriptions-item>
        <el-descriptions-item label="考察组成员">{{ view.row.investigator || '-' }}</el-descriptions-item>
        <el-descriptions-item label="考察材料" :span="2">
          <div class="doc-content">{{ view.row.content || '-' }}</div>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 新增/编辑弹窗 ============ -->
    <el-dialog v-model="dialog.visible" :title="dialog.id ? '编辑考察登记' : '新增考察登记'" width="640px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="考察对象" required>
          <el-select v-model="dialog.form.cadreId" filterable placeholder="请输入姓名搜索在职干部" style="width:100%" @change="onCadreChange">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + '（' + (c.deptName || '-') + '）'" :value="c.id" />
          </el-select>
          <div v-if="selectedCadre" class="cadre-echo">
            部门：{{ selectedCadre.deptName || '-' }} ｜ 职务层次：{{ selectedCadre.positionLevel || '-' }} ｜ 现任职务：{{ selectedCadre.position || '-' }}
          </div>
        </el-form-item>
        <el-form-item label="考察类型" required>
          <el-select v-model="dialog.form.investigationType" style="width:100%">
            <el-option v-for="t in typeOptions" :key="t" :label="t" :value="t" />
          </el-select>
        </el-form-item>
        <el-form-item label="考察时间">
          <el-date-picker v-model="dialog.form.investigationTime" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="考察组成员">
          <el-input v-model="dialog.form.investigator" placeholder="如：考察组（3人）" />
        </el-form-item>
        <el-form-item label="组织单位">
          <el-input v-model="dialog.form.orgUnit" placeholder="如：党委组织部" />
        </el-form-item>
        <el-form-item label="考察结论">
          <el-select v-model="dialog.form.result" clearable style="width:100%">
            <el-option v-for="r in resultOptions" :key="r" :label="r" :value="r" />
          </el-select>
        </el-form-item>
        <el-form-item label="考察材料">
          <el-input v-model="dialog.form.content" type="textarea" :rows="5" placeholder="请输入考察材料内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'

const typeOptions = ['任前考察', '年度考核考察', '专项考察', '换届考察']
const resultOptions = ['优秀', '称职', '基本称职', '其他']

function typeTag(t) {
  if (t === '任前考察') return 'warning'
  if (t === '年度考核考察') return 'success'
  if (t === '换届考察') return 'danger'
  return 'primary'
}
function resultTag(r) {
  if (r === '优秀') return 'success'
  if (r === '称职') return 'primary'
  if (r === '基本称职') return 'warning'
  return 'info'
}

// ---------- 干部 / 部门字典 ----------
const cadreOptions = ref([])
const cadreFullMap = ref({})
const deptNameMap = ref({})
function cadreName(id) {
  if (id == null) return '-'
  const c = cadreFullMap.value[id]
  return c ? c.name : ('#' + id)
}
function cadreDeptName(id) {
  if (id == null) return '-'
  const c = cadreFullMap.value[id]
  return c ? (deptNameMap.value[c.deptId] || '-') : '-'
}
function cadreLevel(id) {
  if (id == null) return '-'
  const c = cadreFullMap.value[id]
  return c ? (c.positionLevel || '-') : '-'
}

async function loadDicts() {
  try {
    const [orgRes, cadreRes] = await Promise.all([
      request({ url: '/organization/tree', method: 'get' }),
      request({ url: '/cadre/page', method: 'post', params: { current: 1, size: 2000 }, data: {} })
    ])
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
    const full = {}
    cadres.forEach(c => { full[c.id] = c })
    cadreFullMap.value = full
    cadreOptions.value = cadres.filter(c => c.cadreStatus === 'ON_JOB')
      .map(c => ({ id: c.id, name: c.name, deptId: c.deptId, deptName: dmap[c.deptId] || '-', positionLevel: c.positionLevel || '', position: c.position || '' }))
  } catch (e) {
    cadreOptions.value = []
    cadreFullMap.value = {}
  }
}

// ---------- 列表 ----------
const loading = ref(false)
const saving = ref(false)
const allList = ref([])
const search = reactive({ name: '', investigationType: '' })
const page = reactive({ current: 1, size: 10, total: 0 })

const filteredList = computed(() => allList.value.filter(d =>
  (!search.name || cadreName(d.cadreId).includes(search.name)) &&
  (!search.investigationType || d.investigationType === search.investigationType)))

const pagedList = computed(() => {
  const p = page
  const start = (p.current - 1) * p.size
  return filteredList.value.slice(start, start + p.size)
})

watch([filteredList, page], () => { page.total = filteredList.value.length })

function handleSearch() { page.current = 1 }
function resetSearch() { Object.assign(search, { name: '', investigationType: '' }); page.current = 1 }

async function loadList() {
  loading.value = true
  try {
    const res = await request({ url: '/investigation/page', method: 'get', params: { current: 1, size: 500 } })
    allList.value = (res.data && res.data.records) || []
  } catch (e) { allList.value = [] } finally { loading.value = false }
}

// ---------- 新增/编辑 ----------
const dialog = reactive({ visible: false, id: null, form: {} })
const selectedCadre = computed(() => {
  if (!dialog.form.cadreId) return null
  return cadreOptions.value.find(c => c.id === dialog.form.cadreId) || null
})
const emptyForm = () => ({ cadreId: null, investigationType: '', investigationTime: null, investigator: '', orgUnit: '', result: '', content: '' })

function openDialog(row) {
  dialog.id = row ? row.id : null
  dialog.form = row
    ? {
        cadreId: row.cadreId,
        investigationType: row.investigationType || '',
        investigationTime: row.investigationTime || null,
        investigator: row.investigator || '',
        orgUnit: row.orgUnit || '',
        result: row.result || '',
        content: row.content || ''
      }
    : emptyForm()
  dialog.visible = true
}
function onCadreChange() {}

async function submit() {
  const f = dialog.form
  if (!f.cadreId) return ElMessage.warning('请选择考察对象')
  if (!f.investigationType) return ElMessage.warning('请选择考察类型')
  saving.value = true
  try {
    const payload = {
      cadreId: f.cadreId,
      investigationType: f.investigationType,
      investigationTime: f.investigationTime || null,
      investigator: f.investigator || null,
      orgUnit: f.orgUnit || null,
      result: f.result || null,
      content: f.content || null
    }
    if (dialog.id) {
      await request({ url: '/investigation', method: 'put', data: { id: dialog.id, ...payload } })
      ElMessage.success('更新成功')
    } else {
      await request({ url: '/investigation', method: 'post', data: payload })
      ElMessage.success('新增成功')
    }
    dialog.visible = false
    loadList()
  } finally { saving.value = false }
}

function handleDelete(row) {
  ElMessageBox.confirm('确定删除该条考察登记记录吗？删除后不可恢复。', '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/investigation/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    loadList()
  }).catch(() => {})
}

// ---------- 查看 ----------
const view = reactive({ visible: false, row: null })
function openView(row) {
  view.row = row
  view.visible = true
}

// ---------- 导出 ----------
function exportList() {
  showExportDialog(filteredList.value.map(d => ({
    name: cadreName(d.cadreId), deptName: cadreDeptName(d.cadreId), positionLevel: cadreLevel(d.cadreId),
    investigationType: d.investigationType, investigationTime: d.investigationTime || '-',
    investigator: d.investigator || '-', result: d.result || '-', orgUnit: d.orgUnit || '-'
  })), [
    { prop: 'name', label: '姓名' }, { prop: 'deptName', label: '所属部门' }, { prop: 'positionLevel', label: '职务层次' },
    { prop: 'investigationType', label: '考察类型' }, { prop: 'investigationTime', label: '考察时间' },
    { prop: 'investigator', label: '考察组成员' }, { prop: 'result', label: '结论' }, { prop: 'orgUnit', label: '组织单位' }
  ], '干部考察登记')
}

loadDicts()
loadList()
</script>

<style scoped>
.pagination-wrap {
  padding: 10px 14px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: flex-end;
}
.cadre-echo {
  margin-top: 6px;
  width: 100%;
  padding: 6px 10px;
  background: #f5f7fa;
  border: 1px solid #e8e8e8;
  border-radius: 2px;
  font-size: 12px;
  color: #666;
  line-height: 1.6;
}
.doc-content {
  max-height: 40vh;
  overflow: auto;
  background: #fafbfc;
  border: 1px solid #e8e8e8;
  border-radius: 2px;
  padding: 10px 12px;
  font-size: 13px;
  line-height: 1.9;
  white-space: pre-wrap;
  word-break: break-all;
  color: #333;
}
</style>
