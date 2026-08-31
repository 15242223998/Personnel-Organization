<template>
  <div>
    <div class="page-header">个人基础信息审批</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <el-tab-pane label="待审批" name="pending">
        <div class="search-bar">
          <span class="label">申请人：</span><el-input v-model="searchName" placeholder="请输入姓名" size="default" style="width:140px" clearable />
          <span class="label">申报类型：</span>
          <el-select v-model="searchType" placeholder="全部" size="default" style="width:140px" clearable>
            <el-option label="个人基础信息" value="basic" /><el-option label="履历信息" value="resume" />
            <el-option label="奖惩资料" value="reward" /><el-option label="家庭成员" value="family" />
          </el-select>
          <el-button type="primary" @click="filterApps"><el-icon><Search /></el-icon> 查询</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="filteredApps" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="applicant" label="申请人" width="90" align="center" sortable />
            <el-table-column prop="deptName" label="所在机构" min-width="150" show-overflow-tooltip sortable />
            <el-table-column prop="type" label="申报类型" width="120" align="center" sortable />
            <el-table-column prop="summary" label="变更摘要" min-width="200" show-overflow-tooltip />
            <el-table-column prop="submitTime" label="提交时间" width="160" align="center" sortable />
            <el-table-column label="操作" width="180" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openReview(row)">审核</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleReject(row)">拒绝</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="已审批" name="done">
        <div class="table-wrap">
          <el-table :data="doneApps" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="applicant" label="申请人" width="90" align="center" />
            <el-table-column prop="type" label="申报类型" width="120" align="center" />
            <el-table-column prop="result" label="审批结果" width="90" align="center">
              <template #default="{ row }"><el-tag :type="row.result === '通过' ? 'success' : 'danger'" size="small">{{ row.result }}</el-tag></template>
            </el-table-column>
            <el-table-column prop="reviewer" label="审批人" width="90" align="center" />
            <el-table-column prop="reviewTime" label="审批时间" width="160" align="center" />
            <el-table-column prop="comment" label="审批意见" min-width="180" show-overflow-tooltip />
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 审核详情：新旧对比弹窗 -->
    <el-dialog v-model="reviewVisible" title="档案变更审核" width="900px" top="2vh" destroy-on-close>
      <el-alert :title="`${currentApp?.applicant} 提交的${currentApp?.type}变更申请`" type="info" :closable="false" show-icon style="margin-bottom:16px" />

      <el-table :data="compareFields" border size="small" style="margin-bottom:16px">
        <el-table-column prop="label" label="字段" width="120" align="center" />
        <el-table-column label="修改前" min-width="200">
          <template #default="{ row }"><span :class="{ 'highlight-changed': row.changed }">{{ row.oldValue }}</span></template>
        </el-table-column>
        <el-table-column label="修改后" min-width="200">
          <template #default="{ row }"><span :class="{ 'highlight-changed': row.changed }" style="color:#1976D2;font-weight:500">{{ row.newValue }}</span></template>
        </el-table-column>
      </el-table>

      <!-- 奖惩/家庭成员/履历的子表对比 -->
      <div v-if="currentApp?.subTables && currentApp.subTables.length > 0" v-for="(st, si) in currentApp.subTables" :key="si" style="margin-bottom:16px">
        <div style="font-weight:600;color:#1976D2;margin-bottom:8px;font-size:13px">{{ st.title }}</div>
        <el-table :data="st.items" border size="small">
          <el-table-column type="index" label="序号" width="50" align="center" />
          <el-table-column v-for="col in st.columns" :key="col" :prop="col" :label="col" min-width="120" align="center">
            <template #default="{ row: item }">
              <span :class="{ 'highlight-changed': item._changed }" :style="item._changed ? 'color:#1976D2;font-weight:500' : ''">{{ item[col] }}</span>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="80" align="center">
            <template #default="{ row: item }">
              <el-tag :type="item._action === '新增' ? 'success' : item._action === '删除' ? 'danger' : ''" size="small">{{ item._action || '—' }}</el-tag>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <el-form label-width="100px">
        <el-form-item label="审批意见">
          <el-input v-model="reviewComment" type="textarea" :rows="3" placeholder="可选填写审批意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="reviewVisible = false">关闭</el-button>
        <el-button type="danger" @click="doReject">拒绝</el-button>
        <el-button type="primary" @click="doApprove">通过</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'

