<template>
  <div>
    <div class="page-header">日常事务管理</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <el-tab-pane label="证照管理" name="certificate">
        <div class="search-bar">
          <span class="label">持证人：</span>
          <el-input v-model="search.cert.name" placeholder="请输入姓名" size="default" style="width:140px" clearable />
          <span class="label">证照类型：</span>
          <el-select v-model="search.cert.type" placeholder="请选择" size="default" style="width:130px" clearable>
            <el-option label="护照" value="护照" />
            <el-option label="港澳通行证" value="港澳通行证" />
            <el-option label="台湾通行证" value="台湾通行证" />
          </el-select>
          <span class="label">状态：</span>
          <el-select v-model="search.cert.status" placeholder="请选择" size="default" style="width:110px" clearable>
            <el-option label="已归还" value="已归还" />
            <el-option label="借出中" value="借出中" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset('cert')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddCert"><el-icon><Plus /></el-icon> 新增登记</el-button>
          <el-button size="small" @click="exportCert"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="certData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="持证人" width="80" align="center" sortable />
            <el-table-column prop="certType" label="证照类型" width="110" align="center" sortable />
            <el-table-column prop="certNo" label="证照号码" min-width="140" align="center" sortable />
            <el-table-column prop="issueDate" label="签发日期" width="110" align="center" sortable />
            <el-table-column prop="expireDate" label="有效期至" width="110" align="center" sortable />
            <el-table-column prop="status" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已归还' ? 'success' : 'warning'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="140" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleCertLend(row)">借出</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleCertReturn(row)">归还</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleCertDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="出境记录" name="overseas">
        <div class="search-bar">
          <span class="label">姓名：</span>
          <el-input v-model="search.overseas.name" placeholder="请输入姓名" size="default" style="width:140px" clearable />
          <span class="label">出境事由：</span>
          <el-select v-model="search.overseas.reason" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="公务出访" value="公务出访" />
            <el-option label="探亲" value="探亲" />
            <el-option label="旅游" value="旅游" />
            <el-option label="学术交流" value="学术交流" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset('overseas')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddOverseas"><el-icon><Plus /></el-icon> 新增记录</el-button>
          <el-button size="small" @click="exportOverseas"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="overseasData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="destination" label="目的地" min-width="110" align="center" sortable />
            <el-table-column prop="reason" label="出境事由" min-width="100" align="center" sortable />
            <el-table-column prop="departDate" label="出境日期" width="110" align="center" sortable />
            <el-table-column prop="returnDate" label="回国日期" width="110" align="center" sortable />
            <el-table-column prop="approveStatus" label="审批状态" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.approveStatus === '已批准' ? 'success' : row.approveStatus === '待审批' ? 'warning' : 'danger'" size="small">{{ row.approveStatus }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="140" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleOverseasView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleOverseasDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="休假管理" name="leave">
        <div class="search-bar">
          <span class="label">申请人：</span>
          <el-input v-model="search.leave.name" placeholder="请输入姓名" size="default" style="width:140px" clearable />
          <span class="label">休假类型：</span>
          <el-select v-model="search.leave.type" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="年休假" value="年休假" />
            <el-option label="病假" value="病假" />
            <el-option label="事假" value="事假" />
            <el-option label="婚假" value="婚假" />
            <el-option label="产假" value="产假" />
          </el-select>
          <span class="label">状态：</span>
          <el-select v-model="search.leave.status" placeholder="请选择" size="default" style="width:110px" clearable>
            <el-option label="待审批" value="待审批" />
            <el-option label="已批准" value="已批准" />
            <el-option label="已驳回" value="已驳回" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset('leave')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddLeave"><el-icon><Plus /></el-icon> 申请休假</el-button>
          <el-button size="small" @click="exportLeave"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="leaveData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="申请人" width="80" align="center" sortable />
            <el-table-column prop="dept" label="部门" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="leaveType" label="休假类型" width="100" align="center" sortable />
            <el-table-column prop="startDate" label="开始日期" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="结束日期" width="110" align="center" sortable />
            <el-table-column prop="days" label="天数" width="60" align="center" sortable />
            <el-table-column prop="status" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已批准' ? 'success' : row.status === '待审批' ? 'warning' : 'danger'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" v-if="row.status === '待审批'" @click="openApprove(row, 'leave')">审批</span>
                <span class="link-blue" v-else @click="handleLeaveView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleLeaveDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="教育培训" name="training">
        <div class="search-bar">
          <span class="label">培训名称：</span>
          <el-input v-model="search.training.name" placeholder="请输入名称" size="default" style="width:160px" clearable />
          <span class="label">培训类型：</span>
          <el-select v-model="search.training.type" placeholder="请选择" size="default" style="width:130px" clearable>
            <el-option label="党校培训" value="党校培训" />
            <el-option label="业务培训" value="业务培训" />
            <el-option label="在线学习" value="在线学习" />
            <el-option label="外出进修" value="外出进修" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset('training')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddTraining"><el-icon><Plus /></el-icon> 新增培训</el-button>
          <el-button size="small" @click="exportTraining"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="trainingData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="培训名称" min-width="180" show-overflow-tooltip sortable />
            <el-table-column prop="type" label="培训类型" width="100" align="center" sortable />
            <el-table-column prop="organizer" label="主办单位" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="startDate" label="开始日期" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="结束日期" width="110" align="center" sortable />
            <el-table-column prop="studentCount" label="参训人数" width="90" align="center" sortable />
            <el-table-column prop="status" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已完成' ? 'success' : row.status === '进行中' ? '' : 'warning'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openStudents(row)">学员管理</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleTrainingEdit(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleTrainingDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="挂职锻炼" name="secondment">
        <div class="search-bar">
          <span class="label">姓名：</span>
          <el-input v-model="search.secondment.name" placeholder="请输入姓名" size="default" style="width:140px" clearable />
          <span class="label">挂职类型：</span>
          <el-select v-model="search.secondment.type" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="上挂" value="上挂" />
            <el-option label="下挂" value="下挂" />
            <el-option label="横向挂" value="横向挂" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset('secondment')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddSecondment"><el-icon><Plus /></el-icon> 新增挂职</el-button>
          <el-button size="small" @click="exportSecondment"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="secondmentData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="originalDept" label="原单位/部门" min-width="150" show-overflow-tooltip sortable />
            <el-table-column prop="targetDept" label="挂职单位" min-width="150" show-overflow-tooltip sortable />
            <el-table-column prop="position" label="挂任职务" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="type" label="挂职类型" width="90" align="center" sortable />
            <el-table-column prop="startDate" label="开始日期" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="结束日期" width="110" align="center" sortable />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleSecondmentView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleSecondmentDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="自助申报" name="declare">
        <div class="toolbar" style="border-top:1px solid #e0e0e0">
          <el-button type="primary" size="small" @click="handleAddDeclare"><el-icon><Plus /></el-icon> 新增申报</el-button>
          <el-button size="small" @click="exportDeclare"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="declareData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="申报人" width="90" align="center" sortable />
            <el-table-column prop="type" label="申报事项" width="110" align="center" sortable />
            <el-table-column prop="title" label="申报标题" min-width="200" show-overflow-tooltip sortable />
            <el-table-column prop="submitDate" label="提交时间" width="150" align="center" sortable />
            <el-table-column prop="status" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已通过' ? 'success' : row.status === '待审批' ? 'warning' : 'danger'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" v-if="row.status === '待审批'" @click="openApprove(row, 'declare')">审批</span>
                <span class="link-blue" v-else @click="handleDeclareView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleDeclareDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <el-dialog title="审批" v-model="approveDialog" width="500px">
      <el-form :model="approveForm" label-width="80px">
        <el-form-item label="申请人">{{ approveForm.name }}</el-form-item>
        <el-form-item label="事项">{{ approveForm.item }}</el-form-item>
        <el-form-item label="审批意见">
          <el-input v-model="approveForm.opinion" type="textarea" :rows="3" placeholder="请输入审批意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="approveDialog = false">取消</el-button>
        <el-button type="danger" @click="handleReject">驳回</el-button>
        <el-button type="primary" @click="handleApprove">通过</el-button>
      </template>
    </el-dialog>

    <el-dialog :title="currentTraining?.name + ' - 学员管理'" v-model="studentDialog" width="650px">
      <div style="margin-bottom:10px">
        <el-button type="primary" size="small" @click="handleAddStudent"><el-icon><Plus /></el-icon> 添加学员</el-button>
      </div>
      <el-table :data="studentList" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="100" align="center" sortable />
        <el-table-column prop="dept" label="部门" min-width="140" align="center" show-overflow-tooltip sortable />
        <el-table-column prop="position" label="职务" min-width="120" align="center" show-overflow-tooltip sortable />
        <el-table-column prop="score" label="考核成绩" width="100" align="center" sortable />
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <span class="link-blue" style="color:#E53935" @click="handleStudentRemove(row)">移除</span>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage } from 'element-plus'

