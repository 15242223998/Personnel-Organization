<template>
  <div>
    <div class="page-header">班子管理</div>

    <el-alert type="info" :closable="false" style="margin-bottom:12px" show-icon
      title="数据说明：本页以真实组织树为骨架展示机构班子。已登记机构展示 org_team_member 班子登记数据（支持新增/编辑/删除）；尚未登记的机构保留“按在职校级/处级干部档案派生预览”作为参考（标注数据来源），并提供“登记班子”入口。" />

    <div class="team-layout">
      <!-- 左：组织树 -->
      <div class="team-tree-panel" v-loading="loading">
        <div class="tree-head">机构列表</div>
        <el-input v-model="treeFilter" placeholder="输入机构名称过滤" clearable size="small" style="margin:8px 10px;width:calc(100% - 20px)" :prefix-icon="Search" @input="onTreeFilter" />
        <el-tree
          ref="treeRef"
          :data="deptTree"
          node-key="id"
          :props="{ label: 'deptName', children: 'children' }"
          :filter-node-method="filterNode"
          highlight-current
          default-expand-all
          :expand-on-click-node="false"
          @node-click="selectDept"
        >
          <template #default="{ data }">
            <div class="tree-node">
              <span class="tree-name">{{ data.deptName }}</span>
              <el-tag v-if="regCount(data.id) > 0" type="success" size="small">班子{{ regCount(data.id) }}</el-tag>
              <el-tag v-else-if="prevCount(data.id) > 0" type="primary" size="small" effect="plain">参考{{ prevCount(data.id) }}</el-tag>
              <el-tag v-else type="info" size="small" effect="plain">空</el-tag>
            </div>
          </template>
        </el-tree>
      </div>

      <!-- 右：当前机构班子详情 -->
      <div class="team-detail-panel" v-loading="loading">
        <template v-if="currentDept">
          <div class="detail-head">
            <div class="detail-title">
              <span class="dept-name">{{ currentDept.deptName }}</span>
              <el-tag v-if="currentDept.deptLevel" size="small" effect="plain" style="margin-left:8px">{{ currentDept.deptLevel }}机构</el-tag>
              <el-tag v-if="currentMembers.length" type="success" size="small" style="margin-left:8px">已登记 {{ currentMembers.length }} 人</el-tag>
              <el-tag v-else type="primary" size="small" effect="plain" style="margin-left:8px">未登记（展示参考）</el-tag>
            </div>
            <div class="detail-actions">
              <el-button type="primary" size="small" @click="openAddDialog"><el-icon><Plus /></el-icon> 登记班子/新增成员</el-button>
              <el-button size="small" @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
            </div>
          </div>

          <!-- 已登记班子成员 -->
          <template v-if="currentMembers.length">
            <div class="source-line">
              <span>数据来源：</span>
              <el-tag type="success" size="small">班子成员登记表（org_team_member）</el-tag>
            </div>
            <el-table :data="currentMembers" border size="small" max-height="520">
              <el-table-column prop="sortOrder" label="排序" width="60" align="center" />
              <el-table-column prop="cadreName" label="姓名" width="90" align="center">
                <template #default="{ row }"><b>{{ row.cadreName || '#' + row.cadreId }}</b></template>
              </el-table-column>
              <el-table-column prop="cadrePosition" label="现任职务" min-width="140" show-overflow-tooltip>
                <template #default="{ row }">{{ row.cadrePosition || '-' }}</template>
              </el-table-column>
              <el-table-column prop="cadreDeptName" label="干部所在机构" min-width="150" show-overflow-tooltip>
                <template #default="{ row }">{{ row.cadreDeptName || (row.deptName || '-') }}</template>
              </el-table-column>
              <el-table-column prop="leaderPost" label="班子职务" min-width="110" align="center">
                <template #default="{ row }">
                  <el-tag :type="row.isLeader === 1 ? 'danger' : ''" size="small">{{ row.leaderPost || '-' }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column label="主要负责人" width="100" align="center">
                <template #default="{ row }">
                  <el-tag :type="row.isLeader === 1 ? 'success' : 'info'" size="small">{{ row.isLeader === 1 ? '是' : '否' }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column label="任职起止" width="180" align="center">
                <template #default="{ row }">
                  {{ fmtDate(row.startDate) }} ~ {{ row.endDate ? fmtDate(row.endDate) : '现任' }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="120" align="center" fixed="right">
                <template #default="{ row }">
                  <span class="link-blue" @click="openEditDialog(row)" style="margin-right:10px">编辑</span>
                  <span class="link-blue" style="color:#f56c6c" @click="handleDelete(row)">删除</span>
                </template>
              </el-table-column>
            </el-table>
          </template>

          <!-- 未登记：派生预览（参考） -->
          <template v-else>
            <div class="source-line">
              <span>数据来源：</span>
              <el-tag type="primary" size="small">干部档案派生预览（/cadre/page，在职 · 职务层次为校级/处级）</el-tag>
              <span style="margin-left:8px;color:#999;font-size:12px">该机构尚未在班子成员登记表中登记，以下为参考数据，不可编辑；请点击右上角“登记班子”录入正式班子。</span>
            </div>
            <template v-if="previewMembers.length">
              <el-table :data="previewMembers" border size="small" max-height="520">
                <el-table-column type="index" label="序号" width="55" align="center" />
                <el-table-column prop="name" label="姓名" width="90" align="center" />
                <el-table-column prop="position" label="现任职务" min-width="160" show-overflow-tooltip>
                  <template #default="{ row }">{{ row.position || '-' }}</template>
                </el-table-column>
                <el-table-column prop="positionLevel" label="职务层次" width="90" align="center" />
                <el-table-column label="主要负责人(参考)" width="140" align="center">
                  <template #default="{ row }">
                    <el-tag :type="isPrincipalCadre(row) ? 'success' : 'info'" size="small">{{ isPrincipalCadre(row) ? '是' : '否' }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="positionStartDateText" label="任现职时间" width="110" align="center">
                  <template #default="{ row }">{{ fmtDate(row.positionStartDate) }}</template>
                </el-table-column>
              </el-table>
            </template>
            <el-empty v-else :image-size="70" description="该机构暂无“校级/处级在职”干部档案可供参考，可直接点击右上角“登记班子”录入成员" />
          </template>
        </template>
        <el-empty v-else :image-size="80" description="请在左侧选择机构" />
      </div>
    </div>

    <!-- 新增/编辑班子成员弹窗 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="620px" destroy-on-close @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="120px">
        <el-form-item label="机构" prop="deptId">
          <el-tree-select
            v-model="form.deptId"
            :data="deptTree"
            :props="{ label: 'deptName', value: 'id', children: 'children' }"
            placeholder="请选择机构（可搜索）"
            check-strictly
            filterable
            style="width:100%"
            @change="onDeptChange"
          />
        </el-form-item>
        <el-form-item label="干部" prop="cadreId">
          <el-select v-model="form.cadreId" placeholder="请选择在职干部（真实档案 /cadre/page）" filterable style="width:100%">
            <el-option v-for="c in onJobCadres" :key="c.id" :label="cadreLabel(c)" :value="c.id" />
          </el-select>
          <div style="font-size:12px;color:#999;line-height:1.5;margin-top:2px">仅展示档案状态为“在职”的干部，选项格式：姓名-部门-现任职务</div>
        </el-form-item>
        <el-form-item label="班子职务" prop="leaderPost">
          <el-select v-model="form.leaderPost" placeholder="请选择班子职务" filterable allow-create style="width:100%">
            <el-option v-for="p in leaderPostOptions" :key="p" :label="p" :value="p" />
          </el-select>
        </el-form-item>
        <el-form-item label="是否主要负责人">
          <el-radio-group v-model="form.isLeader">
            <el-radio :value="1">是（正职）</el-radio>
            <el-radio :value="0">否</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="任职起始">
          <el-date-picker v-model="form.startDate" type="date" value-format="YYYY-MM-DD" placeholder="任职开始日期（可空）" style="width:100%" />
        </el-form-item>
        <el-form-item label="任职结束">
          <el-date-picker v-model="form.endDate" type="date" value-format="YYYY-MM-DD" placeholder="任职结束日期（空=现任）" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'

const loading = ref(false)
const saving = ref(false)
const treeRef = ref(null)
const formRef = ref(null)
const treeFilter = ref('')

const deptTree = ref([])
const allDepts = ref([])          // 扁平机构节点
const teamAll = ref([])           // 已登记班子（/org-team/list 全部）
const onJobCadres = ref([])       // 在职干部（/cadre/page）
const currentDept = ref(null)
const currentDeptId = ref(null)

const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref(null)

const form = reactive({
  deptId: null,
  cadreId: null,
  leaderPost: '',
  isLeader: 0,
  sortOrder: 0,
  startDate: '',
  endDate: ''
})

const formRules = {
  deptId: [{ required: true, message: '请选择机构', trigger: 'change' }],
  cadreId: [{ required: true, message: '请选择干部', trigger: 'change' }],
  leaderPost: [{ required: true, message: '请选择班子职务', trigger: 'change' }]
}

const leaderPostOptions = [
  '党委书记', '校长', '院长', '校长助理', '党委副书记', '纪委书记', '副校长', '副院长',
  '部长', '处长', '副处长', '主任', '副主任', '主席', '副主席', '团委书记', '其他'
]

const dialogTitle = computed(() => (isEdit.value ? '编辑班子成员' : '登记班子（新增成员）'))

function fmtDate(v) {
  if (v === null || v === undefined || v === '') return '-'
  return String(v).slice(0, 10)
}

function cadreLabel(c) {
  return c.name + '-' + (c.deptName || '-') + '-' + (c.position || '无职务')
}

// ---------- 数据加载 ----------
async function loadTree() {
  const res = await request({ url: '/organization/tree', method: 'get' })
  deptTree.value = res.data || []
  allDepts.value = []
  const walk = (list) => {
    ;(list || []).forEach(n => {
      allDepts.value.push(n)
      if (n.children && n.children.length) walk(n.children)
    })
  }
  walk(deptTree.value)
}

async function loadTeams() {
  const res = await request({ url: '/org-team/list', method: 'get' })
  teamAll.value = (res.data || []).slice().sort((a, b) => (a.deptId || 0) - (b.deptId || 0) || (a.sortOrder || 0) - (b.sortOrder || 0))
}

async function loadCadres() {
  // 在职干部一次拉取（分页 size=2000），用于登记选择与派生预览
  const res = await request({
    url: '/cadre/page',
    method: 'post',
    params: { current: 1, size: 2000 },
    data: { cadreStatus: 'ON_JOB' }
  })
  const records = (res.data && res.data.records) || []
  const dmap = {}
  allDepts.value.forEach(d => { dmap[d.id] = d.deptName })
  onJobCadres.value = records.map(c => ({
    ...c,
    deptName: dmap[c.deptId] || '-'
  }))
}

// 主要负责人（派生预览用推断）：职务字段含负责人/领导/书记/正职/主任且非副职
function isPrincipalCadre(c) {
  const pos = c.position || ''
  const hasVice = pos.indexOf('副') >= 0
  return (pos.indexOf('负责人') >= 0 || pos.indexOf('领导') >= 0 || pos.indexOf('书记') >= 0 || pos.indexOf('正职') >= 0 || pos.indexOf('主任') >= 0) && !hasVice
}

// 各机构：已登记成员 / 派生参考成员
function currentMembersOf(deptId) {
  return teamAll.value.filter(t => String(t.deptId) === String(deptId))
}

function previewMembersOf(deptId) {
  return onJobCadres.value.filter(c => {
    if (String(c.deptId) !== String(deptId)) return false
    return c.positionLevel === '校级' || c.positionLevel === '处级'
  }).sort((a, b) => (isPrincipalCadre(a) ? 0 : 1) - (isPrincipalCadre(b) ? 0 : 1))
}

const currentMembers = computed(() => currentDeptId.value == null ? [] : currentMembersOf(currentDeptId.value))
const previewMembers = computed(() => currentDeptId.value == null ? [] : previewMembersOf(currentDeptId.value))

function regCount(deptId) {
  return teamAll.value.filter(t => String(t.deptId) === String(deptId)).length
}

function prevCount(deptId) {
  return onJobCadres.value.filter(c => String(c.deptId) === String(deptId) && (c.positionLevel === '校级' || c.positionLevel === '处级')).length
}

async function selectDept(node) {
  currentDept.value = node
  currentDeptId.value = node.id
}

function filterNode(value, data) {
  if (!value) return true
  return (data.deptName || '').includes(value)
}

function onTreeFilter() {
  treeRef.value?.filter(treeFilter.value)
}

// ---------- 新增/编辑 ----------
function resetForm() {
  formRef.value?.resetFields()
  Object.assign(form, {
    deptId: currentDeptId.value,
    cadreId: null,
    leaderPost: '',
    isLeader: 0,
    sortOrder: 0,
    startDate: '',
    endDate: ''
  })
  isEdit.value = false
  editId.value = null
}

function openAddDialog() {
  resetForm()
  dialogVisible.value = true
}

function openEditDialog(row) {
  resetForm()
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    deptId: row.deptId,
    cadreId: row.cadreId,
    leaderPost: row.leaderPost || '',
    isLeader: row.isLeader === 1 ? 1 : 0,
    sortOrder: row.sortOrder ?? 0,
    startDate: row.startDate || '',
    endDate: row.endDate || ''
  })
  dialogVisible.value = true
}

function onDeptChange() {
  // 切换机构后清空已选干部，避免串机构
  form.cadreId = null
}

async function handleSubmit() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    saving.value = true
    const payload = {
      deptId: form.deptId,
      cadreId: form.cadreId,
      leaderPost: form.leaderPost,
      isLeader: form.isLeader === 1 ? 1 : 0,
      sortOrder: form.sortOrder ?? 0,
      startDate: form.startDate || null,
      endDate: form.endDate || null
    }
    try {
      if (isEdit.value) {
        await request({ url: '/org-team', method: 'put', data: { ...payload, id: editId.value } })
        ElMessage.success('班子记录已更新')
      } else {
        await request({ url: '/org-team', method: 'post', data: payload })
        ElMessage.success('班子登记成功')
      }
      dialogVisible.value = false
      await refresh()
    } catch (e) {
      // 拦截器已提示业务错误（如机构/干部不存在、同一机构干部重复登记）
    } finally {
      saving.value = false
    }
  })
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm(`确定删除 ${row.cadreName || ('#' + row.cadreId)} 的“${row.leaderPost || '班子'}”登记吗？`, '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await request({ url: `/org-team/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    await refresh()
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

async function refresh() {
  await loadTeams()
}

async function init() {
  loading.value = true
  try {
    await loadTree()
    await Promise.all([loadTeams(), loadCadres()])
    // 默认选中根节点
    if (allDepts.value.length) {
      const root = deptTree.value[0]
      currentDept.value = root
      currentDeptId.value = root.id
      await nextTick()
      treeRef.value?.setCurrentKey(root.id)
    }
  } catch (e) {
    teamAll.value = []
    onJobCadres.value = []
  } finally {
    loading.value = false
  }
}

function handleExport() {
  if (!currentMembers.value.length) {
    ElMessage.warning('当前机构尚无已登记班子数据，登记后才能导出')
    return
  }
  showExportDialog(currentMembers.value.map(m => ({
    deptName: currentDept.value.deptName,
    cadreName: m.cadreName,
    cadrePosition: m.cadrePosition || '-',
    cadreDeptName: m.cadreDeptName || '-',
    leaderPost: m.leaderPost || '-',
    isLeaderText: m.isLeader === 1 ? '是' : '否',
    startDate: fmtDate(m.startDate),
    endDate: m.endDate ? fmtDate(m.endDate) : '现任',
    sortOrder: m.sortOrder ?? 0
  })), [
    { prop: 'deptName', label: '机构名称' },
    { prop: 'cadreName', label: '姓名' },
    { prop: 'cadrePosition', label: '现任职务' },
    { prop: 'cadreDeptName', label: '干部所在机构' },
    { prop: 'leaderPost', label: '班子职务' },
    { prop: 'isLeaderText', label: '主要负责人' },
    { prop: 'startDate', label: '任职开始' },
    { prop: 'endDate', label: '任职结束' },
    { prop: 'sortOrder', label: '排序' }
  ], '班子管理')
}

init()
</script>

<style scoped>
.team-layout {
  display: flex;
  gap: 12px;
  align-items: stretch;
}
.team-tree-panel {
  width: 340px;
  flex: 0 0 340px;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 2px;
  max-height: calc(100vh - 220px);
  overflow: auto;
  padding-bottom: 8px;
}
.tree-head {
  padding: 10px 12px;
  font-size: 14px;
  font-weight: bold;
  color: #1976D2;
  border-bottom: 2px solid #1976D2;
  background: #fafbfc;
}
.tree-node {
  display: flex;
  align-items: center;
  gap: 6px;
  padding-right: 6px;
}
.tree-name {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.team-detail-panel {
  flex: 1;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 2px;
  padding: 12px 14px;
  min-height: 480px;
  max-height: calc(100vh - 220px);
  overflow: auto;
}
.detail-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.detail-title {
  display: flex;
  align-items: center;
}
.dept-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}
.source-line {
  display: flex;
  align-items: center;
  font-size: 13px;
  color: #555;
  background: #f7fafd;
  border: 1px solid #e3ecf5;
  border-radius: 2px;
  padding: 6px 10px;
  margin-bottom: 10px;
}
.link-blue {
  color: #1976D2;
  cursor: pointer;
}
</style>
