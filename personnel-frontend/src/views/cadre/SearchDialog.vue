<template>
  <el-dialog v-model="visible" title="多模式便捷查询" width="95%" top="2vh" destroy-on-close class="search-dialog">
    <el-alert type="info" :closable="false" style="margin-bottom:12px"
      title="查询数据源为干部档案库真实数据（由干部信息页按后端查询结果传入），各类过滤均基于该真实结果进行。" />
    <el-tabs v-model="searchMode" class="gov-tabs">
      <el-tab-pane label="快速查询" name="quick">
        <div class="quick-form">
          <el-row :gutter="16">
            <el-col :span="6"><el-input v-model="quick.name" placeholder="姓名" clearable /></el-col>
            <el-col :span="6"><el-select v-model="quick.deptId" placeholder="所属机构" clearable style="width:100%"><el-option v-for="d in depts" :key="d.id" :label="d.deptName" :value="d.id" /></el-select></el-col>
            <el-col :span="6"><el-select v-model="quick.positionLevel" placeholder="职务层次" clearable style="width:100%"><el-option label="校级" value="校级" /><el-option label="处级" value="处级" /><el-option label="科级" value="科级" /></el-select></el-col>
            <el-col :span="6"><el-select v-model="quick.cadreStatus" placeholder="干部状态" clearable style="width:100%"><el-option label="在职" value="ON_JOB" /><el-option label="离退休" value="RETIRED" /><el-option label="已调出" value="TRANSFERRED" /></el-select></el-col>
          </el-row>
          <el-row style="margin-top:12px">
            <el-col :span="24"><el-button type="primary" @click="doSearch">查询</el-button><el-button @click="resetQuick">重置</el-button></el-col>
          </el-row>
        </div>
      </el-tab-pane>

      <el-tab-pane label="固定查询" name="fixed">
        <el-radio-group v-model="fixedQuery" @change="doSearch" style="display:flex;flex-wrap:wrap;gap:8px">
          <el-radio-button v-for="q in fixedQueries" :key="q.key" :value="q.key">{{ q.label }}</el-radio-button>
        </el-radio-group>
      </el-tab-pane>

      <el-tab-pane label="标签查询(待接入)" name="tag">
        <div class="tag-category">
          <el-empty description="干部标签（储备类别/选任方式/工作经历等）尚未接入档案库数据，标签查询暂不可用；请使用快速/固定/高级查询，结果均来自干部档案库真实数据。" :image-size="70" />
        </div>
      </el-tab-pane>

      <el-tab-pane label="高级查询" name="advanced">
        <el-form :model="advForm" label-width="110px" size="default">
          <el-row :gutter="16">
            <el-col :span="8"><el-form-item label="姓名"><el-input v-model="advForm.name" clearable /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="政治面貌"><el-select v-model="advForm.politicalStatus" clearable style="width:100%"><el-option label="中共党员" value="中共党员" /><el-option label="民主党派" value="民主党派" /><el-option label="群众" value="群众" /></el-select></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="职务层次"><el-select v-model="advForm.positionLevel" clearable style="width:100%"><el-option label="校级" value="校级" /><el-option label="处级" value="处级" /><el-option label="科级" value="科级" /></el-select></el-form-item></el-col>
          </el-row>
          <el-row :gutter="16">
            <el-col :span="8"><el-form-item label="干部状态"><el-select v-model="advForm.cadreStatus" clearable style="width:100%"><el-option label="在职" value="ON_JOB" /><el-option label="离退休" value="RETIRED" /><el-option label="已调出" value="TRANSFERRED" /></el-select></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="性别"><el-select v-model="advForm.gender" clearable style="width:100%"><el-option label="男" :value="1" /><el-option label="女" :value="2" /></el-select></el-form-item></el-col>
            <el-col :span="24">
              <el-button type="primary" @click="doSearch">查询</el-button>
              <el-button @click="resetAdv">重置</el-button>
            </el-col>
          </el-row>
        </el-form>
      </el-tab-pane>
    </el-tabs>

    <div style="margin-top:16px" v-if="searchResults.length > 0">
      <div style="margin-bottom:8px;display:flex;justify-content:space-between;align-items:center">
        <span>查询结果：共 <b>{{ searchResults.length }}</b> 人（基于后端干部查询结果）</span>
        <el-button @click="handleRefresh">刷新</el-button>
      </div>
      <el-table :data="searchResults" border size="small" max-height="350">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="genderText" label="性别" width="60" align="center" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="90" align="center" />
        <el-table-column prop="education" label="学历" width="110" align="center" />
        <el-table-column prop="deptName" label="所属机构" min-width="160" show-overflow-tooltip />
        <el-table-column prop="position" label="职务" min-width="130" show-overflow-tooltip />
        <el-table-column prop="positionLevel" label="职务层次" width="85" align="center" />
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <span class="link-blue" @click="handleViewDetail(row)">查看</span>
          </template>
        </el-table-column>
      </el-table>
    </div>
    <div v-else-if="searched" style="margin-top:16px;text-align:center;color:#999;padding:16px 0">当前条件下无匹配记录</div>

    <template #footer>
      <el-button @click="visible = false">关闭</el-button>
      <el-button type="primary" :disabled="searchResults.length === 0" @click="handleExportResult"><el-icon><Download /></el-icon> 导出结果</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'

