<template>
  <div v-loading="loading">
    <div class="page-header">干部队伍统计分析</div>

    <el-row :gutter="12" style="margin-bottom:12px">
      <el-col :span="12">
        <div class="chart-card">
          <div class="chart-title">年龄结构分布</div>
          <div ref="ageChart" class="chart-body"></div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="chart-card">
          <div class="chart-title">性别结构</div>
          <div ref="genderChart" class="chart-body"></div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="chart-card">
          <div class="chart-title">学历结构</div>
          <div ref="eduChart" class="chart-body"></div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="12" style="margin-bottom:12px">
      <el-col :span="10">
        <div class="chart-card">
          <div class="chart-title">政治面貌分布</div>
          <div ref="partyChart" class="chart-body"></div>
        </div>
      </el-col>
      <el-col :span="14">
        <div class="chart-card">
          <div class="chart-title">职务层次分布</div>
          <div ref="positionChart" class="chart-body"></div>
        </div>
      </el-col>
    </el-row>

    <div class="chart-card">
      <div class="chart-title">
        机构干部统计表
        <el-button type="primary" style="float:right;margin-top:-2px" @click="handleExportStats"><el-icon><Download /></el-icon> 导出</el-button>
      </div>
      <el-table :data="orgTableData" border size="small">
        <el-table-column prop="orgName" label="机构名称" min-width="220" align="center" />
        <el-table-column prop="cadreCount" label="在册干部数" width="110" align="center" />
        <el-table-column prop="approvedQuota" label="核定编制" width="100" align="center" />
        <el-table-column prop="leaderQuota" label="领导职数" width="100" align="center" />
        <el-table-column prop="vacant" label="空编数" width="100" align="center">
          <template #default="{ row }">
            <span :style="{ color: row.vacant > 0 ? '#E53935' : '#43A047', fontWeight: 'bold' }">{{ row.vacant }}</span>
          </template>
        </el-table-column>
      </el-table>
      <div style="padding:8px 0 0;font-size:12px;color:#909399">
        注：数据来自干部档案实时统计；编制数为各机构核定编制，空编数 = 核定编制 − 在册干部数（结果不小于 0）。
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import { Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'
import {
  getAgeDistribution,
  getGenderDistribution,
  getEducationDistribution,
  getPoliticalDistribution,
  getPositionLevelDistribution,
  getDeptSummary
} from '@/api/statistics'

const loading = ref(false)

const ageChart = ref(null)
const genderChart = ref(null)
const eduChart = ref(null)
const partyChart = ref(null)
const positionChart = ref(null)

let charts = []
const orgTableData = ref([])

const COLORS = ['#1976D2', '#42A5F5', '#64B5F6', '#90CAF9', '#BBDEFB', '#FB8C00', '#43A047', '#E53935', '#7E57C2', '#26A69A']
const BLUE = '#1976D2'
const BLUE_LIGHT = '#42A5F5'
const BLUE_LIGHTER = '#64B5F6'
const BLUE_PALE = '#90CAF9'

function createChart(el, option) {
  const chart = echarts.init(el.value)
  chart.setOption(option)
  charts.push(chart)
  return chart
}

function pieOption(rows) {
  const colors = ['#1976D2', '#FB8C00', '#43A047', '#7E57C2', '#26A69A', '#E53935']
  return {
    tooltip: { trigger: 'item', formatter: '{b}: {c}人 ({d}%)' },
    legend: { bottom: 0, itemWidth: 10, itemHeight: 10, textStyle: { fontSize: 12 }, itemGap: 12 },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      label: { fontSize: 11, formatter: '{b}\n{d}%' },
      labelLine: { length: 8, length2: 6 },
      data: (rows || []).map((it, i) => ({
        name: it.name,
        value: it.value,
        itemStyle: { color: colors[i % colors.length] }
      }))
    }]
  }
}

