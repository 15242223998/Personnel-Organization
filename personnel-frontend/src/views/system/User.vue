<template>
  <div>
    <div class="page-header">用户管理</div>

    <div class="search-bar">
      <span class="label">用户名：</span>
      <el-input v-model="searchForm.username" placeholder="请输入用户名" size="default" style="width:140px" clearable />
      <span class="label">用户类型：</span>
      <el-select v-model="searchForm.type" placeholder="请选择" size="default" style="width:130px" clearable>
        <el-option v-for="r in roleOptions" :key="r.value" :label="r.label" :value="r.value" />
      </el-select>
      <span class="label">状态：</span>
      <el-select v-model="searchForm.status" placeholder="请选择" size="default" style="width:110px" clearable>
        <el-option v-for="s in statusOptions" :key="s.value" :label="s.label" :value="s.value" />
      </el-select>
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd"><el-icon><Plus /></el-icon> 新增用户</el-button>
      <el-button @click="handleExportUsers"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="pagedData" border size="small" v-loading="loading">
        <el-table-column label="序号" width="55" align="center">
          <template #default="{ $index }">{{ (page.current - 1) * page.size + $index + 1 }}</template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" width="110" align="center" sortable />
        <el-table-column prop="realName" label="姓名" width="90" align="center" sortable />
        <el-table-column prop="email" label="邮箱" min-width="170" show-overflow-tooltip sortable />
        <el-table-column prop="phone" label="手机" width="120" align="center" sortable />
        <el-table-column prop="userType" label="用户类型" width="110" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="roleTagType(row.userType)" size="small">{{ userTypeText(row.userType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="绑定干部档案" min-width="130" align="center">
          <template #default="{ row }">
            <span v-if="row.cadreId" style="color:#1976D2">{{ cadreName(row.cadreId) }}</span>
            <span v-else style="color:#999">未绑定</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : row.status === 0 ? 'warning' : 'info'" size="small">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastLoginTime" label="最后登录" width="150" align="center" sortable>
          <template #default="{ row }">{{ (row.lastLoginTime || '').replace('T', ' ').slice(0, 19) || '-' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="250" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openBind(row)">{{ row.cadreId ? '换绑档案' : '绑定档案' }}</span>
            <span class="link-blue" v-if="row.cadreId" style="margin-left:10px" @click="handleUnbind(row)">解绑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="openEdit(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="handleResetPwd(row)">重置密码</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div style="display:flex;justify-content:flex-end;margin-top:12px">
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        size="small"
      />
    </div>

    <el-dialog :title="isEdit ? '编辑用户' : '新增用户'" v-model="dialogVisible" width="560px" destroy-on-close>
      <el-form :model="form" label-width="90px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="用户名" required>
              <el-input v-model="form.username" placeholder="请输入用户名" :disabled="isEdit" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" required>
              <el-input v-model="form.realName" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="邮箱">
              <el-input v-model="form.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号">
              <el-input v-model="form.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="用户类型" required>
              <el-select v-model="form.userType" placeholder="请选择" style="width:100%">
                <el-option v-for="r in roleOptions" :key="r.value" :label="r.label" :value="r.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item v-if="!isEdit" label="初始密码">
              <el-input v-model="form.password" type="password" placeholder="默认123456" show-password />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="3">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="绑定干部档案" v-model="bindDialog" width="480px" destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="用户">
          {{ bindForm.realName }}（{{ bindForm.username }}）
        </el-form-item>
        <el-form-item label="干部档案" required>
          <el-select v-model="bindForm.cadreId" filterable style="width:100%" placeholder="请选择干部档案">
            <el-option v-for="c in cadreOptions" :key="c.id"
              :label="c.name + (c.position ? `（${c.position}）` : '') + (boundCadreIds.has(c.id) ? ' - 已绑定' : '')"
              :value="c.id" :disabled="boundCadreIds.has(c.id) && c.id !== bindForm.originCadreId" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="bindDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleBindSubmit">确定绑定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'
import { getCadrePage } from '@/api/cadre'
import { bindUserCadre, unbindUserCadre } from '@/api/daily'

const loading = ref(false)
const saving = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const bindDialog = ref(false)

const roleOptions = [
  { label: '系统管理员', value: 1 },
  { label: '校级领导', value: 2 },
  { label: '组织部部长', value: 3 },
  { label: '组织员', value: 4 },
  { label: '二级学院领导', value: 5 },
  { label: '普通干部', value: 6 }
]

const statusOptions = [
  { label: '待审核', value: 0 },
  { label: '正常', value: 1 },
  { label: '已拒绝', value: 2 },
  { label: '停用', value: 3 }
]

const searchForm = reactive({ username: '', type: '', status: '' })
const allUserData = ref([])
const cadreOptions = ref([])

const form = reactive({
  id: null, username: '', realName: '', email: '', phone: '', userType: null, password: '', status: 1
})

const page = reactive({ current: 1, size: 10, total: 0 })

const filteredData = computed(() => {
  let list = allUserData.value
  const s = searchForm
  if (s.username) list = list.filter(u => (u.username || '').includes(s.username))
  if (s.type !== '' && s.type !== null) list = list.filter(u => u.userType === s.type)
  if (s.status !== '' && s.status !== null) list = list.filter(u => u.status === s.status)
  return list
})

const pagedData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

const boundCadreIds = computed(() =>
  new Set(allUserData.value.filter(u => u.cadreId).map(u => u.cadreId)))

const bindForm = reactive({ id: null, username: '', realName: '', cadreId: null, originCadreId: null })

watch(filteredData, (v) => {
  page.total = v.length
  if (page.current > 1 && (page.current - 1) * page.size >= v.length) {
    page.current = Math.max(1, Math.ceil(v.length / page.size))
  }
}, { immediate: true })

watch(() => page.size, () => { page.current = 1 })

async function loadUsers() {
  loading.value = true
  try {
    const res = await request({ url: '/user/page', method: 'get', params: { current: 1, size: 500 } })
    allUserData.value = res.data.records || []
  } finally { loading.value = false }
}

async function loadCadres() {
  try {
    const res = await getCadrePage({ current: 1, size: 500 })
    cadreOptions.value = res.data.records || []
  } catch { cadreOptions.value = [] }
}

function userTypeText(t) {
  return roleOptions.find(r => r.value === t)?.label || `类型${t}`
}

function statusText(s) {
  return statusOptions.find(o => o.value === s)?.label || String(s)
}

function cadreName(id) {
  return cadreOptions.value.find(c => c.id === id)?.name || `#${id}`
}

function roleTagType(type) {
  const map = { 1: 'danger', 2: 'warning', 3: '', 4: 'success', 5: '', 6: 'info' }
  return map[type] || ''
}

function resetSearch() {
  Object.assign(searchForm, { username: '', type: '', status: '' })
  page.current = 1
}

function handleSearch() {
  page.current = 1
}

function openAdd() {
  isEdit.value = false
  Object.assign(form, { id: null, username: '', realName: '', email: '', phone: '', userType: null, password: '', status: 1 })
  dialogVisible.value = true
}

function openEdit(row) {
  isEdit.value = true
  Object.assign(form, {
    id: row.id, username: row.username, realName: row.realName, email: row.email,
    phone: row.phone, userType: row.userType, password: '', status: row.status
  })
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.username) return ElMessage.warning('请输入用户名')
  if (!form.realName) return ElMessage.warning('请输入姓名')
  if (!form.userType) return ElMessage.warning('请选择用户类型')
  saving.value = true
  try {
    if (isEdit.value) {
      await request({ url: '/user', method: 'put', data: { ...form, password: undefined } })
      ElMessage.success('用户已更新')
    } else {
      await request({ url: '/user', method: 'post', data: { ...form, password: form.password || '123456', status: 1 } })
      ElMessage.success('用户创建成功')
    }
    dialogVisible.value = false
    loadUsers()
  } finally { saving.value = false }
}

async function handleResetPwd(row) {
  ElMessageBox.confirm(`确定重置用户「${row.realName || row.username}」的密码吗？重置后密码为默认密码123456。`, '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/user/${row.id}/reset-password`, method: 'put' })
    ElMessage.success('密码已重置为123456')
  }).catch(() => {})
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定删除用户「${row.realName || row.username}」吗？`, '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/user/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    loadUsers()
  }).catch(() => {})
}

function openBind(row) {
  Object.assign(bindForm, {
    id: row.id, username: row.username, realName: row.realName || row.username,
    cadreId: row.cadreId, originCadreId: row.cadreId
  })
  bindDialog.value = true
}

async function handleBindSubmit() {
  if (!bindForm.cadreId) return ElMessage.warning('请选择干部档案')
  saving.value = true
  try {
    await bindUserCadre(bindForm.id, bindForm.cadreId)
    ElMessage.success('绑定成功，该用户可进行干部自助申报')
    bindDialog.value = false
    loadUsers()
  } finally { saving.value = false }
}

function handleUnbind(row) {
  ElMessageBox.confirm(`确定解除「${row.realName || row.username}」的干部档案绑定吗？`, '提示', { type: 'warning' }).then(async () => {
    await unbindUserCadre(row.id)
    ElMessage.success('已解绑')
    loadUsers()
  }).catch(() => {})
}

function handleExportUsers() {
  showExportDialog(filteredData.value.map(u => ({ ...u, typeName: userTypeText(u.userType), statusName: statusText(u.status), cadreNameText: u.cadreId ? cadreName(u.cadreId) : '未绑定' })), [
    { prop: 'username', label: '用户名' },
    { prop: 'realName', label: '姓名' },
    { prop: 'email', label: '邮箱' },
    { prop: 'phone', label: '手机' },
    { prop: 'typeName', label: '用户类型' },
    { prop: 'cadreNameText', label: '绑定干部档案' },
    { prop: 'statusName', label: '状态' },
    { prop: 'lastLoginTime', label: '最后登录' }
  ], '用户列表')
}

onMounted(() => {
  loadUsers()
  loadCadres()
})
</script>
