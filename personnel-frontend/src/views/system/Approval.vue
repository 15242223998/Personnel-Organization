<template>
  <div>
    <div class="page-header">审批事项管理（自助申报待审批）</div>

    <div class="search-bar">
      <span class="label">申请人：</span>
      <el-input v-model="search.name" placeholder="请输入姓名" size="default" style="width:150px" clearable />
      <span class="label">申报类型：</span>
      <el-select v-model="search.type" placeholder="全部" size="default" style="width:150px" clearable>
        <el-option label="信息变更" value="INFO_UPDATE" />
        <el-option label="请假" value="LEAVE" />
        <el-option label="兼职" value="PART_TIME" />
        <el-option label="培训" value="TRAINING" />
        <el-option label="出国（境）" value="ABROAD" />
      </el-select>
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
      <span style="margin-left:12px;font-size:12px;color:#999">数据来源：干部自助申报（/api/self-application，仅展示 SUBMITTED 待审批）</span>
    </div>

    <div class="table-wrap">
      <el-table v-loading="loading" :data="pagedData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column label="申请人" width="100" align="center" sortable>
          <template #default="{ row }">{{ applicantName(row) }}</template>
        </el-table-column>
        <el-table-column label="申报类型" width="120" align="center" sortable>
          <template #default="{ row }">
            <el-tag size="small">{{ applicationTypeText(row.applicationType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="applicationTitle" label="申报标题" min-width="200" show-overflow-tooltip sortable />
        <el-table-column prop="applicationContent" label="申报内容" min-width="260" show-overflow-tooltip />
        <el-table-column label="提交时间" width="160" align="center" sortable>
          <template #default="{ row }">{{ fmtTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag type="warning" size="small">{{ applyStatusText(row.applyStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openApprove(row)">审批</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="openView(row)">查看</span>
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

    <!-- 审批处理弹窗 -->
    <el-dialog title="审批处理" v-model="approveDialogVisible" width="560px" align-center destroy-on-close>
      <el-form label-width="90px" v-if="approveForm.id">
        <el-form-item label="申请人">{{ approveForm.applicantName }}（{{ approveForm.applicantCode }}）</el-form-item>
        <el-form-item label="申报类型">
          <el-tag size="small">{{ approveForm.typeText }}</el-tag>
        </el-form-item>
        <el-form-item label="申报标题">{{ approveForm.title }}</el-form-item>
        <el-form-item label="申报内容">
          <div style="white-space:pre-wrap;line-height:1.6;max-height:220px;overflow:auto">{{ approveForm.content || '-' }}</div>
        </el-form-item>
        <el-form-item label="提交时间">{{ approveForm.createTime }}</el-form-item>
        <el-form-item label="审批意见">
          <el-input v-model="approveForm.comment" type="textarea" :rows="3" placeholder="可选填写审批意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="approveDialogVisible = false">取消</el-button>
        <el-button type="danger" :loading="saving" @click="handleReject">驳回</el-button>
        <el-button type="primary" :loading="saving" @click="handleApprove">批准</el-button>
      </template>
    </el-dialog>

    <!-- 查看详情弹窗 -->
    <el-dialog title="申报详情" v-model="detailVisible" width="640px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="detail.id">
        <el-descriptions-item label="申请人">{{ detail.applicantName }}</el-descriptions-item>
        <el-descriptions-item label="申报类型">
          <el-tag size="small">{{ detail.typeText }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="detail.applyStatus === 'SUBMITTED' ? 'warning' : 'info'" size="small">{{ applyStatusText(detail.applyStatus) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ detail.createTime }}</el-descriptions-item>
        <el-descriptions-item label="申报标题" :span="2">{{ detail.title }}</el-descriptions-item>
        <el-descriptions-item label="申报内容" :span="2">
          <div style="white-space:pre-wrap;line-height:1.6">{{ detail.content || '-' }}</div>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getSelfApplicationPage, approveSelfApplication, rejectSelfApplication, getUserProfile } from '@/api/daily'
import request from '@/utils/request'

const loading = ref(false)
const saving = ref(false)
const allData = ref([])
const users = ref([])

const search = reactive({ name: '', type: '' })
const page = reactive({ current: 1, size: 10, total: 0 })

const approveDialogVisible = ref(false)
const detailVisible = ref(false)
const approveForm = reactive({ id: null, applicantName: '', applicantCode: '', typeText: '', title: '', content: '', createTime: '', comment: '' })
const detail = ref({})

const userMap = computed(() => Object.fromEntries(users.value.map(u => [u.id, u.realName])))
const userCodeMap = computed(() => Object.fromEntries(users.value.map(u => [u.id, u.username])))

function fmtTime(t) {
  if (!t) return '-'
  return String(t).replace('T', ' ').slice(0, 19)
}
function applyStatusText(s) {
  return { DRAFT: '草稿', SUBMITTED: '待审批', APPROVED: '已通过', REJECTED: '已驳回' }[s] || s || '-'
}
function applicationTypeText(t) {
  return { INFO_UPDATE: '信息变更', LEAVE: '请假', PART_TIME: '兼职', TRAINING: '培训', ABROAD: '出国（境）' }[t] || t || '-'
}
function applicantName(row) {
  return userMap.value[row.applicantId] || `#${row.applicantId}`
}
function applicantCode(row) {
  return userCodeMap.value[row.applicantId] || `#${row.applicantId}`
}

const filteredData = computed(() => allData.value.filter(d =>
  (!search.name || applicantName(d).includes(search.name)) &&
  (!search.type || d.applicationType === search.type)))

const pagedData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

async function loadData() {
  loading.value = true
  try {
    const res = await getSelfApplicationPage({ current: 1, size: 500 })
    // 审批中心 = 自助申报中“已提交（待审批）”的真实记录
    allData.value = (res.data.records || []).filter(d => d.applyStatus === 'SUBMITTED')
    page.total = filteredData.value.length
  } finally { loading.value = false }
}

async function loadUsers() {
  try {
    const res = await request({ url: '/user/page', method: 'get', params: { current: 1, size: 500 } })
    users.value = res.data.records || []
  } catch (e) { users.value = [] }
}

const profile = ref(null)
async function loadProfile() {
  try {
    const p = await getUserProfile()
    profile.value = p.data
  } catch (e) { profile.value = null }
}

function handleSearch() {
  page.current = 1
  page.total = filteredData.value.length
}
function handleReset() {
  search.name = ''
  search.type = ''
  page.current = 1
  page.total = filteredData.value.length
}

function openApprove(row) {
  approveForm.id = row.id
  approveForm.applicantName = applicantName(row)
  approveForm.applicantCode = applicantCode(row)
  approveForm.typeText = applicationTypeText(row.applicationType)
  approveForm.title = row.applicationTitle || ''
  approveForm.content = row.applicationContent || ''
  approveForm.createTime = fmtTime(row.createTime)
  approveForm.comment = ''
  approveDialogVisible.value = true
}

function openView(row) {
  detail.value = {
    id: row.id,
    applicantName: applicantName(row),
    typeText: applicationTypeText(row.applicationType),
    applyStatus: row.applyStatus,
    createTime: fmtTime(row.createTime),
    title: row.applicationTitle || '',
    content: row.applicationContent || ''
  }
  detailVisible.value = true
}

async function handleApprove() {
  const id = approveForm.id
  if (!id) return
  saving.value = true
  try {
    await approveSelfApplication(id, { approverId: profile.value?.id, comment: approveForm.comment || undefined })
    ElMessage.success('已批准')
    approveDialogVisible.value = false
    loadData()
  } finally { saving.value = false }
}

async function handleReject() {
  const id = approveForm.id
  if (!id) return
  try {
    const { value } = await ElMessageBox.prompt('请输入驳回原因', '驳回申请', { type: 'warning', confirmButtonText: '确认驳回' })
    saving.value = true
    try {
      await rejectSelfApplication(id, { approverId: profile.value?.id, comment: value || undefined })
      ElMessage.success('已驳回')
      approveDialogVisible.value = false
      loadData()
    } finally { saving.value = false }
  } catch (e) { /* 用户取消 */ }
}

onMounted(() => {
  loadUsers()
  loadProfile()
  loadData()
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
</style>
