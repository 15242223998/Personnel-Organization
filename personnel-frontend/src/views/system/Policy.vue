<template>
  <div>
    <div class="page-header">政策法规管理</div>

    <div class="search-bar">
      <span class="label">标题：</span>
      <el-input v-model="search.title" placeholder="请输入标题" size="default" style="width:180px" clearable />
      <span class="label">类别：</span>
      <el-select v-model="search.category" placeholder="请选择" size="default" style="width:140px" clearable>
        <el-option label="干部选拔任用" value="干部选拔任用" />
        <el-option label="干部教育培训" value="干部教育培训" />
        <el-option label="干部考核管理" value="干部考核管理" />
        <el-option label="干部监督管理" value="干部监督管理" />
        <el-option label="干部档案管理" value="干部档案管理" />
        <el-option label="干部待遇与退出" value="干部待遇与退出" />
        <el-option label="综合政策" value="综合政策" />
      </el-select>
      <span class="label">发文单位：</span>
      <el-input v-model="search.issuer" placeholder="请输入发文单位" size="default" style="width:140px" clearable />
      <el-button type="primary" @click="fetchData"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" size="small" @click="handleAdd"><el-icon><Plus /></el-icon> 新增法规</el-button>
      <el-button size="small" @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" @sort-change="handleSortChange">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="title" label="标题" min-width="280" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="category" label="类别" width="130" align="center" sortable="custom">
          <template #default="{ row }">
            <el-tag size="small">{{ row.category }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="issuer" label="发文单位" min-width="180" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="docNo" label="文号" min-width="160" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="issueDate" label="发布日期" width="110" align="center" sortable="custom" />
        <el-table-column prop="effectiveDate" label="施行日期" width="110" align="center" sortable="custom" />
        <el-table-column prop="status" label="状态" width="100" align="center" sortable="custom">
          <template #default="{ row }">
            <el-tag :type="row.status === '现行有效' ? 'success' : 'info'" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="handleEdit(row)">编辑</span>
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

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="700px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="法规标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入法规标题" />
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="类别" prop="category">
              <el-select v-model="form.category" style="width:100%">
                <el-option label="干部选拔任用" value="干部选拔任用" />
                <el-option label="干部教育培训" value="干部教育培训" />
                <el-option label="干部考核管理" value="干部考核管理" />
                <el-option label="干部监督管理" value="干部监督管理" />
                <el-option label="干部档案管理" value="干部档案管理" />
                <el-option label="干部待遇与退出" value="干部待遇与退出" />
                <el-option label="综合政策" value="综合政策" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="发文单位" prop="issuer">
              <el-input v-model="form.issuer" placeholder="请输入发文单位" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="文号" prop="docNo">
          <el-input v-model="form.docNo" placeholder="如：中办发〔2019〕3号" />
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="发布日期" prop="issueDate">
              <el-date-picker v-model="form.issueDate" type="date" placeholder="选择日期" style="width:100%" value-format="YYYY-MM-DD" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="施行日期" prop="effectiveDate">
              <el-date-picker v-model="form.effectiveDate" type="date" placeholder="选择日期" style="width:100%" value-format="YYYY-MM-DD" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="现行有效">现行有效</el-radio>
            <el-radio label="已废止">已废止</el-radio>
            <el-radio label="已修订">已修订</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="内容摘要" prop="summary">
          <el-input v-model="form.summary" type="textarea" :rows="3" placeholder="请输入法规内容摘要" />
        </el-form-item>
        <el-form-item label="全文内容" prop="content">
          <el-input v-model="form.content" type="textarea" :rows="6" placeholder="请输入法规全文" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="法规详情" v-model="detailVisible" width="750px">
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="法规标题" :span="2"><strong>{{ detail.title }}</strong></el-descriptions-item>
        <el-descriptions-item label="类别"><el-tag size="small">{{ detail.category }}</el-tag></el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="detail.status === '现行有效' ? 'success' : 'info'" size="small">{{ detail.status }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="发文单位">{{ detail.issuer }}</el-descriptions-item>
        <el-descriptions-item label="文号">{{ detail.docNo }}</el-descriptions-item>
        <el-descriptions-item label="发布日期">{{ detail.issueDate }}</el-descriptions-item>
        <el-descriptions-item label="施行日期">{{ detail.effectiveDate }}</el-descriptions-item>
        <el-descriptions-item label="内容摘要" :span="2">{{ detail.summary }}</el-descriptions-item>
        <el-descriptions-item label="全文内容" :span="2"><div style="white-space:pre-wrap">{{ detail.content }}</div></el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage, ElMessageBox } from 'element-plus'

const search = reactive({ title: '', category: '', issuer: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const detailVisible = ref(false)
const dialogTitle = ref('')
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)
const detail = ref({})

const form = reactive({
  title: '', category: '', issuer: '', docNo: '',
  issueDate: '', effectiveDate: '', status: '现行有效', summary: '', content: ''
})

const rules = {
  title: [{ required: true, message: '请输入法规标题', trigger: 'blur' }],
  category: [{ required: true, message: '请选择类别', trigger: 'change' }],
  issuer: [{ required: true, message: '请输入发文单位', trigger: 'blur' }],
  issueDate: [{ required: true, message: '请选择发布日期', trigger: 'change' }],
  summary: [{ required: true, message: '请输入内容摘要', trigger: 'blur' }],
}

const mockData = [
  { id: 1, title: '党政领导干部选拔任用工作条例', category: '干部选拔任用', issuer: '中共中央', docNo: '中发〔2019〕8号', issueDate: '2019-03-03', effectiveDate: '2019-03-03', status: '现行有效', summary: '规范党政领导干部选拔任用工作，建立健全科学的选拔任用机制，防止和纠正选人用人上的不正之风', content: '第一章 总则\n第一条 为了坚持和加强党的全面领导，深入贯彻新时代党的组织路线和干部工作方针政策...' },
  { id: 2, title: '推进领导干部能上能下规定', category: '干部选拔任用', issuer: '中共中央办公厅', docNo: '中办发〔2022〕40号', issueDate: '2022-09-08', effectiveDate: '2022-09-08', status: '现行有效', summary: '健全能上能下的选人用人机制，推动形成能者上、优者奖、庸者下、劣者汰的用人导向', content: '第一条 为了全面推进党的政治建设、思想建设、组织建设、作风建设、纪律建设...' },
  { id: 3, title: '干部教育培训工作条例', category: '干部教育培训', issuer: '中共中央', docNo: '中发〔2015〕8号', issueDate: '2015-10-14', effectiveDate: '2015-10-14', status: '现行有效', summary: '推进干部教育培训工作科学化、制度化、规范化，培养造就高素质干部队伍', content: '第一章 总则\n第一条 为了推进干部教育培训工作科学化、制度化、规范化...' },
  { id: 4, title: '领导干部报告个人有关事项规定', category: '干部监督管理', issuer: '中共中央办公厅、国务院办公厅', docNo: '中办发〔2017〕12号', issueDate: '2017-04-19', effectiveDate: '2017-04-19', status: '现行有效', summary: '加强对领导干部的管理和监督，促进领导干部廉洁从政', content: '第一条 为加强对领导干部的管理和监督...' },
  { id: 5, title: '事业单位领导人员管理规定', category: '干部选拔任用', issuer: '中共中央办公厅', docNo: '中办发〔2022〕6号', issueDate: '2022-01-14', effectiveDate: '2022-01-14', status: '现行有效', summary: '加强和改进事业单位领导人员管理，健全选拔任用机制和管理监督机制', content: '第一章 总则\n第一条 为了加强和改进事业单位领导人员管理...' },
  { id: 6, title: '党政领导干部考核工作条例', category: '干部考核管理', issuer: '中共中央办公厅', docNo: '中办发〔2019〕9号', issueDate: '2019-04-12', effectiveDate: '2019-04-12', status: '现行有效', summary: '坚持严管和厚爱结合、激励和约束并重，完善干部考核评价机制', content: '第一章 总则\n第一条 为了坚持和加强党的全面领导...' },
  { id: 7, title: '干部人事档案工作条例', category: '干部档案管理', issuer: '中共中央办公厅', docNo: '中办发〔2018〕60号', issueDate: '2018-11-20', effectiveDate: '2018-11-20', status: '现行有效', summary: '全面规范干部人事档案的建立、接收、保管、转递和利用工作', content: '第一章 总则\n第一条 为了贯彻新时代党的组织路线...' },
  { id: 8, title: '关于实行党政领导干部问责的暂行规定', category: '干部监督管理', issuer: '中共中央办公厅、国务院办公厅', docNo: '中办发〔2009〕25号', issueDate: '2009-06-30', effectiveDate: '2009-06-30', status: '已修订', summary: '加强对党政领导干部的管理和监督，增强责任意识和大局意识', content: '第一条 为加强对党政领导干部的管理和监督...' },
  { id: 9, title: '高等学校领导人员管理暂行办法', category: '综合政策', issuer: '中组部、教育部', docNo: '中组发〔2017〕2号', issueDate: '2017-06-21', effectiveDate: '2017-06-21', status: '现行有效', summary: '加强和改进高等学校领导人员管理，推进中国特色现代大学制度建设', content: '第一章 总则\n第一条 为加强和改进高等学校领导人员管理...' },
  { id: 10, title: '干部兼职管理规定', category: '干部监督管理', issuer: '中组部', docNo: '中组发〔2013〕18号', issueDate: '2013-10-19', effectiveDate: '2013-10-19', status: '现行有效', summary: '规范党政领导干部在企业兼职（任职）行为', content: '第一条 为规范党政领导干部在企业兼职（任职）...' },
  { id: 11, title: '关于进一步激励广大干部新时代新担当新作为的意见', category: '综合政策', issuer: '中共中央办公厅', docNo: '中办发〔2018〕30号', issueDate: '2018-05-20', effectiveDate: '2018-05-20', status: '现行有效', summary: '建立激励机制和容错纠错机制，激励干部担当作为', content: '为深入贯彻习近平新时代中国特色社会主义思想和党的十九大精神...' },
  { id: 12, title: '公务员职务与职级并行规定', category: '干部待遇与退出', issuer: '中共中央办公厅', docNo: '中办发〔2019〕21号', issueDate: '2019-03-19', effectiveDate: '2019-06-01', status: '现行有效', summary: '推行公务员职务与职级并行、职级与待遇挂钩制度', content: '第一条 为了深化公务员分类改革...' },
]

const allData = ref([...mockData])

const filteredData = computed(() => {
  let list = allData.value
  if (search.title) list = list.filter(d => d.title.includes(search.title))
  if (search.category) list = list.filter(d => d.category === search.category)
  if (search.issuer) list = list.filter(d => d.issuer.includes(search.issuer))
  return list
})

const tableData = computed(() => filteredData.value.slice((page.current - 1) * page.size, page.current * page.size))

function fetchData() { page.total = filteredData.value.length }
function handleReset() { search.title = ''; search.category = ''; search.issuer = ''; page.current = 1; fetchData() }
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
  Object.assign(form, { title: '', category: '', issuer: '', docNo: '', issueDate: '', effectiveDate: '', status: '现行有效', summary: '', content: '' })
}

function handleAdd() { dialogTitle.value = '新增政策法规'; dialogVisible.value = true }

function handleEdit(row) {
  dialogTitle.value = '编辑政策法规'; isEdit.value = true; editId.value = row.id
  Object.assign(form, row)
  dialogVisible.value = true
}

function handleView(row) { detail.value = row; detailVisible.value = true }

function handleSubmit() {
  formRef.value.validate((valid) => {
    if (!valid) return
    if (isEdit.value) {
      const item = allData.value.find(d => d.id === editId.value)
      if (item) Object.assign(item, { ...form })
      ElMessage.success('更新成功')
    } else {
      allData.value.push({ id: Date.now(), ...form })
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    fetchData()
  })
}

function handleDelete(row) {
  ElMessageBox.confirm('确定删除该法规记录吗？', '提示', { type: 'warning' }).then(() => {
    allData.value = allData.value.filter(d => d.id !== row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

function handleExport() {
  showExportDialog(filteredData.value, [
    { prop: 'title', label: '标题' }, { prop: 'category', label: '类别' }, { prop: 'issuer', label: '发文单位' },
    { prop: 'docNo', label: '文号' }, { prop: 'issueDate', label: '发布日期' }, { prop: 'effectiveDate', label: '施行日期' },
    { prop: 'status', label: '状态' }, { prop: 'summary', label: '内容摘要' }
  ], '政策法规')
}

fetchData()
</script>
