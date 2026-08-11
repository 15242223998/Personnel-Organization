<template>
  <div>
    <div class="page-header">干部调配管理</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <!-- 增员 -->
      <el-tab-pane label="增员" name="add">
        <div class="search-bar">
          <el-form :inline="true" :model="addQuery" size="default">
            <el-form-item label="姓名">
              <el-input v-model="addQuery.name" placeholder="输入姓名" style="width:120px" clearable />
            </el-form-item>
            <el-form-item label="调配类型">
              <el-select v-model="addQuery.type" placeholder="全部" style="width:110px" clearable>
                <el-option label="调入" value="调入" />
                <el-option label="录用" value="录用" />
                <el-option label="聘用" value="聘用" />
                <el-option label="转入" value="转入" />
              </el-select>
            </el-form-item>
            <el-form-item label="目标机构">
              <el-select v-model="addQuery.targetDept" placeholder="请选择" style="width:150px" clearable>
                <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.deptName" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
              <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
            </el-form-item>
          </el-form>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openAddDialog('add')"><el-icon><Plus /></el-icon> 新增增员</el-button>
          <el-button @click="exportAddData"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="addData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="type" label="调配类型" width="100" align="center" sortable />
            <el-table-column prop="targetDept" label="目标机构" min-width="160" show-overflow-tooltip sortable />
            <el-table-column prop="targetPosition" label="拟任职务" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="transferDate" label="调配日期" width="110" align="center" sortable />
            <el-table-column prop="docNo" label="文号" min-width="140" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{row}">
                <span class="link-blue" @click="handleEdit(row)">编辑</span>
                <span class="link-blue" style="margin:0 8px;color:#E53935" @click="handleDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <!-- 减员 -->
      <el-tab-pane label="减员" name="reduce">
        <div class="search-bar">
          <el-form :inline="true" :model="reduceQuery" size="default">
            <el-form-item label="姓名">
              <el-input v-model="reduceQuery.name" placeholder="输入姓名" style="width:120px" clearable />
            </el-form-item>
            <el-form-item label="减员类型">
              <el-select v-model="reduceQuery.type" placeholder="全部" style="width:110px" clearable>
                <el-option label="调出" value="调出" />
                <el-option label="辞职" value="辞职" />
                <el-option label="解聘" value="解聘" />
                <el-option label="开除" value="开除" />
              </el-select>
            </el-form-item>
            <el-form-item label="原机构">
              <el-select v-model="reduceQuery.origDept" placeholder="请选择" style="width:150px" clearable>
                <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.deptName" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
              <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
            </el-form-item>
          </el-form>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openAddDialog('reduce')"><el-icon><Plus /></el-icon> 新增减员</el-button>
          <el-button @click="exportReduceData"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="reduceData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="type" label="减员类型" width="100" align="center" sortable>
              <template #default="{row}">
                <el-tag :type="row.type==='开除'?'danger':(row.type==='辞职'||row.type==='解聘'?'warning':'info')" size="small">{{row.type}}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="origDept" label="原机构" min-width="160" show-overflow-tooltip sortable />
            <el-table-column prop="reduceDate" label="减员日期" width="110" align="center" sortable />
            <el-table-column prop="reason" label="原因" min-width="200" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{row}">
                <span class="link-blue" @click="handleEdit(row)">编辑</span>
                <span class="link-blue" style="margin:0 8px;color:#E53935" @click="handleDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <!-- 退休 -->
      <el-tab-pane label="退休" name="retire">
        <div class="search-bar">
          <el-form :inline="true" :model="retireQuery" size="default">
            <el-form-item label="姓名">
              <el-input v-model="retireQuery.name" placeholder="输入姓名" style="width:120px" clearable />
            </el-form-item>
            <el-form-item label="现机构">
              <el-select v-model="retireQuery.curDept" placeholder="请选择" style="width:150px" clearable>
                <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.deptName" />
              </el-select>
            </el-form-item>
            <el-form-item label="状态">
              <el-select v-model="retireQuery.status" placeholder="全部" style="width:110px" clearable>
                <el-option label="待办理" value="待办理" />
                <el-option label="已办理" value="已办理" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
              <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
            </el-form-item>
          </el-form>
        </div>
        <div class="toolbar">
          <el-button @click="exportRetireData"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="retireData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="gender" label="性别" width="60" align="center" sortable />
            <el-table-column prop="birthDate" label="出生年月" width="110" align="center" sortable />
            <el-table-column prop="curDept" label="现机构" min-width="160" show-overflow-tooltip sortable />
            <el-table-column prop="curPosition" label="现职务" min-width="140" show-overflow-tooltip sortable />
            <el-table-column prop="retireDate" label="到龄日期" width="110" align="center" sortable />
            <el-table-column prop="status" label="状态" width="80" align="center" sortable>
              <template #default="{row}">
                <el-tag :type="row.status==='已办理'?'success':'warning'" size="small">{{row.status}}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" align="center" fixed="right">
              <template #default="{row}">
                <span v-if="row.status==='待办理'" class="link-blue" @click="handleRetire(row)">办理退休</span>
                <span v-else class="link-blue" style="color:#999" @click="handleRetireDone(row)">已完成</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <!-- 轮岗 -->
      <el-tab-pane label="轮岗" name="rotate">
        <div class="search-bar">
          <el-form :inline="true" :model="rotateQuery" size="default">
            <el-form-item label="姓名">
              <el-input v-model="rotateQuery.name" placeholder="输入姓名" style="width:120px" clearable />
            </el-form-item>
            <el-form-item label="原机构">
              <el-select v-model="rotateQuery.origDept" placeholder="请选择" style="width:150px" clearable>
                <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.deptName" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
              <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
            </el-form-item>
          </el-form>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openAddDialog('rotate')"><el-icon><Plus /></el-icon> 新增轮岗</el-button>
          <el-button @click="exportRotateData"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="rotateData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="origDeptPos" label="原机构职务" min-width="200" show-overflow-tooltip sortable />
            <el-table-column prop="newDeptPos" label="新机构职务" min-width="200" show-overflow-tooltip sortable />
            <el-table-column prop="rotateDate" label="轮岗日期" width="110" align="center" sortable />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{row}">
                <span class="link-blue" @click="handleEdit(row)">编辑</span>
                <span class="link-blue" style="margin:0 8px;color:#E53935" @click="handleDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="720px" destroy-on-close>
      <el-form :model="dialogForm" label-width="100px" size="default">
        <template v-if="activeTab==='add'">
          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="干部姓名">
                <el-select v-model="dialogForm.name" placeholder="请选择干部" style="width:100%" filterable>
                  <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.name" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="调配类型">
                <el-select v-model="dialogForm.type" placeholder="请选择" style="width:100%">
                  <el-option label="调入" value="调入" />
                  <el-option label="录用" value="录用" />
                  <el-option label="聘用" value="聘用" />
                  <el-option label="转入" value="转入" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="目标机构">
                <el-select v-model="dialogForm.targetDept" placeholder="请选择" style="width:100%">
                  <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.deptName" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="拟任职务">
                <el-input v-model="dialogForm.targetPosition" placeholder="请输入拟任职务" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="调配日期">
                <el-date-picker v-model="dialogForm.transferDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="文号">
                <el-input v-model="dialogForm.docNo" placeholder="请输入文号" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="备注">
            <el-input v-model="dialogForm.remark" type="textarea" :rows="2" placeholder="请输入备注" />
          </el-form-item>
        </template>
        <template v-if="activeTab==='reduce'">
          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="干部姓名">
                <el-select v-model="dialogForm.name" placeholder="请选择干部" style="width:100%" filterable>
                  <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.name" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="减员类型">
                <el-select v-model="dialogForm.type" placeholder="请选择" style="width:100%">
                  <el-option label="调出" value="调出" />
                  <el-option label="辞职" value="辞职" />
                  <el-option label="解聘" value="解聘" />
                  <el-option label="开除" value="开除" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="原机构">
                <el-select v-model="dialogForm.origDept" placeholder="请选择" style="width:100%">
                  <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.deptName" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="减员日期">
                <el-date-picker v-model="dialogForm.reduceDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="原因">
            <el-input v-model="dialogForm.reason" type="textarea" :rows="3" placeholder="请输入减员原因" />
          </el-form-item>
        </template>
        <template v-if="activeTab==='rotate'">
          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="干部姓名">
                <el-select v-model="dialogForm.name" placeholder="请选择干部" style="width:100%" filterable>
                  <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.name" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="轮岗日期">
                <el-date-picker v-model="dialogForm.rotateDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="16">
            <el-col :span="12">
              <el-form-item label="原机构职务">
                <el-input v-model="dialogForm.origDeptPos" placeholder="如：机械工程学院 副院长" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="新机构职务">
                <el-input v-model="dialogForm.newDeptPos" placeholder="如：人事处 处长" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="备注">
            <el-input v-model="dialogForm.remark" type="textarea" :rows="2" placeholder="请输入备注" />
          </el-form-item>
        </template>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible=false">取消</el-button>
        <el-button type="primary" @click="handleSave">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'

