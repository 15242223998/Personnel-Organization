<template>
  <div>
    <div class="page-header">
      干部个人基础信息申报
      <span style="font-size:12px;font-weight:normal;margin-left:12px;color:#888">当前申报人：{{ userStore.realName || '未登录' }}</span>
    </div>

    <el-alert v-if="!loading && !bound" type="warning" :closable="false" style="margin-bottom:16px">
      {{ unboundTip }}
    </el-alert>

    <template v-if="cadre">
      <!-- 申报类型选择 -->
      <el-card class="section-card">
        <template #header><div class="section-title"><el-icon><EditPen /></el-icon> 申报类型</div></template>
        <el-radio-group v-model="declareType">
          <el-radio-button value="basic">个人基础信息申报（整表）</el-radio-button>
          <el-radio-button value="correction">档案信息更正（单字段，审批通过后自动更新档案）</el-radio-button>
        </el-radio-group>
        <div style="font-size:12px;color:#888;margin-top:8px">
          {{ declareType === 'correction'
            ? '仅需选择要更正的档案字段并填写新值；提交后进入组织部审批，通过后由系统自动回写干部档案。'
            : '申报内容以档案库真实档案为初始值；提交后进入审批流程，审批通过前不直接修改档案库。' }}
        </div>
      </el-card>

      <!-- 一、档案信息更正（单字段结构化申报） -->
      <el-card v-if="declareType === 'correction'" class="section-card">
        <template #header><div class="section-title"><el-icon><RefreshLeft /></el-icon> 档案信息更正</div></template>
        <el-form :model="correctionForm" label-width="110px" size="default">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="变更字段" required>
                <el-select v-model="correctionForm.applyField" placeholder="请选择需要更正的档案字段" style="width:100%" @change="onFieldChange">
                  <el-option v-for="f in correctionFields" :key="f.key" :label="f.label" :value="f.key" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="当前档案值">
                <el-input :model-value="currentFieldValue" disabled placeholder="选择变更字段后自动读取档案库真实值" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="更正为新值" required>
                <el-input v-model="correctionForm.newValue" maxlength="255"
                  :placeholder="fieldInputPlaceholder" />
              </el-form-item>
            </el-col>
          </el-row>
        </el-form>
        <div style="text-align:center;padding:8px 0 4px">
          <el-button size="large" type="success" :loading="submitting" @click="handleSubmitCorrection">
            <el-icon><CircleCheck /></el-icon> 确认提交更正
          </el-button>
        </div>
      </el-card>

      <template v-else>
        <el-alert type="info" :closable="false" style="margin-bottom:16px"
          title="申报内容以档案库真实档案为初始值；提交后进入审批流程，审批通过前不直接修改档案库。" />

        <!-- 二、个人基础信息 -->
        <el-card class="section-card">
          <template #header><div class="section-title"><el-icon><User /></el-icon> 个人基础信息</div></template>
          <el-form :model="basic" label-width="110px" size="default">
            <el-row :gutter="20">
              <el-col :span="8"><el-form-item label="姓名" required><el-input v-model="basic.name" disabled /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="性别" required>
                <el-radio-group v-model="basic.gender"><el-radio :value="1">男</el-radio><el-radio :value="2">女</el-radio></el-radio-group>
              </el-form-item></el-col>
              <el-col :span="8"><el-form-item label="民族"><el-select v-model="basic.nation" style="width:100%"><el-option v-for="e in ethnicities" :key="e" :label="e" :value="e" /></el-select></el-form-item></el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="8"><el-form-item label="出生日期" required><el-date-picker v-model="basic.birthDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="身份证号"><el-input v-model="basic.idCard" maxlength="18" /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="籍贯"><el-input v-model="basic.nativePlace" /></el-form-item></el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="8"><el-form-item label="政治面貌"><el-select v-model="basic.politicalStatus" style="width:100%"><el-option label="中共党员" value="中共党员" /><el-option label="民主党派" value="民主党派" /><el-option label="群众" value="群众" /></el-select></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="入党时间"><el-date-picker v-model="basic.partyJoinDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="参工时间"><el-date-picker v-model="basic.workStartDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="8"><el-form-item label="最高学历"><el-select v-model="basic.fullTimeEducation" style="width:100%"><el-option label="博士研究生" value="博士研究生" /><el-option label="硕士研究生" value="硕士研究生" /><el-option label="本科" value="本科" /><el-option label="大专" value="大专" /></el-select></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="最高学位"><el-select v-model="basic.fullTimeDegree" style="width:100%"><el-option label="博士" value="博士" /><el-option label="硕士" value="硕士" /><el-option label="学士" value="学士" /></el-select></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="院校专业"><el-input v-model="basic.fullTimeSchool" /></el-form-item></el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="8"><el-form-item label="所属机构"><el-input :model-value="deptName" disabled /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="岗位职务"><el-input v-model="basic.position" /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="职务层次"><el-select v-model="basic.positionLevel" style="width:100%"><el-option label="校级" value="校级" /><el-option label="处级" value="处级" /><el-option label="科级" value="科级" /><el-option label="正厅级" value="正厅级" /><el-option label="副厅级" value="副厅级" /><el-option label="正处级" value="正处级" /><el-option label="副处级" value="副处级" /><el-option label="正科级" value="正科级" /><el-option label="副科级" value="副科级" /></el-select></el-form-item></el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="8"><el-form-item label="职级"><el-input v-model="basic.rankName" disabled /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="任现职时间"><el-date-picker v-model="basic.positionStartDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
              <el-col :span="8"><el-form-item label="联系电话"><el-input v-model="basic.phone" /></el-form-item></el-col>
            </el-row>
          </el-form>
        </el-card>

        <!-- 三、工作简历 -->
        <el-card class="section-card">
          <template #header><div class="section-title"><el-icon><Tickets /></el-icon> 工作简历</div></template>
          <el-input v-model="resumeText" type="textarea" :rows="8" placeholder="填写/修正工作简历（初始为档案库简历文本）" />
        </el-card>

        <!-- 四、奖惩情况 -->
        <el-card class="section-card">
          <template #header><div class="section-title"><el-icon><Medal /></el-icon> 奖惩相关资料</div></template>
          <el-input v-model="rewardText" type="textarea" :rows="4" placeholder="填写/修正奖惩记录（初始为档案库奖惩文本）" />
        </el-card>

        <!-- 五、家庭成员 -->
        <el-card class="section-card">
          <template #header><div class="section-title"><el-icon><UserFilled /></el-icon> 家庭成员档案信息</div></template>
          <div class="toolbar"><el-button type="primary" @click="addFamily"><el-icon><Plus /></el-icon> 添加家庭成员</el-button></div>
          <el-table :data="family" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="relation" label="关系" width="110" align="center" />
            <el-table-column prop="memberName" label="姓名" width="130" align="center" />
            <el-table-column prop="workplace" label="工作单位" min-width="220" show-overflow-tooltip />
            <el-table-column prop="phone" label="联系电话" width="150" align="center" />
            <el-table-column label="操作" width="80" align="center"><template #default="{ $index }"><span class="link-blue" style="color:#E53935" @click="family.splice($index,1)">删除</span></template></el-table-column>
          </el-table>
          <div v-if="family.length === 0" style="color:#999;font-size:13px;padding:12px 0;text-align:center">档案库暂无家庭成员记录，可通过上方按钮添加后随申报提交</div>
        </el-card>

        <div style="text-align:center;padding:20px 0">
          <el-button size="large" @click="handleRefresh"><el-icon><RefreshLeft /></el-icon> 重置刷新</el-button>
          <el-button size="large" type="primary" :loading="saving" @click="handleSaveDraft"><el-icon><Document /></el-icon> 保存草稿</el-button>
          <el-button size="large" type="success" :loading="submitting" @click="handleSubmit"><el-icon><CircleCheck /></el-icon> 确认提交</el-button>
        </div>
      </template>
    </template>
    <div v-else-if="!loading && !bound" style="text-align:center;padding:80px;color:#999">
      <el-icon style="font-size:52px"><User /></el-icon>
      <p style="margin-top:16px;font-size:15px">未找到对应当前账号绑定的干部档案，无法发起申报</p>
    </div>

    <el-dialog v-model="dialogVisible" title="添加家庭成员" width="520px" destroy-on-close>
      <el-form :model="dialogForm" label-width="100px">
        <el-form-item label="关系"><el-select v-model="dialogForm.relation" style="width:100%"><el-option label="父亲" value="父亲" /><el-option label="母亲" value="母亲" /><el-option label="配偶" value="配偶" /><el-option label="子女" value="子女" /><el-option label="兄弟姐妹" value="兄弟姐妹" /></el-select></el-form-item>
        <el-form-item label="姓名"><el-input v-model="dialogForm.memberName" /></el-form-item>
        <el-form-item label="工作单位"><el-input v-model="dialogForm.workplace" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="联系电话"><el-input v-model="dialogForm.phone" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialogVisible=false">取消</el-button><el-button type="primary" @click="confirmFamily">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { User, Tickets, Medal, UserFilled, Plus, RefreshLeft, Document, CircleCheck, EditPen } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { getUserProfile, addSelfApplication, submitSelfApplication } from '@/api/daily'
