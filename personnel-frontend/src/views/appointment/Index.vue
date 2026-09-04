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
      <el-button @click="configVisible = true"><el-icon><Setting /></el-icon> 流程配置</el-button>
      <el-button @click="handleExport"><el-icon><Download /></el-icon> 导出</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="positionInfo" label="选拔职位信息" min-width="220" show-overflow-tooltip sortable />
        <el-table-column label="流程类型" width="130" align="center" sortable>
          <template #default="{row}">
            <el-tag type="primary" size="small">{{ getWorkflowName(row.workflowType) }}</el-tag>
          </template>
        </el-table-column>
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
        <el-form-item label="流程类型" prop="workflowType">
          <el-select v-model="startForm.workflowType" style="width:100%" @change="onWorkflowTypeChange">
            <el-option v-for="w in workflowPresets" :key="w.key" :label="w.name + '（' + w.steps.length + '节点）'" :value="w.key" />
          </el-select>
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
          <el-step v-for="s in currentSteps" :key="s" :title="s" />
        </el-steps>

        <div class="step-content">
          <!-- 步骤1：动议 -->
          <div v-show="currentSteps[activeStep] === '动议'" class="step-panel">
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
            <div style="margin-top:12px;display:flex;align-items:center;gap:6px">
              <span style="font-size:12px;color:#666">选任材料生成：</span>
              <el-button @click="generateMaterial('motion_plan')"><el-icon><Document /></el-icon> 工作方案记录表</el-button>
              <el-button @click="generateMaterial('motion_competition')"><el-icon><Document /></el-icon> 公开竞聘方案</el-button>
              <el-button @click="generateMaterial('motion_discipline')"><el-icon><Document /></el-icon> 征求纪委意见文档</el-button>
            </div>
          </div>

          <!-- 步骤2：民主推荐 -->
          <div v-show="currentSteps[activeStep] === '民主推荐'" class="step-panel">
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
            <div style="margin-top:12px;display:flex;align-items:center;gap:6px">
              <span style="font-size:12px;color:#666">选任材料生成：</span>
              <el-button @click="generateMaterial('recommend_list')"><el-icon><Document /></el-icon> 推荐人员名单</el-button>
              <el-button @click="generateMaterial('recommend_result')"><el-icon><Document /></el-icon> 会议推荐结果</el-button>
              <el-button @click="generateMaterial('recommend_talk')"><el-icon><Document /></el-icon> 谈话推荐结果</el-button>
            </div>
          </div>

          <!-- 步骤3：考察 -->
          <div v-show="currentSteps[activeStep] === '考察'" class="step-panel">
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
            <div style="margin-top:12px;display:flex;align-items:center;gap:6px">
              <span style="font-size:12px;color:#666">选任材料生成：</span>
              <el-button @click="generateMaterial('inspect_plan')"><el-icon><Document /></el-icon> 考察工作方案</el-button>
              <el-button @click="generateMaterial('inspect_result')"><el-icon><Document /></el-icon> 考察结果文件</el-button>
              <el-button @click="generateMaterial('inspect_supervision')"><el-icon><Document /></el-icon> 干部监督信息表单</el-button>
            </div>
          </div>

          <!-- 步骤4：讨论决定 -->
          <div v-show="currentSteps[activeStep] === '讨论决定'" class="step-panel">
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
            <div style="margin-top:12px;display:flex;align-items:center;gap:6px;flex-wrap:wrap">
              <span style="font-size:12px;color:#666">选任材料生成：</span>
              <el-button @click="generateMaterial('discuss_list')"><el-icon><Document /></el-icon> 上会名单</el-button>
              <el-button @click="generateMaterial('discuss_basic')"><el-icon><Document /></el-icon> 干部基础材料</el-button>
              <el-button type="warning" @click="generateMaterial('discuss_ppt')"><el-icon><DataAnalysis /></el-icon> 表决结果PPT</el-button>
              <el-button @click="generateMaterial('discuss_support')"><el-icon><Document /></el-icon> 配套资料</el-button>
            </div>
          </div>

          <!-- 步骤5：公示 -->
          <div v-show="currentSteps[activeStep] === '公示'" class="step-panel">
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
            <div style="margin-top:12px;display:flex;align-items:center;gap:6px">
              <span style="font-size:12px;color:#666">选任材料生成：</span>
              <el-button @click="generateMaterial('publicity_notice')"><el-icon><Document /></el-icon> 公示公告</el-button>
            </div>
          </div>

          <!-- 步骤6：任职 -->
          <div v-show="currentSteps[activeStep] === '任职'" class="step-panel">
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
            <div style="margin-top:12px;display:flex;align-items:center;gap:6px">
              <span style="font-size:12px;color:#666">选任材料生成：</span>
              <el-button @click="generateMaterial('appoint_talk')"><el-icon><Document /></el-icon> 任职谈话记录</el-button>
              <el-button @click="generateMaterial('appoint_doc')"><el-icon><Document /></el-icon> 任免发文</el-button>
            </div>
          </div>

          <!-- 任免备案 -->
          <div v-show="currentSteps[activeStep] === '任免备案'" class="step-panel">
            <div class="step-title">七、任免备案</div>
            <el-descriptions :column="2" border size="small" style="margin-bottom:12px">
              <el-descriptions-item label="备案时间">2024-07-15</el-descriptions-item>
              <el-descriptions-item label="备案机关">上级主管部门</el-descriptions-item>
              <el-descriptions-item label="备案文号">校党任备[2024]3号</el-descriptions-item>
              <el-descriptions-item label="备案状态">
                <el-tag type="success" size="small">已完成备案</el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="备案内容" :span="2">孙梅同志任机械工程学院院长（正处级），试用期一年。已完成任职备案手续，归档完毕。</el-descriptions-item>
            </el-descriptions>
            <div style="margin-top:12px;display:flex;align-items:center;gap:6px">
              <span style="font-size:12px;color:#666">选任材料生成：</span>
              <el-button @click="generateMaterial('appoint_doc')"><el-icon><Document /></el-icon> 任免发文</el-button>
            </div>
          </div>
        </div>

        <div v-if="currentProcess.status==='进行中'" class="step-nav" style="margin-top:16px;text-align:center">
          <el-button @click="prevStep" :disabled="activeStep===0">上一步</el-button>
          <el-button type="primary" @click="nextStep" :disabled="activeStep>=currentSteps.length-1">下一步</el-button>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible=false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 材料生成预览对话框 -->
    <el-dialog v-model="materialVisible" :title="materialTitle" width="760px" top="5vh" destroy-on-close>
      <div style="border:1px solid #e0e0e0;padding:20px;min-height:200px;max-height:500px;overflow-y:auto;background:#fff;font-size:14px;line-height:2" v-html="materialContent"></div>
      <template #footer>
        <el-button @click="materialVisible=false">关闭</el-button>
        <el-button type="primary" @click="handleExportMaterial"><el-icon><Download /></el-icon> 导出Word</el-button>
      </template>
    </el-dialog>

    <!-- 流程配置对话框 -->
    <el-dialog v-model="configVisible" title="选任流程配置" width="800px" top="5vh" destroy-on-close>
      <el-alert type="info" :closable="false" style="margin-bottom:16px">四类预置流程模板，可根据单位人事业务需要灵活选用。启动流程时在"流程类型"下拉框中选择即可。</el-alert>
      <el-row :gutter="16">
        <el-col :span="12" v-for="w in workflowPresets" :key="w.key">
          <el-card style="margin-bottom:12px" :body-style="{padding:'12px'}">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
              <span style="font-weight:bold;color:#1976D2;font-size:14px">{{ w.name }}</span>
              <el-tag size="small" type="primary">{{ w.steps.length }}节点</el-tag>
            </div>
            <el-steps :active="w.steps.length - 1" finish-status="success" direction="vertical" space="20px">
              <el-step v-for="s in w.steps" :key="s" :title="s" />
            </el-steps>
          </el-card>
        </el-col>
      </el-row>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Download, Search, RefreshLeft, Document, DataAnalysis, Setting } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'

const startDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const configVisible = ref(false)
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
  scope: '校内选拔',
  workflowType: 'promotion'
})

const startRules = {
  positionInfo: [{ required: true, message: '请输入职位信息', trigger: 'blur' }],
  conditions: [{ required: true, message: '请输入任职条件', trigger: 'blur' }]
}

// 四类预置选任业务流程
const workflowPresets = ref([
  { key: 'promotion',  name: '提拔流程',    steps: ['动议', '民主推荐', '考察', '讨论决定', '任职', '任免备案'] },
  { key: 'reuse',      name: '平级重用',    steps: ['动议', '考察', '讨论决定', '任职', '任免备案'] },
  { key: 'adjust',     name: '平级调整／免降职', steps: ['动议', '讨论决定', '任职', '任免备案'] },
  { key: 'social',     name: '社招干部',    steps: ['动议', '考察', '讨论决定', '任职', '任免备案'] }
])

const currentSteps = computed(() => {
  if (!currentProcess.value) return workflowPresets.value[0].steps
  const preset = workflowPresets.value.find(p => p.key === (currentProcess.value.workflowType || 'promotion'))
  return preset ? preset.steps : workflowPresets.value[0].steps
})

const tableData = ref([
  { id: 1, positionInfo: '机械工程学院院长（正处级）', currentStep: '任免备案', candidate: '孙梅', startTime: '2024-06-10', status: '已完成', workflowType: 'promotion' },
  { id: 2, positionInfo: '信息科学与工程学院副院长（副处级）', currentStep: '考察', candidate: '待确定', startTime: '2024-07-01', status: '进行中', workflowType: 'reuse' },
  { id: 3, positionInfo: '人事处副处长（副处级）', currentStep: '民主推荐', candidate: '待确定', startTime: '2024-07-15', status: '进行中', workflowType: 'promotion' }
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

function getWorkflowName(key) {
  const map = { promotion: '提拔流程', reuse: '平级重用', adjust: '平级调整／免降职', social: '社招干部' }
  return map[key] || key
}

function onWorkflowTypeChange() {}

function openStartDialog() {
  Object.assign(startForm, { positionInfo: '', conditions: '', scope: '校内选拔', workflowType: 'promotion' })
  startDialogVisible.value = true
}

function handleStart() {
  startFormRef.value.validate((valid) => {
    if (valid) {
      const preset = workflowPresets.value.find(p => p.key === startForm.workflowType)
      tableData.value.unshift({
        id: Date.now(),
        positionInfo: startForm.positionInfo,
        currentStep: preset ? preset.steps[0] : '动议',
        candidate: '待确定',
        startTime: new Date().toISOString().slice(0, 10),
        status: '进行中',
        workflowType: startForm.workflowType
      })
      ElMessage.success(`${preset ? preset.name : '提拔流程'}已启动`)
      startDialogVisible.value = false
    }
  })
}

function handleDetail(row) {
  currentProcess.value = row
  const steps = workflowPresets.value.find(p => p.key === (row.workflowType || 'promotion'))?.steps || ['动议','民主推荐','考察','讨论决定','任职','任免备案']
  const idx = steps.indexOf(row.currentStep)
  activeStep.value = idx >= 0 ? idx : 0
  if (row.id === 2) activeStep.value = Math.min(2, steps.length - 1)
  else if (row.id === 3) activeStep.value = Math.min(1, steps.length - 1)
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
  if (activeStep.value < currentSteps.value.length - 1) activeStep.value++
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

// 选任材料生成
const materialVisible = ref(false)
const materialTitle = ref('')
const materialContent = ref('')

const materialTemplates = {
  motion_plan: {
    title: '党政领导干部选拔任用工作方案记录表',
    content: `<h3 style="text-align:center;color:#1976D2">党政领导干部选拔任用工作方案记录表</h3>
<p><b>填报单位：</b>党委组织部&emsp;&emsp;<b>填报日期：</b>2024年6月10日</p>
<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse:collapse">
<tr><td width="20%"><b>选拔职位</b></td><td colspan="3">机械工程学院院长（正处级）</td></tr>
<tr><td><b>职位空缺情况</b></td><td colspan="3">原院长调任校领导，职位空缺</td></tr>
<tr><td><b>选拔方式</b></td><td colspan="3">校内选拔，民主推荐方式</td></tr>
<tr><td><b>动议原因</b></td><td colspan="3">根据工作需要和领导班子建设实际</td></tr>
<tr><td><b>选拔条件</b></td><td colspan="3">1.中共党员；2.正高级专业技术职务；3.5年以上副处级经历；4.不超过50周岁</td></tr>
<tr><td><b>党委组织部意见</b></td><td colspan="3">同意启动选拔程序（李芳 6月10日）</td></tr>
<tr><td><b>分管校领导意见</b></td><td colspan="3">同意（张伟 6月11日）</td></tr>
<tr><td><b>党委书记审批</b></td><td colspan="3">同意按程序启动（王建国 6月12日）</td></tr>
</table>`
  },
  motion_competition: {
    title: '机械工程学院院长公开竞聘方案',
    content: `<h3 style="text-align:center;color:#1976D2">机械工程学院院长（正处级）公开竞聘方案</h3>
<p><b>一、竞聘岗位：</b>机械工程学院院长（正处级，1名）</p>
<p><b>二、资格条件：</b>（1）中共党员，政治素质过硬；（2）具有正高级专业技术职务；（3）具有5年以上副处级岗位工作经历；（4）年龄不超过50周岁（1974年1月1日后出生）；（5）具有相关专业背景和较丰富的管理经验；（6）近3年年度考核均为合格以上。</p>
<p><b>三、选拔范围：</b>校内选拔</p>
<p><b>四、选拔程序：</b>发布公告→报名与资格审查→民主推荐→确定考察对象→组织考察→讨论决定→任前公示→正式任职</p>
<p><b>五、组织领导：</b>在党委统一领导下，党委组织部具体负责组织实施。</p>
<p><b>六、时间安排：</b>2024年6月10日—7月10日</p>
<p style="text-align:right;margin-top:30px">党委组织部<br>2024年6月10日</p>`
  },
  motion_discipline: {
    title: '拟推荐考察人选征求纪委意见的函',
    content: `<h3 style="text-align:center;color:#1976D2">关于拟推荐考察人选征求纪委意见的函</h3>
<p><b>校纪委：</b></p>
<p>根据干部选拔任用工作有关规定，拟将孙梅、吴涛等2位同志列为机械工程学院院长岗位拟推荐考察人选，现就上述人选在党风廉政方面的情况书面征求贵单位意见。请予支持。</p>
<p>附件：拟推荐考察人选基本情况表</p>
<p style="text-align:right;margin-top:30px">党委组织部<br>2024年6月13日</p>
<hr>
<h4>纪委回复意见：</h4>
<p>经核查，孙梅、吴涛2位同志均未收到任何信访举报线索，在党风廉政建设方面未发现有影响提拔使用的问题。</p>
<p style="text-align:right;margin-top:10px">校纪委（公章）<br>2024年6月14日</p>`
  },
  recommend_list: {
    title: '民主推荐人员名单',
    content: `<h3 style="text-align:center;color:#1976D2">机械工程学院院长岗位民主推荐人员名单</h3>
<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse:collapse">
<tr><th>序号</th><th>姓名</th><th>现工作单位及职务</th><th>政治面貌</th><th>出生年月</th><th>学历</th></tr>
<tr><td align="center">1</td><td>孙梅</td><td>机械工程学院 副院长、教授</td><td align="center">中共党员</td><td align="center">1975-12</td><td align="center">博士研究生</td></tr>
<tr><td align="center">2</td><td>吴涛</td><td>科研处 副处长、教授</td><td align="center">中共党员</td><td align="center">1978-05</td><td align="center">博士研究生</td></tr>
<tr><td align="center">3</td><td>郑华</td><td>研究生院 副院长、副教授</td><td align="center">中共党员</td><td align="center">1982-09</td><td align="center">博士研究生</td></tr>
<tr><td align="center">4</td><td>黄磊</td><td>机械工程学院 系主任、教授</td><td align="center">中共党员</td><td align="center">1980-03</td><td align="center">博士研究生</td></tr>
</table>
<p style="margin-top:15px"><b>推荐时间：</b>2024年6月15日-6月20日</p>
<p><b>推荐人数：</b>共推荐4人，发放推荐票156张，收回152张，有效票150张</p>`
  },
  recommend_result: {
    title: '民主推荐结果汇总表',
    content: `<h3 style="text-align:center;color:#1976D2">机械工程学院院长岗位民主推荐结果汇总表</h3>
<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse:collapse">
<tr><th>排名</th><th>姓名</th><th>得票数</th><th>得票率</th><th>是否确定为考察对象</th></tr>
<tr><td align="center">1</td><td>孙梅</td><td align="center">128</td><td align="center">85.3%</td><td align="center">√</td></tr>
<tr><td align="center">2</td><td>吴涛</td><td align="center">112</td><td align="center">74.7%</td><td align="center">√</td></tr>
<tr><td align="center">3</td><td>郑华</td><td align="center">65</td><td align="center">43.3%</td><td align="center">—</td></tr>
<tr><td align="center">4</td><td>黄磊</td><td align="center">42</td><td align="center">28.0%</td><td align="center">—</td></tr>
</table>
<p style="margin-top:15px"><b>统计人：</b>王建国&emsp;<b>复核人：</b>陈丽&emsp;<b>日期：</b>2024年6月21日</p>`
  },
  recommend_talk: {
    title: '谈话调研推荐报告',
    content: `<h3 style="text-align:center;color:#1976D2">谈话调研推荐情况报告</h3>
<p><b>一、基本情况：</b>共个别谈话45人，谈话对象包括学院领导班子成员、系主任、教授代表、骨干教师代表等。谈话推荐得票集中情况与会议推荐一致。</p>
<p><b>二、谈话推荐得票情况：</b>孙梅42人推荐，吴涛38人推荐，郑华20人推荐，黄磊15人推荐。</p>
<p><b>三、谈话了解主要特点：</b>推荐人多数认为孙梅同志政治素质好、管理经验丰富、业务能力强，具有较好的群众基础，是合适的人选。</p>
<p style="text-align:right;margin-top:30px">考察组<br>2024年6月21日</p>`
  },
  inspect_plan: {
    title: '干部推荐考察工作方案',
    content: `<h3 style="text-align:center;color:#1976D2">干部推荐考察工作方案</h3>
<p><b>一、考察任务：</b>对机械工程学院院长建议人选孙梅、吴涛同志进行考察</p>
<p><b>二、考察组成员：</b>组长李芳（人事处处长），成员王建国、陈丽、周志强</p>
<p><b>三、考察时间：</b>2024年6月22日—6月28日</p>
<p><b>四、考察内容：</b>德、能、勤、绩、廉五个方面</p>
<p><b>五、考察方式：</b>个别谈话、民主测评、查阅资料、实地考察、专项调查</p>
<p><b>六、考察程序：</b>制定方案→发布预告→个别谈话→实地考察→形成考察报告</p>
<p style="text-align:right;margin-top:30px">党委组织部<br>2024年6月21日</p>`
  },
  inspect_result: {
    title: '干部推荐考察结果报告',
    content: `<h3 style="text-align:center;color:#1976D2">关于孙梅、吴涛同志的考察报告</h3>
<p><b>一、考察对象基本情况：</b>孙梅，女，1975年12月出生，中共党员，博士研究生，现任机械工程学院副院长、教授。吴涛，男，1978年5月出生，中共党员，博士研究生，现任科研处副处长、教授。</p>
<p><b>二、"凡提四必"审核情况：</b>干部档案审核、个人有关事项报告核查、纪检监察机关意见核查、线索具体的信访举报核查均通过。</p>
<p><b>三、考察结论：</b>经考察，孙梅、吴涛2位同志德才兼备、实绩突出、群众认可，均符合机械工程学院院长的任职条件和选任标准，建议使用。</p>
<p style="text-align:right;margin-top:30px">考察组<br>2024年6月29日</p>`
  },
  inspect_supervision: {
    title: '干部监督信息表',
    content: `<h3 style="text-align:center;color:#1976D2">干部监督信息表</h3>
<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse:collapse">
<tr><th width="30%">审核事项</th><th width="20%">审核结果</th><th width="50%">审核详情</th></tr>
<tr><td>干部档案审核</td><td align="center" style="color:#43A047">通过</td><td>档案材料齐全，"三龄两历一身份"信息一致</td></tr>
<tr><td>个人有关事项报告核查</td><td align="center" style="color:#43A047">通过</td><td>已按规定如实报告，核查未发现问题</td></tr>
<tr><td>纪检监察机关意见</td><td align="center" style="color:#43A047">通过</td><td>校纪委出具廉政意见，未收到信访举报</td></tr>
<tr><td>信访举报核查</td><td align="center" style="color:#43A047">通过</td><td>未发现线索具体、有可查性的信访举报</td></tr>
</table>`
  },
  discuss_list: {
    title: '上会干部名单',
    content: `<h3 style="text-align:center;color:#1976D2">拟提交党委常委会讨论决定的干部任免提案</h3>
<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse:collapse">
<tr><th>序号</th><th>姓名</th><th>现任职务</th><th>拟任职务</th><th>考察结论</th></tr>
<tr><td align="center">1</td><td>孙梅</td><td>机械工程学院副院长</td><td>机械工程学院院长（正处级）</td><td align="center" style="color:#43A047">建议使用</td></tr>
</table>`
  },
  discuss_basic: {
    title: '上会干部基础材料',
    content: `<h3 style="text-align:center;color:#1976D2">干部基本信息表</h3>
<p><b>姓名：</b>孙梅&emsp;<b>性别：</b>女&emsp;<b>出生年月：</b>1975年12月</p>
<p><b>政治面貌：</b>中共党员&emsp;<b>学历：</b>博士研究生&emsp;<b>专业：</b>机械工程</p>
<p><b>现任职务：</b>机械工程学院副院长、教授&emsp;<b>任现职时间：</b>2019年3月</p>
<p><b>拟任职务：</b>机械工程学院院长（正处级）</p>
<p><b>学习经历：</b>1994-1998清华大学本科，1999-2002西安交通大学硕士，2002-2006上海交通大学博士</p>
<p><b>工作经历：</b>2006年入校工作，历任讲师、副教授、教授、系主任、副院长</p>
<p><b>民主推荐得票率：</b>85.3%</p>
<p><b>考察结论：</b>该同志政治素质好，管理经验丰富，建议使用</p>`
  },
  discuss_ppt: {
    title: '党委常委会表决结果PPT预览',
    content: `<h3 style="text-align:center;color:#1976D2">党委常委会表决结果</h3>
<p><b>会议时间：</b>2024年7月2日 上午9:00</p>
<p><b>应到常委：</b>11人&emsp;<b>实到常委：</b>10人（1人因公请假）</p>
<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse:collapse">
<tr><th>拟任人选</th><th>拟任职务</th><th>同意票</th><th>不同意票</th><th>弃权票</th><th>表决结果</th></tr>
<tr><td align="center">孙梅</td><td>机械工程学院院长（正处级）</td><td align="center" style="color:#1976D2;font-weight:bold;font-size:18px">10</td><td align="center">0</td><td align="center">0</td><td align="center" style="color:#43A047;font-weight:bold">通过</td></tr>
</table>
<p style="text-align:center;margin-top:20px"><span style="font-size:40px;color:#43A047">■</span> 全票通过</p>`
  },
  discuss_support: {
    title: '上会配套资料清单',
    content: `<h3 style="text-align:center;color:#1976D2">上会配套资料清单</h3>
<p>1. 干部任免提案表</p>
<p>2. 干部基本信息表</p>
<p>3. 民主推荐结果汇总表</p>
<p>4. 考察报告</p>
<p>5. 纪委廉政鉴定意见函</p>
<p>6. 干部档案审核登记表</p>
<p>7. 个人有关事项报告核查情况表</p>
<p>8. 常委会表决票样张</p>`
  },
  publicity_notice: {
    title: '任前公示公告',
    content: `<h3 style="text-align:center;color:#1976D2">干部任前公示公告</h3>
<p>经研究，拟提拔孙梅同志担任机械工程学院院长（正处级）职务，现予以公示。</p>
<p><b>公示对象：</b>孙梅，女，1975年12月出生，中共党员，博士研究生，现任机械工程学院副院长、教授。</p>
<p><b>公示时间：</b>2024年7月3日—7月9日（5个工作日）</p>
<p><b>受理部门：</b>校纪委（0XXX-XXXXXXX）、党委组织部（0XXX-XXXXXXX）</p>
<p><b>公示要求：</b>公示期间，任何单位和个人均可通过来信、来电、来访等方式反映公示对象在德、能、勤、绩、廉等方面存在的问题。</p>
<p style="text-align:right;margin-top:30px">党委组织部<br>2024年7月3日</p>`
  },
  appoint_talk: {
    title: '任职谈话记录',
    content: `<h3 style="text-align:center;color:#1976D2">任职谈话记录</h3>
<p><b>谈话时间：</b>2024年7月10日 下午3:00</p>
<p><b>谈话地点：</b>行政楼4楼接待室</p>
<p><b>谈话人：</b>党委书记王建国同志，分管副校长张伟同志</p>
<p><b>谈话对象：</b>孙梅</p>
<p><b>谈话主要内容：</b></p>
<p>1. 通报校党委决定，即日按程序发文任命。</p>
<p>2. 提出工作要求和期望：继续加强政治理论学习，提高政治站位；发挥专业优势推动学科建设；落实民主集中制，抓好班子自身建设；严守廉洁自律各项规定。</p>
<p>3. 孙梅同志表态：坚决服从组织安排，在新岗位上忠诚履职、勤奋工作、清正廉洁，不辜负校党委和全院师生信任。</p>`
  },
  appoint_doc: {
    title: '干部任免通知',
    content: `<h3 style="text-align:center;color:#1976D2">校党任〔2024〕15号</h3>
<h3 style="text-align:center">关于孙梅等同志职务任免的通知</h3>
<p>各基层党委（党总支），各单位、各部门：</p>
<p>经2024年7月2日党委常委会研究决定：</p>
<p>孙梅同志任机械工程学院院长（正处级），免去其机械工程学院副院长职务。</p>
<p>试用期一年，自2024年7月10日算起。</p>
<p style="text-align:right;margin-top:30px">中共辽宁工业大学委员会<br>2024年7月10日</p>`
  }
}

function generateMaterial(type) {
  const tpl = materialTemplates[type]
  if (!tpl) { ElMessage.warning('该材料模板尚未配置'); return }
  materialTitle.value = tpl.title
  materialContent.value = tpl.content
  materialVisible.value = true
}

function handleExportMaterial() {
  const blob = new Blob([
    `<html><head><meta charset="utf-8"><title>${materialTitle.value}</title></head><body>${materialContent.value}</body></html>`
  ], { type: 'application/msword' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url; a.download = materialTitle.value + '.doc'; a.click()
  URL.revokeObjectURL(url)
  ElMessage.success('Word文档导出成功')
}
</script>

<style scoped>
.process-detail { font-size: 13px; }
.step-title { font-size: 14px; font-weight: bold; color: #1976D2; margin-bottom: 10px; padding-left: 8px; border-left: 3px solid #1976D2; }
.section-title { font-size: 13px; font-weight: bold; color: #333; margin: 12px 0 8px 0; }
.step-panel { max-height: 450px; overflow-y: auto; padding-right: 8px; }
.step-nav { padding-top: 12px; border-top: 1px solid #e8e8e8; }
</style>