const activeTab = ref('add')
const dialogVisible = ref(false)
const dialogTitle = ref('新增增员')

const deptOptions = ref([
  { id: 1, deptName: '党委办公室' },
  { id: 2, deptName: '机械工程学院' },
  { id: 3, deptName: '电气工程学院' },
  { id: 4, deptName: '信息科学与工程学院' },
  { id: 5, deptName: '经济管理学院' },
  { id: 6, deptName: '人事处' },
  { id: 7, deptName: '学生工作处' }
])
const cadreOptions = ref([
  { id: 1, name: '张伟' }, { id: 2, name: '李芳' }, { id: 3, name: '王建国' },
  { id: 4, name: '陈丽' }, { id: 5, name: '刘强' }, { id: 6, name: '赵明' },
  { id: 7, name: '孙梅' }, { id: 8, name: '周志强' }, { id: 9, name: '吴涛' }, { id: 10, name: '郑华' }
])

const addQuery = reactive({ name: '', type: '', targetDept: '' })
const reduceQuery = reactive({ name: '', type: '', origDept: '' })
const retireQuery = reactive({ name: '', curDept: '', status: '' })
const rotateQuery = reactive({ name: '', origDept: '' })

const dialogForm = reactive({
  name: '', type: '', targetDept: '', targetPosition: '', transferDate: '', docNo: '',
  origDept: '', reduceDate: '', reason: '',
  origDeptPos: '', newDeptPos: '', rotateDate: ''
})

