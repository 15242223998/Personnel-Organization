<template>
  <div>
    <!-- 统计卡片 -->
    <el-row :gutter="10" style="margin-bottom:12px">
      <el-col :span="6" v-for="card in statCards" :key="card.label">
        <div class="stat-card" :style="{ borderLeftColor: card.color }">
          <div class="stat-info">
            <div class="stat-value" :style="{ color: card.color }">{{ card.value }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
          <div class="stat-icon" :style="{ background: card.color }">
            <el-icon :size="28"><component :is="card.icon" /></el-icon>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="10">
      <!-- 预警提醒 -->
      <el-col :span="14">
        <el-card>
          <template #header>
            <span><el-icon><Bell /></el-icon> 待办预警提醒</span>
          </template>
          <el-table :data="alertList" border size="small">
            <el-table-column label="序号" width="50" type="index" align="center" />
            <el-table-column label="预警类型" width="100" align="center">
              <template #default="{row}">
                <el-tag :type="row.tagType" size="small">{{ row.type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="title" label="预警内容" />
            <el-table-column prop="time" label="时间" width="120" align="center" />
            <el-table-column label="操作" width="80" align="center">
              <template #default>
                <span class="link-blue">处理</span>
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
          <template #header><span><el-icon><PieChart /></el-icon> 干部队伍概览</span></template>
          <div ref="miniChart" style="height:180px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, markRaw } from 'vue'
import * as echarts from 'echarts'
import {
  UserFilled, User, OfficeBuilding, Medal, WarningFilled,
  Bell, DataAnalysis, Switch, Stamp, Grid, PieChart, Calendar, Top
} from '@element-plus/icons-vue'

const statCards = [
  { label: '在职干部总数', value: '328', color: '#1976D2', icon: markRaw(UserFilled) },
  { label: '机构数量', value: '46', color: '#43A047', icon: markRaw(OfficeBuilding) },
  { label: '后备干部', value: '35', color: '#FB8C00', icon: markRaw(Medal) },
  { label: '待办事项', value: '12', color: '#E53935', icon: markRaw(WarningFilled) }
]

const alertList = [
  { type: '红色预警', tagType: 'danger', title: '张某某将于3个月内达到退休年龄', time: '2026-08-08' },
  { type: '黄色预警', tagType: 'warning', title: '机械工程学院领导职数空缺1个', time: '2026-08-07' },
  { type: '蓝色提醒', tagType: '', title: '李某某试用期将于2026-09-01到期', time: '2026-08-06' },
  { type: '黄色预警', tagType: 'warning', title: '王某某出国证件逾期未归还', time: '2026-08-05' },
  { type: '红色预警', tagType: 'danger', title: '3名干部处分影响期内，不得提拔', time: '2026-08-04' }
]

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

const miniChart = ref(null)

onMounted(() => {
  const chart = echarts.init(miniChart.value)
  chart.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, itemWidth: 10, itemHeight: 10, textStyle: { fontSize: 12 } },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '42%'],
      label: { fontSize: 11 },
      data: [
        { value: 156, name: '处级干部', itemStyle: { color: '#1976D2' } },
        { value: 98, name: '科级干部', itemStyle: { color: '#42A5F5' } },
        { value: 39, name: '校级领导', itemStyle: { color: '#64B5F6' } },
        { value: 35, name: '后备干部', itemStyle: { color: '#FB8C00' } }
      ]
    }]
  })
  window.addEventListener('resize', () => chart.resize())
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
