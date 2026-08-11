<template>
  <div>
    <div class="page-header">组织机构管理</div>

    <div class="search-bar">
      <span class="label">机构名称：</span>
      <el-input v-model="searchForm.deptName" placeholder="请输入机构名称" clearable style="width:200px" />
      <span class="label">机构级别：</span>
      <el-select v-model="searchForm.deptLevel" placeholder="请选择级别" clearable style="width:150px">
        <el-option label="校级" value="校级" />
        <el-option label="处级" value="处级" />
        <el-option label="科级" value="科级" />
      </el-select>
      <el-button type="primary" @click="handleSearch">查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd(null)">新增机构</el-button>
      <el-button @click="handleExport">导出</el-button>
    </div>

    <div class="table-wrap">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="机构列表" name="tree">
          <el-table :data="filteredTreeData" row-key="id" border size="small" v-loading="loading" :tree-props="{children:'children'}" default-expand-all>
            <el-table-column prop="deptName" label="机构名称" min-width="200" />
            <el-table-column prop="shortName" label="简称" min-width="110" />
            <el-table-column prop="deptLevel" label="级别" width="100" />
            <el-table-column prop="leaderQuota" label="班子职数" width="100" />
            <el-table-column prop="establishedDate" label="成立时间" width="120" />
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="deptSort" label="排序" width="70" />
            <el-table-column label="操作" width="220" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openAdd(row)" style="margin-right:10px">新增子级</span>
                <span class="link-blue" @click="openEdit(row)" style="margin-right:10px">编辑</span>
                <span class="link-blue" style="color:#f56c6c" @click="handleDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="编制管理" name="quota">
          <el-table :data="quotaList" border size="small" v-loading="quotaLoading">
            <el-table-column prop="deptName" label="机构" min-width="200" sortable />
            <el-table-column prop="approvedQuota" label="核定编制" width="100" sortable />
            <el-table-column prop="actualCount" label="实有人数" width="100" sortable />
            <el-table-column prop="vacantCount" label="空编数" width="100" sortable />
            <el-table-column prop="leaderQuota" label="领导职数" width="100" sortable />
            <el-table-column prop="actualLeaders" label="实际配备" width="100" sortable />
            <el-table-column prop="leaderVacancy" label="空缺" width="100" sortable />
            <el-table-column label="操作" width="80" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openQuotaEdit(row)">编辑</span>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="quotaPage.current"
            v-model:page-size="quotaPage.size"
            :total="quotaPage.total"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            background
            small
            @current-change="fetchQuota"
            @size-change="handleQuotaSizeChange"
          />
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="上级机构" prop="parentId">
          <el-tree-select v-model="form.parentId" :data="orgTreeSelect" :props="{ label:'deptName', value:'id', children:'children' }" placeholder="请选择上级机构" check-strictly clearable style="width:100%" />
        </el-form-item>
        <el-form-item label="机构名称" prop="deptName">
          <el-input v-model="form.deptName" placeholder="请输入机构名称" />
        </el-form-item>
        <el-form-item label="简称" prop="shortName">
          <el-input v-model="form.shortName" placeholder="请输入简称" />
        </el-form-item>
        <el-form-item label="级别" prop="deptLevel">
          <el-select v-model="form.deptLevel" placeholder="请选择级别" style="width:100%">
            <el-option label="校级" value="校级" />
            <el-option label="处级" value="处级" />
            <el-option label="科级" value="科级" />
          </el-select>
        </el-form-item>
        <el-form-item label="班子职数" prop="leaderQuota">
          <el-input-number v-model="form.leaderQuota" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="成立时间" prop="establishedDate">
          <el-date-picker v-model="form.establishedDate" type="date" placeholder="选择日期" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="排序" prop="deptSort">
          <el-input-number v-model="form.deptSort" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="编辑编制" v-model="quotaDialogVisible" width="500px" @close="resetQuotaForm">
      <el-form ref="quotaFormRef" :model="quotaForm" :rules="quotaRules" label-width="100px">
        <el-form-item label="机构名称">
          <el-input :model-value="quotaForm.deptName" disabled />
        </el-form-item>
        <el-form-item label="核定编制" prop="approvedQuota">
          <el-input-number v-model="quotaForm.approvedQuota" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="领导职数" prop="leaderQuota">
          <el-input-number v-model="quotaForm.leaderQuota" :min="0" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="quotaDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="quotaSubmitLoading" @click="handleQuotaSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'

