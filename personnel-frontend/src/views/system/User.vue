<template>
  <div>
    <div class="page-header">用户管理</div>

    <div class="search-bar">
      <span class="label">用户名：</span>
      <el-input v-model="searchForm.username" placeholder="请输入用户名" size="default" style="width:140px" clearable />
      <span class="label">姓名：</span>
      <el-input v-model="searchForm.name" placeholder="请输入姓名" size="default" style="width:120px" clearable />
      <span class="label">用户类型：</span>
      <el-select v-model="searchForm.type" placeholder="请选择" size="default" style="width:130px" clearable>
        <el-option v-for="r in roleOptions" :key="r.value" :label="r.label" :value="r.value" />
      </el-select>
      <span class="label">状态：</span>
      <el-select v-model="searchForm.status" placeholder="请选择" size="default" style="width:100px" clearable>
        <el-option label="启用" value="启用" />
        <el-option label="禁用" value="禁用" />
      </el-select>
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" size="small" @click="openAdd"><el-icon><Plus /></el-icon> 新增用户</el-button>
      <el-button size="small" @click="handleExportUsers"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="pagedData" border size="small">
        <el-table-column label="序号" width="55" align="center">
          <template #default="{ $index }">{{ (page.current - 1) * page.size + $index + 1 }}</template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" width="110" align="center" sortable />
        <el-table-column prop="name" label="姓名" width="90" align="center" sortable />
        <el-table-column prop="email" label="邮箱" min-width="180" show-overflow-tooltip sortable />
        <el-table-column prop="phone" label="手机" width="120" align="center" sortable />
        <el-table-column prop="type" label="用户类型" width="110" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="roleTagType(row.type)" size="small">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="dept" label="部门" min-width="150" align="center" show-overflow-tooltip sortable />
        <el-table-column prop="status" label="状态" width="80" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.status === '启用' ? 'success' : 'info'" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastLogin" label="最后登录" width="160" align="center" sortable />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openEdit(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="handleResetPwd(row)">重置密码</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div style="display:flex;justify-content:flex-end;margin-top:12px">
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        size="small"
      />
    </div>

    <el-dialog :title="isEdit ? '编辑用户' : '新增用户'" v-model="dialogVisible" width="560px">
      <el-form :model="form" label-width="90px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="用户名">
              <el-input v-model="form.username" placeholder="请输入用户名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名">
              <el-input v-model="form.name" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="邮箱">
              <el-input v-model="form.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号">
              <el-input v-model="form.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="用户类型">
              <el-select v-model="form.type" placeholder="请选择" style="width:100%">
                <el-option v-for="r in roleOptions" :key="r.value" :label="r.label" :value="r.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所属部门">
              <el-select v-model="form.dept" placeholder="请选择" style="width:100%">
                <el-option label="党委办公室、校长办公室" value="党委办公室、校长办公室" />
                <el-option label="组织部（党校）" value="组织部（党校）" />
                <el-option label="人事处" value="人事处" />
                <el-option label="教务处" value="教务处" />
                <el-option label="机械工程学院" value="机械工程学院" />
                <el-option label="电子信息学院" value="电子信息学院" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio label="启用">启用</el-radio>
            <el-radio label="禁用">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'

const dialogVisible = ref(false)
const isEdit = ref(false)

const roleOptions = [
  { label: '超级管理员', value: '超级管理员' },
  { label: '系统管理员', value: '系统管理员' },
  { label: '组织部管理员', value: '组织部管理员' },
  { label: '人事处管理员', value: '人事处管理员' },
  { label: '部门管理员', value: '部门管理员' },
  { label: '普通用户', value: '普通用户' }
]

const searchForm = reactive({ username: '', name: '', type: '', status: '' })

const form = reactive({
  username: '', name: '', email: '', phone: '', type: '', dept: '', status: '启用'
})

const adminUser = { username: 'admin', name: '系统管理员', email: 'admin@lnu.edu.cn', phone: '138******00', type: '超级管理员', dept: '党委办公室、校长办公室', status: '启用', lastLogin: '2026-08-10 08:30:15' }

const surnames = ['张','李','王','刘','陈','杨','赵','黄','周','吴','徐','孙','胡','朱','高','林','何','郭','马','罗']
const givenNames = ['伟','芳','娜','敏','静','丽','强','磊','军','洋','勇','艳','杰','娟','涛','明','超','秀英','霞','平','刚','桂英','建国','建军','志强','丽娟','晓东','晓红','雪梅']
const depts = [
  { id:1, deptName:'党委办公室、校长办公室' },
  { id:2, deptName:'机械工程学院' },
  { id:3, deptName:'电气工程学院' },
  { id:4, deptName:'信息科学与工程学院' },
  { id:5, deptName:'经济管理学院' },
  { id:6, deptName:'人事处（教师工作部）' },
  { id:7, deptName:'学生工作处' },
  { id:8, deptName:'教务处' },
  { id:9, deptName:'科研处' },
  { id:10, deptName:'财务处' },
  { id:11, deptName:'组织部（党校）' },
  { id:12, deptName:'宣传部（新闻中心）' },
  { id:13, deptName:'土木工程学院' },
  { id:14, deptName:'材料科学与工程学院' },
  { id:15, deptName:'自动化学院' },
  { id:16, deptName:'计算机学院' }
]

const initialMap = {
  '张':'z','李':'l','王':'w','刘':'l','陈':'c','杨':'y','赵':'z','黄':'h','周':'z','吴':'w',
  '徐':'x','孙':'s','胡':'h','朱':'z','高':'g','林':'l','何':'h','郭':'g','马':'m','罗':'l',
  '伟':'wei','芳':'fang','娜':'na','敏':'min','静':'jing','丽':'li','强':'qiang','磊':'lei',
  '军':'jun','洋':'yang','勇':'yong','艳':'yan','杰':'jie','娟':'juan','涛':'tao','明':'ming',
  '超':'chao','秀英':'xiuy','霞':'xia','平':'ping','刚':'gang','桂英':'guiy','建国':'jiang',
  '建军':'jianj','志强':'zhiq','丽娟':'lij','晓东':'xiaod','晓红':'xiaoh','雪梅':'xuem'
}

function pinyin(name) {
  let py = ''
  for (let i = 0; i < name.length; i++) {
    const ch = name.charAt(i)
    if (i === 0 && ch === '刘') { py += 'l'; continue }
    py += initialMap[ch] || ch
  }
  return py
}

const positionLevels = ['校级','处级','科级']
const roleByLevel = { '校级': '系统管理员', '处级': '部门管理员', '科级': '普通用户' }

function generateUserData() {
  const data = [adminUser]
  const baseDate = new Date('2026-08-10')
  for (let i = 2; i <= 328; i++) {
    const surname = surnames[Math.floor(Math.random() * surnames.length)]
    const givenName = givenNames[Math.floor(Math.random() * givenNames.length)]
    const name = surname + givenName
    const dept = depts[Math.floor(Math.random() * depts.length)]
    const level = positionLevels[Math.floor(Math.random() * (i < 15 ? 1 : 3))]
    const daysAgo = Math.floor(Math.random() * 120)
    const loginDate = new Date(baseDate.getTime() - daysAgo * 86400000)
    const h = String(Math.floor(Math.random() * 12) + 8).padStart(2, '0')
    const m = String(Math.floor(Math.random() * 60)).padStart(2, '0')
    const s = String(Math.floor(Math.random() * 60)).padStart(2, '0')
    const status = (Math.random() < 0.08) ? '禁用' : '启用'
    data.push({
      username: pinyin(name) + (i < 100 ? String(i).padStart(2,'0') : i),
      name,
      email: pinyin(name) + '@lnu.edu.cn',
      phone: '1' + (30 + Math.floor(Math.random() * 10)) + String(Math.floor(Math.random() * 90000000 + 10000000)).substring(0, 4) + '****' + String(Math.floor(Math.random() * 100)).padStart(2, '0'),
      type: roleByLevel[level],
      dept: dept.deptName,
      status,
      lastLogin: `${loginDate.getFullYear()}-${String(loginDate.getMonth()+1).padStart(2,'0')}-${String(loginDate.getDate()).padStart(2,'0')} ${h}:${m}:${s}`
    })
  }
  return data
}

const allUserData = generateUserData()

const page = reactive({ current: 1, size: 10, total: 0 })

const filteredData = computed(() => {
  let list = allUserData
  const s = searchForm
  if (s.username) list = list.filter(u => u.username.includes(s.username))
  if (s.name) list = list.filter(u => u.name.includes(s.name))
  if (s.type) list = list.filter(u => u.type === s.type)
  if (s.status) list = list.filter(u => u.status === s.status)
  return list
})

const pagedData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

watch(filteredData, (v) => {
  page.total = v.length
  if (page.current > 1 && (page.current - 1) * page.size >= v.length) {
    page.current = Math.max(1, Math.ceil(v.length / page.size))
  }
}, { immediate: true })

watch(() => page.size, () => { page.current = 1 })

function roleTagType(type) {
  const map = { '超级管理员': 'danger', '系统管理员': 'warning', '组织部管理员': '', '人事处管理员': 'success', '部门管理员': '', '普通用户': 'info' }
  return map[type] || ''
}

function resetSearch() {
  Object.assign(searchForm, { username: '', name: '', type: '', status: '' })
  page.current = 1
}

function openAdd() {
  isEdit.value = false
  Object.assign(form, { username: '', name: '', email: '', phone: '', type: '', dept: '', status: '启用' })
  dialogVisible.value = true
}

function openEdit(row) {
  isEdit.value = true
  Object.assign(form, { ...row })
  dialogVisible.value = true
}

function handleSubmit() {
  ElMessage.success(isEdit.value ? '编辑成功' : '新增成功')
  dialogVisible.value = false
}

function handleResetPwd(row) {
  ElMessageBox.confirm(`确定重置用户「${row.name}」的密码吗？重置后密码为默认密码123456。`, '提示', { type: 'warning' }).then(() => {
    ElMessage.success('密码已重置为123456')
  }).catch(() => {})
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定删除用户「${row.name}」吗？`, '提示', { type: 'warning' }).then(() => {
    ElMessage.success('删除成功')
  }).catch(() => {})
}

function handleSearch() {
  page.current = 1
}

function handleExportUsers() {
  showExportDialog(filteredData.value, [
    { prop: 'username', label: '用户名' },
    { prop: 'name', label: '姓名' },
    { prop: 'email', label: '邮箱' },
    { prop: 'phone', label: '手机' },
    { prop: 'type', label: '用户类型' },
    { prop: 'dept', label: '部门' },
    { prop: 'status', label: '状态' },
    { prop: 'lastLogin', label: '最后登录' }
  ], '用户列表')
}
</script>
