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
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/Dashboard.vue'), meta: { title: '首页' } },
      { path: 'organization', name: 'Organization', component: () => import('../views/organization/Index.vue'), meta: { title: '组织机构管理' } },
      { path: 'position-level', name: 'PositionLevel', component: () => import('../views/organization/PositionLevel.vue'), meta: { title: '职务层次管理' } },
      { path: 'rank', name: 'Rank', component: () => import('../views/organization/Rank.vue'), meta: { title: '职级管理' } },
      { path: 'cadre', name: 'CadreList', component: () => import('../views/cadre/List.vue'), meta: { title: '干部信息管理' } },
      { path: 'cadre/:id', name: 'CadreDetail', component: () => import('../views/cadre/Detail.vue'), meta: { title: '干部详情' } },
      { path: 'cadre-reserve', name: 'CadreReserve', component: () => import('../views/cadre/Reserve.vue'), meta: { title: '后备干部库' } },
      { path: 'transfer', name: 'Transfer', component: () => import('../views/transfer/Index.vue'), meta: { title: '干部调配管理' } },
      { path: 'promotion', name: 'Promotion', component: () => import('../views/transfer/Promotion.vue'), meta: { title: '职级晋升管理' } },
      { path: 'appointment', name: 'Appointment', component: () => import('../views/appointment/Index.vue'), meta: { title: '干部任免管理' } },
      { path: 'supervision', name: 'Supervision', component: () => import('../views/supervision/Index.vue'), meta: { title: '干部监督管理' } },
      { path: 'assessment', name: 'Assessment', component: () => import('../views/assessment/Index.vue'), meta: { title: '干部考核管理' } },
      { path: 'daily', name: 'Daily', component: () => import('../views/daily/Index.vue'), meta: { title: '日常事务管理' } },
      { path: 'statistics', name: 'Statistics', component: () => import('../views/statistics/Index.vue'), meta: { title: '统计分析' } },
      { path: 'system/user', name: 'SysUser', component: () => import('../views/system/User.vue'), meta: { title: '用户管理' } },
      { path: 'system/role', name: 'SysRole', component: () => import('../views/system/Role.vue'), meta: { title: '角色管理' } },
      { path: 'system/dict', name: 'SysDict', component: () => import('../views/system/Dict.vue'), meta: { title: '字典管理' } },
      { path: 'system/log', name: 'SysLog', component: () => import('../views/system/Log.vue'), meta: { title: '操作日志' } }
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
