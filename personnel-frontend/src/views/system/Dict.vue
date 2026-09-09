<template>
  <div>
    <div class="page-header">数据字典管理</div>

    <el-row :gutter="12">
      <el-col :span="8">
        <div class="dict-type-panel">
          <div class="dict-header">
            <span>字典类型</span>
            <el-button type="primary" text @click="openTypeDialog(null)"><el-icon><Plus /></el-icon> 新增</el-button>
          </div>
          <div class="dict-type-list" v-loading="typeLoading">
            <div v-if="dictTypes.length === 0" style="padding:30px 10px;text-align:center;color:#999;font-size:12px">
              暂无字典类型<br />（后端 sys_dict_type 无数据，可通过「新增」创建真实字典类型）
            </div>
            <div
              v-for="item in dictTypes"
              :key="item.id"
              class="dict-type-item"
              :class="{ active: activeType === item.typeCode }"
              @click="selectType(item.typeCode)"
            >
              <div class="type-name">{{ item.typeName }}</div>
              <div class="type-code">{{ item.typeCode }}</div>
            </div>
          </div>
        </div>
      </el-col>

      <el-col :span="16">
        <div class="dict-data-panel">
          <div class="dict-header">
            <span>字典数据 - {{ currentTypeName }}</span>
            <div>
              <el-button type="primary" :disabled="!activeType" @click="openItemDialog(null)"><el-icon><Plus /></el-icon> 新增字典项</el-button>
              <el-button type="primary" plain :loading="dataLoading" @click="loadDictData" :disabled="!activeType">刷新</el-button>
            </div>
          </div>
          <el-table v-loading="dataLoading" :data="dictData" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="dictLabel" label="标签" min-width="130" show-overflow-tooltip sortable />
            <el-table-column prop="dictValue" label="键值" min-width="100" align="center" sortable />
            <el-table-column prop="sortOrder" label="排序" width="80" align="center" sortable />
            <el-table-column label="状态" width="90" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="130" align="center">
              <template #default="{ row }">
                <span class="link-blue" @click="openItemDialog(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleItemDelete(row)">删除</span>
              </template>
            </el-table-column>
            <template #empty>
              <span v-if="!activeType" style="color:#999">请先在左侧选择字典类型</span>
              <span v-else style="color:#999">该字典类型下暂无字典数据</span>
            </template>
          </el-table>
          <p style="font-size:12px;color:#999;padding:0 14px;margin:8px 0 0">
            数据来源：系统字典（/api/dict-type、/api/dict-data），新增/编辑/删除均写入真实字典表。
          </p>
        </div>
      </el-col>
    </el-row>

    <!-- 字典类型弹窗 -->
    <el-dialog :title="typeDialog.id ? '编辑字典类型' : '新增字典类型'" v-model="typeDialog.visible" width="480px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="类型名称" required>
          <el-input v-model="typeDialog.form.typeName" placeholder="如：政治面貌" maxlength="64" />
        </el-form-item>
        <el-form-item label="类型编码" required>
          <el-input v-model="typeDialog.form.typeCode" placeholder="如：political_status（唯一）" maxlength="64" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="typeDialog.form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="typeDialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitType">保存</el-button>
      </template>
    </el-dialog>

    <!-- 字典项弹窗 -->
    <el-dialog :title="itemDialog.id ? '编辑字典项' : '新增字典项'" v-model="itemDialog.visible" width="480px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="所属类型">
          <el-input :value="currentTypeName + '（' + activeType + '）'" disabled />
        </el-form-item>
        <el-form-item label="字典标签" required>
          <el-input v-model="itemDialog.form.dictLabel" placeholder="如：中共党员" maxlength="128" />
        </el-form-item>
        <el-form-item label="字典键值" required>
          <el-input v-model="itemDialog.form.dictValue" placeholder="如：1" maxlength="128" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="itemDialog.form.sortOrder" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="itemDialog.form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="itemDialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitItem">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const typeLoading = ref(false)
const dataLoading = ref(false)
const saving = ref(false)
const dictTypes = ref([])
const dictData = ref([])
const activeType = ref('')

const typeDialog = reactive({ visible: false, id: null, form: { typeName: '', typeCode: '', status: 1 } })
const itemDialog = reactive({ visible: false, id: null, form: { dictLabel: '', dictValue: '', sortOrder: 0, status: 1 } })

const currentTypeName = computed(() => {
  const t = dictTypes.value.find(d => d.typeCode === activeType.value)
  return t ? t.typeName : ''
})

