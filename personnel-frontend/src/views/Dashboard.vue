<template>
  <div>
    <!-- 统计卡片 -->
    <el-row :gutter="10" style="margin-bottom:12px">
      <el-col :span="6" v-for="card in statCards" :key="card.label">
        <div class="stat-card" :style="{ borderLeftColor: card.color }" @click="$router.push(card.path)">
          <div class="stat-info">
            <div class="stat-value" :style="{ color: card.color }">{{ card.key === 'todo' ? todoCount : (statNums[card.key] ?? 0) }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
          <div class="stat-icon" :style="{ background: card.color }">
            <el-icon :size="28"><component :is="card.icon" /></el-icon>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="10">
      <!-- 待办预警提醒 -->
      <el-col :span="14">
        <el-card>
          <template #header>
            <span><el-icon><Bell /></el-icon> 待办预警提醒</span>
          </template>
          <el-table :data="alertList" border size="small" :empty-text="emptyText">
            <el-table-column label="序号" width="50" type="index" align="center" />
            <el-table-column label="预警类型" width="110" align="center">
              <template #default="{row}">
                <el-tag :type="row.tagType" size="small">{{ row.type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="title" label="预警内容" show-overflow-tooltip />
            <el-table-column prop="time" label="时间" width="130" align="center" />
            <el-table-column label="操作" width="80" align="center">
              <template #default="{row}">
                <span class="link-blue" @click="handleNotice(row)">处理</span>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <!-- 快捷入口 -->
      <el-col :span="10">
        <el-card style="margin-bottom:10px">
          <template #header><span><el-icon><Grid /></el-icon> 快捷入口</span></template>
          <div class="quick-grid">
            <div class="quick-item" v-for="q in quickMenus" :key="q.path" @click="$router.push(q.path)">
              <div class="quick-icon" :style="{background:q.color}">
                <el-icon :size="20"><component :is="q.icon" /></el-icon>
              </div>
              <span>{{ q.name }}</span>
            </div>
          </div>
        </el-card>
        <el-card>
          <template #header><span><el-icon><PieChart /></el-icon> 干部队伍概览（职务层次分布）</span></template>
          <div ref="miniChart" style="height:180px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted, markRaw } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import { useUserStore } from '../stores/user'
import {
  UserFilled, User, OfficeBuilding, Medal, WarningFilled,
  Bell, DataAnalysis, Switch, Stamp, Grid, PieChart, Calendar, Top
} from '@element-plus/icons-vue'
import request from '../utils/request'
import { getCadrePage } from '../api/cadre'
import { getPositionLevelDistribution } from '../api/statistics'

const statCards = [
  { key: 'onjob', label: '在职干部总数', color: '#1976D2', icon: markRaw(UserFilled), path: '/cadre/onjob' },
  { key: 'org', label: '机构数量', color: '#43A047', icon: markRaw(OfficeBuilding), path: '/organization' },
  { key: 'reserve', label: '后备干部', color: '#FB8C00', icon: markRaw(Medal), path: '/cadre/reserve' },
  { key: 'todo', label: '待办事项', color: '#E53935', icon: markRaw(WarningFilled), path: '/supervision/alert' }
]
const statNums = reactive({ onjob: 0, org: 0, reserve: 0 })

const userStore = useUserStore()
const router = useRouter()
// 管理职能账号（系统管理员/校级领导/部长/组织员）可看全员待办；普通账号后端不推送，显示空态文案
const isManager = computed(() => userStore.isAdmin || [2, 3, 4].includes(Number(userStore.userType)))

// 预警类型展示映射（来自后端 notice 汇总，类型取后端原始 type 兜底）
const noticeTypeMap = {
  register: { label: '注册审批', tagType: 'warning' },
  scheme: { label: '测评提醒', tagType: 'primary' },
  leave: { label: '休假审批', tagType: 'warning' },
  cert: { label: '证照借还', tagType: 'danger' },
  abroad: { label: '出境超期', tagType: 'danger' },
  alert: { label: '本人预警', tagType: 'danger' }
}

const alertList = ref([])
const todoCount = computed(() => alertList.value.length)
const emptyText = computed(() => (isManager.value ? '暂无待办预警提醒' : '暂无与您本人相关的待办预警提醒'))

const quickMenus = [
  { name: '干部信息', path: '/cadre', color: '#1976D2', icon: markRaw(User) },
  { name: '机构管理', path: '/organization', color: '#43A047', icon: markRaw(OfficeBuilding) },
  { name: '干部任免', path: '/appointment', color: '#FB8C00', icon: markRaw(Stamp) },
  { name: '调配管理', path: '/transfer', color: '#8E24AA', icon: markRaw(Switch) },
  { name: '职级晋升', path: '/promotion', color: '#00897B', icon: markRaw(Top) },
  { name: '考核管理', path: '/assessment', color: '#3949AB', icon: markRaw(DataAnalysis) },
  { name: '日常事务', path: '/daily', color: '#00ACC1', icon: markRaw(Calendar) },
  { name: '统计分析', path: '/statistics', color: '#D81B60', icon: markRaw(PieChart) }
]

function formatTime(t) {
  if (!t) return '—'
  return String(t).replace('T', ' ').substring(0, 16)
}

async function loadStats() {
  // 在职干部总数：干部库真实分页 total（在职状态）
  getCadrePage({ current: 1, size: 1, cadreStatus: 'ON_JOB' })
    .then(res => { statNums.onjob = (res.data && res.data.total) || 0 })
    .catch(() => { statNums.onjob = 0 })
  // 机构数量：组织树真实节点数
  request.get('/organization/tree')
    .then(res => {
      const count = { total: 0 }
      const walk = list => {
        if (!Array.isArray(list)) return
        list.forEach(o => {
          if (o && o.id != null) count.total++
          walk(o.children)
        })
      }
      walk(res.data)
      statNums.org = count.total
    })
    .catch(() => { statNums.org = 0 })
  // 后备干部：后备干部库真实列表长度
  request.get('/cadre-reserve/list')
    .then(res => { statNums.reserve = Array.isArray(res.data) ? res.data.length : 0 })
    .catch(() => { statNums.reserve = 0 })
}

async function loadNotices() {
  try {
    const res = await request.get('/notice/list')
    const list = Array.isArray(res.data) ? res.data : []
    alertList.value = list.slice(0, 7).map(n => {
      const map = noticeTypeMap[n.type] || { label: n.type || '提醒', tagType: 'info' }
      return {
        type: map.label,
        tagType: map.tagType,
        title: n.desc || n.title || '',
        time: formatTime(n.time),
        path: n.path || '/supervision/alert'
      }
    })
  } catch (e) {
    alertList.value = []
  }
}

function handleNotice(row) {
  router.push(row.path || '/supervision/alert')
}

const miniChart = ref(null)
let chart = null

function renderPie(rows) {
  if (!chart) return
  const hasData = (rows || []).some(it => Number(it.value) > 0)
  if (!rows || rows.length === 0 || !hasData) {
    chart.clear()
    chart.setOption({
      title: { text: '暂无分布数据', left: 'center', top: 'middle', textStyle: { fontSize: 13, color: '#999', fontWeight: 'normal' } },
      series: []
    })
    return
  }
  const colors = ['#1976D2', '#42A5F5', '#64B5F6', '#90CAF9', '#FB8C00', '#43A047', '#7E57C2', '#26A69A', '#E53935']
  chart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: {c}人 ({d}%)' },
    legend: { bottom: 0, itemWidth: 10, itemHeight: 10, textStyle: { fontSize: 12 } },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '42%'],
      label: { fontSize: 11 },
      data: rows.map((it, i) => ({
        value: Number(it.value) || 0,
        name: it.name,
        itemStyle: { color: colors[i % colors.length] }
      }))
    }]
  })
}

