<template>
  <div>
    <div class="page-header">干部考核管理</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <el-tab-pane label="年度考核" name="annual">
        <div class="search-bar">
          <span class="label">年度：</span>
          <el-select v-model="search.annual.year" placeholder="请选择年度" size="default" style="width:120px" clearable>
            <el-option label="2025" value="2025" />
            <el-option label="2024" value="2024" />
            <el-option label="2023" value="2023" />
          </el-select>
          <span class="label">姓名：</span>
          <el-input v-model="search.annual.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
          <span class="label">考核结果：</span>
          <el-select v-model="search.annual.result" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="优秀" value="优秀" />
            <el-option label="称职" value="称职" />
            <el-option label="基本称职" value="基本称职" />
            <el-option label="不称职" value="不称职" />
          </el-select>
          <el-button type="primary" @click="handleAnnualSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddAnnual"><el-icon><Plus /></el-icon> 新增考核</el-button>
          <el-button size="small" @click="handleImport"><el-icon><Upload /></el-icon> 批量导入</el-button>
          <el-button size="small" @click="exportAnnual"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="annualData" border size="small">
            <el-table-column type="selection" width="45" align="center" />
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="department" label="部门" min-width="140" show-overflow-tooltip sortable />
            <el-table-column prop="position" label="职务" min-width="120" show-overflow-tooltip sortable />
            <el-table-column prop="year" label="年度" width="80" align="center" sortable />
            <el-table-column prop="result" label="考核结果" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="resultTagType(row.result)" size="small">{{ row.result }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="comment" label="评语" min-width="220" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="200" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleViewAnnual(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleEditAnnual(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handlePrintAnnual(row)">打印</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleDeleteAnnual(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="民主测评" name="democracy">
        <div class="toolbar" style="border-top:1px solid #e0e0e0">
          <el-button type="primary" size="small" @click="schemeDialog = true"><el-icon><Plus /></el-icon> 新建方案</el-button>
          <el-button size="small" @click="exportScheme"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="schemeData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="方案名称" min-width="200" sortable />
            <el-table-column prop="year" label="年度" width="80" align="center" sortable />
            <el-table-column prop="startDate" label="开始时间" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="结束时间" width="110" align="center" sortable />
            <el-table-column prop="targetCount" label="测评对象" width="90" align="center" sortable />
            <el-table-column prop="voterCount" label="参评人数" width="90" align="center" sortable />
            <el-table-column prop="status" label="状态" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已结束' ? 'info' : row.status === '进行中' ? 'success' : 'warning'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="260" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" v-if="row.status === '草稿'">发布</span>
                <span class="link-blue" v-else-if="row.status === '进行中'" style="color:#E53935">关闭</span>
                <template v-if="row.status !== '草稿'">
                  <el-divider direction="vertical" />
                  <span class="link-blue" @click="openResult(row)">查看结果</span>
                </template>
                <el-divider direction="vertical" />
                <span class="link-blue">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="importDialogVisible" title="批量导入考核数据" width="700px" destroy-on-close @closed="handleCancelImport">
      <el-upload :auto-upload="false" :limit="1" accept=".xlsx,.xls" :on-change="handleImportFile" :on-remove="() => { importPreviewData = [] }">
        <el-button type="primary"><el-icon><Upload /></el-icon> 选择Excel文件</el-button>
      </el-upload>
      <el-table v-if="importPreviewData.length > 0" :data="importPreviewData" border size="small" style="margin-top:16px" max-height="350">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="department" label="部门" min-width="130" align="center" />
        <el-table-column prop="position" label="职务" min-width="110" align="center" />
        <el-table-column prop="year" label="年度" width="70" align="center" />
        <el-table-column prop="result" label="考核结果" width="90" align="center" />
        <el-table-column prop="comment" label="评语" min-width="160" show-overflow-tooltip />
      </el-table>
      <div v-if="importPreviewData.length > 0" style="margin-top:12px;color:#666;text-align:center">
        共解析 <b>{{ importPreviewData.length }}</b> 条记录
      </div>
      <template #footer>
        <el-button @click="handleCancelImport">取消</el-button>
        <el-button type="primary" :disabled="importPreviewData.length === 0" :loading="importing" @click="confirmImport">确认导入</el-button>
      </template>
    </el-dialog>

    <el-dialog title="新建民主测评方案" v-model="schemeDialog" width="600px">
      <el-form :model="schemeForm" label-width="90px">
        <el-form-item label="方案名称">
          <el-input v-model="schemeForm.name" placeholder="请输入方案名称" />
        </el-form-item>
        <el-form-item label="测评年度">
          <el-select v-model="schemeForm.year" style="width:100%">
            <el-option label="2025" value="2025" />
            <el-option label="2024" value="2024" />
          </el-select>
        </el-form-item>
        <el-form-item label="测评时间">
          <el-date-picker v-model="schemeForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="测评说明">
          <el-input v-model="schemeForm.remark" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="schemeDialog = false">取消</el-button>
        <el-button type="primary" @click="schemeDialog = false">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="民主测评结果" v-model="resultDialog" width="700px">
      <div style="margin-bottom:12px;font-weight:bold">{{ currentScheme?.name }}</div>
      <el-table :data="resultData" border size="small">
        <el-table-column type="index" label="排名" width="60" align="center" />
        <el-table-column prop="name" label="测评对象" width="100" align="center" />
        <el-table-column prop="de" label="德(25分)" width="90" align="center" />
        <el-table-column prop="neng" label="能(25分)" width="90" align="center" />
        <el-table-column prop="qin" label="勤(20分)" width="90" align="center" />
        <el-table-column prop="ji" label="绩(20分)" width="90" align="center" />
        <el-table-column prop="lian" label="廉(10分)" width="90" align="center" />
        <el-table-column prop="total" label="总分" width="80" align="center">
          <template #default="{ row }">
            <span style="font-weight:bold;color:#1976D2">{{ row.total }}</span>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus, Upload, Download } from '@element-plus/icons-vue'
import { importExcel, mapImportData } from '@/utils/excel'
import { showExportDialog } from '@/utils/export-store'

const activeTab = ref('annual')
const schemeDialog = ref(false)
const resultDialog = ref(false)
const currentScheme = ref(null)
const importDialogVisible = ref(false)
const importPreviewData = ref([])
const importing = ref(false)

const search = reactive({
  annual: { year: '', name: '', result: '' }
})

const annualPool = ref([
  { name: '张建国', department: '机械工程学院', position: '院长', year: '2025', result: '优秀', comment: '政治立场坚定，工作业绩突出，带领学院取得显著发展' },
  { name: '李秀英', department: '电子信息学院', position: '党委书记', year: '2025', result: '优秀', comment: '党建工作扎实，班子团结有力，群众威信高' },
  { name: '王志强', department: '教务处', position: '处长', year: '2025', result: '称职', comment: '工作认真负责，教学管理规范，较好完成各项任务' },
  { name: '刘德明', department: '人事处', position: '副处长', year: '2025', result: '称职', comment: '业务能力较强，工作积极主动，配合处长做好工作' },
  { name: '陈丽华', department: '财务处', position: '处长', year: '2025', result: '基本称职', comment: '财务工作基本规范，但创新意识有待加强' },
  { name: '赵国栋', department: '后勤管理处', position: '处长', year: '2025', result: '称职', comment: '后勤保障有力，服务意识较强，校园环境改善明显' }
])

const annualData = computed(() => {
  let data = annualPool.value
  const s = search.annual
  if (s.year) data = data.filter(d => d.year === s.year)
  if (s.name) data = data.filter(d => d.name.includes(s.name))
  if (s.result) data = data.filter(d => d.result === s.result)
  return data
})

const schemeData = [
  { name: '2025年度中层干部民主测评', year: '2025', startDate: '2026-01-10', endDate: '2026-01-20', targetCount: 45, voterCount: 128, status: '已结束' },
  { name: '2025年度机关作风民主测评', year: '2025', startDate: '2026-02-01', endDate: '2026-02-10', targetCount: 20, voterCount: 200, status: '进行中' },
  { name: '2026年新任干部试用期满测评', year: '2026', startDate: '2026-08-15', endDate: '2026-08-25', targetCount: 8, voterCount: 0, status: '草稿' }
]

const schemeForm = reactive({
  name: '', year: '', dateRange: [], remark: ''
})

const resultData = [
  { name: '张建国', de: 24.2, neng: 23.8, qin: 19.5, ji: 19.2, lian: 9.8, total: 96.5 },
  { name: '李秀英', de: 24.5, neng: 23.5, qin: 19.0, ji: 18.8, lian: 9.9, total: 95.7 },
  { name: '王志强', de: 23.0, neng: 22.5, qin: 18.5, ji: 18.0, lian: 9.5, total: 91.5 },
  { name: '刘德明', de: 22.8, neng: 22.0, qin: 18.2, ji: 17.5, lian: 9.6, total: 90.1 },
  { name: '赵国栋', de: 22.5, neng: 21.8, qin: 18.0, ji: 17.8, lian: 9.4, total: 89.5 }
]

function resultTagType(result) {
  const map = { '优秀': 'success', '称职': '', '基本称职': 'warning', '不称职': 'danger' }
  return map[result] || ''
}

function resetSearch() {
  search.annual = { year: '', name: '', result: '' }
}

function handleAnnualSearch() {
  ElMessage.success('查询条件已应用')
}

function handleAddAnnual() {
  ElMessage.info('新增年度考核记录功能')
}

function handleViewAnnual(row) {
  ElMessage.info(`查看 ${row.name} 的年度考核详情`)
}

function handleEditAnnual(row) {
  ElMessage.info(`编辑 ${row.name} 的年度考核记录`)
}

function handlePrintAnnual(row) {
  ElMessage.success(`正在打印 ${row.name} 的年度考核表`)
}

function handleDeleteAnnual(row) {
  const idx = annualPool.value.findIndex(d => d.name === row.name)
  if (idx > -1) annualPool.value.splice(idx, 1)
  ElMessage.success(`已删除 ${row.name} 的年度考核记录`)
}

function openResult(row) {
  currentScheme.value = row
  resultDialog.value = true
}

function exportAnnual() {
  showExportDialog(annualData.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'department', label: '部门' },
    { prop: 'position', label: '职务' },
    { prop: 'year', label: '年度' },
    { prop: 'result', label: '考核结果' },
    { prop: 'comment', label: '评语' }
  ], '年度考核')
}

