<template>
  <div>
    <div class="page-header">干部信息详情 - {{ isNew ? '新增干部档案' : (form.name || '加载中...') }}</div>

    <div class="detail-card">
      <div class="toolbar">
        <el-button @click="handleBack"><el-icon><ArrowLeft /></el-icon> 返回</el-button>
        <el-button v-if="!isEditMode" type="primary" @click="toggleEdit"><el-icon><Edit /></el-icon> 编辑</el-button>
        <el-button v-if="isEditMode" type="primary" :loading="saveLoading" @click="handleSave"><el-icon><Check /></el-icon> 保存</el-button>
        <el-button v-if="isEditMode" @click="cancelEdit"><el-icon><Close /></el-icon> 取消</el-button>
        <el-button type="success" @click="handleExport"><el-icon><Download /></el-icon> 导出任免表</el-button>
      </div>

      <el-tabs v-model="activeTab" class="detail-tabs">
        <el-tab-pane label="基础信息" name="basic">
          <div class="basic-section">
            <div class="form-area">
              <el-form
                ref="basicFormRef"
                :model="form"
                :rules="basicRules"
                label-width="110px"
                :disabled="!isEditMode"
                size="default"
              >
                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item label="姓名" prop="name">
                      <el-input v-model="form.name" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="性别" prop="gender">
                      <el-select v-model="form.gender" style="width:100%" placeholder="请选择">
                        <el-option label="男" :value="1" />
                        <el-option label="女" :value="2" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="出生年月" prop="birthDate">
                      <el-date-picker v-model="form.birthDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="民族" prop="nation">
                      <el-input v-model="form.nation" placeholder="请输入民族" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="籍贯" prop="nativePlace">
                      <el-input v-model="form.nativePlace" placeholder="请输入籍贯" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="政治面貌" prop="politicalStatus">
                      <el-select v-model="form.politicalStatus" style="width:100%" placeholder="请选择">
                        <el-option label="中共党员" value="中共党员" />
                        <el-option label="中共预备党员" value="中共预备党员" />
                        <el-option label="共青团员" value="共青团员" />
                        <el-option label="民主党派" value="民主党派" />
                        <el-option label="群众" value="群众" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="入党时间" prop="partyJoinDate">
                      <el-date-picker v-model="form.partyJoinDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="参加工作时间" prop="workStartDate">
                      <el-date-picker v-model="form.workStartDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="身份证" prop="idCard">
                      <el-input v-model="form.idCard" placeholder="请输入身份证号" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="手机" prop="phone">
                      <el-input v-model="form.phone" placeholder="请输入手机号" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item label="邮箱" prop="email">
                      <el-input v-model="form.email" placeholder="请输入邮箱地址" />
                    </el-form-item>
                  </el-col>
                </el-row>
              </el-form>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="学历学位" name="education">
          <div class="edu-section">
            <div class="edu-block">
              <div class="edu-title">
                <el-icon color="#1976D2"><School /></el-icon>
                <span>全日制教育</span>
              </div>
              <el-form
                ref="eduFullFormRef"
                :model="form"
                label-width="100px"
                :disabled="!isEditMode"
              >
                <el-row :gutter="20">
                  <el-col :span="8">
                    <el-form-item label="学历">
                      <el-select v-model="form.fullTimeEducation" style="width:100%" placeholder="请选择">
                        <el-option label="博士研究生" value="博士研究生" />
                        <el-option label="硕士研究生" value="硕士研究生" />
                        <el-option label="本科" value="本科" />
                        <el-option label="大专" value="大专" />
                        <el-option label="高中" value="高中" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="学位">
                      <el-select v-model="form.fullTimeDegree" style="width:100%" placeholder="请选择">
                        <el-option label="博士" value="博士" />
                        <el-option label="硕士" value="硕士" />
                        <el-option label="学士" value="学士" />
                        <el-option label="无" value="无" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="院校专业">
                      <el-input v-model="form.fullTimeSchool" placeholder="请输入毕业院校及专业" />
                    </el-form-item>
                  </el-col>
                </el-row>
              </el-form>
            </div>
            <div class="edu-block">
              <div class="edu-title">
                <el-icon color="#1976D2"><Reading /></el-icon>
                <span>在职教育</span>
              </div>
              <el-form
                ref="eduPartFormRef"
                :model="form"
                label-width="100px"
                :disabled="!isEditMode"
              >
                <el-row :gutter="20">
                  <el-col :span="8">
                    <el-form-item label="学历">
                      <el-select v-model="form.partTimeEducation" style="width:100%" placeholder="请选择">
                        <el-option label="博士研究生" value="博士研究生" />
                        <el-option label="硕士研究生" value="硕士研究生" />
                        <el-option label="本科" value="本科" />
                        <el-option label="大专" value="大专" />
                        <el-option label="高中" value="高中" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="学位">
                      <el-select v-model="form.partTimeDegree" style="width:100%" placeholder="请选择">
                        <el-option label="博士" value="博士" />
                        <el-option label="硕士" value="硕士" />
                        <el-option label="学士" value="学士" />
                        <el-option label="无" value="无" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="院校专业">
                      <el-input v-model="form.partTimeSchool" placeholder="请输入毕业院校及专业" />
                    </el-form-item>
                  </el-col>
                </el-row>
              </el-form>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="任职信息" name="position">
          <el-form
            ref="posFormRef"
            :model="form"
            label-width="110px"
            :disabled="!isEditMode"
          >
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="所属机构">
                  <el-select v-model="form.deptId" placeholder="请选择机构" style="width:100%" filterable>
                    <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.id" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="职务">
                  <el-input v-model="form.position" placeholder="请输入职务" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="职务层次">
                  <el-select v-model="form.positionLevel" placeholder="请选择职务层次" style="width:100%">
                    <el-option v-for="l in positionLevelOptions" :key="l" :label="l" :value="l" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="职级">
                  <el-select v-model="form.rankId" placeholder="请选择职级" style="width:100%">
                    <el-option v-for="r in rankList" :key="r.id" :label="r.rankName" :value="r.id" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="任现职时间">
                  <el-date-picker v-model="form.positionStartDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="任职文号">
                  <el-input v-model="form.positionDocNo" placeholder="请输入任职文号" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="在库状态">
                  <el-select v-model="form.cadreStatus" style="width:100%">
                    <el-option label="在职" value="ON_JOB" />
                    <el-option label="离退休" value="RETIRED" />
                    <el-option label="已调出" value="TRANSFERRED" />
                    <el-option label="已辞职" value="RESIGNED" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="家庭成员" name="family">
          <div class="sub-table-bar">
            <span class="sub-title">家庭成员列表</span>
            <el-button v-if="isEditMode" type="primary" @click="openFamilyAdd"><el-icon><Plus /></el-icon> 新增</el-button>
          </div>
          <el-table :data="familyList" border size="small">
            <el-table-column type="index" label="序号" width="60" align="center" />
            <el-table-column prop="memberName" label="姓名" width="120" align="center" />
            <el-table-column prop="relation" label="关系" width="100" align="center" />
            <el-table-column prop="workplace" label="工作单位" min-width="200" show-overflow-tooltip />
            <el-table-column prop="phone" label="电话" width="140" align="center" />
            <el-table-column v-if="isEditMode" label="操作" width="90" align="center" fixed="right">
              <template #default="{ row }">
                <el-button link type="danger" @click="delFamily(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-alert v-if="familyList.length === 0" type="info" :closable="false" show-icon style="margin-top:12px"
            title="家庭成员由档案库统一维护，此处展示该干部在档案库中的真实成员记录" />
        </el-tab-pane>

        <el-tab-pane label="佐证材料" name="evidence">
          <div class="sub-table-bar">
            <span class="sub-title">佐证材料列表</span>
            <el-upload
              v-if="isEditMode"
              action="#"
              :http-request="handleUpload"
              :show-file-list="false"
            >
              <el-button type="primary"><el-icon><Upload /></el-icon> 登记材料</el-button>
            </el-upload>
          </div>
          <el-table :data="evidenceFiles" border size="small">
            <el-table-column prop="fileName" label="文件名" min-width="220" show-overflow-tooltip />
            <el-table-column prop="fileType" label="类型" width="90" align="center" />
            <el-table-column prop="fileSizeText" label="大小" width="100" align="center" />
            <el-table-column prop="createTime" label="登记时间" width="160" align="center" />
            <el-table-column label="操作" width="90" align="center" fixed="right">
              <template #default="{ row }">
                <el-button v-if="isEditMode" link type="danger" @click="delEvidence(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-alert type="info" :closable="false" style="margin-top:12px"
            title="佐证材料由档案库统一维护；本处登记文件元数据，文件实体由档案管理部门线下归档保管" />
        </el-tab-pane>

        <el-tab-pane label="简历" name="resume">
          <el-form :model="form" label-width="0" :disabled="!isEditMode">
            <el-form-item>
              <el-input
                v-model="form.resumeText"
                type="textarea"
                :rows="16"
                placeholder="请输入干部简历信息..."
                class="resume-textarea"
              />
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="考核测评" name="assessment">
          <div class="sub-table-bar">
            <span class="sub-title">年度考核记录（档案 annual_assessment 字段 + 年度考核管理 assessment_annual 合并展示）</span>
          </div>
          <el-table :data="assessmentRows" border size="small" v-loading="assessmentLoading">
            <el-table-column prop="year" label="考核年度" width="110" align="center" />
            <el-table-column label="考核结果" width="150" align="center">
              <template #default="{ row }">
                <el-tag v-if="row.result" :type="resultTagType(row.result)" size="small">{{ row.result }}</el-tag>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column prop="assessmentTime" label="考核时间" width="170" align="center">
              <template #default="{ row }">{{ row.assessmentTime || '-' }}</template>
            </el-table-column>
            <el-table-column label="备注" min-width="220" show-overflow-tooltip>
              <template #default="{ row }">{{ row.comment || '-' }}</template>
            </el-table-column>
            <template #empty>
              <el-empty :image-size="60" description="暂无考核记录" />
            </template>
          </el-table>
          <el-alert type="info" :closable="false" show-icon style="margin-top:12px"
            title="“近三年考核称职以上”判定口径：最近三个自然年（当前年-2 至 当前年）内，最近两个关键年份（如当前年 2026 时的 2024、2025）均须存在称职以上记录，且任一年度结果不含“基本称职/不称职”；当年考核通常年末开展、暂缺不视为缺失。" />
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog
      :title="familyDialogTitle"
      v-model="familyDialogVisible"
      width="520px"
      :close-on-click-modal="false"
    >
      <el-form ref="familyFormRef" :model="familyForm" label-width="90px" size="default">
        <el-form-item label="姓名" prop="memberName" :rules="[{ required: true, message: '请输入姓名', trigger: 'blur' }]">
          <el-input v-model="familyForm.memberName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="关系" prop="relation" :rules="[{ required: true, message: '请选择关系', trigger: 'change' }]">
          <el-select v-model="familyForm.relation" style="width:100%" placeholder="请选择关系">
            <el-option label="配偶" value="配偶" />
            <el-option label="父亲" value="父亲" />
            <el-option label="母亲" value="母亲" />
            <el-option label="儿子" value="儿子" />
            <el-option label="女儿" value="女儿" />
            <el-option label="兄弟" value="兄弟" />
            <el-option label="姐妹" value="姐妹" />
          </el-select>
        </el-form-item>
        <el-form-item label="工作单位" prop="workplace">
          <el-input v-model="familyForm.workplace" placeholder="请输入工作单位" />
        </el-form-item>
        <el-form-item label="电话" prop="phone">
          <el-input v-model="familyForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="familyDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="familySaving" @click="handleFamilySave">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft, Edit, Check, Close, Download, Upload, Plus,
  School, Reading
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import { getCadreDetail, addCadre } from '@/api/cadre'

