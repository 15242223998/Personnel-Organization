<template>
  <div>
    <div class="page-header">数据字典管理</div>

    <el-row :gutter="12">
      <el-col :span="8">
        <div class="dict-type-panel">
          <div class="dict-header">
            <span>字典类型</span>
            <el-button type="primary" size="small" text @click="handleAddDictType"><el-icon><Plus /></el-icon> 新增</el-button>
          </div>
          <div class="dict-type-list">
            <div
              v-for="item in dictTypes"
              :key="item.code"
              class="dict-type-item"
              :class="{ active: activeType === item.code }"
              @click="selectType(item.code)"
            >
              <div class="type-name">{{ item.name }}</div>
              <div class="type-code">{{ item.code }}</div>
            </div>
          </div>
        </div>
      </el-col>

      <el-col :span="16">
        <div class="dict-data-panel">
          <div class="dict-header">
            <span>字典数据 - {{ currentTypeName }}</span>
            <div>
              <el-button type="primary" size="small" @click="handleAddDictItem"><el-icon><Plus /></el-icon> 新增字典项</el-button>
            </div>
          </div>
          <el-table :data="dictDataMap[activeType]" border size="small">
            <el-table-column type="index" label="序号" width="55" align="center" />
            <el-table-column prop="label" label="标签" min-width="110" show-overflow-tooltip sortable />
            <el-table-column prop="value" label="键值" min-width="80" align="center" sortable />
            <el-table-column prop="sort" label="排序" width="70" align="center" sortable />
            <el-table-column label="标签样式" width="100" align="center">
              <template #default="{ row }">
                <el-tag v-if="row.tagType" :type="row.tagType" size="small">示例</el-tag>
                <span v-else style="color:#999">-</span>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80" align="center" sortable>
              <template #default="{ row }">
                <el-tag :type="row.status === '启用' ? 'success' : 'info'" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip sortable />
            <el-table-column label="操作" width="120" align="center">
              <template #default="{ row }">
                <span class="link-blue" @click="handleDictEdit(row)">编辑</span>
                <el-divider direction="vertical" />
                <span class="link-blue" style="color:#E53935" @click="handleDictDelete(row)">删除</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const activeType = ref('political_status')

const dictTypes = [
  { name: '政治面貌', code: 'political_status' },
  { name: '性别', code: 'gender' },
  { name: '民族', code: 'nation' },
  { name: '学历', code: 'education' }
]