import { getCadreDetail } from '@/api/cadre'

const userStore = useUserStore()

const ethnicities = ['汉族','蒙古族','回族','藏族','维吾尔族','苗族','彝族','壮族','布依族','朝鲜族','满族','侗族','瑶族','白族','土家族','哈尼族','哈萨克族','傣族','黎族','其他']

const loading = ref(false)
const saving = ref(false)
const submitting = ref(false)
const bound = ref(false)
const cadre = ref(null)
const deptNameMap = ref({})
const rankNameMap = ref({})

// 申报类型：basic=个人基础信息申报（整表）；correction=档案信息更正（单字段）
const declareType = ref('basic')

// 档案信息更正：白名单字段（与后端 CadreInfoMapperKeys 保持一致）
const correctionFields = [
  { key: 'phone', label: '联系电话' },
  { key: 'email', label: '邮箱' },
  { key: 'education', label: '最高学历' },
  { key: 'political_status', label: '政治面貌' },
  { key: 'home_address', label: '家庭住址' },
  { key: 'emergency_contact', label: '紧急联系人' }
]
const correctionForm = reactive({ applyField: '', newValue: '' })

// 读真实档案的当前值（只读展示）
function readArchiveValue(fieldKey) {
  const c = cadre.value
  if (!c) return ''
  return {
    phone: c.phone,
    email: c.email,
    education: c.fullTimeEducation,
    political_status: c.politicalStatus,
    home_address: c.homeAddress,
    emergency_contact: c.emergencyContact
  }[fieldKey] || ''
}
const currentFieldLabel = computed(() => {
  const f = correctionFields.find(x => x.key === correctionForm.applyField)
  return f ? f.label : ''
})
const currentFieldValue = computed(() => readArchiveValue(correctionForm.applyField))
const fieldInputPlaceholder = computed(() => {
  if (!correctionForm.applyField) return '请先选择变更字段'
  return '请输入' + currentFieldLabel.value + '的新值'
})