const addData = ref([
  { id: 1, name: '吴涛', type: '调入', targetDept: '信息科学与工程学院', targetPosition: '副教授', transferDate: '2024-03-01', docNo: '校人[2024]12号' },
  { id: 2, name: '郑华', type: '录用', targetDept: '人事处', targetPosition: '主任科员', transferDate: '2024-04-15', docNo: '校人[2024]18号' },
  { id: 3, name: '黄磊', type: '聘用', targetDept: '经济管理学院', targetPosition: '讲师', transferDate: '2024-05-20', docNo: '校人[2024]25号' },
  { id: 4, name: '林静', type: '转入', targetDept: '党委办公室', targetPosition: '副主任', transferDate: '2024-06-01', docNo: '校人[2024]31号' },
  { id: 5, name: '徐峰', type: '调入', targetDept: '机械工程学院', targetPosition: '教授', transferDate: '2024-07-10', docNo: '校人[2024]38号' }
])

const reduceData = ref([
  { id: 1, name: '钱明', type: '调出', origDept: '电气工程学院', reduceDate: '2024-02-28', reason: '调往其他高校任教' },
  { id: 2, name: '孙洁', type: '辞职', origDept: '学生工作处', reduceDate: '2024-03-31', reason: '个人发展原因' },
  { id: 3, name: '李杰', type: '解聘', origDept: '经济管理学院', reduceDate: '2024-04-30', reason: '聘期考核不合格' },
  { id: 4, name: '赵伟', type: '调出', origDept: '机械工程学院', reduceDate: '2024-05-15', reason: '调任地方政府部门' }
])

const retireData = ref([
  { id: 1, name: '赵明', gender: '男', birthDate: '1964-08-15', curDept: '电气工程学院', curPosition: '教授', retireDate: '2024-08-15', status: '待办理' },
  { id: 2, name: '王淑芬', gender: '女', birthDate: '1964-09-20', curDept: '人事处', curPosition: '副处长', retireDate: '2024-09-20', status: '待办理' },
  { id: 3, name: '陈国强', gender: '男', birthDate: '1964-05-10', curDept: '党委办公室', curPosition: '调研员', retireDate: '2024-05-10', status: '已办理' },
  { id: 4, name: '刘桂兰', gender: '女', birthDate: '1964-11-08', curDept: '机械工程学院', curPosition: '副教授', retireDate: '2024-11-08', status: '待办理' },
  { id: 5, name: '张振华', gender: '男', birthDate: '1964-03-25', curDept: '信息科学与工程学院', curPosition: '教授', retireDate: '2024-03-25', status: '已办理' }
])

