<template>
  <div>
    <div class="page-header">班子管理</div>

    <div class="search-bar">
      <span class="label">机构名称：</span>
      <el-input v-model="search.deptName" placeholder="请输入机构名称" size="default" style="width:180px" clearable />
      <span class="label">班子届次：</span>
      <el-select v-model="search.term" placeholder="请选择" size="default" style="width:120px" clearable>
        <el-option label="2026届" value="2026届" />
        <el-option label="2025届" value="2025届" />
        <el-option label="2024届" value="2024届" />
      </el-select>
      <el-button type="primary" @click="fetchData"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="handleReset">重置</el-button>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon> 新增班子</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="deptName" label="机构名称" min-width="180" show-overflow-tooltip sortable />
        <el-table-column prop="term" label="班子届次" width="100" align="center" sortable />
        <el-table-column prop="leaderName" label="主要负责人" width="120" align="center" sortable />
        <el-table-column prop="memberCount" label="班子人数" width="110" align="center" sortable />
        <el-table-column prop="memberList" label="班子成员" min-width="300" show-overflow-tooltip />
        <el-table-column prop="startDate" label="任期起始" width="110" align="center" sortable />
        <el-table-column prop="endDate" label="任期届满" width="110" align="center" sortable />
        <el-table-column prop="status" label="状态" width="100" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.status === '在任' ? 'success' : 'info'" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleEdit(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="handleView(row)">查看成员</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
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

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="所属机构" prop="deptName">
          <el-select v-model="form.deptName" placeholder="请选择机构" style="width:100%" filterable>
            <el-option label="机械工程学院" value="机械工程学院" />
            <el-option label="电子信息学院" value="电子信息学院" />
            <el-option label="经济管理学院" value="经济管理学院" />
            <el-option label="计算机科学与技术学院" value="计算机科学与技术学院" />
            <el-option label="外国语学院" value="外国语学院" />
            <el-option label="马克思主义学院" value="马克思主义学院" />
            <el-option label="体育教学部" value="体育教学部" />
            <el-option label="继续教育学院" value="继续教育学院" />
          </el-select>
        </el-form-item>
        <el-form-item label="班子届次" prop="term">
          <el-input v-model="form.term" placeholder="如：2026届" />
        </el-form-item>
        <el-form-item label="主要负责人" prop="leaderName">
          <el-input v-model="form.leaderName" placeholder="请输入主要负责人姓名" />
        </el-form-item>
        <el-form-item label="班子人数" prop="memberCount">
          <el-input-number v-model="form.memberCount" :min="1" :max="20" style="width:100%" />
        </el-form-item>
        <el-form-item label="任期起始" prop="startDate">
          <el-date-picker v-model="form.startDate" type="date" placeholder="选择日期" style="width:100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="任期届满" prop="endDate">
          <el-date-picker v-model="form.endDate" type="date" placeholder="选择日期" style="width:100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" style="width:100%">
            <el-option label="在任" value="在任" />
            <el-option label="届满" value="届满" />
            <el-option label="调整中" value="调整中" />
          </el-select>
        </el-form-item>
        <el-form-item label="班子分工" prop="dutyDesc">
          <el-input v-model="form.dutyDesc" type="textarea" :rows="3" placeholder="描述班子成员分工情况" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog title="班子成员" v-model="memberDialogVisible" width="800px">
      <el-table :data="memberTable" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="position" label="职务" min-width="160" show-overflow-tooltip />
        <el-table-column prop="duty" label="分工职责" min-width="200" show-overflow-tooltip />
        <el-table-column prop="phone" label="联系电话" width="130" align="center" />
        <el-table-column prop="isPrincipal" label="是否正职" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isPrincipal ? 'success' : 'info'" size="small">{{ row.isPrincipal ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage, ElMessageBox } from 'element-plus'

const search = reactive({ deptName: '', term: '' })
const page = reactive({ current: 1, size: 10, total: 0 })
const dialogVisible = ref(false)
const memberDialogVisible = ref(false)
const dialogTitle = ref('')
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref(null)
const memberTable = ref([])

const form = reactive({
  deptName: '', term: '', leaderName: '', memberCount: 5,
  startDate: '', endDate: '', status: '在任', dutyDesc: ''
})

const rules = {
  deptName: [{ required: true, message: '请选择机构', trigger: 'change' }],
  term: [{ required: true, message: '请输入班子届次', trigger: 'blur' }],
  leaderName: [{ required: true, message: '请输入主要负责人', trigger: 'blur' }],
  memberCount: [{ required: true, message: '请输入班子人数', trigger: 'blur' }],
  startDate: [{ required: true, message: '请选择任期起始', trigger: 'change' }],
}

