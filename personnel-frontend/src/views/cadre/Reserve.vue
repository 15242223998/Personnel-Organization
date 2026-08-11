<template>
  <div>
    <div class="page-header">后备干部库</div>

    <div class="search-bar">
      <el-form :inline="true" :model="queryForm" size="default">
        <el-form-item label="姓名">
          <el-input v-model="queryForm.name" placeholder="请输入姓名" style="width:140px" clearable />
        </el-form-item>
        <el-form-item label="后备类型">
          <el-select v-model="queryForm.reserveType" placeholder="全部" style="width:130px" clearable>
            <el-option label="正职后备" value="正职" />
            <el-option label="副职后备" value="副职" />
          </el-select>
        </el-form-item>
        <el-form-item label="后备级别">
          <el-select v-model="queryForm.reserveLevel" placeholder="全部" style="width:130px" clearable>
            <el-option label="正厅级" value="正厅级" />
            <el-option label="副厅级" value="副厅级" />
            <el-option label="正处级" value="正处级" />
            <el-option label="副处级" value="副处级" />
            <el-option label="正科级" value="正科级" />
            <el-option label="副科级" value="副科级" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd"><el-icon><Plus /></el-icon> 添加后备干部</el-button>
      <el-button type="warning" :disabled="selectedRows.length === 0" @click="handleBatchRemove">
        <el-icon><Delete /></el-icon> 移出后备库
      </el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table
        :data="tableData"
        border
        size="small"
        v-loading="loading"
        @selection-change="handleSelectionChange"
        @sort-change="handleSortChange"
      >
        <el-table-column type="selection" width="45" align="center" />
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" sortable="custom" />
        <el-table-column prop="gender" label="性别" width="60" align="center" sortable="custom" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" sortable="custom" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="100" align="center" sortable="custom" />
        <el-table-column prop="education" label="学历" width="110" align="center" sortable="custom" />
        <el-table-column prop="position" label="现职务" min-width="160" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="rankName" label="现职级" width="110" align="center" sortable="custom" />
        <el-table-column prop="reserveType" label="后备类型" width="100" align="center" sortable="custom">
          <template #default="{ row }">
            <el-tag :type="row.reserveType === '正职' ? 'danger' : 'primary'" size="small">
              {{ row.reserveType }}后备
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reserveLevel" label="级别" width="90" align="center" sortable="custom" />
        <el-table-column prop="entryDate" label="入库日期" width="110" align="center" sortable="custom" />
        <el-table-column prop="status" label="状态" width="70" align="center" sortable="custom">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '在库' : '已出库' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <span class="link-blue" style="margin:0 8px" @click="handleEdit(row)">编辑</span>
            <span class="link-blue" style="color:#E53935" @click="handleRemove(row)">移出</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        background
        small
        @current-change="fetchData"
        @size-change="handleSizeChange"
      />
    </div>

    <el-dialog
      :title="isEdit ? '编辑后备干部' : '添加后备干部'"
      v-model="dialogVisible"
      width="520px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px" size="default">
        <el-form-item label="选择干部" prop="cadreId">
          <el-select v-model="form.cadreId" filterable placeholder="请搜索选择干部" style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + ' - ' + c.position" :value="c.id" :disabled="c.inReserve" />
          </el-select>
        </el-form-item>
        <el-form-item label="后备类型" prop="reserveType">
          <el-radio-group v-model="form.reserveType">
            <el-radio value="正职">正职后备</el-radio>
            <el-radio value="副职">副职后备</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="后备级别" prop="reserveLevel">
          <el-select v-model="form.reserveLevel" placeholder="请选择后备级别" style="width:100%">
            <el-option label="正厅级" value="正厅级" />
            <el-option label="副厅级" value="副厅级" />
            <el-option label="正处级" value="正处级" />
            <el-option label="副处级" value="副处级" />
            <el-option label="正科级" value="正科级" />
            <el-option label="副科级" value="副科级" />
          </el-select>
        </el-form-item>
        <el-form-item label="入库日期" prop="entryDate">
          <el-date-picker v-model="form.entryDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择入库日期" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注信息（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, Delete, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'

const router = useRouter()
const loading = ref(false)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)
const selectedRows = ref([])
const tableData = ref([])

const cadreOptions = ref([
  { id: 4, name: '陈丽', position: '信息学院副院长', inReserve: false },
  { id: 5, name: '刘强', position: '经管学院系主任', inReserve: false },
  { id: 7, name: '孙梅', position: '机械学院副院长', inReserve: true },
  { id: 8, name: '周志强', position: '学工处副处长', inReserve: true },
  { id: 9, name: '吴敏', position: '电气学院院长助理', inReserve: false },
  { id: 10, name: '郑涛', position: '人事处科长', inReserve: false },
  { id: 11, name: '黄丽娟', position: '党委办公室副主任', inReserve: false }
])

