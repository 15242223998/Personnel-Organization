<template>
  <div>
    <div class="page-header">干部信息详情 - {{ form.name }}</div>

    <div class="detail-card">
      <div class="toolbar">
        <el-button @click="handleBack"><el-icon><ArrowLeft /></el-icon> 返回</el-button>
        <el-button v-if="!isEditMode" type="primary" @click="toggleEdit"><el-icon><Edit /></el-icon> 编辑</el-button>
        <el-button v-if="isEditMode" type="primary" :loading="saveLoading" @click="handleSave"><el-icon><Check /></el-icon> 保存</el-button>
        <el-button v-if="isEditMode" @click="cancelEdit"><el-icon><Close /></el-icon> 取消</el-button>
        <el-button type="success" @click="handleExport"><el-icon><Download /></el-icon> 导出任免表</el-button>
      </div>

      <el-tabs v-model="activeTab" class="detail-tabs">
        <el-tab-pane label="基础信息" name="basic">
          <div class="basic-section">
            <div class="photo-area">
              <div class="photo-placeholder">
                <el-icon :size="48" color="#ccc"><UserFilled /></el-icon>
                <span class="photo-text">照片</span>
              </div>
              <el-upload
                v-if="isEditMode"
                class="photo-upload"
                action="#"
                :show-file-list="false"
                :http-request="handlePhotoUpload"
                accept="image/*"
              >
                <el-button size="small" type="primary" plain>上传照片</el-button>
              </el-upload>
            </div>
            <div class="form-area">
              <el-form
                ref="basicFormRef"
                :model="form"
                :rules="basicRules"
                label-width="110px"
                :disabled="!isEditMode"
                size="default"
              >
                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item label="姓名" prop="name">
                      <el-input v-model="form.name" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="性别" prop="gender">
                      <el-select v-model="form.gender" style="width:100%" placeholder="请选择">
                        <el-option label="男" value="男" />
                        <el-option label="女" value="女" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="出生年月" prop="birthDate">
                      <el-date-picker v-model="form.birthDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="民族" prop="nation">
                      <el-input v-model="form.nation" placeholder="请输入民族" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="籍贯" prop="nativePlace">
                      <el-input v-model="form.nativePlace" placeholder="请输入籍贯" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="政治面貌" prop="politicalStatus">
                      <el-select v-model="form.politicalStatus" style="width:100%" placeholder="请选择">
                        <el-option label="中共党员" value="中共党员" />
                        <el-option label="中共预备党员" value="中共预备党员" />
                        <el-option label="共青团员" value="共青团员" />
                        <el-option label="民主党派" value="民主党派" />
                        <el-option label="群众" value="群众" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="入党时间" prop="partyJoinDate">
                      <el-date-picker v-model="form.partyJoinDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="参加工作时间" prop="workStartDate">
                      <el-date-picker v-model="form.workStartDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="身份证" prop="idCard">
                      <el-input v-model="form.idCard" placeholder="请输入身份证号" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="手机" prop="phone">
                      <el-input v-model="form.phone" placeholder="请输入手机号" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item label="邮箱" prop="email">
                      <el-input v-model="form.email" placeholder="请输入邮箱地址" />
                    </el-form-item>
                  </el-col>
                </el-row>
              </el-form>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="学历学位" name="education">
          <div class="edu-section">
            <div class="edu-block">
              <div class="edu-title">
                <el-icon color="#1976D2"><School /></el-icon>
                <span>全日制教育</span>
              </div>
              <el-form
                ref="eduFullFormRef"
                :model="form"
                label-width="100px"
                :disabled="!isEditMode"
              >
                <el-row :gutter="20">
                  <el-col :span="8">
                    <el-form-item label="学历">
                      <el-select v-model="form.fullTimeEducation" style="width:100%" placeholder="请选择">
                        <el-option label="博士研究生" value="博士研究生" />
                        <el-option label="硕士研究生" value="硕士研究生" />
                        <el-option label="本科" value="本科" />
                        <el-option label="大专" value="大专" />
                        <el-option label="高中" value="高中" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="学位">
                      <el-select v-model="form.fullTimeDegree" style="width:100%" placeholder="请选择">
                        <el-option label="博士" value="博士" />
                        <el-option label="硕士" value="硕士" />
                        <el-option label="学士" value="学士" />
                        <el-option label="无" value="无" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="院校专业">
                      <el-input v-model="form.fullTimeSchool" placeholder="请输入毕业院校及专业" />
                    </el-form-item>
                  </el-col>
                </el-row>
              </el-form>
            </div>
            <div class="edu-block">
              <div class="edu-title">
                <el-icon color="#1976D2"><Reading /></el-icon>
                <span>在职教育</span>
              </div>
              <el-form
                ref="eduPartFormRef"
                :model="form"
                label-width="100px"
                :disabled="!isEditMode"
              >
                <el-row :gutter="20">
                  <el-col :span="8">
                    <el-form-item label="学历">
                      <el-select v-model="form.partTimeEducation" style="width:100%" placeholder="请选择">
                        <el-option label="博士研究生" value="博士研究生" />
                        <el-option label="硕士研究生" value="硕士研究生" />
                        <el-option label="本科" value="本科" />
                        <el-option label="大专" value="大专" />
                        <el-option label="高中" value="高中" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="学位">
                      <el-select v-model="form.partTimeDegree" style="width:100%" placeholder="请选择">
                        <el-option label="博士" value="博士" />
                        <el-option label="硕士" value="硕士" />
                        <el-option label="学士" value="学士" />
                        <el-option label="无" value="无" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="8">
                    <el-form-item label="院校专业">
                      <el-input v-model="form.partTimeSchool" placeholder="请输入毕业院校及专业" />
                    </el-form-item>
                  </el-col>
                </el-row>
              </el-form>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="任职信息" name="position">
          <el-form
            ref="posFormRef"
            :model="form"
            label-width="110px"
            :disabled="!isEditMode"
          >
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="所属机构">
                  <el-select v-model="form.deptId" placeholder="请选择机构" style="width:100%" filterable>
                    <el-option v-for="d in deptOptions" :key="d.id" :label="d.deptName" :value="d.id" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="职务">
                  <el-input v-model="form.position" placeholder="请输入职务" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="职务层次">
                  <el-select v-model="form.positionLevel" placeholder="请选择职务层次" style="width:100%">
                    <el-option label="正厅级" value="正厅级" />
                    <el-option label="副厅级" value="副厅级" />
                    <el-option label="正处级" value="正处级" />
                    <el-option label="副处级" value="副处级" />
                    <el-option label="正科级" value="正科级" />
                    <el-option label="副科级" value="副科级" />
                    <el-option label="科员" value="科员" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="职级">
                  <el-select v-model="form.rankId" placeholder="请选择职级" style="width:100%">
                    <el-option v-for="r in rankList" :key="r.id" :label="r.rankName" :value="r.id" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="任现职时间">
                  <el-date-picker v-model="form.positionStartDate" type="date" value-format="YYYY-MM-DD" style="width:100%" placeholder="请选择日期" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="任职文号">
                  <el-input v-model="form.positionDocNo" placeholder="请输入任职文号" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="家庭成员" name="family">
          <div class="sub-table-bar">
            <span class="sub-title">家庭成员列表</span>
            <el-button v-if="isEditMode" type="primary" size="small" @click="openFamilyAdd"><el-icon><Plus /></el-icon> 新增</el-button>
          </div>
          <el-table :data="familyList" border size="small">
            <el-table-column type="index" label="序号" width="60" align="center" />
            <el-table-column prop="memberName" label="姓名" width="120" align="center" />
            <el-table-column prop="relationship" label="关系" width="100" align="center" />
            <el-table-column prop="workUnit" label="工作单位" min-width="200" show-overflow-tooltip />
            <el-table-column prop="phone" label="电话" width="140" align="center" />
            <el-table-column v-if="isEditMode" label="操作" width="80" align="center" fixed="right">
              <template #default="{ $index }">
                <el-button link type="danger" @click="delFamily($index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="佐证材料" name="evidence">
          <div class="sub-table-bar">
            <span class="sub-title">佐证材料列表</span>
            <el-upload
              v-if="isEditMode"
              action="#"
              :http-request="handleUpload"
              :show-file-list="false"
            >
              <el-button type="primary" size="small"><el-icon><Upload /></el-icon> 上传材料</el-button>
            </el-upload>
          </div>
          <el-table :data="evidenceFiles" border size="small">
            <el-table-column prop="fileName" label="文件名" min-width="200" show-overflow-tooltip />
            <el-table-column prop="fileType" label="类型" width="100" align="center" />
            <el-table-column prop="fileSize" label="大小" width="100" align="center" />
            <el-table-column prop="uploadTime" label="上传时间" width="160" align="center" />
            <el-table-column label="操作" width="140" align="center" fixed="right">
              <template #default="{ $index }">
                <el-button link type="primary" @click="downloadFile($index)">下载</el-button>
                <el-button v-if="isEditMode" link type="danger" @click="delEvidence($index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="简历" name="resume">
          <el-form :model="form" label-width="0" :disabled="!isEditMode">
            <el-form-item>
              <el-input
                v-model="form.resumeText"
                type="textarea"
                :rows="16"
                placeholder="请输入干部简历信息..."
                class="resume-textarea"
              />
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog
      :title="familyDialogTitle"
      v-model="familyDialogVisible"
      width="520px"
      :close-on-click-modal="false"
    >
      <el-form ref="familyFormRef" :model="familyForm" label-width="90px" size="default">
        <el-form-item label="姓名" prop="memberName" :rules="[{ required: true, message: '请输入姓名', trigger: 'blur' }]">
          <el-input v-model="familyForm.memberName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="关系" prop="relationship" :rules="[{ required: true, message: '请输入关系', trigger: 'blur' }]">
          <el-select v-model="familyForm.relationship" style="width:100%" placeholder="请选择关系">
            <el-option label="配偶" value="配偶" />
            <el-option label="父亲" value="父亲" />
            <el-option label="母亲" value="母亲" />
            <el-option label="儿子" value="儿子" />
            <el-option label="女儿" value="女儿" />
            <el-option label="兄弟" value="兄弟" />
            <el-option label="姐妹" value="姐妹" />
          </el-select>
        </el-form-item>
        <el-form-item label="工作单位" prop="workUnit">
          <el-input v-model="familyForm.workUnit" placeholder="请输入工作单位" />
        </el-form-item>
        <el-form-item label="电话" prop="phone">
          <el-input v-model="familyForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="familyDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleFamilySave">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft, Edit, Check, Close, Download, Upload, Plus,
  UserFilled, School, Reading
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const activeTab = ref('basic')
const saveLoading = ref(false)
const isEditMode = ref(false)
const familyDialogVisible = ref(false)
const familyEditIdx = ref(-1)
const basicFormRef = ref(null)
const familyFormRef = ref(null)

