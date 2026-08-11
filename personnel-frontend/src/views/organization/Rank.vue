<template>
  <div>
    <div class="page-header">职级管理</div>

    <div class="search-bar">
      <span class="label">职级名称：</span>
      <el-input v-model="searchForm.rankName" placeholder="请输入职级名称" clearable style="width:200px" />
      <span class="label">职级类型：</span>
      <el-select v-model="searchForm.rankType" placeholder="请选择类型" clearable style="width:160px">
        <el-option label="管理岗" value="管理岗" />
        <el-option label="专业技术岗" value="专业技术岗" />
      </el-select>
      <el-button type="primary" @click="handleSearch">查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd">新增</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading">
        <el-table-column prop="rankName" label="职级名称" min-width="180" show-overflow-tooltip sortable />
        <el-table-column prop="rankType" label="职级类型" min-width="110" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.rankType === '管理岗' ? 'primary' : 'success'" size="small">{{ row.rankType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="promotionYears" label="晋升所需年限" width="130" sortable />
        <el-table-column prop="rankSort" label="排序" width="80" sortable />
        <el-table-column prop="status" label="状态" width="80" sortable>
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
        :total="page.total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
      />
    </div>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="500px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="职级名称" prop="rankName">
          <el-input v-model="form.rankName" placeholder="请输入职级名称" />
        </el-form-item>
        <el-form-item label="职级类型" prop="rankType">
          <el-select v-model="form.rankType" placeholder="请选择类型" style="width:100%">
            <el-option label="管理岗" value="管理岗" />
            <el-option label="专业技术岗" value="专业技术岗" />
          </el-select>
        </el-form-item>
        <el-form-item label="晋升所需年限" prop="promotionYears">
          <el-input-number v-model="form.promotionYears" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="排序" prop="rankSort">
          <el-input-number v-model="form.rankSort" :min="0" style="width:100%" />
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
  rankName: '',
  rankType: ''
})

const tableData = ref([
  { id: 1, rankName: '一级调研员', rankType: '管理岗', promotionYears: 4, rankSort: 1, status: 1 },
  { id: 2, rankName: '二级调研员', rankType: '管理岗', promotionYears: 3, rankSort: 2, status: 1 },
  { id: 3, rankName: '三级调研员', rankType: '管理岗', promotionYears: 2, rankSort: 3, status: 1 },
  { id: 4, rankName: '教授', rankType: '专业技术岗', promotionYears: 5, rankSort: 4, status: 1 },
  { id: 5, rankName: '副教授', rankType: '专业技术岗', promotionYears: 4, rankSort: 5, status: 1 },
  { id: 6, rankName: '讲师', rankType: '专业技术岗', promotionYears: 3, rankSort: 6, status: 1 }
])

const page = reactive({
  current: 1,
  size: 10,
  total: 6
})

const form = reactive({
  rankName: '',
  rankType: '',
  promotionYears: 0,
  rankSort: 0,
  status: 1
})

const rules = {
  rankName: [{ required: true, message: '请输入职级名称', trigger: 'blur' }],
  rankType: [{ required: true, message: '请选择职级类型', trigger: 'change' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑职级' : '新增职级')

function handleSearch() {
  ElMessage.success('查询完成')
}

function handleReset() {
  searchForm.rankName = ''
  searchForm.rankType = ''
}

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { rankName: '', rankType: '', promotionYears: 0, rankSort: 0, status: 1 })
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
  ElMessageBox.confirm('确定删除该职级吗？', '提示', { type: 'warning' }).then(() => {
    ElMessage.success('删除成功')
  }).catch(() => {})
}

function handleExport() {
  showExportDialog(tableData.value, [
    { prop: 'rankName', label: '职级名称' },
    { prop: 'rankType', label: '职级类型' },
    { prop: 'promotionYears', label: '晋升所需年限' },
    { prop: 'rankSort', label: '排序' },
    { prop: 'status', label: '状态' }
  ], '职级管理')
}
</script>

<style scoped>
</style>