const route = useRoute()
const router = useRouter()
const activeTab = ref('basic')
const saveLoading = ref(false)
const familySaving = ref(false)
const isEditMode = ref(false)
const familyDialogVisible = ref(false)
const basicFormRef = ref(null)
const familyFormRef = ref(null)
const cadreId = ref(null)

const isNew = computed(() => route.params.id === 'new' || route.params.id == null)

const deptOptions = ref([])
const rankList = ref([])
const positionLevelOptions = ['校级', '处级', '科级', '正厅级', '副厅级', '正处级', '副处级', '正科级', '副科级', '科员']

const emptyForm = () => ({
  id: null,
  name: '',
  gender: null,
  birthDate: null,
  nation: '',
  nativePlace: '',
  politicalStatus: '',
  partyJoinDate: null,
  workStartDate: null,
  idCard: '',
  phone: '',
  email: '',
  fullTimeEducation: '',
  fullTimeDegree: '',
  fullTimeSchool: '',
  partTimeEducation: '',
  partTimeDegree: '',
  partTimeSchool: '',
  deptId: null,
  position: '',
  positionLevel: '',
  rankId: null,
  positionStartDate: null,
  positionDocNo: '',
  resumeText: '',
  rewardPunishment: '',
  cadreStatus: 'ON_JOB'
})