const deptOptions = ref([
  { id: 1, deptName: '党委办公室' },
  { id: 2, deptName: '机械工程学院' },
  { id: 3, deptName: '电气工程学院' },
  { id: 4, deptName: '信息科学与工程学院' },
  { id: 5, deptName: '经济管理学院' },
  { id: 6, deptName: '人事处' },
  { id: 7, deptName: '学生工作处' }
])

const rankList = ref([
  { id: 1, rankName: '教授一级' },
  { id: 2, rankName: '教授二级' },
  { id: 3, rankName: '教授三级' },
  { id: 4, rankName: '副教授一级' },
  { id: 5, rankName: '副教授二级' },
  { id: 6, rankName: '讲师一级' },
  { id: 7, rankName: '讲师二级' },
  { id: 8, rankName: '助教' }
])

const defaultForm = {
  id: 1,
  name: '张伟',
  gender: '男',
  birthDate: '1968-03-15',
  nation: '汉族',
  nativePlace: '山东济南',
  politicalStatus: '中共党员',
  partyJoinDate: '1992-06-01',
  workStartDate: '1990-07-01',
  idCard: '37010219680315****',
  phone: '13800138001',
  email: 'zhangwei@university.edu.cn',
  photoUrl: '',
  fullTimeEducation: '博士研究生',
  fullTimeDegree: '博士',
  fullTimeSchool: '清华大学机械工程系',
  partTimeEducation: '',
  partTimeDegree: '',
  partTimeSchool: '',
  deptId: 2,
  position: '院长',
  positionLevel: '正处级',
  rankId: 3,
  positionStartDate: '2021-06-01',
  positionDocNo: '校党发〔2021〕28号',
  resumeText: `1986.09-1990.07  山东大学机械工程系 本科学习
1990.07-1993.09  济南机床一厂 助理工程师
1993.09-1996.07  清华大学机械工程系 硕士研究生
1996.07-2001.09  机械工程学院 讲师
2001.09-2008.12  机械工程学院 副教授（其间：2003.09-2007.06 清华大学机械工程系在职博士研究生）
2008.12-2015.06  机械工程学院 教授、副院长
2015.06-2021.06  机械工程学院 党委书记
2021.06-至今     机械工程学院 院长、党委副书记`
}

