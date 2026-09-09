import { createRouter, createWebHistory } from 'vue-router'
import Layout from '../layout/Layout.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { noAuth: true }
  },
  {
    path: '/tablet',
    name: 'TabletVote',
    component: () => import('../views/assessment/TabletVote.vue'),
    meta: { title: '平板投票' }
  },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/Dashboard.vue'), meta: { title: '首页' } },
      { path: 'profile', name: 'Profile', component: () => import('../views/cadre/Profile.vue'), meta: { title: '个人信息' } },
      { path: 'organization', name: 'Organization', component: () => import('../views/organization/Index.vue'), meta: { title: '组织机构管理' } },
      { path: 'organization/leadership', name: 'Leadership', component: () => import('../views/organization/Leadership.vue'), meta: { title: '班子管理' } },
      { path: 'position-level', name: 'PositionLevel', component: () => import('../views/organization/PositionLevel.vue'), meta: { title: '职务层次管理' } },
      { path: 'rank', name: 'Rank', component: () => import('../views/organization/Rank.vue'), meta: { title: '职级管理' } },
      { path: 'cadre', redirect: '/cadre/onjob' },
      { path: 'cadre/onjob', name: 'CadreOnJob', component: () => import('../views/cadre/List.vue'), meta: { title: '在职干部库' } },
      { path: 'cadre/former', name: 'CadreFormer', component: () => import('../views/cadre/List.vue'), meta: { title: '原任干部库' } },
      { path: 'cadre/retired', name: 'CadreRetired', component: () => import('../views/cadre/List.vue'), meta: { title: '离退休干部库' } },
      { path: 'cadre/reserve', name: 'CadreReserve', component: () => import('../views/cadre/Reserve.vue'), meta: { title: '后备干部库' } },
      { path: 'cadre/young', name: 'CadreYoung', component: () => import('../views/cadre/List.vue'), meta: { title: '年轻干部库' } },
      { path: 'cadre/declaration', name: 'CadreDeclaration', component: () => import('../views/cadre/Declaration.vue'), meta: { title: '个人基础信息申报' } },
      { path: 'cadre/:id', name: 'CadreDetail', component: () => import('../views/cadre/Detail.vue'), meta: { title: '干部详情' } },
      { path: 'transfer', name: 'Transfer', component: () => import('../views/transfer/Index.vue'), meta: { title: '干部调配管理' } },
      { path: 'promotion', name: 'Promotion', component: () => import('../views/transfer/Promotion.vue'), meta: { title: '职级晋升管理' } },
      { path: 'appointment', name: 'Appointment', component: () => import('../views/appointment/Index.vue'), meta: { title: '干部任免管理' } },
      { path: 'evaluation', name: 'Evaluation', component: () => import('../views/appointment/Evaluation.vue'), meta: { title: '干部考察评价管理' } },
      { path: 'supervision', redirect: '/supervision/integrity' },
      { path: 'supervision/integrity', name: 'SupervisionIntegrity', component: () => import('../views/supervision/Index.vue'), meta: { title: '廉政意见' } },
      { path: 'supervision/complaint', name: 'SupervisionComplaint', component: () => import('../views/supervision/Index.vue'), meta: { title: '信访举报' } },
      { path: 'supervision/personal', name: 'SupervisionPersonal', component: () => import('../views/supervision/Index.vue'), meta: { title: '个人事项报告' } },
      { path: 'supervision/alert', name: 'SupervisionAlert', component: () => import('../views/supervision/Index.vue'), meta: { title: '智能预警分析' } },
      { path: 'supervision/admonish', name: 'SupervisionAdmonish', component: () => import('../views/supervision/Index.vue'), meta: { title: '提醒函询诫勉' } },
      { path: 'supervision/audit', name: 'SupervisionAudit', component: () => import('../views/supervision/Index.vue'), meta: { title: '经济责任审计' } },
      { path: 'assessment', name: 'Assessment', component: () => import('../views/assessment/Index.vue'), meta: { title: '干部考核管理' } },
      { path: 'daily', name: 'Daily', component: () => import('../views/daily/Index.vue'), meta: { title: '日常事务管理' } },
      { path: 'statistics', name: 'Statistics', component: () => import('../views/statistics/Index.vue'), meta: { title: '统计分析' } },
      { path: 'system/user', name: 'SysUser', component: () => import('../views/system/User.vue'), meta: { title: '用户管理' } },
      { path: 'system/dict', name: 'SysDict', component: () => import('../views/system/Dict.vue'), meta: { title: '字典管理' } },
      { path: 'system/log', name: 'SysLog', component: () => import('../views/system/Log.vue'), meta: { title: '系统日志' } },
      { path: 'system/approval', name: 'SysApproval', component: () => import('../views/system/Approval.vue'), meta: { title: '审批事项管理' } },
      { path: 'system/policy', name: 'SysPolicy', component: () => import('../views/system/Policy.vue'), meta: { title: '政策法规管理' } },
      { path: 'system/alert-rule', name: 'SysAlertRule', component: () => import('../views/system/AlertRule.vue'), meta: { title: '预警规则管理' } },
      { path: 'system/declaration-approval', name: 'DeclarationApproval', component: () => import('../views/system/DeclarationApproval.vue'), meta: { title: '信息申报审批' } },
      { path: 'system/register-approval', name: 'RegisterApproval', component: () => import('../views/system/RegisterApproval.vue'), meta: { title: '注册审批' } },
      { path: 'system/grant', name: 'PermissionGrant', component: () => import('../views/system/PermissionGrant.vue'), meta: { title: '权限授予' } }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (!to.meta.noAuth && !token) {
    next('/login')
  } else if (to.path === '/login' && token) {
    next('/')
  } else {
    next()
  }
})

export default router