const props = defineProps({ modelValue: Boolean, allData: Array, deptList: Array })
const emit = defineEmits(['update:modelValue', 'viewDetail'])

const visible = computed({
  get: () => props.modelValue,
  set: (v) => emit('update:modelValue', v)
})

const depts = computed(() => props.deptList || [])
const searchMode = ref('quick')
const searchResults = ref([])
const searched = ref(false)

// Quick
const quick = reactive({ name: '', deptId: null, positionLevel: '', cadreStatus: '' })
function resetQuick() { Object.assign(quick, { name: '', deptId: null, positionLevel: '', cadreStatus: '' }); doSearch() }

// Fixed
const fixedQuery = ref('')
const fixedQueries = [
  { key: 'middleLevel', label: '中层干部' },
  { key: 'youngMiddle', label: '40岁以下中层' },
  { key: 'femaleCadre', label: '女干部' },
  { key: 'nonParty', label: '党外干部' },
  { key: 'doctorDegree', label: '博士学历' },
  { key: 'fiveYear', label: '任现职5年以上' },
  { key: 'newlyAppointed', label: '近1年新任职' },
  { key: 'retireSoon', label: '3年内退休' }
]

// Advanced
const advForm = reactive({ name: '', politicalStatus: '', positionLevel: '', cadreStatus: '', gender: null })
function resetAdv() {
  Object.assign(advForm, { name: '', politicalStatus: '', positionLevel: '', cadreStatus: '', gender: null })
  doSearch()
}

// 仅在传入的真实数据上进行文本/条件过滤；未传数据则提示无数据源
function doSearch() {
  const src = props.allData || []
  if (!Array.isArray(props.allData)) {
    searchResults.value = []
    searched.value = true
    return
  }
  let data = [...src]
  const mode = searchMode.value

  if (mode === 'quick') {
    if (quick.name) data = data.filter(d => (d.name || '').includes(quick.name))
    if (quick.deptId) data = data.filter(d => d.deptId === quick.deptId)
    if (quick.positionLevel) data = data.filter(d => d.positionLevel === quick.positionLevel)
    if (quick.cadreStatus) data = data.filter(d => d.cadreStatus === quick.cadreStatus)
  } else if (mode === 'fixed') {
    if (!fixedQuery.value) { data = [] }
    else if (fixedQuery.value === 'middleLevel') data = data.filter(d => d.positionLevel === '处级')
    else if (fixedQuery.value === 'youngMiddle') {
      const cutoff = new Date().getFullYear() - 40
      data = data.filter(d => d.positionLevel === '处级' && d.birthDate && parseInt(d.birthDate.substring(0, 4), 10) >= cutoff)
    }
    else if (fixedQuery.value === 'femaleCadre') data = data.filter(d => d.gender === 2)
    else if (fixedQuery.value === 'nonParty') data = data.filter(d => d.politicalStatus && d.politicalStatus !== '中共党员')
    else if (fixedQuery.value === 'doctorDegree') data = data.filter(d => d.education && d.education.includes('博士'))
    else if (fixedQuery.value === 'fiveYear') data = data.filter(d => d.positionStartDate && d.positionStartDate.substring(0, 4) <= String(new Date().getFullYear() - 5))
    else if (fixedQuery.value === 'newlyAppointed') data = data.filter(d => d.positionStartDate && d.positionStartDate.substring(0, 4) >= String(new Date().getFullYear() - 1))
    else if (fixedQuery.value === 'retireSoon') {
      const cutoff = new Date().getFullYear() - 57
      data = data.filter(d => d.birthDate && parseInt(d.birthDate.substring(0, 4), 10) <= cutoff)
    } else data = []
  } else if (mode === 'advanced') {
    if (advForm.name) data = data.filter(d => (d.name || '').includes(advForm.name))
    if (advForm.politicalStatus) data = data.filter(d => d.politicalStatus === advForm.politicalStatus)
    if (advForm.positionLevel) data = data.filter(d => d.positionLevel === advForm.positionLevel)
    if (advForm.cadreStatus) data = data.filter(d => d.cadreStatus === advForm.cadreStatus)
    if (advForm.gender) data = data.filter(d => d.gender === advForm.gender)
  } else {
    // 标签查询：标签体系未接入档案库，无匹配
    data = []
  }

  searchResults.value = data
  searched.value = true
}

function handleRefresh() {
  doSearch()
  ElMessage.info('已基于干部档案库真实数据刷新')
}

function handleViewDetail(row) { emit('viewDetail', row); visible.value = false }

function handleExportResult() {
  if (searchResults.value.length === 0) { ElMessage.warning('没有可导出的结果'); return }
  showExportDialog(searchResults.value, [
    { prop: 'name', label: '姓名' }, { prop: 'genderText', label: '性别' }, { prop: 'birthDate', label: '出生年月' },
    { prop: 'politicalStatus', label: '政治面貌' }, { prop: 'education', label: '学历' },
    { prop: 'deptName', label: '所属机构' }, { prop: 'position', label: '职务' }, { prop: 'positionLevel', label: '职务层次' }
  ], '查询结果')
}
</script>

<style scoped>
.search-dialog :deep(.el-dialog__body) { padding: 16px 20px; }
.quick-form { padding: 10px 0; }
.tag-category { margin-bottom: 16px; border: 1px solid #e8e8e8; border-radius: 4px; padding: 16px; }
</style>