async function loadChartData() {
  try {
    const res = await getPositionLevelDistribution()
    renderPie((res.data || []).filter(it => it && it.name != null))
  } catch (e) {
    renderPie([])
  }
}

function handleResize() {
  chart && chart.resize()
}

onMounted(() => {
  chart = echarts.init(miniChart.value)
  loadStats()
  loadNotices()
  loadChartData()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  chart && chart.dispose()
  chart = null
})
</script>

<style scoped>
.stat-card {
  background: #fff;
  border-left: 4px solid #1976D2;
  padding: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-radius: 2px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  cursor: pointer;
  transition: box-shadow 0.2s, transform 0.2s;
}
.stat-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  transform: translateY(-2px);
}
.stat-value {
  font-size: 28px;
  font-weight: bold;
  line-height: 1;
  margin-bottom: 6px;
}
.stat-label {
  font-size: 13px;
  color: #666;
}
.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 6px;
  background: #1976D2;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
}
.quick-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
}
.quick-item {
  text-align: center;
  cursor: pointer;
  padding: 10px 4px;
  border-radius: 4px;
  transition: all 0.2s;
}
.quick-item:hover {
  background: #f0f7ff;
}
.quick-icon {
  width: 38px;
  height: 38px;
  border-radius: 6px;
  background: #1976D2;
  color: #fff;
  margin: 0 auto 6px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.quick-item span {
  font-size: 12px;
  color: #333;
}
</style>