function exportScheme() {
  showExportDialog(schemeData, [
    { prop: 'name', label: '方案名称' },
    { prop: 'year', label: '年度' },
    { prop: 'startDate', label: '开始时间' },
    { prop: 'endDate', label: '结束时间' },
    { prop: 'targetCount', label: '测评对象' },
    { prop: 'voterCount', label: '参评人数' },
    { prop: 'status', label: '状态' }
  ], '民主测评方案')
}

function handleImport() { importDialogVisible.value = true }
async function handleImportFile(file) {
  try {
    const raw = await importExcel(file.raw)
    const mapped = mapImportData(raw, {
      '姓名': 'name', '部门': 'department', '职务': 'position',
      '年度': 'year', '考核结果': 'result', '评语': 'comment'
    })
    importPreviewData.value = mapped
  } catch(e) { ElMessage.error(e.message); importPreviewData.value = [] }
}
function confirmImport() {
  if (importPreviewData.value.length === 0) { ElMessage.warning('没有可导入的数据'); return }
  importing.value = true
  setTimeout(() => {
    importPreviewData.value.forEach(item => annualPool.value.unshift(item))
    ElMessage.success(`成功导入 ${importPreviewData.value.length} 条记录`)
    importDialogVisible.value = false
    importPreviewData.value = []
    importing.value = false
  }, 400)
}
function handleCancelImport() { importDialogVisible.value = false; importPreviewData.value = [] }
</script>

<style scoped>
.gov-tabs :deep(.el-tabs__header) {
  background: #fff;
  margin: 0;
  padding: 0 14px;
  border: 1px solid #e0e0e0;
  border-bottom: 2px solid #1976D2;
}
.gov-tabs :deep(.el-tabs__nav-wrap::after) {
  display: none;
}
.gov-tabs :deep(.el-tabs__content) {
  padding-top: 0;
}
</style>