const dictDataMap = {
  political_status: [
    { label: '中共党员', value: '01', sort: 1, tagType: 'danger', status: '启用', remark: '中国共产党党员' },
    { label: '中共预备党员', value: '02', sort: 2, tagType: 'danger', status: '启用', remark: '中国共产党预备党员' },
    { label: '共青团员', value: '03', sort: 3, tagType: '', status: '启用', remark: '中国共产主义青年团团员' },
    { label: '民革会员', value: '04', sort: 4, tagType: 'warning', status: '启用', remark: '中国国民党革命委员会会员' },
    { label: '民盟盟员', value: '05', sort: 5, tagType: 'warning', status: '启用', remark: '中国民主同盟盟员' },
    { label: '民建会员', value: '06', sort: 6, tagType: 'warning', status: '启用', remark: '中国民主建国会会员' },
    { label: '民进会员', value: '07', sort: 7, tagType: 'warning', status: '启用', remark: '中国民主促进会会员' },
    { label: '农工党党员', value: '08', sort: 8, tagType: 'warning', status: '启用', remark: '中国农工民主党党员' },
    { label: '致公党党员', value: '09', sort: 9, tagType: 'warning', status: '启用', remark: '中国致公党党员' },
    { label: '九三学社社员', value: '10', sort: 10, tagType: 'warning', status: '启用', remark: '九三学社社员' },
    { label: '台盟盟员', value: '11', sort: 11, tagType: 'warning', status: '启用', remark: '台湾民主自治同盟盟员' },
    { label: '无党派人士', value: '12', sort: 12, tagType: '', status: '启用', remark: '无党派人士' },
    { label: '群众', value: '13', sort: 13, tagType: 'info', status: '启用', remark: '普通群众' }
  ],
  gender: [
    { label: '男', value: '1', sort: 1, tagType: '', status: '启用', remark: '男性' },
    { label: '女', value: '2', sort: 2, tagType: '', status: '启用', remark: '女性' }
  ],
  nation: [
    { label: '汉族', value: '01', sort: 1, tagType: '', status: '启用', remark: '' },
    { label: '蒙古族', value: '02', sort: 2, tagType: '', status: '启用', remark: '' },
    { label: '回族', value: '03', sort: 3, tagType: '', status: '启用', remark: '' },
    { label: '藏族', value: '04', sort: 4, tagType: '', status: '启用', remark: '' },
    { label: '维吾尔族', value: '05', sort: 5, tagType: '', status: '启用', remark: '' },
    { label: '苗族', value: '06', sort: 6, tagType: '', status: '启用', remark: '' },
    { label: '彝族', value: '07', sort: 7, tagType: '', status: '启用', remark: '' },
    { label: '壮族', value: '08', sort: 8, tagType: '', status: '启用', remark: '' },
    { label: '布依族', value: '09', sort: 9, tagType: '', status: '启用', remark: '' },
    { label: '朝鲜族', value: '10', sort: 10, tagType: '', status: '启用', remark: '' },
    { label: '满族', value: '11', sort: 11, tagType: '', status: '启用', remark: '' },
    { label: '侗族', value: '12', sort: 12, tagType: '', status: '启用', remark: '' },
    { label: '瑶族', value: '13', sort: 13, tagType: '', status: '启用', remark: '' },
    { label: '白族', value: '14', sort: 14, tagType: '', status: '启用', remark: '' },
    { label: '土家族', value: '15', sort: 15, tagType: '', status: '启用', remark: '' },
    { label: '哈尼族', value: '16', sort: 16, tagType: '', status: '启用', remark: '' },
    { label: '哈萨克族', value: '17', sort: 17, tagType: '', status: '启用', remark: '' },
    { label: '傣族', value: '18', sort: 18, tagType: '', status: '启用', remark: '' },
    { label: '黎族', value: '19', sort: 19, tagType: '', status: '启用', remark: '' },
    { label: '傈僳族', value: '20', sort: 20, tagType: '', status: '启用', remark: '' },
    { label: '佤族', value: '21', sort: 21, tagType: '', status: '启用', remark: '' },
    { label: '畲族', value: '22', sort: 22, tagType: '', status: '启用', remark: '' },
    { label: '高山族', value: '23', sort: 23, tagType: '', status: '启用', remark: '' },
    { label: '拉祜族', value: '24', sort: 24, tagType: '', status: '启用', remark: '' },
    { label: '水族', value: '25', sort: 25, tagType: '', status: '启用', remark: '' },
    { label: '东乡族', value: '26', sort: 26, tagType: '', status: '启用', remark: '' },
    { label: '纳西族', value: '27', sort: 27, tagType: '', status: '启用', remark: '' },
    { label: '景颇族', value: '28', sort: 28, tagType: '', status: '启用', remark: '' },
    { label: '柯尔克孜族', value: '29', sort: 29, tagType: '', status: '启用', remark: '' },
    { label: '土族', value: '30', sort: 30, tagType: '', status: '启用', remark: '' },
    { label: '达斡尔族', value: '31', sort: 31, tagType: '', status: '启用', remark: '' },
    { label: '仫佬族', value: '32', sort: 32, tagType: '', status: '启用', remark: '' },
    { label: '羌族', value: '33', sort: 33, tagType: '', status: '启用', remark: '' },
    { label: '布朗族', value: '34', sort: 34, tagType: '', status: '启用', remark: '' },
    { label: '撒拉族', value: '35', sort: 35, tagType: '', status: '启用', remark: '' },
    { label: '毛南族', value: '36', sort: 36, tagType: '', status: '启用', remark: '' },
    { label: '仡佬族', value: '37', sort: 37, tagType: '', status: '启用', remark: '' },
    { label: '锡伯族', value: '38', sort: 38, tagType: '', status: '启用', remark: '' },
    { label: '阿昌族', value: '39', sort: 39, tagType: '', status: '启用', remark: '' },
    { label: '普米族', value: '40', sort: 40, tagType: '', status: '启用', remark: '' },
    { label: '塔吉克族', value: '41', sort: 41, tagType: '', status: '启用', remark: '' },
    { label: '怒族', value: '42', sort: 42, tagType: '', status: '启用', remark: '' },
    { label: '乌孜别克族', value: '43', sort: 43, tagType: '', status: '启用', remark: '' },
    { label: '俄罗斯族', value: '44', sort: 44, tagType: '', status: '启用', remark: '' },
    { label: '鄂温克族', value: '45', sort: 45, tagType: '', status: '启用', remark: '' },
    { label: '德昂族', value: '46', sort: 46, tagType: '', status: '启用', remark: '' },
    { label: '保安族', value: '47', sort: 47, tagType: '', status: '启用', remark: '' },
    { label: '裕固族', value: '48', sort: 48, tagType: '', status: '启用', remark: '' },
    { label: '京族', value: '49', sort: 49, tagType: '', status: '启用', remark: '' },
    { label: '塔塔尔族', value: '50', sort: 50, tagType: '', status: '启用', remark: '' },
    { label: '独龙族', value: '51', sort: 51, tagType: '', status: '启用', remark: '' },
    { label: '鄂伦春族', value: '52', sort: 52, tagType: '', status: '启用', remark: '' },
    { label: '赫哲族', value: '53', sort: 53, tagType: '', status: '启用', remark: '' },
    { label: '门巴族', value: '54', sort: 54, tagType: '', status: '启用', remark: '' },
    { label: '珞巴族', value: '55', sort: 55, tagType: '', status: '启用', remark: '' },
    { label: '基诺族', value: '56', sort: 56, tagType: '', status: '启用', remark: '' }
  ],
  education: [
    { label: '博士研究生', value: '1', sort: 1, tagType: '', status: '启用', remark: '博士学位' },
    { label: '硕士研究生', value: '2', sort: 2, tagType: '', status: '启用', remark: '硕士学位' },
    { label: '大学本科', value: '3', sort: 3, tagType: '', status: '启用', remark: '学士学位' },
    { label: '大学专科', value: '4', sort: 4, tagType: '', status: '启用', remark: '大专学历' },
    { label: '中专及以下', value: '5', sort: 5, tagType: 'info', status: '启用', remark: '中专、高中、初中等' }
  ]
}

const currentTypeName = computed(() => {
  const t = dictTypes.find(d => d.code === activeType.value)
  return t ? t.name : ''
})

function selectType(code) {
  activeType.value = code
}

function handleAddDictType() { ElMessage.info('新增字典类型功能') }
function handleAddDictItem() { ElMessage.info('新增字典项功能') }
function handleDictEdit(row) { ElMessage.info(`编辑字典项：${row.label}`) }
function handleDictDelete(row) { ElMessage.success(`已删除字典项：${row.label}`) }
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
  max-height: calc(100vh - 220px);
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
