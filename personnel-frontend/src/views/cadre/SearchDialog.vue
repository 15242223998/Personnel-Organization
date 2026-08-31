<template>
  <el-dialog v-model="visible" title="多模式便捷查询" width="95%" top="2vh" destroy-on-close class="search-dialog">
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

      <el-tab-pane label="标签查询" name="tag">
        <el-row :gutter="16">
          <el-col :span="18">
            <div class="tag-category">
              <div class="tag-cat-title">基础干部标记条件</div>
              <div class="tag-group">
                <span class="tag-label">储备类别：</span>
                <el-checkbox-group v-model="tags.reserve" @change="doTagSearch" size="small">
                  <el-checkbox label="后备干部" border /> <el-checkbox label="优秀年轻干部" border /> <el-checkbox label="中长期培养对象" border />
                </el-checkbox-group>
              </div>
              <div class="tag-group">
                <span class="tag-label">选任方式：</span>
                <el-checkbox-group v-model="tags.selectMethod" @change="doTagSearch" size="small">
                  <el-checkbox label="民主推荐" border /> <el-checkbox label="公开选拔" border /> <el-checkbox label="竞争上岗" border /> <el-checkbox label="调任" border />
                </el-checkbox-group>
              </div>
              <div class="tag-group">
                <span class="tag-label">干部来源：</span>
                <el-checkbox-group v-model="tags.cadreSource" @change="doTagSearch" size="small">
                  <el-checkbox label="校内提拔" border /> <el-checkbox label="校外调入" border /> <el-checkbox label="军转安置" border />
                </el-checkbox-group>
              </div>
              <div class="tag-group">
                <span class="tag-label">专项标记：</span>
                <el-checkbox-group v-model="tags.special" @change="doTagSearch" size="small">
                  <el-checkbox label="裸官标记" border /> <el-checkbox label="军转安置" border /> <el-checkbox label="挂职外派" border /> <el-checkbox label="基层经历≥3年" border />
                </el-checkbox-group>
              </div>
            </div>

            <div class="tag-category">
              <div class="tag-cat-title">岗位工作经历</div>
              <div class="tag-group">
                <el-checkbox-group v-model="tags.workExp" @change="doTagSearch" size="small">
                  <el-checkbox label="思政教师" border /> <el-checkbox label="辅导员" border /> <el-checkbox label="机关任职" border />
                  <el-checkbox label="支教驻村" border /> <el-checkbox label="校内挂职" border /> <el-checkbox label="多部门轮岗" border />
                  <el-checkbox label="实验室管理" border /> <el-checkbox label="教学管理" border />
                </el-checkbox-group>
              </div>
            </div>

            <div class="tag-category">
              <div class="tag-cat-title">业务熟悉领域</div>
              <div class="tag-group">
                <el-checkbox-group v-model="tags.business" @change="doTagSearch" size="small">
                  <el-checkbox label="党建纪检" border /> <el-checkbox label="人事学生管理" border /> <el-checkbox label="后勤基建" border />
                  <el-checkbox label="科研管理" border /> <el-checkbox label="行政文秘" border /> <el-checkbox label="教育管理" border />
                  <el-checkbox label="财务审计" border /> <el-checkbox label="外事管理" border /> <el-checkbox label="信息化建设" border />
                  <el-checkbox label="招生就业" border />
                </el-checkbox-group>
              </div>
            </div>

            <div class="tag-category">
              <div class="tag-cat-title">年轻干部专项筛选</div>
              <div class="tag-group">
                <el-checkbox-group v-model="tags.young" @change="doTagSearch" size="small">
                  <el-checkbox label="选调生" border /> <el-checkbox label="高校优秀毕业生" border /> <el-checkbox label="大学生村官" border />
                  <el-checkbox label="学生干部经历" border /> <el-checkbox label="985/211院校" border /> <el-checkbox label="本届政治安排" border />
                  <el-checkbox label="海外留学背景" border /> <el-checkbox label="博士学历" border />
                </el-checkbox-group>
              </div>
            </div>
          </el-col>

          <el-col :span="6">
            <div class="result-panel">
              <div class="result-header">
                <span>筛选结果 ({{ tagResults.length }}人)</span>
                <span class="link-blue" style="float:right;font-size:12px" @click="resetTags">清空标签</span>
              </div>
              <div class="result-list">
                <div v-for="(item, idx) in tagResults" :key="item.id" class="result-item">
                  <span class="result-idx">{{ idx + 1 }}</span>
                  <span class="result-name">{{ item.name }}</span>
                  <span class="result-dept">{{ item.deptName }}</span>
                  <el-icon class="result-del" @click="removeFromResults(item)"><Close /></el-icon>
                </div>
                <div v-if="tagResults.length === 0 && hasTagFilter" class="empty-hint">无匹配结果</div>
                <div v-if="!hasTagFilter" class="empty-hint">请选择标签条件进行筛选</div>
              </div>
            </div>
          </el-col>
        </el-row>
      </el-tab-pane>

      <el-tab-pane label="高级查询" name="advanced">
        <el-form :model="advForm" label-width="110px" size="default">
          <el-row :gutter="16">
            <el-col :span="8"><el-form-item label="姓名"><el-input v-model="advForm.name" clearable /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="身份证号"><el-input v-model="advForm.idCard" clearable /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="出生年月起"><el-input v-model="advForm.birthFrom" placeholder="1980-01" clearable /></el-form-item></el-col>
          </el-row>
          <el-row :gutter="16">
            <el-col :span="8"><el-form-item label="出生年月止"><el-input v-model="advForm.birthTo" placeholder="2000-12" clearable /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="政治面貌"><el-select v-model="advForm.politicalStatus" clearable style="width:100%"><el-option label="中共党员" value="中共党员" /><el-option label="民主党派" value="民主党派" /><el-option label="群众" value="群众" /></el-select></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="民族"><el-select v-model="advForm.ethnicity" clearable style="width:100%"><el-option label="汉族" value="汉族" /><el-option label="蒙古族" value="蒙古族" /><el-option label="回族" value="回族" /><el-option label="藏族" value="藏族" /></el-select></el-form-item></el-col>
          </el-row>
          <el-row :gutter="16">
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
        <span>查询结果：共 <b>{{ searchResults.length }}</b> 人</span>
        <el-button size="small" @click="handleRefresh">刷新</el-button>
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
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleRemoveItem(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <template #footer>
      <el-button @click="visible = false">关闭</el-button>
      <el-button type="primary" @click="handleExportResult"><el-icon><Download /></el-icon> 导出结果</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Close, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'

const props = defineProps({ modelValue: Boolean, allData: Array, deptList: Array })
const emit = defineEmits(['update:modelValue', 'viewDetail'])

const visible = computed({
  get: () => props.modelValue,
  set: (v) => emit('update:modelValue', v)
})

const depts = computed(() => props.deptList || [])
const searchMode = ref('tag')
const searchResults = ref([])

// Quick
const quick = reactive({ name: '', deptId: null, positionLevel: '', cadreStatus: '' })
function resetQuick() { Object.assign(quick, { name: '', deptId: null, positionLevel: '', cadreStatus: '' }); doSearch() }

// Fixed
const fixedQuery = ref('')
const fixedQueries = [
  { key: 'middleLevel', label: '中层干部' },
  { key: 'youngMiddle', label: '40岁以下中层' },
  { key: 'femaleCadre', label: '女干部' },
  { key: 'minority', label: '少数民族干部' },
  { key: 'nonParty', label: '党外干部' },
  { key: 'doctorDegree', label: '博士学历' },
  { key: 'fiveYear', label: '任现职5年以上' },
  { key: 'newlyAppointed', label: '近1年新任职' },
  { key: 'retireSoon', label: '3年内退休' },
  { key: 'reserveList', label: '后备干部名册' }
]

// Tag
const tags = reactive({
  reserve: [], selectMethod: [], cadreSource: [], special: [],
  workExp: [], business: [], young: []
})
const hasTagFilter = computed(() => Object.values(tags).some(arr => arr.length > 0))
const tagResults = ref([])

function resetTags() {
  Object.keys(tags).forEach(k => tags[k] = [])
  tagResults.value = []
  searchResults.value = []
}

// Advanced
const advForm = reactive({ name: '', idCard: '', birthFrom: '', birthTo: '', politicalStatus: '', ethnicity: '' })
function resetAdv() { Object.assign(advForm, { name: '', idCard: '', birthFrom: '', birthTo: '', politicalStatus: '', ethnicity: '' }); doSearch() }

function doSearch() {
  let data = [...(props.allData || [])]
  const mode = searchMode.value

  if (mode === 'quick') {
    if (quick.name) data = data.filter(d => d.name.includes(quick.name))
    if (quick.deptId) data = data.filter(d => d.deptId === quick.deptId)
    if (quick.positionLevel) data = data.filter(d => d.positionLevel === quick.positionLevel)
    if (quick.cadreStatus) data = data.filter(d => d.cadreStatus === quick.cadreStatus)
  } else if (mode === 'fixed') {
    if (fixedQuery.value === 'middleLevel') data = data.filter(d => d.positionLevel === '处级')
    else if (fixedQuery.value === 'youngMiddle') { const cutoff = new Date().getFullYear() - 40; data = data.filter(d => d.positionLevel === '处级' && d.birthDate && parseInt(d.birthDate.substring(0,4)) >= cutoff) }
    else if (fixedQuery.value === 'femaleCadre') data = data.filter(d => d.gender === 2)
    else if (fixedQuery.value === 'nonParty') data = data.filter(d => d.politicalStatus !== '中共党员')
    else if (fixedQuery.value === 'doctorDegree') data = data.filter(d => d.education && d.education.includes('博士'))
    else if (fixedQuery.value === 'fiveYear') data = data.filter(d => d.positionStartDate && d.positionStartDate.substring(0,4) <= String(new Date().getFullYear() - 5))
    else if (fixedQuery.value === 'newlyAppointed') data = data.filter(d => d.positionStartDate && d.positionStartDate.substring(0,4) >= String(new Date().getFullYear() - 1))
    else if (fixedQuery.value === 'retireSoon') { const cutoff = new Date().getFullYear() - 57; data = data.filter(d => d.birthDate && parseInt(d.birthDate.substring(0,4)) <= cutoff) }
  } else if (mode === 'advanced') {
    if (advForm.name) data = data.filter(d => d.name.includes(advForm.name))
    if (advForm.politicalStatus) data = data.filter(d => d.politicalStatus === advForm.politicalStatus)
    if (advForm.birthFrom) data = data.filter(d => d.birthDate >= advForm.birthFrom)
    if (advForm.birthTo) data = data.filter(d => d.birthDate <= advForm.birthTo)
  }

  searchResults.value = data
}

function doTagSearch() {
  if (!hasTagFilter.value) { tagResults.value = []; return }
  let data = [...(props.allData || [])]

  // Simulate tag matching by distributing tags across mock data
  const tagScore = {}
  const allTags = [...tags.reserve, ...tags.selectMethod, ...tags.cadreSource, ...tags.special, ...tags.workExp, ...tags.business, ...tags.young]
  
  data.forEach((d, idx) => {
    let score = 0
    allTags.forEach(tag => {
      const hash = tag.split('').reduce((a, c) => a + c.charCodeAt(0), 0)
      if ((d.id + hash) % 3 === 0) score++
    })
    if (score >= Math.max(1, Math.floor(allTags.length / 3))) tagScore[d.id] = score
  })

  tagResults.value = data.filter(d => tagScore[d.id])
  searchResults.value = tagResults.value
}

function removeFromResults(item) {
  tagResults.value = tagResults.value.filter(d => d.id !== item.id)
  searchResults.value = searchResults.value.filter(d => d.id !== item.id)
}

function handleRemoveItem(row) {
  searchResults.value = searchResults.value.filter(d => d.id !== row.id)
  tagResults.value = tagResults.value.filter(d => d.id !== row.id)
  ElMessage.success('已从结果中移除')
}

function handleRefresh() { doSearch(); doTagSearch() }

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
.tag-category { margin-bottom: 16px; border: 1px solid #e8e8e8; border-radius: 4px; padding: 12px; }
.tag-cat-title { font-size: 13px; font-weight: 600; color: #1976D2; margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px dashed #d0d0d0; }
.tag-group { margin-bottom: 8px; display: flex; align-items: center; flex-wrap: wrap; gap: 6px; }
.tag-label { font-size: 12px; color: #666; min-width: 70px; }
.tag-group :deep(.el-checkbox) { margin-right: 4px; }
.tag-group :deep(.el-checkbox.is-bordered) { padding: 4px 10px; margin-right: 4px; }
.result-panel { border: 1px solid #e8e8e8; border-radius: 4px; height: 100%; }
.result-header { padding: 10px 12px; font-size: 13px; font-weight: 600; border-bottom: 1px solid #e8e8e8; background: #f8f9fa; }
.result-list { max-height: 520px; overflow-y: auto; }
.result-item { display: flex; align-items: center; padding: 6px 12px; border-bottom: 1px solid #f0f0f0; font-size: 13px; }
.result-item:hover { background: #e3f2fd; }
.result-idx { width: 24px; color: #999; font-size: 12px; }
.result-name { flex: 1; font-weight: 500; }
.result-dept { color: #888; font-size: 12px; margin: 0 8px; }
.result-del { color: #ccc; cursor: pointer; font-size: 14px; }
.result-del:hover { color: #E53935; }
.empty-hint { padding: 40px; text-align: center; color: #999; font-size: 13px; }
</style>