const queryForm = reactive({
  name: '',
  reserveType: '',
  reserveLevel: ''
})

const page = reactive({ current: 1, size: 10, total: 35 })

const form = reactive({
  cadreId: null,
  reserveType: '副职',
  reserveLevel: '',
  entryDate: '',
  remark: ''
})

const rules = {
  cadreId: [{ required: true, message: '请选择干部', trigger: 'change' }],
  reserveType: [{ required: true, message: '请选择后备类型', trigger: 'change' }],
  reserveLevel: [{ required: true, message: '请选择后备级别', trigger: 'change' }],
  entryDate: [{ required: true, message: '请选择入库日期', trigger: 'change' }]
}

const baseMockData = [
  { id:1,name:'孙梅',gender:'女',birthDate:'1975-12-03',politicalStatus:'中共党员',education:'博士研究生',position:'机械工程学院副院长',rankName:'教授',reserveType:'正职',reserveLevel:'正处级',entryDate:'2022-03-15',status:1,remark:'教学科研能力突出，管理经验丰富' },
  { id:2,name:'周志强',gender:'男',birthDate:'1982-09-18',politicalStatus:'中共党员',education:'博士研究生',position:'学生工作处副处长',rankName:'副教授',reserveType:'正职',reserveLevel:'正处级',entryDate:'2023-06-20',status:1,remark:'学生工作经验丰富，组织协调能力强' },
  { id:3,name:'陈丽',gender:'女',birthDate:'1978-05-12',politicalStatus:'中共党员',education:'博士研究生',position:'信息科学与工程学院副院长',rankName:'副教授',reserveType:'副职',reserveLevel:'副厅级',entryDate:'2023-01-10',status:1,remark:'学科带头人，科研成果显著' },
  { id:4,name:'黄丽娟',gender:'女',birthDate:'1980-03-25',politicalStatus:'中共党员',education:'硕士研究生',position:'党委办公室副主任',rankName:'研究员',reserveType:'正职',reserveLevel:'正处级',entryDate:'2024-01-08',status:1,remark:'党务工作经验丰富，政策理论水平高' },
  { id:5,name:'郑涛',gender:'男',birthDate:'1985-11-08',politicalStatus:'中共党员',education:'硕士研究生',position:'人事处科长',rankName:'助理研究员',reserveType:'副职',reserveLevel:'副处级',entryDate:'2024-03-01',status:1,remark:'人事业务精通，工作认真负责' }
]

const surnames = ['张','李','王','刘','陈','杨','赵','黄','吴','徐','孙','胡','朱','高','林','何','郭','马','罗','梁']
const givenNames = ['伟','芳','娜','敏','静','强','磊','军','洋','勇','杰','娟','涛','明','超','艳','秀英','霞','平','刚','桂英','建国','建军','志强','晓东','晓红','雪梅','振华','永明','国栋']
const positions = ['院长助理','副处长','副院长','副主任','系主任','科长','副系主任','副科长']
const ranks = ['教授','副教授','研究员','副研究员','讲师','助理研究员']
const levels = ['正处级','副处级','正科级','副科级','副厅级']
const educations = ['博士研究生','硕士研究生','本科']

function generateReserveData() {
  const data = [...baseMockData]
  const types = ['正职','副职']
  for (let i = 6; i <= 35; i++) {
    const sn = surnames[Math.floor(Math.random() * surnames.length)]
    const gn = givenNames[Math.floor(Math.random() * givenNames.length)]
    const gender = Math.random() > 0.35 ? '男' : '女'
    const year = 1970 + Math.floor(Math.random() * 20)
    const month = String(Math.floor(Math.random()*12)+1).padStart(2,'0')
    const day = String(Math.floor(Math.random()*28)+1).padStart(2,'0')
    const entryYear = 2020 + Math.floor(Math.random() * 6)
    const rType = types[Math.floor(Math.random() * 2)]
    data.push({
      id: i,
      name: sn + gn,
      gender,
      birthDate: `${year}-${month}-${day}`,
      politicalStatus: Math.random()>0.2?'中共党员':'群众',
      education: educations[Math.floor(Math.random() * educations.length)],
      position: positions[Math.floor(Math.random() * positions.length)],
      rankName: ranks[Math.floor(Math.random() * ranks.length)],
      reserveType: rType,
      reserveLevel: levels[Math.floor(Math.random() * levels.length)],
      entryDate: `${entryYear}-${String(Math.floor(Math.random()*12)+1).padStart(2,'0')}-${String(Math.floor(Math.random()*28)+1).padStart(2,'0')}`,
      status: Math.random()>0.15 ? 1 : 0,
      remark: ''
    })
  }
  return data
}

const allReserveData = generateReserveData()

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
    let data = [...allReserveData]
    if (queryForm.name) {
      data = data.filter(d => d.name.includes(queryForm.name))
    }
    if (queryForm.reserveType) {
      data = data.filter(d => d.reserveType === queryForm.reserveType)
    }
    if (queryForm.reserveLevel) {
      data = data.filter(d => d.reserveLevel === queryForm.reserveLevel)
    }
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

