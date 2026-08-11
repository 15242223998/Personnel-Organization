<template>
  <div>
    <div class="page-header">职级晋升管理</div>

    <div class="search-bar">
      <el-form :inline="true" :model="queryForm" size="default">
        <el-form-item label="姓名">
          <el-input v-model="queryForm.name" placeholder="输入姓名" style="width:120px" clearable />
        </el-form-item>
        <el-form-item label="原职级">
          <el-select v-model="queryForm.origRank" placeholder="全部" style="width:140px" clearable>
            <el-option v-for="r in rankOptions" :key="r" :label="r" :value="r" />
          </el-select>
        </el-form-item>
        <el-form-item label="新职级">
          <el-select v-model="queryForm.newRank" placeholder="全部" style="width:140px" clearable>
            <el-option v-for="r in rankOptions" :key="r" :label="r" :value="r" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAddDialog"><el-icon><Plus /></el-icon> 新增晋升</el-button>
      <el-button type="success" @click="showEligible"><el-icon><User /></el-icon> 查看符合条件</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
        <el-table-column prop="gender" label="性别" width="60" align="center" sortable />
        <el-table-column prop="deptName" label="现机构" min-width="160" show-overflow-tooltip sortable />
        <el-table-column prop="origRank" label="原职级" min-width="110" align="center" sortable />
        <el-table-column prop="newRank" label="新职级" min-width="110" align="center" sortable>
          <template #default="{row}">
            <el-tag type="primary" size="small">{{ row.newRank }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="promoteDate" label="晋升日期" width="110" align="center" sortable />
        <el-table-column prop="docNo" label="文号" min-width="140" show-overflow-tooltip sortable />
        <el-table-column label="操作" width="150" align="center" fixed="right">
          <template #default="{row}">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <span class="link-blue" style="margin:0 8px" @click="handleEdit(row)">编辑</span>
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 新增晋升对话框 -->
    <el-dialog v-model="addDialogVisible" title="新增职级晋升" width="560px" destroy-on-close>
      <el-form :model="addForm" label-width="90px" size="default" :rules="addRules" ref="addFormRef">
        <el-form-item label="选择干部" prop="name">
          <el-select v-model="addForm.name" placeholder="请选择干部" style="width:100%" filterable @change="handleCadreChange">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + ' - ' + c.deptName" :value="c.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="原职级">
          <el-input v-model="addForm.origRank" disabled style="width:100%" />
        </el-form-item>
        <el-form-item label="新职级" prop="newRank">
          <el-select v-model="addForm.newRank" placeholder="请选择新职级" style="width:100%">
            <el-option v-for="r in rankOptions" :key="r" :label="r" :value="r" />
          </el-select>
        </el-form-item>
        <el-form-item label="晋升日期" prop="promoteDate">
          <el-date-picker v-model="addForm.promoteDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择晋升日期" />
        </el-form-item>
        <el-form-item label="文号" prop="docNo">
          <el-input v-model="addForm.docNo" placeholder="请输入文号，如：校人[2024]XX号" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="addForm.remark" type="textarea" :rows="3" placeholder="请输入备注信息" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible=false">取消</el-button>
        <el-button type="primary" @click="handleSave">确定</el-button>
      </template>
    </el-dialog>

    <!-- 符合条件人员对话框 -->
    <el-dialog v-model="eligibleDialogVisible" title="符合晋升条件人员" width="700px" destroy-on-close>
      <div style="margin-bottom:10px">
        <el-alert title="以下人员根据任职年限、年度考核结果等条件筛选，符合职级晋升基本条件" type="info" :closable="false" show-icon />
      </div>
      <el-table :data="eligibleData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
        <el-table-column prop="gender" label="性别" width="55" align="center" sortable />
        <el-table-column prop="deptName" label="所在机构" min-width="160" show-overflow-tooltip sortable />
        <el-table-column prop="curRank" label="现职级" min-width="110" align="center" sortable />
        <el-table-column prop="rankStartDate" label="任现职级时间" width="120" align="center" sortable />
        <el-table-column prop="years" label="任职年限" width="90" align="center" sortable />
        <el-table-column prop="assessment" label="近五年考核" min-width="130" align="center" sortable />
        <el-table-column label="操作" width="80" align="center">
          <template #default="{row}">
            <span class="link-blue" @click="selectEligible(row)">选择</span>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, User, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'

const addDialogVisible = ref(false)
const eligibleDialogVisible = ref(false)
const addFormRef = ref(null)

const rankOptions = ref([
  '一级职员', '二级职员', '三级职员', '四级职员',
  '一级教授', '二级教授', '三级教授', '四级教授',
  '副教授', '讲师', '助教',
  '一级主任科员', '二级主任科员', '三级主任科员', '四级主任科员', '一级科员', '二级科员'
])

const cadreOptions = ref([
  { id: 1, name: '张伟', gender: '男', deptName: '机械工程学院', curRank: '四级教授' },
  { id: 2, name: '李芳', gender: '女', deptName: '人事处', curRank: '三级教授' },
  { id: 3, name: '王建国', gender: '男', deptName: '党委办公室', curRank: '二级教授' },
  { id: 4, name: '陈丽', gender: '女', deptName: '信息科学与工程学院', curRank: '副教授' },
  { id: 5, name: '刘强', gender: '男', deptName: '经济管理学院', curRank: '讲师' },
  { id: 6, name: '孙梅', gender: '女', deptName: '机械工程学院', curRank: '四级教授' },
  { id: 7, name: '周志强', gender: '男', deptName: '学生工作处', curRank: '副教授' }
])

const queryForm = reactive({ name: '', origRank: '', newRank: '' })

const addForm = reactive({
  name: '', origRank: '', newRank: '', promoteDate: '', docNo: '', remark: ''
})

const addRules = {
  name: [{ required: true, message: '请选择干部', trigger: 'change' }],
  newRank: [{ required: true, message: '请选择新职级', trigger: 'change' }],
  promoteDate: [{ required: true, message: '请选择晋升日期', trigger: 'change' }],
  docNo: [{ required: true, message: '请输入文号', trigger: 'blur' }]
}

const tableData = ref([
  { id: 1, name: '张伟', gender: '男', deptName: '机械工程学院', origRank: '副教授', newRank: '四级教授', promoteDate: '2024-01-15', docNo: '校人[2024]05号' },
  { id: 2, name: '李芳', gender: '女', deptName: '人事处', origRank: '四级教授', newRank: '三级教授', promoteDate: '2024-02-20', docNo: '校人[2024]09号' },
  { id: 3, name: '陈丽', gender: '女', deptName: '信息科学与工程学院', origRank: '讲师', newRank: '副教授', promoteDate: '2024-03-10', docNo: '校人[2024]14号' },
  { id: 4, name: '孙梅', gender: '女', deptName: '机械工程学院', origRank: '副教授', newRank: '四级教授', promoteDate: '2024-05-01', docNo: '校人[2024]22号' },
  { id: 5, name: '周志强', gender: '男', deptName: '学生工作处', origRank: '讲师', newRank: '副教授', promoteDate: '2024-06-15', docNo: '校人[2024]30号' }
])

const eligibleData = ref([
  { id: 1, name: '吴涛', gender: '男', deptName: '信息科学与工程学院', curRank: '副教授', rankStartDate: '2018-06-01', years: '6年', assessment: '优秀2次/称职3次' },
  { id: 2, name: '郑华', gender: '女', deptName: '教务处', curRank: '四级主任科员', rankStartDate: '2019-03-01', years: '5年', assessment: '优秀1次/称职4次' },
  { id: 3, name: '黄磊', gender: '男', deptName: '经济管理学院', curRank: '讲师', rankStartDate: '2017-09-01', years: '7年', assessment: '优秀2次/称职3次' },
  { id: 4, name: '林静', gender: '女', deptName: '党委办公室', curRank: '三级主任科员', rankStartDate: '2018-12-01', years: '5年', assessment: '优秀1次/称职4次' },
  { id: 5, name: '徐峰', gender: '男', deptName: '科研处', curRank: '副教授', rankStartDate: '2016-07-01', years: '8年', assessment: '优秀3次/称职2次' }
])

function handleSearch() { ElMessage.success('查询条件已应用') }
function handleReset() { ElMessage.info('已重置查询条件') }

function openAddDialog() {
  Object.assign(addForm, { name: '', origRank: '', newRank: '', promoteDate: '', docNo: '', remark: '' })
  addDialogVisible.value = true
}

function handleCadreChange(name) {
  const c = cadreOptions.value.find(i => i.name === name)
  if (c) addForm.origRank = c.curRank
}

function showEligible() {
  eligibleDialogVisible.value = true
}

function selectEligible(row) {
  eligibleDialogVisible.value = false
  addForm.name = row.name
  addForm.origRank = row.curRank
  addDialogVisible.value = true
}

function handleView(row) {
  ElMessage.info('查看晋升详情：' + row.name)
}

function handleEdit(row) {
  ElMessage.info('编辑功能：打开编辑对话框加载数据')
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除"${row.name}"的晋升记录吗？`, '提示', { type: 'warning' })
    .then(() => { ElMessage.success('删除成功') })
    .catch(() => {})
}

function handleSave() {
  addFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('晋升记录保存成功')
      addDialogVisible.value = false
    }
  })
}

function handleExport() {
  showExportDialog(tableData.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'gender', label: '性别' },
    { prop: 'deptName', label: '现机构' },
    { prop: 'origRank', label: '原职级' },
    { prop: 'newRank', label: '新职级' },
    { prop: 'promoteDate', label: '晋升日期' },
    { prop: 'docNo', label: '文号' }
  ], '职级晋升')
}
</script>

<style scoped>
</style>