const activeTab = ref('certificate')
const approveDialog = ref(false)
const studentDialog = ref(false)
const currentTraining = ref(null)

const search = reactive({
  cert: { name: '', type: '', status: '' },
  overseas: { name: '', reason: '' },
  leave: { name: '', type: '', status: '' },
  training: { name: '', type: '' },
  secondment: { name: '', type: '' }
})

const approveForm = reactive({ name: '', item: '', opinion: '' })

const certData = [
  { name: '张建国', certType: '护照', certNo: 'E12345678', issueDate: '2022-03-15', expireDate: '2032-03-14', status: '已归还', remark: '因私护照' },
  { name: '李秀英', certType: '港澳通行证', certNo: 'C87654321', issueDate: '2023-06-20', expireDate: '2033-06-19', status: '借出中', remark: '赴港学术交流' },
  { name: '王志强', certType: '护照', certNo: 'E23456789', issueDate: '2021-09-10', expireDate: '2031-09-09', status: '已归还', remark: '公务护照' },
  { name: '刘德明', certType: '台湾通行证', certNo: 'T34567890', issueDate: '2024-01-05', expireDate: '2029-01-04', status: '已归还', remark: '' },
  { name: '陈丽华', certType: '护照', certNo: 'E45678901', issueDate: '2020-11-20', expireDate: '2030-11-19', status: '借出中', remark: '出国探亲' }
]