const form = reactive(emptyForm())
const backupForm = ref(null)

const familyList = ref([])
const evidenceFiles = ref([])
const familyForm = reactive({ memberName: '', relation: '', workplace: '', phone: '' })

const basicRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  gender: [{ required: true, message: '请选择性别', trigger: 'change' }]
}

const familyDialogTitle = computed(() => '添加家庭成员')

function fmtTime(t) {
  return t ? String(t).replace('T', ' ').substring(0, 16) : ''
}

function fmtSize(bytes) {
  if (bytes == null) return '-'
  const n = Number(bytes)
  if (n < 1024) return n + 'B'
  if (n < 1024 * 1024) return (n / 1024).toFixed(0) + 'KB'
  return (n / 1024 / 1024).toFixed(1) + 'MB'
}

async function loadDict() {
  const [treeRes, rankRes] = await Promise.all([
    request.get('/organization/tree').catch(() => null),
    request.get('/rank/list').catch(() => null)
  ])
  const list = []
  const walk = nodes => {
    if (!Array.isArray(nodes)) return
    nodes.forEach(o => {
      if (o && o.id != null) list.push({ id: o.id, deptName: o.deptName || o.shortName || '' })
      walk(o.children)
    })
  }
  walk(treeRes && treeRes.data)
  deptOptions.value = list
  if (rankRes && Array.isArray(rankRes.data)) {
    rankList.value = rankRes.data.map(r => ({ id: r.id, rankName: r.rankName }))
  }
}

