<template>
  <div>
    <div class="page-header">政策法规管理</div>

    <div class="search-bar">
      <span class="label">标题：</span>
      <el-input v-model="search.title" placeholder="请输入文档标题" size="default" style="width:220px" clearable />
      <span class="label">分类：</span>
      <el-select v-model="search.category" placeholder="请选择" size="default" style="width:140px" clearable>
        <el-option v-for="c in categoryOptions" :key="c" :label="c" :value="c" />
      </el-select>
      <el-button type="primary" @click="handleSearch"><el-icon><Search /></el-icon> 查询</el-button>
      <el-button @click="resetSearch">重置</el-button>
      <span style="margin-left:12px;font-size:12px;color:#999">数据来源：政策法规库（/api/policy-document）</span>
    </div>

    <div class="toolbar">
      <el-button type="primary" @click="openDialog(null)"><el-icon><Plus /></el-icon> 新增政策文件</el-button>
      <el-button @click="exportList"><el-icon><Download /></el-icon> 导出当前页</el-button>
    </div>

    <div class="table-wrap">
      <el-table v-loading="loading" :data="pagedList" border size="small">
        <el-table-column type="index" label="序号" width="55" align="center" />
        <el-table-column prop="title" label="标题" min-width="240" show-overflow-tooltip sortable />
        <el-table-column prop="docNo" label="文号" min-width="150" align="center" show-overflow-tooltip />
        <el-table-column prop="publishUnit" label="发布单位" min-width="160" align="center" show-overflow-tooltip />
        <el-table-column label="分类" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="categoryTag(row.category)" size="small">{{ row.category || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="发布日期" width="110" align="center">
          <template #default="{ row }">{{ row.issueDate || '-' }}</template>
        </el-table-column>
        <el-table-column label="施行日期" width="110" align="center">
          <template #default="{ row }">{{ row.effectiveDate || '-' }}</template>
        </el-table-column>
        <el-table-column label="附件" min-width="130" show-overflow-tooltip>
          <template #default="{ row }">{{ row.attachmentName || '-' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="190" align="center" fixed="right">
          <template #default="{ row }">
            <span class="link-blue" @click="openView(row)">查看正文</span>
            <el-divider direction="vertical" />
            <span class="link-blue" @click="openDialog(row)">编辑</span>
            <el-divider direction="vertical" />
            <span class="link-blue" style="color:#E53935" @click="handleDelete(row)">删除</span>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="page.current"
          v-model:page-size="page.size"
          :page-sizes="[10, 20, 50]"
          :total="page.total"
          layout="total, sizes, prev, pager, next, jumper"
          background small
          @size-change="page.current = 1"
        />
      </div>
    </div>

    <!-- ============ 正文查看弹窗 ============ -->
    <el-dialog v-model="view.visible" title="政策文件详情" width="760px" align-center destroy-on-close>
      <el-descriptions :column="2" border size="small" v-if="view.row">
        <el-descriptions-item label="标题" :span="2">{{ view.row.title || '-' }}</el-descriptions-item>
        <el-descriptions-item label="文号">{{ view.row.docNo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="发布单位">{{ view.row.publishUnit || '-' }}</el-descriptions-item>
        <el-descriptions-item label="分类">
          <el-tag :type="categoryTag(view.row.category)" size="small">{{ view.row.category || '-' }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="施行日期">{{ view.row.effectiveDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="发布日期">{{ view.row.issueDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="附件" :span="2">
          <template v-if="view.row.attachmentUrl">
            <a :href="view.row.attachmentUrl" target="_blank" rel="noopener" style="color:#1976D2">{{ view.row.attachmentName || '点击下载' }}</a>
          </template>
          <span v-else>{{ view.row.attachmentName || '-' }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="正文" :span="2">
          <div class="doc-content">{{ view.row.content || '-' }}</div>
        </el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="view.visible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- ============ 新增/编辑弹窗 ============ -->
    <el-dialog v-model="dialog.visible" :title="dialog.id ? '编辑政策文件' : '新增政策文件'" width="680px" align-center destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="标题" required>
          <el-input v-model="dialog.form.title" placeholder="请输入文档标题" />
        </el-form-item>
        <el-form-item label="文号">
          <el-input v-model="dialog.form.docNo" placeholder="如：辽工大党发〔2026〕4号" />
        </el-form-item>
        <el-form-item label="分类" required>
          <el-select v-model="dialog.form.category" style="width:100%">
            <el-option v-for="c in categoryOptions" :key="c" :label="c" :value="c" />
          </el-select>
        </el-form-item>
        <el-form-item label="发布单位">
          <el-input v-model="dialog.form.publishUnit" placeholder="如：中共辽宁某某大学委员会" />
        </el-form-item>
        <el-form-item label="发布日期">
          <el-date-picker v-model="dialog.form.issueDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="施行日期">
          <el-date-picker v-model="dialog.form.effectiveDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="附件名称">
          <el-input v-model="dialog.form.attachmentName" placeholder="选填，如：办法全文（示例）.pdf" />
        </el-form-item>
        <el-form-item label="附件地址">
          <el-input v-model="dialog.form.attachmentUrl" placeholder="选填，附件访问地址" />
        </el-form-item>
        <el-form-item label="正文">
          <el-input v-model="dialog.form.content" type="textarea" :rows="10" placeholder="请输入政策文件正文内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { showExportDialog } from '@/utils/export-store'
import { getPolicyDocumentPage, addPolicyDocument, updatePolicyDocument, deletePolicyDocument } from '@/api/system'

const categoryOptions = ['党内法规', '干部选拔', '干部监督', '教育培训', '其他']

function categoryTag(c) {
  if (c === '党内法规') return 'danger'
  if (c === '干部选拔') return 'primary'
  if (c === '干部监督') return 'warning'
  if (c === '教育培训') return 'success'
  return 'info'
}

const loading = ref(false)
const saving = ref(false)
const allList = ref([])
const search = reactive({ title: '', category: '' })
const page = reactive({ current: 1, size: 10, total: 0 })

const filteredList = computed(() => allList.value.filter(d =>
  (!search.title || (d.title || '').includes(search.title)) &&
  (!search.category || d.category === search.category)))

const pagedList = computed(() => {
  const p = page
  const start = (p.current - 1) * p.size
  return filteredList.value.slice(start, start + p.size)
})

watch(filteredList, () => { page.total = filteredList.value.length })
watch(page, () => { page.total = filteredList.value.length })

function handleSearch() { page.current = 1 }
function resetSearch() { Object.assign(search, { title: '', category: '' }); page.current = 1 }

async function loadList() {
  loading.value = true
  try {
    const res = await getPolicyDocumentPage({ current: 1, size: 500 })
    allList.value = (res.data && res.data.records) || []
  } catch (e) { allList.value = [] } finally { loading.value = false }
}

// ---------- 新增/编辑 ----------
const dialog = reactive({ visible: false, id: null, form: {} })
const emptyForm = () => ({ title: '', docNo: '', publishUnit: '', issueDate: null, effectiveDate: null, category: '', content: '', attachmentName: '', attachmentUrl: '' })

function openDialog(row) {
  dialog.id = row ? row.id : null
  dialog.form = row
    ? {
        title: row.title || '',
        docNo: row.docNo || '',
        publishUnit: row.publishUnit || '',
        issueDate: row.issueDate || null,
        effectiveDate: row.effectiveDate || null,
        category: row.category || '',
        content: row.content || '',
        attachmentName: row.attachmentName || '',
        attachmentUrl: row.attachmentUrl || ''
      }
    : emptyForm()
  dialog.visible = true
}

async function submit() {
  const f = dialog.form
  if (!f.title || !String(f.title).trim()) return ElMessage.warning('请填写文档标题')
  if (!f.category) return ElMessage.warning('请选择文档分类')
  saving.value = true
  try {
    const payload = {
      title: f.title,
      docNo: f.docNo || null,
      publishUnit: f.publishUnit || null,
      issueDate: f.issueDate || null,
      effectiveDate: f.effectiveDate || null,
      category: f.category,
      content: f.content || null,
      attachmentName: f.attachmentName || null,
      attachmentUrl: f.attachmentUrl || null
    }
    if (dialog.id) {
      await updatePolicyDocument({ id: dialog.id, ...payload })
      ElMessage.success('更新成功')
    } else {
      await addPolicyDocument(payload)
      ElMessage.success('新增成功')
    }
    dialog.visible = false
    loadList()
  } finally { saving.value = false }
}

function handleDelete(row) {
  ElMessageBox.confirm('确定删除该份政策文件吗？删除后不可恢复。', '提示', { type: 'warning' }).then(async () => {
    await deletePolicyDocument(row.id)
    ElMessage.success('删除成功')
    loadList()
  }).catch(() => {})
}

// ---------- 正文查看 ----------
const view = reactive({ visible: false, row: null })
function openView(row) {
  view.row = row
  view.visible = true
}

// ---------- 导出当前页 ----------
function exportList() {
  showExportDialog(pagedList.value.map(d => ({
    title: d.title, docNo: d.docNo, publishUnit: d.publishUnit, category: d.category,
    issueDate: d.issueDate || '-', effectiveDate: d.effectiveDate || '-', attachmentName: d.attachmentName || '-'
  })), [
    { prop: 'title', label: '标题' }, { prop: 'docNo', label: '文号' }, { prop: 'publishUnit', label: '发布单位' },
    { prop: 'category', label: '分类' }, { prop: 'issueDate', label: '发布日期' },
    { prop: 'effectiveDate', label: '施行日期' }, { prop: 'attachmentName', label: '附件' }
  ], '政策法规清单')
}

loadList()
</script>

<style scoped>
.pagination-wrap {
  padding: 10px 14px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: flex-end;
}
.doc-content {
  max-height: 46vh;
  overflow: auto;
  background: #fafbfc;
  border: 1px solid #e8e8e8;
  border-radius: 2px;
  padding: 10px 12px;
  font-size: 13px;
  line-height: 1.9;
  white-space: pre-wrap;
  word-break: break-all;
  color: #333;
}
</style>
