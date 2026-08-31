<template>
  <div>
    <div class="page-header">
      干部个人基础信息申报
      <span style="font-size:12px;font-weight:normal;margin-left:12px;color:#888">当前申报人：{{ userStore.realName || '未绑定' }}（{{ userStore.userType === 'cadre' ? '干部账号' : '管理员账号' }}）</span>
    </div>

    <el-alert v-if="userStore.userType === 'admin' && userStore.realName === '系统管理员'" type="warning" :closable="false" style="margin-bottom:16px">
      管理员账号无法绑定干部档案。请使用干部账号登录（如 zhangjg / lixiuying）查看对应干部的申报页面。
    </el-alert>

    <template v-if="hasCadreData">
      <!-- 一、个人基础信息 -->
      <el-card class="section-card">
        <template #header><div class="section-title"><el-icon><User /></el-icon> 个人基础信息</div></template>
        <el-form :model="basic" label-width="110px" size="default">
          <el-row :gutter="20">
            <el-col :span="8"><el-form-item label="姓名" required><el-input v-model="basic.name" disabled /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="性别" required>
              <el-radio-group v-model="basic.gender"><el-radio :value="1">男</el-radio><el-radio :value="2">女</el-radio></el-radio-group>
            </el-form-item></el-col>
            <el-col :span="8"><el-form-item label="民族"><el-select v-model="basic.ethnicity" style="width:100%"><el-option v-for="e in ethnicities" :key="e" :label="e" :value="e" /></el-select></el-form-item></el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="8"><el-form-item label="出生日期" required><el-date-picker v-model="basic.birthDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="身份证号"><el-input v-model="basic.idCard" maxlength="18" /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="籍贯"><el-input v-model="basic.nativePlace" /></el-form-item></el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="8"><el-form-item label="政治面貌"><el-select v-model="basic.politicalStatus" style="width:100%"><el-option label="中共党员" value="中共党员" /><el-option label="民主党派" value="民主党派" /><el-option label="群众" value="群众" /></el-select></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="入党时间"><el-date-picker v-model="basic.joinPartyDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="参工时间"><el-date-picker v-model="basic.workDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="8"><el-form-item label="最高学历"><el-select v-model="basic.education" style="width:100%"><el-option label="博士研究生" value="博士研究生" /><el-option label="硕士研究生" value="硕士研究生" /><el-option label="本科" value="本科" /><el-option label="大专" value="大专" /></el-select></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="最高学位"><el-select v-model="basic.degree" style="width:100%"><el-option label="博士" value="博士" /><el-option label="硕士" value="硕士" /><el-option label="学士" value="学士" /></el-select></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="全日制学历"><el-input v-model="basic.fullTimeEdu" /></el-form-item></el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="8"><el-form-item label="所属机构"><el-input v-model="basic.deptName" /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="岗位职务"><el-input v-model="basic.position" /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="职务层次"><el-select v-model="basic.positionLevel" style="width:100%"><el-option label="校级" value="校级" /><el-option label="处级" value="处级" /><el-option label="科级" value="科级" /></el-select></el-form-item></el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="8"><el-form-item label="职级"><el-input v-model="basic.rankName" /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="任现职时间"><el-date-picker v-model="basic.positionStartDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item></el-col>
            <el-col :span="8"><el-form-item label="联系电话"><el-input v-model="basic.phone" /></el-form-item></el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12"><el-form-item label="家庭住址"><el-input v-model="basic.address" /></el-form-item></el-col>
            <el-col :span="12"><el-form-item label="办公地址"><el-input v-model="basic.officeAddr" /></el-form-item></el-col>
          </el-row>
        </el-form>
      </el-card>

      <!-- 二、履历信息 -->
      <el-card class="section-card">
        <template #header><div class="section-title"><el-icon><Tickets /></el-icon> 履历信息</div></template>
        <el-tabs v-model="resumeTab" class="gov-tabs">
          <el-tab-pane label="任职经历" name="work">
            <el-button size="small" type="primary" style="margin-bottom:10px" @click="addResume('work')"><el-icon><Plus /></el-icon> 添加任职经历</el-button>
            <el-table :data="resumes.work" border size="small">
              <el-table-column type="index" label="序号" width="55" align="center" />
              <el-table-column prop="startDate" label="起止时间" width="200" align="center">
                <template #default="{ row }">{{ row.startDate }} 至 {{ row.endDate }}</template>
              </el-table-column>
              <el-table-column prop="dept" label="所在单位" min-width="150" show-overflow-tooltip />
              <el-table-column prop="position" label="担任职务" min-width="120" show-overflow-tooltip />
              <el-table-column prop="level" label="职务层次" width="80" align="center" />
              <el-table-column label="操作" width="80" align="center">
                <template #default="{ $index }"><span class="link-blue" style="color:#E53935" @click="resumes.work.splice($index,1)">删除</span></template>
              </el-table-column>
            </el-table>
          </el-tab-pane>
          <el-tab-pane label="求学履历" name="edu">
            <el-button size="small" type="primary" style="margin-bottom:10px" @click="addResume('edu')"><el-icon><Plus /></el-icon> 添加求学经历</el-button>
            <el-table :data="resumes.edu" border size="small">
              <el-table-column type="index" label="序号" width="55" align="center" />
              <el-table-column prop="startDate" label="起止时间" width="200" align="center">
                <template #default="{ row }">{{ row.startDate }} 至 {{ row.endDate }}</template>
              </el-table-column>
              <el-table-column prop="school" label="院校名称" min-width="150" show-overflow-tooltip />
              <el-table-column prop="major" label="专业" min-width="120" show-overflow-tooltip />
              <el-table-column prop="degree" label="学历/学位" width="120" align="center" />
              <el-table-column label="操作" width="80" align="center">
                <template #default="{ $index }"><span class="link-blue" style="color:#E53935" @click="resumes.edu.splice($index,1)">删除</span></template>
              </el-table-column>
            </el-table>
          </el-tab-pane>
        </el-tabs>
      </el-card>

      <!-- 三、奖惩 -->
      <el-card class="section-card">
        <template #header><div class="section-title"><el-icon><Medal /></el-icon> 奖惩相关资料</div></template>
        <div class="toolbar"><el-button type="primary" size="small" @click="addReward"><el-icon><Plus /></el-icon> 添加奖惩记录</el-button></div>
        <el-table :data="rewards" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column prop="type" label="类型" width="80" align="center"><template #default="{ row }"><el-tag :type="row.type==='奖励'?'success':'danger'" size="small">{{ row.type }}</el-tag></template></el-table-column>
          <el-table-column prop="name" label="奖惩名称" min-width="180" show-overflow-tooltip />
          <el-table-column prop="org" label="批准机关" min-width="140" show-overflow-tooltip />
          <el-table-column prop="date" label="批准日期" width="120" align="center" />
          <el-table-column prop="level" label="级别" width="100" align="center" />
          <el-table-column label="操作" width="80" align="center"><template #default="{ $index }"><span class="link-blue" style="color:#E53935" @click="rewards.splice($index,1)">删除</span></template></el-table-column>
        </el-table>
      </el-card>

      <!-- 四、家庭成员 -->
      <el-card class="section-card">
        <template #header><div class="section-title"><el-icon><UserFilled /></el-icon> 家庭成员档案信息</div></template>
        <div class="toolbar"><el-button type="primary" size="small" @click="addFamily"><el-icon><Plus /></el-icon> 添加家庭成员</el-button></div>
        <el-table :data="family" border size="small">
          <el-table-column type="index" label="序号" width="55" align="center" />
          <el-table-column prop="relation" label="关系" width="80" align="center" />
          <el-table-column prop="name" label="姓名" width="100" align="center" />
          <el-table-column prop="gender" label="性别" width="60" align="center" />
          <el-table-column prop="birthDate" label="出生日期" width="120" align="center" />
          <el-table-column prop="politicalStatus" label="政治面貌" width="100" align="center" />
          <el-table-column prop="workUnit" label="工作单位及职务" min-width="180" show-overflow-tooltip />
          <el-table-column label="操作" width="80" align="center"><template #default="{ $index }"><span class="link-blue" style="color:#E53935" @click="family.splice($index,1)">删除</span></template></el-table-column>
        </el-table>
      </el-card>

      <div style="text-align:center;padding:20px 0">
        <el-button size="large" @click="handleRefresh"><el-icon><RefreshLeft /></el-icon> 重置刷新</el-button>
        <el-button size="large" type="primary" @click="handleSaveDraft"><el-icon><Document /></el-icon> 保存草稿</el-button>
        <el-button size="large" type="success" @click="handleSubmit"><el-icon><CircleCheck /></el-icon> 确认提交</el-button>
      </div>
    </template>
    <div v-else style="text-align:center;padding:80px;color:#999">
      <el-icon style="font-size:52px"><User /></el-icon>
      <p style="margin-top:16px;font-size:15px">未找到对应当前账号的干部档案</p>
    </div>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="520px" destroy-on-close>
      <el-form :model="dialogForm" label-width="100px">
        <template v-if="dialogType==='workResume'">
          <el-form-item label="起始时间"><el-date-picker v-model="dialogForm.startDate" type="month" style="width:100%" value-format="YYYY-MM" /></el-form-item>
          <el-form-item label="结束时间"><el-date-picker v-model="dialogForm.endDate" type="month" style="width:100%" value-format="YYYY-MM" /></el-form-item>
          <el-form-item label="所在单位"><el-input v-model="dialogForm.dept" /></el-form-item>
          <el-form-item label="担任职务"><el-input v-model="dialogForm.position" /></el-form-item>
          <el-form-item label="职务层次"><el-input v-model="dialogForm.level" /></el-form-item>
        </template>
        <template v-else-if="dialogType==='eduResume'">
          <el-form-item label="起始时间"><el-date-picker v-model="dialogForm.startDate" type="month" style="width:100%" value-format="YYYY-MM" /></el-form-item>
          <el-form-item label="结束时间"><el-date-picker v-model="dialogForm.endDate" type="month" style="width:100%" value-format="YYYY-MM" /></el-form-item>
          <el-form-item label="院校名称"><el-input v-model="dialogForm.school" /></el-form-item>
          <el-form-item label="专业"><el-input v-model="dialogForm.major" /></el-form-item>
          <el-form-item label="学历/学位"><el-input v-model="dialogForm.degree" /></el-form-item>
        </template>
        <template v-else-if="dialogType==='reward'">
          <el-form-item label="类型"><el-radio-group v-model="dialogForm.type"><el-radio value="奖励">奖励</el-radio><el-radio value="惩处">惩处</el-radio></el-radio-group></el-form-item>
          <el-form-item label="奖惩名称"><el-input v-model="dialogForm.name" /></el-form-item>
          <el-form-item label="批准机关"><el-input v-model="dialogForm.org" /></el-form-item>
          <el-form-item label="批准日期"><el-date-picker v-model="dialogForm.date" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item>
          <el-form-item label="级别"><el-select v-model="dialogForm.level" style="width:100%"><el-option label="国家级" value="国家级" /><el-option label="省部级" value="省部级" /><el-option label="市厅级" value="市厅级" /><el-option label="校级" value="校级" /></el-select></el-form-item>
        </template>
        <template v-else-if="dialogType==='family'">
          <el-form-item label="关系"><el-select v-model="dialogForm.relation" style="width:100%"><el-option label="父亲" value="父亲" /><el-option label="母亲" value="母亲" /><el-option label="配偶" value="配偶" /><el-option label="子女" value="子女" /><el-option label="兄弟姐妹" value="兄弟姐妹" /></el-select></el-form-item>
          <el-form-item label="姓名"><el-input v-model="dialogForm.name" /></el-form-item>
          <el-form-item label="性别"><el-radio-group v-model="dialogForm.gender"><el-radio value="男">男</el-radio><el-radio value="女">女</el-radio></el-radio-group></el-form-item>
          <el-form-item label="出生日期"><el-date-picker v-model="dialogForm.birthDate" type="date" style="width:100%" value-format="YYYY-MM-DD" /></el-form-item>
          <el-form-item label="政治面貌"><el-input v-model="dialogForm.politicalStatus" /></el-form-item>
          <el-form-item label="工作单位及职务"><el-input v-model="dialogForm.workUnit" type="textarea" :rows="2" /></el-form-item>
        </template>
      </el-form>
      <template #footer><el-button @click="dialogVisible=false">取消</el-button><el-button type="primary" @click="confirmDialog">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { User, Tickets, Medal, UserFilled, Plus, RefreshLeft, Document, CircleCheck } from '@element-plus/icons-vue'