const form = reactive({ ...defaultForm })
const backupForm = ref(null)

const familyList = ref([
  { memberName: '李淑芬', relationship: '配偶', workUnit: '市第一人民医院', phone: '13900139001' },
  { memberName: '张文博', relationship: '儿子', workUnit: '上海交通大学（在读）', phone: '13700137001' },
  { memberName: '张建国', relationship: '父亲', workUnit: '退休', phone: '13600136001' }
])

const evidenceFiles = ref([
  { fileName: '干部任免审批表.pdf', fileType: 'PDF', fileSize: '256KB', uploadTime: '2023-06-15 10:30' },
  { fileName: '学历学位证书扫描件.zip', fileType: 'ZIP', fileSize: '1.2MB', uploadTime: '2023-06-15 10:32' },
  { fileName: '考核登记表2023.docx', fileType: 'DOCX', fileSize: '89KB', uploadTime: '2024-01-10 14:20' },
  { fileName: '入党志愿书.pdf', fileType: 'PDF', fileSize: '512KB', uploadTime: '2023-06-15 10:28' }
])

const familyForm = reactive({ memberName: '', relationship: '', workUnit: '', phone: '' })

const basicRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  gender: [{ required: true, message: '请选择性别', trigger: 'change' }]
}

const familyDialogTitle = computed(() => familyEditIdx.value >= 0 ? '编辑家庭成员' : '添加家庭成员')

