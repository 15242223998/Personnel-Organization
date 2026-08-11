<template>
  <el-dialog v-model="dialogVisible" title="导出文件" width="480px" :close-on-click-modal="false" destroy-on-close
    @closed="handleCancel">
    <div class="export-format-list">
      <div class="format-item" :class="{ selected: selectedFormat === 'xlsx' }" @click="selectedFormat = 'xlsx'">
        <div class="format-icon xlsx-icon">
          <span>XLSX</span>
        </div>
        <div class="format-info">
          <div class="format-name">Excel 工作簿 (.xlsx)</div>
          <div class="format-desc">Office 2007 及以上版本，推荐格式</div>
        </div>
        <el-icon v-if="selectedFormat === 'xlsx'" class="check-icon" color="#1976D2" :size="20"><Check /></el-icon>
      </div>
      <div class="format-item" :class="{ selected: selectedFormat === 'xls' }" @click="selectedFormat = 'xls'">
        <div class="format-icon xls-icon">
          <span>XLS</span>
        </div>
        <div class="format-info">
          <div class="format-name">Excel 97-2003 工作簿 (.xls)</div>
          <div class="format-desc">兼容旧版 Office，列宽可能受限</div>
        </div>
        <el-icon v-if="selectedFormat === 'xls'" class="check-icon" color="#1976D2" :size="20"><Check /></el-icon>
      </div>
      <div class="format-item" :class="{ selected: selectedFormat === 'csv' }" @click="selectedFormat = 'csv'">
        <div class="format-icon csv-icon">
          <span>CSV</span>
        </div>
        <div class="format-info">
          <div class="format-name">CSV 逗号分隔值 (.csv)</div>
          <div class="format-desc">纯文本格式，通用性最强，不含样式</div>
        </div>
        <el-icon v-if="selectedFormat === 'csv'" class="check-icon" color="#1976D2" :size="20"><Check /></el-icon>
      </div>
    </div>
    <div class="export-footer-info">
      <el-icon :size="16"><InfoFilled /></el-icon>
      <span>共导出 <b>{{ totalCount }}</b> 条记录，文件大小约 {{ estimatedSize }}</span>
    </div>
    <template #footer>
      <el-button @click="handleCancel">取消</el-button>
      <el-button type="primary" :loading="exporting" @click="handleConfirm">
        <el-icon><Download /></el-icon> 导出
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { exportDialog } from '@/utils/export-store'
import { Check, InfoFilled, Download } from '@element-plus/icons-vue'
import { exportExcel } from '@/utils/excel'

const dialogVisible = ref(false)
const selectedFormat = ref('xlsx')
const exporting = ref(false)
const totalCount = computed(() => exportDialog.data?.length || 0)

const estimatedSize = computed(() => {
  const c = totalCount.value
  if (c < 100) return '< 10 KB'
  if (c < 1000) return '10-100 KB'
  if (c < 10000) return '100 KB - 1 MB'
  return '> 1 MB'
})

watch(() => exportDialog.visible, (v) => {
  dialogVisible.value = v
  if (v) {
    selectedFormat.value = 'xlsx'
    exporting.value = false
  }
})

function handleConfirm() {
  exporting.value = true
  setTimeout(() => {
    try {
      exportExcel(exportDialog.data, exportDialog.columns, exportDialog.fileName, selectedFormat.value)
    } finally {
      exporting.value = false
      dialogVisible.value = false
      exportDialog.visible = false
      if (exportDialog.resolve) {
        exportDialog.resolve(selectedFormat.value)
        exportDialog.resolve = null
      }
    }
  }, 200)
}

function handleCancel() {
  dialogVisible.value = false
  exportDialog.visible = false
  if (exportDialog.resolve) {
    exportDialog.resolve(null)
    exportDialog.resolve = null
  }
}
</script>

<style scoped>
.export-format-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.format-item {
  display: flex;
  align-items: center;
  padding: 12px 14px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  position: relative;
}
.format-item:hover {
  border-color: #90caf9;
  background: #f5f9ff;
}
.format-item.selected {
  border-color: #1976D2;
  background: #e3f2fd;
}
.format-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  flex-shrink: 0;
}
.xlsx-icon { background: #217346; }
.xls-icon { background: #1e7145; }
.csv-icon { background: #6c757d; }
.format-info {
  margin-left: 14px;
  flex: 1;
}
.format-name {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}
.format-desc {
  font-size: 12px;
  color: #888;
  margin-top: 2px;
}
.check-icon {
  flex-shrink: 0;
}
.export-footer-info {
  margin-top: 16px;
  padding: 10px 14px;
  background: #f5f7fa;
  border-radius: 6px;
  font-size: 13px;
  color: #666;
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>