const activeTab = ref('pending')
const searchName = ref('')
const searchType = ref('')
const reviewVisible = ref(false)
const reviewComment = ref('')
const currentApp = ref(null)

// Built-in sample approvals (always present as baseline)
const sampleApps = [
  {
    id: 1, applicant: '张建国', deptName: '党委办公室', type: '个人基础信息',
    summary: '学历由"硕士研究生"变更为"博士研究生"；学位由"硕士"变更为"博士"',
    submitTime: '2026-08-10 14:30',
    fields: [
      { label: '最高学历', oldValue: '硕士研究生', newValue: '博士研究生', changed: true },
      { label: '最高学位', oldValue: '硕士', newValue: '博士', changed: true },
      { label: '联系电话', oldValue: '13800138000', newValue: '13912345678', changed: true },
      { label: '家庭住址', oldValue: '鼓楼区中山路100号', newValue: '建邺区奥体大街200号', changed: true }
    ]
  },
  {
    id: 2, applicant: '李秀英', deptName: '机械工程学院', type: '家庭成员',
    summary: '新增家庭成员"李小明"（子女）；删除原配偶记录',
    submitTime: '2026-08-11 09:15',
    fields: [
      { label: '原配偶', oldValue: '王志强（电气工程学院 教授）', newValue: '—（已删除）', changed: true },
      { label: '新增子女', oldValue: '—', newValue: '李小明（南京市第一中学 在读）', changed: true }
    ]
  },
  {
    id: 3, applicant: '王志强', deptName: '电气工程学院', type: '履历信息',
    summary: '补充挂职经历；修正任职结束时间',
    submitTime: '2026-08-09 16:20',
    fields: [
      { label: '新增经历', oldValue: '—', newValue: '2018-06 至 2021-07 甘肃省陇南市教育局', changed: true },
      { label: '修改历史', oldValue: '2015-03 至 2017-06', newValue: '2015-03 至 2017-12', changed: true }
    ]
  }
]

function loadSubmissions() {
  return JSON.parse(localStorage.getItem('cadre_submissions') || '[]')
}

function saveSubmissions(subs) {
  localStorage.setItem('cadre_submissions', JSON.stringify(subs))
}

const pendingApps = ref([])
const doneApps = ref([
  { applicant: '刘德明', type: '个人基础信息', result: '通过', reviewer: '赵处长', reviewTime: '2026-08-05 10:30', comment: '学历信息已核实无误，准予通过' },
  { applicant: '陈丽华', type: '奖惩资料', result: '拒绝', reviewer: '赵处长', reviewTime: '2026-08-03 15:00', comment: '奖励证明文件不完整，请补充后重新提交' },
  { applicant: '周伟民', type: '家庭成员', result: '通过', reviewer: '钱副处长', reviewTime: '2026-07-28 11:20', comment: '家庭成员变更与实际情况相符' }
])

function refreshFromStorage() {
  const subs = loadSubmissions()
  const fromStorage = subs.map(s => ({
    ...s,
    fields: buildCompareFields(s),
    _source: 'storage'
  })).filter(s => !pendingApps.value.find(p => p.id === s.id && p._source === 'storage'))
  pendingApps.value = [...sampleApps]
}

