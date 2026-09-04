<template>
  <div>
    <div class="page-header">预警规则管理</div>

    <div class="toolbar">
      <el-button type="primary" @click="handleResetDefault"><el-icon><RefreshLeft /></el-icon> 恢复默认配置</el-button>
    </div>

    <div class="table-wrap">
      <el-table :data="tableData" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="name" label="规则名称" width="140" align="center" />
        <el-table-column label="预警级别" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="levelType(row.level)" size="small">{{ row.level }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="预警阈值" width="150" align="center">
          <template #default="{ row }">
            <span v-if="row.thresholdLabel !== '—'">{{ row.thresholdLabel.replace('N', row.threshold) }}</span>
            <span v-else>—</span>
          </template>
        </el-table-column>
        <el-table-column prop="desc" label="规则说明" min-width="280" show-overflow-tooltip />
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.enabled ? 'success' : 'info'" size="small">{{ row.enabled ? '启用' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="handleEdit(row)">编辑</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" title="编辑预警规则" width="520px" align-center destroy-on-close>
      <el-form :model="form" label-width="110px">
        <el-form-item label="规则名称">
          <el-input :model-value="form.name" disabled />
        </el-form-item>
        <el-form-item label="预警级别">
          <el-select v-model="form.level" style="width:100%">
            <el-option label="红色" value="红色" />
            <el-option label="黄色" value="黄色" />
            <el-option label="蓝色" value="蓝色" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.thresholdLabel !== '—'" :label="form.thresholdLabel">
          <el-input-number v-model="form.threshold" :min="1" :max="60" style="width:100%" />
        </el-form-item>
        <el-form-item label="是否启用">
          <el-switch v-model="form.enabled" active-text="启用" inactive-text="停用" />
        </el-form-item>
        <el-form-item label="规则说明">
          <div style="color:#666;font-size:12px;line-height:1.6">{{ form.desc }}</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { RefreshLeft } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getRuleConfig, saveRuleConfig, RULE_DEFAULTS } from '@/utils/alert-service'

const dialogVisible = ref(false)
const editKey = ref('')

const form = reactive({ name: '', level: '黄色', enabled: true, threshold: 1, thresholdLabel: '', desc: '' })

const config = ref(getRuleConfig())

const tableData = computed(() => Object.keys(config.value).map(key => ({
  key,
  ...config.value[key]
})))

function levelType(level) {
  return level === '红色' ? 'danger' : level === '黄色' ? 'warning' : ''
}

function handleEdit(row) {
  editKey.value = row.key
  Object.assign(form, {
    name: row.name,
    level: row.level,
    enabled: row.enabled,
    threshold: row.threshold || 1,
    thresholdLabel: row.thresholdLabel,
    desc: row.desc
  })
  dialogVisible.value = true
}

function handleSave() {
  config.value[editKey.value] = {
    ...config.value[editKey.value],
    level: form.level,
    enabled: form.enabled,
    threshold: form.thresholdLabel !== '—' ? form.threshold : 0
  }
  saveRuleConfig(config.value)
  dialogVisible.value = false
  ElMessage.success('规则配置已保存，智能预警将按新规则生效')
}

function handleResetDefault() {
  ElMessageBox.confirm('确定恢复全部预警规则的默认配置吗？', '提示', { type: 'warning' }).then(() => {
    config.value = JSON.parse(JSON.stringify(RULE_DEFAULTS))
    saveRuleConfig(config.value)
    ElMessage.success('已恢复默认配置')
  }).catch(() => {})
}
</script>