function barOption(names, values) {
  const colors = [BLUE_PALE, BLUE_LIGHTER, BLUE_LIGHT, BLUE]
  return {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: 50, right: 20, top: 20, bottom: 35 },
    xAxis: {
      type: 'category',
      data: names,
      axisLabel: { fontSize: 12, interval: 0 }
    },
    yAxis: { type: 'value', axisLabel: { fontSize: 11 }, minInterval: 1 },
    series: [{
      type: 'bar',
      barWidth: '45%',
      data: (values || []).map((v, i) => ({ value: v, itemStyle: { color: colors[i % colors.length] } })),
      label: { show: true, position: 'top', fontSize: 12, fontWeight: 'bold', color: '#333' }
    }]
  }
}

function distToRows(list) {
  return (list || []).filter(it => it && it.value != null)
}

async function loadData() {
  loading.value = true
  try {
    const [ageRes, genderRes, eduRes, partyRes, posRes, deptRes] = await Promise.all([
      getAgeDistribution(), getGenderDistribution(), getEducationDistribution(),
      getPoliticalDistribution(), getPositionLevelDistribution(), getDeptSummary()
    ])
    const ageRows = distToRows(ageRes.data)
    createChart(ageChart, barOption(ageRows.map(r => r.name), ageRows.map(r => r.value)))
    createChart(genderChart, pieOption(distToRows(genderRes.data)))
    createChart(eduChart, pieOption(distToRows(eduRes.data)))
    createChart(partyChart, pieOption(distToRows(partyRes.data)))
    createChart(positionChart, pieOption(distToRows(posRes.data)))

    // 机构干部统计：树取名称 + 编制合并
    const treeRes = await request.get('/organization/tree').catch(() => null)
    const quotaRes = await request.get('/staffing-quota/list').catch(() => null)
    const nameMap = {}
    if (treeRes && Array.isArray(treeRes.data)) {
      const walk = list => {
        if (!list) return
        list.forEach(o => {
          if (o && o.id != null) nameMap[o.id] = o.deptName || o.dept_name || ''
          walk(o.children)
        })
      }
      walk(treeRes.data)
    }
    const quotaMap = {}
    if (quotaRes && Array.isArray(quotaRes.data)) {
      quotaRes.data.forEach(q => {
        if (q && q.deptId != null) {
          quotaMap[q.deptId] = { approved: q.approvedQuota ?? 0, leader: q.leaderQuota ?? 0 }
        }
      })
    }
    const summary = (deptRes && Array.isArray(deptRes.data)) ? deptRes.data : []
    orgTableData.value = summary
      .map(it => {
        const quota = quotaMap[it.deptId] || { approved: 0, leader: 0 }
        const count = Number(it.count) || 0
        return {
          deptId: it.deptId,
          orgName: nameMap[it.deptId] || ('机构#' + it.deptId),
          cadreCount: count,
          approvedQuota: quota.approved,
          leaderQuota: quota.leader,
          vacant: Math.max(0, quota.approved - count)
        }
      })
      .sort((a, b) => b.cadreCount - a.cadreCount)
  } catch (e) {
    ElMessage.error('统计数据加载失败，请确认后端服务已启动')
    console.error('statistics load error', e)
  } finally {
    loading.value = false
  }
}

function handleExportStats() {
  showExportDialog(orgTableData.value, [
    { prop: 'orgName', label: '机构名称' },
    { prop: 'cadreCount', label: '在册干部数' },
    { prop: 'approvedQuota', label: '核定编制' },
    { prop: 'leaderQuota', label: '领导职数' },
    { prop: 'vacant', label: '空编数' }
  ], '机构干部统计表')
}

function handleResize() {
  charts.forEach(c => c.resize())
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
  loadData()
})

onUnmounted(() => {
  charts.forEach(c => c.dispose())
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.chart-card {
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 2px;
  margin-bottom: 0;
}
.chart-title {
  padding: 10px 14px;
  font-size: 14px;
  font-weight: bold;
  color: #1976D2;
  border-bottom: 2px solid #1976D2;
  background: #fafbfc;
}
.chart-body {
  height: 280px;
  padding: 10px 0;
}
</style>
