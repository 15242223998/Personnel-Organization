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
          <el-button size="small" @click="handleCleanOper"><el-icon><Delete /></el-icon> 清空日志</el-button>
          <el-button size="small" @click="exportOperLog"><el-icon><Download /></el-icon> 导出</el-button>
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
          <el-button size="small" @click="handleCleanLogin"><el-icon><Delete /></el-icon> 清空日志</el-button>
          <el-button size="small" @click="exportLoginLog"><el-icon><Download /></el-icon> 导出</el-button>
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

// Mock数据兜底
const mockOperData = [
  { id: 1, username: 'admin', operType: 'INSERT', operModule: '用户管理', operDesc: '新增用户：wangzq（王志强）', operIp: '192.168.1.100', operTime: '2026-08-10T09:15:23', operResult: 'SUCCESS' },
  { id: 2, username: 'liudm', operType: 'UPDATE', operModule: '干部信息', operDesc: '修改干部张建国的职务信息', operIp: '192.168.1.105', operTime: '2026-08-10T08:45:12', operResult: 'SUCCESS' },
  { id: 3, username: 'admin', operType: 'DELETE', operModule: '角色管理', operDesc: '删除角色：临时访客', operIp: '192.168.1.100', operTime: '2026-08-09T17:30:05', operResult: 'SUCCESS' },
  { id: 4, username: 'wangzq', operType: 'QUERY', operModule: '干部考核', operDesc: '查询2025年度考核结果列表', operIp: '192.168.1.108', operTime: '2026-08-09T16:20:45', operResult: 'SUCCESS' },
  { id: 5, username: 'lixy', operType: 'EXPORT', operModule: '统计分析', operDesc: '导出干部队伍年龄结构统计表', operIp: '192.168.1.112', operTime: '2026-08-09T15:10:33', operResult: 'SUCCESS' },
  { id: 6, username: 'zhangjg', operType: 'APPROVE', operModule: '日常事务', operDesc: '审批休假申请：刘德明年休假', operIp: '192.168.1.120', operTime: '2026-08-09T14:05:18', operResult: 'SUCCESS' },
  { id: 7, username: 'admin', operType: 'INSERT', operModule: '字典管理', operDesc: '新增字典项：政治面貌-民主促进会会员', operIp: '192.168.1.100', operTime: '2026-08-09T11:30:22', operResult: 'SUCCESS' },
  { id: 8, username: 'chenlh', operType: 'DELETE', operModule: '日常事务', operDesc: '删除证照记录：E99999999', operIp: '192.168.1.115', operTime: '2026-08-08T16:45:10', operResult: 'FAIL' },
  { id: 9, username: 'admin', operType: 'UPDATE', operModule: '系统配置', operDesc: '修改系统参数：密码有效期', operIp: '192.168.1.100', operTime: '2026-08-08T10:20:05', operResult: 'SUCCESS' },
  { id: 10, username: 'zhaogd', operType: 'QUERY', operModule: '个人事项', operDesc: '查询个人事项报告记录', operIp: '192.168.1.125', operTime: '2026-08-08T09:30:41', operResult: 'SUCCESS' }
]