function toggleEdit() {
  backupForm.value = JSON.parse(JSON.stringify(form))
  isEditMode.value = true
}

function cancelEdit() {
  Object.assign(form, backupForm.value)
  isEditMode.value = false
}

function handleBack() {
  router.back()
}

async function handleSave() {
  const valid = await basicFormRef.value?.validate().catch(() => false)
  if (!valid) return
  saveLoading.value = true
  setTimeout(() => {
    saveLoading.value = false
    isEditMode.value = false
    ElMessage.success('保存成功')
  }, 500)
}

function handleExport() {
  ElMessage.success('正在导出任免表，请稍候...')
}

function openFamilyAdd() {
  familyEditIdx.value = -1
  Object.assign(familyForm, { memberName: '', relationship: '', workUnit: '', phone: '' })
  familyDialogVisible.value = true
}

function handleFamilySave() {
  familyFormRef.value?.validate((valid) => {
    if (!valid) return
    const item = { ...familyForm }
    if (familyEditIdx.value >= 0) {
      familyList.value[familyEditIdx.value] = item
    } else {
      familyList.value.push(item)
    }
    familyDialogVisible.value = false
    ElMessage.success('添加成功')
  })
}

function delFamily(idx) {
  familyList.value.splice(idx, 1)
  ElMessage.success('删除成功')
}

function handleUpload(options) {
  const file = options.file
  const fileType = file.name.split('.').pop().toUpperCase()
  const fileSize = file.size < 1024 ? file.size + 'B' : file.size < 1024 * 1024 ? (file.size / 1024).toFixed(0) + 'KB' : (file.size / 1024 / 1024).toFixed(1) + 'MB'
  const now = new Date()
  const uploadTime = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')} ${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`
  evidenceFiles.value.push({
    fileName: file.name,
    fileType: fileType,
    fileSize: fileSize,
    uploadTime: uploadTime
  })
  ElMessage.success('上传成功')
}

function handlePhotoUpload(options) {
  ElMessage.success('照片上传成功')
}

function downloadFile(idx) {
  ElMessage.success('开始下载：' + evidenceFiles.value[idx].fileName)
}

function delEvidence(idx) {
  evidenceFiles.value.splice(idx, 1)
  ElMessage.success('删除成功')
}

onMounted(() => {
  if (route.query.edit === '1') {
    toggleEdit()
  }
})
</script>

<style scoped>
.detail-card {
  background: #fff;
  border: 1px solid #e0e0e0;
}

.detail-card .toolbar {
  border-bottom: 1px solid #e0e0e0;
}

.detail-tabs {
  padding: 0 16px 16px;
}

.detail-tabs :deep(.el-tabs__header) {
  margin-bottom: 18px;
}

.basic-section {
  display: flex;
  gap: 24px;
}

.photo-area {
  flex-shrink: 0;
  text-align: center;
}

.photo-placeholder {
  width: 130px;
  height: 170px;
  border: 2px dashed #d0d0d0;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #fafafa;
  margin-bottom: 10px;
}

.photo-text {
  color: #999;
  font-size: 13px;
  margin-top: 8px;
}

.form-area {
  flex: 1;
}

.edu-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.edu-block {
  background: #f8fafc;
  border: 1px solid #e8eef5;
  border-radius: 4px;
  padding: 16px 20px 4px;
}

.edu-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 14px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e0e0e0;
}

.sub-table-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.sub-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
}

.resume-textarea :deep(.el-textarea__inner) {
  font-family: "Microsoft YaHei", sans-serif;
  line-height: 1.8;
  font-size: 13px;
}
</style>
