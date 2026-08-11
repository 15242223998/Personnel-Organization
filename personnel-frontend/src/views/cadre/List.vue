<template>
  <div>
    <!-- 功能标题栏 -->
    <div class="page-header">干部信息管理</div>

    <!-- 查询栏 -->
    <div class="search-bar">
      <el-form :inline="true" :model="queryForm" size="default">
        <el-form-item label="姓名">
          <el-input v-model="queryForm.name" placeholder="输入姓名" style="width:120px" clearable />
        </el-form-item>
        <el-form-item label="所在机构">
          <el-select v-model="queryForm.deptId" placeholder="请选择" style="width:150px" clearable>
            <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="干部状态">
          <el-select v-model="queryForm.cadreStatus" placeholder="全部" style="width:110px" clearable>
            <el-option label="在职" value="ON_JOB" />
            <el-option label="离退休" value="RETIRED" />
            <el-option label="已调出" value="TRANSFERRED" />
            <el-option label="已辞职" value="RESIGNED" />
          </el-select>
        </el-form-item>
        <el-form-item label="职务层次">
          <el-select v-model="queryForm.positionLevel" placeholder="全部" style="width:110px" clearable>
            <el-option label="校级" value="校级" />
            <el-option label="处级" value="处级" />
            <el-option label="科级" value="科级" />
          </el-select>
        </el-form-item>
        <el-form-item label="性别">
          <el-select v-model="queryForm.gender" placeholder="全部" style="width:90px" clearable>
            <el-option label="男" :value="1" />
            <el-option label="女" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon> 新增干部</el-button>
      <el-button @click="handleImport"><el-icon><Upload /></el-icon> 批量导入</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出Excel</el-button>
      <el-button type="success" @click="handlePrint"><el-icon><Printer /></el-icon> 打印名册</el-button>
    </div>

    <!-- 表格 -->
    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading" @sort-change="handleSortChange">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="80" align="center" sortable="custom" />
        <el-table-column prop="genderText" label="性别" width="55" align="center" sortable="custom" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" sortable="custom" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="90" align="center" sortable="custom" />
        <el-table-column prop="education" label="学历(全日制)" width="110" align="center" sortable="custom" />
        <el-table-column prop="deptName" label="所属机构" width="150" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="position" label="职务" width="130" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="positionLevel" label="职务层次" width="85" align="center" sortable="custom" />
        <el-table-column prop="rankName" label="职级" width="100" align="center" sortable="custom" />
        <el-table-column prop="positionStartDate" label="任现职时间" width="100" align="center" sortable="custom" />
        <el-table-column prop="cadreStatus" label="状态" width="80" align="center" sortable="custom">
          <template #default="{row}">
            <el-tag :type="row.cadreStatus==='ON_JOB'?'success':(row.cadreStatus==='RETIRED'?'info':'danger')" size="small">
              {{ statusMap[row.cadreStatus] }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{row}">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <span class="link-blue" style="margin:0 8px" @click="handleEdit(row)">编辑</span>
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50, 100]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        background
        small
        @current-change="fetchData"
        @size-change="handleSizeChange"
      />
    </div>

    <!-- 批量导入对话框 -->
    <el-dialog v-model="importDialogVisible" title="批量导入干部信息" width="700px" destroy-on-close @closed="handleCancelImport">
      <div style="margin-bottom:16px">
        <el-alert title="请选择Excel文件(.xlsx)，第一行为表头，表头需与模板一致" type="info" :closable="false" show-icon />
      </div>
      <el-upload
        ref="fileInputRef"
        :auto-upload="false"
        :limit="1"
        accept=".xlsx,.xls"
        :on-change="handleFileChange"
        :on-remove="() => { importPreviewData = [] }"
      >
        <el-button type="primary"><el-icon><Upload /></el-icon> 选择Excel文件</el-button>
      </el-upload>
      <el-table v-if="importPreviewData.length > 0" :data="importPreviewData" border size="small" style="margin-top:16px" max-height="350">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="genderText" label="性别" width="60" align="center" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="90" align="center" />
        <el-table-column prop="education" label="学历" width="110" align="center" />
        <el-table-column prop="deptName" label="所属机构" width="150" show-overflow-tooltip />
        <el-table-column prop="position" label="职务" min-width="120" show-overflow-tooltip />
      </el-table>
      <div v-if="importPreviewData.length > 0" style="margin-top:12px;color:#666;text-align:center">
        共解析 <b>{{ importPreviewData.length }}</b> 条记录，确认导入后数据将添加到列表顶部
      </div>
      <template #footer>
        <el-button @click="handleCancelImport">取消</el-button>
        <el-button type="primary" :disabled="importPreviewData.length === 0" :loading="importing" @click="confirmImport">
          确认导入
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, Upload, Download, Printer } from '@element-plus/icons-vue'
import { importExcel, mapImportData } from '@/utils/excel'
import { showExportDialog } from '@/utils/export-store'

