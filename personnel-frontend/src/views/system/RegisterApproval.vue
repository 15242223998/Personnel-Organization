<template>
  <div>
    <div class="page-header">注册审批</div>

    <div class="search-bar">
      <span class="label">账号：</span>
      <el-input v-model="search.username" placeholder="请输入账号" size="default" style="width:180px" clearable @keyup.enter="handleSearch" />
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="username" label="账号" min-width="120" show-overflow-tooltip />
        <el-table-column prop="realName" label="姓名" width="110" align="center" />
        <el-table-column prop="phone" label="手机号" width="130" align="center" />
        <el-table-column prop="email" label="邮箱" min-width="160" show-overflow-tooltip />
        <el-table-column prop="createTime" label="申请时间" width="160" align="center" />
        <el-table-column label="状态" width="90" align="center">
          <template #default>
            <el-tag type="warning" size="small">待审核</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleApprove(row)">批准</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleReject(row)">拒绝</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div class="pagination-wrap">
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10,20,50]"
        :total="page.total"
        layout="total,sizes,prev,pager,next,jumper"
        background
        small
        @size-change="handleSizeChange"
        @current-change="fetchData"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPendingRegistrations, approveRegistration, rejectRegistration } from '@/api/system'

const search = reactive({ username: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const tableData = ref([])

function fetchData() {
  getPendingRegistrations({
    current: page.current,
    size: page.size,
    status: 0,
    username: search.username || undefined
  }).then(res => {
    page.total = Number(res.data.total) || 0
    tableData.value = res.data.records || []
  })
}

function handleSearch() {
  page.current = 1
  fetchData()
}

function handleReset() {
  search.username = ''
  page.current = 1
  fetchData()
}

function handleSizeChange() {
  page.current = 1
  fetchData()
}

function handleApprove(row) {
  ElMessageBox.confirm(`确定批准账号「${row.username}（${row.realName}）」的注册申请吗？`, '提示', { type: 'warning' })
    .then(() => {
      approveRegistration(row.id).then(() => {
        ElMessage.success('已批准，该账号现在可以登录')
        fetchData()
      })
    })
    .catch(() => {})
}

function handleReject(row) {
  ElMessageBox.confirm(`确定拒绝账号「${row.username}（${row.realName}）」的注册申请吗？`, '提示', { type: 'warning' })
    .then(() => {
      rejectRegistration(row.id).then(() => {
        ElMessage.warning('已拒绝该注册申请')
        fetchData()
      })
    })
    .catch(() => {})
}

fetchData()
</script>
