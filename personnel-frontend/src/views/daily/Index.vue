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
          <el-button type="primary" @click="() => {}"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="search.cert = { name: '', type: '' }">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openCertDialog(null)"><el-icon><Plus /></el-icon> 新增登记</el-button>
          <el-button @click="exportCert"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="filteredCertData" border size="small" v-loading="certLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column label="持证人" width="90" align="center">
              <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
            </el-table-column>
            <el-table-column prop="certType" label="证照类型" width="110" align="center" sortable />
            <el-table-column prop="certNumber" label="证照号码" min-width="140" align="center" sortable />
            <el-table-column prop="certStatus" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.certStatus === '已归还' ? 'success' : row.certStatus === '在借' ? 'warning' : 'info'" size="small">{{ row.certStatus || '在库' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="borrowDate" label="借出日期" width="110" align="center" sortable />
            <el-table-column prop="expectedReturnDate" label="应还日期" width="110" align="center" sortable />
            <el-table-column prop="returnDate" label="归还日期" width="110" align="center" sortable />
            <el-table-column prop="remark" label="备注" min-width="140" show-overflow-tooltip />
            <el-table-column label="操作" width="180" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" v-if="row.certStatus !== '在借'" @click="handleCertLend(row)">借出</span>
                <span class="link-blue" v-else @click="handleCertReturn(row)">归还</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="openCertDialog(row)">编辑</span>
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
          <el-button type="primary"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="search.overseas = { name: '' }">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openAbroadDialog(null)"><el-icon><Plus /></el-icon> 新增记录</el-button>
          <el-button @click="exportOverseas"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="filteredAbroadData" border size="small" v-loading="abroadLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column label="姓名" width="90" align="center">
              <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
            </el-table-column>
            <el-table-column prop="destination" label="目的地" min-width="110" align="center" sortable />
            <el-table-column prop="purpose" label="出境事由" min-width="110" align="center" sortable />
            <el-table-column prop="departDate" label="出境日期" width="110" align="center" sortable />
            <el-table-column prop="returnDate" label="回国日期" width="110" align="center" sortable />
            <el-table-column prop="approvedDays" label="批准天数" width="90" align="center" sortable />
            <el-table-column prop="actualDays" label="实际天数" width="90" align="center" sortable />
            <el-table-column prop="isOverdue" label="是否超期" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.isOverdue === 1 ? 'danger' : 'success'" size="small">{{ row.isOverdue === 1 ? '超期' : '正常' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openAbroadDialog(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleAbroadDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="休假管理" name="leave">
        <div class="search-bar">
          <span class="label">申请人：</span>
          <el-input v-model="search.leave.name" placeholder="请输入姓名" size="default" style="width:140px" clearable />
          <span class="label">状态：</span>
          <el-select v-model="search.leave.status" placeholder="请选择" size="default" style="width:110px" clearable>
            <el-option label="待审批" value="待审批" />
            <el-option label="已批准" value="已批准" />
            <el-option label="已驳回" value="已驳回" />
          </el-select>
          <el-button type="primary"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="search.leave = { name: '', status: '' }">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openLeaveDialog(null)"><el-icon><Plus /></el-icon> 申请休假</el-button>
          <el-button @click="exportLeave"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="filteredLeaveData" border size="small" v-loading="leaveLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column label="申请人" width="90" align="center">
              <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
            </el-table-column>
            <el-table-column prop="leaveType" label="休假类型" width="100" align="center" sortable />
            <el-table-column prop="startDate" label="开始日期" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="结束日期" width="110" align="center" sortable />
            <el-table-column prop="leaveDays" label="天数" width="70" align="center" sortable />
            <el-table-column prop="reason" label="事由" min-width="150" show-overflow-tooltip />
            <el-table-column prop="approveStatus" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.approveStatus === '已批准' ? 'success' : row.approveStatus === '待审批' ? 'warning' : 'danger'" size="small">{{ row.approveStatus }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" v-if="row.approveStatus === '待审批'" @click="openApprove(row, 'leave')">审批</span>
                <span class="link-blue" @click="openLeaveDialog(row)">编辑</span>
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
          <el-button type="primary"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="search.training = { name: '', type: '' }">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openTrainingDialog(null)"><el-icon><Plus /></el-icon> 新增培训</el-button>
          <el-button @click="exportTraining"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="filteredTrainingData" border size="small" v-loading="trainingLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="trainingName" label="培训名称" min-width="180" show-overflow-tooltip sortable />
            <el-table-column prop="trainingType" label="培训类型" width="100" align="center" sortable />
            <el-table-column prop="organizer" label="主办单位" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="startDate" label="开始日期" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="结束日期" width="110" align="center" sortable />
            <el-table-column label="参训人数" width="90" align="center">
              <template #default="{ row }">{{ (trainingCadreCounts[row.id] ?? '-') }}</template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '已完成' ? 'success' : row.status === '进行中' ? '' : 'warning'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openStudents(row)">学员管理</span>
                <el-divider direction="vertical" />
                <span class="link-blue" @click="openTrainingDialog(row)">编辑</span>
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
          <el-button type="primary"><el-icon><Search /></el-icon> 查询</el-button>
          <el-button @click="search.secondment = { name: '' }">重置</el-button>
        </div>
        <div class="toolbar">
          <el-button type="primary" @click="openSecondmentDialog(null)"><el-icon><Plus /></el-icon> 新增挂职</el-button>
          <el-button @click="exportSecondment"><el-icon><Download /></el-icon> 导出</el-button>
        </div>
        <div class="table-wrap">
          <el-table :data="filteredSecondmentData" border size="small" v-loading="secondmentLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column label="姓名" width="90" align="center">
              <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
            </el-table-column>
            <el-table-column prop="secondmentUnit" label="挂职单位" min-width="160" show-overflow-tooltip sortable />
            <el-table-column prop="secondmentPosition" label="挂任职务" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="startDate" label="开始日期" width="110" align="center" sortable />
            <el-table-column prop="endDate" label="结束日期" width="110" align="center" sortable />
            <el-table-column prop="status" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '挂职中' ? 'success' : row.status === '未开始' ? 'warning' : 'info'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="120" show-overflow-tooltip />
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" @click="openSecondmentDialog(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleSecondmentDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="自助申报" name="declare">
        <div class="toolbar" style="border-top:1px solid #e0e0e0">
          <el-button type="primary" @click="openDeclareDialog"><el-icon><Plus /></el-icon> 新增申报</el-button>
          <el-button @click="exportDeclare"><el-icon><Download /></el-icon> 导出</el-button>
          <el-alert v-if="profile && !profile.cadreId" type="warning" :closable="false" show-icon
            title="当前账号未绑定干部档案，无法自助申报，请联系管理员在【系统管理-用户管理】中绑定" style="flex:1;margin-left:12px;padding:4px 8px" />
        </div>
        <div class="table-wrap">
          <el-table :data="declareData" border size="small" v-loading="declareLoading">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column label="申报人" width="100" align="center">
              <template #default="{ row }">{{ userName(row.applicantId) }}</template>
            </el-table-column>
            <el-table-column prop="applicationType" label="申报类型" width="110" align="center" sortable />
            <el-table-column prop="applicationTitle" label="申报标题" min-width="200" show-overflow-tooltip sortable />
            <el-table-column prop="createTime" label="提交时间" width="150" align="center" sortable>
              <template #default="{ row }">{{ (row.createTime || '').replace('T', ' ').slice(0, 16) }}</template>
            </el-table-column>
            <el-table-column prop="applyStatus" label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.applyStatus === 'APPROVED' ? 'success' : row.applyStatus === 'SUBMITTED' ? 'warning' : row.applyStatus === 'REJECTED' ? 'danger' : 'info'" size="small">
                  {{ applyStatusText(row.applyStatus) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="220" align="center" fixed="right">
              <template #default="{ row }">
                <span class="link-blue" v-if="row.applyStatus === 'DRAFT'" @click="handleDeclareSubmit(row)">提交</span>
                <span class="link-blue" v-if="row.applyStatus === 'SUBMITTED'" @click="openApprove(row, 'declare')">审批</span>
                <span class="link-blue" @click="handleDeclareView(row)">查看</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleDeclareDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 证照 -->
    <el-dialog :title="editId.cert ? '编辑证照登记' : '新增证照登记'" v-model="certDialog" width="560px" destroy-on-close>
      <el-form :model="certForm" label-width="90px">
        <el-form-item label="持证人" required>
          <el-select v-model="certForm.cadreId" filterable style="width:100%" placeholder="请选择干部">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="证照类型" required>
          <el-select v-model="certForm.certType" style="width:100%" placeholder="请选择">
            <el-option label="护照" value="护照" />
            <el-option label="港澳通行证" value="港澳通行证" />
            <el-option label="台湾通行证" value="台湾通行证" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="证照号码" required>
          <el-input v-model="certForm.certNumber" placeholder="请输入证照号码" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="certForm.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="certDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleCertSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 出境 -->
    <el-dialog :title="editId.abroad ? '编辑出境记录' : '新增出境记录'" v-model="abroadDialog" width="560px" destroy-on-close>
      <el-form :model="abroadForm" label-width="90px">
        <el-form-item label="干部" required>
          <el-select v-model="abroadForm.cadreId" filterable style="width:100%" placeholder="请选择干部">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="目的地" required>
          <el-input v-model="abroadForm.destination" placeholder="请输入国家/地区" />
        </el-form-item>
        <el-form-item label="出境事由">
          <el-select v-model="abroadForm.purpose" style="width:100%">
            <el-option label="公务出访" value="公务出访" />
            <el-option label="探亲" value="探亲" />
            <el-option label="旅游" value="旅游" />
            <el-option label="学术交流" value="学术交流" />
          </el-select>
        </el-form-item>
        <el-form-item label="起止日期" required>
          <el-date-picker v-model="abroadForm.dateRange" type="daterange" range-separator="至" start-placeholder="出境" end-placeholder="回国" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="批准天数" required>
          <el-input-number v-model="abroadForm.approvedDays" :min="1" :max="365" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="abroadDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleAbroadSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 休假 -->
    <el-dialog :title="editId.leave ? '编辑休假申请' : '申请休假'" v-model="leaveDialog" width="560px" destroy-on-close>
      <el-form :model="leaveForm" label-width="90px">
        <el-form-item label="申请人" required>
          <el-select v-model="leaveForm.cadreId" filterable style="width:100%" placeholder="请选择干部">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="休假类型" required>
          <el-select v-model="leaveForm.leaveType" style="width:100%">
            <el-option label="年休假" value="年休假" />
            <el-option label="病假" value="病假" />
            <el-option label="事假" value="事假" />
            <el-option label="婚假" value="婚假" />
            <el-option label="产假" value="产假" />
          </el-select>
        </el-form-item>
        <el-form-item label="起止日期" required>
          <el-date-picker v-model="leaveForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="事由" required>
          <el-input v-model="leaveForm.reason" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="leaveDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleLeaveSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 培训 -->
    <el-dialog :title="editId.training ? '编辑培训' : '新增培训'" v-model="trainingDialog" width="600px" destroy-on-close>
      <el-form :model="trainingForm" label-width="90px">
        <el-form-item label="培训名称" required>
          <el-input v-model="trainingForm.trainingName" />
        </el-form-item>
        <el-form-item label="培训类型" required>
          <el-select v-model="trainingForm.trainingType" style="width:100%">
            <el-option label="党校培训" value="党校培训" />
            <el-option label="业务培训" value="业务培训" />
            <el-option label="在线学习" value="在线学习" />
            <el-option label="外出进修" value="外出进修" />
          </el-select>
        </el-form-item>
        <el-form-item label="主办单位" required>
          <el-input v-model="trainingForm.organizer" />
        </el-form-item>
        <el-form-item label="培训地点">
          <el-input v-model="trainingForm.trainingLocation" />
        </el-form-item>
        <el-form-item label="起止日期" required>
          <el-date-picker v-model="trainingForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="trainingForm.description" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="trainingDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleTrainingSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 挂职 -->
    <el-dialog :title="editId.secondment ? '编辑挂职记录' : '新增挂职记录'" v-model="secondmentDialog" width="560px" destroy-on-close>
      <el-form :model="secondmentForm" label-width="90px">
        <el-form-item label="挂职干部" required>
          <el-select v-model="secondmentForm.cadreId" filterable style="width:100%" placeholder="请选择干部">
            <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="挂职单位" required>
          <el-input v-model="secondmentForm.secondmentUnit" />
        </el-form-item>
        <el-form-item label="挂任职务" required>
          <el-input v-model="secondmentForm.secondmentPosition" />
        </el-form-item>
        <el-form-item label="起止日期" required>
          <el-date-picker v-model="secondmentForm.dateRange" type="daterange" range-separator="至" start-placeholder="开始" end-placeholder="结束" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="secondmentForm.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="secondmentDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSecondmentSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 自助申报 -->
    <el-dialog title="新增自助申报" v-model="declareDialog" width="600px" destroy-on-close>
      <el-form :model="declareForm" label-width="90px">
        <el-form-item label="申报类型" required>
          <el-select v-model="declareForm.applicationType" style="width:100%">
            <el-option label="信息修改" value="INFO_UPDATE" />
            <el-option label="请假" value="LEAVE" />
            <el-option label="兼职" value="PART_TIME" />
            <el-option label="培训" value="TRAINING" />
            <el-option label="出国(境)" value="ABROAD" />
          </el-select>
        </el-form-item>
        <el-form-item label="申报标题" required>
          <el-input v-model="declareForm.applicationTitle" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="申报内容" required>
          <el-input v-model="declareForm.applicationContent" type="textarea" :rows="4" placeholder="请输入具体申报事项说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="declareDialog = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleDeclareSubmitNew">保存并提交</el-button>
      </template>
    </el-dialog>

    <!-- 申报详情 -->
    <el-dialog title="申报详情" v-model="declareViewDialog" width="600px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="申报人">{{ declareViewRow ? userName(declareViewRow.applicantId) : '' }}</el-descriptions-item>
        <el-descriptions-item label="申报类型">{{ declareViewRow?.applicationType }}</el-descriptions-item>
        <el-descriptions-item label="申报标题">{{ declareViewRow?.applicationTitle }}</el-descriptions-item>
        <el-descriptions-item label="申报内容">{{ declareViewRow?.applicationContent }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ applyStatusText(declareViewRow?.applyStatus) }}</el-descriptions-item>
        <el-descriptions-item label="审批意见">{{ declareViewRow?.approveComment || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 审批 -->
    <el-dialog title="审批" v-model="approveDialog" width="520px">
      <el-form :model="approveForm" label-width="90px">
        <el-form-item label="申请人">{{ approveForm.name }}</el-form-item>
        <el-form-item label="事项">{{ approveForm.item }}</el-form-item>
        <el-form-item label="审批意见">
          <el-input v-model="approveForm.opinion" type="textarea" :rows="3" placeholder="请输入审批意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="approveDialog = false">取消</el-button>
        <el-button type="danger" :loading="saving" @click="handleReject">驳回</el-button>
        <el-button type="primary" :loading="saving" @click="handleApprove">通过</el-button>
      </template>
    </el-dialog>

    <!-- 学员管理 -->
    <el-dialog :title="(currentTraining?.trainingName || '') + ' - 学员管理'" v-model="studentDialog" width="680px">
      <div style="margin-bottom:10px">
        <el-select v-model="studentForm.cadreId" filterable placeholder="选择干部添加为学员" style="width:280px">
          <el-option v-for="c in cadreOptions" :key="c.id" :label="c.name" :value="c.id" />
        </el-select>
        <el-button type="primary" style="margin-left:8px" :loading="saving" @click="handleAddStudent"><el-icon><Plus /></el-icon> 添加学员</el-button>
      </div>
      <el-table :data="studentList" border size="small" v-loading="studentLoading">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column label="姓名" width="100" align="center">
          <template #default="{ row }">{{ cadreName(row.cadreId) }}</template>
        </el-table-column>
        <el-table-column label="是否完成" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isCompleted === 1 ? 'success' : 'info'" size="small">{{ row.isCompleted === 1 ? '已完成' : '未完成' }}</el-tag>
          </template>
        </el-table-column>
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
import { ref, reactive, computed, onMounted } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { showExportDialog } from '@/utils/export-store'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCadrePage } from '@/api/cadre'
import {
  getCertificatePage, addCertificate, updateCertificate, deleteCertificate,
  getAbroadPage, addAbroad, updateAbroad, deleteAbroad,
  getLeavePage, addLeave, updateLeave, deleteLeave,
  getTrainingPage, addTraining, updateTraining, deleteTraining,
  getTrainingCadreList, addTrainingCadre, deleteTrainingCadre,
  getSecondmentPage, addSecondment, updateSecondment, deleteSecondment,
  getSelfApplicationPage, addSelfApplication, deleteSelfApplication,
  submitSelfApplication, approveSelfApplication, rejectSelfApplication,
  getUserProfile
} from '@/api/daily'

const activeTab = ref('certificate')
const saving = ref(false)

// ================= 公共数据 =================
const cadreOptions = ref([])
const userOptions = ref([])
const profile = ref(null)
const cadreMap = computed(() => Object.fromEntries(cadreOptions.value.map(c => [c.id, c.name])))
const userMap = computed(() => Object.fromEntries(userOptions.value.map(u => [u.id, u.realName])))
function cadreName(id) { return cadreMap.value[id] || `#${id}` }
function userName(id) { return userMap.value[id] || `#${id}` }
function applyStatusText(s) {
  return { DRAFT: '草稿', SUBMITTED: '待审批', APPROVED: '已通过', REJECTED: '已驳回' }[s] || s
}

const editId = reactive({ cert: null, abroad: null, leave: null, training: null, secondment: null })

const search = reactive({
  cert: { name: '', type: '' },
  overseas: { name: '' },
  leave: { name: '', status: '' },
  training: { name: '', type: '' },
  secondment: { name: '' }
})

// ================= 证照管理 =================
const certLoading = ref(false)
const certData = ref([])
const certDialog = ref(false)
const certForm = reactive({ cadreId: null, certType: '', certNumber: '', remark: '' })

async function loadCert() {
  certLoading.value = true
  try {
    const res = await getCertificatePage({ current: 1, size: 500 })
    certData.value = res.data.records || []
  } finally { certLoading.value = false }
}

const filteredCertData = computed(() => certData.value.filter(d =>
  (!search.cert.name || (cadreName(d.cadreId) || '').includes(search.cert.name)) &&
  (!search.cert.type || d.certType === search.cert.type)))

function openCertDialog(row) {
  editId.cert = row ? row.id : null
  certForm.cadreId = row?.cadreId ?? null
  certForm.certType = row?.certType || ''
  certForm.certNumber = row?.certNumber || ''
  certForm.remark = row?.remark || ''
  certDialog.value = true
}

async function handleCertSubmit() {
  saving.value = true
  try {
    if (editId.cert) {
      await updateCertificate({ id: editId.cert, ...certForm })
      ElMessage.success('证照登记已更新')
    } else {
      await addCertificate({ ...certForm, certStatus: '在库' })
      ElMessage.success('证照登记成功')
    }
    certDialog.value = false
    loadCert()
  } finally { saving.value = false }
}

async function handleCertLend(row) {
  await updateCertificate({ ...row, certStatus: '在借', borrowDate: today() })
  ElMessage.success('已登记借出')
  loadCert()
}

async function handleCertReturn(row) {
  await updateCertificate({ ...row, certStatus: '已归还', returnDate: today() })
  ElMessage.success('已登记归还')
  loadCert()
}

function handleCertDelete(row) {
  ElMessageBox.confirm('确定删除该证照记录吗？', '提示', { type: 'warning' }).then(async () => {
    await deleteCertificate(row.id)
    ElMessage.success('删除成功')
    loadCert()
  }).catch(() => {})
}

function exportCert() {
  showExportDialog(filteredCertData.value, [
    { prop: 'cadreName', label: '持证人' }, { prop: 'certType', label: '证照类型' },
    { prop: 'certNumber', label: '证照号码' }, { prop: 'certStatus', label: '状态' },
    { prop: 'borrowDate', label: '借出日期' }, { prop: 'expectedReturnDate', label: '应还日期' },
    { prop: 'returnDate', label: '归还日期' }, { prop: 'remark', label: '备注' }
  ], '证照管理')
}

// ================= 出境记录 =================
const abroadLoading = ref(false)
const abroadData = ref([])
const abroadDialog = ref(false)
const abroadForm = reactive({ cadreId: null, destination: '', purpose: '', dateRange: [], approvedDays: 7 })

async function loadAbroad() {
  abroadLoading.value = true
  try {
    const res = await getAbroadPage({ current: 1, size: 500 })
    abroadData.value = res.data.records || []
  } finally { abroadLoading.value = false }
}

const filteredAbroadData = computed(() => abroadData.value.filter(d =>
  !search.overseas.name || (cadreName(d.cadreId) || '').includes(search.overseas.name)))

function openAbroadDialog(row) {
  editId.abroad = row ? row.id : null
  abroadForm.cadreId = row?.cadreId ?? null
  abroadForm.destination = row?.destination || ''
  abroadForm.purpose = row?.purpose || ''
  abroadForm.dateRange = row ? [row.departDate, row.returnDate] : []
  abroadForm.approvedDays = row?.approvedDays ?? 7
  abroadDialog.value = true
}

async function handleAbroadSubmit() {
  if (!abroadForm.cadreId) return ElMessage.warning('请选择干部')
  if (!abroadForm.destination) return ElMessage.warning('请输入目的地')
  if (!abroadForm.dateRange || abroadForm.dateRange.length !== 2) return ElMessage.warning('请选择起止日期')
  saving.value = true
  try {
    const payload = {
      cadreId: abroadForm.cadreId,
      destination: abroadForm.destination,
      purpose: abroadForm.purpose,
      departDate: abroadForm.dateRange[0],
      returnDate: abroadForm.dateRange[1],
      approvedDays: abroadForm.approvedDays
    }
    if (editId.abroad) {
      await updateAbroad({ id: editId.abroad, ...payload })
      ElMessage.success('出境记录已更新')
    } else {
      await addAbroad(payload)
      ElMessage.success('出境记录已登记')
    }
    abroadDialog.value = false
    loadAbroad()
  } finally { saving.value = false }
}

function handleAbroadDelete(row) {
  ElMessageBox.confirm('确定删除该出境记录吗？', '提示', { type: 'warning' }).then(async () => {
    await deleteAbroad(row.id)
    ElMessage.success('删除成功')
    loadAbroad()
  }).catch(() => {})
}

function exportOverseas() {
  showExportDialog(filteredAbroadData.value, [
    { prop: 'cadreName', label: '姓名' }, { prop: 'destination', label: '目的地' },
    { prop: 'purpose', label: '出境事由' }, { prop: 'departDate', label: '出境日期' },
    { prop: 'returnDate', label: '回国日期' }, { prop: 'approvedDays', label: '批准天数' },
    { prop: 'actualDays', label: '实际天数' }, { prop: 'isOverdue', label: '是否超期(1是0否)' }
  ], '出境记录')
}

// ================= 休假管理 =================
const leaveLoading = ref(false)
const leaveData = ref([])
const leaveDialog = ref(false)
const leaveForm = reactive({ cadreId: null, leaveType: '', dateRange: [], reason: '' })

async function loadLeave() {
  leaveLoading.value = true
  try {
    const res = await getLeavePage({ current: 1, size: 500 })
    leaveData.value = res.data.records || []
  } finally { leaveLoading.value = false }
}

const filteredLeaveData = computed(() => leaveData.value.filter(d =>
  (!search.leave.name || (cadreName(d.cadreId) || '').includes(search.leave.name)) &&
  (!search.leave.status || d.approveStatus === search.leave.status)))

function openLeaveDialog(row) {
  editId.leave = row ? row.id : null
  leaveForm.cadreId = row?.cadreId ?? null
  leaveForm.leaveType = row?.leaveType || ''
  leaveForm.dateRange = row ? [row.startDate, row.endDate] : []
  leaveForm.reason = row?.reason || ''
  leaveDialog.value = true
}

async function handleLeaveSubmit() {
  if (!leaveForm.cadreId) return ElMessage.warning('请选择申请人')
  if (!leaveForm.leaveType) return ElMessage.warning('请选择休假类型')
  if (!leaveForm.dateRange || leaveForm.dateRange.length !== 2) return ElMessage.warning('请选择起止日期')
  if (!leaveForm.reason) return ElMessage.warning('请填写事由')
  saving.value = true
  try {
    const payload = {
      cadreId: leaveForm.cadreId,
      leaveType: leaveForm.leaveType,
      startDate: leaveForm.dateRange[0],
      endDate: leaveForm.dateRange[1],
      reason: leaveForm.reason
    }
    if (editId.leave) {
      await updateLeave({ id: editId.leave, ...payload })
      ElMessage.success('休假申请已更新')
    } else {
      await addLeave(payload)
      ElMessage.success('休假申请已提交，等待审批')
    }
    leaveDialog.value = false
    loadLeave()
  } finally { saving.value = false }
}

function handleLeaveDelete(row) {
  ElMessageBox.confirm('确定删除该休假记录吗？', '提示', { type: 'warning' }).then(async () => {
    await deleteLeave(row.id)
    ElMessage.success('删除成功')
    loadLeave()
  }).catch(() => {})
}

function exportLeave() {
  showExportDialog(filteredLeaveData.value, [
    { prop: 'cadreName', label: '申请人' }, { prop: 'leaveType', label: '休假类型' },
    { prop: 'startDate', label: '开始日期' }, { prop: 'endDate', label: '结束日期' },
    { prop: 'leaveDays', label: '天数' }, { prop: 'reason', label: '事由' },
    { prop: 'approveStatus', label: '状态' }
  ], '休假管理')
}

// ================= 审批（休假/自助申报） =================
const approveDialog = ref(false)
const approveForm = reactive({ kind: 'leave', id: null, name: '', item: '', opinion: '' })

function openApprove(row, kind) {
  approveForm.kind = kind
  approveForm.id = row.id
  approveForm.opinion = ''
  if (kind === 'leave') {
    approveForm.name = cadreName(row.cadreId)
    approveForm.item = `${row.leaveType}（${row.startDate} ~ ${row.endDate}）`
  } else {
    approveForm.name = userName(row.applicantId)
    approveForm.item = `${row.applicationType} - ${row.applicationTitle}`
  }
  approveDialog.value = true
}

async function handleApprove() {
  saving.value = true
  try {
    if (approveForm.kind === 'leave') {
      const row = leaveData.value.find(d => d.id === approveForm.id)
      await updateLeave({ ...row, approveStatus: '已批准' })
    } else {
      await approveSelfApplication(approveForm.id, { approverId: profile.value?.id, comment: approveForm.opinion })
    }
    ElMessage.success('审批通过')
    approveDialog.value = false
    approveForm.kind === 'leave' ? loadLeave() : loadDeclare()
  } finally { saving.value = false }
}

async function handleReject() {
  saving.value = true
  try {
    if (approveForm.kind === 'leave') {
      const row = leaveData.value.find(d => d.id === approveForm.id)
      await updateLeave({ ...row, approveStatus: '已驳回' })
    } else {
      await rejectSelfApplication(approveForm.id, { approverId: profile.value?.id, comment: approveForm.opinion })
    }
    ElMessage.success('已驳回')
    approveDialog.value = false
    approveForm.kind === 'leave' ? loadLeave() : loadDeclare()
  } finally { saving.value = false }
}

// ================= 教育培训 =================
const trainingLoading = ref(false)
const trainingData = ref([])
const trainingDialog = ref(false)
const trainingForm = reactive({
  trainingName: '', trainingType: '', organizer: '', trainingLocation: '', dateRange: [], description: ''
})
const trainingCadreCounts = ref({})
const studentDialog = ref(false)
const studentLoading = ref(false)
const studentList = ref([])
const currentTraining = ref(null)
const studentForm = reactive({ cadreId: null })

async function loadTraining() {
  trainingLoading.value = true
  try {
    const res = await getTrainingPage({ current: 1, size: 500 })
    trainingData.value = res.data.records || []
    // 参训人数
    const counts = {}
    await Promise.all(trainingData.value.map(async (t) => {
      try {
        const r = await getTrainingCadreList({ trainingId: t.id })
        counts[t.id] = (r.data || []).length
      } catch { counts[t.id] = 0 }
    }))
    trainingCadreCounts.value = counts
  } finally { trainingLoading.value = false }
}

const filteredTrainingData = computed(() => trainingData.value.filter(d =>
  (!search.training.name || (d.trainingName || '').includes(search.training.name)) &&
  (!search.training.type || d.trainingType === search.training.type)))

function openTrainingDialog(row) {
  editId.training = row ? row.id : null
  trainingForm.trainingName = row?.trainingName || ''
  trainingForm.trainingType = row?.trainingType || ''
  trainingForm.organizer = row?.organizer || ''
  trainingForm.trainingLocation = row?.trainingLocation || ''
  trainingForm.dateRange = row ? [row.startDate, row.endDate] : []
  trainingForm.description = row?.description || ''
  trainingDialog.value = true
}

async function handleTrainingSubmit() {
  if (!trainingForm.trainingName) return ElMessage.warning('请填写培训名称')
  if (!trainingForm.trainingType) return ElMessage.warning('请选择培训类型')
  if (!trainingForm.organizer) return ElMessage.warning('请填写主办单位')
  if (!trainingForm.dateRange || trainingForm.dateRange.length !== 2) return ElMessage.warning('请选择起止日期')
  saving.value = true
  try {
    const payload = {
      trainingName: trainingForm.trainingName,
      trainingType: trainingForm.trainingType,
      organizer: trainingForm.organizer,
      trainingLocation: trainingForm.trainingLocation,
      startDate: trainingForm.dateRange[0],
      endDate: trainingForm.dateRange[1],
      description: trainingForm.description
    }
    if (editId.training) {
      await updateTraining({ id: editId.training, ...payload })
      ElMessage.success('培训已更新')
    } else {
      await addTraining(payload)
      ElMessage.success('培训创建成功')
    }
    trainingDialog.value = false
    loadTraining()
  } finally { saving.value = false }
}

function handleTrainingDelete(row) {
  ElMessageBox.confirm('确定删除该培训计划吗？', '提示', { type: 'warning' }).then(async () => {
    await deleteTraining(row.id)
    ElMessage.success('删除成功')
    loadTraining()
  }).catch(() => {})
}

async function openStudents(row) {
  currentTraining.value = row
  studentForm.cadreId = null
  studentDialog.value = true
  studentLoading.value = true
  try {
    const res = await getTrainingCadreList({ trainingId: row.id })
    studentList.value = res.data || []
  } finally { studentLoading.value = false }
}

async function handleAddStudent() {
  if (!studentForm.cadreId) return ElMessage.warning('请选择干部')
  saving.value = true
  try {
    await addTrainingCadre({ trainingId: currentTraining.value.id, cadreId: studentForm.cadreId })
    ElMessage.success('学员添加成功')
    studentForm.cadreId = null
    await openStudents(currentTraining.value)
    loadTraining()
  } finally { saving.value = false }
}

async function handleStudentRemove(row) {
  await deleteTrainingCadre(row.id)
  ElMessage.success('已移除学员')
  await openStudents(currentTraining.value)
  loadTraining()
}

function exportTraining() {
  showExportDialog(filteredTrainingData.value, [
    { prop: 'trainingName', label: '培训名称' }, { prop: 'trainingType', label: '培训类型' },
    { prop: 'organizer', label: '主办单位' }, { prop: 'startDate', label: '开始日期' },
    { prop: 'endDate', label: '结束日期' }, { prop: 'status', label: '状态' }
  ], '教育培训')
}

// ================= 挂职锻炼 =================
const secondmentLoading = ref(false)
const secondmentData = ref([])
const secondmentDialog = ref(false)
const secondmentForm = reactive({ cadreId: null, secondmentUnit: '', secondmentPosition: '', dateRange: [], remark: '' })

async function loadSecondment() {
  secondmentLoading.value = true
  try {
    const res = await getSecondmentPage({ current: 1, size: 500 })
    secondmentData.value = res.data.records || []
  } finally { secondmentLoading.value = false }
}

const filteredSecondmentData = computed(() => secondmentData.value.filter(d =>
  !search.secondment.name || (cadreName(d.cadreId) || '').includes(search.secondment.name)))

function openSecondmentDialog(row) {
  editId.secondment = row ? row.id : null
  secondmentForm.cadreId = row?.cadreId ?? null
  secondmentForm.secondmentUnit = row?.secondmentUnit || ''
  secondmentForm.secondmentPosition = row?.secondmentPosition || ''
  secondmentForm.dateRange = row ? [row.startDate, row.endDate] : []
  secondmentForm.remark = row?.remark || ''
  secondmentDialog.value = true
}

async function handleSecondmentSubmit() {
  if (!secondmentForm.cadreId) return ElMessage.warning('请选择挂职干部')
  if (!secondmentForm.secondmentUnit) return ElMessage.warning('请填写挂职单位')
  if (!secondmentForm.secondmentPosition) return ElMessage.warning('请填写挂任职务')
  if (!secondmentForm.dateRange || secondmentForm.dateRange.length !== 2) return ElMessage.warning('请选择起止日期')
  saving.value = true
  try {
    const payload = {
      cadreId: secondmentForm.cadreId,
      secondmentUnit: secondmentForm.secondmentUnit,
      secondmentPosition: secondmentForm.secondmentPosition,
      startDate: secondmentForm.dateRange[0],
      endDate: secondmentForm.dateRange[1],
      remark: secondmentForm.remark
    }
    if (editId.secondment) {
      await updateSecondment({ id: editId.secondment, ...payload })
      ElMessage.success('挂职记录已更新')
    } else {
      await addSecondment(payload)
      ElMessage.success('挂职记录已登记')
    }
    secondmentDialog.value = false
    loadSecondment()
  } finally { saving.value = false }
}

function handleSecondmentDelete(row) {
  ElMessageBox.confirm('确定删除该挂职记录吗？', '提示', { type: 'warning' }).then(async () => {
    await deleteSecondment(row.id)
    ElMessage.success('删除成功')
    loadSecondment()
  }).catch(() => {})
}

function exportSecondment() {
  showExportDialog(filteredSecondmentData.value, [
    { prop: 'cadreName', label: '姓名' }, { prop: 'secondmentUnit', label: '挂职单位' },
    { prop: 'secondmentPosition', label: '挂任职务' }, { prop: 'startDate', label: '开始日期' },
    { prop: 'endDate', label: '结束日期' }, { prop: 'status', label: '状态' }, { prop: 'remark', label: '备注' }
  ], '挂职锻炼')
}

// ================= 自助申报 =================
const declareLoading = ref(false)
const declareData = ref([])
const declareDialog = ref(false)
const declareViewDialog = ref(false)
const declareViewRow = ref(null)
const declareForm = reactive({ applicationType: '', applicationTitle: '', applicationContent: '' })

async function loadDeclare() {
  declareLoading.value = true
  try {
    const res = await getSelfApplicationPage({ current: 1, size: 500 })
    declareData.value = res.data.records || []
  } finally { declareLoading.value = false }
}

function openDeclareDialog() {
  if (profile.value && !profile.value.cadreId) {
    ElMessage.warning('当前账号未绑定干部档案，无法自助申报')
    return
  }
  declareForm.applicationType = ''
  declareForm.applicationTitle = ''
  declareForm.applicationContent = ''
  declareDialog.value = true
}

async function handleDeclareSubmitNew() {
  if (!declareForm.applicationType) return ElMessage.warning('请选择申报类型')
  if (!declareForm.applicationTitle) return ElMessage.warning('请填写申报标题')
  if (!declareForm.applicationContent) return ElMessage.warning('请填写申报内容')
  saving.value = true
  try {
    const res = await addSelfApplication({ ...declareForm })
    const id = res.data
    if (id) {
      await submitSelfApplication(id)
    }
    ElMessage.success('申报已提交，等待审批')
    declareDialog.value = false
    loadDeclare()
  } finally { saving.value = false }
}

async function handleDeclareSubmit(row) {
  await submitSelfApplication(row.id)
  ElMessage.success('申报已提交')
  loadDeclare()
}

function handleDeclareView(row) {
  declareViewRow.value = row
  declareViewDialog.value = true
}

function handleDeclareDelete(row) {
  ElMessageBox.confirm('确定删除该申报吗？', '提示', { type: 'warning' }).then(async () => {
    await deleteSelfApplication(row.id)
    ElMessage.success('删除成功')
    loadDeclare()
  }).catch(() => {})
}

function exportDeclare() {
  showExportDialog(declareData.value.map(d => ({ ...d, applicantName: userName(d.applicantId), statusText: applyStatusText(d.applyStatus) })), [
    { prop: 'applicantName', label: '申报人' }, { prop: 'applicationType', label: '申报类型' },
    { prop: 'applicationTitle', label: '申报标题' }, { prop: 'createTime', label: '提交时间' },
    { prop: 'statusText', label: '状态' }
  ], '自助申报')
}

// ================= 工具 =================
function today() {
  return new Date().toISOString().slice(0, 10)
}

// ================= 初始化 =================
onMounted(async () => {
  loadCert()
  loadAbroad()
  loadLeave()
  loadTraining()
  loadSecondment()
  loadDeclare()
  try {
    const res = await getCadrePage({ current: 1, size: 500 })
    cadreOptions.value = res.data.records || []
  } catch { cadreOptions.value = [] }
  try {
    const p = await getUserProfile()
    profile.value = p.data
  } catch { profile.value = null }
})
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