const router = useRouter()
const loading = ref(false)
const tableData = ref([])
const importDialogVisible = ref(false)
const importFile = ref(null)
const importPreviewData = ref([])
const importing = ref(false)
const fileInputRef = ref(null)
const deptOptions = ref([
  { id: 1, deptName: '党委办公室' },
  { id: 2, deptName: '机械工程学院' },
  { id: 3, deptName: '电气工程学院' },
  { id: 4, deptName: '信息科学与工程学院' },
  { id: 5, deptName: '经济管理学院' },
  { id: 6, deptName: '人事处' },
  { id: 7, deptName: '学生工作处' }
])

const queryForm = reactive({
  name: '', deptId: null, cadreStatus: '', positionLevel: '', gender: null
})
const page = reactive({ current: 1, size: 10, total: 328 })

const statusMap = { ON_JOB: '在职', RETIRED: '离退休', TRANSFERRED: '已调出', RESIGNED: '已辞职' }

const surnames = ['张','李','王','刘','陈','杨','赵','黄','周','吴','徐','孙','胡','朱','高','林','何','郭','马','罗']
const givenNames = ['伟','芳','娜','敏','静','丽','强','磊','军','洋','勇','艳','杰','娟','涛','明','超','秀英','霞','平','刚','桂英','建国','建军','志强','丽娟','丽娟','晓东','晓红','雪梅']
const depts = [
  { id:1, deptName:'党委办公室、校长办公室' },
  { id:2, deptName:'机械工程学院' },
  { id:3, deptName:'电气工程学院' },
  { id:4, deptName:'信息科学与工程学院' },
  { id:5, deptName:'经济管理学院' },
  { id:6, deptName:'人事处（教师工作部）' },
  { id:7, deptName:'学生工作处' },
  { id:8, deptName:'教务处' },
  { id:9, deptName:'科研处' },
  { id:10, deptName:'财务处' },
  { id:11, deptName:'组织部（党校）' },
  { id:12, deptName:'宣传部（新闻中心）' },
  { id:13, deptName:'土木工程学院' },
  { id:14, deptName:'材料科学与工程学院' },
  { id:15, deptName:'自动化学院' },
  { id:16, deptName:'计算机学院' }
]
const positions = {
  '校级': ['党委书记','校长','党委副书记','副校长','纪委书记'],
  '处级': ['处长','部长','院长','副处长','副部长','副院长','副书记'],
  '科级': ['科长','系主任','主任','副科长','副主任','副系主任']
}
const ranks = ['教授二级','教授三级','教授四级','副教授五级','副教授六级','副教授七级','讲师八级','讲师九级','讲师十级','助教十一级','研究员','副研究员']
const educations = ['博士研究生','硕士研究生','本科','大专']
const polStatuses = ['中共党员','中共党员','中共党员','民主党派','群众']

function generateMockData() {
  const data = []
  const statuses = ['ON_JOB','ON_JOB','ON_JOB','ON_JOB','RETIRED','TRANSFERRED','RESIGNED']
  for (let i = 1; i <= page.total; i++) {
    const surname = surnames[Math.floor(Math.random() * surnames.length)]
    const givenName = givenNames[Math.floor(Math.random() * givenNames.length)]
    const gender = Math.random() > 0.4 ? 1 : 2
    const levels = ['校级','处级','科级']
    const level = levels[Math.floor(Math.random() * (i < 10 ? 1 : 3))]
    const posList = positions[level]
    const dept = depts[Math.floor(Math.random() * depts.length)]
    const year = 1960 + Math.floor(Math.random() * 40)
    const month = String(Math.floor(Math.random() * 12) + 1).padStart(2, '0')
    const day = String(Math.floor(Math.random() * 28) + 1).padStart(2, '0')
    const posYear = 2015 + Math.floor(Math.random() * 10)
    const status = i < 300 ? statuses[Math.floor(Math.random() * 4)] : statuses[Math.floor(Math.random() * statuses.length)]
    data.push({
      id: i,
      name: surname + givenName,
      gender,
      genderText: gender === 1 ? '男' : '女',
      birthDate: `${year}-${month}-${day}`,
      politicalStatus: polStatuses[Math.floor(Math.random() * polStatuses.length)],
      education: educations[Math.floor(Math.random() * educations.length)],
      deptId: dept.id,
      deptName: dept.deptName,
      position: posList[Math.floor(Math.random() * posList.length)],
      positionLevel: level,
      rankName: ranks[Math.floor(Math.random() * ranks.length)],
      positionStartDate: `${posYear}-${String(Math.floor(Math.random()*12)+1).padStart(2,'0')}-01`,
      cadreStatus: status
    })
  }
  return data
}

const allMockData = generateMockData()

const sortInfo = reactive({ prop: '', order: '' })

function applySort(data) {
  if (!sortInfo.prop || !sortInfo.order) return data
  const sorted = [...data]
  const dir = sortInfo.order === 'ascending' ? 1 : -1
  sorted.sort((a, b) => {
    let va = a[sortInfo.prop]
    let vb = b[sortInfo.prop]
    if (va == null) va = ''
    if (vb == null) vb = ''
    if (typeof va === 'number' && typeof vb === 'number') return (va - vb) * dir
    return String(va).localeCompare(String(vb), 'zh-CN') * dir
  })
  return sorted
}