const userStore = useUserStore()

const ethnicities = ['汉族','蒙古族','回族','藏族','维吾尔族','苗族','彝族','壮族','布依族','朝鲜族','满族','侗族','瑶族','白族','土家族','哈尼族','哈萨克族','傣族','黎族','其他']

// Mock data for each cadre
const cadreDataMap = {
  '张建国': {
    basic: { name:'张建国', gender:1, ethnicity:'汉族', birthDate:'1968-03-15', idCard:'320102196803151234', nativePlace:'江苏南京', politicalStatus:'中共党员', joinPartyDate:'1992-06-01', workDate:'1990-07-01', education:'博士研究生', degree:'博士', fullTimeEdu:'本科', deptName:'党委办公室', position:'主任', positionLevel:'处级', rankName:'正处级', positionStartDate:'2018-03-01', phone:'13800138000', address:'鼓楼区中山路100号', officeAddr:'行政楼301' },
    work: [{ startDate:'2018-03',endDate:'至今',dept:'党委办公室',position:'主任',level:'处级' },{ startDate:'2013-01',endDate:'2018-02',dept:'机械工程学院',position:'副院长',level:'处级副职' },{ startDate:'2008-06',endDate:'2012-12',dept:'机械工程学院',position:'系主任',level:'科级' }],
    edu: [{ startDate:'2003-09',endDate:'2008-06',school:'东南大学',major:'机械工程',degree:'博士研究生' },{ startDate:'2000-09',endDate:'2003-06',school:'南京航空航天大学',major:'机械设计及理论',degree:'硕士' },{ startDate:'1990-09',endDate:'1994-06',school:'南京理工大学',major:'机械制造',degree:'学士' }],
    rewards: [{ type:'奖励',name:'全国教育系统先进工作者',org:'教育部',date:'2020-09-10',level:'国家级' },{ type:'奖励',name:'江苏省高校优秀共产党员',org:'江苏省委教育工委',date:'2019-07-01',level:'省部级' }],
    family: [{ relation:'配偶',name:'陈丽华',gender:'女',birthDate:'1972-05-20',politicalStatus:'群众',workUnit:'南京市第一中学 教师' },{ relation:'子女',name:'张小鹏',gender:'男',birthDate:'1998-12-10',politicalStatus:'共青团员',workUnit:'南京大学 在读研究生' },{ relation:'父亲',name:'张德才',gender:'男',birthDate:'1945-08-03',politicalStatus:'群众',workUnit:'已退休' }]
  },
  '李秀英': {
    basic: { name:'李秀英', gender:2, ethnicity:'汉族', birthDate:'1972-08-20', idCard:'320102197208202345', nativePlace:'山东济南', politicalStatus:'中共党员', joinPartyDate:'1998-12-01', workDate:'1995-07-01', education:'博士研究生', degree:'博士', fullTimeEdu:'硕士', deptName:'机械工程学院', position:'院长', positionLevel:'处级', rankName:'正处级', positionStartDate:'2020-06-01', phone:'13900139001', address:'江宁区天元路88号', officeAddr:'机械楼402' },
    work: [{ startDate:'2020-06',endDate:'至今',dept:'机械工程学院',position:'院长',level:'处级' },{ startDate:'2015-03',endDate:'2020-05',dept:'机械工程学院',position:'副院长',level:'处级副职' },{ startDate:'2008-09',endDate:'2015-02',dept:'机械工程学院',position:'系主任',level:'科级' }],
    edu: [{ startDate:'2006-09',endDate:'2010-06',school:'上海交通大学',major:'机械工程',degree:'博士研究生' },{ startDate:'2003-09',endDate:'2006-06',school:'山东大学',major:'机械设计',degree:'硕士' },{ startDate:'1991-09',endDate:'1995-06',school:'山东大学',major:'机械制造',degree:'学士' }],
    rewards: [{ type:'奖励',name:'教育部科技进步二等奖',org:'教育部',date:'2021-12-01',level:'省部级' }],
    family: [{ relation:'配偶',name:'王志强',gender:'男',birthDate:'1965-08-20',politicalStatus:'中共党员',workUnit:'电气工程学院 教授' }]
  },
  '王志强': {
    basic: { name:'王志强', gender:1, ethnicity:'汉族', birthDate:'1965-08-20', idCard:'320102196508203456', nativePlace:'江苏苏州', politicalStatus:'中共党员', joinPartyDate:'1995-06-01', workDate:'1988-07-01', education:'博士研究生', degree:'博士', fullTimeEdu:'本科', deptName:'电气工程学院', position:'党委书记', positionLevel:'处级', rankName:'正处级', positionStartDate:'2018-01-01', phone:'13800138001', address:'秦淮区健康路50号', officeAddr:'电气楼301' },
    work: [{ startDate:'2018-01',endDate:'至今',dept:'电气工程学院',position:'党委书记',level:'处级' },{ startDate:'2015-03',endDate:'2017-12',dept:'电气工程学院',position:'副院长',level:'处级副职' }],
    edu: [{ startDate:'2005-09',endDate:'2009-06',school:'西安交通大学',major:'电气工程',degree:'博士研究生' },{ startDate:'2002-09',endDate:'2005-06',school:'东南大学',major:'电力系统',degree:'硕士' },{ startDate:'1984-09',endDate:'1988-06',school:'东南大学',major:'电气工程',degree:'学士' }],
    rewards: [{ type:'奖励',name:'省高校优秀党务工作者',org:'江苏省委教育工委',date:'2022-07-01',level:'省部级' }],
    family: [{ relation:'配偶',name:'李秀英',gender:'女',birthDate:'1972-08-20',politicalStatus:'中共党员',workUnit:'机械工程学院 院长' },{ relation:'子女',name:'王小明',gender:'男',birthDate:'2000-05-10',politicalStatus:'共青团员',workUnit:'浙江大学 在读研究生' }]
  },
  '刘德明': {
    basic: { name:'刘德明', gender:1, ethnicity:'汉族', birthDate:'1975-11-08', idCard:'320102197511084567', nativePlace:'江苏南通', politicalStatus:'中共党员', joinPartyDate:'2002-06-01', workDate:'1998-07-01', education:'硕士研究生', degree:'硕士', fullTimeEdu:'本科', deptName:'人事处', position:'副处长', positionLevel:'处级副职', rankName:'副处级', positionStartDate:'2019-09-01', phone:'13800138002', address:'浦口区文德路100号', officeAddr:'行政楼202' },
    work: [{ startDate:'2019-09',endDate:'至今',dept:'人事处',position:'副处长',level:'处级副职' },{ startDate:'2015-06',endDate:'2019-08',dept:'人事处',position:'科长',level:'科级' }],
    edu: [{ startDate:'2012-09',endDate:'2015-06',school:'南京大学',major:'公共管理',degree:'硕士' },{ startDate:'1994-09',endDate:'1998-06',school:'苏州大学',major:'行政管理',degree:'学士' }],
    rewards: [{ type:'奖励',name:'校先进工作者',org:'本校',date:'2023-12-30',level:'校级' }],
    family: [{ relation:'配偶',name:'赵红梅',gender:'女',birthDate:'1978-03-15',politicalStatus:'群众',workUnit:'南京市教育局 科员' },{ relation:'子女',name:'刘小琪',gender:'女',birthDate:'2006-09-20',politicalStatus:'学生',workUnit:'南京市第一中学 在读' }]
  },
  '陈丽华': {
    basic: { name:'陈丽华', gender:2, ethnicity:'汉族', birthDate:'1978-04-12', idCard:'320102197804125678', nativePlace:'江苏无锡', politicalStatus:'中共党员', joinPartyDate:'2005-06-01', workDate:'2000-07-01', education:'硕士研究生', degree:'硕士', fullTimeEdu:'本科', deptName:'经济管理学院', position:'副院长', positionLevel:'处级副职', rankName:'副处级', positionStartDate:'2021-03-01', phone:'13800138003', address:'建邺区梦都大街200号', officeAddr:'经管楼305' },
    work: [{ startDate:'2021-03',endDate:'至今',dept:'经济管理学院',position:'副院长',level:'处级副职' },{ startDate:'2016-01',endDate:'2021-02',dept:'经济管理学院',position:'系主任',level:'科级' }],
    edu: [{ startDate:'2010-09',endDate:'2013-06',school:'复旦大学',major:'工商管理',degree:'硕士' },{ startDate:'1996-09',endDate:'2000-06',school:'南京大学',major:'经济学',degree:'学士' }],
    rewards: [{ type:'奖励',name:'省社科优秀成果三等奖',org:'省社科联',date:'2024-05-01',level:'省部级' }],
    family: [{ relation:'配偶',name:'张建国',gender:'男',birthDate:'1968-03-15',politicalStatus:'中共党员',workUnit:'党委办公室 主任' },{ relation:'子女',name:'张小鹏',gender:'男',birthDate:'1998-12-10',politicalStatus:'共青团员',workUnit:'南京大学 在读研究生' }]
  }
}

