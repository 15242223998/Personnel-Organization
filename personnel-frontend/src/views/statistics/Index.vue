<template>
  <div>
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
        <el-button size="small" type="primary" style="float:right;margin-top:-2px" @click="handleExportStats"><el-icon><Download /></el-icon> 导出</el-button>
      </div>
      <el-table :data="orgTableData" border size="small">
        <el-table-column prop="orgName" label="机构名称" min-width="200" align="center" />
        <el-table-column prop="bianzhi" label="编制数" width="90" align="center" />
        <el-table-column prop="shiyou" label="实有人数" width="90" align="center" />
        <el-table-column prop="kongbian" label="空编数" width="90" align="center">
          <template #default="{ row }">
            <span :style="{ color: row.kongbian > 0 ? '#E53935' : '#43A047', fontWeight: 'bold' }">{{ row.kongbian }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="leaderPos" label="领导职数" width="100" align="center" />
        <el-table-column prop="equipped" label="已配备" width="90" align="center" />
        <el-table-column prop="vacant" label="空缺" width="90" align="center">
          <template #default="{ row }">
            <span :style="{ color: row.vacant > 0 ? '#FB8C00' : '#43A047', fontWeight: 'bold' }">{{ row.vacant }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="fillRate" label="配备率" width="100" align="center">
          <template #default="{ row }">
            <span style="font-weight:bold;color:#1976D2">{{ row.fillRate }}%</span>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import { Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage } from 'element-plus'

const BLUE = '#1976D2'
const BLUE_LIGHT = '#42A5F5'
const BLUE_LIGHTER = '#64B5F6'
const BLUE_PALE = '#90CAF9'
const ORANGE = '#FB8C00'
const GREEN = '#43A047'
const RED = '#E53935'

const ageChart = ref(null)
const genderChart = ref(null)
const eduChart = ref(null)
const partyChart = ref(null)
const positionChart = ref(null)

let charts = []

const orgTableData = [
  { orgName: '党委办公室、校长办公室', bianzhi: 28, shiyou: 26, kongbian: 2, leaderPos: 5, equipped: 4, vacant: 1, fillRate: 80 },
  { orgName: '组织部（党校）', bianzhi: 18, shiyou: 18, kongbian: 0, leaderPos: 4, equipped: 4, vacant: 0, fillRate: 100 },
  { orgName: '宣传部（新闻中心）', bianzhi: 15, shiyou: 14, kongbian: 1, leaderPos: 3, equipped: 3, vacant: 0, fillRate: 100 },
  { orgName: '人事处（教师工作部）', bianzhi: 25, shiyou: 24, kongbian: 1, leaderPos: 5, equipped: 5, vacant: 0, fillRate: 100 },
  { orgName: '教务处', bianzhi: 32, shiyou: 30, kongbian: 2, leaderPos: 5, equipped: 4, vacant: 1, fillRate: 80 },
  { orgName: '科研处', bianzhi: 20, shiyou: 19, kongbian: 1, leaderPos: 4, equipped: 4, vacant: 0, fillRate: 100 },
  { orgName: '财务处', bianzhi: 22, shiyou: 22, kongbian: 0, leaderPos: 4, equipped: 4, vacant: 0, fillRate: 100 },
  { orgName: '机械工程学院', bianzhi: 45, shiyou: 43, kongbian: 2, leaderPos: 7, equipped: 6, vacant: 1, fillRate: 86 },
  { orgName: '电子信息学院', bianzhi: 52, shiyou: 50, kongbian: 2, leaderPos: 7, equipped: 7, vacant: 0, fillRate: 100 },
  { orgName: '经济管理学院', bianzhi: 48, shiyou: 45, kongbian: 3, leaderPos: 7, equipped: 5, vacant: 2, fillRate: 71 }
]

function createChart(el, option) {
  const chart = echarts.init(el.value)
  chart.setOption(option)
  charts.push(chart)
  return chart
}

const pieBaseOption = {
  tooltip: { trigger: 'item', formatter: '{b}: {c}人 ({d}%)' },
  legend: {
    bottom: 0,
    itemWidth: 10,
    itemHeight: 10,
    textStyle: { fontSize: 12 },
    itemGap: 12
  },
  series: [{
    type: 'pie',
    radius: ['40%', '65%'],
    center: ['50%', '45%'],
    label: { fontSize: 11, formatter: '{b}\n{d}%' },
    labelLine: { length: 8, length2: 6 }
  }]
}

onMounted(() => {
  createChart(ageChart, {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: 50, right: 20, top: 20, bottom: 35 },
    xAxis: {
      type: 'category',
      data: ['35岁以下', '36-45岁', '46-55岁', '56岁以上'],
      axisLabel: { fontSize: 12 }
    },
    yAxis: { type: 'value', axisLabel: { fontSize: 11 } },
    series: [{
      type: 'bar',
      barWidth: '45%',
      data: [
        { value: 68, itemStyle: { color: BLUE_PALE } },
        { value: 125, itemStyle: { color: BLUE_LIGHTER } },
        { value: 98, itemStyle: { color: BLUE_LIGHT } },
        { value: 37, itemStyle: { color: BLUE } }
      ],
      label: { show: true, position: 'top', fontSize: 12, fontWeight: 'bold', color: '#333' }
    }]
  })

  createChart(genderChart, {
    ...pieBaseOption,
    series: [{
      ...pieBaseOption.series[0],
      data: [
        { value: 212, name: '男', itemStyle: { color: BLUE } },
        { value: 116, name: '女', itemStyle: { color: ORANGE } }
      ]
    }]
  })

  createChart(eduChart, {
    ...pieBaseOption,
    series: [{
      ...pieBaseOption.series[0],
      data: [
        { value: 48, name: '博士', itemStyle: { color: BLUE } },
        { value: 152, name: '硕士', itemStyle: { color: BLUE_LIGHT } },
        { value: 108, name: '本科', itemStyle: { color: BLUE_LIGHTER } },
        { value: 20, name: '大专及以下', itemStyle: { color: BLUE_PALE } }
      ]
    }]
  })

  createChart(partyChart, {
    ...pieBaseOption,
    series: [{
      ...pieBaseOption.series[0],
      radius: ['35%', '62%'],
      center: ['50%', '45%'],
      data: [
        { value: 258, name: '中共党员', itemStyle: { color: RED } },
        { value: 28, name: '民主党派', itemStyle: { color: BLUE } },
        { value: 42, name: '群众', itemStyle: { color: BLUE_LIGHTER } }
      ]
    }]
  })

  createChart(positionChart, {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    legend: { data: ['编制数', '实有数'], top: 0, right: 10, itemWidth: 12, itemHeight: 10, textStyle: { fontSize: 12 } },
    grid: { left: 80, right: 20, top: 35, bottom: 25 },
    xAxis: { type: 'value', axisLabel: { fontSize: 11 } },
    yAxis: {
      type: 'category',
      data: ['校级领导', '处级正职', '处级副职', '科级正职', '科级副职', '一般干部'],
      axisLabel: { fontSize: 12 }
    },
    series: [
      {
        name: '编制数',
        type: 'bar',
        barWidth: '30%',
        data: [12, 45, 78, 95, 65, 80],
        itemStyle: { color: BLUE_LIGHTER },
        label: { show: true, position: 'right', fontSize: 11 }
      },
      {
        name: '实有数',
        type: 'bar',
        barWidth: '30%',
        data: [11, 42, 72, 88, 60, 75],
        itemStyle: { color: BLUE },
        label: { show: true, position: 'right', fontSize: 11 }
      }
    ]
  })

  window.addEventListener('resize', handleResize)
})

function handleResize() {
  charts.forEach(c => c.resize())
}

onUnmounted(() => {
  charts.forEach(c => c.dispose())
  window.removeEventListener('resize', handleResize)
})

function handleExportStats() {
  showExportDialog(orgTableData, [
    { prop: 'orgName', label: '机构名称' },
    { prop: 'bianzhi', label: '编制数' },
    { prop: 'shiyou', label: '实有人数' },
    { prop: 'kongbian', label: '空编数' },
    { prop: 'leaderPos', label: '领导职数' },
    { prop: 'equipped', label: '已配备' },
    { prop: 'vacant', label: '空缺' },
    { prop: 'fillRate', label: '配备率' }
  ], '机构干部统计表')
}
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