const rotateData = ref([
  { id: 1, name: '周志强', origDeptPos: '电气工程学院 副院长', newDeptPos: '学生工作处 处长', rotateDate: '2024-03-01' },
  { id: 2, name: '陈丽', origDeptPos: '信息科学与工程学院 副院长', newDeptPos: '教务处 处长', rotateDate: '2024-04-15' },
  { id: 3, name: '孙梅', origDeptPos: '机械工程学院 副院长', newDeptPos: '研究生院 副院长', rotateDate: '2024-06-01' },
  { id: 4, name: '刘强', origDeptPos: '经济管理学院 系主任', newDeptPos: '科研处 主任科员', rotateDate: '2024-07-01' }
])

function openAddDialog(tab) {
  const tabNameMap = { add: '增员', reduce: '减员', rotate: '轮岗' }
  dialogTitle.value = '新增' + tabNameMap[tab]
  Object.assign(dialogForm, {
    name: '', type: '', targetDept: '', targetPosition: '', transferDate: '', docNo: '',
    origDept: '', reduceDate: '', reason: '',
    origDeptPos: '', newDeptPos: '', rotateDate: ''
  })
  dialogVisible.value = true
}

function handleEdit(row) {
  ElMessage.info('编辑功能：打开编辑对话框加载数据')
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除该记录吗？`, '提示', { type: 'warning' })
    .then(() => { ElMessage.success('删除成功') })
    .catch(() => {})
}

function handleRetire(row) {
  ElMessageBox.confirm(`确定为"${row.name}"办理退休手续吗？`, '办理退休', { type: 'info' })
    .then(() => {
      row.status = '已办理'
      ElMessage.success('退休手续办理成功')
    })
    .catch(() => {})
}

function handleSave() {
  ElMessage.success('保存成功')
  dialogVisible.value = false
}

function exportAddData() {
  showExportDialog(addData.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'type', label: '调配类型' },
    { prop: 'targetDept', label: '目标机构' },
    { prop: 'targetPosition', label: '拟任职务' },
    { prop: 'transferDate', label: '调配日期' },
    { prop: 'docNo', label: '文号' }
  ], '干部增员')
}
function exportReduceData() {
  showExportDialog(reduceData.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'type', label: '减员类型' },
    { prop: 'origDept', label: '原机构' },
    { prop: 'reduceDate', label: '减员日期' },
    { prop: 'reason', label: '原因' }
  ], '干部减员')
}
function exportRetireData() {
  showExportDialog(retireData.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'gender', label: '性别' },
    { prop: 'birthDate', label: '出生年月' },
    { prop: 'curDept', label: '现机构' },
    { prop: 'curPosition', label: '现职务' },
    { prop: 'retireDate', label: '到龄日期' },
    { prop: 'status', label: '状态' }
  ], '干部退休')
}
function handleSearch() { ElMessage.success('查询条件已应用') }
function handleReset() { ElMessage.info('已重置查询条件') }
function handleRetireDone(row) { ElMessage.success(`${row.name} 已标记为退休完成`) }

function exportRotateData() {
  showExportDialog(rotateData.value, [
    { prop: 'name', label: '姓名' },
    { prop: 'origDeptPos', label: '原机构职务' },
    { prop: 'newDeptPos', label: '新机构职务' },
    { prop: 'rotateDate', label: '轮岗日期' }
  ], '干部轮岗')
}
</script>

<style scoped>
.gov-tabs :deep(.el-tabs__header) {
  background: #fff;
  margin: 0;
  padding: 0 14px;
  border: 1px solid #e0e0e0;
  border-bottom: 2px solid #1976D2;
}
.gov-tabs :deep(.el-tabs__nav-wrap::after) {
  display: none;
}
.gov-tabs :deep(.el-tabs__content) {
  padding-top: 0;
}
</style>