function buildCompareFields(submission) {
  const fields = []
  const b = submission.basic || {}
  const defaultData = {
    '张建国': { phone:'13800138000', education:'硕士研究生', degree:'硕士', address:'鼓楼区中山路100号' },
    '李秀英': { phone:'13900139001', education:'博士研究生', degree:'博士', address:'江宁区天元路88号' },
    '王志强': { phone:'13800138001', education:'博士研究生', degree:'博士', address:'秦淮区健康路50号' },
    '刘德明': { phone:'13800138002', education:'硕士研究生', degree:'硕士', address:'浦口区文德路100号' },
    '陈丽华': { phone:'13800138003', education:'硕士研究生', degree:'硕士', address:'建邺区梦都大街200号' }
  }
  const old = defaultData[submission.applicant] || {}
  if (b.phone && b.phone !== old.phone) fields.push({ label:'联系电话', oldValue: old.phone||'(空)', newValue: b.phone, changed: true })
  if (b.education && b.education !== old.education) fields.push({ label:'最高学历', oldValue: old.education||'(空)', newValue: b.education, changed: true })
  if (b.degree && b.degree !== old.degree) fields.push({ label:'最高学位', oldValue: old.degree||'(空)', newValue: b.degree, changed: true })
  if (b.address && b.address !== old.address) fields.push({ label:'家庭住址', oldValue: old.address||'(空)', newValue: b.address, changed: true })
  if (fields.length === 0) fields.push({ label:'全部字段', oldValue:'无变更', newValue:'无变更', changed: false })
  return fields
}

onMounted(() => {
  pendingApps.value = [...sampleApps]
})

const filteredApps = computed(() => {
  let data = pendingApps.value
  if (searchName.value) data = data.filter(d => d.applicant.includes(searchName.value))
  if (searchType.value) data = data.filter(d => d.type === searchType.value || searchType.value === 'basic' && d.type === '个人基础信息')
  return data
})

function filterApps() {}

function openReview(row) {
  currentApp.value = row
  reviewComment.value = ''
  reviewVisible.value = true
}

function removeSubmission(app) {
  pendingApps.value = pendingApps.value.filter(d => d.id !== app.id)
  const subs = loadSubmissions().filter(s => String(s.id) !== String(app.id))
  saveSubmissions(subs)
}

function doApprove() {
  const app = currentApp.value
  ElMessageBox.confirm(`确认通过 ${app.applicant} 的申报申请吗？通过后变更数据将写入正式干部信息库。`, '确认通过', { type: 'success', confirmButtonText: '确认通过' })
    .then(() => {
      doneApps.value.unshift({ applicant: app.applicant, type: app.type, result: '通过', reviewer: '当前审批人', reviewTime: new Date().toLocaleString(), comment: reviewComment.value || '已核实，准予通过' })
      removeSubmission(app)
      reviewVisible.value = false
      ElMessage.success(`已通过 ${app.applicant} 的申报申请，数据已正式入库`)
    }).catch(() => {})
}

function handleReject(row) {
  ElMessageBox.prompt('请输入拒绝原因', '拒绝申请', { type: 'warning', confirmButtonText: '确认拒绝' })
    .then(({ value }) => {
      doneApps.value.unshift({ applicant: row.applicant, type: row.type, result: '拒绝', reviewer: '当前审批人', reviewTime: new Date().toLocaleString(), comment: value })
      removeSubmission(row)
      ElMessage.success(`已拒绝 ${row.applicant} 的申报申请`)
    }).catch(() => {})
}

function doReject() {
  const app = currentApp.value
  ElMessageBox.prompt('请输入拒绝原因', '拒绝申请', { type: 'warning', confirmButtonText: '确认拒绝' })
    .then(({ value }) => {
      doneApps.value.unshift({ applicant: app.applicant, type: app.type, result: '拒绝', reviewer: '当前审批人', reviewTime: new Date().toLocaleString(), comment: value })
      removeSubmission(app)
      reviewVisible.value = false
      ElMessage.success(`已拒绝 ${app.applicant} 的申报申请`)
    }).catch(() => {})
}

const compareFields = computed(() => currentApp.value?.fields || [])
</script>

<style scoped>
.highlight-changed {
  background: #FFF9C4;
  padding: 2px 6px;
  border-radius: 3px;
  display: inline-block;
}
.search-bar { margin-bottom: 12px; display: flex; align-items: center; gap: 10px; }
.search-bar .label { font-size: 13px; color: #666; white-space: nowrap; }
</style>