async function loadDetail() {
  if (isNew.value) {
    Object.assign(form, emptyForm())
    isEditMode.value = true
    return
  }
  const id = Number(route.params.id)
  if (!id) {
    ElMessage.error('干部档案标识无效')
    return
  }
  cadreId.value = id
  try {
    const res = await getCadreDetail(id)
    const raw = res.data || {}
    annualAssessmentRaw.value = raw.annualAssessment || ''
    Object.assign(form, {
      id: raw.id,
      name: raw.name || '',
      gender: raw.gender ?? null,
      birthDate: raw.birthDate || null,
      nation: raw.nation || '',
      nativePlace: raw.nativePlace || '',
      politicalStatus: raw.politicalStatus || '',
      partyJoinDate: raw.partyJoinDate || null,
      workStartDate: raw.workStartDate || null,
      idCard: raw.idCard || '',
      phone: raw.phone || '',
      email: raw.email || '',
      fullTimeEducation: raw.fullTimeEducation || '',
      fullTimeDegree: raw.fullTimeDegree || '',
      fullTimeSchool: raw.fullTimeSchool || '',
      partTimeEducation: raw.partTimeEducation || '',
      partTimeDegree: raw.partTimeDegree || '',
      partTimeSchool: raw.partTimeSchool || '',
      deptId: raw.deptId ?? null,
      position: raw.position || '',
      positionLevel: raw.positionLevel || '',
      rankId: raw.rankId ?? null,
      positionStartDate: raw.positionStartDate || null,
      positionDocNo: raw.positionDocNo || '',
      resumeText: raw.resumeText || '',
      rewardPunishment: raw.rewardPunishment || '',
      cadreStatus: raw.cadreStatus || 'ON_JOB'
    })
    // 家庭成员：后端详情已带 familyMembers；仍以独立接口为准刷新
    await loadFamily()
    await loadAttachments()
    if (route.query.edit === '1') {
      toggleEdit()
    }
  } catch (e) {
    ElMessage.error(e.message || '加载干部档案失败')
  }
}