const overseasData = [
  { name: '李秀英', destination: '中国香港', reason: '学术交流', departDate: '2026-07-20', returnDate: '2026-07-25', approveStatus: '已批准', remark: '参加国际学术会议' },
  { name: '张建国', destination: '新加坡', reason: '公务出访', departDate: '2026-08-15', returnDate: '2026-08-22', approveStatus: '已批准', remark: '校际交流访问' },
  { name: '赵国栋', destination: '日本', reason: '旅游', departDate: '2026-09-01', returnDate: '2026-09-07', approveStatus: '待审批', remark: '个人旅游' },
  { name: '孙红梅', destination: '德国', reason: '学术交流', departDate: '2026-06-10', returnDate: '2026-06-20', approveStatus: '已批准', remark: '访问学者' },
  { name: '周伟民', destination: '泰国', reason: '探亲', departDate: '2026-05-01', returnDate: '2026-05-08', approveStatus: '已驳回', remark: '出境时间与工作冲突' }
]

const leaveData = [
  { name: '张建国', dept: '机械工程学院', leaveType: '年休假', startDate: '2026-08-01', endDate: '2026-08-10', days: 10, status: '已批准' },
  { name: '李秀英', dept: '电子信息学院', leaveType: '病假', startDate: '2026-08-05', endDate: '2026-08-07', days: 3, status: '已批准' },
  { name: '王志强', dept: '教务处', leaveType: '事假', startDate: '2026-08-12', endDate: '2026-08-13', days: 2, status: '待审批' },
  { name: '刘德明', dept: '人事处', leaveType: '年休假', startDate: '2026-08-20', endDate: '2026-08-29', days: 10, status: '待审批' },
  { name: '吴玉芬', dept: '财务处', leaveType: '婚假', startDate: '2026-09-01', endDate: '2026-09-10', days: 10, status: '已驳回' }
]

