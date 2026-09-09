<template>
  <!-- 已废弃：角色管理的菜单入口与路由已移除（权限模型收敛为“用户类型内置模板 + 用户级覆盖”，不再读取 sys_role/sys_user_role），本页面不再可达，保留仅供历史回溯参考。 -->
  <div>
    <div class="page-header">角色管理</div>

    <div class="search-bar">
      <span class="label">角色名称：</span>
      <el-input v-model="searchForm.name" placeholder="请输入角色名称" clearable style="width:180px" />
      <span class="label">状态：</span>
      <el-select v-model="searchForm.status" placeholder="请选择" clearable style="width:120px">
        <el-option label="启用" :value="1" />
        <el-option label="停用" :value="0" />
      </el-select>
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="resetSearch">重置</el-button>
      <el-button type="primary" plain :loading="loading" @click="loadRoles"><el-icon><Refresh /></el-icon> 刷新</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openDialog(null)"><el-icon><Plus /></el-icon> 新增角色</el-button>
      <span style="font-size:12px;color:#999">数据来源：系统角色（/api/role/list）。勾选模块即可授权角色访问对应菜单，未单独授权用户登录时自动回退其角色权限。</span>
    </div>

    <div class="table-wrap">
      <el-table v-loading="loading" :data="pagedData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="roleName" label="角色名称" min-width="150" show-overflow-tooltip sortable />
        <el-table-column prop="roleCode" label="角色编码" min-width="130" show-overflow-tooltip sortable />
        <el-table-column label="数据范围" width="110" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="dataScopeTagType(row.dataScope)" size="small">{{ dataScopeText(row.dataScope) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="模块权限" min-width="120" align="center">
          <template #default="{ row }">
            <el-tag v-if="String(row.permissions || '').trim() === 'ALL'" type="danger" size="small">ALL 全部模块</el-tag>
            <el-tag v-else :type="permModuleCount(row) > 0 ? 'success' : 'info'" size="small">
              {{ permModuleCount(row) }}/{{ permOptions.length || 10 }} 模块
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" width="160" align="center" sortable>
          <template #default="{ row }">{{ fmtTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openDialog(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="openPermDialog(row)">授权</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div class="pagination-wrap">
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50]"
        :total="page.total"
        layout="total,sizes,prev,pager,next,jumper"
        background small
        @size-change="page.current = 1"
      />
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="dialog.id ? '编辑角色' : '新增角色'" v-model="dialog.visible" width="520px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="角色名称" required>
          <el-input v-model="dialog.form.roleName" placeholder="请输入角色名称" maxlength="64" />
        </el-form-item>
        <el-form-item label="角色编码" required>
          <el-input v-model="dialog.form.roleCode" placeholder="如：org_leader（唯一）" maxlength="64" />
        </el-form-item>
        <el-form-item label="数据范围">
          <el-select v-model="dialog.form.dataScope" style="width:100%">
            <el-option label="全部" :value="1" />
            <el-option label="自定义" :value="2" />
            <el-option label="本级及下级" :value="3" />
            <el-option label="本级" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="dialog.form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>

    <!-- 角色模块/按钮权限授权弹窗 -->
    <el-dialog title="角色权限授权" v-model="permDialog.visible" width="680px" align-center destroy-on-close>
      <div class="perm-tip">
        角色「{{ permDialog.roleName }}」：勾选模块即授权该模块访问；勾选模块后可再展开勾选按钮级权限（以
        <code>模块key:按钮key</code> 形式保存到同一 permissions 串）。未单独授权的用户登录时自动按所绑定角色生效。
      </div>
      <div v-loading="permLoading" class="perm-list">
        <div v-for="m in permOptions" :key="m.key" class="perm-item">
          <div class="perm-item-head">
            <el-checkbox :model-value="checkedModules.includes(m.key)" @change="v => toggleModule(m, v)">
              {{ m.label }}
            </el-checkbox>
            <el-tag v-if="checkedModules.includes(m.key) && (actionMap[m.key] || []).length" size="small" type="success" class="perm-sub-tag">
              {{ (actionMap[m.key] || []).length }} 项按钮
            </el-tag>
            <span class="perm-mod-key">{{ m.key }}</span>
          </div>
          <div v-if="checkedModules.includes(m.key)" class="perm-actions">
            <el-checkbox-group :model-value="actionMap[m.key] || []" @update:model-value="val => (actionMap[m.key] = val)">
              <el-checkbox v-for="a in BUTTON_PERMS" :key="a.key" :value="`${m.key}:${a.key}`" size="small">
                {{ a.label }}
              </el-checkbox>
            </el-checkbox-group>
          </div>
        </div>
        <el-empty v-if="!permLoading && !permOptions.length" description="暂无可授权模块" :image-size="60" />
      </div>
      <template #footer>
        <el-button size="small" @click="selectAllModules">全选模块</el-button>
        <el-button size="small" @click="clearAllModules">清空</el-button>
        <el-button @click="permDialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="savingPerm" @click="savePerm">保存授权</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { Search, Plus, Refresh } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

// 按钮级权限（与模块 key 组合为 模块key:按钮key，如 organization:add）
const BUTTON_PERMS = [
  { key: 'view', label: '查看' },
  { key: 'add', label: '新增' },
  { key: 'edit', label: '编辑' },
  { key: 'delete', label: '删除' },
  { key: 'export', label: '导出' },
  { key: 'approve', label: '审批' }
]

const loading = ref(false)
const saving = ref(false)
const savingPerm = ref(false)
const allData = ref([])
const searchForm = reactive({ name: '', status: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const dialog = reactive({ visible: false, id: null, form: { roleName: '', roleCode: '', dataScope: 4, status: 1 } })

// ====== 角色权限授权 ======
const permOptions = ref([])
const permLoading = ref(false)
const permDialog = reactive({ visible: false, id: null, roleName: '' })
const checkedModules = ref([])
const actionMap = reactive({})

function parsePerms(val) {
  if (!val) return []
  return String(val).split(',').map(s => s.trim()).filter(Boolean)
}

async function loadPermOptions() {
  if (permOptions.value.length) return
  permLoading.value = true
  try {
    const res = await request({ url: '/role/permission-options', method: 'get' })
    permOptions.value = res.data || []
    permOptions.value.forEach(m => { if (!actionMap[m.key]) actionMap[m.key] = [] })
  } catch { permOptions.value = [] } finally { permLoading.value = false }
}

// 角色已勾选模块数（按钮级如 organization:add 不计数）
function permModuleCount(row) {
  const keys = new Set(parsePerms(row.permissions))
  return permOptions.value.filter(m => keys.has(m.key)).length
}

async function openPermDialog(row) {
  await loadPermOptions()
  permDialog.visible = true
  permDialog.id = row.id
  permDialog.roleName = row.roleName
  const keys = new Set(parsePerms(row.permissions))
  checkedModules.value = permOptions.value.filter(m => keys.has(m.key)).map(m => m.key)
  permOptions.value.forEach(m => { actionMap[m.key] = [] })
  permOptions.value.forEach(m => {
    if (keys.has(m.key)) {
      actionMap[m.key] = [...keys].filter(k => k.startsWith(m.key + ':'))
    }
  })
}

function toggleModule(m, checked) {
  if (checked) {
    if (!checkedModules.value.includes(m.key)) checkedModules.value.push(m.key)
    if (!actionMap[m.key]) actionMap[m.key] = []
  } else {
    checkedModules.value = checkedModules.value.filter(k => k !== m.key)
    actionMap[m.key] = []
  }
}

function selectAllModules() {
  checkedModules.value = permOptions.value.map(m => m.key)
  permOptions.value.forEach(m => { if (!actionMap[m.key]) actionMap[m.key] = [] })
}

function clearAllModules() {
  checkedModules.value = []
  permOptions.value.forEach(m => { actionMap[m.key] = [] })
}

async function savePerm() {
  const list = [...checkedModules.value]
  checkedModules.value.forEach(m => {
    ;(actionMap[m.key] || []).forEach(k => {
      if (k && !list.includes(k)) list.push(k)
    })
  })
  savingPerm.value = true
  try {
    await request({ url: `/role/${permDialog.id}/permissions`, method: 'put', data: list })
    ElMessage.success('角色权限已保存')
    permDialog.visible = false
    loadRoles()
  } catch { /* 业务错误已由拦截器提示 */ } finally { savingPerm.value = false }
}

function fmtTime(t) {
  if (!t) return '-'
  return String(t).replace('T', ' ').slice(0, 19)
}
function dataScopeText(s) {
  return { 1: '全部', 2: '自定义', 3: '本级及下级', 4: '本级' }[s] || `范围${s}`
}
function dataScopeTagType(s) {
  const map = { 1: 'danger', 2: 'warning', 3: '', 4: 'info' }
  return map[s] || ''
}

const filteredData = computed(() => {
  let list = allData.value
  if (searchForm.name) list = list.filter(d => (d.roleName || '').includes(searchForm.name) || (d.roleCode || '').includes(searchForm.name))
  if (searchForm.status !== '' && searchForm.status !== null) list = list.filter(d => d.status === searchForm.status)
  return list
})

const pagedData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

function syncTotal() { page.total = filteredData.value.length }

async function loadRoles() {
  loading.value = true
  try {
    const res = await request({ url: '/role/list', method: 'get' })
    allData.value = res.data || []
    syncTotal()
  } catch (e) { allData.value = [] } finally { loading.value = false }
}

function handleSearch() { page.current = 1; syncTotal() }
function resetSearch() {
  searchForm.name = ''
  searchForm.status = ''
  page.current = 1
  syncTotal()
}

function openDialog(row) {
  dialog.id = row ? row.id : null
  dialog.form = row
    ? { roleName: row.roleName || '', roleCode: row.roleCode || '', dataScope: row.dataScope ?? 4, status: row.status ?? 1 }
    : { roleName: '', roleCode: '', dataScope: 4, status: 1 }
  dialog.visible = true
}

async function handleSubmit() {
  const f = dialog.form
  if (!f.roleName.trim()) return ElMessage.warning('请输入角色名称')
  if (!f.roleCode.trim()) return ElMessage.warning('请输入角色编码')
  saving.value = true
  try {
    if (dialog.id) {
      await request({ url: '/role', method: 'put', data: { id: dialog.id, ...f } })
      ElMessage.success('角色已更新')
    } else {
      await request({ url: '/role', method: 'post', data: { ...f } })
      ElMessage.success('角色创建成功')
    }
    dialog.visible = false
    loadRoles()
  } catch (e) { /* 业务错误已由拦截器提示 */ } finally { saving.value = false }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定删除角色「${row.roleName}」吗？若已有用户绑定该角色将受影响。`, '提示', { type: 'warning' })
    .then(async () => {
      await request({ url: `/role/${row.id}`, method: 'delete' })
      ElMessage.success('删除成功')
      loadRoles()
    }).catch(() => {})
}

onMounted(() => {
  loadPermOptions()
  loadRoles()
})
</script>

<style scoped>
.search-bar {
  background: #f8f9fa;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 10px 14px;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}
.search-bar .label { font-size: 13px; color: #666; white-space: nowrap; }
.perm-tip { font-size: 12px; color: #777; line-height: 1.8; background: #f7f9fc; border-radius: 4px; padding: 8px 10px; margin-bottom: 12px; }
.perm-tip code { background: #eef1f6; padding: 0 4px; border-radius: 3px; color: #1976D2; }
.perm-list { max-height: 420px; overflow-y: auto; border: 1px solid #ebeef5; border-radius: 4px; padding: 4px 10px; }
.perm-item { border-bottom: 1px dashed #f0f0f0; padding: 8px 2px; }
.perm-item:last-child { border-bottom: none; }
.perm-item-head { display: flex; align-items: center; gap: 8px; }
.perm-item-head :deep(.el-checkbox__label) { font-weight: 600; color: #333; }
.perm-sub-tag { margin-left: 2px; }
.perm-mod-key { font-size: 11px; color: #bbb; }
.perm-actions { padding: 6px 0 4px 24px; }
.perm-actions :deep(.el-checkbox) { margin-right: 12px; }
.perm-actions :deep(.el-checkbox__label) { font-size: 12px; padding-left: 4px; }
</style>