async function loadFamily() {
  if (cadreId.value == null) return
  try {
    const res = await request.get(`/cadre/${cadreId.value}/family/list`)
    familyList.value = Array.isArray(res.data) ? res.data.map(m => ({
      id: m.id,
      memberName: m.memberName || '',
      relation: m.relation || '',
      workplace: m.workplace || '',
      phone: m.phone || ''
    })) : []
  } catch (e) {
    familyList.value = []
  }
}

async function loadAttachments() {
  if (cadreId.value == null) return
  try {
    const res = await request.get(`/cadre/${cadreId.value}/attachment/list`)
    evidenceFiles.value = Array.isArray(res.data) ? res.data.map(a => ({
      id: a.id,
      fileName: a.fileName || '',
      fileType: a.fileType || '',
      fileSizeText: fmtSize(a.fileSize),
      createTime: fmtTime(a.createTime)
    })) : []
  } catch (e) {
    evidenceFiles.value = []
  }
}

// ---------- 考核测评：档案 annual_assessment 与 assessment_annual 记录合并 ----------
// 年度考核记录调已有接口 GET /annual/list（assessment_annual 原始实体，含登记时间 create_time 与评语
// assessment_comment；/annual/page 的 AnnualVO 不含登记时间，故详情页按干部 cadreId 过滤 list 合并，后端不改动）。
function parseAnnualRaw(raw) {
  const map = {}
  if (!raw) return map
  String(raw).split(/[;；]/).forEach(part => {
    const item = (part || '').trim()
    if (!item) return
    const m = item.match(/^(\d{4})\s*[:：]\s*(.+)$/)
    if (m) map[Number(m[1])] = m[2].trim()
  })
  return map
}

async function loadAnnualRecords() {
  if (cadreId.value == null) return
  assessmentLoading.value = true
  try {
    const res = await request.get('/annual/list').catch(() => null)
    const list = (res && Array.isArray(res.data)) ? res.data : []
    const records = list.filter(r => Number(r.cadreId) === cadreId.value)
    const detailMap = parseAnnualRaw(annualAssessmentRaw.value)
    const years = new Set()
    Object.keys(detailMap).forEach(y => years.add(Number(y)))
    records.forEach(r => { if (r.assessmentYear != null) years.add(Number(r.assessmentYear)) })
    const sorted = [...years].filter(n => Number.isFinite(n)).sort((a, b) => b - a)
    assessmentRows.value = sorted.map(y => {
      const rec = records.find(r => Number(r.assessmentYear) === y)
      return {
        year: String(y),
        result: rec ? (rec.assessmentResult || detailMap[y] || '') : (detailMap[y] || ''),
        assessmentTime: rec ? fmtTime(rec.createTime) : '',
        comment: rec ? (rec.assessmentComment || '') : ''
      }
    })
  } catch (e) {
    assessmentRows.value = []
  } finally {
    assessmentLoading.value = false
  }
}

