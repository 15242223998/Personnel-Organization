<template>
  <div>
    <div class="page-header">个人信息</div>

    <el-alert v-if="!cadreData" type="warning" :closable="false" style="margin-bottom:16px">
      管理员账号暂无可查看的个人档案信息。
    </el-alert>

    <template v-if="cadreData">
      <el-card class="section-card">
        <template #header><div class="section-title">基础信息</div></template>
        <el-descriptions :column="3" border size="small">
          <el-descriptions-item label="姓名">{{ cadreData.basic.name }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ cadreData.basic.gender === 1 ? '男' : '女' }}</el-descriptions-item>
          <el-descriptions-item label="民族">{{ cadreData.basic.ethnicity }}</el-descriptions-item>
          <el-descriptions-item label="出生日期">{{ cadreData.basic.birthDate }}</el-descriptions-item>
          <el-descriptions-item label="身份证号">{{ cadreData.basic.idCard }}</el-descriptions-item>
          <el-descriptions-item label="籍贯">{{ cadreData.basic.nativePlace }}</el-descriptions-item>
          <el-descriptions-item label="政治面貌">{{ cadreData.basic.politicalStatus }}</el-descriptions-item>
          <el-descriptions-item label="入党时间">{{ cadreData.basic.joinPartyDate }}</el-descriptions-item>
          <el-descriptions-item label="参工时间">{{ cadreData.basic.workDate }}</el-descriptions-item>
          <el-descriptions-item label="最高学历">{{ cadreData.basic.education }}</el-descriptions-item>
          <el-descriptions-item label="最高学位">{{ cadreData.basic.degree }}</el-descriptions-item>
          <el-descriptions-item label="全日制学历">{{ cadreData.basic.fullTimeEdu }}</el-descriptions-item>
          <el-descriptions-item label="所属机构">{{ cadreData.basic.deptName }}</el-descriptions-item>
          <el-descriptions-item label="岗位职务">{{ cadreData.basic.position }}</el-descriptions-item>
          <el-descriptions-item label="职务层次">{{ cadreData.basic.positionLevel }}</el-descriptions-item>
          <el-descriptions-item label="职级">{{ cadreData.basic.rankName }}</el-descriptions-item>
          <el-descriptions-item label="任现职时间">{{ cadreData.basic.positionStartDate }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ cadreData.basic.phone }}</el-descriptions-item>
          <el-descriptions-item label="家庭住址" :span="2">{{ cadreData.basic.address }}</el-descriptions-item>
          <el-descriptions-item label="办公地址">{{ cadreData.basic.officeAddr }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card class="section-card">
        <template #header><div class="section-title">工作履历</div></template>
        <el-table :data="cadreData.work" border size="small">
          <el-table-column prop="startDate" label="起始时间" width="100" align="center" />
          <el-table-column prop="endDate" label="结束时间" width="100" align="center" />
          <el-table-column prop="dept" label="工作单位" min-width="150" />
          <el-table-column prop="position" label="职务" min-width="120" />
          <el-table-column prop="level" label="职级" width="100" align="center" />
        </el-table>
      </el-card>

      <el-card class="section-card">
        <template #header><div class="section-title">教育经历</div></template>
        <el-table :data="cadreData.edu" border size="small">
          <el-table-column prop="startDate" label="起始时间" width="100" align="center" />
          <el-table-column prop="endDate" label="结束时间" width="100" align="center" />
          <el-table-column prop="school" label="毕业院校" min-width="150" />
          <el-table-column prop="major" label="专业" min-width="120" />
          <el-table-column prop="degree" label="学位" width="100" align="center" />
        </el-table>
      </el-card>

      <el-card class="section-card">
        <template #header><div class="section-title">奖惩记录</div></template>
        <el-table :data="cadreData.rewards" border size="small">
          <el-table-column prop="type" label="类型" width="80" align="center">
            <template #default="{ row }"><el-tag :type="row.type === '奖励' ? 'success' : 'danger'" size="small">{{ row.type }}</el-tag></template>
          </el-table-column>
          <el-table-column prop="name" label="名称" min-width="200" />
          <el-table-column prop="org" label="授予单位" min-width="150" />
          <el-table-column prop="date" label="日期" width="110" align="center" />
          <el-table-column prop="level" label="级别" width="90" align="center" />
        </el-table>
      </el-card>

      <el-card class="section-card">
        <template #header><div class="section-title">家庭成员</div></template>
        <el-table :data="cadreData.family" border size="small">
          <el-table-column prop="relation" label="关系" width="80" align="center" />
          <el-table-column prop="name" label="姓名" width="100" align="center" />
          <el-table-column prop="gender" label="性别" width="60" align="center" />
          <el-table-column prop="birthDate" label="出生日期" width="110" align="center" />
          <el-table-column prop="politicalStatus" label="政治面貌" width="100" align="center" />
          <el-table-column prop="workUnit" label="工作单位" min-width="180" show-overflow-tooltip />
        </el-table>
      </el-card>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

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

const cadreData = computed(() => cadreDataMap[userStore.realName] || null)
</script>

<style scoped>
.section-card {
  margin-bottom: 16px;
}
.section-title {
  font-size: 14px;
  font-weight: bold;
  color: #1976D2;
}
</style>