const trainingData = [
  { name: '2026年春季处级干部进修班', type: '党校培训', organizer: '省委党校', startDate: '2026-03-01', endDate: '2026-04-30', studentCount: 45, status: '已完成' },
  { name: '中青年干部能力提升培训班', type: '业务培训', organizer: '组织部', startDate: '2026-06-15', endDate: '2026-06-25', studentCount: 60, status: '已完成' },
  { name: '学习贯彻党的二十届三中全会精神专题研讨', type: '党校培训', organizer: '校党校', startDate: '2026-08-10', endDate: '2026-08-14', studentCount: 80, status: '进行中' },
  { name: '2026年秋季学期在线学习', type: '在线学习', organizer: '国家教育行政学院', startDate: '2026-09-01', endDate: '2026-12-31', studentCount: 200, status: '未开始' }
]

const secondmentData = [
  { name: '陈丽华', originalDept: '财务处', targetDept: '教育部财务司', position: '副处长（挂职）', type: '上挂', startDate: '2025-09-01', endDate: '2026-08-31' },
  { name: '郑海涛', originalDept: '学校办公室', targetDept: 'XX县人民政府', position: '副县长（挂职）', type: '下挂', startDate: '2025-03-01', endDate: '2027-02-28' },
  { name: '钱淑华', originalDept: '科研处', targetDept: '科技厅高新处', position: '副处长（挂职）', type: '上挂', startDate: '2026-01-15', endDate: '2027-01-14' },
  { name: '马晓东', originalDept: '学生处', targetDept: '清华大学学工部', position: '部长助理（挂职）', type: '横向挂', startDate: '2026-03-01', endDate: '2026-12-31' }
]

const declareData = [
  { name: '张建国', type: '出差报销', title: '赴新加坡出访差旅费报销', submitDate: '2026-08-01 10:30', status: '待审批' },
  { name: '李秀英', type: '用车申请', title: '8月15日机场接送用车', submitDate: '2026-08-05 14:20', status: '已通过' },
  { name: '王志强', type: '印章使用', title: '教务处文件盖章申请', submitDate: '2026-08-08 09:15', status: '已通过' },
  { name: '赵国栋', type: '会议室预约', title: '8月20日学术报告厅使用申请', submitDate: '2026-08-10 16:40', status: '待审批' },
  { name: '孙红梅', type: '出差报销', title: '赴德国访问学者差旅费报销', submitDate: '2026-07-01 11:00', status: '已驳回' }
]

const studentList = ref([])

const defaultStudents = [
  { name: '张建国', dept: '机械工程学院', position: '院长', score: '优秀' },
  { name: '李秀英', dept: '电子信息学院', position: '党委书记', score: '优秀' },
  { name: '王志强', dept: '教务处', position: '处长', score: '良好' },
  { name: '刘德明', dept: '人事处', position: '副处长', score: '良好' },
  { name: '赵国栋', dept: '后勤管理处', position: '处长', score: '合格' }
]

function openApprove(row, type) {
  approveForm.name = row.name
  approveForm.item = type === 'leave' ? row.leaveType + '申请' : row.type + ' - ' + row.title
  approveForm.opinion = ''
  approveDialog.value = true
}

function handleApprove() {
  ElMessage.success('审批通过')
  approveDialog.value = false
}

function handleReject() {
  ElMessage.success('已驳回')
  approveDialog.value = false
}

function openStudents(row) {
  currentTraining.value = row
  studentList.value = defaultStudents
  studentDialog.value = true
}