const activeTab = ref('tree')
const loading = ref(false)
const quotaLoading = ref(false)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)

const searchForm = reactive({
  deptName: '',
  deptLevel: ''
})

const treeData = ref([
  {
    id: 1,
    deptName: '学校党委',
    shortName: '党委',
    deptLevel: '校级',
    leaderQuota: 11,
    establishedDate: '1950-09-01',
    deptSort: 1,
    status: 1,
    children: [
      {
        id: 2,
        parentId: 1,
        deptName: '党委办公室',
        shortName: '党办',
        deptLevel: '处级',
        leaderQuota: 4,
        establishedDate: '1950-09-01',
        deptSort: 1,
        status: 1,
        children: []
      },
      {
        id: 3,
        parentId: 1,
        deptName: '组织部',
        shortName: '组织部',
        deptLevel: '处级',
        leaderQuota: 4,
        establishedDate: '1950-09-01',
        deptSort: 2,
        status: 1,
        children: [
          {
            id: 31,
            parentId: 3,
            deptName: '干部科',
            shortName: '干部科',
            deptLevel: '科级',
            leaderQuota: 2,
            establishedDate: '1985-03-15',
            deptSort: 1,
            status: 1,
            children: []
          },
          {
            id: 32,
            parentId: 3,
            deptName: '组织科',
            shortName: '组织科',
            deptLevel: '科级',
            leaderQuota: 2,
            establishedDate: '1985-03-15',
            deptSort: 2,
            status: 1,
            children: []
          }
        ]
      },
      {
        id: 4,
        parentId: 1,
        deptName: '宣传部',
        shortName: '宣传部',
        deptLevel: '处级',
        leaderQuota: 3,
        establishedDate: '1950-09-01',
        deptSort: 3,
        status: 1,
        children: []
      },
      {
        id: 5,
        parentId: 1,
        deptName: '纪委办公室',
        shortName: '纪委办',
        deptLevel: '处级',
        leaderQuota: 3,
        establishedDate: '1980-05-20',
        deptSort: 4,
        status: 1,
        children: []
      },
      {
        id: 6,
        parentId: 1,
        deptName: '人事处',
        shortName: '人事处',
        deptLevel: '处级',
        leaderQuota: 5,
        establishedDate: '1950-09-01',
        deptSort: 5,
        status: 1,
        children: []
      },
      {
        id: 7,
        parentId: 1,
        deptName: '教务处',
        shortName: '教务处',
        deptLevel: '处级',
        leaderQuota: 5,
        establishedDate: '1950-09-01',
        deptSort: 6,
        status: 1,
        children: []
      },
      {
        id: 8,
        parentId: 1,
        deptName: '计算机学院',
        shortName: '计算机学院',
        deptLevel: '处级',
        leaderQuota: 7,
        establishedDate: '1995-07-01',
        deptSort: 101,
        status: 1,
        children: []
      },
      {
        id: 9,
        parentId: 1,
        deptName: '经济管理学院',
        shortName: '经管学院',
        deptLevel: '处级',
        leaderQuota: 7,
        establishedDate: '1985-09-01',
        deptSort: 102,
        status: 1,
        children: []
      },
      {
        id: 10,
        parentId: 1,
        deptName: '文学院',
        shortName: '文学院',
        deptLevel: '处级',
        leaderQuota: 6,
        establishedDate: '1950-09-01',
        deptSort: 103,
        status: 1,
        children: []
      },
      {
        id: 11,
        parentId: 1,
        deptName: '理学院',
        shortName: '理学院',
        deptLevel: '处级',
        leaderQuota: 6,
        establishedDate: '1952-09-01',
        deptSort: 104,
        status: 1,
        children: []
      }
    ]
  }
])