function resultTagType(result) {
  if (!result) return 'info'
  if (['优秀', '称职', '合格'].includes(result)) return 'success'
  if (result === '基本称职') return 'warning'
  if (['不称职', '不合格'].includes(result)) return 'danger'
  return 'info'
}

function toggleEdit() {
  backupForm.value = JSON.parse(JSON.stringify(form))
  isEditMode.value = true
}

function cancelEdit() {
  if (isNew.value) {
    Object.assign(form, emptyForm())
    return
  }
  Object.assign(form, backupForm.value)
  isEditMode.value = false
}

function handleBack() {
  if (isNew.value) {
    router.push('/cadre/onjob')
  } else {
    router.back()
  }
}

function buildPayload() {
  return {
    ...form,
    idCard: form.idCard || null,
    phone: form.phone || null,
    email: form.email || null,
    nation: form.nation || null,
    nativePlace: form.nativePlace || null,
    positionDocNo: form.positionDocNo || null
  }
}

async function handleSave() {
  const valid = await basicFormRef.value?.validate().catch(() => false)
  if (!valid) return
  saveLoading.value = true
  try {
    if (isNew.value) {
      await addCadre(buildPayload())
      ElMessage.success('新增成功')
      router.push('/cadre/onjob')
    } else {
      const payload = buildPayload()
      if (payload.id == null) {
        ElMessage.error('档案标识缺失')
        return
      }
      await request.put('/cadre', payload)
      ElMessage.success('保存成功')
      isEditMode.value = false
      backupForm.value = null
    }
  } catch (e) {
    ElMessage.error(e.message || '保存失败')
  } finally {
    saveLoading.value = false
  }
}

