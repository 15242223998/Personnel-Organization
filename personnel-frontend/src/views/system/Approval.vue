<template>
  <div>
    <div class="page-header">审批事项管理</div>

    <div class="search-bar">
      <span class="label">申请人：</span>
      <el-input v-model="search.name" placeholder="请输入姓名" size="default" style="width:140px" clearable />
      <span class="label">审批类型：</span>
      <el-select v-model="search.type" placeholder="请选择" size="default" style="width:140px" clearable>
        <el-option label="因私出国（境）" value="因私出国（境）" />
        <el-option label="干部兼职" value="干部兼职" />
        <el-option label="请销假" value="请销假" />
        <el-option label="培训申报" value="培训申报" />
        <el-option label="干部基础信息变更" value="干部基础信息变更" />
        <el-option label="证照借出" value="证照借出" />
      </el-select>
      <span class="label">状态：</span>
      <el-select v-model="search.status" placeholder="请选择" size="default" style="width:120px" clearable>
        <el-option label="待审批" value="待审批" />
        <el-option label="审批中" value="审批中" />
        <el-option label="已批准" value="已批准" />
        <el-option label="已驳回" value="已驳回" />
      </el-select>
      <el-button type="primary" @click="fetchData"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" size="small" @click="handleAdd"><el-icon><Plus /></el-icon> 发起审批</el-button>
      <el-button size="small" @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" @sort-change="handleSortChange">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="申请人" width="90" align="center" sortable="custom" />
        <el-table-column prop="dept" label="部门" min-width="140" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="type" label="审批类型" width="130" align="center" sortable="custom" />
        <el-table-column prop="title" label="事项标题" min-width="220" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="applyDate" label="申请日期" width="110" align="center" sortable="custom" />
        <el-table-column prop="status" label="状态" width="100" align="center" sortable="custom">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="currentApprover" label="当前审批人" width="100" align="center" sortable="custom" />
        <el-table-column prop="approveDate" label="审批完成日期" width="130" align="center" sortable="custom" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <el-divider direction="vertical" />
            <span class="link-blue" v-if="row.status==='待审批'||row.status==='审批中'" @click="openApprove(row)">处理</span>
            <span class="link-blue" v-else style="color:#43A047" @click="handleView(row)">已办结</span>
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
        :page-sizes="[10,20,50]"
        :total="page.total"
        layout="total,sizes,prev,pager,next,jumper"
        background
        small
        @size-change="handleSizeChange"
        @current-change="fetchData"
      />
    </div>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="申请人" prop="name">
          <el-input v-model="form.name" placeholder="请输入申请人姓名" />
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="部门" prop="dept">
              <el-input v-model="form.dept" placeholder="请输入部门" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="审批类型" prop="type">
              <el-select v-model="form.type" style="width:100%">
                <el-option label="因私出国（境）" value="因私出国（境）" />
                <el-option label="干部兼职" value="干部兼职" />
                <el-option label="请销假" value="请销假" />
                <el-option label="培训申报" value="培训申报" />
                <el-option label="干部基础信息变更" value="干部基础信息变更" />
                <el-option label="证照借出" value="证照借出" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="事项标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入事项标题" />
        </el-form-item>
        <el-form-item label="申请日期" prop="applyDate">
          <el-date-picker v-model="form.applyDate" type="date" placeholder="选择日期" style="width:100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="事项描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="4" placeholder="请详细描述审批事项" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>

    <el-dialog title="审批处理" v-model="approveDialogVisible" width="500px">
      <el-form label-width="100px">
        <el-form-item label="事项标题">
          <span>{{ approveForm.title }}</span>
        </el-form-item>
        <el-form-item label="申请人">
          <span>{{ approveForm.name }}（{{ approveForm.dept }}）</span>
        </el-form-item>
        <el-form-item label="事项描述">
          <span>{{ approveForm.description }}</span>
        </el-form-item>
        <el-form-item label="审批意见">
          <el-input v-model="approveForm.opinion" type="textarea" :rows="3" placeholder="请输入审批意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="danger" @click="handleReject">驳回</el-button>
        <el-button type="success" @click="handleApprove">批准</el-button>
      </template>
    </el-dialog>

    <el-dialog title="审批详情" v-model="detailVisible" width="600px">
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="申请人">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="部门">{{ detail.dept }}</el-descriptions-item>
        <el-descriptions-item label="审批类型">
          <el-tag size="small">{{ detail.type }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(detail.status)" size="small">{{ detail.status }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="事项标题" :span="2">{{ detail.title }}</el-descriptions-item>
        <el-descriptions-item label="申请日期">{{ detail.applyDate }}</el-descriptions-item>
        <el-descriptions-item label="审批完成">{{ detail.approveDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="事项描述" :span="2">{{ detail.description }}</el-descriptions-item>
        <el-descriptions-item label="审批意见" :span="2">{{ detail.opinion || '暂无' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage, ElMessageBox } from 'element-plus'

const search = reactive({ name: '', type: '', status: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const approveDialogVisible = ref(false)
const detailVisible = ref(false)
const dialogTitle = ref('')
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)
const detail = ref({})
const approveForm = reactive({ id: null, name: '', dept: '', title: '', description: '', opinion: '' })

const form = reactive({ name: '', dept: '', type: '', title: '', applyDate: '', description: '' })

const rules = {
  name: [{ required: true, message: '请输入申请人', trigger: 'blur' }],
  dept: [{ required: true, message: '请输入部门', trigger: 'blur' }],
  type: [{ required: true, message: '请选择审批类型', trigger: 'change' }],
  title: [{ required: true, message: '请输入事项标题', trigger: 'blur' }],
  applyDate: [{ required: true, message: '请选择申请日期', trigger: 'change' }],
}

function getStatusType(status) {
  if (status === '已批准') return 'success'
  if (status === '审批中' || status === '待审批') return 'warning'
  if (status === '已驳回') return 'danger'
  return 'info'
}

const mockData = [
  { id: 1, name: '张建国', dept: '机械工程学院', type: '因私出国（境）', title: '申请因私赴日本旅游', applyDate: '2026-08-01', status: '待审批', currentApprover: '组织部', approveDate: '', description: '计划于2026年10月1日至10月7日赴日本旅游', opinion: '' },
  { id: 2, name: '李秀英', dept: '组织部（党校）', type: '干部兼职', title: '申请兼职省高校党建研究会理事', applyDate: '2026-07-25', status: '审批中', currentApprover: '人事处', approveDate: '', description: '拟兼任省高校党建研究会理事（非营利性学术团体）', opinion: '' },
  { id: 3, name: '王志强', dept: '电子信息学院', type: '请销假', title: '申请年休假5天', applyDate: '2026-07-20', status: '已批准', currentApprover: '人事处', approveDate: '2026-07-21', description: '拟于2026年8月15日至8月19日休年休假', opinion: '同意' },
  { id: 4, name: '刘德明', dept: '经济管理学院', type: '培训申报', title: '申请参加教育部高校管理干部培训班', applyDate: '2026-07-18', status: '已批准', currentApprover: '组织部', approveDate: '2026-07-19', description: '参加2026年教育部举办的高校管理干部能力提升培训班（北京）', opinion: '同意参加' },
  { id: 5, name: '陈丽华', dept: '人事处（教师工作部）', type: '干部兼职', title: '申请兼职中国高教学会理事', applyDate: '2026-07-15', status: '已驳回', currentApprover: '组织部', approveDate: '2026-07-17', description: '拟兼任中国高等教育学会理事', opinion: '不符合干部兼职相关规定，不予批准' },
  { id: 6, name: '赵建国', dept: '电子信息学院', type: '因私出国（境）', title: '申请因私前往新加坡探亲', applyDate: '2026-07-10', status: '已批准', currentApprover: '组织部', approveDate: '2026-07-12', description: '计划于2026年9月赴新加坡探亲7天', opinion: '同意' },
  { id: 7, name: '周伟民', dept: '外国语学院', type: '干部基础信息变更', title: '申请更新学历信息', applyDate: '2026-07-08', status: '已批准', currentApprover: '人事处', approveDate: '2026-07-09', description: '已取得博士学位，申请更新学历信息', opinion: '同意' },
  { id: 8, name: '吴玉芬', dept: '外国语学院', type: '请销假', title: '申请病假3天', applyDate: '2026-07-05', status: '待审批', currentApprover: '组织部', approveDate: '', description: '因病需休养3天', opinion: '' },
  { id: 9, name: '钱淑华', dept: '计算机科学与技术学院', type: '证照借出', title: '因公出国借出护照', applyDate: '2026-06-28', status: '已批准', currentApprover: '外事办', approveDate: '2026-06-29', description: '因参加国际学术会议需要借出因私护照', opinion: '同意借出' },
  { id: 10, name: '李国强', dept: '人事处（教师工作部）', type: '培训申报', title: '申请参加省级人事管理培训', applyDate: '2026-06-20', status: '审批中', currentApprover: '组织部', approveDate: '', description: '拟参加省人社厅组织的人事管理业务培训', opinion: '' },
]

const allData = ref([...mockData])

const filteredData = computed(() => {
  let list = allData.value
  if (search.name) list = list.filter(d => d.name.includes(search.name))
  if (search.type) list = list.filter(d => d.type === search.type)
  if (search.status) list = list.filter(d => d.status === search.status)
  return list
})

const tableData = computed(() => filteredData.value.slice((page.current - 1) * page.size, page.current * page.size))

function fetchData() { page.total = filteredData.value.length }
function handleReset() { search.name = ''; search.type = ''; search.status = ''; page.current = 1; fetchData() }
function handleSizeChange() { page.current = 1; fetchData() }

function handleSortChange({ prop, order }) {
  if (!order) { allData.value = [...mockData]; return }
  allData.value.sort((a, b) => {
    const va = a[prop] || ''; const vb = b[prop] || ''
    return order === 'ascending' ? String(va).localeCompare(String(vb), 'zh-CN') : String(vb).localeCompare(String(va), 'zh-CN')
  })
}

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false; editId.value = null
  Object.assign(form, { name: '', dept: '', type: '', title: '', applyDate: '', description: '' })
}

function handleAdd() { dialogTitle.value = '发起审批'; dialogVisible.value = true }

function handleView(row) { detail.value = row; detailVisible.value = true }

function openApprove(row) {
  approveForm.id = row.id
  approveForm.name = row.name
  approveForm.dept = row.dept
  approveForm.title = row.title
  approveForm.description = row.description
  approveForm.opinion = ''
  approveDialogVisible.value = true
}

function handleApprove() {
  const item = allData.value.find(d => d.id === approveForm.id)
  if (item) {
    item.status = '已批准'
    item.approveDate = new Date().toISOString().slice(0, 10)
    item.opinion = approveForm.opinion || '同意'
  }
  ElMessage.success('已批准')
  approveDialogVisible.value = false
  fetchData()
}

function handleReject() {
  const item = allData.value.find(d => d.id === approveForm.id)
  if (item) {
    item.status = '已驳回'
    item.approveDate = new Date().toISOString().slice(0, 10)
    item.opinion = approveForm.opinion || '不予批准'
  }
  ElMessage.warning('已驳回')
  approveDialogVisible.value = false
  fetchData()
}

function handleSubmit() {
  formRef.value.validate((valid) => {
    if (!valid) return
    allData.value.push({
      id: Date.now(), ...form,
      status: '待审批', currentApprover: '组织部', approveDate: '', opinion: ''
    })
    ElMessage.success('审批申请已提交')
    dialogVisible.value = false
    fetchData()
  })
}

function handleDelete(row) {
  ElMessageBox.confirm('确定删除该审批记录吗？', '提示', { type: 'warning' }).then(() => {
    allData.value = allData.value.filter(d => d.id !== row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

function handleExport() {
  showExportDialog(filteredData.value, [
    { prop: 'name', label: '申请人' }, { prop: 'dept', label: '部门' }, { prop: 'type', label: '审批类型' },
    { prop: 'title', label: '事项标题' }, { prop: 'applyDate', label: '申请日期' }, { prop: 'status', label: '状态' },
    { prop: 'currentApprover', label: '当前审批人' }, { prop: 'approveDate', label: '审批完成日期' }
  ], '审批事项')
}

fetchData()
</script>