const baseQuotaData = [
  { id:1,deptName:'党委办公室',approvedQuota:15,actualCount:14,vacantCount:1,leaderQuota:4,actualLeaders:4,leaderVacancy:0 },
  { id:2,deptName:'组织部',approvedQuota:12,actualCount:11,vacantCount:1,leaderQuota:4,actualLeaders:3,leaderVacancy:1 },
  { id:3,deptName:'宣传部',approvedQuota:10,actualCount:9,vacantCount:1,leaderQuota:3,actualLeaders:3,leaderVacancy:0 },
  { id:4,deptName:'纪委办公室',approvedQuota:8,actualCount:7,vacantCount:1,leaderQuota:3,actualLeaders:2,leaderVacancy:1 },
  { id:5,deptName:'人事处',approvedQuota:18,actualCount:17,vacantCount:1,leaderQuota:5,actualLeaders:5,leaderVacancy:0 },
  { id:6,deptName:'教务处',approvedQuota:20,actualCount:19,vacantCount:1,leaderQuota:5,actualLeaders:4,leaderVacancy:1 },
  { id:7,deptName:'计算机学院',approvedQuota:120,actualCount:115,vacantCount:5,leaderQuota:7,actualLeaders:6,leaderVacancy:1 },
  { id:8,deptName:'经济管理学院',approvedQuota:100,actualCount:98,vacantCount:2,leaderQuota:7,actualLeaders:7,leaderVacancy:0 },
  { id:9,deptName:'文学院',approvedQuota:80,actualCount:76,vacantCount:4,leaderQuota:6,actualLeaders:5,leaderVacancy:1 },
  { id:10,deptName:'理学院',approvedQuota:90,actualCount:85,vacantCount:5,leaderQuota:6,actualLeaders:6,leaderVacancy:0 }
]
const moreDepts = ['学生工作处','科研处','财务处','研究生院','招生就业处','国际交流处','保卫处','后勤管理处','资产处','审计处','基建处','离退休工作处','工会','团委','机械工程学院','电气工程学院','信息科学与工程学院','土木工程学院','材料科学与工程学院','自动化学院','外国语学院','体育学院','马克思主义学院','艺术学院','继续教育学院','图书馆','网络信息中心','学报编辑部','校医院','附属中学','实验实训中心','工程训练中心','高等教育研究所','校友总会','招投标中心','采购中心']

const allQuotaList = ref([...baseQuotaData, ...moreDepts.map((name, i) => {
  const aq = 8 + Math.floor(Math.random()*100)
  const lq = 3 + Math.floor(Math.random()*5)
  const al = Math.random() > 0.3 ? lq : lq - 1
  return { id: 11+i, deptName: name, approvedQuota: aq, actualCount: aq - Math.floor(Math.random()*4), vacantCount: Math.floor(Math.random()*4), leaderQuota: lq, actualLeaders: al, leaderVacancy: Math.max(0, lq - al) }
})])

const quotaList = ref([])

const quotaPage = reactive({
  current: 1,
  size: 10,
  total: allQuotaList.value.length
})

function fetchQuota() {
  quotaLoading.value = true
  setTimeout(() => {
    const start = (quotaPage.current - 1) * quotaPage.size
    quotaList.value = allQuotaList.value.slice(start, start + quotaPage.size)
    quotaPage.total = allQuotaList.value.length
    quotaLoading.value = false
  }, 200)
}
function handleQuotaSizeChange() {
  quotaPage.current = 1
  fetchQuota()
}

const form = reactive({
  parentId: null,
  deptName: '',
  shortName: '',
  deptLevel: '',
  leaderQuota: 0,
  establishedDate: '',
  deptSort: 0,
  status: 1
})

const rules = {
  deptName: [{ required: true, message: '请输入机构名称', trigger: 'blur' }],
  deptLevel: [{ required: true, message: '请选择级别', trigger: 'change' }]
}

const orgTreeSelect = computed(() => {
  const wrap = (list) => list.map(item => ({
    ...item,
    children: item.children ? wrap(item.children) : []
  }))
  return wrap(treeData.value)
})