const mockLoginData = [
  { id: 1, username: 'admin', loginIp: '192.168.1.100', deviceType: 'PC', browser: 'Chrome 128', os: 'Windows 11', loginTime: '2026-08-10T08:30:15', loginResult: 'SUCCESS', failReason: '' },
  { id: 2, username: 'liudm', loginIp: '192.168.1.105', deviceType: 'PC', browser: 'Chrome 128', os: 'Windows 10', loginTime: '2026-08-10T08:25:03', loginResult: 'SUCCESS', failReason: '' },
  { id: 3, username: 'zhangjg', loginIp: '192.168.1.120', deviceType: 'PC', browser: 'Edge 128', os: 'Windows 11', loginTime: '2026-08-10T08:15:42', loginResult: 'SUCCESS', failReason: '' },
  { id: 4, username: 'unknown', loginIp: '45.33.32.156', deviceType: 'PC', browser: 'Unknown', os: 'Linux', loginTime: '2026-08-10T07:55:11', loginResult: 'FAIL', failReason: '用户名不存在' },
  { id: 5, username: 'lixy', loginIp: '192.168.1.112', deviceType: 'PHONE', browser: 'Safari', os: 'iOS 17', loginTime: '2026-08-09T22:30:05', loginResult: 'SUCCESS', failReason: '' },
  { id: 6, username: 'chenlh', loginIp: '192.168.1.115', deviceType: 'PC', browser: 'Firefox 129', os: 'Windows 10', loginTime: '2026-08-09T16:30:18', loginResult: 'FAIL', failReason: '密码错误' },
  { id: 7, username: 'chenlh', loginIp: '192.168.1.115', deviceType: 'PC', browser: 'Firefox 129', os: 'Windows 10', loginTime: '2026-08-09T16:32:05', loginResult: 'SUCCESS', failReason: '' },
  { id: 8, username: 'zhaogd', loginIp: '192.168.1.125', deviceType: 'PC', browser: 'Chrome 128', os: 'Windows 11', loginTime: '2026-08-09T14:15:33', loginResult: 'SUCCESS', failReason: '' },
  { id: 9, username: 'sunhm', loginIp: '10.0.0.55', deviceType: 'PAD', browser: 'Safari', os: 'iPadOS 17', loginTime: '2026-08-09T10:05:47', loginResult: 'SUCCESS', failReason: '' },
  { id: 10, username: 'test01', loginIp: '203.0.113.50', deviceType: 'PC', browser: 'Chrome 128', os: 'Windows 10', loginTime: '2026-08-08T23:45:00', loginResult: 'FAIL', failReason: '账户已被禁用' }
]

function useMock() {
  // 后端未启动时使用mock数据
  return !window.__backendReady
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
    // 后端未连接，使用mock
    let data = [...mockOperData]
    if (operSearch.username) {
      data = data.filter(d => d.username.includes(operSearch.username))
    }
    if (operSearch.operType) {
      data = data.filter(d => d.operType === operSearch.operType)
    }
    operPage.total = data.length
    const start = (operPage.current - 1) * operPage.size
    operData.value = data.slice(start, start + operPage.size)
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
    let data = [...mockLoginData]
    if (loginSearch.username) {
      data = data.filter(d => d.username.includes(loginSearch.username))
    }
    if (loginSearch.loginResult) {
      data = data.filter(d => d.loginResult === loginSearch.loginResult)
    }
    loginPage.total = data.length
    const start = (loginPage.current - 1) * loginPage.size
    loginData.value = data.slice(start, start + loginPage.size)
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
  // 切换tab时加载对应数据
}

async function handleDeleteOper(id) {
  try {
    await ElMessageBox.confirm('确定删除该条日志吗？', '提示', { type: 'warning' })
    try {
      await deleteOperLog(id)
      ElMessage.success('删除成功')
    } catch (e) {
      // mock
    }
    const idx = operData.value.findIndex(d => d.id === id)
    if (idx > -1) operData.value.splice(idx, 1)
    operPage.total--
  } catch {}
}

async function handleDeleteLogin(id) {
  try {
    await ElMessageBox.confirm('确定删除该条日志吗？', '提示', { type: 'warning' })
    try {
      await deleteLoginLog(id)
      ElMessage.success('删除成功')
    } catch (e) {}
    const idx = loginData.value.findIndex(d => d.id === id)
    if (idx > -1) loginData.value.splice(idx, 1)
    loginPage.total--
  } catch {}
}

async function handleCleanOper() {
  try {
    await ElMessageBox.confirm('确定清空所有操作日志吗？此操作不可恢复！', '警告', { type: 'warning' })
    try {
      await cleanOperLog()
      ElMessage.success('清空成功')
    } catch (e) {}
    operData.value = []
    operPage.total = 0
  } catch {}
}

async function handleCleanLogin() {
  try {
    await ElMessageBox.confirm('确定清空所有登录日志吗？此操作不可恢复！', '警告', { type: 'warning' })
    try {
      await cleanLoginLog()
      ElMessage.success('清空成功')
    } catch (e) {}
    loginData.value = []
    loginPage.total = 0
  } catch {}
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