async function loadTypes() {
  typeLoading.value = true
  try {
    const res = await request({ url: '/dict-type/list', method: 'get' })
    dictTypes.value = res.data || []
    if (!dictTypes.value.find(d => d.typeCode === activeType.value)) {
      activeType.value = dictTypes.value.length ? dictTypes.value[0].typeCode : ''
    }
    if (activeType.value) loadDictData()
  } catch (e) { dictTypes.value = [] } finally { typeLoading.value = false }
}

async function loadDictData() {
  if (!activeType.value) {
    dictData.value = []
    return
  }
  dataLoading.value = true
  try {
    const res = await request({ url: '/dict-data/list', method: 'get', params: { typeCode: activeType.value } })
    dictData.value = res.data || []
  } catch (e) { dictData.value = [] } finally { dataLoading.value = false }
}

function selectType(code) {
  activeType.value = code
  loadDictData()
}

function openTypeDialog(row) {
  typeDialog.id = row ? row.id : null
  typeDialog.form = row
    ? { typeName: row.typeName || '', typeCode: row.typeCode || '', status: row.status ?? 1 }
    : { typeName: '', typeCode: '', status: 1 }
  typeDialog.visible = true
}

async function submitType() {
  const f = typeDialog.form
  if (!f.typeName.trim()) return ElMessage.warning('请输入类型名称')
  if (!f.typeCode.trim()) return ElMessage.warning('请输入类型编码')
  saving.value = true
  try {
    if (typeDialog.id) {
      await request({ url: '/dict-type', method: 'put', data: { id: typeDialog.id, ...f } })
      ElMessage.success('字典类型已更新')
    } else {
      await request({ url: '/dict-type', method: 'post', data: { ...f } })
      ElMessage.success('字典类型创建成功')
    }
    typeDialog.visible = false
    loadTypes()
  } catch (e) { /* 业务错误已由拦截器提示 */ } finally { saving.value = false }
}

function openItemDialog(row) {
  if (!row && !activeType.value) return ElMessage.warning('请先在左侧选择字典类型')
  itemDialog.id = row ? row.id : null
  itemDialog.form = row
    ? { dictLabel: row.dictLabel || '', dictValue: row.dictValue || '', sortOrder: row.sortOrder ?? 0, status: row.status ?? 1 }
    : { dictLabel: '', dictValue: '', sortOrder: 0, status: 1 }
  itemDialog.visible = true
}

async function submitItem() {
  const f = itemDialog.form
  if (!activeType.value) return ElMessage.warning('请先选择字典类型')
  if (!f.dictLabel.trim()) return ElMessage.warning('请输入字典标签')
  if (!f.dictValue.trim()) return ElMessage.warning('请输入字典键值')
  saving.value = true
  try {
    const payload = { typeCode: activeType.value, dictLabel: f.dictLabel, dictValue: f.dictValue, sortOrder: f.sortOrder ?? 0, status: f.status ?? 1 }
    if (itemDialog.id) {
      await request({ url: '/dict-data', method: 'put', data: { id: itemDialog.id, ...payload } })
      ElMessage.success('字典项已更新')
    } else {
      await request({ url: '/dict-data', method: 'post', data: { ...payload } })
      ElMessage.success('字典项创建成功')
    }
    itemDialog.visible = false
    loadDictData()
  } catch (e) { /* 业务错误已由拦截器提示 */ } finally { saving.value = false }
}

function handleItemDelete(row) {
  ElMessageBox.confirm(`确定删除字典项「${row.dictLabel}」吗？`, '提示', { type: 'warning' })
    .then(async () => {
      await request({ url: `/dict-data/${row.id}`, method: 'delete' })
      ElMessage.success('删除成功')
      loadDictData()
    }).catch(() => {})
}

onMounted(loadTypes)
</script>

<style scoped>
.dict-type-panel,
.dict-data-panel {
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 2px;
}
.dict-header {
  padding: 10px 14px;
  font-size: 14px;
  font-weight: bold;
  color: #1976D2;
  border-bottom: 2px solid #1976D2;
  background: #fafbfc;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.dict-type-list {
  max-height: calc(100vh - 260px);
  overflow-y: auto;
}
.dict-type-item {
  padding: 12px 14px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
  transition: background 0.2s;
}
.dict-type-item:hover {
  background: #f5f9ff;
}
.dict-type-item.active {
  background: #E3F2FD;
  border-left: 3px solid #1976D2;
  padding-left: 11px;
}
.type-name {
  font-size: 13px;
  color: #333;
  font-weight: 500;
}
.type-code {
  font-size: 11px;
  color: #999;
  margin-top: 3px;
}
</style>
