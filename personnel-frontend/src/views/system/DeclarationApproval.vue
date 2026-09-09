<template>
  <div>
    <div class="page-header">档案变更审批</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <el-tab-pane label="待审批" name="pending">
        <div class="search-bar">
          <span class="label">申请人：</span>
          <el-input v-model="searchName" placeholder="请输入姓名" size="default" style="width:150px" clearable />
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
          <span style="margin-left:12px;font-size:12px;color:#999">
            数据来源：干部自助申报「档案信息变更 INFO_UPDATE」（/api/self-application，仅 SUBMITTED）
          </span>
        </div>
        <div class="table-wrap">
          <el-table v-loading="loading" :data="pagedPending" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column label="申请人" width="100" align="center" sortable>
              <template #default="{ row }">{{ applicantName(row) }}</template>
            </el-table-column>
            <el-table-column label="申报类型" width="120" align="center">
              <template #default="{ row }">
                <el-tag size="small">{{ applicationTypeText(row.applicationType) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="applicationTitle" label="申报标题" min-width="200" show-overflow-tooltip sortable />
            <el-table-column prop="applicationContent" label="申报内容" min-width="220" show-overflow-tooltip />
            <el-table-column label="变更字段" width="110" align="center">
              <template #default="{ row }">
                <el-tag v-if="row.applyField" size="small" type="warning">{{ fieldLabel(row.applyField) }}</el-tag>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="旧值 → 新值" min-width="220">
              <template #default="{ row }">
                <span v-if="row.applyField" style="font-family:monospace">
                  {{ displayVal(row.oldValue) }} <span style="color:#1976D2">→</span> {{ displayVal(row.newValue) }}
                </span>
                <span v-else style="color:#bbb">非字段级更正</span>
              </template>
            </el-table-column>
            <el-table-column label="提交时间" width="160" align="center" sortable>
              <template #default="{ row }">{{ fmtTime(row.createTime) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openReview(row)">审核</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleReject(row)">拒绝</span>
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
      </el-tab-pane>

      <el-tab-pane label="已审批" name="done">
        <div class="search-bar">
          <span style="font-size:12px;color:#999">已审批 = INFO_UPDATE 中 APPROVED / REJECTED 的真实记录</span>
        </div>
        <div class="table-wrap">
          <el-table v-loading="doneLoading" :data="doneApps" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column label="申请人" width="100" align="center">
              <template #default="{ row }">{{ applicantName(row) }}</template>
            </el-table-column>
            <el-table-column prop="applicationTitle" label="申报标题" min-width="200" show-overflow-tooltip />
            <el-table-column prop="applicationContent" label="申报内容" min-width="220" show-overflow-tooltip />
            <el-table-column label="变更字段" width="110" align="center">
              <template #default="{ row }">
                <el-tag v-if="row.applyField" size="small" type="warning">{{ fieldLabel(row.applyField) }}</el-tag>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="旧值 → 新值" min-width="200">
              <template #default="{ row }">
                <span v-if="row.applyField" style="font-family:monospace">
                  {{ displayVal(row.oldValue) }} <span style="color:#1976D2">→</span> {{ displayVal(row.newValue) }}
                </span>
                <span v-else style="color:#bbb">非字段级更正</span>
              </template>
            </el-table-column>
            <el-table-column label="审批结果" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="row.applyStatus === 'APPROVED' ? 'success' : 'danger'" size="small">{{ applyStatusText(row.applyStatus) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="审批人" width="100" align="center">
              <template #default="{ row }">{{ approverName(row) }}</template>
            </el-table-column>
            <el-table-column label="审批时间" width="160" align="center">
              <template #default="{ row }">{{ fmtTime(row.approveTime) }}</template>
            </el-table-column>
            <el-table-column label="审批意见" min-width="180" show-overflow-tooltip>
              <template #default="{ row }">{{ row.approveComment || '-' }}</template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 审核详情弹窗 -->
    <el-dialog v-model="reviewVisible" title="档案变更审核" width="640px" top="8vh" align-center destroy-on-close>
      <div v-if="currentApp">
        <el-alert :title="`${applicantName(currentApp)} 提交的档案信息变更申报`" type="info" :closable="false" show-icon style="margin-bottom:16px" />
        <el-descriptions :column="1" border size="small" style="margin-bottom:16px">
          <el-descriptions-item label="申报标题">{{ currentApp.applicationTitle || '-' }}</el-descriptions-item>
          <el-descriptions-item v-if="currentApp.applyField" label="变更字段">
            <el-tag size="small" type="warning">{{ fieldLabel(currentApp.applyField) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item v-if="currentApp.applyField" label="变更前后">
            <span style="font-family:monospace">{{ displayVal(currentApp.oldValue) }} <span style="color:#1976D2">→</span> {{ displayVal(currentApp.newValue) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ fmtTime(currentApp.createTime) }}</el-descriptions-item>
          <el-descriptions-item label="申报内容">
            <div style="white-space:pre-wrap;line-height:1.6">{{ currentApp.applicationContent || '-' }}</div>
          </el-descriptions-item>
        </el-descriptions>
        <el-alert v-if="currentApp.applyField" type="success" :closable="false" show-icon style="margin-bottom:8px"
          title="通过后系统将按「变更字段」把干部档案由旧值自动更新为新值（白名单字段）并记录审批意见。" />
        <p v-else style="font-size:12px;color:#999;margin:0 0 8px">说明：该申报为整表信息申报（无单字段更正），通过后仅完成审批归档，不直接回写档案。</p>
        <el-form label-width="90px">
          <el-form-item label="审批意见">
            <el-input v-model="reviewComment" type="textarea" :rows="3" placeholder="可选填写审批意见" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="reviewVisible = false">关闭</el-button>
        <el-button type="danger" :loading="saving" @click="doReject">拒绝</el-button>
        <el-button type="primary" :loading="saving" @click="doApprove">通过</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { getSelfApplicationPage, approveSelfApplication, rejectSelfApplication, getUserProfile } from '@/api/daily'
import request from '@/utils/request'

const activeTab = ref('pending')
const loading = ref(false)
const doneLoading = ref(false)
const saving = ref(false)
const searchName = ref('')

const pendingAll = ref([])
const doneApps = ref([])
const users = ref([])

const reviewVisible = ref(false)
const reviewComment = ref('')
const currentApp = ref(null)

const profile = ref(null)

const userMap = computed(() => Object.fromEntries(users.value.map(u => [u.id, u.realName])))

function fmtTime(t) {
  if (!t) return '-'
  return String(t).replace('T', ' ').slice(0, 19)
}
function applyStatusText(s) {
  return { SUBMITTED: '待审批', APPROVED: '已通过', REJECTED: '已驳回' }[s] || s || '-'
}
function applicationTypeText(t) {
  return { INFO_UPDATE: '档案信息变更' }[t] || t || '-'
}
function applicantName(row) {
  return userMap.value[row.applicantId] || `#${row.applicantId}`
}
function approverName(row) {
  if (!row.approverId) return '-'
  return userMap.value[row.approverId] || `#${row.approverId}`
}

const filteredPending = computed(() => pendingAll.value.filter(d =>
  !searchName.value || applicantName(d).includes(searchName.value)))

const page = ref({ current: 1, size: 10, total: 0 })
const pagedPending = computed(() => {
  const start = (page.value.current - 1) * page.value.size
  return filteredPending.value.slice(start, start + page.value.size)
})

function syncTotal() {
  page.value.total = filteredPending.value.length
}

function handleSearch() {
  page.value.current = 1
  syncTotal()
}
function resetSearch() {
  searchName.value = ''
  page.value.current = 1
  syncTotal()
}

async function loadPending() {
  loading.value = true
  try {
    const res = await getSelfApplicationPage({ current: 1, size: 500 })
    pendingAll.value = (res.data.records || []).filter(d => d.applicationType === 'INFO_UPDATE' && d.applyStatus === 'SUBMITTED')
    syncTotal()
  } finally { loading.value = false }
}

async function loadDone() {
  doneLoading.value = true
  try {
    const res = await getSelfApplicationPage({ current: 1, size: 500 })
    doneApps.value = (res.data.records || []).filter(d => d.applicationType === 'INFO_UPDATE' && (d.applyStatus === 'APPROVED' || d.applyStatus === 'REJECTED'))
  } finally { doneLoading.value = false }
}

async function loadUsers() {
  try {
    const res = await request({ url: '/user/page', method: 'get', params: { current: 1, size: 500 } })
    users.value = res.data.records || []
  } catch (e) { users.value = [] }
}

async function loadProfile() {
  try {
    const p = await getUserProfile()
    profile.value = p.data
  } catch (e) { profile.value = null }
}

function openReview(row) {
  currentApp.value = row
  reviewComment.value = ''
  reviewVisible.value = true
}

async function doApprove() {
  const app = currentApp.value
  if (!app) return
  saving.value = true
  try {
    await approveSelfApplication(app.id, { approverId: profile.value?.id, comment: reviewComment.value || undefined })
    ElMessage.success(app.applyField ? '已通过，干部档案已自动更新' : '已通过，档案变更申请审批完成')
    reviewVisible.value = false
    loadPending()
    loadDone()
  } finally { saving.value = false }
}

async function doReject() {
  const app = currentApp.value
  if (!app) return
  let reason = reviewComment.value
  if (!reason) {
    try {
      const { value } = await ElMessageBox.prompt('请输入拒绝原因', '拒绝申请', { type: 'warning', confirmButtonText: '确认拒绝' })
      reason = value
    } catch (e) { return }
  }
  saving.value = true
  try {
    await rejectSelfApplication(app.id, { approverId: profile.value?.id, comment: reason || undefined })
    ElMessage.success('已拒绝该档案变更申报')
    reviewVisible.value = false
    loadPending()
    loadDone()
  } finally { saving.value = false }
}

async function handleReject(row) {
  let reason
  try {
    const { value } = await ElMessageBox.prompt('请输入拒绝原因', '拒绝申请', { type: 'warning', confirmButtonText: '确认拒绝' })
    reason = value
  } catch (e) { return }
  saving.value = true
  try {
    await rejectSelfApplication(row.id, { approverId: profile.value?.id, comment: reason || undefined })
    ElMessage.success('已拒绝该档案变更申报')
    loadPending()
    loadDone()
  } finally { saving.value = false }
}

onMounted(() => {
  loadUsers()
  loadProfile()
  loadPending()
  loadDone()
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