const filteredTreeData = computed(() => {
  if (!searchForm.deptName && !searchForm.deptLevel) return treeData.value
  const filter = (list) => {
    return list.filter(item => {
      const matchName = !searchForm.deptName || item.deptName.includes(searchForm.deptName)
      const matchLevel = !searchForm.deptLevel || item.deptLevel === searchForm.deptLevel
      if (item.children && item.children.length > 0) {
        item.children = filter(item.children)
        return matchName || matchLevel || item.children.length > 0
      }
      return matchName && matchLevel
    })
  }
  return filter(JSON.parse(JSON.stringify(treeData.value)))
})

const dialogTitle = computed(() => isEdit.value ? '编辑机构' : '新增机构')

function handleSearch() {
  ElMessage.success('查询完成')
}

function handleReset() {
  searchForm.deptName = ''
  searchForm.deptLevel = ''
}

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { parentId: null, deptName: '', shortName: '', deptLevel: '', leaderQuota: 0, establishedDate: '', deptSort: 0, status: 1 })
}

function openAdd(parent) {
  resetForm()
  if (parent) {
    form.parentId = parent.id
  }
  dialogVisible.value = true
}

function openEdit(row) {
  resetForm()
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    parentId: row.parentId || null,
    deptName: row.deptName,
    shortName: row.shortName || '',
    deptLevel: row.deptLevel,
    leaderQuota: row.leaderQuota || 0,
    establishedDate: row.establishedDate || '',
    deptSort: row.deptSort || 0,
    status: row.status
  })
  dialogVisible.value = true
}

function handleSubmit() {
  formRef.value.validate((valid) => {
    if (!valid) return
    submitLoading.value = true
    setTimeout(() => {
      ElMessage.success(isEdit.value ? '更新成功' : '添加成功')
      dialogVisible.value = false
      submitLoading.value = false
    }, 500)
  })
}

function handleDelete(row) {
  ElMessageBox.confirm('确定删除该机构吗？', '提示', { type: 'warning' }).then(() => {
    ElMessage.success('删除成功')
  }).catch(() => {})
}

const quotaDialogVisible = ref(false)
const quotaSubmitLoading = ref(false)
const quotaFormRef = ref(null)
const quotaEditId = ref(null)

const quotaForm = reactive({
  deptName: '',
  approvedQuota: 0,
  leaderQuota: 0
})

const quotaRules = {
  approvedQuota: [{ required: true, message: '请输入核定编制', trigger: 'blur' }],
  leaderQuota: [{ required: true, message: '请输入领导职数', trigger: 'blur' }]
}

function resetQuotaForm() {
  quotaFormRef.value?.resetFields()
  quotaEditId.value = null
  Object.assign(quotaForm, { deptName: '', approvedQuota: 0, leaderQuota: 0 })
}

function openQuotaEdit(row) {
  quotaEditId.value = row.id
  quotaForm.deptName = row.deptName
  quotaForm.approvedQuota = row.approvedQuota
  quotaForm.leaderQuota = row.leaderQuota
  quotaDialogVisible.value = true
}

function handleQuotaSubmit() {
  quotaFormRef.value.validate((valid) => {
    if (!valid) return
    quotaSubmitLoading.value = true
    setTimeout(() => {
      const item = allQuotaList.value.find(q => q.id === quotaEditId.value)
      if (item) {
        item.approvedQuota = quotaForm.approvedQuota
        item.leaderQuota = quotaForm.leaderQuota
        item.vacantCount = Math.max(0, item.approvedQuota - item.actualCount)
        item.leaderVacancy = Math.max(0, item.leaderQuota - item.actualLeaders)
        fetchQuota()
      }
      ElMessage.success('编制更新成功')
      quotaDialogVisible.value = false
      quotaSubmitLoading.value = false
    }, 300)
  })
}

function handleExport() {
  showExportDialog(quotaList.value, [
    { prop: 'deptName', label: '机构' },
    { prop: 'approvedQuota', label: '核定编制' },
    { prop: 'actualCount', label: '实有人数' },
    { prop: 'vacantCount', label: '空编数' },
    { prop: 'leaderQuota', label: '领导职数' },
    { prop: 'actualLeaders', label: '实际配备' },
    { prop: 'leaderVacancy', label: '空缺' }
  ], '编制管理')
}

onMounted(fetchQuota)
</script>

<style scoped>
</style>