function onFieldChange() {
  correctionForm.newValue = ''
}

const basic = reactive({
  name: '', gender: null, nation: '', birthDate: '', idCard: '', nativePlace: '',
  politicalStatus: '', partyJoinDate: '', workStartDate: '', fullTimeEducation: '',
  fullTimeDegree: '', fullTimeSchool: '', deptId: null, position: '', positionLevel: '',
  rankId: null, positionStartDate: '', phone: ''
})
const resumeText = ref('')
const rewardText = ref('')
const family = ref([])

const deptName = computed(() => (basic.deptId != null ? (deptNameMap.value[basic.deptId] || '-') : '-'))

const unboundTip = computed(() => userStore.isManagerRole
  ? '当前为管理职能账号，未绑定干部档案，不能发起个人申报。'
  : '该账号未绑定干部档案，无法发起个人基础信息申报；请联系管理员在「用户管理-账号绑定」中绑定对应干部档案。')

const dialogVisible = ref(false)
const dialogForm = reactive({ relation: '配偶', memberName: '', workplace: '', phone: '' })

async function loadDict() {
  const [treeRes, rankRes] = await Promise.all([
    request.get('/organization/tree').catch(() => null),
    request.get('/rank/list').catch(() => null)
  ])
  const deptMap = {}
  const walk = nodes => {
    if (!Array.isArray(nodes)) return
    nodes.forEach(o => {
      if (o && o.id != null) deptMap[o.id] = o.deptName || o.shortName || ''
      walk(o.children)
    })
  }
  walk(treeRes && treeRes.data)
  deptNameMap.value = deptMap
  const rankMap = {}
  if (rankRes && Array.isArray(rankRes.data)) {
    rankRes.data.forEach(r => { if (r && r.id != null) rankMap[r.id] = r.rankName })
  }
  rankNameMap.value = rankMap
}

