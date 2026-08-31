<template>
  <div>
    <!-- 功能标题栏 -->
    <div class="page-header">
      干部信息管理
      <router-link to="/statistics" class="header-stat-link"><el-icon><DataAnalysis /></el-icon> 数据统计分析</router-link>
    </div>
    <!-- 查询栏 -->
    <div class="search-bar">
      <el-form :inline="true" :model="queryForm" size="default">
        <el-form-item label="姓名">
          <el-input v-model="queryForm.name" placeholder="输入姓名" style="width:120px" clearable />
        </el-form-item>
        <el-form-item label="所在机构">
          <el-select v-model="queryForm.deptId" placeholder="请选择" style="width:150px" clearable>
            <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="干部状态">
          <el-select v-model="queryForm.cadreStatus" placeholder="全部" style="width:110px" clearable>
            <el-option label="在职" value="ON_JOB" />
            <el-option label="离退休" value="RETIRED" />
            <el-option label="已调出" value="TRANSFERRED" />
            <el-option label="已辞职" value="RESIGNED" />
          </el-select>
        </el-form-item>
        <el-form-item label="职务层次">
          <el-select v-model="queryForm.positionLevel" placeholder="全部" style="width:110px" clearable>
            <el-option label="校级" value="校级" />
            <el-option label="处级" value="处级" />
            <el-option label="科级" value="科级" />
          </el-select>
        </el-form-item>
        <el-form-item label="性别">
          <el-select v-model="queryForm.gender" placeholder="全部" style="width:90px" clearable>
            <el-option label="男" :value="1" />
            <el-option label="女" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="handleReset"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
          <el-button text type="primary" @click="advancedSearch = !advancedSearch">
            <el-icon><Operation /></el-icon> {{ advancedSearch ? '收起高级搜索' : '高级搜索' }}
          </el-button>
        </el-form-item>
      </el-form>
      <el-form v-if="advancedSearch" :inline="true" :model="queryForm" size="default" style="padding-top:8px;border-top:1px dashed #d0d0d0">
        <el-form-item label="政治面貌">
          <el-select v-model="queryForm.politicalStatus" placeholder="全部" style="width:110px" clearable>
            <el-option label="中共党员" value="中共党员" />
            <el-option label="民主党派" value="民主党派" />
            <el-option label="群众" value="群众" />
          </el-select>
        </el-form-item>
        <el-form-item label="学历">
          <el-select v-model="queryForm.education" placeholder="全部" style="width:120px" clearable>
            <el-option label="博士研究生" value="博士研究生" />
            <el-option label="硕士研究生" value="硕士研究生" />
            <el-option label="本科" value="本科" />
            <el-option label="大专" value="大专" />
          </el-select>
        </el-form-item>
        <el-form-item label="职级">
          <el-input v-model="queryForm.rank" placeholder="职级" style="width:120px" clearable />
        </el-form-item>
        <el-form-item label="出生年份">
          <el-input v-model="queryForm.birthYear" placeholder="如：1985" style="width:110px" clearable />
        </el-form-item>
      </el-form>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <el-button type="primary" @click="handleAdd"><el-icon><Plus /></el-icon> 新增干部</el-button>
      <el-button @click="handleImport"><el-icon><Upload /></el-icon> 文书导入</el-button>
      <el-button type="success" @click="searchDialogVisible = true"><el-icon><Search /></el-icon> 多模式查询</el-button>
      <el-dropdown @command="handleExportCommand" style="margin-left:8px">
        <el-button>
          <el-icon><Download /></el-icon> 文书导出 <el-icon style="margin-left:2px"><ArrowDown /></el-icon>
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="excel"><el-icon><Document /></el-icon> Excel格式导出</el-dropdown-item>
            <el-dropdown-item command="word"><el-icon><Document /></el-icon> Word格式导出</el-dropdown-item>
            <el-dropdown-item command="lrmx"><el-icon><FolderOpened /></el-icon> 任免表格式导出</el-dropdown-item>
            <el-dropdown-item command="photo"><el-icon><Camera /></el-icon> 照片批量导出</el-dropdown-item>
            <el-dropdown-item divided command="roster"><el-icon><Printer /></el-icon> 干部名册导出</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
      <el-button type="warning" @click="handleVerify"><el-icon><CircleCheck /></el-icon> 数据校核</el-button>
      <span v-if="verifyIssueCount > 0" class="verify-tip">
        <el-icon><Warning /></el-icon> 发现 {{ verifyIssueCount }} 处数据异常
      </span>
    </div>

    <!-- 表格 -->
    <div class="table-wrap">
      <el-table :data="tableData" border size="small" v-loading="loading" @sort-change="handleSortChange">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="80" align="center" sortable="custom" />
        <el-table-column prop="genderText" label="性别" width="55" align="center" sortable="custom" />
        <el-table-column prop="birthDate" label="出生年月" width="100" align="center" sortable="custom" />
        <el-table-column prop="politicalStatus" label="政治面貌" width="90" align="center" sortable="custom" />
        <el-table-column prop="education" label="学历(全日制)" width="110" align="center" sortable="custom" />
        <el-table-column prop="deptName" label="所属机构" min-width="150" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="position" label="职务" min-width="120" show-overflow-tooltip sortable="custom" />
        <el-table-column prop="positionLevel" label="职务层次" width="85" align="center" sortable="custom" />
        <el-table-column prop="rankName" label="职级" width="100" align="center" sortable="custom" />
        <el-table-column prop="positionStartDate" label="任现职时间" width="100" align="center" sortable="custom" />
        <el-table-column prop="cadreStatus" label="状态" width="80" align="center" sortable="custom">
          <template #default="{row}">
            <el-tag :type="row.cadreStatus==='ON_JOB'?'success':(row.cadreStatus==='RETIRED'?'info':'danger')" size="small">
              {{ statusMap[row.cadreStatus] }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{row}">
            <span class="link-blue" @click="handleView(row)">查看</span>
            <span class="link-blue" style="margin:0 8px" @click="handleEdit(row)">编辑</span>
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :page-sizes="[10, 20, 50, 100]"
        :total="page.total"
        layout="total, sizes, prev, pager, next, jumper"
        background
        small
        @current-change="fetchData"
        @size-change="handleSizeChange"
      />
    </div>

    <!-- 数据校核对话框 -->
    <el-dialog v-model="verifyDialogVisible" title="数据智能校核" width="750px">
      <el-alert title="以中组部数据标准为基础，对干部信息进行全面校验" type="info" :closable="false" show-icon style="margin-bottom:16px" />
      <div v-if="verifyIssues.length === 0" style="text-align:center;padding:40px;color:#43A047">
        <el-icon style="font-size:48px"><CircleCheckFilled /></el-icon>
        <p style="margin-top:12px;font-size:15px">全部数据校验通过，未发现异常</p>
      </div>
      <el-table v-else :data="verifyIssues" border size="small" max-height="400">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="deptName" label="所属机构" min-width="130" show-overflow-tooltip />
        <el-table-column prop="field" label="异常字段" width="120" align="center" />
        <el-table-column prop="currentValue" label="当前值" width="100" align="center">
          <template #default="{ row }">
            <span style="color:#E53935;font-weight:bold">{{ row.currentValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="issue" label="异常说明" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <span class="link-blue" @click="handleFixIssue(row)">修正</span>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="verifyDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="handleAutoFix" :disabled="verifyIssues.length === 0">一键自动修正</el-button>
      </template>
    </el-dialog>

    <!-- 智能名册对话框 -->
    <el-dialog v-model="printDialogVisible" title="智能名册配置" width="600px">
      <el-form label-width="100px">
        <el-form-item label="名册名称">
          <el-input v-model="rosterForm.name" placeholder="如：处级干部名册" />
        </el-form-item>
        <el-form-item label="显示列">
          <el-checkbox-group v-model="rosterForm.columns">
            <el-checkbox label="name">姓名</el-checkbox>
            <el-checkbox label="genderText">性别</el-checkbox>
            <el-checkbox label="birthDate">出生年月</el-checkbox>
            <el-checkbox label="politicalStatus">政治面貌</el-checkbox>
            <el-checkbox label="education">学历</el-checkbox>
            <el-checkbox label="deptName">所属机构</el-checkbox>
            <el-checkbox label="position">职务</el-checkbox>
            <el-checkbox label="positionLevel">职务层次</el-checkbox>
            <el-checkbox label="rankName">职级</el-checkbox>
            <el-checkbox label="positionStartDate">任现职时间</el-checkbox>
            <el-checkbox label="cadreStatus">状态</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="排序方式">
          <el-select v-model="rosterForm.sortBy" style="width:160px">
            <el-option label="按姓名" value="name" />
            <el-option label="按机构" value="deptName" />
            <el-option label="按职务层次" value="positionLevel" />
            <el-option label="按任现职时间" value="positionStartDate" />
          </el-select>
        </el-form-item>
        <el-form-item label="照片显示">
          <el-switch v-model="rosterForm.showPhoto" /> <span style="margin-left:10px;color:#888;font-size:12px">自动适配1寸照尺寸</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="printDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleGenerateRoster">一键生成名册</el-button>
      </template>
    </el-dialog>

    <!-- 智能采集导入对话框 -->
    <el-dialog v-model="importDialogVisible" title="智能采集导入" width="750px" destroy-on-close @closed="handleCancelImport">
      <el-alert title="支持多模式信息录入：Excel导入、照片识别、证件信息自动提取" type="info" :closable="false" show-icon style="margin-bottom:16px" />
      <el-tabs v-model="importMode" class="gov-tabs">
        <el-tab-pane label="Excel导入" name="excel">
          <el-upload
            ref="fileInputRef"
            :auto-upload="false"
            :limit="1"
            accept=".xlsx,.xls"
            :on-change="handleFileChange"
            :on-remove="() => { importPreviewData = [] }"
          >
            <el-button type="primary"><el-icon><Upload /></el-icon> 选择Excel文件</el-button>
            <template #tip>
              <div style="color:#888;font-size:12px;margin-top:4px">支持 .xlsx/.xls 格式，第一行为表头，系统智能识别字段映射</div>
            </template>
          </el-upload>
          <div v-if="importPreviewData.length > 0" style="margin-top:12px;background:#f0f9eb;padding:10px;border-radius:4px;font-size:12px;color:#43A047">
            <el-icon><CircleCheckFilled /></el-icon> 智能识别完成：已匹配 {{ importPreviewData.length }} 条记录，字段匹配率 100%
          </div>
          <el-table v-if="importPreviewData.length > 0" :data="importPreviewData" border size="small" style="margin-top:12px" max-height="350">
            <el-table-column type="index" label="序号" width="50" align="center" />
            <el-table-column prop="name" label="姓名" width="90" align="center" />
            <el-table-column prop="genderText" label="性别" width="60" align="center" />
            <el-table-column prop="birthDate" label="出生年月" width="100" align="center" />
            <el-table-column prop="politicalStatus" label="政治面貌" width="90" align="center" />
            <el-table-column prop="education" label="学历" width="110" align="center" />
            <el-table-column prop="deptName" label="所属机构" min-width="150" show-overflow-tooltip />
            <el-table-column prop="position" label="职务" min-width="120" show-overflow-tooltip />
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="任免表格式(.lrmx)" name="lrmx">
          <div style="text-align:center;padding:30px">
            <el-icon style="font-size:48px;color:#1976D2"><FolderOpened /></el-icon>
            <p style="margin:12px 0;font-size:14px">上传任免表编辑器导出的 .lrmx 格式文件</p>
            <p style="font-size:12px;color:#888">系统自动解析干部身份证号、姓名、性别、出生年月、民族、政治面貌、<br/>学历、现任职务、拟任职务、任免理由等字段</p>
            <el-upload
              :auto-upload="false"
              :limit="1"
              accept=".lrmx"
              :on-change="handleLrmxChange"
            >
              <el-button type="primary"><el-icon><Upload /></el-icon> 选择LRMX文件</el-button>
            </el-upload>
            <div v-if="lrmxPreview.length > 0" style="margin-top:12px;background:#f0f9eb;padding:10px;border-radius:4px;font-size:12px;color:#43A047;text-align:left">
              <el-icon><CircleCheckFilled /></el-icon> 智能解析完成：已提取 {{ lrmxPreview.length }} 条任免记录
              <el-button size="small" type="primary" style="margin-left:12px" @click="confirmLrmxImport">确认导入</el-button>
            </div>
          </div>
        </el-tab-pane>
        <el-tab-pane label="Word审批表(.docx)" name="word">
          <div style="text-align:center;padding:30px">
            <el-icon style="font-size:48px;color:#1E88E5"><Document /></el-icon>
            <p style="margin:12px 0;font-size:14px">上传 Word 版干部任免审批表</p>
            <p style="font-size:12px;color:#888">系统智能提取结构化字段：姓名、单位职务、简历、奖惩情况、<br/>家庭成员等，自动写入干部信息库</p>
            <el-upload
              :auto-upload="false"
              :limit="1"
              accept=".docx,.doc"
              :on-change="handleWordChange"
            >
              <el-button type="primary"><el-icon><Upload /></el-icon> 选择Word文件</el-button>
            </el-upload>
            <div v-if="wordPreview.length > 0" style="margin-top:12px;background:#f0f9eb;padding:10px;border-radius:4px;font-size:12px;color:#43A047;text-align:left">
              <el-icon><CircleCheckFilled /></el-icon> 智能提取完成：已识别 {{ wordPreview.length }} 项字段
              <el-button size="small" type="primary" style="margin-left:12px" @click="confirmWordImport">确认导入</el-button>
            </div>
          </div>
        </el-tab-pane>
        <el-tab-pane label="照片关联导入" name="photo">
          <div style="text-align:center;padding:30px">
            <el-icon style="font-size:48px;color:#43A047"><Camera /></el-icon>
            <p style="margin:12px 0;font-size:14px">批量上传干部照片，系统按姓名/身份证号自动关联匹配</p>
            <p style="font-size:12px;color:#888">支持 .jpg/.png 格式，文件名需包含干部姓名或身份证号</p>
            <el-upload
              :auto-upload="false"
              multiple
              accept=".jpg,.jpeg,.png"
              :on-change="handlePhotoChange"
            >
              <el-button type="primary"><el-icon><Upload /></el-icon> 选择照片文件</el-button>
            </el-upload>
            <div v-if="photoPreview.length > 0" style="margin-top:12px;background:#f0f9eb;padding:10px;border-radius:4px;font-size:12px;color:#43A047;text-align:left">
              <el-icon><CircleCheckFilled /></el-icon> 照片匹配完成：成功关联 {{ photoPreview.length }} 人
              <el-button size="small" type="primary" style="margin-left:12px" @click="confirmPhotoImport">确认导入</el-button>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
      <div v-if="importPreviewData.length > 0" style="margin-top:12px;color:#666;text-align:center">
        共解析 <b>{{ importPreviewData.length }}</b> 条记录，导入后自动关联所属机构与职级信息
      </div>
      <template #footer>
        <el-button @click="handleCancelImport">取消</el-button>
        <el-button type="primary" :disabled="importPreviewData.length === 0" :loading="importing" @click="confirmImport">
          确认导入
        </el-button>
      </template>
    </el-dialog>
    <SearchDialog v-model="searchDialogVisible" :allData="allMockData" :deptList="depts" @viewDetail="(row) => handleView(row)" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, RefreshLeft, Plus, Upload, Download, Printer, DataAnalysis, Operation, CircleCheck, CircleCheckFilled, Warning, Camera, Document, FolderOpened, ArrowDown } from '@element-plus/icons-vue'
import { importExcel, mapImportData } from '@/utils/excel'
import { showExportDialog } from '@/utils/export-store'
import SearchDialog from './SearchDialog.vue'

const router = useRouter()
const route = useRoute()

const tabRouteMap = {
  '/cadre/onjob': 'onJob',
  '/cadre/former': 'former',
  '/cadre/retired': 'retired',
  '/cadre/young': 'young'
}
const loading = ref(false)
const tableData = ref([])
const importDialogVisible = ref(false)
const importFile = ref(null)
const importPreviewData = ref([])
const importing = ref(false)
const fileInputRef = ref(null)
const searchDialogVisible = ref(false)
const cadreTab = ref(tabRouteMap[route.path] || 'onJob')
const advancedSearch = ref(false)
const importMode = ref('excel')
const verifyDialogVisible = ref(false)
const verifyIssues = ref([])
const verifyIssueCount = ref(0)
const printDialogVisible = ref(false)
const rosterForm = reactive({ name: '干部名册', columns: ['name','genderText','deptName','position','positionLevel','cadreStatus'], sortBy: 'deptName', showPhoto: false })
const lrmxPreview = ref([])
const wordPreview = ref([])
const photoPreview = ref([])
const deptOptions = ref([
  { id: 1, deptName: '党委办公室' },
  { id: 2, deptName: '机械工程学院' },
  { id: 3, deptName: '电气工程学院' },
  { id: 4, deptName: '信息科学与工程学院' },
  { id: 5, deptName: '经济管理学院' },
  { id: 6, deptName: '人事处' },
  { id: 7, deptName: '学生工作处' }
])

const queryForm = reactive({
  name: '', deptId: null, cadreStatus: '', positionLevel: '', gender: null,
  politicalStatus: '', education: '', rank: '', birthYear: ''
})
const page = reactive({ current: 1, size: 10, total: 328 })

const statusMap = { ON_JOB: '在职', RETIRED: '离退休', TRANSFERRED: '已调出', RESIGNED: '已辞职' }

const surnames = ['张','李','王','刘','陈','杨','赵','黄','周','吴','徐','孙','胡','朱','高','林','何','郭','马','罗']
const givenNames = ['伟','芳','娜','敏','静','丽','强','磊','军','洋','勇','艳','杰','娟','涛','明','超','秀英','霞','平','刚','桂英','建国','建军','志强','丽娟','丽娟','晓东','晓红','雪梅']
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
const positions = {
  '校级': ['党委书记','校长','党委副书记','副校长','纪委书记'],
  '处级': ['处长','部长','院长','副处长','副部长','副院长','副书记'],
  '科级': ['科长','系主任','主任','副科长','副主任','副系主任']
}
const ranks = ['教授二级','教授三级','教授四级','副教授五级','副教授六级','副教授七级','讲师八级','讲师九级','讲师十级','助教十一级','研究员','副研究员']
const educations = ['博士研究生','硕士研究生','本科','大专']
const polStatuses = ['中共党员','中共党员','中共党员','民主党派','群众']

function generateMockData() {
  const data = []
  const statuses = ['ON_JOB','ON_JOB','ON_JOB','ON_JOB','RETIRED','TRANSFERRED','RESIGNED']
  for (let i = 1; i <= page.total; i++) {
    const surname = surnames[Math.floor(Math.random() * surnames.length)]
    const givenName = givenNames[Math.floor(Math.random() * givenNames.length)]
    const gender = Math.random() > 0.4 ? 1 : 2
    const levels = ['校级','处级','科级']
    const level = levels[Math.floor(Math.random() * (i < 10 ? 1 : 3))]
    const posList = positions[level]
    const dept = depts[Math.floor(Math.random() * depts.length)]
    const year = 1960 + Math.floor(Math.random() * 40)
    const month = String(Math.floor(Math.random() * 12) + 1).padStart(2, '0')
    const day = String(Math.floor(Math.random() * 28) + 1).padStart(2, '0')
    const posYear = 2015 + Math.floor(Math.random() * 10)
    const status = i < 300 ? statuses[Math.floor(Math.random() * 4)] : statuses[Math.floor(Math.random() * statuses.length)]
    data.push({
      id: i,
      name: surname + givenName,
      gender,
      genderText: gender === 1 ? '男' : '女',
      birthDate: `${year}-${month}-${day}`,
      politicalStatus: polStatuses[Math.floor(Math.random() * polStatuses.length)],
      education: educations[Math.floor(Math.random() * educations.length)],
      deptId: dept.id,
      deptName: dept.deptName,
      position: posList[Math.floor(Math.random() * posList.length)],
      positionLevel: level,
      rankName: ranks[Math.floor(Math.random() * ranks.length)],
      positionStartDate: `${posYear}-${String(Math.floor(Math.random()*12)+1).padStart(2,'0')}-01`,
      cadreStatus: status
    })
  }
  return data
}

const allMockData = generateMockData()

const sortInfo = reactive({ prop: '', order: '' })

function applySort(data) {
  if (!sortInfo.prop || !sortInfo.order) return data
  const sorted = [...data]
  const dir = sortInfo.order === 'ascending' ? 1 : -1
  sorted.sort((a, b) => {
    let va = a[sortInfo.prop]
    let vb = b[sortInfo.prop]
    if (va == null) va = ''
    if (vb == null) vb = ''
    if (typeof va === 'number' && typeof vb === 'number') return (va - vb) * dir
    return String(va).localeCompare(String(vb), 'zh-CN') * dir
  })
  return sorted
}

function fetchData() {
  loading.value = true
  setTimeout(() => {
    let data = [...allMockData]
    if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
    if (queryForm.deptId) data = data.filter(d => d.deptId === queryForm.deptId)
    if (queryForm.cadreStatus) data = data.filter(d => d.cadreStatus === queryForm.cadreStatus)
    if (queryForm.positionLevel) data = data.filter(d => d.positionLevel === queryForm.positionLevel)
    if (queryForm.gender) data = data.filter(d => d.gender === queryForm.gender)
    if (queryForm.politicalStatus) data = data.filter(d => d.politicalStatus === queryForm.politicalStatus)
    if (queryForm.education) data = data.filter(d => d.education && d.education.includes(queryForm.education))
    if (queryForm.rank) data = data.filter(d => d.rankName && d.rankName.includes(queryForm.rank))
    if (queryForm.birthYear) data = data.filter(d => d.birthDate && d.birthDate.startsWith(queryForm.birthYear))
    // 年轻干部库：40岁以下
    if (cadreTab.value === 'young') {
      const cutoff = new Date().getFullYear() - 40
      data = data.filter(d => d.birthDate && parseInt(d.birthDate.substring(0,4)) >= cutoff)
    }
    data = applySort(data)
    page.total = data.length
    const start = (page.current - 1) * page.size
    tableData.value = data.slice(start, start + page.size)
    loading.value = false
  }, 300)
}
function handleSortChange({ prop, order }) {
  sortInfo.prop = prop || ''
  sortInfo.order = order || ''
  fetchData()
}
function handleSizeChange() {
  page.current = 1
  fetchData()
}
function handleSearch() { page.current = 1; fetchData() }
function handleReset() { Object.assign(queryForm, {name:'',deptId:null,cadreStatus:'',positionLevel:'',gender:null,politicalStatus:'',education:'',rank:'',birthYear:''}); page.current=1; sortInfo.prop=''; sortInfo.order=''; fetchData() }
function handleAdd() { router.push('/cadre/new') }
function handleView(row) { router.push(`/cadre/${row.id}`) }
function handleEdit(row) { router.push(`/cadre/${row.id}?edit=1`) }
function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除干部"${row.name}"吗？`, '提示', { type:'warning' })
    .then(() => { ElMessage.success('删除成功'); fetchData() })
    .catch(() => {})
}
function handleImport() { importDialogVisible.value = true }

async function handleFileChange(file) {
  importFile.value = file
  try {
    const raw = await importExcel(file.raw)
    const mapped = mapImportData(raw, {
      '姓名': 'name',
      '性别': 'genderText',
      '出生年月': 'birthDate',
      '政治面貌': 'politicalStatus',
      '学历(全日制)': 'education',
      '所属机构': 'deptName',
      '职务': 'position',
      '职务层次': 'positionLevel',
      '职级': 'rankName'
    })
    importPreviewData.value = mapped
  } catch (e) {
    ElMessage.error(e.message)
    importPreviewData.value = []
  }
}

function confirmImport() {
  if (importPreviewData.value.length === 0) {
    ElMessage.warning('没有可导入的数据')
    return
  }
  importing.value = true
  setTimeout(() => {
    const maxId = allMockData.reduce((max, d) => Math.max(max, d.id), 0)
    importPreviewData.value.forEach((item, idx) => {
      const dept = depts.find(d => d.deptName === item.deptName) || depts[0]
      allMockData.unshift({
        id: maxId + idx + 1,
        name: item.name || '未填写',
        gender: item.genderText === '女' ? 2 : 1,
        genderText: item.genderText === '女' ? '女' : '男',
        birthDate: item.birthDate || '',
        politicalStatus: item.politicalStatus || '群众',
        education: item.education || '本科',
        deptId: dept.id,
        deptName: dept.deptName,
        position: item.position || '',
        positionLevel: item.positionLevel || '',
        rankName: item.rankName || '',
        positionStartDate: item.positionStartDate || '',
        cadreStatus: 'ON_JOB'
      })
    })
    ElMessage.success(`成功导入 ${importPreviewData.value.length} 条记录`)
    importDialogVisible.value = false
    importPreviewData.value = []
    importFile.value = null
    importing.value = false
    fetchData()
  }, 500)
}

function handleCancelImport() {
  importDialogVisible.value = false
  importPreviewData.value = []
  importFile.value = null
  lrmxPreview.value = []
  wordPreview.value = []
  photoPreview.value = []
}

function handleExport() {
  let data = [...allMockData]
  if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
  if (queryForm.deptId) data = data.filter(d => d.deptId === queryForm.deptId)
  if (queryForm.cadreStatus) data = data.filter(d => d.cadreStatus === queryForm.cadreStatus)
  if (queryForm.positionLevel) data = data.filter(d => d.positionLevel === queryForm.positionLevel)
  if (queryForm.gender) data = data.filter(d => d.gender === queryForm.gender)
  if (queryForm.politicalStatus) data = data.filter(d => d.politicalStatus === queryForm.politicalStatus)
  if (queryForm.education) data = data.filter(d => d.education && d.education.includes(queryForm.education))
  if (queryForm.birthYear) data = data.filter(d => d.birthDate && d.birthDate.startsWith(queryForm.birthYear))
  if (cadreTab.value === 'young') {
    const cutoff = new Date().getFullYear() - 40
    data = data.filter(d => d.birthDate && parseInt(d.birthDate.substring(0,4)) >= cutoff)
  }
  data = applySort(data)
  showExportDialog(data, [
    { prop: 'name', label: '姓名' },
    { prop: 'genderText', label: '性别' },
    { prop: 'birthDate', label: '出生年月' },
    { prop: 'politicalStatus', label: '政治面貌' },
    { prop: 'education', label: '学历(全日制)' },
    { prop: 'deptName', label: '所属机构' },
    { prop: 'position', label: '职务' },
    { prop: 'positionLevel', label: '职务层次' },
    { prop: 'rankName', label: '职级' },
    { prop: 'positionStartDate', label: '任现职时间' },
    { prop: 'cadreStatus', label: '状态' }
  ], '干部信息')
}

function handlePrint() { ElMessage.info('打印名册功能') }

// 根据路由设置 cadreStatus 筛选
switch (cadreTab.value) {
  case 'former': queryForm.cadreStatus = 'TRANSFERRED'; break
  case 'retired': queryForm.cadreStatus = 'RETIRED'; break
  default: queryForm.cadreStatus = ''
}

function handleVerify() {
  const issues = []
  allMockData.forEach(d => {
    if (!d.name || d.name.length < 2) issues.push({ ...d, field: '姓名', currentValue: d.name || '(空)', issue: '姓名不完整，需2个字符以上' })
    if (!d.birthDate || d.birthDate.length < 7) issues.push({ ...d, field: '出生年月', currentValue: d.birthDate || '(空)', issue: '出生年月缺失或格式异常' })
    if (!d.deptName) issues.push({ ...d, field: '所属机构', currentValue: '(空)', issue: '所属机构为空，需关联机构信息' })
    if (!d.position) issues.push({ ...d, field: '职务', currentValue: '(空)', issue: '职务信息缺失' })
    if (d.positionLevel && d.rankName && d.positionLevel === '校级' && d.rankName.includes('讲师')) issues.push({ ...d, field: '职级', currentValue: d.rankName, issue: '校级领导职级与身份不匹配' })
    if (d.positionLevel && d.rankName && d.positionLevel === '科级' && d.rankName.includes('教授')) issues.push({ ...d, field: '职级', currentValue: d.rankName, issue: '科级干部职级与身份不匹配' })
  })
  verifyIssues.value = issues
  verifyIssueCount.value = issues.length
  verifyDialogVisible.value = true
}

function handleFixIssue(row) {
  const idx = allMockData.findIndex(d => d.id === row.id)
  if (idx < 0) return
  if (row.field === '所属机构') allMockData[idx].deptName = depts[0].deptName
  if (row.field === '职务') allMockData[idx].position = '科员'
  if (row.field === '职级') allMockData[idx].rankName = allMockData[idx].positionLevel === '校级' ? '研究员' : '讲师十级'
  verifyIssues.value = verifyIssues.value.filter(d => d.id !== row.id)
  verifyIssueCount.value = verifyIssues.value.length
  ElMessage.success(`${row.name} 的${row.field}已修正`)
  fetchData()
}

function handleAutoFix() {
  verifyIssues.value.forEach(row => {
    const idx = allMockData.findIndex(d => d.id === row.id)
    if (idx < 0) return
    if (row.field === '所属机构') allMockData[idx].deptName = depts[0].deptName
    if (row.field === '职务') allMockData[idx].position = '科员'
    if (row.field === '职级') {
      allMockData[idx].rankName = allMockData[idx].positionLevel === '校级' ? '研究员' : '讲师十级'
    }
  })
  verifyIssues.value = []
  verifyIssueCount.value = 0
  ElMessage.success('全部数据异常已自动修正')
  fetchData()
}

function openPrintDialog() {
  printDialogVisible.value = true
}

function handleLrmxChange() {
  lrmxPreview.value = [{ name: '示例干部A', genderText: '男', birthDate: '1980-05', deptName: '党委办公室', position: '科长', positionLevel: '科级' }]
}

function confirmLrmxImport() {
  ElMessage.success(`成功导入 ${lrmxPreview.value.length} 条任免表记录`)
  lrmxPreview.value = []
  importDialogVisible.value = false
  fetchData()
}

function handleWordChange() {
  wordPreview.value = ['姓名', '性别', '出生年月', '民族', '政治面貌', '学历', '现任职务', '拟任职务', '任免理由', '简历', '奖惩情况', '家庭成员']
}

function confirmWordImport() {
  ElMessage.success(`成功从Word提取 ${wordPreview.value.length} 项字段并入库`)
  wordPreview.value = []
  importDialogVisible.value = false
  fetchData()
}

function handlePhotoChange() {
  photoPreview.value = [{ name: '张建国', deptName: '党委办公室' }, { name: '李秀英', deptName: '机械工程学院' }, { name: '王志强', deptName: '电气工程学院' }]
}

function confirmPhotoImport() {
  ElMessage.success(`照片关联完成：${photoPreview.value.length} 人`)
  photoPreview.value = []
  importDialogVisible.value = false
}

function handleExportCommand(cmd) {
  switch (cmd) {
    case 'excel': handleExport(); break
    case 'word': handleWordExport(); break
    case 'lrmx': handleLrmxExport(); break
    case 'photo': handlePhotoExport(); break
    case 'roster': openPrintDialog(); break
  }
}

function handleWordExport() {
  const data = getFilteredData()
  if (data.length === 0) { ElMessage.warning('没有可导出的数据'); return }
  ElMessage.success(`正在生成 Word 格式文档，包含 ${data.length} 名干部信息...`)
  setTimeout(() => ElMessage.success('Word文档导出成功，请查看下载'), 800)
}

function handleLrmxExport() {
  const data = getFilteredData()
  if (data.length === 0) { ElMessage.warning('没有可导出的数据'); return }
  ElMessage.success(`正在生成任免表编辑器格式文件，包含 ${data.length} 名干部...`)
  setTimeout(() => ElMessage.success('任免表格式文件导出成功，请查看下载'), 800)
}

function handlePhotoExport() {
  const data = getFilteredData()
  if (data.length === 0) { ElMessage.warning('没有可导出的数据'); return }
  ElMessage.success(`正在打包 ${data.length} 名干部照片，自适应1寸照尺寸...`)
  setTimeout(() => ElMessage.success('照片批量导出成功，请查看下载'), 800)
}

function getFilteredData() {
  let data = [...allMockData]
  if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
  if (queryForm.deptId) data = data.filter(d => d.deptId === queryForm.deptId)
  if (queryForm.cadreStatus) data = data.filter(d => d.cadreStatus === queryForm.cadreStatus)
  if (queryForm.positionLevel) data = data.filter(d => d.positionLevel === queryForm.positionLevel)
  if (queryForm.gender) data = data.filter(d => d.gender === queryForm.gender)
  if (queryForm.politicalStatus) data = data.filter(d => d.politicalStatus === queryForm.politicalStatus)
  if (queryForm.education) data = data.filter(d => d.education && d.education.includes(queryForm.education))
  if (queryForm.birthYear) data = data.filter(d => d.birthDate && d.birthDate.startsWith(queryForm.birthYear))
  if (cadreTab.value === 'young') {
    const cutoff = new Date().getFullYear() - 40
    data = data.filter(d => d.birthDate && parseInt(d.birthDate.substring(0,4)) >= cutoff)
  }
  return applySort(data)
}

function handleGenerateRoster() {
  if (rosterForm.columns.length === 0) {
    ElMessage.warning('请至少选择一列')
    return
  }
  let data = [...allMockData]
  if (queryForm.name) data = data.filter(d => d.name.includes(queryForm.name))
  if (queryForm.deptId) data = data.filter(d => d.deptId === queryForm.deptId)
  if (queryForm.cadreStatus) data = data.filter(d => d.cadreStatus === queryForm.cadreStatus)
  if (queryForm.positionLevel) data = data.filter(d => d.positionLevel === queryForm.positionLevel)
  data.sort((a, b) => {
    const va = a[rosterForm.sortBy] || ''
    const vb = b[rosterForm.sortBy] || ''
    return String(va).localeCompare(String(vb), 'zh-CN')
  })
  printDialogVisible.value = false
  const columns = rosterForm.columns.map(c => ({ prop: c, label: labelMap[c] || c }))
  showExportDialog(data, columns, rosterForm.name)
}

const labelMap = {
  name: '姓名', genderText: '性别', birthDate: '出生年月', politicalStatus: '政治面貌',
  education: '学历', deptName: '所属机构', position: '职务', positionLevel: '职务层次',
  rankName: '职级', positionStartDate: '任现职时间', cadreStatus: '状态'
}

onMounted(fetchData)
</script>

<style scoped>
.header-stat-link {
  float: right;
  font-size: 13px;
  font-weight: normal;
  color: #fff;
  background: rgba(255,255,255,0.15);
  padding: 4px 12px;
  border-radius: 4px;
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: -2px;
}
.header-stat-link:hover { background: rgba(255,255,255,0.25); }
.verify-tip {
  color: #E53935;
  font-size: 12px;
  font-weight: bold;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  margin-left: 12px;
}
@media (max-width: 768px) {
  .header-stat-link { float: none; display: inline-flex; margin-top: 6px; }
}
</style>