function getCadreData() {
  return cadreDataMap[userStore.realName] || null
}

const hasCadreData = computed(() => !!getCadreData())

const basic = reactive(JSON.parse(JSON.stringify(getCadreData()?.basic || {})))
const resumes = reactive({
  work: JSON.parse(JSON.stringify(getCadreData()?.work || [])),
  edu: JSON.parse(JSON.stringify(getCadreData()?.edu || []))
})
const rewards = ref(JSON.parse(JSON.stringify(getCadreData()?.rewards || [])))
const family = ref(JSON.parse(JSON.stringify(getCadreData()?.family || [])))

const resumeTab = ref('work')

const dialogVisible = ref(false)
const dialogTitle = ref('')
const dialogType = ref('')
const dialogForm = reactive({})

function addResume(type) {
  dialogType.value = type==='work'?'workResume':'eduResume'
  dialogTitle.value = type==='work'?'添加任职经历':'添加求学经历'
  Object.keys(dialogForm).forEach(k=>delete dialogForm[k])
  dialogVisible.value = true
}
function addReward() {
  dialogType.value='reward'; dialogTitle.value='添加奖惩记录'
  Object.keys(dialogForm).forEach(k=>delete dialogForm[k]); dialogForm.type='奖励'
  dialogVisible.value=true
}
function addFamily() {
  dialogType.value='family'; dialogTitle.value='添加家庭成员'
  Object.keys(dialogForm).forEach(k=>delete dialogForm[k]); dialogForm.gender='男'
  dialogVisible.value=true
}
function confirmDialog() {
  const form = {...dialogForm}
  if(dialogType.value==='workResume') resumes.work.push(form)
  else if(dialogType.value==='eduResume') resumes.edu.push(form)
  else if(dialogType.value==='reward') rewards.value.push(form)
  else if(dialogType.value==='family') family.value.push(form)
  dialogVisible.value=false
  ElMessage.success('添加成功')
}
function handleRefresh() {
  ElMessageBox.confirm('刷新将恢复到上次保存的数据，未保存的修改将丢失，确定继续吗？','提示',{type:'warning'})
    .then(()=>{
      const cd = getCadreData()
      if(cd){
        Object.assign(basic, JSON.parse(JSON.stringify(cd.basic)))
        resumes.work.splice(0, resumes.work.length, ...JSON.parse(JSON.stringify(cd.work)))
        resumes.edu.splice(0, resumes.edu.length, ...JSON.parse(JSON.stringify(cd.edu)))
        rewards.value = JSON.parse(JSON.stringify(cd.rewards))
        family.value = JSON.parse(JSON.stringify(cd.family))
      }
      ElMessage.info('数据已刷新')
    }).catch(()=>{})
}
function handleSaveDraft() {
  const draft = { basic:{...basic}, resumes:{work:[...resumes.work],edu:[...resumes.edu]}, rewards:[...rewards.value], family:[...family.value] }
  localStorage.setItem(`cadre_draft_${userStore.userId}`, JSON.stringify(draft))
  ElMessage.success('草稿保存成功')
}
function handleSubmit() {
  ElMessageBox.confirm('提交后将正式更新您的干部档案，确认信息真实准确？','确认提交',{type:'warning',confirmButtonText:'确认提交'})
    .then(()=>{
      const submission = {
        id: Date.now(),
        userId: userStore.userId,
        applicant: userStore.realName,
        deptName: basic.deptName || '',
        type: '个人基础信息',
        summary: `${userStore.realName}提交的个人基础信息变更`,
        submitTime: new Date().toLocaleString(),
        basic: {...basic},
        resumes: {work:[...resumes.work],edu:[...resumes.edu]},
        rewards: [...rewards.value],
        family: [...family.value]
      }
      const subs = JSON.parse(localStorage.getItem('cadre_submissions') || '[]')
      subs.unshift(submission)
      localStorage.setItem('cadre_submissions', JSON.stringify(subs))
      localStorage.removeItem(`cadre_draft_${userStore.userId}`)
      ElMessage.success(`申报信息已成功提交，待人事部门审核后生效（当前共${subs.length}条待审批）`)
    }).catch(()=>{})
}
</script>

<style scoped>
.section-card { margin-bottom: 16px; }
.section-card :deep(.el-card__header) { padding: 10px 16px; background: #f8f9fa; border-bottom: 2px solid #1976D2; }
.section-title { font-size: 14px; font-weight: 600; color: #1976D2; display: flex; align-items: center; gap: 6px; }
.gov-tabs :deep(.el-tabs__header) { margin-bottom: 8px; }
.gov-tabs :deep(.el-tabs__nav-wrap::after) { display: none; }
</style>