function fillFromCadre(c) {
  Object.assign(basic, {
    name: c.name || '',
    gender: c.gender ?? null,
    nation: c.nation || '',
    birthDate: c.birthDate || '',
    idCard: c.idCard || '',
    nativePlace: c.nativePlace || '',
    politicalStatus: c.politicalStatus || '',
    partyJoinDate: c.partyJoinDate || '',
    workStartDate: c.workStartDate || '',
    fullTimeEducation: c.fullTimeEducation || '',
    fullTimeDegree: c.fullTimeDegree || '',
    fullTimeSchool: c.fullTimeSchool || '',
    deptId: c.deptId ?? null,
    position: c.position || '',
    positionLevel: c.positionLevel || '',
    rankId: c.rankId ?? null,
    positionStartDate: c.positionStartDate || '',
    phone: c.phone || ''
  })
  resumeText.value = c.resumeText || ''
  rewardText.value = c.rewardPunishment || ''
  family.value = (Array.isArray(c.familyMembers) ? c.familyMembers : []).map(m => ({
    relation: m.relation || '',
    memberName: m.memberName || '',
    workplace: m.workplace || '',
    phone: m.phone || ''
  }))
}

async function loadCadre() {
  loading.value = true
  try {
    await loadDict()
    let profile = null
    try {
      const res = await getUserProfile()
      profile = res.data || null
    } catch (e) {
      profile = null
    }
    const cadreId = profile && profile.cadreId
    bound.value = !!cadreId
    if (cadreId) {
      try {
        const res = await getCadreDetail(cadreId)
        cadre.value = res.data || null
        if (cadre.value) {
          fillFromCadre(cadre.value)
        }
      } catch (e) {
        cadre.value = null
      }
    } else {
      cadre.value = null
    }
  } finally {
    loading.value = false
  }
}

function addFamily() {
  Object.assign(dialogForm, { relation: '配偶', memberName: '', workplace: '', phone: '' })
  dialogVisible.value = true
}

function confirmFamily() {
  family.value.push({ ...dialogForm })
  dialogVisible.value = false
  ElMessage.success('已加入申报草稿')
}

function buildContent() {
  return JSON.stringify({
    basic: { ...basic },
    resumeText: resumeText.value,
    rewardPunishment: rewardText.value,
    family: family.value
  })
}

async function saveApplication(status) {
  const content = buildContent()
  const payload = {
    applicationType: 'INFO_UPDATE',
    applicationTitle: '个人基础信息申报',
    applicationContent: content,
    applyStatus: status
  }
  const res = await addSelfApplication(payload)
  return res.data
}