function handleExport() {
  const html = buildAppointmentDoc()
  const blob = new Blob(['\ufeff' + html], { type: 'application/msword;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = (form.name || '干部') + '任免表.doc'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
  ElMessage.success('任免表导出成功（基于当前档案库数据）')
}

// 生成 Word 兼容的 HTML 任免表（数据来自当前真实档案行）
function buildAppointmentDoc() {
  const f = form
  const deptName = (deptOptions.value.find(d => d.id === f.deptId) || {}).deptName || f.deptId || ''
  const rankName = (rankList.value.find(r => r.id === f.rankId) || {}).rankName || f.rankId || ''
  const birth = f.birthDate ? String(f.birthDate).replace(/-/g, '.') : ''
  const tr = cells => '<tr>' + cells + '</tr>'
  const th = t => `<td style="width:110px;background:#f2f2f2;font-weight:bold;text-align:center">${t}</td>`
  const td = v => `<td>${v || ''}</td>`

  const rows = []
  rows.push(tr(th('姓名') + td(f.name) + th('性别') + td(f.gender === 1 ? '男' : f.gender === 2 ? '女' : '') + th('出生年月') + td(birth)))
  rows.push(tr(th('民族') + td(f.nation) + th('籍贯') + td(f.nativePlace) + th('政治面貌') + td(f.politicalStatus)))
  rows.push(tr(th('入党时间') + td(f.partyJoinDate) + th('参加工作时间') + td(f.workStartDate) + th('手机号码') + td(f.phone)))
  rows.push(tr(th('全日制学历') + td(f.fullTimeEducation) + th('学位') + td(f.fullTimeDegree) + th('毕业院校') + td(f.fullTimeSchool)))
  rows.push(tr(th('现任职务') + td(f.position) + th('职务层次') + td(f.positionLevel) + th('职级') + td(rankName)))
  rows.push(tr(th('所属机构') + td(deptName) + th('任现职时间') + td(f.positionStartDate) + th('任命文号') + td(f.positionDocNo)))
  rows.push(tr(th('工作简历') + `<td colspan="5" style="white-space:pre-wrap;line-height:1.7">${f.resumeText || ''}</td>`))

  let familyHtml = ''
  if (familyList.value && familyList.value.length) {
    familyHtml = '<p style="margin:10px 0 4px;font-weight:bold">家庭成员</p><table style="border-collapse:collapse;width:100%;border:1px solid #333">' +
      '<tr style="background:#f2f2f2"><th style="border:1px solid #333;padding:4px">姓名</th><th style="border:1px solid #333;padding:4px">关系</th><th style="border:1px solid #333;padding:4px">工作单位</th><th style="border:1px solid #333;padding:4px">联系电话</th></tr>' +
      familyList.value.map(m => `<tr><td style="border:1px solid #333;padding:4px">${m.memberName || ''}</td><td style="border:1px solid #333;padding:4px">${m.relation || ''}</td><td style="border:1px solid #333;padding:4px">${m.workplace || ''}</td><td style="border:1px solid #333;padding:4px">${m.phone || ''}</td></tr>`).join('') +
      '</table>'
  }

  return `<!DOCTYPE html><html><head><meta charset="UTF-8"><title>干部任免表</title></head><body>` +
    `<h2 style="text-align:center;margin:0 0 12px">干部任免审批表</h2>` +
    `<table style="border-collapse:collapse;width:100%;border:1px solid #333;border-top:0">${rows.join('')}</table>` +
    familyHtml +
    `<p style="margin-top:14px;font-size:12px;color:#666">导出时间：${new Date().toLocaleString()}</p>` +
    `</body></html>`
}

function openFamilyAdd() {
  Object.assign(familyForm, { memberName: '', relation: '', workplace: '', phone: '' })
  familyDialogVisible.value = true
}

async function handleFamilySave() {
  familyFormRef.value?.validate(async (valid) => {
    if (!valid) return
    familySaving.value = true
    try {
      await request.post(`/cadre/${cadreId.value}/family`, { ...familyForm })
      ElMessage.success('添加成功')
      familyDialogVisible.value = false
      await loadFamily()
    } catch (e) {
      ElMessage.error(e.message || '添加失败')
    } finally {
      familySaving.value = false
    }
  })
}

async function delFamily(row) {
  if (!row.id) return
  try {
    await request.delete(`/cadre/${cadreId.value}/family/${row.id}`)
    ElMessage.success('删除成功')
    await loadFamily()
  } catch (e) {
    ElMessage.error(e.message || '删除失败')
  }
}

async function handleUpload(options) {
  const file = options.file
  try {
    await request.post(`/cadre/${cadreId.value}/attachment/upload`, {
      fileName: file.name,
      filePath: file.name,
      fileType: (file.name.split('.').pop() || 'FILE').toUpperCase(),
      fileSize: file.size,
      attachCategory: '佐证材料'
    })
    ElMessage.success('登记成功')
    await loadAttachments()
  } catch (e) {
    ElMessage.error(e.message || '登记失败')
  }
}

async function delEvidence(row) {
  if (!row.id) return
  try {
    await request.delete(`/cadre/${cadreId.value}/attachment/${row.id}`)
    ElMessage.success('删除成功')
    await loadAttachments()
  } catch (e) {
    ElMessage.error(e.message || '删除失败')
  }
}

onMounted(async () => {
  await loadDict()
  loadDetail()
})
</script>

<style scoped>
.detail-card {
  background: #fff;
  border: 1px solid #e0e0e0;
}

.detail-card .toolbar {
  border-bottom: 1px solid #e0e0e0;
}

.detail-tabs {
  padding: 0 16px 16px;
}

.detail-tabs :deep(.el-tabs__header) {
  margin-bottom: 18px;
}

.basic-section {
  display: flex;
  gap: 24px;
}

.form-area {
  flex: 1;
}

.edu-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.edu-block {
  background: #f8fafc;
  border: 1px solid #e8eef5;
  border-radius: 4px;
  padding: 16px 20px 4px;
}

.edu-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 14px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e0e0e0;
}

.sub-table-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.sub-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
}

.resume-textarea :deep(.el-textarea__inner) {
  font-family: "Microsoft YaHei", sans-serif;
  line-height: 1.8;
  font-size: 13px;
}
</style>
