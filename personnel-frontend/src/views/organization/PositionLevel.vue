<template>
  <div>
    <div class="page-header">职务层次管理</div>

    <div class="search-bar">
      <span class="label">职务层次名称：</span>
      <el-input v-model="searchForm.levelName" placeholder="请输入职务层次名称" clearable style="width:220px" />
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd"><el-icon><Plus /></el-icon> 新增层次</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading">
        <el-table-column prop="levelName" label="职务层次名称" min-width="150" show-overflow-tooltip sortable />
        <el-table-column prop="minLowerYears" label="任低一级最低年限(年)" min-width="160" align="center" sortable />
        <el-table-column prop="maxAge" label="年龄上限" min-width="100" align="center" sortable />
        <el-table-column prop="minEducation" label="最低学历" min-width="110" align="center" sortable />
        <el-table-column prop="assessmentRequired" label="年度考核要求" min-width="200" show-overflow-tooltip />
        <el-table-column prop="penaltyPeriodRestrict" label="处分影响期(月)" min-width="130" align="center" sortable />
        <el-table-column prop="sortOrder" label="排序" width="80" align="center" sortable />
        <el-table-column prop="status" label="状态" width="90" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
          </template>
        </el-table-column>
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
        :total="pageTotal"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
        @size-change="handleSizeChange"
      />
    </div>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="560px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="160px">
        <el-form-item label="职务层次名称" prop="levelName">
          <el-input v-model="form.levelName" placeholder="如：校级/处级/科级" />
        </el-form-item>
        <el-form-item label="任低一级最低年限(年)" prop="minLowerYears">
          <el-input-number v-model="form.minLowerYears" :min="0" style="width:100%" />
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
        <el-form-item label="年度考核要求" prop="assessmentRequired">
          <el-input v-model="form.assessmentRequired" placeholder="如：近三年考核合格以上" />
        </el-form-item>
        <el-form-item label="处分影响期(月)" prop="penaltyPeriodRestrict">
          <el-input-number v-model="form.penaltyPeriodRestrict" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="排序" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" style="width:100%" />
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
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'
import request from '@/utils/request'

const loading = ref(false)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)

const searchForm = reactive({
  levelName: ''
})

const allData = ref([])

const page = reactive({ current: 1, size: 10 })

async function fetchData() {
  loading.value = true
  try {
    const res = await request({ url: '/position-level/list', method: 'get' })
    allData.value = (res.data || []).slice().sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
  } catch (e) {
    allData.value = []
  } finally {
    loading.value = false
  }
}

const filteredData = computed(() => {
  let list = allData.value
  if (searchForm.levelName) list = list.filter(d => (d.levelName || '').includes(searchForm.levelName))
  return list
})

const pageTotal = computed(() => filteredData.value.length)

const tableData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

function handleSearch() { page.current = 1 }
function handleReset() {
  searchForm.levelName = ''
  page.current = 1
}
function handleSizeChange() { page.current = 1 }

const form = reactive({
  levelName: '',
  minLowerYears: 0,
  maxAge: 0,
  minEducation: '',
  assessmentRequired: '',
  penaltyPeriodRestrict: 0,
  sortOrder: 0,
  status: 1
})

const rules = {
  levelName: [{ required: true, message: '请输入职务层次名称', trigger: 'blur' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑职务层次' : '新增职务层次')

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { levelName: '', minLowerYears: 0, maxAge: 0, minEducation: '', assessmentRequired: '', penaltyPeriodRestrict: 0, sortOrder: 0, status: 1 })
}

function openAdd() {
  resetForm()
  dialogVisible.value = true
}

function openEdit(row) {
  resetForm()
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    levelName: row.levelName || '',
    minLowerYears: row.minLowerYears || 0,
    maxAge: row.maxAge || 0,
    minEducation: row.minEducation || '',
    assessmentRequired: row.assessmentRequired || '',
    penaltyPeriodRestrict: row.penaltyPeriodRestrict || 0,
    sortOrder: row.sortOrder || 0,
    status: row.status === 0 ? 0 : 1
  })
  dialogVisible.value = true
}

async function handleSubmit() {
  formRef.value.validate(async (valid) => {
    if (!valid) return
    submitLoading.value = true
    try {
      const body = {
        levelName: form.levelName,
        minLowerYears: form.minLowerYears || 0,
        maxAge: form.maxAge || 0,
        minEducation: form.minEducation || '',
        assessmentRequired: form.assessmentRequired || '',
        penaltyPeriodRestrict: form.penaltyPeriodRestrict || 0,
        sortOrder: form.sortOrder || 0,
        status: form.status === 0 ? 0 : 1
      }
      if (isEdit.value) {
        await request({ url: '/position-level', method: 'put', data: { ...body, id: editId.value } })
        ElMessage.success('更新成功')
      } else {
        await request({ url: '/position-level', method: 'post', data: body })
        ElMessage.success('添加成功')
      }
      dialogVisible.value = false
      await fetchData()
    } catch (e) {
      // 拦截器已提示
    } finally {
      submitLoading.value = false
    }
  })
}

async function handleDelete(row) {
  try {
    await ElMessageBox.confirm('确定删除该职务层次吗？', '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await request({ url: `/position-level/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    await fetchData()
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

function handleExport() {
  showExportDialog(filteredData.value, [
    { prop: 'levelName', label: '职务层次名称' },
    { prop: 'minLowerYears', label: '任低一级最低年限(年)' },
    { prop: 'maxAge', label: '年龄上限' },
    { prop: 'minEducation', label: '最低学历' },
    { prop: 'assessmentRequired', label: '年度考核要求' },
    { prop: 'penaltyPeriodRestrict', label: '处分影响期(月)' }
  ], '职务层次')
}

onMounted(fetchData)
</script>