function exportCert() {
  showExportDialog(certData, [
    { prop: 'name', label: '持证人' },
    { prop: 'certType', label: '证照类型' },
    { prop: 'certNo', label: '证照号码' },
    { prop: 'issueDate', label: '签发日期' },
    { prop: 'expireDate', label: '有效期至' },
    { prop: 'status', label: '状态' },
    { prop: 'remark', label: '备注' }
  ], '证照管理')
}
function exportOverseas() {
  showExportDialog(overseasData, [
    { prop: 'name', label: '姓名' },
    { prop: 'destination', label: '目的地' },
    { prop: 'reason', label: '出境事由' },
    { prop: 'departDate', label: '出境日期' },
    { prop: 'returnDate', label: '回国日期' },
    { prop: 'approveStatus', label: '审批状态' },
    { prop: 'remark', label: '备注' }
  ], '出境记录')
}
function exportLeave() {
  showExportDialog(leaveData, [
    { prop: 'name', label: '申请人' },
    { prop: 'dept', label: '部门' },
    { prop: 'leaveType', label: '休假类型' },
    { prop: 'startDate', label: '开始日期' },
    { prop: 'endDate', label: '结束日期' },
    { prop: 'days', label: '天数' },
    { prop: 'status', label: '状态' }
  ], '休假管理')
}
function exportTraining() {
  showExportDialog(trainingData, [
    { prop: 'name', label: '培训名称' },
    { prop: 'type', label: '培训类型' },
    { prop: 'organizer', label: '主办单位' },
    { prop: 'startDate', label: '开始日期' },
    { prop: 'endDate', label: '结束日期' },
    { prop: 'studentCount', label: '参训人数' },
    { prop: 'status', label: '状态' }
  ], '教育培训')
}
function exportSecondment() {
  showExportDialog(secondmentData, [
    { prop: 'name', label: '姓名' },
    { prop: 'originalDept', label: '原单位/部门' },
    { prop: 'targetDept', label: '挂职单位' },
    { prop: 'position', label: '挂任职务' },
    { prop: 'type', label: '挂职类型' },
    { prop: 'startDate', label: '开始日期' },
    { prop: 'endDate', label: '结束日期' }
  ], '挂职锻炼')
}
function exportDeclare() {
  showExportDialog(declareData, [
    { prop: 'name', label: '申报人' },
    { prop: 'type', label: '申报事项' },
    { prop: 'title', label: '申报标题' },
    { prop: 'submitDate', label: '提交时间' },
    { prop: 'status', label: '状态' }
  ], '自助申报')
}

function handleSearch() { ElMessage.success('查询条件已应用') }
function handleReset(tab) {
  if (tab === 'cert') search.cert = { name: '', type: '', status: '' }
  else if (tab === 'overseas') search.overseas = { name: '', reason: '' }
  else if (tab === 'leave') search.leave = { name: '', type: '', status: '' }
  else if (tab === 'training') search.training = { name: '', type: '' }
  else if (tab === 'secondment') search.secondment = { name: '', type: '' }
  ElMessage.info('已重置查询条件')
}

function handleAddCert() { ElMessage.info('新增证照登记功能') }
function handleCertLend(row) { ElMessage.success(`已将 ${row.name} 的 ${row.certType}(${row.certNo}) 标记为借出`) }
function handleCertReturn(row) { ElMessage.success(`${row.name} 的 ${row.certType} 已归还`) }
function handleCertDelete(row) { ElMessage.success(`已删除 ${row.name} 的证照记录`) }

function handleAddOverseas() { ElMessage.info('新增出境记录功能') }
function handleOverseasView(row) { ElMessage.info(`查看 ${row.name} 的出境记录详情`) }
function handleOverseasDelete(row) { ElMessage.success(`已删除 ${row.name} 的出境记录`) }

function handleAddLeave() { ElMessage.info('申请休假功能') }
function handleLeaveView(row) { ElMessage.info(`查看 ${row.name} 的休假详情`) }
function handleLeaveDelete(row) { ElMessage.success(`已删除 ${row.name} 的休假记录`) }

function handleAddTraining() { ElMessage.info('新增培训功能') }
function handleTrainingEdit(row) { ElMessage.info(`编辑培训：${row.name}`) }
function handleTrainingDelete(row) { ElMessage.success(`已删除培训：${row.name}`) }

function handleAddSecondment() { ElMessage.info('新增挂职记录功能') }
function handleSecondmentView(row) { ElMessage.info(`查看 ${row.name} 的挂职详情`) }
function handleSecondmentDelete(row) { ElMessage.success(`已删除 ${row.name} 的挂职记录`) }

function handleAddDeclare() { ElMessage.info('新增申报功能') }
function handleDeclareView(row) { ElMessage.info(`查看申报：${row.title}`) }
function handleDeclareDelete(row) { ElMessage.success(`已删除申报：${row.title}`) }

function handleAddStudent() { ElMessage.info('添加学员功能') }
function handleStudentRemove(row) { ElMessage.success(`已移除学员：${row.name}`) }
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