function handleSearch() {
  page.current = 1
  fetchData()
}

function handleReset() {
  Object.assign(queryForm, { name: '', reserveType: '', reserveLevel: '' })
  page.current = 1
  sortInfo.prop = ''
  sortInfo.order = ''
  fetchData()
}

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { cadreId: null, reserveType: '副职', reserveLevel: '', entryDate: '', remark: '' })
}

function openAdd() {
  resetForm()
  dialogVisible.value = true
}

function handleView(row) {
  router.push(`/cadre/${row.id}`)
}

function handleEdit(row) {
  resetForm()
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    cadreId: cadreOptions.value.find(c => c.name === row.name)?.id || null,
    reserveType: row.reserveType,
    reserveLevel: row.reserveLevel,
    entryDate: row.entryDate,
    remark: row.remark || ''
  })
  dialogVisible.value = true
}

function handleSubmit() {
  formRef.value?.validate((valid) => {
    if (!valid) return
    submitLoading.value = true
    setTimeout(() => {
      const selectedCadre = cadreOptions.value.find(c => c.id === form.cadreId)
      if (isEdit.value) {
        const idx = tableData.value.findIndex(d => d.id === editId.value)
        if (idx > -1) {
          tableData.value[idx] = {
            ...tableData.value[idx],
            reserveType: form.reserveType,
            reserveLevel: form.reserveLevel,
            entryDate: form.entryDate,
            remark: form.remark
          }
        }
        ElMessage.success('更新成功')
      } else {
        if (selectedCadre) {
          selectedCadre.inReserve = true
        }
        const newId = Math.max(...tableData.value.map(d => d.id)) + 1
        tableData.value.unshift({
          id: newId,
          name: selectedCadre?.name || '未知',
          gender: '男',
          birthDate: '1980-01-01',
          politicalStatus: '中共党员',
          education: '硕士研究生',
          position: selectedCadre?.position || '',
          rankName: '待补充',
          reserveType: form.reserveType,
          reserveLevel: form.reserveLevel,
          entryDate: form.entryDate,
          status: 1,
          remark: form.remark
        })
        page.total = tableData.value.length
        ElMessage.success('添加成功')
      }
      submitLoading.value = false
      dialogVisible.value = false
    }, 400)
  })
}

function handleRemove(row) {
  ElMessageBox.confirm(`确定将"${row.name}"移出后备干部库吗？`, '移出确认', {
    type: 'warning',
    confirmButtonText: '确定移出',
    cancelButtonText: '取消'
  }).then(() => {
    const idx = tableData.value.findIndex(d => d.id === row.id)
    if (idx > -1) {
      tableData.value[idx].status = 0
    }
    const cadre = cadreOptions.value.find(c => c.name === row.name)
    if (cadre) cadre.inReserve = false
    ElMessage.success('已移出后备库')
  }).catch(() => {})
}

function handleBatchRemove() {
  if (selectedRows.value.length === 0) return
  ElMessageBox.confirm(`确定将选中的 ${selectedRows.value.length} 名干部移出后备干部库吗？`, '批量移出确认', {
    type: 'warning',
    confirmButtonText: '确定移出',
    cancelButtonText: '取消'
  }).then(() => {
    selectedRows.value.forEach(row => {
      const idx = tableData.value.findIndex(d => d.id === row.id)
      if (idx > -1) {
        tableData.value[idx].status = 0
      }
      const cadre = cadreOptions.value.find(c => c.name === row.name)
      if (cadre) cadre.inReserve = false
    })
    selectedRows.value = []
    ElMessage.success('批量移出成功')
  }).catch(() => {})
}

function handleSelectionChange(rows) {
  selectedRows.value = rows.filter(r => r.status === 1)
}

onMounted(fetchData)

function handleExport() {
  let data = [...allReserveData]
  if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
  if (queryForm.reserveType) data = data.filter(d => d.reserveType === queryForm.reserveType)
  if (queryForm.reserveLevel) data = data.filter(d => d.reserveLevel === queryForm.reserveLevel)
  data = applySort(data)
  showExportDialog(data, [
    { prop: 'name', label: '姓名' },
    { prop: 'gender', label: '性别' },
    { prop: 'birthDate', label: '出生年月' },
    { prop: 'politicalStatus', label: '政治面貌' },
    { prop: 'education', label: '学历' },
    { prop: 'position', label: '现职务' },
    { prop: 'rankName', label: '现职级' },
    { prop: 'reserveType', label: '后备类型' },
    { prop: 'reserveLevel', label: '级别' },
    { prop: 'entryDate', label: '入库日期' },
    { prop: 'status', label: '状态' }
  ], '后备干部库')
}

</script>

<style scoped>
</style>
