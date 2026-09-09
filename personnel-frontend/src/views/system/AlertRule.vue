<template>
  <div>
    <div class="page-header">预警规则管理</div>

    <div class="toolbar">
      <el-button type="primary" @click="openDialog(null)"><el-icon><Plus /></el-icon> 新增规则</el-button>
      <el-button type="primary" plain :loading="loading" @click="loadRules"><el-icon><Refresh /></el-icon> 刷新</el-button>
      <span style="font-size:12px;color:#999">数据来源：预警规则配置（/api/supervise/alert-rule）。启用状态用开关直接生效，预警生成逻辑将按启用规则与阈值执行。</span>
    </div>

    <div class="table-wrap">
      <el-table v-loading="loading" :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="ruleName" label="规则名称" min-width="140" align="center" show-overflow-tooltip sortable />
        <el-table-column label="预警类型" width="120" align="center">
          <template #default="{ row }">
            <el-tag size="small" type="primary" effect="plain">{{ row.ruleType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="预警级别" width="100" align="center">
          <template #default="{ row }">
            <span style="display:inline-block;padding:0 7px;border-radius:3px;font-size:12px;font-weight:600;line-height:20px;white-space:nowrap"
              :style="levelChipStyle(row.level)">{{ row.level }}</span>
          </template>
        </el-table-column>
        <el-table-column label="触发阈值" width="130" align="center">
          <template #default="{ row }">
            <span>{{ row.threshold ?? '-' }}<span v-if="row.threshold !== null && row.threshold !== undefined"> 天</span></span>
          </template>
        </el-table-column>
        <el-table-column label="启用" width="100" align="center">
          <template #default="{ row }">
            <el-switch
              :model-value="Number(row.isEnabled) === 1"
              :active-value="true"
              :inactive-value="false"
              @change="v => handleToggle(row, v)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="240" show-overflow-tooltip />
        <el-table-column label="操作" width="120" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openDialog(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="dialog.id ? '编辑预警规则' : '新增预警规则'" v-model="dialog.visible" width="540px" align-center destroy-on-close>
      <el-form label-width="100px">
        <el-form-item label="规则名称" required>
          <el-input v-model="dialog.form.ruleName" placeholder="请输入规则名称" maxlength="64" />
        </el-form-item>
        <el-form-item label="预警类型" required>
          <el-select
            v-model="dialog.form.ruleType"
            placeholder="请选择或输入预警类型"
            allow-create
            filterable
            default-first-option
            style="width:100%"
          >
            <el-option v-for="t in ruleTypeOptions" :key="t" :label="t" :value="t" />
          </el-select>
        </el-form-item>
        <el-form-item label="预警级别" required>
          <el-select v-model="dialog.form.level" style="width:100%">
            <el-option label="红色" value="红色" />
            <el-option label="橙色" value="橙色" />
            <el-option label="黄色" value="黄色" />
          </el-select>
        </el-form-item>
        <el-form-item label="触发阈值">
          <el-input-number v-model="dialog.form.threshold" :min="0" :max="3650" style="width:100%" />
          <div style="font-size:12px;color:#999;line-height:1.6">单位：天（或数值），用于触发预警判断</div>
        </el-form-item>
        <el-form-item label="是否启用">
          <el-switch v-model="dialog.form.isEnabled" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="dialog.form.remark" type="textarea" :rows="2" maxlength="500" placeholder="请输入备注说明（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Plus, Refresh } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const ruleTypeOptions = ['证件到期', '出国超期', '休假超时', '任职超期', '到龄退休']

const loading = ref(false)
const saving = ref(false)
const tableData = ref([])
const dialog = reactive({
  visible: false,
  id: null,
  form: { ruleName: '', ruleType: '', level: '黄色', threshold: 30, isEnabled: 1, remark: '' }
})

function levelChipStyle(level) {
  const map = {
    '红色': { color: '#B71C1C', bg: '#FFEBEE', border: '#EF9A9A' },
    '橙色': { color: '#BF360C', bg: '#FBE9E7', border: '#FFAB91' },
    '黄色': { color: '#795600', bg: '#FFFDE7', border: '#F9F295' }
  }
  const c = map[level] || { color: '#333', bg: '#F5F5F5', border: '#DDD' }
  return { color: c.color, background: c.bg, border: '1px solid ' + c.border }
}

async function loadRules() {
  loading.value = true
  try {
    const res = await request({ url: '/supervise/alert-rule/list', method: 'get' })
    tableData.value = res.data || []
  } catch { tableData.value = [] } finally { loading.value = false }
}

function openDialog(row) {
  dialog.id = row ? row.id : null
  dialog.form = row
    ? {
        ruleName: row.ruleName || '',
        ruleType: row.ruleType || '',
        level: row.level || '黄色',
        threshold: row.threshold ?? 30,
        isEnabled: Number(row.isEnabled) === 1 ? 1 : 0,
        remark: row.remark || ''
      }
    : { ruleName: '', ruleType: '', level: '黄色', threshold: 30, isEnabled: 1, remark: '' }
  dialog.visible = true
}

async function handleSubmit() {
  const f = dialog.form
  if (!f.ruleName.trim()) return ElMessage.warning('请输入规则名称')
  if (!f.ruleType.trim()) return ElMessage.warning('请选择或输入预警类型')
  if (!f.level) return ElMessage.warning('请选择预警级别')
  saving.value = true
  try {
    const payload = { ...f }
    if (dialog.id) {
      await request({ url: '/supervise/alert-rule', method: 'put', data: { id: dialog.id, ...payload } })
      ElMessage.success('规则已更新')
    } else {
      await request({ url: '/supervise/alert-rule', method: 'post', data: payload })
      ElMessage.success('规则创建成功')
    }
    dialog.visible = false
    loadRules()
  } catch { /* 业务错误已由拦截器提示 */ } finally { saving.value = false }
}

// 表格内开关直接保存启用/停用
async function handleToggle(row, enabled) {
  const val = enabled ? 1 : 0
  try {
    await request({
      url: '/supervise/alert-rule',
      method: 'put',
      data: { id: row.id, ruleName: row.ruleName, ruleType: row.ruleType, level: row.level, threshold: row.threshold, isEnabled: val, remark: row.remark }
    })
    row.isEnabled = val
    ElMessage.success(val === 1 ? '已启用' : '已停用')
  } catch {
    loadRules()
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定删除预警规则「${row.ruleName}」吗？`, '提示', { type: 'warning' })
    .then(async () => {
      await request({ url: `/supervise/alert-rule/${row.id}`, method: 'delete' })
      ElMessage.success('删除成功')
      loadRules()
    }).catch(() => {})
}

onMounted(loadRules)
</script>
