<template>
  <div>
    <div class="page-header">{{ pageTitle }}</div>


      <div v-show="activeTab === 'integrity'">
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
      </div>

      <div v-show="activeTab === 'complaint'">
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
      </div>

      <div v-show="activeTab === 'personal'">
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
      </div>

      <div v-show="activeTab === 'alert'">
        <div class="alert-config-bar">
          <span style="font-weight:600;font-size:13px;color:#333">预警规则配置：</span>
          <el-checkbox-group v-model="alertRules" size="small" @change="regenerateAlerts">
            <el-checkbox label="retire" border>到龄退休</el-checkbox>
            <el-checkbox label="probation" border>试用期将满</el-checkbox>
            <el-checkbox label="overStaff" border>三超问题</el-checkbox>
            <el-checkbox label="tenure" border>任职年限</el-checkbox>
            <el-checkbox label="grassroots" border>基层履历不足</el-checkbox>
            <el-checkbox label="discipline" border>处分影响期</el-checkbox>
          </el-checkbox-group>
          <el-select v-model="alertTimeFilter" style="width:130px;margin-left:12px" @change="regenerateAlerts" size="default">
            <el-option label="3个月内" value="3m" />
            <el-option label="6个月内" value="6m" />
            <el-option label="1年内" value="1y" />
            <el-option label="全部时间" value="all" />
          </el-select>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="regenerateAlerts"><el-icon><Bell /></el-icon> 重新扫描</el-button>
          <el-button size="small" @click="exportAlert"><el-icon><Download /></el-icon> 导出预警清单</el-button>
          <span style="margin-left:12px;font-size:12px;color:#888">
            最后扫描: {{ lastScanTime }}
          </span>
        </div>
        <div v-if="generatedAlerts.length === 0 && alertRules.length > 0" style="text-align:center;padding:60px;color:#43A047">
          <el-icon style="font-size:52px"><CircleCheckFilled /></el-icon>
          <p style="margin-top:12px;font-size:15px">未发现预警信息，当前数据符合管理要求</p>
        </div>
        <div v-else-if="alertRules.length === 0" style="text-align:center;padding:60px;color:#999">
          <el-icon style="font-size:52px"><Warning /></el-icon>
          <p style="margin-top:12px;font-size:14px">请至少勾选一项预警规则进行扫描</p>
        </div>
        <div class="table-wrap" v-else>
          <el-table :data="generatedAlerts" border size="small" row-class-name="alert-row" @sort-change="(info) => sortAlerts(info)">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="category" label="预警类别" width="120" align="center" sortable="custom">
              <template #default="{ row }">
                <el-tag :type="row.level === '红色' ? 'danger' : row.level === '黄色' ? 'warning' : ''" size="small">{{ row.category }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="level" label="级别" width="70" align="center" sortable="custom">
              <template #default="{ row }">
                <span :style="{color: row.level === '红色' ? '#E53935' : row.level === '黄色' ? '#FB8C00' : '#1976D2', fontWeight: 'bold'}">{{ row.level }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="title" label="预警内容" min-width="260" show-overflow-tooltip />
            <el-table-column prop="relatedCadre" label="关联干部" min-width="100" align="center" sortable="custom" />
            <el-table-column prop="deptName" label="所在机构" min-width="120" show-overflow-tooltip />
            <el-table-column prop="triggerDate" label="触发时间" width="110" align="center" sortable="custom" />
            <el-table-column prop="deadline" label="到期时间" width="110" align="center" sortable="custom">
              <template #default="{ row }">{{ row.deadline || '—' }}</template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleAlertView(row)">详情</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleAlertDismiss(row)">忽略</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>

      <div v-show="activeTab === 'admonish'">
        <div class="search-bar">
          <span class="label">被提醒人：</span>
          <el-input v-model="search.admonish.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
          <span class="label">类型：</span>
          <el-select v-model="search.admonish.type" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="提醒" value="提醒" />
            <el-option label="函询" value="函询" />
            <el-option label="诫勉" value="诫勉" />
          </el-select>
          <span class="label">状态：</span>
          <el-select v-model="search.admonish.status" placeholder="请选择" size="default" style="width:110px" clearable>
            <el-option label="已完成" value="已完成" />
            <el-option label="处理中" value="处理中" />
            <el-option label="待处理" value="待处理" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch('admonish')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddAdmonish"><el-icon><Plus /></el-icon> 新增提醒函询诫勉</el-button>
          <el-button size="small" @click="exportAdmonish"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="admonishData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="被提醒人" width="90" align="center" sortable />
            <el-table-column prop="type" label="类型" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.type === '诫勉' ? 'danger' : row.type === '函询' ? 'warning' : ''" size="small">{{ row.type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="reason" label="事由摘要" min-width="200" show-overflow-tooltip sortable />
            <el-table-column prop="date" label="发起日期" width="110" align="center" sortable />
            <el-table-column prop="replyDate" label="回复日期" width="110" align="center" sortable />
            <el-table-column prop="handlingOrg" label="承办单位" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="status" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已完成' ? 'success' : row.status === '处理中' ? 'warning' : 'info'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleAdmonishView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleAdmonishEdit(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleAdmonishDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>

      <div v-show="activeTab === 'audit'">
        <div class="search-bar">
          <span class="label">被审计人：</span>
          <el-input v-model="search.audit.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
          <span class="label">审计类型：</span>
          <el-select v-model="search.audit.type" placeholder="请选择" size="default" style="width:130px" clearable>
            <el-option label="离任审计" value="离任审计" />
            <el-option label="任中审计" value="任中审计" />
            <el-option label="专项审计" value="专项审计" />
          </el-select>
          <span class="label">审计结果：</span>
          <el-select v-model="search.audit.result" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="合格" value="合格" />
            <el-option label="基本合格" value="基本合格" />
            <el-option label="存在违规" value="存在违规" />
          </el-select>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch('audit')">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddAudit"><el-icon><Plus /></el-icon> 新增审计项目</el-button>
          <el-button size="small" @click="exportAudit"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="auditData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="name" label="被审计人" width="90" align="center" sortable />
            <el-table-column prop="dept" label="所在部门" min-width="150" show-overflow-tooltip sortable />
            <el-table-column prop="position" label="时任职务" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="type" label="审计类型" width="100" align="center" sortable />
            <el-table-column prop="auditOrg" label="审计单位" min-width="150" show-overflow-tooltip sortable />
            <el-table-column prop="startDate" label="审计开始" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="审计结束" width="110" align="center" sortable />
            <el-table-column prop="result" label="审计结果" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.result === '合格' ? 'success' : row.result === '存在违规' ? 'danger' : 'warning'" size="small">{{ row.result }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="handleAuditView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="handleAuditEdit(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleAuditDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>

      <!-- 预警详情弹窗 -->
      <el-dialog v-model="alertDetailVisible" title="预警详情" width="680px" align-center destroy-on-close>
        <el-descriptions v-if="currentAlert" :column="2" border size="small">
          <el-descriptions-item label="预警类别">
            <el-tag :type="currentAlert.level === '红色' ? 'danger' : currentAlert.level === '黄色' ? 'warning' : ''" size="small">{{ currentAlert.category }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="预警级别">
            <span :style="{ color: currentAlert.level === '红色' ? '#E53935' : currentAlert.level === '黄色' ? '#FB8C00' : '#1976D2', fontWeight: 'bold' }">{{ currentAlert.level }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="关联干部">{{ currentAlert.relatedCadre }}</el-descriptions-item>
          <el-descriptions-item label="所在机构">{{ currentAlert.deptName }}</el-descriptions-item>
          <el-descriptions-item label="触发时间">{{ currentAlert.triggerDate }}</el-descriptions-item>
          <el-descriptions-item label="到期时间">{{ currentAlert.deadline || '—' }}</el-descriptions-item>
          <el-descriptions-item label="预警内容" :span="2">{{ currentAlert.title }}</el-descriptions-item>
        </el-descriptions>
        <template #footer>
          <el-button @click="alertDetailVisible = false">关闭</el-button>
          <el-button type="primary" @click="handleAlertDismiss(currentAlert); alertDetailVisible = false">忽略该预警</el-button>
        </template>
      </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Search, Plus, Download, Bell, CircleCheckFilled, Warning } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { generateAlerts } from '@/utils/alert-service'
import { ElMessage } from 'element-plus'

const route = useRoute()

const tabRouteMap = {
  '/supervision/integrity': 'integrity',
  '/supervision/complaint': 'complaint',
  '/supervision/personal': 'personal',
  '/supervision/alert': 'alert',
  '/supervision/admonish': 'admonish',
  '/supervision/audit': 'audit'
}
const activeTab = ref(tabRouteMap[route.path] || 'integrity')

const titleMap = {
  integrity: '廉政意见',
  complaint: '信访举报',
  personal: '个人事项报告',
  alert: '智能预警分析',
  admonish: '提醒函询诫勉',
  audit: '经济责任审计'
}
const pageTitle = computed(() => titleMap[activeTab.value] || '干部监督管理')

watch(() => route.path, (path) => {
  activeTab.value = tabRouteMap[path] || 'integrity'
})

const search = reactive({
  integrity: { name: '', type: '' },
  complaint: { name: '', status: '' },
  personal: { name: '', year: '' },
  alert: { type: '', read: '' },
  admonish: { name: '', type: '', status: '' },
  audit: { name: '', type: '', result: '' }
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

const alertRules = ref(['retire', 'overStaff', 'tenure', 'probation', 'discipline', 'grassroots'])
const alertTimeFilter = ref('all')
const generatedAlerts = ref([])
const lastScanTime = ref('')
const alertDetailVisible = ref(false)
const currentAlert = ref(null)

function regenerateAlerts() {
  generatedAlerts.value = generateAlerts({ rules: alertRules.value, timeFilter: alertTimeFilter.value })
  const now = new Date()
  lastScanTime.value = `${now.getHours().toString().padStart(2,'0')}:${now.getMinutes().toString().padStart(2,'0')}:${now.getSeconds().toString().padStart(2,'0')}`
}

function sortAlerts({ prop, order }) {
  if (!prop || !order) return
  const dir = order === 'ascending' ? 1 : -1
  generatedAlerts.value.sort((a, b) => {
    const va = a[prop] || ''; const vb = b[prop] || ''
    return String(va).localeCompare(String(vb), 'zh-CN') * dir
  })
}

function handleAlertView(row) {
  currentAlert.value = row
  alertDetailVisible.value = true
}
function handleAlertDismiss(row) {
  generatedAlerts.value = generatedAlerts.value.filter(a => a !== row)
  ElMessage.success('已忽略该条预警')
}

function handleMarkAllRead() { ElMessage.success('已标记全部预警为已读') }

regenerateAlerts()

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
  showExportDialog(generatedAlerts.value, [
    { prop: 'category', label: '预警类别' },
    { prop: 'level', label: '级别' },
    { prop: 'title', label: '预警内容' },
    { prop: 'relatedCadre', label: '关联干部' },
    { prop: 'deptName', label: '所在机构' },
    { prop: 'deadline', label: '到期时间' }
  ], '智能预警清单')
}

const admonishData = [
  { name: '张建国', type: '提醒', reason: '年度考核中群众反映较多，提醒注意工作方法', date: '2026-07-25', replyDate: '2026-08-01', handlingOrg: '组织部', status: '已完成' },
  { name: '王志强', type: '函询', reason: '关于科研经费使用问题的函询', date: '2026-07-10', replyDate: '2026-07-17', handlingOrg: '纪委', status: '已完成' },
  { name: '刘德明', type: '诫勉', reason: '因履职不到位、工作推进不力，经研究决定予以诫勉', date: '2026-06-15', replyDate: '2026-06-30', handlingOrg: '组织部、纪委', status: '已完成' },
  { name: '赵建国', type: '提醒', reason: '在干部选拔任用工作中存在程序不规范问题', date: '2026-08-05', replyDate: '', handlingOrg: '组织部', status: '处理中' },
  { name: '周伟民', type: '函询', reason: '关于个人有关事项报告抽查发现不一致问题', date: '2026-08-01', replyDate: '', handlingOrg: '组织部', status: '待处理' },
]

const auditData = [
  { name: '张建国', dept: '机械工程学院', position: '院长', type: '离任审计', auditOrg: '审计处', startDate: '2026-06-01', endDate: '2026-06-30', result: '合格' },
  { name: '李秀英', dept: '电子信息学院', position: '党委书记', type: '任中审计', auditOrg: '省审计厅委托', startDate: '2026-03-15', endDate: '2026-04-28', result: '合格' },
  { name: '刘德明', dept: '经济管理学院', position: '院长', type: '离任审计', auditOrg: '审计处', startDate: '2026-01-10', endDate: '2026-02-20', result: '基本合格' },
  { name: '王志强', dept: '人事处（教师工作部）', position: '处长', type: '专项审计', auditOrg: '审计处', startDate: '2025-11-01', endDate: '2025-12-15', result: '合格' },
  { name: '陈丽华', dept: '财务处', position: '处长', type: '任中审计', auditOrg: '省审计厅', startDate: '2025-09-01', endDate: '2025-10-20', result: '存在违规' },
]

function handleAddAdmonish() { ElMessage.info('新增提醒函询诫勉') }
function handleAdmonishView(row) { ElMessage.info(`查看提醒函询诫勉详情：${row.name}`) }
function handleAdmonishEdit(row) { ElMessage.info(`编辑提醒函询诫勉：${row.name}`) }
function handleAdmonishDelete(row) { ElMessage.info(`删除提醒函询诫勉：${row.name}`) }
function exportAdmonish() {
  showExportDialog(admonishData, [
    { prop: 'name', label: '被提醒人' }, { prop: 'type', label: '类型' }, { prop: 'reason', label: '事由摘要' },
    { prop: 'date', label: '发起日期' }, { prop: 'replyDate', label: '回复日期' }, { prop: 'handlingOrg', label: '承办单位' }, { prop: 'status', label: '状态' }
  ], '提醒函询诫勉')
}

function handleAddAudit() { ElMessage.info('新增经济责任审计项目') }
function handleAuditView(row) { ElMessage.info(`查看审计详情：${row.name}`) }
function handleAuditEdit(row) { ElMessage.info(`编辑审计项目：${row.name}`) }
function handleAuditDelete(row) { ElMessage.info(`删除审计项目：${row.name}`) }
function exportAudit() {
  showExportDialog(auditData, [
    { prop: 'name', label: '被审计人' }, { prop: 'dept', label: '所在部门' }, { prop: 'position', label: '时任职务' },
    { prop: 'type', label: '审计类型' }, { prop: 'auditOrg', label: '审计单位' }, { prop: 'startDate', label: '审计开始' },
    { prop: 'endDate', label: '审计结束' }, { prop: 'result', label: '审计结果' }
  ], '经济责任审计')
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
.alert-config-bar {
  background: #f8f9fa;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 10px 14px;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
}
</style>