async function handleSaveDraft() {
  saving.value = true
  try {
    await saveApplication('DRAFT')
    ElMessage.success('草稿已保存到申报中心')
  } catch (e) {
    ElMessage.error(e.message || '草稿保存失败')
  } finally {
    saving.value = false
  }
}

async function handleSubmit() {
  try {
    await ElMessageBox.confirm('提交后将进入人事部门审批流程，请确认信息真实准确？', '确认提交', { type: 'warning', confirmButtonText: '确认提交' })
  } catch (e) {
    return
  }
  submitting.value = true
  try {
    const id = await saveApplication('DRAFT')
    await submitSelfApplication(id)
    ElMessage.success('申报信息已成功提交，待人事部门审核')
  } catch (e) {
    ElMessage.error(e.message || '提交失败')
  } finally {
    submitting.value = false
  }
}

// 档案信息更正：提交结构化变更（apply_field/new_value），审批通过后由后端自动回写档案
async function handleSubmitCorrection() {
  const fieldKey = correctionForm.applyField
  const field = correctionFields.find(x => x.key === fieldKey)
  if (!field) {
    ElMessage.warning('请选择需要更正的档案字段')
    return
  }
  const newValue = (correctionForm.newValue || '').trim()
  const oldValue = readArchiveValue(fieldKey)
  if (!newValue) {
    ElMessage.warning('请填写「' + field.label + '」更正后的新值')
    return
  }
  if (newValue === oldValue) {
    ElMessage.warning('新值与档案当前值相同，无需更正')
    return
  }
  if (fieldKey === 'phone' && !/^[0-9+\-\s()]{6,20}$/.test(newValue)) {
    ElMessage.warning('联系电话格式不正确')
    return
  }
  if (fieldKey === 'email' && (!newValue.includes('@') || !newValue.split('@')[1].includes('.'))) {
    ElMessage.warning('邮箱格式不正确')
    return
  }
  try {
    await ElMessageBox.confirm(
      '确认将档案「' + field.label + '」由「' + (oldValue || '（空）') + '」更正为「' + newValue + '」？\n提交后待组织部审批，审批通过后自动更新档案。',
      '确认提交更正', { type: 'warning', confirmButtonText: '确认提交', cancelButtonText: '再想想' })
  } catch (e) {
    return
  }
  submitting.value = true
  try {
    const res = await addSelfApplication({
      applicationType: 'INFO_UPDATE',
      applicationTitle: '档案信息更正-' + field.label,
      applicationContent: '【档案信息更正】' + field.label + '：' + (oldValue || '（空）') + ' → ' + newValue,
      applyField: fieldKey,
      newValue: newValue,
      applyStatus: 'DRAFT'
    })
    await submitSelfApplication(res.data)
    correctionForm.newValue = ''
    ElMessage.success('提交成功，待组织部审批后自动更新档案')
  } catch (e) {
    ElMessage.error(e.message || '提交失败')
  } finally {
    submitting.value = false
  }
}

function handleRefresh() {
  ElMessageBox.confirm('将重新加载档案库中该干部的档案作为初始值，未保存的修改将丢失，确定继续吗？', '提示', { type: 'warning' })
    .then(() => {
      if (cadre.value) fillFromCadre(cadre.value)
      ElMessage.info('已按档案库数据重置')
    }).catch(() => {})
}

onMounted(loadCadre)
</script>

<style scoped>
.section-card { margin-bottom: 16px; }
.section-card :deep(.el-card__header) { padding: 10px 16px; background: #f8f9fa; border-bottom: 2px solid #1976D2; }
.section-title { font-size: 14px; font-weight: 600; color: #1976D2; display: flex; align-items: center; gap: 6px; }
.gov-tabs :deep(.el-tabs__header) { margin-bottom: 8px; }
.gov-tabs :deep(.el-tabs__nav-wrap::after) { display: none; }
</style>
