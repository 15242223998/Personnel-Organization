<template>
  <div>
    <div class="page-header">{{ pageTitle }}</div>

    <!-- ============ 廉政意见（真实后端 /api/integrity） ============ -->
    <div v-show="activeTab === 'integrity'">
      <div class="search-bar">
        <span class="label">姓名：</span>
        <el-input v-model="search.integrity.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
        <span class="label">意见类型：</span>
        <el-select v-model="search.integrity.type" placeholder="请选择" size="default" style="width:140px" clearable>
          <el-option label="选拔任用" value="选拔任用" />
          <el-option label="职级晋升" value="职级晋升" />
          <el-option label="其他" value="其他" />
        </el-select>
        <el-button type="primary" @click="handleSearch('integrity')"><el-icon><Search /></el-icon> 查询</el-button>
        <el-button @click="resetSearch('integrity')">重置</el-button>
      </div>
      <div class="toolbar">
        <el-button type="primary" @click="openIntegrityDialog(null)"><el-icon><Plus /></el-icon> 新增廉政意见</el-button>
        <el-button @click="exportIntegrity"><el-icon><Download /></el-icon> 导出</el-button>
      </div>
      <div class="table-wrap">
        <el-table v-loading="loading.integrity" :data="pagedIntegrity" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column label="姓名" width="90" align="center" sortable>
            <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
          </el-table-column>
          <el-table-column prop="opinionType" label="意见类型" width="100" align="center" sortable />
          <el-table-column prop="opinionSource" label="来源" min-width="110" align="center" sortable />
          <el-table-column label="日期" width="110" align="center" sortable>
            <template #default="{ row }">{{ row.opinionDate || '-' }}</template>
          </el-table-column>
          <el-table-column prop="opinionResult" label="结果" width="90" align="center" sortable>
            <template #default="{ row }">
              <el-tag v-if="row.opinionResult" :type="row.opinionResult === '不同意' ? 'danger' : row.opinionResult === '暂缓' ? 'warning' : 'success'" size="small">{{ row.opinionResult }}</el-tag>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column prop="opinionContent" label="意见内容" min-width="200" show-overflow-tooltip />
          <el-table-column label="操作" width="170" align="center" fixed="right">
            <template #default="{ row }">
              <span class="link-blue" @click="openIntegrityView(row)">查看</span>
              <el-divider direction="vertical" />
              <span class="link-blue" @click="openIntegrityDialog(row)">编辑</span>
              <el-divider direction="vertical" />
              <span class="link-blue" style="color:#E53935" @click="handleIntegrityDelete(row)">删除</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.integrity.current"
          v-model:page-size="page.integrity.size"
          :page-sizes="[10, 20, 50]"
          :total="page.integrity.total"
          layout="total,sizes,prev,pager,next,jumper"
          background small
          @size-change="page.integrity.current = 1"
        />
      </div>
    </div>

    <!-- ============ 信访举报（真实后端 /api/complaint） ============ -->
    <div v-show="activeTab === 'complaint'">
      <div class="search-bar">
        <span class="label">被举报人：</span>
        <el-input v-model="search.complaint.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
        <span class="label">状态：</span>
        <el-select v-model="search.complaint.status" placeholder="请选择" size="default" style="width:130px" clearable>
          <el-option label="待处理" value="PENDING" />
          <el-option label="查核中" value="INVESTIGATING" />
          <el-option label="已办结" value="CLOSED" />
        </el-select>
        <el-button type="primary" @click="handleSearch('complaint')"><el-icon><Search /></el-icon> 查询</el-button>
        <el-button @click="resetSearch('complaint')">重置</el-button>
      </div>
      <div class="toolbar">
        <el-button type="primary" @click="openComplaintDialog(null)"><el-icon><Plus /></el-icon> 登记举报</el-button>
        <el-button @click="exportComplaint"><el-icon><Download /></el-icon> 导出</el-button>
      </div>
      <div class="table-wrap">
        <el-table v-loading="loading.complaint" :data="pagedComplaint" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column label="被举报人" width="90" align="center" sortable>
            <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
          </el-table-column>
          <el-table-column prop="complaintSource" label="来源" min-width="100" align="center" sortable />
          <el-table-column prop="complaintType" label="类型" min-width="100" align="center" sortable />
          <el-table-column label="日期" width="110" align="center" sortable>
            <template #default="{ row }">{{ row.complaintDate || '-' }}</template>
          </el-table-column>
          <el-table-column label="状态" width="100" align="center" sortable>
            <template #default="{ row }">
              <el-tag :type="handleStatusTag(row.handleStatus)" size="small">{{ handleStatusText(row.handleStatus) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="complaintContent" label="举报内容摘要" min-width="200" show-overflow-tooltip />
          <el-table-column label="操作" width="170" align="center" fixed="right">
            <template #default="{ row }">
              <span class="link-blue" @click="openComplaintView(row)">查看</span>
              <el-divider direction="vertical" />
              <span class="link-blue" @click="openProcessDialog(row)">办理</span>
              <el-divider direction="vertical" />
              <span class="link-blue" style="color:#E53935" @click="handleComplaintDelete(row)">删除</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.complaint.current"
          v-model:page-size="page.complaint.size"
          :page-sizes="[10, 20, 50]"
          :total="page.complaint.total"
          layout="total,sizes,prev,pager,next,jumper"
          background small
          @size-change="page.complaint.current = 1"
        />
      </div>
    </div>

    <!-- ============ 个人事项报告（真实后端 /api/personal-report） ============ -->
    <div v-show="activeTab === 'personal'">
      <div class="search-bar">
        <span class="label">姓名：</span>
        <el-input v-model="search.personal.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
        <span class="label">年度：</span>
        <el-input v-model="search.personal.year" placeholder="如2026" size="default" style="width:110px" clearable />
        <el-button type="primary" @click="handleSearch('personal')"><el-icon><Search /></el-icon> 查询</el-button>
        <el-button @click="resetSearch('personal')">重置</el-button>
      </div>
      <div class="toolbar">
        <el-button type="primary" @click="openPersonalDialog(null)"><el-icon><Plus /></el-icon> 新增报告</el-button>
        <el-button @click="exportPersonal"><el-icon><Download /></el-icon> 导出</el-button>
      </div>
      <div class="table-wrap">
        <el-table v-loading="loading.personal" :data="pagedPersonal" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column label="姓名" width="100" align="center" sortable>
            <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
          </el-table-column>
          <el-table-column prop="reportYear" label="年度" width="80" align="center" sortable />
          <el-table-column label="提交日期" width="110" align="center" sortable>
            <template #default="{ row }">{{ row.submitDate || '-' }}</template>
          </el-table-column>
          <el-table-column label="核查结果" width="100" align="center" sortable>
            <template #default="{ row }">
              <el-tag v-if="row.checkResult" :type="row.checkResult === 'NORMAL' ? 'success' : 'danger'" size="small">{{ checkResultText(row.checkResult) }}</el-tag>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="核查问题" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">{{ row.checkIssue || '-' }}</template>
          </el-table-column>
          <el-table-column prop="reportContent" label="报告内容摘要" min-width="200" show-overflow-tooltip />
          <el-table-column label="操作" width="190" align="center" fixed="right">
            <template #default="{ row }">
              <span class="link-blue" @click="openPersonalView(row)">查看</span>
              <el-divider direction="vertical" />
              <span class="link-blue" @click="openCheckDialog(row)">核查</span>
              <el-divider direction="vertical" />
              <span class="link-blue" @click="openPersonalDialog(row)">编辑</span>
              <el-divider direction="vertical" />
              <span class="link-blue" style="color:#E53935" @click="handlePersonalDelete(row)">删除</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.personal.current"
          v-model:page-size="page.personal.size"
          :page-sizes="[10, 20, 50]"
          :total="page.personal.total"
          layout="total,sizes,prev,pager,next,jumper"
          background small
          @size-change="page.personal.current = 1"
        />
      </div>
    </div>

    <!-- ============ 智能预警（真实后端 /api/alert） ============ -->
    <div v-show="activeTab === 'alert'">
      <div class="search-bar">
        <span class="label">关联干部：</span>
        <el-input v-model="search.alert.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
        <el-button type="primary" @click="handleSearch('alert')"><el-icon><Search /></el-icon> 查询</el-button>
        <el-button @click="resetSearch('alert')">重置</el-button>
        <span style="margin-left:12px;font-size:12px;color:#999">数据来源：监督预警记录（/api/alert）</span>
      </div>
      <div class="toolbar">
        <el-button type="warning" :loading="generatingAlert" @click="handleGenerateAlert"><el-icon><Plus /></el-icon> 按规则生成预警</el-button>
        <el-button type="primary" @click="loadAlerts"><el-icon><Refresh /></el-icon> 刷新</el-button>
        <el-button @click="exportAlert"><el-icon><Download /></el-icon> 导出预警清单</el-button>
      </div>
      <div class="table-wrap">
        <el-table v-loading="loading.alert" :data="pagedAlerts" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column label="预警类别" width="130" align="center">
            <template #default="{ row }">
              <el-tag :type="alertTagType(row.alertType)" size="small">{{ row.alertCategory || '-' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="级别" width="70" align="center">
            <template #default="{ row }">
              <span class="lv-chip" :style="levelStyle(row.alertType)">{{ levelText(row.alertType) }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="alertTitle" label="预警标题" min-width="200" show-overflow-tooltip />
          <el-table-column prop="alertContent" label="预警内容" min-width="220" show-overflow-tooltip />
          <el-table-column label="关联对象" width="100" align="center">
            <template #default="{ row }">{{ relatedName(row) }}</template>
          </el-table-column>
          <el-table-column label="已读" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="row.isRead === 1 ? 'info' : 'danger'" size="small">{{ row.isRead === 1 ? '已读' : '未读' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="触发时间" width="160" align="center">
            <template #default="{ row }">{{ fmtTime(row.createTime) }}</template>
          </el-table-column>
          <el-table-column label="操作" width="130" align="center" fixed="right">
            <template #default="{ row }">
              <span class="link-blue" @click="openAlertView(row)">详情</span>
              <el-divider direction="vertical" />
              <span class="link-blue" style="color:#E53935" @click="handleAlertDelete(row)">删除</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.alert.current"
          v-model:page-size="page.alert.size"
          :page-sizes="[10, 20, 50]"
          :total="page.alert.total"
          layout="total,sizes,prev,pager,next,jumper"
          background small
          @size-change="page.alert.current = 1"
        />
      </div>
    </div>

    <!-- ============ 提醒函询诫勉（真实后端 /api/admonish） ============ -->
    <div v-show="activeTab === 'admonish'">
      <div class="search-bar">
        <span class="label">姓名：</span>
        <el-input v-model="search.admonish.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
        <span class="label">状态：</span>
        <el-select v-model="search.admonish.status" placeholder="请选择" size="default" style="width:130px" clearable>
          <el-option label="待处理" value="待处理" />
          <el-option label="已办结" value="已办结" />
        </el-select>
        <el-button type="primary" @click="handleSearch('admonish')"><el-icon><Search /></el-icon> 查询</el-button>
        <el-button @click="resetSearch('admonish')">重置</el-button>
      </div>
      <div class="toolbar">
        <el-button type="primary" @click="openAdmonishDialog(null)"><el-icon><Plus /></el-icon> 新增登记</el-button>
        <el-button @click="exportAdmonish"><el-icon><Download /></el-icon> 导出</el-button>
      </div>
      <div class="table-wrap">
        <el-table v-loading="loading.admonish" :data="pagedAdmonish" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column label="姓名" width="90" align="center" sortable>
            <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
          </el-table-column>
          <el-table-column label="类型" width="90" align="center" sortable>
            <template #default="{ row }">
              <el-tag :type="admonishTypeTag(row.admonishType)" size="small">{{ row.admonishType || '-' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="triggerType" label="触发事由" min-width="180" show-overflow-tooltip />
          <el-table-column label="状态" width="90" align="center" sortable>
            <template #default="{ row }">
              <el-tag :type="row.handleStatus === '已办结' ? 'success' : 'warning'" size="small">{{ row.handleStatus || '-' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="handleUser" label="处理人" width="90" align="center" show-overflow-tooltip />
          <el-table-column label="处理时间" width="150" align="center">
            <template #default="{ row }">{{ fmtTime(row.handleTime) }}</template>
          </el-table-column>
          <el-table-column prop="content" label="内容摘要" min-width="180" show-overflow-tooltip />
          <el-table-column label="操作" width="200" align="center" fixed="right">
            <template #default="{ row }">
              <span class="link-blue" @click="openAdmonishView(row)">查看</span>
              <el-divider direction="vertical" />
              <span class="link-blue" @click="openAdmonishDialog(row)">编辑</span>
              <el-divider direction="vertical" />
              <span class="link-blue" @click="openAdmonishHandle(row)">办理结案</span>
              <el-divider direction="vertical" />
              <span class="link-blue" style="color:#E53935" @click="handleAdmonishDelete(row)">删除</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.admonish.current"
          v-model:page-size="page.admonish.size"
          :page-sizes="[10, 20, 50]"
          :total="page.admonish.total"
          layout="total,sizes,prev,pager,next,jumper"
          background small
          @size-change="page.admonish.current = 1"
        />
      </div>
    </div>

    <!-- ============ 经济责任审计（真实后端 /api/audit） ============ -->
    <div v-show="activeTab === 'audit'">
      <div class="search-bar">
        <span class="label">姓名：</span>
        <el-input v-model="search.audit.name" placeholder="请输入姓名" size="default" style="width:160px" clearable />
        <span class="label">审计范围：</span>
        <el-select v-model="search.audit.scope" placeholder="请选择" size="default" style="width:180px" clearable>
          <el-option label="任期经济责任审计" value="任期经济责任审计" />
          <el-option label="离任审计" value="离任审计" />
          <el-option label="专项审计" value="专项审计" />
        </el-select>
        <el-button type="primary" @click="handleSearch('audit')"><el-icon><Search /></el-icon> 查询</el-button>
        <el-button @click="resetSearch('audit')">重置</el-button>
      </div>
      <div class="toolbar">
        <el-button type="primary" @click="openAuditDialog(null)"><el-icon><Plus /></el-icon> 新增审计记录</el-button>
        <el-button @click="exportAudit"><el-icon><Download /></el-icon> 导出</el-button>
      </div>
      <div class="table-wrap">
        <el-table v-loading="loading.audit" :data="pagedAudit" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column label="姓名" width="90" align="center" sortable>
            <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
          </el-table-column>
          <el-table-column prop="auditScope" label="审计范围" width="150" align="center" sortable />
          <el-table-column label="审计期间" min-width="200" align="center">
            <template #default="{ row }">{{ row.auditPeriodStart || '-' }} 至 {{ row.auditPeriodEnd || '-' }}</template>
          </el-table-column>
          <el-table-column prop="auditOrg" label="审计机构" min-width="150" show-overflow-tooltip />
          <el-table-column label="审计结论" width="130" align="center" sortable>
            <template #default="{ row }">
              <el-tag v-if="row.auditResult" :type="auditResultTag(row.auditResult)" size="small">{{ row.auditResult }}</el-tag>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="整改状态" width="90" align="center" sortable>
            <template #default="{ row }">
              <el-tag v-if="row.rectifyStatus" :type="rectifyTag(row.rectifyStatus)" size="small">{{ row.rectifyStatus }}</el-tag>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="170" align="center" fixed="right">
            <template #default="{ row }">
              <span class="link-blue" @click="openAuditView(row)">查看</span>
              <el-divider direction="vertical" />
              <span class="link-blue" @click="openAuditDialog(row)">编辑</span>
              <el-divider direction="vertical" />
              <span class="link-blue" style="color:#E53935" @click="handleAuditDelete(row)">删除</span>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.audit.current"
          v-model:page-size="page.audit.size"
          :page-sizes="[10, 20, 50]"
          :total="page.audit.total"
          layout="total,sizes,prev,pager,next,jumper"
          background small
          @size-change="page.audit.current = 1"
        />
      </div>
    </div>

    <!-- ============ 详情弹窗（廉政意见） ============ -->
    <el-dialog v-model="view.integrity.visible" title="廉政意见详情" width="680px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.integrity.row">
        <el-descriptions-item label="姓名">{{ cadreName(view.integrity.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="意见类型">{{ view.integrity.row.opinionType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="来源">{{ view.integrity.row.opinionSource || '-' }}</el-descriptions-item>
        <el-descriptions-item label="结果">{{ view.integrity.row.opinionResult || '-' }}</el-descriptions-item>
        <el-descriptions-item label="日期">{{ view.integrity.row.opinionDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ fmtTime(view.integrity.row.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="意见内容" :span="2">{{ view.integrity.row.opinionContent || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.integrity.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 新增/编辑弹窗（廉政意见） ============ -->
    <el-dialog v-model="dialog.integrity.visible" :title="dialog.integrity.id ? '编辑廉政意见' : '新增廉政意见'" width="620px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="干部" required>
          <el-select v-model="dialog.integrity.form.cadreId" filterable placeholder="请输入姓名搜索" style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="意见类型">
          <el-select v-model="dialog.integrity.form.opinionType" style="width:100%">
            <el-option label="选拔任用" value="选拔任用" />
            <el-option label="职级晋升" value="职级晋升" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="来源单位">
          <el-input v-model="dialog.integrity.form.opinionSource" placeholder="请输入意见来源单位" />
        </el-form-item>
        <el-form-item label="出具日期">
          <el-date-picker v-model="dialog.integrity.form.opinionDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="意见结果">
          <el-input v-model="dialog.integrity.form.opinionResult" placeholder="如：同意/不同意/暂缓" />
        </el-form-item>
        <el-form-item label="意见内容">
          <el-input v-model="dialog.integrity.form.opinionContent" type="textarea" :rows="4" placeholder="请输入廉政意见内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.integrity.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitIntegrity">保存</el-button>
      </template>
    </el-dialog>

    <!-- ============ 详情弹窗（信访举报） ============ -->
    <el-dialog v-model="view.complaint.visible" title="举报详情" width="680px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.complaint.row">
        <el-descriptions-item label="被举报人">{{ cadreName(view.complaint.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="handleStatusTag(view.complaint.row.handleStatus)" size="small">{{ handleStatusText(view.complaint.row.handleStatus) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="来源">{{ view.complaint.row.complaintSource || '-' }}</el-descriptions-item>
        <el-descriptions-item label="类型">{{ view.complaint.row.complaintType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="日期">{{ view.complaint.row.complaintDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ fmtTime(view.complaint.row.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="举报内容" :span="2">{{ view.complaint.row.complaintContent || '-' }}</el-descriptions-item>
        <el-descriptions-item label="处理结果" :span="2">{{ view.complaint.row.handleResult || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.complaint.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 登记弹窗（信访举报） ============ -->
    <el-dialog v-model="dialog.complaint.visible" title="登记举报" width="620px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="被举报人" required>
          <el-select v-model="dialog.complaint.form.cadreId" filterable placeholder="请输入姓名搜索" style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="来源">
          <el-input v-model="dialog.complaint.form.complaintSource" placeholder="如：来信/来访/来电/网络举报" />
        </el-form-item>
        <el-form-item label="类型">
          <el-input v-model="dialog.complaint.form.complaintType" placeholder="如：经济问题/作风问题" />
        </el-form-item>
        <el-form-item label="举报日期">
          <el-date-picker v-model="dialog.complaint.form.complaintDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="dialog.complaint.form.handleStatus" style="width:100%">
            <el-option label="待处理" value="PENDING" />
            <el-option label="查核中" value="INVESTIGATING" />
            <el-option label="已办结" value="CLOSED" />
          </el-select>
        </el-form-item>
        <el-form-item label="举报内容">
          <el-input v-model="dialog.complaint.form.complaintContent" type="textarea" :rows="4" placeholder="请输入举报内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.complaint.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitComplaint">保存</el-button>
      </template>
    </el-dialog>

    <!-- ============ 办理弹窗（信访举报） ============ -->
    <el-dialog v-model="dialog.process.visible" title="举报办理" width="560px" align-center destroy-on-close>
      <el-form label-width="90px" v-if="dialog.process.row">
        <el-form-item label="被举报人">{{ cadreName(dialog.process.row.cadreId) }}</el-form-item>
        <el-form-item label="办理状态">
          <el-select v-model="dialog.process.form.handleStatus" style="width:100%">
            <el-option label="待处理" value="PENDING" />
            <el-option label="查核中" value="INVESTIGATING" />
            <el-option label="已办结" value="CLOSED" />
          </el-select>
        </el-form-item>
        <el-form-item label="处理结果">
          <el-input v-model="dialog.process.form.handleResult" type="textarea" :rows="4" placeholder="请输入调查核实及处理结果" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.process.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitProcess">保存</el-button>
      </template>
    </el-dialog>

    <!-- ============ 详情弹窗（个人事项报告） ============ -->
    <el-dialog v-model="view.personal.visible" title="个人事项报告详情" width="680px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.personal.row">
        <el-descriptions-item label="姓名">{{ cadreName(view.personal.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="年度">{{ view.personal.row.reportYear || '-' }}</el-descriptions-item>
        <el-descriptions-item label="提交日期">{{ view.personal.row.submitDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="核查结果">
          <el-tag v-if="view.personal.row.checkResult" :type="view.personal.row.checkResult === 'NORMAL' ? 'success' : 'danger'" size="small">{{ checkResultText(view.personal.row.checkResult) }}</el-tag>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="核查问题" :span="2">{{ view.personal.row.checkIssue || '-' }}</el-descriptions-item>
        <el-descriptions-item label="报告内容" :span="2">{{ view.personal.row.reportContent || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.personal.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 新增/编辑弹窗（个人事项报告） ============ -->
    <el-dialog v-model="dialog.personal.visible" :title="dialog.personal.id ? '编辑报告' : '新增报告'" width="620px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="干部" required>
          <el-select v-model="dialog.personal.form.cadreId" filterable placeholder="请输入姓名搜索" style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="年度" required>
          <el-input v-model="dialog.personal.form.reportYear" placeholder="如：2026" />
        </el-form-item>
        <el-form-item label="提交日期">
          <el-date-picker v-model="dialog.personal.form.submitDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="核查结果">
          <el-select v-model="dialog.personal.form.checkResult" clearable style="width:100%">
            <el-option label="正常（NORMAL）" value="NORMAL" />
            <el-option label="异常（ABNORMAL）" value="ABNORMAL" />
          </el-select>
        </el-form-item>
        <el-form-item label="核查问题">
          <el-input v-model="dialog.personal.form.checkIssue" type="textarea" :rows="3" placeholder="抽查/比对发现的问题描述" />
        </el-form-item>
        <el-form-item label="报告内容">
          <el-input v-model="dialog.personal.form.reportContent" type="textarea" :rows="4" placeholder="请输入报告事项内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.personal.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitPersonal">保存</el-button>
      </template>
    </el-dialog>

    <!-- ============ 核查弹窗（个人事项报告） ============ -->
    <el-dialog v-model="dialog.check.visible" title="事项核查" width="560px" align-center destroy-on-close>
      <el-form label-width="90px" v-if="dialog.check.row">
        <el-form-item label="报告人">{{ cadreName(dialog.check.row.cadreId) }}（{{ dialog.check.row.reportYear }} 年度）</el-form-item>
        <el-form-item label="核查结果">
          <el-select v-model="dialog.check.form.checkResult" style="width:100%">
            <el-option label="正常（NORMAL）" value="NORMAL" />
            <el-option label="异常（ABNORMAL）" value="ABNORMAL" />
          </el-select>
        </el-form-item>
        <el-form-item label="核查问题">
          <el-input v-model="dialog.check.form.checkIssue" type="textarea" :rows="4" placeholder="请输入核查发现问题描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.check.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitCheck">保存</el-button>
      </template>
    </el-dialog>

    <!-- ============ 预警详情弹窗 ============ -->
    <el-dialog v-model="view.alert.visible" title="预警详情" width="680px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.alert.row">
        <el-descriptions-item label="预警类别">{{ view.alert.row.alertCategory || '-' }}</el-descriptions-item>
        <el-descriptions-item label="预警级别">
          <span class="lv-chip" :style="levelStyle(view.alert.row.alertType)">{{ levelText(view.alert.row.alertType) }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="关联对象">{{ relatedName(view.alert.row) }}</el-descriptions-item>
        <el-descriptions-item label="已读">
          <el-tag :type="view.alert.row.isRead === 1 ? 'info' : 'danger'" size="small">{{ view.alert.row.isRead === 1 ? '已读' : '未读' }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="触发时间">{{ fmtTime(view.alert.row.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="阅读时间">{{ fmtTime(view.alert.row.readTime) }}</el-descriptions-item>
        <el-descriptions-item label="预警标题" :span="2">{{ view.alert.row.alertTitle || '-' }}</el-descriptions-item>
        <el-descriptions-item label="预警内容" :span="2">{{ view.alert.row.alertContent || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.alert.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 详情弹窗（提醒函询诫勉） ============ -->
    <el-dialog v-model="view.admonish.visible" title="提醒函询诫勉详情" width="680px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.admonish.row">
        <el-descriptions-item label="姓名">{{ cadreName(view.admonish.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="类型">{{ view.admonish.row.admonishType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="view.admonish.row.handleStatus === '已办结' ? 'success' : 'warning'" size="small">{{ view.admonish.row.handleStatus || '-' }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="纪律处分">{{ view.admonish.row.discipline || '-' }}</el-descriptions-item>
        <el-descriptions-item label="处理人">{{ view.admonish.row.handleUser || '-' }}</el-descriptions-item>
        <el-descriptions-item label="处理时间">{{ fmtTime(view.admonish.row.handleTime) }}</el-descriptions-item>
        <el-descriptions-item label="触发事由" :span="2">{{ view.admonish.row.triggerType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="内容" :span="2">{{ view.admonish.row.content || '-' }}</el-descriptions-item>
        <el-descriptions-item label="处理结果" :span="2">{{ view.admonish.row.result || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.admonish.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 新增/编辑弹窗（提醒函询诫勉） ============ -->
    <el-dialog v-model="dialog.admonish.visible" :title="dialog.admonish.id ? '编辑登记' : '新增登记'" width="620px" align-center destroy-on-close>
      <el-form label-width="100px">
        <el-form-item label="干部" required>
          <el-select v-model="dialog.admonish.form.cadreId" filterable placeholder="请输入姓名搜索" style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="类型" required>
          <el-select v-model="dialog.admonish.form.admonishType" style="width:100%">
            <el-option label="提醒谈话" value="提醒谈话" />
            <el-option label="函询" value="函询" />
            <el-option label="诫勉" value="诫勉" />
          </el-select>
        </el-form-item>
        <el-form-item label="触发事由">
          <el-input v-model="dialog.admonish.form.triggerType" type="textarea" :rows="2" placeholder="请输入触发事由" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="dialog.admonish.form.content" type="textarea" :rows="3" placeholder="请输入内容" />
        </el-form-item>
        <el-form-item label="纪律处分">
          <el-input v-model="dialog.admonish.form.discipline" placeholder="如：无 / 党内警告" />
        </el-form-item>
        <el-form-item label="处理状态">
          <el-select v-model="dialog.admonish.form.handleStatus" style="width:100%">
            <el-option label="待处理" value="待处理" />
            <el-option label="已办结" value="已办结" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.admonish.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitAdmonish">保存</el-button>
      </template>
    </el-dialog>

    <!-- ============ 办理结案弹窗（提醒函询诫勉） ============ -->
    <el-dialog v-model="dialog.admonishHandle.visible" title="办理结案" width="560px" align-center destroy-on-close>
      <el-form label-width="100px" v-if="dialog.admonishHandle.row">
        <el-form-item label="干部">{{ cadreName(dialog.admonishHandle.row.cadreId) }}（{{ dialog.admonishHandle.row.admonishType }}）</el-form-item>
        <el-form-item label="处理状态">
          <el-select v-model="dialog.admonishHandle.form.handleStatus" style="width:100%">
            <el-option label="待处理" value="待处理" />
            <el-option label="已办结" value="已办结" />
          </el-select>
        </el-form-item>
        <el-form-item label="处理人">
          <el-input v-model="dialog.admonishHandle.form.handleUser" placeholder="请输入处理人姓名" />
        </el-form-item>
        <el-form-item label="处理时间">
          <el-date-picker v-model="dialog.admonishHandle.form.handleTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" placeholder="选择处理时间" />
        </el-form-item>
        <el-form-item label="处理结果">
          <el-input v-model="dialog.admonishHandle.form.result" type="textarea" :rows="4" placeholder="请输入处理结果" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.admonishHandle.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitAdmonishHandle">保存</el-button>
      </template>
    </el-dialog>

    <!-- ============ 详情弹窗（经济责任审计） ============ -->
    <el-dialog v-model="view.audit.visible" title="经济责任审计详情" width="680px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.audit.row">
        <el-descriptions-item label="姓名">{{ cadreName(view.audit.row.cadreId) }}</el-descriptions-item>
        <el-descriptions-item label="审计范围">{{ view.audit.row.auditScope || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审计期间" :span="2">{{ view.audit.row.auditPeriodStart || '-' }} 至 {{ view.audit.row.auditPeriodEnd || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审计机构">{{ view.audit.row.auditOrg || '-' }}</el-descriptions-item>
        <el-descriptions-item label="实施时间">{{ view.audit.row.startTime || '-' }} 至 {{ view.audit.row.endTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审计结论">
          <el-tag v-if="view.audit.row.auditResult" :type="auditResultTag(view.audit.row.auditResult)" size="small">{{ view.audit.row.auditResult }}</el-tag>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="整改状态">
          <el-tag v-if="view.audit.row.rectifyStatus" :type="rectifyTag(view.audit.row.rectifyStatus)" size="small">{{ view.audit.row.rectifyStatus }}</el-tag>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="报告附件" :span="2">
          <a v-if="view.audit.row.auditReportUrl" :href="view.audit.row.auditReportUrl" target="_blank" rel="noopener" style="color:#1976D2">查看审计报告</a>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="发现问题" :span="2">{{ view.audit.row.issue || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.audit.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 新增/编辑弹窗（经济责任审计） ============ -->
    <el-dialog v-model="dialog.audit.visible" :title="dialog.audit.id ? '编辑审计记录' : '新增审计记录'" width="640px" align-center destroy-on-close>
      <el-form label-width="110px">
        <el-form-item label="干部" required>
          <el-select v-model="dialog.audit.form.cadreId" filterable placeholder="请输入姓名搜索" style="width:100%">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="审计范围" required>
          <el-select v-model="dialog.audit.form.auditScope" style="width:100%">
            <el-option label="任期经济责任审计" value="任期经济责任审计" />
            <el-option label="离任审计" value="离任审计" />
            <el-option label="专项审计" value="专项审计" />
          </el-select>
        </el-form-item>
        <el-form-item label="审计期间">
          <el-date-picker v-model="dialog.audit.form.auditPeriodStart" type="date" value-format="YYYY-MM-DD" placeholder="开始" style="width:47%" />
          <span style="margin:0 6px">至</span>
          <el-date-picker v-model="dialog.audit.form.auditPeriodEnd" type="date" value-format="YYYY-MM-DD" placeholder="结束" style="width:47%" />
        </el-form-item>
        <el-form-item label="审计机构">
          <el-input v-model="dialog.audit.form.auditOrg" placeholder="如：学校审计处" />
        </el-form-item>
        <el-form-item label="实施时间">
          <el-date-picker v-model="dialog.audit.form.startTime" type="date" value-format="YYYY-MM-DD" placeholder="开始" style="width:47%" />
          <span style="margin:0 6px">至</span>
          <el-date-picker v-model="dialog.audit.form.endTime" type="date" value-format="YYYY-MM-DD" placeholder="结束" style="width:47%" />
        </el-form-item>
        <el-form-item label="审计结论">
          <el-select v-model="dialog.audit.form.auditResult" clearable style="width:100%">
            <el-option label="无重大问题" value="无重大问题" />
            <el-option label="基本正常" value="基本正常" />
            <el-option label="存在需整改问题" value="存在需整改问题" />
            <el-option label="重大问题" value="重大问题" />
          </el-select>
        </el-form-item>
        <el-form-item label="整改状态">
          <el-select v-model="dialog.audit.form.rectifyStatus" clearable style="width:100%">
            <el-option label="待整改" value="待整改" />
            <el-option label="整改中" value="整改中" />
            <el-option label="已整改" value="已整改" />
          </el-select>
        </el-form-item>
        <el-form-item label="发现问题">
          <el-input v-model="dialog.audit.form.issue" type="textarea" :rows="3" placeholder="请输入审计发现问题" />
        </el-form-item>
        <el-form-item label="报告附件地址">
          <el-input v-model="dialog.audit.form.auditReportUrl" placeholder="选填，审计报告附件访问地址" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.audit.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitAudit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Search, Plus, Download, Refresh } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

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

// ============ 通用工具 ============
function fmt(v) { return v === null || v === undefined || v === '' ? '-' : v }
function fmtTime(t) {
  if (!t) return '-'
  return String(t).replace('T', ' ').slice(0, 19)
}
const cadreOptions = ref([])
const userOptions = ref([])
const cadreMap = computed(() => Object.fromEntries(cadreOptions.value.map(c => [c.id, c.name])))
const userMap = computed(() => Object.fromEntries(userOptions.value.map(u => [u.id, u.realName])))
function cadreName(id) {
  if (!id) return '-'
  return cadreMap.value[id] || `#${id}`
}
function userName(id) {
  if (!id) return '-'
  return userMap.value[id] || `#${id}`
}
function relatedName(row) {
  if (row.targetCadreId) return cadreName(row.targetCadreId)
  if (row.targetUserId) return userName(row.targetUserId)
  return '-'
}
function checkResultText(s) {
  return { NORMAL: '正常', ABNORMAL: '异常' }[s] || s || '-'
}
function handleStatusText(s) {
  return { PENDING: '待处理', INVESTIGATING: '查核中', CLOSED: '已办结' }[s] || fmt(s)
}
function handleStatusTag(s) {
  if (s === 'CLOSED') return 'success'
  if (s === 'INVESTIGATING') return 'warning'
  if (s === 'PENDING') return 'info'
  return ''
}
function levelText(s) {
  return { RED: '红', ORANGE: '橙', YELLOW: '黄', BLUE: '蓝' }[s] || fmt(s)
}
function levelStyle(s) {
  const map = {
    RED:    { color: '#B71C1C', bg: '#FFEBEE', border: '#EF9A9A' },
    ORANGE: { color: '#BF360C', bg: '#FBE9E7', border: '#FFAB91' },
    YELLOW: { color: '#795600', bg: '#FFFDE7', border: '#F9F295' },
    BLUE:   { color: '#0D47A1', bg: '#E3F2FD', border: '#90CAF9' }
  }
  const c = map[s] || { color: '#333', bg: '#F5F5F5', border: '#DDD' }
  return { color: c.color, background: c.bg, border: '1px solid ' + c.border }
}
function alertTagType(s) {
  if (s === 'RED') return 'danger'
  if (s === 'ORANGE') return 'warning'
  if (s === 'YELLOW') return 'warning'
  if (s === 'BLUE') return 'primary'
  return ''
}
function admonishTypeTag(s) {
  if (s === '提醒谈话') return 'info'
  if (s === '函询') return 'warning'
  if (s === '诫勉') return 'danger'
  return ''
}
function auditResultTag(s) {
  if (s === '无重大问题') return 'success'
  if (s === '基本正常') return 'primary'
  if (s === '存在需整改问题') return 'warning'
  if (s === '重大问题') return 'danger'
  return ''
}
function rectifyTag(s) {
  if (s === '已整改') return 'success'
  if (s === '整改中') return 'warning'
  if (s === '待整改') return 'danger'
  return ''
}

const saving = ref(false)
const loading = reactive({ integrity: false, complaint: false, personal: false, alert: false, admonish: false, audit: false })

const search = reactive({
  integrity: { name: '', type: '' },
  complaint: { name: '', status: '' },
  personal: { name: '', year: '' },
  alert: { name: '' },
  admonish: { name: '', status: '' },
  audit: { name: '', scope: '' }
})

const page = reactive({
  integrity: { current: 1, size: 10, total: 0 },
  complaint: { current: 1, size: 10, total: 0 },
  personal: { current: 1, size: 10, total: 0 },
  alert: { current: 1, size: 10, total: 0 },
  admonish: { current: 1, size: 10, total: 0 },
  audit: { current: 1, size: 10, total: 0 }
})

// ============ 数据集合 ============
const integrityAll = ref([])
const complaintAll = ref([])
const personalAll = ref([])
const alertAll = ref([])
const admonishAll = ref([])
const auditAll = ref([])

const filteredIntegrity = computed(() => integrityAll.value.filter(d =>
  (!search.integrity.name || cadreName(d.cadreId).includes(search.integrity.name)) &&
  (!search.integrity.type || d.opinionType === search.integrity.type)))
const pagedIntegrity = computed(() => {
  const p = page.integrity
  const start = (p.current - 1) * p.size
  return filteredIntegrity.value.slice(start, start + p.size)
})

const filteredComplaint = computed(() => complaintAll.value.filter(d =>
  (!search.complaint.name || cadreName(d.cadreId).includes(search.complaint.name)) &&
  (!search.complaint.status || d.handleStatus === search.complaint.status)))
const pagedComplaint = computed(() => {
  const p = page.complaint
  const start = (p.current - 1) * p.size
  return filteredComplaint.value.slice(start, start + p.size)
})

const filteredPersonal = computed(() => personalAll.value.filter(d =>
  (!search.personal.name || cadreName(d.cadreId).includes(search.personal.name)) &&
  (!search.personal.year || (d.reportYear || '') === search.personal.year)))
const pagedPersonal = computed(() => {
  const p = page.personal
  const start = (p.current - 1) * p.size
  return filteredPersonal.value.slice(start, start + p.size)
})

// 预警严重程度排序：红 > 橙 > 黄 > 蓝，同级按未读优先、时间新在前
const LEVEL_ORDER = { RED: 0, ORANGE: 1, YELLOW: 2, BLUE: 3 }
const filteredAlerts = computed(() => {
  const list = alertAll.value.filter(d =>
    !search.alert.name || relatedName(d).includes(search.alert.name))
  return list.sort((a, b) => {
    const oa = LEVEL_ORDER[a.alertType] ?? 9
    const ob = LEVEL_ORDER[b.alertType] ?? 9
    if (oa !== ob) return oa - ob
    const ua = a.isRead === 1 ? 1 : 0
    const ub = b.isRead === 1 ? 1 : 0
    if (ua !== ub) return ua - ub
    return String(b.createTime || '').localeCompare(String(a.createTime || ''))
  })
})
const pagedAlerts = computed(() => {
  const p = page.alert
  const start = (p.current - 1) * p.size
  return filteredAlerts.value.slice(start, start + p.size)
})

const filteredAdmonish = computed(() => admonishAll.value.filter(d =>
  (!search.admonish.name || cadreName(d.cadreId).includes(search.admonish.name)) &&
  (!search.admonish.status || d.handleStatus === search.admonish.status)))
const pagedAdmonish = computed(() => {
  const p = page.admonish
  const start = (p.current - 1) * p.size
  return filteredAdmonish.value.slice(start, start + p.size)
})

const filteredAudit = computed(() => auditAll.value.filter(d =>
  (!search.audit.name || cadreName(d.cadreId).includes(search.audit.name)) &&
  (!search.audit.scope || d.auditScope === search.audit.scope)))
const pagedAudit = computed(() => {
  const p = page.audit
  const start = (p.current - 1) * p.size
  return filteredAudit.value.slice(start, start + p.size)
})

function syncTotals() {
  page.integrity.total = filteredIntegrity.value.length
  page.complaint.total = filteredComplaint.value.length
  page.personal.total = filteredPersonal.value.length
  page.alert.total = filteredAlerts.value.length
  page.admonish.total = filteredAdmonish.value.length
  page.audit.total = filteredAudit.value.length
}
watch([filteredIntegrity, filteredComplaint, filteredPersonal, filteredAlerts, filteredAdmonish, filteredAudit], syncTotals)

function handleSearch(tab) {
  page[tab].current = 1
  syncTotals()
}
function resetSearch(tab) {
  Object.keys(search[tab]).forEach(k => { search[tab][k] = '' })
  page[tab].current = 1
  syncTotals()
}

// ============ 后端数据加载 ============
async function loadIntegrity() {
  loading.integrity = true
  try {
    const res = await request({ url: '/integrity/page', method: 'get', params: { current: 1, size: 500 } })
    integrityAll.value = res.data.records || []
  } catch (e) { integrityAll.value = [] } finally { loading.integrity = false }
}
async function loadComplaint() {
  loading.complaint = true
  try {
    const res = await request({ url: '/complaint/page', method: 'get', params: { current: 1, size: 500 } })
    complaintAll.value = res.data.records || []
  } catch (e) { complaintAll.value = [] } finally { loading.complaint = false }
}
async function loadPersonal() {
  loading.personal = true
  try {
    const res = await request({ url: '/personal-report/page', method: 'get', params: { current: 1, size: 500 } })
    personalAll.value = res.data.records || []
  } catch (e) { personalAll.value = [] } finally { loading.personal = false }
}
async function loadAlerts() {
  loading.alert = true
  try {
    const res = await request({ url: '/alert/page', method: 'get', params: { current: 1, size: 500 } })
    alertAll.value = res.data.records || []
  } catch (e) { alertAll.value = [] } finally { loading.alert = false }
}
const generatingAlert = ref(false)
async function handleGenerateAlert() {
  generatingAlert.value = true
  try {
    const res = await request({ url: '/supervise/alert/generate', method: 'post', showError: false })
    const data = res.data || {}
    const message = data.message || (data.added ? `新增预警 ${data.added} 条` : '扫描完成，无新增预警（当前台账无触发记录）')
    if ((data.added || 0) > 0) {
      ElMessage.success(message)
    } else {
      ElMessage.info(message)
    }
    loadAlerts()
  } catch (e) {
    ElMessage.error(e && e.message ? e.message : '预警生成失败')
  } finally {
    generatingAlert.value = false
  }
}
async function loadAdmonish() {
  loading.admonish = true
  try {
    const res = await request({ url: '/admonish/page', method: 'get', params: { current: 1, size: 500 } })
    admonishAll.value = res.data.records || []
  } catch (e) { admonishAll.value = [] } finally { loading.admonish = false }
}
async function loadAudit() {
  loading.audit = true
  try {
    const res = await request({ url: '/audit/page', method: 'get', params: { current: 1, size: 500 } })
    auditAll.value = res.data.records || []
  } catch (e) { auditAll.value = [] } finally { loading.audit = false }
}

async function loadNameMaps() {
  try {
    const res = await request({ url: '/cadre/page', method: 'post', params: { current: 1, size: 1000 }, data: {} })
    cadreOptions.value = res.data.records || []
  } catch (e) { cadreOptions.value = [] }
  try {
    const res = await request({ url: '/user/page', method: 'get', params: { current: 1, size: 500 } })
    userOptions.value = res.data.records || []
  } catch (e) { userOptions.value = [] }
}

// ============ 廉政意见 CRUD ============
const view = reactive({
  integrity: { visible: false, row: null },
  complaint: { visible: false, row: null },
  personal: { visible: false, row: null },
  alert: { visible: false, row: null },
  admonish: { visible: false, row: null },
  audit: { visible: false, row: null }
})

const emptyIntegrityForm = () => ({ cadreId: null, opinionType: '', opinionSource: '', opinionDate: '', opinionResult: '', opinionContent: '' })
const emptyAdmonishForm = () => ({ cadreId: null, admonishType: '', triggerType: '', content: '', result: '', discipline: '', handleStatus: '待处理' })
const emptyAuditForm = () => ({ cadreId: null, auditScope: '', auditPeriodStart: null, auditPeriodEnd: null, auditOrg: '', startTime: null, endTime: null, auditResult: '', issue: '', rectifyStatus: '', auditReportUrl: '' })
const dialog = reactive({
  integrity: { visible: false, id: null, form: emptyIntegrityForm() },
  complaint: { visible: false, id: null, form: {} },
  process: { visible: false, row: null, form: {} },
  personal: { visible: false, id: null, form: {} },
  check: { visible: false, row: null, form: {} },
  admonish: { visible: false, id: null, form: emptyAdmonishForm() },
  admonishHandle: { visible: false, row: null, form: {} },
  audit: { visible: false, id: null, form: emptyAuditForm() }
})

function openIntegrityDialog(row) {
  dialog.integrity.id = row ? row.id : null
  dialog.integrity.form = row
    ? { cadreId: row.cadreId, opinionType: row.opinionType || '', opinionSource: row.opinionSource || '', opinionDate: row.opinionDate || '', opinionResult: row.opinionResult || '', opinionContent: row.opinionContent || '' }
    : emptyIntegrityForm()
  dialog.integrity.visible = true
}
function openIntegrityView(row) {
  view.integrity.row = row
  view.integrity.visible = true
}
async function submitIntegrity() {
  const f = dialog.integrity.form
  if (!f.cadreId) return ElMessage.warning('请选择干部')
  saving.value = true
  try {
    if (dialog.integrity.id) {
      await request({ url: '/integrity', method: 'put', data: { id: dialog.integrity.id, ...f } })
      ElMessage.success('更新成功')
    } else {
      await request({ url: '/integrity', method: 'post', data: { ...f } })
      ElMessage.success('新增成功')
    }
    dialog.integrity.visible = false
    loadIntegrity()
  } finally { saving.value = false }
}
function handleIntegrityDelete(row) {
  ElMessageBox.confirm('确定删除该条廉政意见记录吗？', '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/integrity/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    loadIntegrity()
  }).catch(() => {})
}
function exportIntegrity() {
  showExportDialog(filteredIntegrity.value.map(d => ({ ...d, cadreName: cadreName(d.cadreId) })), [
    { prop: 'cadreName', label: '姓名' }, { prop: 'opinionType', label: '意见类型' }, { prop: 'opinionSource', label: '来源' },
    { prop: 'opinionDate', label: '日期' }, { prop: 'opinionResult', label: '结果' }, { prop: 'opinionContent', label: '意见内容' }
  ], '廉政意见')
}

// ============ 信访举报 CRUD ============
const emptyComplaintForm = () => ({ cadreId: null, complaintSource: '', complaintType: '', complaintDate: '', handleStatus: 'PENDING', complaintContent: '' })
function openComplaintDialog() {
  dialog.complaint.form = emptyComplaintForm()
  dialog.complaint.visible = true
}
function openComplaintView(row) {
  view.complaint.row = row
  view.complaint.visible = true
}
async function submitComplaint() {
  const f = dialog.complaint.form
  if (!f.cadreId) return ElMessage.warning('请选择被举报人')
  saving.value = true
  try {
    await request({ url: '/complaint', method: 'post', data: { ...f } })
    ElMessage.success('登记成功')
    dialog.complaint.visible = false
    loadComplaint()
  } finally { saving.value = false }
}
function openProcessDialog(row) {
  dialog.process.row = row
  dialog.process.form = { handleStatus: row.handleStatus || 'PENDING', handleResult: row.handleResult || '' }
  dialog.process.visible = true
}
async function submitProcess() {
  const row = dialog.process.row
  if (!row) return
  saving.value = true
  try {
    await request({ url: '/complaint', method: 'put', data: { id: row.id, ...dialog.process.form } })
    ElMessage.success('办理状态已更新')
    dialog.process.visible = false
    loadComplaint()
  } finally { saving.value = false }
}
function handleComplaintDelete(row) {
  ElMessageBox.confirm('确定删除该条举报记录吗？', '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/complaint/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    loadComplaint()
  }).catch(() => {})
}
function exportComplaint() {
  showExportDialog(filteredComplaint.value.map(d => ({ ...d, cadreName: cadreName(d.cadreId), statusText: handleStatusText(d.handleStatus) })), [
    { prop: 'cadreName', label: '被举报人' }, { prop: 'complaintSource', label: '来源' }, { prop: 'complaintType', label: '类型' },
    { prop: 'complaintDate', label: '日期' }, { prop: 'statusText', label: '状态' }, { prop: 'complaintContent', label: '举报内容' }
  ], '信访举报')
}

// ============ 个人事项报告 CRUD ============
const emptyPersonalForm = () => ({ cadreId: null, reportYear: '', submitDate: null, checkResult: '', checkIssue: '', reportContent: '' })
function openPersonalDialog(row) {
  dialog.personal.id = row ? row.id : null
  dialog.personal.form = row
    ? { cadreId: row.cadreId, reportYear: row.reportYear || '', submitDate: row.submitDate ?? null, checkResult: row.checkResult || '', checkIssue: row.checkIssue || '', reportContent: row.reportContent || '' }
    : emptyPersonalForm()
  dialog.personal.visible = true
}
function openPersonalView(row) {
  view.personal.row = row
  view.personal.visible = true
}
async function submitPersonal() {
  const f = dialog.personal.form
  if (!f.cadreId) return ElMessage.warning('请选择干部')
  if (!f.reportYear) return ElMessage.warning('请填写年度')
  saving.value = true
  try {
    if (dialog.personal.id) {
      await request({ url: '/personal-report', method: 'put', data: { id: dialog.personal.id, ...f } })
      ElMessage.success('更新成功')
    } else {
      await request({ url: '/personal-report', method: 'post', data: { ...f } })
      ElMessage.success('新增成功')
    }
    dialog.personal.visible = false
    loadPersonal()
  } finally { saving.value = false }
}
function openCheckDialog(row) {
  dialog.check.row = row
  dialog.check.form = { checkResult: row.checkResult || 'NORMAL', checkIssue: row.checkIssue || '' }
  dialog.check.visible = true
}
async function submitCheck() {
  const row = dialog.check.row
  if (!row) return
  saving.value = true
  try {
    await request({ url: '/personal-report', method: 'put', data: { id: row.id, cadreId: row.cadreId, reportYear: row.reportYear, ...dialog.check.form } })
    ElMessage.success('核查结果已保存')
    dialog.check.visible = false
    loadPersonal()
  } finally { saving.value = false }
}
function handlePersonalDelete(row) {
  ElMessageBox.confirm('确定删除该条个人事项报告吗？', '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/personal-report/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    loadPersonal()
  }).catch(() => {})
}
function exportPersonal() {
  showExportDialog(filteredPersonal.value.map(d => ({ ...d, cadreName: cadreName(d.cadreId), resultText: checkResultText(d.checkResult) })), [
    { prop: 'cadreName', label: '姓名' }, { prop: 'reportYear', label: '年度' }, { prop: 'submitDate', label: '提交日期' },
    { prop: 'resultText', label: '核查结果' }, { prop: 'checkIssue', label: '核查问题' }
  ], '个人事项报告')
}

// ============ 智能预警 ============
function openAlertView(row) {
  view.alert.row = row
  view.alert.visible = true
}
function handleAlertDelete(row) {
  ElMessageBox.confirm('确定删除该条预警记录吗？删除后不可恢复。', '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/alert/${row.id}`, method: 'delete' })
    ElMessage.success('已删除该条预警')
    loadAlerts()
  }).catch(() => {})
}
function exportAlert() {
  showExportDialog(filteredAlerts.value.map(d => ({
    ...d, levelText: levelText(d.alertType), relatedName: relatedName(d), createTimeText: fmtTime(d.createTime)
  })), [
    { prop: 'alertCategory', label: '预警类别' }, { prop: 'levelText', label: '级别' }, { prop: 'alertTitle', label: '预警标题' },
    { prop: 'alertContent', label: '预警内容' }, { prop: 'relatedName', label: '关联对象' }, { prop: 'createTimeText', label: '触发时间' }
  ], '智能预警清单')
}

// ============ 提醒函询诫勉 CRUD ============
function openAdmonishDialog(row) {
  dialog.admonish.id = row ? row.id : null
  dialog.admonish.form = row
    ? {
        cadreId: row.cadreId,
        admonishType: row.admonishType || '',
        triggerType: row.triggerType || '',
        content: row.content || '',
        result: row.result || '',
        discipline: row.discipline || '',
        handleStatus: row.handleStatus || '待处理'
      }
    : emptyAdmonishForm()
  dialog.admonish.visible = true
}
function openAdmonishView(row) {
  view.admonish.row = row
  view.admonish.visible = true
}
async function submitAdmonish() {
  const f = dialog.admonish.form
  if (!f.cadreId) return ElMessage.warning('请选择干部')
  if (!f.admonishType) return ElMessage.warning('请选择提醒函询诫勉类型')
  saving.value = true
  try {
    const payload = {
      cadreId: f.cadreId,
      admonishType: f.admonishType,
      triggerType: f.triggerType || null,
      content: f.content || null,
      result: f.result || null,
      discipline: f.discipline || null,
      handleStatus: f.handleStatus || '待处理'
    }
    if (dialog.admonish.id) {
      await request({ url: '/admonish', method: 'put', data: { id: dialog.admonish.id, ...payload } })
      ElMessage.success('更新成功')
    } else {
      await request({ url: '/admonish', method: 'post', data: payload })
      ElMessage.success('新增成功')
    }
    dialog.admonish.visible = false
    loadAdmonish()
  } finally { saving.value = false }
}
function openAdmonishHandle(row) {
  dialog.admonishHandle.row = row
  dialog.admonishHandle.form = {
    handleStatus: row.handleStatus || '待处理',
    handleUser: row.handleUser || '',
    handleTime: row.handleTime || null,
    result: row.result || ''
  }
  dialog.admonishHandle.visible = true
}
async function submitAdmonishHandle() {
  const row = dialog.admonishHandle.row
  if (!row) return
  saving.value = true
  try {
    await request({ url: '/admonish', method: 'put', data: { id: row.id, ...dialog.admonishHandle.form } })
    ElMessage.success('办理状态已保存')
    dialog.admonishHandle.visible = false
    loadAdmonish()
  } finally { saving.value = false }
}
function handleAdmonishDelete(row) {
  ElMessageBox.confirm('确定删除该条提醒函询诫勉记录吗？删除后不可恢复。', '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/admonish/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    loadAdmonish()
  }).catch(() => {})
}
function exportAdmonish() {
  showExportDialog(filteredAdmonish.value.map(d => ({ ...d, cadreName: cadreName(d.cadreId), handleTimeText: fmtTime(d.handleTime) })), [
    { prop: 'cadreName', label: '姓名' }, { prop: 'admonishType', label: '类型' }, { prop: 'triggerType', label: '触发事由' },
    { prop: 'handleStatus', label: '状态' }, { prop: 'discipline', label: '纪律处分' },
    { prop: 'handleUser', label: '处理人' }, { prop: 'handleTimeText', label: '处理时间' }, { prop: 'content', label: '内容' }
  ], '提醒函询诫勉')
}

// ============ 经济责任审计 CRUD ============
function openAuditDialog(row) {
  dialog.audit.id = row ? row.id : null
  dialog.audit.form = row
    ? {
        cadreId: row.cadreId,
        auditScope: row.auditScope || '',
        auditPeriodStart: row.auditPeriodStart || null,
        auditPeriodEnd: row.auditPeriodEnd || null,
        auditOrg: row.auditOrg || '',
        startTime: row.startTime || null,
        endTime: row.endTime || null,
        auditResult: row.auditResult || '',
        issue: row.issue || '',
        rectifyStatus: row.rectifyStatus || '',
        auditReportUrl: row.auditReportUrl || ''
      }
    : emptyAuditForm()
  dialog.audit.visible = true
}
function openAuditView(row) {
  view.audit.row = row
  view.audit.visible = true
}
async function submitAudit() {
  const f = dialog.audit.form
  if (!f.cadreId) return ElMessage.warning('请选择被审计干部')
  if (!f.auditScope) return ElMessage.warning('请选择审计范围')
  saving.value = true
  try {
    const payload = {
      cadreId: f.cadreId,
      auditScope: f.auditScope,
      auditPeriodStart: f.auditPeriodStart || null,
      auditPeriodEnd: f.auditPeriodEnd || null,
      auditOrg: f.auditOrg || null,
      startTime: f.startTime || null,
      endTime: f.endTime || null,
      auditResult: f.auditResult || null,
      issue: f.issue || null,
      rectifyStatus: f.rectifyStatus || null,
      auditReportUrl: f.auditReportUrl || null
    }
    if (dialog.audit.id) {
      await request({ url: '/audit', method: 'put', data: { id: dialog.audit.id, ...payload } })
      ElMessage.success('更新成功')
    } else {
      await request({ url: '/audit', method: 'post', data: payload })
      ElMessage.success('新增成功')
    }
    dialog.audit.visible = false
    loadAudit()
  } finally { saving.value = false }
}
function handleAuditDelete(row) {
  ElMessageBox.confirm('确定删除该条审计记录吗？删除后不可恢复。', '提示', { type: 'warning' }).then(async () => {
    await request({ url: `/audit/${row.id}`, method: 'delete' })
    ElMessage.success('删除成功')
    loadAudit()
  }).catch(() => {})
}
function exportAudit() {
  showExportDialog(filteredAudit.value.map(d => ({
    ...d, cadreName: cadreName(d.cadreId),
    periodText: (d.auditPeriodStart || '-') + ' 至 ' + (d.auditPeriodEnd || '-'),
    implText: (d.startTime || '-') + ' 至 ' + (d.endTime || '-')
  })), [
    { prop: 'cadreName', label: '姓名' }, { prop: 'auditScope', label: '审计范围' }, { prop: 'periodText', label: '审计期间' },
    { prop: 'auditOrg', label: '审计机构' }, { prop: 'implText', label: '实施时间' }, { prop: 'auditResult', label: '审计结论' },
    { prop: 'rectifyStatus', label: '整改状态' }, { prop: 'issue', label: '发现问题' }
  ], '经济责任审计')
}

// ============ 初始化 ============
loadNameMaps()
loadIntegrity()
loadComplaint()
loadPersonal()
loadAlerts()
loadAdmonish()
loadAudit()
</script>

<style scoped>
.search-bar {
  background: #f8f9fa;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 10px 14px;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}
.search-bar .label { font-size: 13px; color: #666; white-space: nowrap; }
.lv-chip {
  display: inline-block;
  padding: 0 7px;
  border-radius: 3px;
  font-size: 12px;
  font-weight: 600;
  line-height: 20px;
  white-space: nowrap;
}
</style>
