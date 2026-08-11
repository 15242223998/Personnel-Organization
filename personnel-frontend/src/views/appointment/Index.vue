<template>
  <div>
    <div class="page-header">干部任免管理</div>

    <div class="search-bar">
      <el-form :inline="true" :model="searchForm" size="default">
        <el-form-item label="职位信息">
          <el-input v-model="searchForm.positionInfo" placeholder="输入职位关键词" style="width:180px" clearable />
        </el-form-item>
        <el-form-item label="当前环节">
          <el-select v-model="searchForm.currentStep" placeholder="全部" style="width:120px" clearable>
            <el-option label="动议" value="动议" />
            <el-option label="民主推荐" value="民主推荐" />
            <el-option label="考察" value="考察" />
            <el-option label="讨论决定" value="讨论决定" />
            <el-option label="公示" value="公示" />
            <el-option label="任职" value="任职" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部" style="width:100px" clearable>
            <el-option label="进行中" value="进行中" />
            <el-option label="已完成" value="已完成" />
            <el-option label="已终止" value="已终止" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetSearch"><el-icon><RefreshLeft /></el-icon> 重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openStartDialog"><el-icon><Plus /></el-icon> 启动任免流程</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="positionInfo" label="选拔职位信息" min-width="220" show-overflow-tooltip sortable />
        <el-table-column prop="currentStep" label="当前环节" width="120" align="center" sortable>
          <template #default="{row}">
            <el-tag :type="getStepTagType(row.currentStep)" size="small">{{ row.currentStep }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="candidate" label="确定人选" min-width="100" show-overflow-tooltip sortable />
        <el-table-column prop="startTime" label="启动时间" width="110" align="center" sortable />
        <el-table-column prop="status" label="状态" width="90" align="center" sortable>
          <template #default="{row}">
            <el-tag :type="row.status==='进行中'?'warning':(row.status==='已完成'?'success':'info')" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" align="center" fixed="right">
          <template #default="{row}">
            <span class="link-blue" @click="handleDetail(row)">详情</span>
            <span v-if="row.status==='进行中'" class="link-blue" style="margin:0 8px;color:#E53935" @click="handleTerminate(row)">终止</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 启动任免流程对话框 -->
    <el-dialog v-model="startDialogVisible" title="启动任免流程" width="560px" destroy-on-close>
      <el-form :model="startForm" label-width="90px" size="default" :rules="startRules" ref="startFormRef">
        <el-form-item label="职位信息" prop="positionInfo">
          <el-input v-model="startForm.positionInfo" placeholder="如：机械工程学院院长（正处级）" />
        </el-form-item>
        <el-form-item label="任职条件" prop="conditions">
          <el-input v-model="startForm.conditions" type="textarea" :rows="5" placeholder="请输入选拔任用条件，包括：&#10;1. 政治面貌要求&#10;2. 学历学位要求&#10;3. 任职年限要求&#10;4. 专业背景要求&#10;5. 其他条件" />
        </el-form-item>
        <el-form-item label="选拔范围">
          <el-radio-group v-model="startForm.scope">
            <el-radio label="校内选拔">校内选拔</el-radio>
            <el-radio label="校内外公开选拔">校内外公开选拔</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="startDialogVisible=false">取消</el-button>
        <el-button type="primary" @click="handleStart">启动流程</el-button>
      </template>
    </el-dialog>

    <!-- 流程详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="任免流程详情" width="820px" destroy-on-close top="5vh">
      <div v-if="currentProcess" class="process-detail">
        <div class="process-header">
          <el-descriptions :column="3" border size="small">
            <el-descriptions-item label="选拔职位">{{ currentProcess.positionInfo }}</el-descriptions-item>
            <el-descriptions-item label="启动时间">{{ currentProcess.startTime }}</el-descriptions-item>
            <el-descriptions-item label="当前状态">
              <el-tag :type="currentProcess.status==='进行中'?'warning':'success'" size="small">{{ currentProcess.status }}</el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <el-steps :active="activeStep" finish-status="success" align-center style="margin:20px 0">
          <el-step title="动议" />
          <el-step title="民主推荐" />
          <el-step title="考察" />
          <el-step title="讨论决定" />
          <el-step title="公示" />
          <el-step title="任职" />
        </el-steps>

        <div class="step-content">
          <!-- 步骤1：动议 -->
          <div v-show="activeStep===0" class="step-panel">
            <div class="step-title">一、动议</div>
            <el-descriptions :column="2" border size="small" style="margin-bottom:12px">
              <el-descriptions-item label="动议时间">2024-06-10</el-descriptions-item>
              <el-descriptions-item label="动议人">党委组织部</el-descriptions-item>
              <el-descriptions-item label="动议原因" :span="2">根据工作需要和领导班子建设实际，提出启动干部选拔任用工作意见</el-descriptions-item>
              <el-descriptions-item label="职位空缺情况" :span="2">机械工程学院院长职位因原院长调任校领导职位空缺，需补充院长1名</el-descriptions-item>
              <el-descriptions-item label="选拔条件" :span="2">
                1. 中共党员，政治素质好；2. 具有正高级专业技术职务；3. 具有5年以上副处级岗位工作经历；4. 年龄不超过50周岁；5. 具有相关专业背景和管理经验
              </el-descriptions-item>
            </el-descriptions>
            <div class="section-title">动议审批情况</div>
            <el-table :data="motionApprovalData" border size="small">
              <el-table-column prop="role" label="审批环节" min-width="120" align="center" />
              <el-table-column prop="person" label="审批人" width="100" align="center" />
              <el-table-column prop="opinion" label="审批意见" align="center" />
              <el-table-column prop="time" label="审批时间" width="120" align="center" />
            </el-table>
          </div>

          <!-- 步骤2：民主推荐 -->
          <div v-show="activeStep===1" class="step-panel">
            <div class="step-title">二、民主推荐</div>
            <el-descriptions :column="2" border size="small" style="margin-bottom:12px">
              <el-descriptions-item label="推荐时间">2024-06-15 至 2024-06-20</el-descriptions-item>
              <el-descriptions-item label="参与范围">机械工程学院全体教职工、校领导、相关职能部门负责人</el-descriptions-item>
              <el-descriptions-item label="发放票数">156票</el-descriptions-item>
              <el-descriptions-item label="收回票数">152票，其中有效票150票</el-descriptions-item>
            </el-descriptions>
            <div class="section-title">会议推荐结果</div>
            <el-table :data="recommendData" border size="small" style="margin-bottom:12px">
              <el-table-column type="index" label="排名" width="60" align="center" />
              <el-table-column prop="name" label="姓名" width="90" align="center" />
              <el-table-column prop="dept" label="现工作单位及职务" show-overflow-tooltip />
              <el-table-column prop="votes" label="得票数" width="80" align="center" />
              <el-table-column prop="rate" label="得票率" width="90" align="center">
                <template #default="{row}">
                  <span :style="{color: row.rate.includes('80')||row.rate.includes('70')?'#1976D2':'#666'}">{{ row.rate }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="remark" label="备注" width="100" align="center">
                <template #default="{row}">
                  <el-tag v-if="row.remark==='确定为考察对象'" type="success" size="small">{{ row.remark }}</el-tag>
                </template>
              </el-table-column>
            </el-table>
            <div class="section-title">谈话调研推荐</div>
            <p style="color:#666;font-size:12px;line-height:1.8">个别谈话推荐共45人，谈话对象包括学院领导班子成员、系主任、教授代表、骨干教师代表等。谈话推荐得票集中情况与会议推荐一致。</p>
          </div>

          <!-- 步骤3：考察 -->
          <div v-show="activeStep===2" class="step-panel">
            <div class="step-title">三、考察</div>
            <el-descriptions :column="2" border size="small" style="margin-bottom:12px">
              <el-descriptions-item label="考察组组长">李芳（人事处处长）</el-descriptions-item>
              <el-descriptions-item label="考察组成员">王建国、陈丽、周志强</el-descriptions-item>
              <el-descriptions-item label="考察时间">2024-06-22 至 2024-06-28</el-descriptions-item>
              <el-descriptions-item label="考察对象">孙梅、吴涛</el-descriptions-item>
            </el-descriptions>
            <div class="section-title">"凡提四必"审核情况</div>
            <el-table :data="checklistData" border size="small" style="margin-bottom:12px">
              <el-table-column prop="item" label="审核事项" min-width="140" align="center" />
              <el-table-column prop="result" label="审核结果" width="100" align="center">
                <template #default="{row}">
                  <el-tag :type="row.result==='通过'?'success':'danger'" size="small">{{ row.result }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="detail" label="审核详情" align="center" />
            </el-table>
            <div class="section-title">考察对象基本情况</div>
            <el-table :data="inspectData" border size="small" style="margin-bottom:12px">
              <el-table-column prop="name" label="姓名" width="80" align="center" />
              <el-table-column prop="gender" label="性别" width="55" align="center" />
              <el-table-column prop="birth" label="出生年月" width="100" align="center" />
              <el-table-column prop="politics" label="政治面貌" width="90" align="center" />
              <el-table-column prop="education" label="学历" width="90" align="center" />
              <el-table-column prop="position" label="现任职务" show-overflow-tooltip />
              <el-table-column prop="conclusion" label="考察结论" width="120" align="center">
                <template #default="{row}">
                  <el-tag :type="row.conclusion==='建议使用'?'success':'warning'" size="small">{{ row.conclusion }}</el-tag>
                </template>
              </el-table-column>
            </el-table>
            <div class="section-title">廉政意见</div>
            <p style="color:#666;font-size:12px;line-height:1.8">校纪委对考察对象出具了廉政鉴定意见，均未发现影响提拔使用的问题。</p>
          </div>

          <!-- 步骤4：讨论决定 -->
          <div v-show="activeStep===3" class="step-panel">
            <div class="step-title">四、讨论决定</div>
            <el-descriptions :column="2" border size="small" style="margin-bottom:12px">
              <el-descriptions-item label="会议时间">2024-07-02 上午9:00</el-descriptions-item>
              <el-descriptions-item label="会议名称">党委常委会</el-descriptions-item>
              <el-descriptions-item label="应到常委">11人</el-descriptions-item>
              <el-descriptions-item label="实到常委">10人（1人因公请假）</el-descriptions-item>
            </el-descriptions>
            <div class="section-title">常委会投票表决情况</div>
            <el-table :data="voteData" border size="small" style="margin-bottom:12px">
              <el-table-column prop="name" label="拟任人选" width="100" align="center" />
              <el-table-column prop="position" label="拟任职务" show-overflow-tooltip />
              <el-table-column prop="agree" label="同意票" width="80" align="center">
                <template #default="{row}"><span style="color:#1976D2;font-weight:bold">{{ row.agree }}</span></template>
              </el-table-column>
              <el-table-column prop="disagree" label="不同意票" width="90" align="center" />
              <el-table-column prop="abstain" label="弃权票" width="80" align="center" />
              <el-table-column prop="result" label="表决结果" width="100" align="center">
                <template #default="{row}">
                  <el-tag type="success" size="small">{{ row.result }}</el-tag>
                </template>
              </el-table-column>
            </el-table>
            <div class="section-title">会议纪要</div>
            <p style="color:#666;font-size:12px;line-height:1.8">会议听取了党委组织部关于机械工程学院院长选拔任用工作情况的汇报，到会常委经过充分讨论，以无记名投票方式进行表决，同意孙梅同志担任机械工程学院院长。</p>
          </div>

          <!-- 步骤5：公示 -->
          <div v-show="activeStep===4" class="step-panel">
            <div class="step-title">五、任前公示</div>
            <el-descriptions :column="2" border size="small" style="margin-bottom:12px">
              <el-descriptions-item label="公示时间">2024-07-03 至 2024-07-09（5个工作日）</el-descriptions-item>
              <el-descriptions-item label="公示方式">校园网、校务公开栏、学院公告栏</el-descriptions-item>
              <el-descriptions-item label="公示对象">孙梅</el-descriptions-item>
              <el-descriptions-item label="拟任职务">机械工程学院院长（正处级）</el-descriptions-item>
              <el-descriptions-item label="受理部门">校纪委、党委组织部</el-descriptions-item>
              <el-descriptions-item label="监督电话">0XXX-XXXXXXX</el-descriptions-item>
            </el-descriptions>
            <div class="section-title">公示期间反映情况</div>
            <el-alert title="公示期间未收到任何不良反映" type="success" :closable="false" show-icon style="margin-bottom:12px" />
            <div class="section-title">公示结果</div>
            <p style="color:#666;font-size:12px;line-height:1.8">公示期满，未收到任何单位或个人对孙梅同志任职的异议。经研究，决定予以任职。</p>
          </div>

          <!-- 步骤6：任职 -->
          <div v-show="activeStep===5" class="step-panel">
            <div class="step-title">六、任职</div>
            <el-descriptions :column="2" border size="small" style="margin-bottom:12px">
              <el-descriptions-item label="任职时间">2024-07-10</el-descriptions-item>
              <el-descriptions-item label="任职文号">校党任[2024]15号</el-descriptions-item>
              <el-descriptions-item label="任职人员">孙梅</el-descriptions-item>
              <el-descriptions-item label="任职职务">机械工程学院院长（正处级）</el-descriptions-item>
              <el-descriptions-item label="试用期">一年</el-descriptions-item>
              <el-descriptions-item label="谈话时间">2024-07-10 下午3:00</el-descriptions-item>
            </el-descriptions>
            <div class="section-title">任职谈话</div>
            <p style="color:#666;font-size:12px;line-height:1.8">校党委书记王建国同志、分管副校长张伟同志与孙梅同志进行了任职谈话，提出了工作要求和期望。孙梅同志作了表态发言，表示将在新岗位上认真履职、廉洁从政、不辜负组织信任。</p>
            <div class="section-title">宣布任职</div>
            <p style="color:#666;font-size:12px;line-height:1.8">2024年7月10日下午，在机械工程学院全体教职工大会上，党委组织部部长李芳同志宣布了校党委关于孙梅同志任职的决定。</p>
          </div>
        </div>

        <div v-if="currentProcess.status==='进行中'" class="step-nav" style="margin-top:16px;text-align:center">
          <el-button @click="prevStep" :disabled="activeStep===0">上一步</el-button>
          <el-button type="primary" @click="nextStep" :disabled="activeStep>=5">下一步</el-button>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible=false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Download, Search, RefreshLeft } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'

const startDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const startFormRef = ref(null)
const currentProcess = ref(null)
const activeStep = ref(0)

const searchForm = reactive({
  positionInfo: '',
  currentStep: '',
  status: ''
})

function handleSearch() { ElMessage.success('查询条件已应用') }

function resetSearch() {
  Object.assign(searchForm, { positionInfo: '', currentStep: '', status: '' })
}

const startForm = reactive({
  positionInfo: '',
  conditions: '',
  scope: '校内选拔'
})

const startRules = {
  positionInfo: [{ required: true, message: '请输入职位信息', trigger: 'blur' }],
  conditions: [{ required: true, message: '请输入任职条件', trigger: 'blur' }]
}

const tableData = ref([
  { id: 1, positionInfo: '机械工程学院院长（正处级）', currentStep: '任职', candidate: '孙梅', startTime: '2024-06-10', status: '已完成' },
  { id: 2, positionInfo: '信息科学与工程学院副院长（副处级）', currentStep: '考察', candidate: '待确定', startTime: '2024-07-01', status: '进行中' },
  { id: 3, positionInfo: '人事处副处长（副处级）', currentStep: '民主推荐', candidate: '待确定', startTime: '2024-07-15', status: '进行中' }
])

const motionApprovalData = ref([
  { role: '组织部初审', person: '李芳', opinion: '同意启动选拔程序', time: '2024-06-10' },
  { role: '分管校领导审核', person: '张伟', opinion: '同意', time: '2024-06-11' },
  { role: '党委书记审批', person: '王建国', opinion: '同意按程序启动', time: '2024-06-12' }
])

const recommendData = ref([
  { name: '孙梅', dept: '机械工程学院 副院长、教授', votes: 128, rate: '85.3%', remark: '确定为考察对象' },
  { name: '吴涛', dept: '科研处 副处长、教授', votes: 112, rate: '74.7%', remark: '确定为考察对象' },
  { name: '郑华', dept: '研究生院 副院长、副教授', votes: 65, rate: '43.3%', remark: '' },
  { name: '黄磊', dept: '机械工程学院 系主任、教授', votes: 42, rate: '28.0%', remark: '' }
])

const checklistData = ref([
  { item: '干部档案审核', result: '通过', detail: '档案材料齐全，"三龄两历一身份"信息一致' },
  { item: '个人有关事项报告核查', result: '通过', detail: '已按规定如实报告个人有关事项，核查未发现问题' },
  { item: '纪检监察机关意见', result: '通过', detail: '校纪委出具廉政意见，未收到信访举报' },
  { item: '线索具体的信访举报核查', result: '通过', detail: '未发现线索具体、有可查性的信访举报' }
])

const inspectData = ref([
  { name: '孙梅', gender: '女', birth: '1975-12', politics: '中共党员', education: '博士研究生', position: '机械工程学院副院长、教授', conclusion: '建议使用' },
  { name: '吴涛', gender: '男', birth: '1978-05', politics: '中共党员', education: '博士研究生', position: '科研处副处长、教授', conclusion: '建议使用' }
])

const voteData = ref([
  { name: '孙梅', position: '机械工程学院院长（正处级）', agree: 10, disagree: 0, abstain: 0, result: '通过' }
])

function getStepTagType(step) {
  const stepMap = { '动议': 'info', '民主推荐': '', '考察': 'warning', '讨论决定': '', '公示': '', '任职': 'success' }
  return stepMap[step] || 'info'
}

function openStartDialog() {
  Object.assign(startForm, { positionInfo: '', conditions: '', scope: '校内选拔' })
  startDialogVisible.value = true
}

function handleStart() {
  startFormRef.value.validate((valid) => {
    if (valid) {
      tableData.value.unshift({
        id: Date.now(),
        positionInfo: startForm.positionInfo,
        currentStep: '动议',
        candidate: '待确定',
        startTime: new Date().toISOString().slice(0, 10),
        status: '进行中'
      })
      ElMessage.success('任免流程已启动')
      startDialogVisible.value = false
    }
  })
}

function handleDetail(row) {
  currentProcess.value = row
  const stepMap = { '动议': 0, '民主推荐': 1, '考察': 2, '讨论决定': 3, '公示': 4, '任职': 5 }
  activeStep.value = stepMap[row.currentStep] || 0
  if (row.id === 2) {
    activeStep.value = 2
  } else if (row.id === 3) {
    activeStep.value = 1
  }
  detailDialogVisible.value = true
}

function handleTerminate(row) {
  ElMessageBox.confirm(`确定要终止"${row.positionInfo}"的任免流程吗？终止后不可恢复。`, '终止流程', {
    type: 'warning',
    confirmButtonText: '确定终止',
    cancelButtonText: '取消'
  }).then(() => {
    row.status = '已终止'
    row.currentStep = '已终止'
    ElMessage.success('流程已终止')
  }).catch(() => {})
}

function prevStep() {
  if (activeStep.value > 0) activeStep.value--
}

function nextStep() {
  if (activeStep.value < 5) activeStep.value++
}

function handleExport() {
  showExportDialog(tableData.value, [
    { prop: 'positionInfo', label: '选拔职位信息' },
    { prop: 'currentStep', label: '当前环节' },
    { prop: 'candidate', label: '确定人选' },
    { prop: 'startTime', label: '启动时间' },
    { prop: 'status', label: '状态' }
  ], '干部选拔任用')
}
</script>

<style scoped>
.process-detail { font-size: 13px; }
.step-title { font-size: 14px; font-weight: bold; color: #1976D2; margin-bottom: 10px; padding-left: 8px; border-left: 3px solid #1976D2; }
.section-title { font-size: 13px; font-weight: bold; color: #333; margin: 12px 0 8px 0; }
.step-panel { max-height: 450px; overflow-y: auto; padding-right: 8px; }
.step-nav { padding-top: 12px; border-top: 1px solid #e8e8e8; }
</style>
