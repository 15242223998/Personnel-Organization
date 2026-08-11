<template>
  <div>
    <div class="page-header">角色管理</div>

    <div class="search-bar">
      <span class="label">角色名称：</span>
      <el-input v-model="searchForm.name" placeholder="请输入角色名称" clearable style="width:180px" />
      <span class="label">状态：</span>
      <el-select v-model="searchForm.status" placeholder="请选择" clearable style="width:120px">
        <el-option label="启用" value="启用" />
        <el-option label="禁用" value="禁用" />
      </el-select>
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" size="small" @click="handleAddRole"><el-icon><Plus /></el-icon> 新增角色</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="roleData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="角色名称" min-width="140" show-overflow-tooltip sortable />
        <el-table-column prop="code" label="角色编码" min-width="140" show-overflow-tooltip sortable />
        <el-table-column prop="dataScope" label="数据范围" min-width="110" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="dataScopeTagType(row.dataScope)" size="small">{{ row.dataScope }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="70" align="center" sortable />
        <el-table-column prop="status" label="状态" width="80" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.status === '启用' ? 'success' : 'info'" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="200" show-overflow-tooltip sortable />
        <el-table-column prop="createTime" label="创建时间" width="160" align="center" sortable />
        <el-table-column label="操作" width="220" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleRolePerm(row)">权限配置</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="handleRoleEdit(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleRoleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { Plus, Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const searchForm = reactive({ name: '', status: '' })

function resetSearch() {
  Object.assign(searchForm, { name: '', status: '' })
}

function handleSearch() { ElMessage.success('查询条件已应用') }
function handleAddRole() { ElMessage.info('新增角色功能') }
function handleRolePerm(row) { ElMessage.info(`配置角色「${row.name}」的权限`) }
function handleRoleEdit(row) { ElMessage.info(`编辑角色：${row.name}`) }
function handleRoleDelete(row) {
  ElMessageBox.confirm(`确定删除角色「${row.name}」吗？`, '提示', { type: 'warning' }).then(() => {
    ElMessage.success(`已删除角色：${row.name}`)
  }).catch(() => {})
}

const roleData = [
  { name: '超级管理员', code: 'super_admin', dataScope: '全部数据', sort: 1, status: '启用', remark: '拥有系统所有权限', createTime: '2025-01-01 00:00:00' },
  { name: '系统管理员', code: 'sys_admin', dataScope: '全部数据', sort: 2, status: '启用', remark: '负责系统配置和用户管理', createTime: '2025-01-01 00:00:00' },
  { name: '组织部管理员', code: 'org_admin', dataScope: '全部数据', sort: 3, status: '启用', remark: '负责干部管理、任免、监督等核心业务', createTime: '2025-01-05 10:00:00' },
  { name: '人事处管理员', code: 'hr_admin', dataScope: '本部门数据', sort: 4, status: '启用', remark: '负责人事日常管理、薪酬考勤等', createTime: '2025-01-05 10:10:00' },
  { name: '部门管理员', code: 'dept_admin', dataScope: '本部门数据', sort: 5, status: '启用', remark: '负责本部门人员信息维护和审批', createTime: '2025-01-10 14:00:00' },
  { name: '普通用户', code: 'normal_user', dataScope: '本人数据', sort: 6, status: '启用', remark: '仅可查看本人信息和提交申请', createTime: '2025-01-01 00:00:00' }
]

function dataScopeTagType(scope) {
  const map = { '全部数据': 'danger', '本部门数据': 'warning', '本人数据': 'info' }
  return map[scope] || ''
}
</script>
