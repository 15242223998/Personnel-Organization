<template>
  <div>
    <div class="page-header">干部考察评价管理</div>

    <div class="search-bar">
      <span class="label">姓名：</span>
      <el-input v-model="search.name" placeholder="请输入姓名" size="default" style="width:140px" clearable />
      <span class="label">考察类型：</span>
      <el-select v-model="search.type" placeholder="请选择" size="default" style="width:140px" clearable>
        <el-option label="年度考察" value="年度考察" />
        <el-option label="专项考察" value="专项考察" />
        <el-option label="试用期考察" value="试用期考察" />
        <el-option label="机构考察" value="机构考察" />
        <el-option label="任期考察" value="任期考察" />
      </el-select>
      <span class="label">考察结果：</span>
      <el-select v-model="search.result" placeholder="请选择" size="default" style="width:120px" clearable>
        <el-option label="优秀" value="优秀" />
        <el-option label="称职" value="称职" />
        <el-option label="基本称职" value="基本称职" />
        <el-option label="不称职" value="不称职" />
      </el-select>
      <el-button type="primary" @click="fetchData"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon> 新增考察</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
        <el-table-column prop="dept" label="所在部门" min-width="160" show-overflow-tooltip sortable />
        <el-table-column prop="position" label="职务" min-width="140" show-overflow-tooltip sortable />
        <el-table-column prop="type" label="考察类型" width="110" align="center" sortable />
        <el-table-column prop="evaluateDate" label="考察日期" width="110" align="center" sortable />
        <el-table-column prop="participants" label="参评人数" width="90" align="center" sortable />
        <el-table-column prop="result" label="考察结果" width="110" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="getResultType(row.result)" size="small">{{ row.result }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="evaluator" label="考察组" min-width="130" show-overflow-tooltip sortable />
        <el-table-column prop="reportSummary" label="考察意见摘要" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="160" align="center" fixed="right">
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
        <el-form-item label="被考察人" prop="name">
          <el-input v-model="form.name" placeholder="请输入被考察人姓名" />
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="所在部门" prop="dept">
              <el-input v-model="form.dept" placeholder="请输入部门" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="职务" prop="position">
              <el-input v-model="form.position" placeholder="请输入职务" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="考察类型" prop="type">
              <el-select v-model="form.type" style="width:100%">
                <el-option label="年度考察" value="年度考察" />
                <el-option label="专项考察" value="专项考察" />
                <el-option label="试用期考察" value="试用期考察" />
                <el-option label="机构考察" value="机构考察" />
                <el-option label="任期考察" value="任期考察" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="考察日期" prop="evaluateDate">
              <el-date-picker v-model="form.evaluateDate" type="date" placeholder="选择日期" style="width:100%" value-format="YYYY-MM-DD" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="8">
            <el-form-item label="参评人数" prop="participants">
              <el-input-number v-model="form.participants" :min="1" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="考察组" prop="evaluator">
              <el-input v-model="form.evaluator" placeholder="考察组名称" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="考察结果" prop="result">
              <el-select v-model="form.result" style="width:100%">
                <el-option label="优秀" value="优秀" />
                <el-option label="称职" value="称职" />
                <el-option label="基本称职" value="基本称职" />
                <el-option label="不称职" value="不称职" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="德能评价" prop="moralityScore">
          <el-input v-model="form.moralityScore" placeholder="思想政治、道德品质方面评价" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="能力评价" prop="abilityScore">
          <el-input v-model="form.abilityScore" placeholder="业务能力、领导能力、执行力方面评价" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="勤勉评价" prop="diligenceScore">
          <el-input v-model="form.diligenceScore" placeholder="工作态度、敬业精神方面评价" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="业绩评价" prop="performanceScore">
          <el-input v-model="form.performanceScore" placeholder="工作实绩、目标完成方面评价" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="廉洁评价" prop="integrityScore">
          <el-input v-model="form.integrityScore" placeholder="廉洁自律、遵纪守法方面评价" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="综评意见" prop="reportSummary">
          <el-input v-model="form.reportSummary" placeholder="考察组综合评价意见" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="考察详情" v-model="detailVisible" width="700px">
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="姓名">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="所在部门">{{ detail.dept }}</el-descriptions-item>
        <el-descriptions-item label="职务">{{ detail.position }}</el-descriptions-item>
        <el-descriptions-item label="考察类型">{{ detail.type }}</el-descriptions-item>
        <el-descriptions-item label="考察日期">{{ detail.evaluateDate }}</el-descriptions-item>
        <el-descriptions-item label="考察结果">
          <el-tag :type="getResultType(detail.result)" size="small">{{ detail.result }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="参评人数">{{ detail.participants }}</el-descriptions-item>
        <el-descriptions-item label="考察组">{{ detail.evaluator }}</el-descriptions-item>
        <el-descriptions-item label="德能评价" :span="2">{{ detail.moralityScore }}</el-descriptions-item>
        <el-descriptions-item label="能力评价" :span="2">{{ detail.abilityScore }}</el-descriptions-item>
        <el-descriptions-item label="勤勉评价" :span="2">{{ detail.diligenceScore }}</el-descriptions-item>
        <el-descriptions-item label="业绩评价" :span="2">{{ detail.performanceScore }}</el-descriptions-item>
        <el-descriptions-item label="廉洁评价" :span="2">{{ detail.integrityScore }}</el-descriptions-item>
        <el-descriptions-item label="综评意见" :span="2">{{ detail.reportSummary }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage, ElMessageBox } from 'element-plus'

const search = reactive({ name: '', type: '', result: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const detailVisible = ref(false)
const dialogTitle = ref('')
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)
const detail = ref({})

const form = reactive({
  name: '', dept: '', position: '', type: '', evaluateDate: '', participants: 30,
  evaluator: '', result: '', moralityScore: '', abilityScore: '', diligenceScore: '',
  performanceScore: '', integrityScore: '', reportSummary: ''
})

const rules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  dept: [{ required: true, message: '请输入部门', trigger: 'blur' }],
  type: [{ required: true, message: '请选择考察类型', trigger: 'change' }],
  evaluateDate: [{ required: true, message: '请选择考察日期', trigger: 'change' }],
  result: [{ required: true, message: '请选择考察结果', trigger: 'change' }],
}

function getResultType(result) {
  if (result === '优秀') return 'success'
  if (result === '称职') return ''
  if (result === '基本称职') return 'warning'
  if (result === '不称职') return 'danger'
  return 'info'
}

const mockData = [
  { id: 1, name: '张建国', dept: '机械工程学院', position: '院长', type: '年度考察', evaluateDate: '2026-07-20', participants: 45, result: '优秀', evaluator: '组织部考察一组', reportSummary: '思想政治素质好，工作能力强，业绩突出，群众公认度高', moralityScore: '政治立场坚定，大局意识强', abilityScore: '组织领导能力强，善于处理复杂问题', diligenceScore: '工作勤奋踏实，责任心强', performanceScore: '年度目标全面完成，学科建设成效显著', integrityScore: '严格遵守廉洁自律规定' },
  { id: 2, name: '李永强', dept: '机械工程学院', position: '党委书记', type: '年度考察', evaluateDate: '2026-07-20', participants: 45, result: '称职', evaluator: '组织部考察一组', reportSummary: '党务工作扎实，但创新意识有待加强', moralityScore: '政治素质过硬', abilityScore: '党务工作能力较好', diligenceScore: '工作认真负责', performanceScore: '党建目标基本完成', integrityScore: '廉洁自律情况良好' },
  { id: 3, name: '王志强', dept: '电子信息学院', position: '院长', type: '专项考察', evaluateDate: '2026-06-15', participants: 52, result: '优秀', evaluator: '组织部考察二组', reportSummary: '科研能力强，成果丰硕', moralityScore: '思想政治表现好', abilityScore: '科研创新能力突出，学科带头人', diligenceScore: '工作投入度高', performanceScore: '科研成果显著，获批国家重大项目', integrityScore: '严格遵纪守法' },
  { id: 4, name: '刘德明', dept: '经济管理学院', position: '院长', type: '试用期考察', evaluateDate: '2026-05-10', participants: 38, result: '称职', evaluator: '组织部考察一组', reportSummary: '试用期表现达标，建议正式任职', moralityScore: '政治合格', abilityScore: '管理能力稳步提升', diligenceScore: '工作态度端正', performanceScore: '试用期工作目标完成', integrityScore: '无违纪违规行为' },
  { id: 5, name: '陈丽华', dept: '人事处（教师工作部）', position: '处长', type: '机构考察', evaluateDate: '2026-04-22', participants: 25, result: '优秀', evaluator: '组织部考察三组', reportSummary: '人事管理规范高效', moralityScore: '政治原则性强', abilityScore: '人事管理经验丰富', diligenceScore: '勤奋敬业', performanceScore: '人才引进和培养工作成效显著', integrityScore: '廉洁从政' },
  { id: 6, name: '赵建国', dept: '电子信息学院', position: '党委书记', type: '任期考察', evaluateDate: '2026-03-18', participants: 52, result: '基本称职', evaluator: '组织部考察二组', reportSummary: '党建工作有较大提升空间', moralityScore: '政治立场基本正确', abilityScore: '党务工作能力一般', diligenceScore: '工作投入度不足', performanceScore: '部分党建目标未完成', integrityScore: '基本遵守纪律' },
  { id: 7, name: '周伟民', dept: '外国语学院', position: '院长', type: '年度考察', evaluateDate: '2026-07-15', participants: 32, result: '称职', evaluator: '组织部考察一组', reportSummary: '常规工作完成尚可', moralityScore: '政治素质较好', abilityScore: '外语学科建设有一定思路', diligenceScore: '工作态度认真', performanceScore: '年度目标基本达成', integrityScore: '廉洁自律' },
  { id: 8, name: '钱淑华', dept: '计算机科学与技术学院', position: '党委书记', type: '专项考察', evaluateDate: '2026-07-05', participants: 40, result: '优秀', evaluator: '组织部考察三组', reportSummary: '党建创新工作走在前列', moralityScore: '政治素质突出', abilityScore: '党建创新能力强', diligenceScore: '工作勤勉', performanceScore: '党建品牌建设成效显著', integrityScore: '严于律己' },
]

const allData = ref([...mockData])

const filteredData = computed(() => {
  let list = allData.value
  if (search.name) list = list.filter(d => d.name.includes(search.name))
  if (search.type) list = list.filter(d => d.type === search.type)
  if (search.result) list = list.filter(d => d.result === search.result)
  return list
})

const tableData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

function fetchData() { page.total = filteredData.value.length }
function handleReset() { search.name = ''; search.type = ''; search.result = ''; page.current = 1; fetchData() }
function handleSizeChange() { page.current = 1; fetchData() }

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false; editId.value = null
  Object.assign(form, { name: '', dept: '', position: '', type: '', evaluateDate: '', participants: 30, evaluator: '', result: '', moralityScore: '', abilityScore: '', diligenceScore: '', performanceScore: '', integrityScore: '', reportSummary: '' })
}

function handleAdd() { dialogTitle.value = '新增考察评价'; dialogVisible.value = true }
function handleEdit(row) {
  dialogTitle.value = '编辑考察评价'; isEdit.value = true; editId.value = row.id
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
  ElMessageBox.confirm('确定删除该考察记录吗？', '提示', { type: 'warning' }).then(() => {
    allData.value = allData.value.filter(d => d.id !== row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

function handleExport() {
  showExportDialog(filteredData.value, [
    { prop: 'name', label: '姓名' }, { prop: 'dept', label: '所在部门' }, { prop: 'position', label: '职务' },
    { prop: 'type', label: '考察类型' }, { prop: 'evaluateDate', label: '考察日期' }, { prop: 'participants', label: '参评人数' },
    { prop: 'result', label: '考察结果' }, { prop: 'evaluator', label: '考察组' }, { prop: 'reportSummary', label: '考察意见摘要' }
  ], '干部考察评价')
}

fetchData()
</script>
