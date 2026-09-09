<template>
  <div v-loading="loading">
    <div class="page-header">个人信息</div>

    <el-alert v-if="!loading && !bound" type="info" :closable="false" style="margin-bottom:16px">
      {{ unboundTip }}
    </el-alert>

    <template v-if="cadre">
      <el-card class="section-card">
        <template #header><div class="section-title">基础信息（来自干部档案库）</div></template>
        <el-descriptions :column="3" border size="small">
          <el-descriptions-item label="姓名">{{ display(cadre.name) }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ cadre.gender === 1 ? '男' : cadre.gender === 2 ? '女' : '-' }}</el-descriptions-item>
          <el-descriptions-item label="民族">{{ display(cadre.nation) }}</el-descriptions-item>
          <el-descriptions-item label="出生日期">{{ display(cadre.birthDate) }}</el-descriptions-item>
          <el-descriptions-item label="身份证号">{{ display(cadre.idCard) }}</el-descriptions-item>
          <el-descriptions-item label="籍贯">{{ display(cadre.nativePlace) }}</el-descriptions-item>
          <el-descriptions-item label="政治面貌">{{ display(cadre.politicalStatus) }}</el-descriptions-item>
          <el-descriptions-item label="入党时间">{{ display(cadre.partyJoinDate) }}</el-descriptions-item>
          <el-descriptions-item label="参工时间">{{ display(cadre.workStartDate) }}</el-descriptions-item>
          <el-descriptions-item label="全日制学历">{{ display(cadre.fullTimeEducation) }}</el-descriptions-item>
          <el-descriptions-item label="全日制学位">{{ display(cadre.fullTimeDegree) }}</el-descriptions-item>
          <el-descriptions-item label="全日制院校专业">{{ display(cadre.fullTimeSchool) }}</el-descriptions-item>
          <el-descriptions-item label="在职学历">{{ display(cadre.partTimeEducation || '-') }}</el-descriptions-item>
          <el-descriptions-item label="在职学位">{{ display(cadre.partTimeDegree || '-') }}</el-descriptions-item>
          <el-descriptions-item label="在职院校专业">{{ display(cadre.partTimeSchool || '-') }}</el-descriptions-item>
          <el-descriptions-item label="所属机构">{{ deptName }}</el-descriptions-item>
          <el-descriptions-item label="岗位职务">{{ display(cadre.position) }}</el-descriptions-item>
          <el-descriptions-item label="职务层次">{{ display(cadre.positionLevel) }}</el-descriptions-item>
          <el-descriptions-item label="职级">{{ rankName }}</el-descriptions-item>
          <el-descriptions-item label="任现职时间">{{ display(cadre.positionStartDate) }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ display(cadre.phone) }}</el-descriptions-item>
          <el-descriptions-item label="电子邮箱" :span="2">{{ display(cadre.email || '-') }}</el-descriptions-item>
          <el-descriptions-item label="在库状态">{{ statusText }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card class="section-card">
        <template #header><div class="section-title">工作简历</div></template>
        <div v-if="cadre.resumeText" class="text-block">{{ cadre.resumeText }}</div>
        <div v-else class="empty-block">档案库暂无简历文本</div>
      </el-card>

      <el-card class="section-card">
        <template #header><div class="section-title">奖惩情况</div></template>
        <div v-if="cadre.rewardPunishment" class="text-block">{{ cadre.rewardPunishment }}</div>
        <div v-else class="empty-block">档案库暂无奖惩记录</div>
      </el-card>

      <el-card class="section-card">
        <template #header><div class="section-title">家庭成员（来自干部档案库）</div></template>
        <el-table :data="familyRows" border size="small">
          <el-table-column prop="relation" label="关系" width="100" align="center" />
          <el-table-column prop="memberName" label="姓名" width="120" align="center" />
          <el-table-column prop="workplace" label="工作单位" min-width="220" show-overflow-tooltip />
          <el-table-column prop="phone" label="联系电话" width="150" align="center" />
        </el-table>
        <div v-if="familyRows.length === 0" class="empty-block">档案库暂无家庭成员记录</div>
      </el-card>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { getUserProfile } from '@/api/daily'
import { getCadreDetail } from '@/api/cadre'
import request from '@/utils/request'

const userStore = useUserStore()
const loading = ref(false)
const bound = ref(false)
const cadre = ref(null)
const deptNameMap = ref({})
const rankNameMap = ref({})

const deptName = computed(() => (cadre.value && cadre.value.deptId != null
  ? (deptNameMap.value[cadre.value.deptId] || '-') : '-'))
const rankName = computed(() => (cadre.value && cadre.value.rankId != null
  ? (rankNameMap.value[cadre.value.rankId] || '-') : '-'))
const statusText = computed(() => {
  const m = { ON_JOB: '在职', RETIRED: '离退休', TRANSFERRED: '已调出', RESIGNED: '已辞职' }
  return cadre.value ? (m[cadre.value.cadreStatus] || '-') : '-'
})

const unboundTip = computed(() => userStore.isManagerRole
  ? '当前为管理职能账号，无个人干部档案绑定。如需查看干部档案请前往「干部信息管理」。'
  : '该账号未绑定干部档案，无法展示个人档案；请联系管理员在「用户管理-账号绑定」中绑定后查看。')

const familyRows = computed(() => (cadre.value && Array.isArray(cadre.value.familyMembers)
  ? cadre.value.familyMembers.map(m => ({
      relation: m.relation || '-',
      memberName: m.memberName || '-',
      workplace: m.workplace || '-',
      phone: m.phone || '-'
    }))
  : []))

function display(v) {
  return (v === null || v === undefined || v === '') ? '-' : v
}

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

onLoad()
async function onLoad() {
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
</script>

<style scoped>
.section-card {
  margin-bottom: 16px;
}
.section-title {
  font-size: 14px;
  font-weight: bold;
  color: #1976D2;
}
.text-block {
  white-space: pre-wrap;
  line-height: 1.9;
  font-size: 13px;
  color: #333;
  padding: 4px 2px;
}
.empty-block {
  color: #999;
  font-size: 13px;
  padding: 12px 2px;
  text-align: center;
}
</style>
