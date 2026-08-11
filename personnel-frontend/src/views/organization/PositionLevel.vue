<template>
  <div>
    <div class="page-header">职务层次管理</div>

    <div class="search-bar">
      <span class="label">职务层次名称：</span>
      <el-input v-model="searchForm.levelName" placeholder="请输入职务层次名称" clearable style="width:200px" />
      <el-button type="primary" @click="handleSearch">查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd">新增</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading">
        <el-table-column prop="levelName" label="职务层次名称" min-width="150" show-overflow-tooltip sortable />
        <el-table-column prop="minYears" label="任低一级最低年限(年)" min-width="150" align="center" sortable />
        <el-table-column prop="maxAge" label="年龄上限" min-width="100" align="center" sortable />
        <el-table-column prop="minEducation" label="最低学历" min-width="110" align="center" sortable />
        <el-table-column prop="assessmentRequirement" label="年度考核要求" min-width="180" show-overflow-tooltip />
        <el-table-column prop="penaltyPeriod" label="处分影响期(月)" min-width="120" align="center" sortable />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openEdit(row)" style="margin-right:10px">编辑</span>
            <span class="link-blue" style="color:#f56c6c" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
      />
    </div>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="550px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="150px">
        <el-form-item label="职务层次名称" prop="levelName">
          <el-input v-model="form.levelName" placeholder="请输入职务层次名称" />
        </el-form-item>
        <el-form-item label="任低一级最低年限(年)" prop="minYears">
          <el-input-number v-model="form.minYears" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="年龄上限" prop="maxAge">
          <el-input-number v-model="form.maxAge" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="最低学历" prop="minEducation">
          <el-select v-model="form.minEducation" placeholder="请选择" style="width:100%">
            <el-option label="博士" value="博士" />
            <el-option label="硕士" value="硕士" />
            <el-option label="本科" value="本科" />
            <el-option label="大专" value="大专" />
            <el-option label="中专" value="中专" />
          </el-select>
        </el-form-item>
        <el-form-item label="年度考核要求" prop="assessmentRequirement">
          <el-input v-model="form.assessmentRequirement" placeholder="如：近三年考核合格以上" />
        </el-form-item>
        <el-form-item label="处分影响期(月)" prop="penaltyPeriod">
          <el-input-number v-model="form.penaltyPeriod" :min="0" style="width:100%" />
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
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'

const loading = ref(false)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)

const searchForm = reactive({
  levelName: ''
})

const tableData = ref([
  { id: 1, levelName: '校级', minYears: 5, maxAge: 60, minEducation: '本科', assessmentRequirement: '近五年考核合格以上', penaltyPeriod: 24 },
  { id: 2, levelName: '处级', minYears: 3, maxAge: 55, minEducation: '大专', assessmentRequirement: '近三年考核合格以上', penaltyPeriod: 12 },
  { id: 3, levelName: '科级', minYears: 2, maxAge: 50, minEducation: '中专', assessmentRequirement: '近两年考核合格以上', penaltyPeriod: 6 }
])

const page = reactive({
  current: 1,
  size: 10,
  total: 3
})

const form = reactive({
  levelName: '',
  minYears: 0,
  maxAge: 0,
  minEducation: '',
  assessmentRequirement: '',
  penaltyPeriod: 0
})

const rules = {
  levelName: [{ required: true, message: '请输入职务层次名称', trigger: 'blur' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑职务层次' : '新增职务层次')

function handleSearch() {
  ElMessage.success('查询完成')
}

function handleReset() {
  searchForm.levelName = ''
}

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { levelName: '', minYears: 0, maxAge: 0, minEducation: '', assessmentRequirement: '', penaltyPeriod: 0 })
}

function openAdd() {
  resetForm()
  dialogVisible.value = true
}

function openEdit(row) {
  resetForm()
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, row)
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
  ElMessageBox.confirm('确定删除该职务层次吗？', '提示', { type: 'warning' }).then(() => {
    ElMessage.success('删除成功')
  }).catch(() => {})
}

function handleExport() {
  showExportDialog(tableData.value, [
    { prop: 'levelName', label: '职务层次名称' },
    { prop: 'minYears', label: '任低一级最低年限(年)' },
    { prop: 'maxAge', label: '年龄上限' },
    { prop: 'minEducation', label: '最低学历' },
    { prop: 'assessmentRequirement', label: '年度考核要求' },
    { prop: 'penaltyPeriod', label: '处分影响期(月)' }
  ], '职务层次')
}
</script>

<style scoped>
</style>
