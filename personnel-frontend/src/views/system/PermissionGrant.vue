<template>
  <div class="grant-page">
    <div class="page-head">
      <div class="page-title">
        <h2>模块权限授予</h2>
        <p class="page-tip">
          说明：菜单对所有账号可见，未授权模块进入后右侧内容区将显示“未拥有权限”占位提示。
          系统管理员（用户类型 1）免授权、全模块放行；其余账号默认按“用户类型内置模板”放行模块：
          校级领导/组织部部长/组织员 = 除“系统管理”外全部业务模块；二级学院领导 = 机构/干部/调配/晋升/考核/日常；普通干部 = 无默认模块。
          勾选模块并点“保存授权”即为该账号“单独授权”（非空权限将覆盖其类型默认模板）；
          点“恢复类型默认”即清空单独授权，回到该用户类型的默认模板。
        </p>
      </div>
      <div class="head-tools">
        <el-input
          v-model="keyword"
          placeholder="搜索账号/姓名"
          clearable
          style="width: 200px"
          size="default"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-button type="primary" :icon="Refresh" @click="loadUsers">刷新</el-button>
      </div>
    </div>

    <el-card shadow="never" class="grant-card">
      <div class="list-tip">共 {{ filteredRows.length }} 个账号（不含系统管理员限制）</div>
      <el-table :data="filteredRows" v-loading="loading" border size="small" row-key="id">
        <el-table-column prop="username" label="账号" width="110" show-overflow-tooltip />
        <el-table-column prop="realName" label="姓名" width="110" align="center" />
        <el-table-column label="用户类型" width="150" align="center">
          <template #default="{ row }">
            <el-select
              v-model="row.userType"
              :disabled="row.userType === 1"
              size="small"
              style="width: 128px"
              @change="changeType(row)"
            >
              <el-option v-for="r in roleOptions" :key="r.value" :label="r.label" :value="r.value" />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : row.status === 0 ? 'warning' : 'info'" size="small">
              {{ statusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="模块权限（勾选后保存）" min-width="520">
          <template #default="{ row }">
            <div v-if="row.userType === 1" class="admin-tip">系统管理员免授权，始终放行</div>
            <template v-else>
              <div v-if="!hasOverride(row)" class="default-tip">当前无单独授权，生效权限使用类型默认模板</div>
              <el-checkbox-group v-model="row.perms" class="perm-group">
                <el-checkbox v-for="p in PERM_KEYS" :key="p.key" :value="p.key" size="small">
                  {{ p.label }}
                </el-checkbox>
              </el-checkbox-group>
            </template>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="310" align="center">
          <template #default="{ row }">
            <div v-if="row.userType !== 1" class="op-btns">
              <el-button
                type="primary"
                size="small"
                :loading="savingId === row.id"
                @click="saveRow(row)"
              >保存授权</el-button>
              <el-button link type="primary" size="small" @click="selectAll(row)">全选</el-button>
              <el-button link type="danger" size="small" @click="clearAll(row)">清空</el-button>
              <el-button
                link
                type="warning"
                size="small"
                :disabled="!hasOverride(row)"
                :loading="restoringId === row.id"
                @click="restoreDefault(row)"
              >恢复类型默认</el-button>
            </div>
            <span v-else class="muted">—</span>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { getUserList, putUserPermissions } from '../../api/system'
import { PERM_KEYS } from '../../utils/perms'

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

function parsePerms(val) {
  if (!val) return []
  return String(val).split(',').map(s => s.trim()).filter(Boolean)
}

// 是否有“单独授权”覆盖：用户级 permissions 非空即视为覆盖（空则按用户类型内置默认模板生效）
function hasOverride(row) {
  return !!(row.permissions && String(row.permissions).trim())
}

const loading = ref(false)
const savingId = ref(null)
const restoringId = ref(null)
const keyword = ref('')
const allRows = ref([])

const filteredRows = computed(() => {
  const kw = (keyword.value || '').trim()
  if (!kw) return allRows.value
  return allRows.value.filter(r =>
    (r.username || '').includes(kw) || (r.realName || '').includes(kw)
  )
})

async function loadUsers() {
  loading.value = true
  try {
    const res = await getUserList({ current: 1, size: 500 })
    allRows.value = (res.data.records || []).map(u => ({
      ...u,
      perms: parsePerms(u.permissions)
    }))
  } catch {
    allRows.value = []
  } finally {
    loading.value = false
  }
}

async function saveRow(row) {
  savingId.value = row.id
  try {
    await putUserPermissions(row.id, { permissions: row.perms })
    row.permissions = row.perms.join(',')
    ElMessage.success(`已保存「${row.username}」的模块权限`)
  } catch {
    // 请求层已提示错误
  } finally {
    savingId.value = null
  }
}

// 恢复类型默认：清空用户级覆盖（落空串），该用户生效权限回退为“用户类型内置模板”
async function restoreDefault(row) {
  restoringId.value = row.id
  try {
    await putUserPermissions(row.id, { permissions: [] })
    row.permissions = ''
    row.perms = []
    ElMessage.success(`已恢复为「${userTypeText(row.userType)}」内置默认权限`)
  } catch {
    // 请求层已提示错误
  } finally {
    restoringId.value = null
  }
}

// 修改用户类型：选中即保存；系统管理员(type=1)账号不可在此修改（避免误降级）
async function changeType(row) {
  try {
    await putUserType(row.id, row.userType)
    row._type0 = row.userType
    ElMessage.success(`已将「${row.username}」类型改为${userTypeText(row.userType)}`)
  } catch {
    row.userType = row._type0
    ElMessage.error('用户类型修改失败，已恢复原类型')
  }
}

function selectAll(row) {
  row.perms = PERM_KEYS.map(p => p.key)
}

function clearAll(row) {
  row.perms = []
}

function userTypeText(t) {
  return roleOptions.find(r => r.value === t)?.label || `类型${t}`
}

function statusText(s) {
  return statusOptions.find(o => o.value === s)?.label || String(s)
}

onMounted(loadUsers)
</script>

<style scoped>
.grant-page {
  background: #fff;
  border-radius: 6px;
  padding: 16px;
}
.page-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}
.page-title h2 {
  margin: 0 0 6px;
  font-size: 17px;
  color: #333;
}
.page-tip {
  margin: 0;
  font-size: 12px;
  color: #888;
  line-height: 1.8;
  max-width: 720px;
}
.head-tools {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-top: 2px;
}
.grant-card {
  border: 1px solid #ebeef5;
}
.grant-card :deep(.el-card__body) {
  padding: 12px;
}
.list-tip {
  font-size: 12px;
  color: #999;
  margin-bottom: 10px;
}
.perm-group {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.perm-group :deep(.el-checkbox) {
  margin-right: 0;
}
.perm-group :deep(.el-checkbox__label) {
  font-size: 12px;
  padding-left: 5px;
}
.admin-tip {
  color: #c45656;
  font-size: 12px;
}
.default-tip {
  color: #bbb;
  font-size: 12px;
  margin-bottom: 4px;
}
.op-btns {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 2px;
  flex-wrap: wrap;
}
.muted {
  color: #bbb;
}
</style>