function fetchData() {
  loading.value = true
  setTimeout(() => {
    let data = [...allMockData]
    if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
    if (queryForm.deptId) data = data.filter(d => d.deptId === queryForm.deptId)
    if (queryForm.cadreStatus) data = data.filter(d => d.cadreStatus === queryForm.cadreStatus)
    if (queryForm.positionLevel) data = data.filter(d => d.positionLevel === queryForm.positionLevel)
    if (queryForm.gender) data = data.filter(d => d.gender === queryForm.gender)
    data = applySort(data)
    page.total = data.length
    const start = (page.current - 1) * page.size
    tableData.value = data.slice(start, start + page.size)
    loading.value = false
  }, 300)
}
function handleSortChange({ prop, order }) {
  sortInfo.prop = prop || ''
  sortInfo.order = order || ''
  fetchData()
}
function handleSizeChange() {
  page.current = 1
  fetchData()
}
function handleSearch() { page.current = 1; fetchData() }
function handleReset() { Object.assign(queryForm, {name:'',deptId:null,cadreStatus:'',positionLevel:'',gender:null}); page.current=1; sortInfo.prop=''; sortInfo.order=''; fetchData() }
function handleAdd() { router.push('/cadre/new') }
function handleView(row) { router.push(`/cadre/${row.id}`) }
function handleEdit(row) { router.push(`/cadre/${row.id}?edit=1`) }
function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除干部"${row.name}"吗？`, '提示', { type:'warning' })
    .then(() => { ElMessage.success('删除成功'); fetchData() })
    .catch(() => {})
}
function handleImport() { importDialogVisible.value = true }

async function handleFileChange(file) {
  importFile.value = file
  try {
    const raw = await importExcel(file.raw)
    const mapped = mapImportData(raw, {
      '姓名': 'name',
      '性别': 'genderText',
      '出生年月': 'birthDate',
      '政治面貌': 'politicalStatus',
      '学历(全日制)': 'education',
      '所属机构': 'deptName',
      '职务': 'position',
      '职务层次': 'positionLevel',
      '职级': 'rankName'
    })
    importPreviewData.value = mapped
  } catch (e) {
    ElMessage.error(e.message)
    importPreviewData.value = []
  }
}

function confirmImport() {
  if (importPreviewData.value.length === 0) {
    ElMessage.warning('没有可导入的数据')
    return
  }
  importing.value = true
  setTimeout(() => {
    const maxId = allMockData.reduce((max, d) => Math.max(max, d.id), 0)
    importPreviewData.value.forEach((item, idx) => {
      const dept = depts.find(d => d.deptName === item.deptName) || depts[0]
      allMockData.unshift({
        id: maxId + idx + 1,
        name: item.name || '未填写',
        gender: item.genderText === '女' ? 2 : 1,
        genderText: item.genderText === '女' ? '女' : '男',
        birthDate: item.birthDate || '',
        politicalStatus: item.politicalStatus || '群众',
        education: item.education || '本科',
        deptId: dept.id,
        deptName: dept.deptName,
        position: item.position || '',
        positionLevel: item.positionLevel || '',
        rankName: item.rankName || '',
        positionStartDate: item.positionStartDate || '',
        cadreStatus: 'ON_JOB'
      })
    })
    ElMessage.success(`成功导入 ${importPreviewData.value.length} 条记录`)
    importDialogVisible.value = false
    importPreviewData.value = []
    importFile.value = null
    importing.value = false
    fetchData()
  }, 500)
}

function handleCancelImport() {
  importDialogVisible.value = false
  importPreviewData.value = []
  importFile.value = null
}

function handleExport() {
  let data = [...allMockData]
  if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
  if (queryForm.deptId) data = data.filter(d => d.deptId === queryForm.deptId)
  if (queryForm.cadreStatus) data = data.filter(d => d.cadreStatus === queryForm.cadreStatus)
  if (queryForm.positionLevel) data = data.filter(d => d.positionLevel === queryForm.positionLevel)
  if (queryForm.gender) data = data.filter(d => d.gender === queryForm.gender)
  data = applySort(data)
  showExportDialog(data, [
    { prop: 'name', label: '姓名' },
    { prop: 'genderText', label: '性别' },
    { prop: 'birthDate', label: '出生年月' },
    { prop: 'politicalStatus', label: '政治面貌' },
    { prop: 'education', label: '学历(全日制)' },
    { prop: 'deptName', label: '所属机构' },
    { prop: 'position', label: '职务' },
    { prop: 'positionLevel', label: '职务层次' },
    { prop: 'rankName', label: '职级' },
    { prop: 'positionStartDate', label: '任现职时间' },
    { prop: 'cadreStatus', label: '状态' }
  ], '干部信息')
}
function handlePrint() { ElMessage.info('打印名册功能') }

onMounted(fetchData)
</script>

<style scoped>
</style>
