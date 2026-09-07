<template>
  <div>
    <div class="page-header">干部考核管理</div>

    <el-tabs v-model="activeTab" class="gov-tabs">
      <el-tab-pane label="年度考核" name="annual">
        <div class="search-bar">
          <span class="label">年度：</span>
          <el-select v-model="search.annual.year" placeholder="请选择年度" size="default" style="width:120px" clearable>
            <el-option v-for="y in yearOptions" :key="y" :label="y" :value="y" />
          </el-select>
          <span class="label">姓名：</span>
          <el-input v-model="search.annual.name" placeholder="请输入姓名" size="default" style="width:160px" clearable @keyup.enter="loadAnnual" />
          <span class="label">考核结果：</span>
          <el-select v-model="search.annual.result" placeholder="请选择" size="default" style="width:120px" clearable>
            <el-option label="优秀" value="优秀" />
            <el-option label="称职" value="称职" />
            <el-option label="基本称职" value="基本称职" />
            <el-option label="不称职" value="不称职" />
          </el-select>
          <el-button type="primary" @click="loadAnnual"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="resetAnnualSearch">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openAnnualDialog(null)"><el-icon><Plus /></el-icon> 新增考核</el-button>
          <el-button @click="handleImport"><el-icon><Upload /></el-icon> 批量导入</el-button>
          <el-button @click="exportAnnual"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="annualData" border size="small" v-loading="annualLoading">
            <el-table-column type="index" :index="(i) => (annualPage.current - 1) * annualPage.size + i + 1" label="序号" width="55" align="center" />
            <el-table-column prop="cadreName" label="姓名" width="80" align="center" sortable />
            <el-table-column prop="deptName" label="部门" min-width="140" show-overflow-tooltip sortable />
            <el-table-column prop="position" label="职务" min-width="120" show-overflow-tooltip sortable />
            <el-table-column prop="assessmentYear" label="年度" width="80" align="center" sortable />
            <el-table-column prop="assessmentResult" label="考核结果" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="resultTagType(row.assessmentResult)" size="small">{{ row.assessmentResult }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="assessmentComment" label="评语" min-width="220" show-overflow-tooltip />
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openAnnualDialog(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleDeleteAnnual(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div class="pagination-wrap">
          <el-pagination
            v-model:current-page="annualPage.current"
            v-model:page-size="annualPage.size"
            :page-sizes="[10,20,50]"
            :total="annualPage.total"
            layout="total,sizes,prev,pager,next,jumper"
            background
            @size-change="annualPage.current = 1; loadAnnual()"
            @current-change="loadAnnual"
          />
        </div>
      </el-tab-pane>

      <el-tab-pane label="民主测评" name="democracy">
        <div class="toolbar" style="border-top:1px solid #e0e0e0">
          <el-button type="primary" @click="openSchemeDialog(null)"><el-icon><Plus /></el-icon> 新建方案</el-button>
          <el-button @click="exportScheme"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="schemeData" border size="small" v-loading="schemeLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="schemeName" label="方案名称" min-width="180" sortable />
            <el-table-column prop="schemeYear" label="年度" width="70" align="center" sortable />
            <el-table-column label="投票方式" width="90" align="center">
              <template #default="{ row }">
                <el-tag :type="row.voteMode === 'BALLOT' ? 'warning' : 'primary'" size="small">
                  {{ row.voteMode === 'BALLOT' ? '表决式' : '评分式' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="开始时间" width="110" align="center">
              <template #default="{ row }">{{ formatDate(row.voteStartTime) }}</template>
            </el-table-column>
            <el-table-column label="结束时间" width="110" align="center">
              <template #default="{ row }">{{ formatDate(row.voteEndTime) }}</template>
            </el-table-column>
            <el-table-column prop="targetCount" label="测评对象" width="90" align="center" />
            <el-table-column prop="voterCount" label="参评人数" width="90" align="center" />
            <el-table-column prop="status" label="状态" width="100" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已关闭' ? 'info' : row.status === '进行中' ? 'success' : 'warning'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="430" align="center" fixed="right">
              <template #default="{ row }">
                <div class="op-cell">
                  <span class="link-blue" @click="openTargetManager(row)">测评对象</span>
                  <span class="op-sep" />
                  <span class="link-blue" @click="onSchemeVote(row)">投票</span>
                  <span class="link-blue" @click="onSchemeResult(row)">结果</span>
                  <el-dropdown trigger="click" @command="cmd => onSchemeMore(cmd, row)">
                    <span class="link-blue more-link">更多<el-icon class="el-icon--right"><ArrowDown /></el-icon></span>
                    <template #dropdown>
                      <el-dropdown-menu>
                        <template v-if="row.status === '草稿'">
                          <el-dropdown-item command="gen">生成对象</el-dropdown-item>
                          <el-dropdown-item command="publish">发布</el-dropdown-item>
                          <el-dropdown-item command="edit">编辑</el-dropdown-item>
                        </template>
                        <template v-else-if="row.status === '进行中'">
                          <el-dropdown-item command="close">关闭测评</el-dropdown-item>
                        </template>
                        <el-dropdown-item divided command="signs">签字留证</el-dropdown-item>
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                  <span class="op-sep" />
                  <span class="link-blue danger" @click="handleSchemeDelete(row)">删除</span>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div class="pagination-wrap">
          <el-pagination
            v-model:current-page="schemePage.current"
            v-model:page-size="schemePage.size"
            :page-sizes="[10,20,50]"
            :total="schemePage.total"
            layout="total,sizes,prev,pager,next,jumper"
            background
            @size-change="schemePage.current = 1; loadSchemes()"
            @current-change="loadSchemes"
          />
        </div>
      </el-tab-pane>

      <el-tab-pane label="成果输出" name="output">
        <div class="toolbar">
          <el-button type="primary" @click="exportOutput"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="outputData" border size="small" v-loading="outputLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="year" label="年度" width="100" align="center" sortable />
            <el-table-column prop="total" label="考核人数" width="100" align="center" sortable />
            <el-table-column prop="excellent" label="优秀" width="90" align="center" sortable />
            <el-table-column prop="qualified" label="称职" width="90" align="center" sortable />
            <el-table-column prop="basic" label="基本称职" width="100" align="center" sortable />
            <el-table-column prop="unqualified" label="不称职" width="90" align="center" sortable />
            <el-table-column label="优秀率" width="100" align="center">
              <template #default="{ row }">
                {{ row.total ? ((row.excellent / row.total) * 100).toFixed(1) + '%' : '-' }}
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 年度考核编辑 -->
    <el-dialog :title="annualEditId ? '编辑年度考核' : '新增年度考核'" v-model="annualDialog" width="560px" destroy-on-close>
      <el-form :model="annualForm" label-width="90px">
        <el-form-item label="干部" required>
          <el-select v-model="annualForm.cadreId" filterable style="width:100%" placeholder="请选择干部">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + (c.position ? `（${c.position}）` : '')" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="考核年度" required>
          <el-select v-model="annualForm.assessmentYear" style="width:100%" placeholder="请选择年度">
            <el-option v-for="y in yearOptions" :key="y" :label="y" :value="y" />
          </el-select>
        </el-form-item>
        <el-form-item label="考核结果" required>
          <el-select v-model="annualForm.assessmentResult" style="width:100%" placeholder="请选择">
            <el-option label="优秀" value="优秀" />
            <el-option label="称职" value="称职" />
            <el-option label="基本称职" value="基本称职" />
            <el-option label="不称职" value="不称职" />
          </el-select>
        </el-form-item>
        <el-form-item label="评语">
          <el-input v-model="annualForm.assessmentComment" type="textarea" :rows="3" placeholder="请输入考核评语" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="annualDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleAnnualSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 批量导入 -->
    <el-dialog v-model="importDialogVisible" title="批量导入考核数据" width="700px" destroy-on-close @closed="handleCancelImport">
      <el-upload :auto-upload="false" :limit="1" accept=".xlsx,.xls" :on-change="handleImportFile" :on-remove="() => { importPreviewData = [] }">
        <el-button type="primary"><el-icon><Upload /></el-icon> 选择Excel文件</el-button>
      </el-upload>
      <el-table v-if="importPreviewData.length > 0" :data="importPreviewData" border size="small" style="margin-top:16px" max-height="350">
        <el-table-column type="index" label="序号" width="50" align="center" />
        <el-table-column prop="name" label="姓名" width="90" align="center" />
        <el-table-column prop="assessmentYear" label="年度" width="70" align="center" />
        <el-table-column prop="assessmentResult" label="考核结果" width="90" align="center" />
        <el-table-column prop="assessmentComment" label="评语" min-width="160" show-overflow-tooltip />
      </el-table>
      <template #footer>
        <el-button @click="handleCancelImport">取消</el-button>
        <el-button type="primary" :disabled="importPreviewData.length === 0" :loading="importing" @click="confirmImport">确认导入</el-button>
      </template>
    </el-dialog>

    <!-- 方案编辑 -->
    <el-dialog :title="schemeEditId ? '编辑测评方案' : '新建测评方案'" v-model="schemeDialog" width="620px" destroy-on-close>
      <el-form :model="schemeForm" label-width="90px">
        <el-form-item label="方案名称" required>
          <el-input v-model="schemeForm.schemeName" placeholder="请输入方案名称" />
        </el-form-item>
        <el-form-item label="测评年度" required>
          <el-select v-model="schemeForm.schemeYear" style="width:100%">
            <el-option v-for="y in yearOptions" :key="y" :label="y" :value="y" />
          </el-select>
        </el-form-item>
        <el-form-item label="投票方式" required>
          <el-radio-group v-model="schemeForm.voteMode">
            <el-radio value="SCORE">评分式</el-radio>
            <el-radio value="BALLOT">表决式</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="需要签字留证">
          <el-switch v-model="schemeForm.needSign" active-text="是" inactive-text="否" />
          <span style="margin-left:10px;color:#999">投票结束后要求投票人手写签字留证</span>
        </el-form-item>
        <el-form-item label="测评时间">
          <el-date-picker v-model="schemeForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="维度/指标">
          <template v-if="schemeForm.voteMode === 'BALLOT'">
            <el-alert type="info" :closable="false" title="表决式方案无需配置维度/指标，投票时对每位测评对象作赞成/反对/弃权表决" />
          </template>
          <template v-else>
            <el-alert v-if="!schemeEditId" type="info" :closable="false" title="默认套用“德能勤绩廉”五维模板（总分100分），创建后可在详情中查看" />
            <el-alert v-else type="info" :closable="false" title="维度/指标模板创建后不可在此修改" />
          </template>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="schemeDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSchemeSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 生成测评对象 -->
    <el-dialog title="生成测评对象" v-model="targetDialog" width="560px" destroy-on-close>
      <div style="margin-bottom:8px">为方案【{{ currentScheme?.schemeName }}】选择测评对象干部：</div>
      <el-select v-model="targetForm.cadreIds" multiple filterable style="width:100%" placeholder="请选择干部（可多选）">
        <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name + (c.position ? `（${c.position}）` : '')" :value="c.id" />
      </el-select>
      <template #footer>
        <el-button @click="targetDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleTargetSubmit">确定生成</el-button>
      </template>
    </el-dialog>

    <!-- 投票 -->
    <el-dialog title="民主测评投票" v-model="voteDialog" width="720px" destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="测评对象">
          <el-select v-model="voteForm.targetCadreId" style="width:100%" placeholder="请选择被评干部" @change="handleVoteTargetChange">
            <el-option v-for="t in voteTargets" :key="t.cadreId" :label="t.cadreName" :value="t.cadreId" :disabled="t.voted" />
          </el-select>
        </el-form-item>
      </el-form>
      <el-table v-if="voteForm.targetCadreId" :data="voteIndicatorRows" border size="small">
        <el-table-column prop="dimensionName" label="维度" width="90" align="center" />
        <el-table-column prop="indicatorName" label="指标" min-width="180" />
        <el-table-column prop="maxScore" label="最高分" width="80" align="center" />
        <el-table-column label="评分" width="150" align="center">
          <template #default="{ row }">
            <el-input-number v-model="voteForm.scores[row.indicatorId]" :min="0" :max="Number(row.maxScore)" :step="0.5" size="small" style="width:120px" />
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="voteDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleVoteSubmit">提交投票</el-button>
      </template>
    </el-dialog>

    <!-- 测评结果 -->
    <el-dialog title="民主测评结果" v-model="resultDialog" width="820px">
      <div style="margin-bottom:12px;font-weight:bold">{{ currentScheme?.schemeName }}</div>
      <el-table :data="resultData" border size="small">
        <el-table-column type="index" label="排名" width="60" align="center" />
        <el-table-column prop="cadreName" label="测评对象" width="100" align="center" />
        <el-table-column prop="deptName" label="部门" min-width="120" show-overflow-tooltip />
        <el-table-column v-for="dim in resultDimensions" :key="dim.id" :label="`${dim.dimensionName}(${dim.dimensionWeight}分)`" width="110" align="center">
          <template #default="{ row }">
            {{ row.dimensionScores?.[dim.id] ?? '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="totalScore" label="总分" width="80" align="center">
          <template #default="{ row }">
            <span style="font-weight:bold;color:#1976D2">{{ row.totalScore }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="voterCount" label="参评人数" width="90" align="center" />
      </el-table>
    </el-dialog>

    <!-- 测评对象与材料 -->
    <el-dialog :title="'测评对象与材料 - ' + (targetManagerScheme?.schemeName || '')" v-model="targetManagerDialog" width="820px">
      <el-alert v-if="targetManagerRows.length === 0" type="info" :closable="false"
        title="该方案暂无测评对象。若为草稿方案，请先在列表中点击“生成对象”生成测评对象后再维护材料。" />
      <el-table v-else :data="targetManagerRows" border size="small" v-loading="targetManagerLoading">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="cadreName" label="测评对象" width="110" align="center" />
        <el-table-column prop="deptName" label="部门" min-width="110" show-overflow-tooltip />
        <el-table-column prop="position" label="职务" min-width="100" show-overflow-tooltip />
        <el-table-column label="测评材料" min-width="180" show-overflow-tooltip>
          <template #default="{ row }">
            <span v-if="row.materialTitle">{{ row.materialTitle }}</span>
            <span v-else style="color:#bbb">未填写</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="110" align="center">
          <template #default="{ row }">
            <span class="link-blue" @click="openMaterialDialog(row)">编辑材料</span>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="targetManagerDialog = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 材料编辑 -->
    <el-dialog :title="'编辑测评材料 - ' + materialForm.cadreName" v-model="materialDialog" width="680px" destroy-on-close>
      <el-form :model="materialForm" label-width="90px">
        <el-form-item label="材料标题" required>
          <el-input v-model="materialForm.materialTitle" placeholder="如：2026年度述职述廉报告" maxlength="120" />
        </el-form-item>
        <el-form-item label="材料正文" required>
          <el-input v-model="materialForm.materialText" type="textarea" :rows="10" placeholder="请输入测评材料正文内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="materialDialog = false">取消</el-button>
        <el-button type="primary" :loading="materialSaving" @click="handleMaterialSubmit">保存</el-button>
      </template>
    </el-dialog>

    <!-- 票决结果 -->
    <el-dialog title="票决结果" v-model="ballotDialog" width="720px">
      <div style="margin-bottom:12px;font-weight:bold">{{ currentScheme?.schemeName }}</div>
      <el-table :data="ballotData" border size="small" v-loading="ballotLoading">
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column label="测评对象" min-width="120" align="center">
          <template #default="{ row }">{{ rowName(row) }}</template>
        </el-table-column>
        <el-table-column label="部门" min-width="120" show-overflow-tooltip>
          <template #default="{ row }">{{ rowDept(row) }}</template>
        </el-table-column>
        <el-table-column label="赞成" width="100" align="center">
          <template #default="{ row }">
            <span style="color:#2E7D32;font-weight:bold">{{ rowCount(row, ['approveCount','approve','approveNum','agreeCount']) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="反对" width="100" align="center">
          <template #default="{ row }">
            <span style="color:#C62828;font-weight:bold">{{ rowCount(row, ['disapproveCount','disapprove','disapproveNum','opposeCount']) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="弃权" width="100" align="center">
          <template #default="{ row }">
            <span style="color:#78909C;font-weight:bold">{{ rowCount(row, ['abstainCount','abstain','abstainNum','waiveCount']) }}</span>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <!-- 签字留证 -->
    <el-dialog title="签字留证记录" v-model="signDialog" width="820px">
      <div style="margin-bottom:12px;font-weight:bold">{{ currentScheme?.schemeName }}</div>
      <el-table :data="signRows" border size="small" v-loading="signLoading">
        <el-table-column prop="voterName" label="投票人" width="120" align="center" />
        <el-table-column label="签字时间" width="170" align="center">
          <template #default="{ row }">{{ formatDateTime(row.signTime) }}</template>
        </el-table-column>
        <el-table-column prop="deviceIp" label="设备IP" width="150" align="center" />
        <el-table-column label="签字图片" min-width="180" align="center">
          <template #default="{ row }">
            <el-image
              v-if="row.imageData"
              :src="imgDataSrc(row.imageData)"
              :preview-src-list="[imgDataSrc(row.imageData)]"
              preview-teleported
              fit="contain"
              style="width:140px;height:60px;border:1px solid #e0e0e0;border-radius:4px;background:#fff"
            />
            <span v-else style="color:#bbb">无图片</span>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="signDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus, Upload, Download } from '@element-plus/icons-vue'
import { importExcel, mapImportData } from '@/utils/excel'
import { showExportDialog } from '@/utils/export-store'
import { getCadrePage } from '@/api/cadre'
import {
  getAnnualPage, addAnnual, updateAnnual, deleteAnnual, getAnnualStatsAll,
  getSchemePage, getSchemeDetail, addScheme, updateScheme, deleteScheme,
  publishScheme, closeScheme, generateTargets,
  submitVote, getVoteResult, hasMyVote,
  getSchemeTargets, updateTargetMaterial, getBallotResult, getSignatures
} from '@/api/assessment'

const activeTab = ref('annual')
const saving = ref(false)
const yearOptions = ['2026', '2025', '2024', '2023']

// ================= 年度考核 =================
const annualLoading = ref(false)
const annualData = ref([])
const annualPage = reactive({ current: 1, size: 10, total: 0 })
const search = reactive({ annual: { year: '', name: '', result: '' } })
const annualDialog = ref(false)
const annualEditId = ref(null)
const annualForm = reactive({ cadreId: null, assessmentYear: '', assessmentResult: '', assessmentComment: '' })
const cadreOptions = ref([])

async function loadAnnual() {
  annualLoading.value = true
  try {
    const res = await getAnnualPage({
      current: annualPage.current,
      size: annualPage.size,
      year: search.annual.year || undefined,
      name: search.annual.name || undefined,
      result: search.annual.result || undefined
    })
    annualData.value = res.data.records || []
    annualPage.total = Number(res.data.total) || 0
  } finally {
    annualLoading.value = false
  }
}

function resetAnnualSearch() {
  search.annual = { year: '', name: '', result: '' }
  annualPage.current = 1
  loadAnnual()
}

function resultTagType(result) {
  const map = { '优秀': 'success', '称职': '', '基本称职': 'warning', '不称职': 'danger' }
  return map[result] || ''
}

function openAnnualDialog(row) {
  if (row) {
    annualEditId.value = row.id
    annualForm.cadreId = row.cadreId
    annualForm.assessmentYear = row.assessmentYear
    annualForm.assessmentResult = row.assessmentResult
    annualForm.assessmentComment = row.assessmentComment || ''
  } else {
    annualEditId.value = null
    annualForm.cadreId = null
    annualForm.assessmentYear = ''
    annualForm.assessmentResult = ''
    annualForm.assessmentComment = ''
  }
  annualDialog.value = true
}

async function handleAnnualSubmit() {
  if (!annualForm.cadreId) return ElMessage.warning('请选择干部')
  if (!annualForm.assessmentYear) return ElMessage.warning('请选择考核年度')
  if (!annualForm.assessmentResult) return ElMessage.warning('请选择考核结果')
  saving.value = true
  try {
    if (annualEditId.value) {
      await updateAnnual({ id: annualEditId.value, ...annualForm })
      ElMessage.success('考核记录已更新并回写干部档案')
    } else {
      await addAnnual({ ...annualForm })
      ElMessage.success('考核记录已保存并回写干部档案')
    }
    annualDialog.value = false
    loadAnnual()
  } finally {
    saving.value = false
  }
}

function handleDeleteAnnual(row) {
  ElMessageBox.confirm(`确定删除 ${row.cadreName} ${row.assessmentYear} 年度考核记录吗？档案中的考核记录将同步移除。`, '提示', { type: 'warning' }).then(async () => {
    await deleteAnnual(row.id)
    ElMessage.success('删除成功')
    loadAnnual()
  }).catch(() => {})
}

// 批量导入
const importDialogVisible = ref(false)
const importPreviewData = ref([])
const importing = ref(false)

function handleImport() { importDialogVisible.value = true }

async function handleImportFile(file) {
  try {
    const raw = await importExcel(file.raw)
    importPreviewData.value = mapImportData(raw, {
      '姓名': 'name', '年度': 'assessmentYear', '考核结果': 'assessmentResult', '评语': 'assessmentComment'
    })
  } catch (e) { ElMessage.error(e.message); importPreviewData.value = [] }
}

async function confirmImport() {
  if (importPreviewData.value.length === 0) { ElMessage.warning('没有可导入的数据'); return }
  importing.value = true
  let ok = 0, fail = 0
  try {
    for (const item of importPreviewData.value) {
      const cadre = cadreOptions.value.find(c => c.name === item.name)
      if (!cadre) { fail++; continue }
      try {
        await addAnnual({
          cadreId: cadre.id,
          assessmentYear: String(item.assessmentYear || ''),
          assessmentResult: item.assessmentResult,
          assessmentComment: item.assessmentComment || ''
        })
        ok++
      } catch { fail++ }
    }
    ElMessage.success(`导入完成：成功 ${ok} 条，失败 ${fail} 条`)
    importDialogVisible.value = false
    importPreviewData.value = []
    loadAnnual()
  } finally {
    importing.value = false
  }
}

function handleCancelImport() { importDialogVisible.value = false; importPreviewData.value = [] }

function exportAnnual() {
  showExportDialog(annualData.value, [
    { prop: 'cadreName', label: '姓名' },
    { prop: 'deptName', label: '部门' },
    { prop: 'position', label: '职务' },
    { prop: 'assessmentYear', label: '年度' },
    { prop: 'assessmentResult', label: '考核结果' },
    { prop: 'assessmentComment', label: '评语' }
  ], '年度考核')
}

// ================= 民主测评 =================
const schemeLoading = ref(false)
const schemeData = ref([])
const schemePage = reactive({ current: 1, size: 10, total: 0 })
const schemeDialog = ref(false)
const schemeEditId = ref(null)
const schemeForm = reactive({ schemeName: '', schemeYear: '', dateRange: [], voteMode: 'SCORE', needSign: false })
const currentScheme = ref(null)

async function loadSchemes() {
  schemeLoading.value = true
  try {
    const res = await getSchemePage({ current: schemePage.current, size: schemePage.size })
    const records = res.data.records || []
    schemePage.total = Number(res.data.total) || 0
    // 补充测评对象数/参评人数
    schemeData.value = await Promise.all(records.map(async (s) => {
      try {
        const detail = await getSchemeDetail(s.id)
        return { ...s, targetCount: detail.data.targetCount, voterCount: detail.data.voterCount }
      } catch {
        return { ...s, targetCount: '-', voterCount: '-' }
      }
    }))
  } finally {
    schemeLoading.value = false
  }
}

function formatDate(dt) {
  if (!dt) return '-'
  return String(dt).replace('T', ' ').slice(0, 10)
}

function openSchemeDialog(row) {
  if (row) {
    schemeEditId.value = row.id
    schemeForm.schemeName = row.schemeName
    schemeForm.schemeYear = row.schemeYear
    schemeForm.voteMode = row.voteMode || 'SCORE'
    schemeForm.needSign = !!row.needSign
    schemeForm.dateRange = row.voteStartTime && row.voteEndTime
      ? [formatDate(row.voteStartTime), formatDate(row.voteEndTime)] : []
  } else {
    schemeEditId.value = null
    schemeForm.schemeName = ''
    schemeForm.schemeYear = ''
    schemeForm.voteMode = 'SCORE'
    schemeForm.needSign = false
    schemeForm.dateRange = []
  }
  schemeDialog.value = true
}

async function handleSchemeSubmit() {
  if (!schemeForm.schemeName) return ElMessage.warning('请填写方案名称')
  if (!schemeForm.schemeYear) return ElMessage.warning('请选择测评年度')
  const startTime = schemeForm.dateRange?.[0] ? `${schemeForm.dateRange[0]}T00:00:00` : null
  const endTime = schemeForm.dateRange?.[1] ? `${schemeForm.dateRange[1]}T23:59:59` : null
  saving.value = true
  try {
    if (schemeEditId.value) {
      await updateScheme({
        id: schemeEditId.value,
        schemeName: schemeForm.schemeName,
        schemeYear: schemeForm.schemeYear,
        voteStartTime: startTime,
        voteEndTime: endTime,
        voteMode: schemeForm.voteMode,
        needSign: schemeForm.needSign ? 1 : 0
      })
      ElMessage.success('方案更新成功')
    } else {
      await addScheme({
        scheme: {
          schemeName: schemeForm.schemeName,
          schemeYear: schemeForm.schemeYear,
          voteStartTime: startTime,
          voteEndTime: endTime,
          voteMode: schemeForm.voteMode,
          needSign: schemeForm.needSign ? 1 : 0
        },
        dimensions: []
      })
      ElMessage.success(schemeForm.voteMode === 'BALLOT'
        ? '方案创建成功（表决式方案，无需维度指标）'
        : '方案创建成功（已套用默认德能勤绩廉模板）')
    }
    schemeDialog.value = false
    schemeEditId.value = null
    loadSchemes()
  } finally {
    saving.value = false
  }
}

function handleSchemeDelete(row) {
  ElMessageBox.confirm('删除方案将同时清除其维度/指标与投票数据，确定删除吗？', '提示', { type: 'warning' }).then(async () => {
    await deleteScheme(row.id)
    ElMessage.success('删除成功')
    loadSchemes()
  }).catch(() => {})
}

async function handlePublish(row) {
  await publishScheme(row.id)
  ElMessage.success('方案已发布，进入投票阶段')
  loadSchemes()
}

async function handleClose(row) {
  ElMessageBox.confirm('关闭后本方案将停止投票，确定关闭吗？', '提示', { type: 'warning' }).then(async () => {
    await closeScheme(row.id)
    ElMessage.success('方案已关闭')
    loadSchemes()
  }).catch(() => {})
}

// 生成测评对象
const targetDialog = ref(false)
const targetForm = reactive({ cadreIds: [] })

function openTargetDialog(row) {
  currentScheme.value = row
  targetForm.cadreIds = []
  targetDialog.value = true
}

async function handleTargetSubmit() {
  if (targetForm.cadreIds.length === 0) return ElMessage.warning('请选择测评对象干部')
  saving.value = true
  try {
    await generateTargets(currentScheme.value.id, targetForm.cadreIds)
    ElMessage.success(`已生成 ${targetForm.cadreIds.length} 名测评对象`)
    targetDialog.value = false
    loadSchemes()
  } finally {
    saving.value = false
  }
}

// 投票
const voteDialog = ref(false)
const voteForm = reactive({ targetCadreId: null, scores: {} })
const voteTargets = ref([])
const voteIndicatorRows = ref([])

async function openVoteDialog(row) {
  currentScheme.value = row
  voteForm.targetCadreId = null
  voteForm.scores = {}
  const detail = await getSchemeDetail(row.id)
  // 从结果接口获取对象名单（含已投票标记用）
  let list = []
  try {
    const result = await getVoteResult(row.id)
    list = (result.data || []).map(item => ({ cadreId: item.targetCadreId, cadreName: item.cadreName }))
  } catch { list = [] }
  // 标记已投过票的对象
  voteTargets.value = await Promise.all(list.map(async (t) => {
    try {
      const my = await hasMyVote({ schemeId: row.id, targetCadreId: t.cadreId })
      return { ...t, voted: !!my.data }
    } catch {
      return { ...t, voted: false }
    }
  }))
  // 展开维度-指标
  const rows = []
  for (const node of detail.data.dimensions || []) {
    for (const ind of node.indicators || []) {
      rows.push({
        dimensionName: node.dimension.dimensionName,
        indicatorId: ind.id,
        indicatorName: ind.indicatorName,
        maxScore: ind.maxScore
      })
    }
  }
  voteIndicatorRows.value = rows
  voteDialog.value = true
}

function handleVoteTargetChange() {
  voteForm.scores = {}
}

async function handleVoteSubmit() {
  if (!voteForm.targetCadreId) return ElMessage.warning('请选择被评干部')
  const unfilled = voteIndicatorRows.value.find(r => voteForm.scores[r.indicatorId] == null)
  if (unfilled) return ElMessage.warning(`请填写指标【${unfilled.indicatorName}】的评分`)
  saving.value = true
  try {
    await submitVote({
      schemeId: currentScheme.value.id,
      targetCadreId: voteForm.targetCadreId,
      scores: voteForm.scores
    })
    ElMessage.success('投票成功')
    voteDialog.value = false
    loadSchemes()
  } finally {
    saving.value = false
  }
}

// 平板投票入口（表决式方案在平板端进行）
function openTablet() {
  window.open('/tablet', '_blank')
}

// ================= 测评对象与材料 =================
const targetManagerDialog = ref(false)
const targetManagerLoading = ref(false)
const targetManagerScheme = ref(null)
const targetManagerRows = ref([])

async function openTargetManager(row) {
  targetManagerScheme.value = row
  targetManagerDialog.value = true
  await reloadTargetManager()
}

async function reloadTargetManager() {
  const row = targetManagerScheme.value
  if (!row) return
  targetManagerLoading.value = true
  try {
    const res = await getSchemeTargets(row.id)
    targetManagerRows.value = (res.data || []).map(t => {
      const c = cadreOptions.value.find(x => Number(x.id) === Number(t.cadreId))
      return {
        ...t,
        cadreName: c ? (c.name || c.cadreName) : `干部#${t.cadreId}`,
        deptName: c?.deptName || '',
        position: c?.position || ''
      }
    })
  } catch {
    targetManagerRows.value = []
  } finally {
    targetManagerLoading.value = false
  }
}

const materialDialog = ref(false)
const materialSaving = ref(false)
const materialForm = reactive({ id: null, cadreName: '', materialTitle: '', materialText: '' })

function openMaterialDialog(row) {
  materialForm.id = row.id
  materialForm.cadreName = row.cadreName
  materialForm.materialTitle = row.materialTitle || ''
  materialForm.materialText = row.materialText || ''
  materialDialog.value = true
}

async function handleMaterialSubmit() {
  if (!materialForm.id) return ElMessage.warning('缺少测评对象信息，无法保存')
  if (!materialForm.materialTitle) return ElMessage.warning('请填写材料标题')
  if (!materialForm.materialText) return ElMessage.warning('请填写材料正文')
  materialSaving.value = true
  try {
    await updateTargetMaterial(materialForm.id, {
      materialTitle: materialForm.materialTitle,
      materialText: materialForm.materialText
    })
    ElMessage.success('测评材料已保存')
    materialDialog.value = false
    reloadTargetManager()
  } finally {
    materialSaving.value = false
  }
}

// ================= 票决结果（表决式） =================
const ballotDialog = ref(false)
const ballotLoading = ref(false)
const ballotData = ref([])

async function openBallotResult(row) {
  currentScheme.value = row
  ballotData.value = []
  ballotDialog.value = true
  ballotLoading.value = true
  try {
    const res = await getBallotResult(row.id)
    ballotData.value = res.data || []
  } catch {
    ballotData.value = []
  } finally {
    ballotLoading.value = false
  }
}

function rowName(r) {
  return r?.cadreName || r?.name || r?.targetName || r?.cadre_name || `对象#${r?.targetCadreId ?? ''}`
}
function rowDept(r) {
  return r?.deptName || r?.department || r?.dept_name || ''
}
function rowCount(r, keys) {
  for (const k of keys) {
    if (r[k] != null) return Number(r[k]) || 0
  }
  return 0
}

// ================= 签字留证记录 =================
const signDialog = ref(false)
const signLoading = ref(false)
const signRows = ref([])

async function openSignatures(row) {
  currentScheme.value = row
  signRows.value = []
  signDialog.value = true
  signLoading.value = true
  try {
    const res = await getSignatures(row.id)
    signRows.value = res.data || []
  } catch {
    signRows.value = []
  } finally {
    signLoading.value = false
  }
}

function formatDateTime(v) {
  if (!v) return '-'
  return String(v).replace('T', ' ').slice(0, 19)
}

function imgDataSrc(img) {
  if (!img) return ''
  return img.startsWith('data:') ? img : 'data:image/png;base64,' + img
}

// 统一操作入口：投票（草稿/已结束给出提示，BALLOT 走平板端）
function onSchemeVote(row) {
  if (row.status === '草稿') return ElMessage.info('方案尚未发布，暂不能投票')
  if (row.status === '已关闭') return ElMessage.info('测评已结束，请查看结果')
  if (row.voteMode === 'BALLOT') openTablet()
  else openVoteDialog(row)
}

// 统一操作入口：结果（草稿提示，BALLOT 展示票决结果，SCORE 展示计票结果）
function onSchemeResult(row) {
  if (row.status === '草稿') return ElMessage.info('测评尚未开始，暂无结果')
  if (row.voteMode === 'BALLOT') openBallotResult(row)
  else openResult(row)
}

// 更多下拉：状态相关操作
function onSchemeMore(cmd, row) {
  if (cmd === 'gen') openTargetDialog(row)
  else if (cmd === 'publish') handlePublish(row)
  else if (cmd === 'edit') openSchemeDialog(row)
  else if (cmd === 'close') handleClose(row)
  else if (cmd === 'signs') openSignatures(row)
}

// 测评结果
const resultDialog = ref(false)
const resultData = ref([])
const resultDimensions = ref([])

async function openResult(row) {
  currentScheme.value = row
  const detail = await getSchemeDetail(row.id)
  resultDimensions.value = (detail.data.dimensions || []).map(n => n.dimension)
  const res = await getVoteResult(row.id)
  resultData.value = res.data || []
  resultDialog.value = true
}

function exportScheme() {
  showExportDialog(schemeData.value, [
    { prop: 'schemeName', label: '方案名称' },
    { prop: 'schemeYear', label: '年度' },
    { prop: 'targetCount', label: '测评对象' },
    { prop: 'voterCount', label: '参评人数' },
    { prop: 'status', label: '状态' }
  ], '民主测评方案')
}

// ================= 成果输出 =================
const outputLoading = ref(false)
const outputData = ref([])

async function loadOutput() {
  outputLoading.value = true
  try {
    const res = await getAnnualStatsAll()
    outputData.value = res.data || []
  } finally {
    outputLoading.value = false
  }
}

function exportOutput() {
  showExportDialog(outputData.value, [
    { prop: 'year', label: '年度' },
    { prop: 'total', label: '考核人数' },
    { prop: 'excellent', label: '优秀' },
    { prop: 'qualified', label: '称职' },
    { prop: 'basic', label: '基本称职' },
    { prop: 'unqualified', label: '不称职' }
  ], '考核成果输出')
}

onMounted(async () => {
  if (window.innerWidth <= 768) activeTab.value = 'democracy'
  loadAnnual()
  loadSchemes()
  loadOutput()
  try {
    const res = await getCadrePage({ current: 1, size: 500 })
    cadreOptions.value = res.data.records || []
  } catch { cadreOptions.value = [] }
})
</script>

<style scoped>
.op-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  white-space: nowrap;
}
.op-cell .more-link {
  display: inline-flex;
  align-items: center;
}
.op-cell .danger {
  color: #E53935;
}
.op-cell .danger:hover {
  color: #c62828;
  text-decoration: underline;
}
.op-sep {
  width: 1px;
  height: 14px;
  flex: none;
  background: #e0e0e0;
  margin: 0 -3px;
}
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

@media (max-width: 768px) {
  .gov-tabs :deep(.el-tabs__header) {
    padding: 0 4px;
  }
  .gov-tabs :deep(.el-tabs__item) {
    font-size: 13px;
    padding: 0 10px;
  }
  .search-bar {
    flex-wrap: wrap;
    gap: 6px;
  }
  .toolbar {
    flex-wrap: wrap;
    gap: 6px;
  }
  .toolbar .el-button {
    margin-left: 0;
  }
}
</style>
