<template>
  <div>
    <div class="page-header">干部监督管理</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <el-tab-pane label="廉政意见" name="integrity">
        <div class="search-bar">
          <span class="label">姓名：</span>
          <el-input v-model="search.integrity.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
          <span class="label">意见类型：</span>
          <el-select v-model="search.integrity.type" placeholder="请选择" size="default" style="width:140px" clearable>
            <el-option label="提拔任用" value="提拔任用" />
            <el-option label="评优评先" value="评优评先" />
            <el-option label="换届考察" value="换届考察" />
            <el-option label="出国出境" value="出国出境" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch('integrity')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddIntegrity"><el-icon><Plus /></el-icon> 新增廉政意见</el-button>
          <el-button size="small" @click="exportIntegrity"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="integrityData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="opinionType" label="意见类型" min-width="110" align="center" sortable />
            <el-table-column prop="source" label="来源" min-width="110" align="center" sortable />
            <el-table-column prop="date" label="日期" width="110" align="center" sortable />
            <el-table-column prop="result" label="结果" width="80" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.result === '同意' ? 'success' : 'danger'" size="small">{{ row.result }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleIntegrityView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleIntegrityEdit(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleIntegrityDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="信访举报" name="complaint">
        <div class="search-bar">
          <span class="label">被举报人：</span>
          <el-input v-model="search.complaint.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
          <span class="label">状态：</span>
          <el-select v-model="search.complaint.status" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="待处理" value="待处理" />
            <el-option label="查核中" value="查核中" />
            <el-option label="已办结" value="已办结" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch('complaint')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddComplaint"><el-icon><Plus /></el-icon> 登记举报</el-button>
          <el-button size="small" @click="exportComplaint"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="complaintData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="reportedName" label="被举报人" width="80" align="center" sortable />
            <el-table-column prop="source" label="来源" min-width="100" align="center" sortable />
            <el-table-column prop="type" label="类型" min-width="100" align="center" sortable />
            <el-table-column prop="date" label="日期" width="110" align="center" sortable />
            <el-table-column prop="status" label="状态" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已办结' ? 'success' : row.status === '查核中' ? 'warning' : 'info'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="content" label="举报内容摘要" min-width="200" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleComplaintView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleComplaintProcess(row)">办理</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleComplaintDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="个人事项报告" name="personal">
        <div class="search-bar">
          <span class="label">姓名：</span>
          <el-input v-model="search.personal.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
          <span class="label">年度：</span>
          <el-select v-model="search.personal.year" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="2025" value="2025" />
            <el-option label="2024" value="2024" />
            <el-option label="2023" value="2023" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch('personal')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddPersonal"><el-icon><Plus /></el-icon> 新增报告</el-button>
          <el-button size="small" @click="exportPersonal"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="personalData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="姓名" width="100" align="center" sortable />
            <el-table-column prop="year" label="年度" width="80" align="center" sortable />
            <el-table-column prop="submitDate" label="提交日期" width="110" align="center" sortable />
            <el-table-column prop="checkResult" label="核查结果" width="110" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.checkResult === '一致' ? 'success' : row.checkResult === '未报告' ? 'danger' : 'warning'" size="small">{{ row.checkResult }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="200" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="180" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handlePersonalView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handlePersonalCheck(row)">核查</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handlePersonalEdit(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handlePersonalDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="预警记录" name="alert">
        <div class="search-bar">
          <span class="label">类型：</span>
          <el-select v-model="search.alert.type" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="红色预警" value="红色" />
            <el-option label="黄色预警" value="黄色" />
            <el-option label="蓝色提醒" value="蓝色" />
          </el-select>
          <span class="label">是否已读：</span>
          <el-select v-model="search.alert.read" placeholder="请选择" size="default" style="width:100px" clearable>
            <el-option label="已读" value="已读" />
            <el-option label="未读" value="未读" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch('alert')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleMarkAllRead"><el-icon><Bell /></el-icon> 标记全部已读</el-button>
          <el-button size="small" @click="exportAlert"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="alertData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="type" label="类型" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.type === '红色' ? 'danger' : row.type === '黄色' ? 'warning' : ''" size="small">{{ row.type }}预警</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="title" label="标题" min-width="220" show-overflow-tooltip sortable />
            <el-table-column prop="relatedCadre" label="关联干部" min-width="100" align="center" sortable />
            <el-table-column prop="remindTarget" label="提醒对象" min-width="120" align="center" sortable />
            <el-table-column prop="isRead" label="是否已读" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.isRead === '已读' ? 'info' : 'danger'" size="small">{{ row.isRead }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createTime" label="创建时间" width="150" align="center" sortable />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleAlertView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleAlertProcess(row)">处理</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { Search, Plus, Download, Bell } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage } from 'element-plus'

const activeTab = ref('integrity')

const search = reactive({
  integrity: { name: '', type: '' },
  complaint: { name: '', status: '' },
  personal: { name: '', year: '' },
  alert: { type: '', read: '' }
})

const integrityData = [
  { name: '张建国', opinionType: '提拔任用', source: '组织部', date: '2026-07-15', result: '同意' },
  { name: '李秀英', opinionType: '评优评先', source: '纪委', date: '2026-07-10', result: '同意' },
  { name: '王志强', opinionType: '换届考察', source: '考察组', date: '2026-06-28', result: '暂缓' },
  { name: '刘德明', opinionType: '出国出境', source: '外事办', date: '2026-06-20', result: '同意' },
  { name: '陈丽华', opinionType: '提拔任用', source: '组织部', date: '2026-06-15', result: '不同意' }
]

const complaintData = [
  { reportedName: '赵国栋', source: '来信', type: '经济问题', date: '2026-08-01', status: '待处理', content: '反映其在工程招标中收受好处费' },
  { reportedName: '孙红梅', source: '来访', type: '作风问题', date: '2026-07-25', status: '查核中', content: '反映其生活作风问题' },
  { reportedName: '周伟民', source: '来电', type: '工作纪律', date: '2026-07-18', status: '已办结', content: '反映其上班时间脱岗' },
  { reportedName: '吴玉芬', source: '网络举报', type: '廉洁问题', date: '2026-07-10', status: '查核中', content: '反映其违规收受礼品礼金' },
  { reportedName: '郑海涛', source: '上级转办', type: '选人用人', date: '2026-07-05', status: '已办结', content: '反映其在干部选拔中任人唯亲' },
  { reportedName: '钱淑华', source: '来信', type: '经济问题', date: '2026-06-30', status: '待处理', content: '反映其虚报冒领差旅费' }
]

const personalData = [
  { name: '张建国', year: '2025', submitDate: '2026-01-15', checkResult: '一致', remark: '房产、投资等事项均如实报告' },
  { name: '李秀英', year: '2025', submitDate: '2026-01-18', checkResult: '漏报', remark: '漏报配偶持有基金情况，已补报' },
  { name: '王志强', year: '2025', submitDate: '2026-01-20', checkResult: '一致', remark: '所有事项均如实报告' },
  { name: '刘德明', year: '2025', submitDate: '2026-01-16', checkResult: '未报告', remark: '未按规定时间提交，已约谈' },
  { name: '陈丽华', year: '2024', submitDate: '2025-01-12', checkResult: '一致', remark: '报告事项完整准确' }
]

const alertData = [
  { type: '红色', title: '张某某将于3个月内达到退休年龄，请及时办理退休手续', relatedCadre: '张某某', remindTarget: '人事处', isRead: '未读', createTime: '2026-08-08 09:30' },
  { type: '黄色', title: '机械工程学院领导职数空缺1个，请尽快配备', relatedCadre: '-', remindTarget: '组织部', isRead: '已读', createTime: '2026-08-07 14:20' },
  { type: '蓝色', title: '李某某试用期将于2026-09-01到期，请组织考核', relatedCadre: '李某某', remindTarget: '干部科', isRead: '未读', createTime: '2026-08-06 10:15' },
  { type: '黄色', title: '王某某出国证件逾期未归还，请督促归还', relatedCadre: '王某某', remindTarget: '外事办', isRead: '已读', createTime: '2026-08-05 16:45' },
  { type: '红色', title: '3名干部处分影响期内，不得提拔使用', relatedCadre: '多人', remindTarget: '干部科', isRead: '已读', createTime: '2026-08-04 08:00' }
]

function resetSearch(tab) {
  if (tab === 'integrity') search.integrity = { name: '', type: '' }
  if (tab === 'complaint') search.complaint = { name: '', status: '' }
  if (tab === 'personal') search.personal = { name: '', year: '' }
  if (tab === 'alert') search.alert = { type: '', read: '' }
}

function handleSearch() { ElMessage.success('查询条件已应用') }

function handleAddIntegrity() { ElMessage.info('新增廉政意见功能') }
function handleIntegrityView(row) { ElMessage.info(`查看 ${row.name} 的廉政意见详情`) }
function handleIntegrityEdit(row) { ElMessage.info(`编辑 ${row.name} 的廉政意见`) }
function handleIntegrityDelete(row) { ElMessage.success(`已删除 ${row.name} 的廉政意见`) }

function handleAddComplaint() { ElMessage.info('登记举报功能') }
function handleComplaintView(row) { ElMessage.info(`查看 ${row.reportedName} 的信访举报详情`) }
function handleComplaintProcess(row) { ElMessage.info(`办理 ${row.reportedName} 的举报件`) }
function handleComplaintDelete(row) { ElMessage.success(`已删除 ${row.reportedName} 的举报记录`) }

function handleAddPersonal() { ElMessage.info('新增个人事项报告功能') }
function handlePersonalView(row) { ElMessage.info(`查看 ${row.name} 的 ${row.year}年 个人事项报告`) }
function handlePersonalCheck(row) { ElMessage.info(`核查 ${row.name} 的 ${row.year}年 个人事项`) }
function handlePersonalEdit(row) { ElMessage.info(`编辑 ${row.name} 的个人事项报告`) }
function handlePersonalDelete(row) { ElMessage.success(`已删除 ${row.name} 的个人事项报告`) }

function handleMarkAllRead() { ElMessage.success('已标记全部预警为已读') }
function handleAlertView(row) { ElMessage.info(`查看预警详情：${row.title}`) }
function handleAlertProcess(row) { ElMessage.info(`处理预警：${row.title}`) }

function exportIntegrity() {
  showExportDialog(integrityData, [
    { prop: 'name', label: '姓名' },
    { prop: 'opinionType', label: '意见类型' },
    { prop: 'source', label: '来源' },
    { prop: 'date', label: '日期' },
    { prop: 'result', label: '结果' }
  ], '廉政意见')
}
function exportComplaint() {
  showExportDialog(complaintData, [
    { prop: 'reportedName', label: '被举报人' },
    { prop: 'source', label: '来源' },
    { prop: 'type', label: '类型' },
    { prop: 'date', label: '日期' },
    { prop: 'status', label: '状态' },
    { prop: 'content', label: '举报内容摘要' }
  ], '信访举报')
}
function exportPersonal() {
  showExportDialog(personalData, [
    { prop: 'name', label: '姓名' },
    { prop: 'year', label: '年度' },
    { prop: 'submitDate', label: '提交日期' },
    { prop: 'checkResult', label: '核查结果' },
    { prop: 'remark', label: '备注' }
  ], '个人事项报告')
}
function exportAlert() {
  showExportDialog(alertData, [
    { prop: 'type', label: '类型' },
    { prop: 'title', label: '标题' },
    { prop: 'relatedCadre', label: '关联干部' },
    { prop: 'remindTarget', label: '提醒对象' },
    { prop: 'isRead', label: '是否已读' },
    { prop: 'createTime', label: '创建时间' }
  ], '预警记录')
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
