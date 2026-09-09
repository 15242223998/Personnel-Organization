<template>
  <div>
    <div class="page-header">系统日志</div>

    <el-tabs v-model="activeTab" class="gov-tabs" @tab-change="handleTabChange">
      <el-tab-pane label="操作日志" name="operation">
        <div class="search-bar">
          <span class="label">用户名：</span>
          <el-input v-model="operSearch.username" placeholder="请输入用户名" size="default" style="width:140px" clearable />
          <span class="label">操作类型：</span>
          <el-select v-model="operSearch.operType" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="新增" value="INSERT" />
            <el-option label="修改" value="UPDATE" />
            <el-option label="删除" value="DELETE" />
            <el-option label="查询" value="QUERY" />
            <el-option label="审批" value="APPROVE" />
            <el-option label="导出" value="EXPORT" />
          </el-select>
          <span class="label">操作时间：</span>
          <el-date-picker v-model="operSearch.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" size="default" style="width:240px" />
          <el-button type="primary" @click="fetchOperLog"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetOperSearch">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button @click="handleCleanOper"><el-icon><Delete /></el-icon> 清空日志</el-button>
          <el-button @click="exportOperLog"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="operData" border size="small" v-loading="operLoading">
            <el-table-column type="index" label="序号" width="55" align="center" :index="operIndexMethod" />
            <el-table-column prop="username" label="用户名" width="100" align="center" sortable />
            <el-table-column prop="operType" label="操作类型" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="operTypeTagType(row.operType)" size="small">{{ operTypeLabel(row.operType) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="operModule" label="操作模块" min-width="120" align="center" sortable />
            <el-table-column prop="operDesc" label="操作描述" min-width="220" show-overflow-tooltip sortable />
            <el-table-column prop="operIp" label="IP地址" min-width="130" align="center" sortable />
            <el-table-column prop="operTime" label="操作时间" width="160" align="center" sortable>
              <template #default="{ row }">{{ formatTime(row.operTime) }}</template>
            </el-table-column>
            <el-table-column prop="operResult" label="结果" width="80" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.operResult === 'SUCCESS' ? 'success' : 'danger'" size="small">{{ row.operResult === 'SUCCESS' ? '成功' : '失败' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="80" align="center">
              <template #default="{ row }">
                <span class="link-blue" @click="handleDeleteOper(row.id)">删除</span>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrap">
            <el-pagination
              v-model:current-page="operPage.current"
              v-model:page-size="operPage.size"
              :total="operPage.total"
              :page-sizes="[10, 20, 50]"
              layout="total, sizes, prev, pager, next, jumper"
              background
              small
              @size-change="fetchOperLog"
              @current-change="fetchOperLog"
            />
          </div>
        </div>
      </el-tab-pane>

      <el-tab-pane label="登录日志" name="login">
        <div class="search-bar">
          <span class="label">用户名：</span>
          <el-input v-model="loginSearch.username" placeholder="请输入用户名" size="default" style="width:140px" clearable />
          <span class="label">登录结果：</span>
          <el-select v-model="loginSearch.loginResult" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="成功" value="SUCCESS" />
            <el-option label="失败" value="FAIL" />
          </el-select>
          <span class="label">登录时间：</span>
          <el-date-picker v-model="loginSearch.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" size="default" style="width:240px" />
          <el-button type="primary" @click="fetchLoginLog"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetLoginSearch">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button @click="handleCleanLogin"><el-icon><Delete /></el-icon> 清空日志</el-button>
          <el-button @click="exportLoginLog"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="loginData" border size="small" v-loading="loginLoading">
            <el-table-column type="index" label="序号" width="55" align="center" :index="loginIndexMethod" />
            <el-table-column prop="username" label="用户名" width="100" align="center" sortable />
            <el-table-column prop="loginIp" label="IP地址" min-width="130" align="center" sortable />
            <el-table-column prop="deviceType" label="设备" width="80" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="deviceTagType(row.deviceType)" size="small">{{ deviceLabel(row.deviceType) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="browser" label="浏览器" min-width="130" align="center" sortable />
            <el-table-column prop="os" label="操作系统" min-width="130" align="center" sortable />
            <el-table-column prop="loginTime" label="登录时间" width="160" align="center" sortable>
              <template #default="{ row }">{{ formatTime(row.loginTime) }}</template>
            </el-table-column>
            <el-table-column prop="loginResult" label="结果" width="80" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.loginResult === 'SUCCESS' ? 'success' : 'danger'" size="small">{{ row.loginResult === 'SUCCESS' ? '成功' : '失败' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="failReason" label="失败原因" min-width="140" show-overflow-tooltip sortable>
              <template #default="{ row }">
                <span v-if="row.failReason" style="color:#E53935">{{ row.failReason }}</span>
                <span v-else style="color:#999">-</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="80" align="center">
              <template #default="{ row }">
                <span class="link-blue" @click="handleDeleteLogin(row.id)">删除</span>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrap">
            <el-pagination
              v-model:current-page="loginPage.current"
              v-model:page-size="loginPage.size"
              :total="loginPage.total"
              :page-sizes="[10, 20, 50]"
              layout="total, sizes, prev, pager, next, jumper"
              background
              small
              @size-change="fetchLoginLog"
              @current-change="fetchLoginLog"
            />
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Delete, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { getOperLogPage, deleteOperLog, cleanOperLog, getLoginLogPage, deleteLoginLog, cleanLoginLog } from '../../api/system'

const activeTab = ref('operation')

// 操作日志
const operLoading = ref(false)
const operData = ref([])
const operPage = reactive({ current: 1, size: 10, total: 0 })
const operSearch = reactive({ username: '', operType: '', dateRange: [] })

// 登录日志
const loginLoading = ref(false)
const loginData = ref([])
const loginPage = reactive({ current: 1, size: 10, total: 0 })
const loginSearch = reactive({ username: '', loginResult: '', dateRange: [] })

function failTips(name) {
  ElMessage.warning(`后端未连接，无法加载${name}`)
}

async function fetchOperLog() {
  operLoading.value = true
  try {
    const params = {
      current: operPage.current,
      size: operPage.size,
      username: operSearch.username || undefined,
      operType: operSearch.operType || undefined
    }
    if (operSearch.dateRange && operSearch.dateRange.length === 2) {
      params.startTime = operSearch.dateRange[0]
      params.endTime = operSearch.dateRange[1]
    }
    const res = await getOperLogPage(params)
    operData.value = res.data.records
    operPage.total = res.data.total
  } catch (e) {
    // 后端未连接：不渲染任何兜底数据，直接空态并提示
    operData.value = []
    operPage.total = 0
    failTips('操作日志')
  } finally {
    operLoading.value = false
  }
}

async function fetchLoginLog() {
  loginLoading.value = true
  try {
    const params = {
      current: loginPage.current,
      size: loginPage.size,
      username: loginSearch.username || undefined,
      loginResult: loginSearch.loginResult || undefined
    }
    if (loginSearch.dateRange && loginSearch.dateRange.length === 2) {
      params.startTime = loginSearch.dateRange[0]
      params.endTime = loginSearch.dateRange[1]
    }
    const res = await getLoginLogPage(params)
    loginData.value = res.data.records
    loginPage.total = res.data.total
  } catch (e) {
    loginData.value = []
    loginPage.total = 0
    failTips('登录日志')
  } finally {
    loginLoading.value = false
  }
}

function resetOperSearch() {
  operSearch.username = ''
  operSearch.operType = ''
  operSearch.dateRange = []
  operPage.current = 1
  fetchOperLog()
}

function resetLoginSearch() {
  loginSearch.username = ''
  loginSearch.loginResult = ''
  loginSearch.dateRange = []
  loginPage.current = 1
  fetchLoginLog()
}

function handleTabChange() {
  if (activeTab.value === 'operation') fetchOperLog()
  else fetchLoginLog()
}

async function handleDeleteOper(id) {
  try {
    await ElMessageBox.confirm('确定删除该条日志吗？', '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await deleteOperLog(id)
    ElMessage.success('删除成功')
    const idx = operData.value.findIndex(d => d.id === id)
    if (idx > -1) operData.value.splice(idx, 1)
    if (operPage.total > 0) operPage.total--
  } catch (e) {
    ElMessage.error('删除失败：后端未连接')
  }
}

async function handleDeleteLogin(id) {
  try {
    await ElMessageBox.confirm('确定删除该条日志吗？', '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await deleteLoginLog(id)
    ElMessage.success('删除成功')
    const idx = loginData.value.findIndex(d => d.id === id)
    if (idx > -1) loginData.value.splice(idx, 1)
    if (loginPage.total > 0) loginPage.total--
  } catch (e) {
    ElMessage.error('删除失败：后端未连接')
  }
}

async function handleCleanOper() {
  try {
    await ElMessageBox.confirm('确定清空所有操作日志吗？此操作不可恢复！', '警告', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await cleanOperLog()
    ElMessage.success('清空成功')
    operData.value = []
    operPage.total = 0
  } catch (e) {
    ElMessage.error('清空失败：后端未连接')
  }
}

async function handleCleanLogin() {
  try {
    await ElMessageBox.confirm('确定清空所有登录日志吗？此操作不可恢复！', '警告', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await cleanLoginLog()
    ElMessage.success('清空成功')
    loginData.value = []
    loginPage.total = 0
  } catch (e) {
    ElMessage.error('清空失败：后端未连接')
  }
}

function operIndexMethod(index) {
  return (operPage.current - 1) * operPage.size + index + 1
}

function loginIndexMethod(index) {
  return (loginPage.current - 1) * loginPage.size + index + 1
}

function operTypeTagType(type) {
  const map = { INSERT: 'success', UPDATE: '', DELETE: 'danger', QUERY: 'info', APPROVE: 'warning', EXPORT: 'warning' }
  return map[type] || ''
}

function operTypeLabel(type) {
  const map = { INSERT: '新增', UPDATE: '修改', DELETE: '删除', QUERY: '查询', APPROVE: '审批', EXPORT: '导出' }
  return map[type] || type
}

function deviceTagType(device) {
  const map = { PC: '', PHONE: 'success', PAD: 'warning' }
  return map[device] || ''
}

function deviceLabel(device) {
  const map = { PC: 'PC', PHONE: '手机', PAD: '平板' }
  return map[device] || device
}

function formatTime(t) {
  if (!t) return ''
  if (typeof t === 'string') {
    return t.replace('T', ' ').substring(0, 19)
  }
  return t
}

onMounted(() => {
  fetchOperLog()
  fetchLoginLog()
})

function exportOperLog() {
  if (operData.value.length === 0) { ElMessage.warning('当前没有可导出的日志数据'); return }
  showExportDialog(operData.value, [
    { prop: 'username', label: '用户名' },
    { prop: 'operType', label: '操作类型' },
    { prop: 'operModule', label: '操作模块' },
    { prop: 'operDesc', label: '操作描述' },
    { prop: 'operIp', label: 'IP地址' },
    { prop: 'operTime', label: '操作时间' },
    { prop: 'operResult', label: '结果' }
  ], '操作日志')
}
function exportLoginLog() {
  if (loginData.value.length === 0) { ElMessage.warning('当前没有可导出的日志数据'); return }
  showExportDialog(loginData.value, [
    { prop: 'username', label: '用户名' },
    { prop: 'loginIp', label: 'IP地址' },
    { prop: 'deviceType', label: '设备' },
    { prop: 'browser', label: '浏览器' },
    { prop: 'os', label: '操作系统' },
    { prop: 'loginTime', label: '登录时间' },
    { prop: 'loginResult', label: '结果' },
    { prop: 'failReason', label: '失败原因' }
  ], '登录日志')
}
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
.pagination-wrap {
  padding: 10px 14px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: flex-end;
}
</style>