const mockData = [
  { id: 1, deptName: '机械工程学院', term: '2026届', leaderName: '张建国', memberCount: 7, memberList: '张建国(院长)、李永强(书记)、王海峰(副院长)、陈志远(副院长)、赵文博(副书记)、刘明辉(教学秘书)、孙晓东(科研秘书)', startDate: '2026-06-01', endDate: '2028-05-31', status: '在任' },
  { id: 2, deptName: '电子信息学院', term: '2026届', leaderName: '王志强', memberCount: 9, memberList: '王志强(院长)、赵国栋(书记)、钱伟强(副院长)、周海涛(副院长)、吴玉芬(副书记)、郑建国(系主任)、王丽华(系主任)、张明辉(教学秘书)、李新宇(科研秘书)', startDate: '2026-06-01', endDate: '2028-05-31', status: '在任' },
  { id: 3, deptName: '经济管理学院', term: '2025届', leaderName: '刘德明', memberCount: 5, memberList: '刘德明(院长)、孙红梅(书记)、陈丽华(副院长)、李国强(副书记)、王建民(系主任)', startDate: '2025-09-01', endDate: '2027-08-31', status: '在任' },
  { id: 4, deptName: '计算机科学与技术学院', term: '2026届', leaderName: '郑海涛', memberCount: 7, memberList: '郑海涛(院长)、钱淑华(书记)、李伟民(副院长)、赵建国(副院长)、孙玉芬(副书记)、王海峰(系主任)、陈志远(系主任)', startDate: '2026-03-01', endDate: '2028-02-28', status: '在任' },
  { id: 5, deptName: '外国语学院', term: '2025届', leaderName: '周伟民', memberCount: 6, memberList: '周伟民(院长)、吴玉芬(书记)、刘德明(副院长)、李秀英(副书记)、王芳(系主任)、张丽(教学秘书)', startDate: '2025-09-01', endDate: '2027-08-31', status: '在任' },
  { id: 6, deptName: '马克思主义学院', term: '2024届', leaderName: '赵建国', memberCount: 5, memberList: '赵建国(院长)、陈志远(书记)、刘明辉(副院长)、孙晓东(副书记)、王丽华(系主任)', startDate: '2024-09-01', endDate: '2026-08-31', status: '届满' },
  { id: 7, deptName: '体育教学部', term: '2026届', leaderName: '钱伟强', memberCount: 4, memberList: '钱伟强(主任)、李国强(副主任)、王建民(教学组长)、张明辉(行政秘书)', startDate: '2026-06-01', endDate: '2028-05-31', status: '在任' },
  { id: 8, deptName: '继续教育学院', term: '2025届', leaderName: '李伟民', memberCount: 5, memberList: '李伟民(院长)、孙玉芬(书记)、赵文博(副院长)、王海峰(副书记)、陈志远(教学主任)', startDate: '2025-09-01', endDate: '2027-08-31', status: '在任' },
  { id: 9, deptName: '党委办公室、校长办公室', term: '2026届', leaderName: '王海峰', memberCount: 3, memberList: '王海峰(主任)、张丽(副主任)、刘明辉(副主任)', startDate: '2026-06-01', endDate: '2028-05-31', status: '在任' },
  { id: 10, deptName: '组织部（党校）', term: '2026届', leaderName: '李秀英', memberCount: 3, memberList: '李秀英(部长)、王芳(副部长)、赵文博(党校办公室主任)', startDate: '2026-06-01', endDate: '2028-05-31', status: '在任' },
  { id: 11, deptName: '人事处（教师工作部）', term: '2025届', leaderName: '陈丽华', memberCount: 4, memberList: '陈丽华(处长)、李国强(副处长)、王建民(副处长)、孙晓东(科长)', startDate: '2025-09-01', endDate: '2027-08-31', status: '在任' },
]

const allData = ref([...mockData])

const filteredData = computed(() => {
  let list = allData.value
  if (search.deptName) list = list.filter(d => d.deptName.includes(search.deptName))
  if (search.term) list = list.filter(d => d.term === search.term)
  return list
})

const tableData = computed(() => {
  const start = (page.current - 1) * page.size
  return filteredData.value.slice(start, start + page.size)
})

function fetchData() {
  page.total = filteredData.value.length
}

function handleReset() {
  search.deptName = ''
  search.term = ''
  page.current = 1
  fetchData()
}

function handleSizeChange() {
  page.current = 1
  fetchData()
}

function resetForm() {
  formRef.value?.resetFields()
  isEdit.value = false
  editId.value = null
  Object.assign(form, { deptName: '', term: '', leaderName: '', memberCount: 5, startDate: '', endDate: '', status: '在任', dutyDesc: '' })
}

function handleAdd() {
  dialogTitle.value = '新增班子'
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑班子'
  isEdit.value = true
  editId.value = row.id
  Object.assign(form, {
    deptName: row.deptName, term: row.term, leaderName: row.leaderName,
    memberCount: row.memberCount, startDate: row.startDate, endDate: row.endDate,
    status: row.status, dutyDesc: row.dutyDesc || ''
  })
  dialogVisible.value = true
}

function handleView(row) {
  const names = row.memberList.split('、')
  memberTable.value = names.map((n, i) => {
    const match = n.match(/^(.+?)\((.+?)\)$/)
    return {
      name: match ? match[1] : n,
      position: match ? match[2] : '',
      duty: '负责相关工作',
      phone: '138xxxx' + String(1000 + i).slice(-4),
      isPrincipal: i === 0
    }
  })
  memberDialogVisible.value = true
}

function handleSubmit() {
  formRef.value.validate((valid) => {
    if (!valid) return
    const memberList = form.deptName + '班子成员名单'
    if (isEdit.value) {
      const item = allData.value.find(d => d.id === editId.value)
      if (item) {
        Object.assign(item, { ...form, memberList: item.memberList })
      }
      ElMessage.success('班子信息更新成功')
    } else {
      allData.value.push({
        id: Date.now(),
        ...form,
        memberList: memberList
      })
      ElMessage.success('班子创建成功')
    }
    dialogVisible.value = false
    fetchData()
  })
}

function handleDelete(row) {
  ElMessageBox.confirm('确定删除该班子记录吗？', '提示', { type: 'warning' }).then(() => {
    allData.value = allData.value.filter(d => d.id !== row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

function handleExport() {
  showExportDialog(filteredData.value, [
    { prop: 'deptName', label: '机构名称' },
    { prop: 'term', label: '班子届次' },
    { prop: 'leaderName', label: '主要负责人' },
    { prop: 'memberCount', label: '班子人数' },
    { prop: 'memberList', label: '班子成员' },
    { prop: 'startDate', label: '任期起始' },
    { prop: 'endDate', label: '任期届满' },
    { prop: 'status', label: '状态' }
  ], '班子管理')
}

fetchData()
</script>
