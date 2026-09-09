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
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openAdd"><el-icon><Plus /></el-icon> 新增职级</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading">
        <el-table-column prop="rankName" label="职级名称" min-width="200" show-overflow-tooltip sortable />
        <el-table-column prop="rankType" label="职级类型" min-width="120" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.rankType === '管理岗' ? 'primary' : 'success'" size="small">{{ row.rankType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="promotionYears" label="晋升所需年限" width="130" align="center" sortable />
        <el-table-column prop="sortOrder" label="排序" width="90" align="center" sortable />
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

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="500px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="130px">
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
  rankName: '',
  rankType: ''
})

const allData = ref([])

const page = reactive({ current: 1, size: 10 })

async function fetchData() {
  loading.value = true
  try {
    const res = await request({ url: '/rank/list', method: 'get' })
    allData.value = (res.data || []).slice().sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
  } catch (e) {
    allData.value = []
  } finally {
    loading.value = false
  }
}

const filteredData = computed(() => {
  let list = allData.value
  if (searchForm.rankName) list = list.filter(d => (d.rankName || '').includes(searchForm.rankName))
  if (searchForm.rankType) list = list.filter(d => d.rankType === searchForm.rankType)
  return list
})

const pageTotal = computed(() => filteredData.value.length)

const tableData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

function handleSearch() { page.current = 1 }
function handleReset() {
  searchForm.rankName = ''
  searchForm.rankType = ''
  page.current = 1
}
function handleSizeChange() { page.current = 1 }

const form = reactive({
  rankName: '',
  rankType: '',
  promotionYears: 0,
  sortOrder: 0,
  status: 1
})

const rules = {
  rankName: [{ required: true, message: '请输入职级名称', trigger: 'blur' }],
  rankType: [{ required: true, message: '请选择职级类型', trigger: 'change' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑职级' : '新增职级')

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { rankName: '', rankType: '', promotionYears: 0, sortOrder: 0, status: 1 })
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
    rankName: row.rankName || '',
    rankType: row.rankType || '',
    promotionYears: row.promotionYears || 0,
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
        rankName: form.rankName,
        rankType: form.rankType,
        promotionYears: form.promotionYears || 0,
        sortOrder: form.sortOrder || 0,
        status: form.status === 0 ? 0 : 1
      }
      if (isEdit.value) {
        await request({ url: '/rank', method: 'put', data: { ...body, id: editId.value } })
        ElMessage.success('更新成功')
      } else {
        await request({ url: '/rank', method: 'post', data: body })
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
    await ElMessageBox.confirm('确定删除该职级吗？若已有干部使用该职级将删除失败。', '提示', { type: 'warning' })
  } catch (e) {
    return
  }
  try {
    await request({ url: `/rank/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    await fetchData()
  } catch (e) {
    ElMessage.error('删除失败，请确认无干部使用该职级')
  }
}

function handleExport() {
  showExportDialog(filteredData.value, [
    { prop: 'rankName', label: '职级名称' },
    { prop: 'rankType', label: '职级类型' },
    { prop: 'promotionYears', label: '晋升所需年限' },
    { prop: 'sortOrder', label: '排序' },
    { prop: 'status', label: '状态' }
  ], '职级管理')
}

onMounted(fetchData)
</script>
