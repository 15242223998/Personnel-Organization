<template>
  <el-container class="layout-container">
    <!-- 顶部蓝色导航栏 -->
    <el-header class="top-header">
      <div class="header-left">
        <el-icon class="hamburger-btn" @click="mobileMenuVisible = !mobileMenuVisible"><Expand /></el-icon>
        <div class="logo-icon">
          <svg viewBox="0 0 24 24" width="28" height="28" fill="white">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
          </svg>
        </div>
        <span class="sys-name">辽宁某某大学 - 组织人事档案管理系统</span>
      </div>
      <div class="header-right">
        <el-popover
          placement="bottom-end"
          :width="360"
          trigger="click"
          popper-class="msg-popover"
        >
          <template #reference>
            <el-badge :value="unreadCount" :hidden="unreadCount===0" class="msg-badge">
              <span class="header-link"><el-icon><Bell /></el-icon> 消息通知</span>
            </el-badge>
          </template>
          <div class="msg-panel">
            <div class="msg-panel-header">
              <span>消息通知（{{ unreadCount }}条未读）</span>
              <span class="msg-header-tools">
                <el-icon class="msg-refresh" title="刷新通知" @click="refreshNotices"><Refresh /></el-icon>
                <span class="msg-read-all" @click="markAllRead">全部已读</span>
              </span>
            </div>
            <div class="msg-list">
              <div
                v-for="item in notifications"
                :key="item.id"
                class="msg-item"
                :class="{ unread: !item.read }"
                @click="handleMsgClick(item)"
              >
                <div class="msg-dot" v-if="!item.read"></div>
                <div class="msg-icon-wrap" :style="{ background: item.color }">
                  <el-icon :size="18"><component :is="item.icon" /></el-icon>
                </div>
                <div class="msg-body">
                  <div class="msg-title">{{ item.title }}</div>
                  <div class="msg-desc">{{ item.desc }}</div>
                  <div class="msg-time">{{ fmtTime(item.time) }}</div>
                </div>
              </div>
              <div v-if="!notifications.length" class="msg-empty">暂无通知</div>
            </div>
            <div class="msg-panel-footer" @click="viewAllMessages">查看全部消息</div>
          </div>
        </el-popover>
        <el-dropdown>
          <span class="header-link">
            <el-icon><UserFilled /></el-icon>
            {{ userStore.username }}
            <el-icon><ArrowDown /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="goProfile">个人信息</el-dropdown-item>
              <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </el-header>

    <el-container class="main-container">
      <!-- 左侧菜单 -->
      <div class="mobile-overlay" :class="{ show: mobileMenuVisible }" @click.self="mobileMenuVisible = false">
        <el-aside width="200px" class="left-aside">
        <el-menu
          :default-active="$route.path"
          :default-openeds="openedGroups"
          class="side-menu"
          background-color="#fff"
          text-color="#333"
          active-text-color="#fff"
          router
        >
          <el-menu-item index="/dashboard">
            <el-icon><HomeFilled /></el-icon><span>首页</span>
          </el-menu-item>
          <el-menu-item index="/statistics">
            <el-icon><PieChart /></el-icon><span>统计分析</span>
          </el-menu-item>
          <el-menu-item index="/cadre/declaration">
            <el-icon><UserFilled /></el-icon><span>个人信息申报</span>
          </el-menu-item>
          <el-sub-menu index="org">
            <template #title>
              <el-icon><OfficeBuilding /></el-icon><span>组织机构管理</span>
            </template>
            <el-menu-item index="/organization"><el-icon><OfficeBuilding /></el-icon>机构管理</el-menu-item>
            <el-menu-item index="/organization/leadership"><el-icon><UserFilled /></el-icon>班子管理</el-menu-item>
            <el-menu-item index="/position-level"><el-icon><Grid /></el-icon>职务层次</el-menu-item>
            <el-menu-item index="/rank"><el-icon><Medal /></el-icon>职级管理</el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="cadre">
            <template #title>
              <el-icon><UserFilled /></el-icon><span>干部信息管理</span>
            </template>
            <el-menu-item index="/cadre/onjob"><el-icon><UserFilled /></el-icon>在职干部库</el-menu-item>
            <el-menu-item index="/cadre/former"><el-icon><Switch /></el-icon>原任干部库</el-menu-item>
            <el-menu-item index="/cadre/retired"><el-icon><Timer /></el-icon>离退休干部库</el-menu-item>
            <el-menu-item index="/cadre/reserve"><el-icon><Star /></el-icon>后备干部库</el-menu-item>
            <el-menu-item index="/cadre/young"><el-icon><Sunny /></el-icon>年轻干部库</el-menu-item>
          </el-sub-menu>
          <el-menu-item index="/transfer">
            <el-icon><Switch /></el-icon><span>干部调配管理</span>
          </el-menu-item>
          <el-menu-item index="/promotion">
            <el-icon><Top /></el-icon><span>职级晋升管理</span>
          </el-menu-item>
          <el-menu-item index="/appointment">
            <el-icon><Stamp /></el-icon><span>干部任免管理</span>
          </el-menu-item>
          <el-menu-item index="/evaluation">
            <el-icon><EditPen /></el-icon><span>干部考察评价管理</span>
          </el-menu-item>
          <el-sub-menu index="supervision">
            <template #title>
              <el-icon><WarningFilled /></el-icon><span>干部监督管理</span>
            </template>
            <el-menu-item index="/supervision/integrity"><el-icon><DocumentChecked /></el-icon>廉政意见</el-menu-item>
            <el-menu-item index="/supervision/complaint"><el-icon><Message /></el-icon>信访举报</el-menu-item>
            <el-menu-item index="/supervision/personal"><el-icon><Notebook /></el-icon>个人事项报告</el-menu-item>
            <el-menu-item index="/supervision/alert"><el-icon><Warning /></el-icon>智能预警分析</el-menu-item>
            <el-menu-item index="/supervision/admonish"><el-icon><ChatDotRound /></el-icon>提醒函询诫勉</el-menu-item>
            <el-menu-item index="/supervision/audit"><el-icon><Coin /></el-icon>经济责任审计</el-menu-item>
          </el-sub-menu>
          <el-menu-item index="/assessment">
            <el-icon><DataAnalysis /></el-icon><span>干部考核管理</span>
          </el-menu-item>
          <el-menu-item index="/daily">
            <el-icon><Calendar /></el-icon><span>日常事务管理</span>
          </el-menu-item>
          <el-sub-menu index="sys">
            <template #title>
              <el-icon><Setting /></el-icon><span>系统管理</span>
            </template>
            <el-menu-item index="/system/user"><el-icon><User /></el-icon>用户管理</el-menu-item>
            <el-menu-item index="/system/dict"><el-icon><Collection /></el-icon>字典管理</el-menu-item>
            <el-menu-item index="/system/approval"><el-icon><Finished /></el-icon>审批事项管理</el-menu-item>
            <el-menu-item index="/system/policy"><el-icon><Files /></el-icon>政策法规管理</el-menu-item>
            <el-menu-item index="/system/alert-rule"><el-icon><Bell /></el-icon>预警规则管理</el-menu-item>
            <el-menu-item index="/system/declaration-approval"><el-icon><DocumentChecked /></el-icon>信息申报审批</el-menu-item>
            <el-menu-item v-if="isAdmin" index="/system/register-approval"><el-icon><CircleCheck /></el-icon>注册审批</el-menu-item>
            <el-menu-item v-if="isAdmin" index="/system/grant"><el-icon><Key /></el-icon>权限授予</el-menu-item>
            <el-menu-item index="/system/log"><el-icon><Tickets /></el-icon>系统日志</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>
      </div>

      <el-container class="content-container">
        <!-- 标签页栏 -->
        <div class="tabs-bar">
          <span
            v-for="tab in tabs"
            :key="tab.path"
            class="tab-item"
            :class="{ active: $route.path === tab.path }"
            @click="switchTab(tab)"
          >
            {{ tab.title }}
            <el-icon
              v-if="tab.path !== '/dashboard'"
              class="tab-close"
              @click.stop="closeTab(tab)"
            >
              <Close />
            </el-icon>
          </span>
        </div>
        <!-- 内容区 -->
        <el-main class="content-main">
          <div v-if="blocked" class="perm-block">
            <el-icon class="perm-block-icon" :size="46"><Lock /></el-icon>
            <div class="perm-block-text">该账号未拥有“{{ permLabel }}”权限，请联系管理员处理</div>
          </div>
          <router-view v-else />
        </el-main>
      </el-container>
    </el-container>

    <ExportDialog />
  </el-container>
</template>

<script setup>
import { ref, computed, watch, onMounted, markRaw } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../stores/user'
import request from '../utils/request'
import ExportDialog from '../components/ExportDialog.vue'
import { ElMessage } from 'element-plus'
import { Bell, UserFilled, ArrowDown, Close, HomeFilled, OfficeBuilding, Switch, Top, Stamp, WarningFilled, DataAnalysis, Calendar, PieChart, Setting, Document, User, CircleCheck, Warning, EditPen, Expand, Grid, Medal, Timer, Star, Sunny, DocumentChecked, Message, Notebook, ChatDotRound, Coin, Collection, Finished, Files, Tickets, Key, Lock, Refresh } from '@element-plus/icons-vue'
import { matchPermKey, PERM_KEYS } from '../utils/perms'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isAdmin = computed(() => userStore.userType === 'admin')

// ====== 模块级权限拦截：菜单可见，进入未授权模块时右侧内容区渲染灰色占位 ======
const permKey = computed(() => matchPermKey(route.path))
const permLabel = computed(() => PERM_KEYS.find(p => p.key === permKey.value)?.label || route.meta.title || '')
const blocked = computed(() => !isAdmin.value && !!permKey.value && !userStore.permissions.includes(permKey.value))

const openedGroups = ['cadre']
const mobileMenuVisible = ref(false)

// ========== 消息通知（实时汇总自真实业务数据） ==========
const notifications = ref([])

const msgStyleMap = {
  register: { icon: CircleCheck, color: '#9C27B0', path: '/system/register-approval' },
  scheme: { icon: DataAnalysis, color: '#1976D2', path: '/assessment' },
  leave: { icon: Stamp, color: '#1976D2', path: '/daily' },
  cert: { icon: Document, color: '#FB8C00', path: '/daily' },
  abroad: { icon: Switch, color: '#E53935', path: '/daily' },
  alert: { icon: WarningFilled, color: '#E53935', path: '/dashboard' },
  application: { icon: DocumentChecked, color: '#2E7D32', path: '/cadre/declaration' }
}

// 从 localStorage 恢复已读状态（按通知 id）
const readIds = new Set(JSON.parse(localStorage.getItem('msg_read_ids') || '[]'))

async function loadNotices() {
  try {
    const res = await request({ url: '/notice/list', method: 'get' })
    // 未读永远排最前；同读状态下按时间倒序
    notifications.value = (res.data || []).map(n => {
      const style = msgStyleMap[n.type] || msgStyleMap.leave
      return {
        id: n.id,
        title: n.title,
        desc: n.desc,
        time: n.time,
        type: n.type,
        path: n.path || style.path,
        read: readIds.has(n.id),
        icon: style.icon,
        color: style.color
      }
    }).sort((a, b) => {
      if (a.read !== b.read) return a.read ? 1 : -1
      return (new Date(String(b.time).replace(' ', 'T')).getTime() || 0)
        - (new Date(String(a.time).replace(' ', 'T')).getTime() || 0)
    })
  } catch {
    notifications.value = []
  }
}

onMounted(loadNotices)

// 手动刷新消息通知
async function refreshNotices() {
  await loadNotices()
  ElMessage.success('通知已刷新')
}

// 由真实时间计算友好展示：刚刚/xx分钟前/xx小时前/xx天前，超过7天显示日期
function fmtTime(t) {
  if (!t) return ''
  const date = new Date(String(t).replace(' ', 'T'))
  if (isNaN(date.getTime())) return String(t)
  const diff = Date.now() - date.getTime()
  const minute = 60 * 1000
  const hour = 60 * minute
  const day = 24 * hour
  if (diff < minute) return '刚刚'
  if (diff < hour) return Math.floor(diff / minute) + '分钟前'
  if (diff < day) return Math.floor(diff / hour) + '小时前'
  if (diff < 7 * day) return Math.floor(diff / day) + '天前'
  const p = n => String(n).padStart(2, '0')
  return `${date.getFullYear()}-${p(date.getMonth() + 1)}-${p(date.getDate())}`
}

const unreadCount = computed(() => notifications.value.filter(n => !n.read).length)

const tabs = ref([
  { path: '/dashboard', title: '首页' }
])

watch(() => route.path, (path) => {
  if (!path) return
  const title = route.meta.title || '页面'
  const exist = tabs.value.find(t => t.path === path)
  if (!exist) {
    tabs.value.push({ path, title })
  }
}, { immediate: true })

function switchTab(tab) {
  router.push(tab.path)
}

function closeTab(tab) {
  const idx = tabs.value.findIndex(t => t.path === tab.path)
  if (idx > -1) {
    tabs.value.splice(idx, 1)
    if (route.path === tab.path) {
      const next = tabs.value[idx - 1] || tabs.value[0]
      router.push(next.path)
    }
  }
}

function markAllRead() {
  notifications.value.forEach(n => n.read = true)
  localStorage.setItem('msg_read_ids', JSON.stringify(notifications.value.map(n => n.id)))
  sortNoticesOrder()
}

function handleMsgClick(item) {
  item.read = true
  localStorage.setItem('msg_read_ids', JSON.stringify(notifications.value.filter(n => n.read).map(n => n.id)))
  sortNoticesOrder()
  if (item.path) {
    router.push(item.path)
  }
}

function viewAllMessages() {
  // 可跳转到消息中心页面，目前跳转到dashboard
  router.push('/dashboard')
}

function goProfile() {
  router.push('/profile')
}

function logout() {
  localStorage.removeItem('token')
  userStore.clearUser()
  router.push('/login')
}
</script>

<style>
html, body, #app {
  margin: 0;
  padding: 0;
  height: 100%;
  font-family: "Microsoft YaHei", "微软雅黑", -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 13px;
  color: #333;
  overflow-y: scroll;
  overflow-x: hidden;
}
body {
  padding-right: 0 !important;
}
.el-popup-parent--hidden {
  padding-right: 0 !important;
}
.msg-popover {
  padding: 0 !important;
  border-radius: 6px !important;
  min-width: 380px !important;
  overflow: hidden;
  box-shadow: 0 6px 24px rgba(0,0,0,0.12) !important;
}
.msg-popover .el-popover__content {
  padding: 0 !important;
}
.msg-panel {
  font-size: 13px;
  width: 100%;
}
.msg-panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #f5f7fa;
  border-bottom: 1px solid #e8e8e8;
  font-weight: bold;
  color: #333;
  font-size: 14px;
}
.msg-header-tools {
  display: flex;
  align-items: center;
  gap: 12px;
}
.msg-refresh {
  font-size: 15px;
  color: #1976D2;
  cursor: pointer;
  font-weight: normal;
}
.msg-refresh:hover {
  color: #42A5F5;
}
.msg-read-all {
  font-size: 12px;
  color: #1976D2;
  cursor: pointer;
  font-weight: normal;
}
.msg-read-all:hover {
  color: #42A5F5;
  text-decoration: underline;
}
.msg-list {
  max-height: 320px;
  overflow-y: auto;
}
.msg-empty {
  padding: 24px 0;
  text-align: center;
  color: #999;
}
.msg-item {
  display: flex;
  align-items: flex-start;
  padding: 14px 16px 14px 22px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  position: relative;
  transition: background 0.15s;
}
.msg-item:hover {
  background: #E3F2FD;
}
.msg-item.unread {
  background: #fafcff;
}
.msg-dot {
  position: absolute;
  top: 18px;
  left: 10px;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #FF5252;
  z-index: 1;
}
.msg-icon-wrap {
  flex: 0 0 36px;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 18px;
  align-self: flex-start;
  flex-shrink: 0;
  overflow: hidden;
  box-sizing: border-box;
  margin-right: 12px;
}
.msg-icon-wrap .el-icon {
  font-size: 18px;
  width: 18px;
  height: 18px;
}
.msg-icon-wrap .el-icon svg {
  width: 18px;
  height: 18px;
}
.msg-body {
  flex: 1;
  min-width: 0;
  overflow: hidden;
}
.msg-title {
  font-size: 13px;
  font-weight: 600;
  color: #333;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.msg-item.unread .msg-title {
  color: #1976D2;
}
.msg-desc {
  font-size: 12px;
  color: #666;
  line-height: 1.6;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  word-break: break-all;
}
.msg-time {
  font-size: 11px;
  color: #999;
  margin-top: 6px;
}
.msg-panel-footer {
  text-align: center;
  padding: 10px;
  color: #1976D2;
  cursor: pointer;
  font-size: 12px;
  border-top: 1px solid #e8e8e8;
  background: #fafbfc;
}
.msg-panel-footer:hover {
  background: #E3F2FD;
}
</style>

<style scoped>
.layout-container {
  height: 100vh;
  width: 100%;
}

/* ====== 顶栏 ====== */
.top-header {
  height: 50px !important;
  background: linear-gradient(90deg, #1976D2 0%, #2196F3 100%);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  z-index: 100;
}
.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.logo-icon {
  width: 34px;
  height: 34px;
  background: rgba(255,255,255,0.2);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.sys-name {
  font-size: 18px;
  font-weight: bold;
  letter-spacing: 1px;
}
.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}
.header-link {
  color: #fff;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
}
.header-link:hover {
  color: #BBDEFB;
}
.msg-badge :deep(.el-badge__content) {
  background-color: #FF5252;
  border: none;
}

/* ====== 主容器 ====== */
.main-container {
  height: calc(100vh - 50px);
}

/* ====== 左侧菜单 ====== */
.left-aside {
  background: #fff;
  border-right: 1px solid #e0e0e0;
  overflow-y: auto;
}
.side-menu {
  border-right: none !important;
  font-size: 13px;
}
.side-menu :deep(.el-menu-item),
.side-menu :deep(.el-sub-menu__title) {
  height: 38px;
  line-height: 38px;
  padding: 0 16px !important;
}
.side-menu :deep(.el-menu-item .el-icon),
.side-menu :deep(.el-sub-menu__title .el-icon) {
  margin-right: 6px;
  font-size: 16px;
  vertical-align: -2px;
}
.side-menu :deep(.el-menu-item.is-active) {
  background-color: #1976D2 !important;
  color: #fff !important;
  border-radius: 0;
}
.side-menu :deep(.el-menu-item:hover:not(.is-active)),
.side-menu :deep(.el-sub-menu__title:hover) {
  background-color: #E3F2FD !important;
  color: #1976D2 !important;
}
.side-menu :deep(.el-sub-menu .el-menu-item) {
  padding-left: 48px !important;
  background-color: #fafcff;
  min-width: auto;
}
.side-menu :deep(.el-sub-menu .el-menu-item .el-icon) {
  font-size: 14px;
  margin-right: 8px;
}
.side-menu :deep(.el-sub-menu .el-menu-item.is-active) {
  background-color: #1976D2 !important;
}

/* ====== 标签页 ====== */
.content-container {
  background: #f5f7fa;
  flex-direction: column !important;
  overflow: hidden;
}
.tabs-bar {
  height: 32px;
  background: #fff;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  align-items: center;
  padding: 0 8px;
  overflow-x: auto;
  overflow-y: hidden;
  white-space: nowrap;
  flex-shrink: 0;
  width: 100%;
}
.tab-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  height: 24px;
  padding: 0 10px;
  margin-right: 4px;
  background: #f0f2f5;
  border: 1px solid #e0e0e0;
  border-radius: 2px;
  font-size: 12px;
  color: #666;
  cursor: pointer;
  flex-shrink: 0;
}
.tab-item.active {
  background: #1976D2;
  color: #fff;
  border-color: #1976D2;
}
.tab-close {
  font-size: 12px;
  border-radius: 50%;
  width: 14px;
  height: 14px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.tab-close:hover {
  background: rgba(0,0,0,0.15);
}
.tab-item.active .tab-close:hover {
  background: rgba(255,255,255,0.3);
}

/* ====== 内容区 ====== */
.content-main {
  padding: 12px !important;
  background: #f5f7fa;
  overflow-y: auto;
  flex: 1;
  min-width: 0;
}
.content-main > div {
  min-width: 0;
}

/* ====== 无权限灰色占位 ====== */
.perm-block {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  height: 100%;
  min-height: 420px;
  background: #eceff3;
  border-radius: 6px;
  color: #999;
}
.perm-block-icon {
  color: #bfbfbf;
}
.perm-block-text {
  font-size: 15px;
  color: #999;
  letter-spacing: 0.5px;
}

/* ====== 移动端适配 ====== */
@media (max-width: 768px) {
  .top-header {
    padding: 0 10px;
  }
  .sys-name {
    font-size: 15px;
  }
  .hamburger-btn {
    display: inline-flex !important;
    font-size: 22px;
    cursor: pointer;
    color: #fff;
    margin-right: 6px;
  }
  .header-right {
    gap: 10px;
  }
  .header-link {
    font-size: 12px;
  }
  /* 消息弹窗全宽 */
  .msg-popover {
    min-width: 100vw !important;
    width: 100vw !important;
    left: 0 !important;
    border-radius: 0 !important;
  }

  .main-container {
    position: relative;
  }
  .mobile-overlay {
    position: fixed;
    top: 50px;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 200;
    pointer-events: none;
    background: transparent;
    transition: background 0.25s;
  }
  .mobile-overlay.show {
    pointer-events: auto;
    background: rgba(0,0,0,0.35);
  }
  .left-aside {
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    z-index: 201;
    transform: translateX(-100%);
    transition: transform 0.25s;
    box-shadow: 2px 0 12px rgba(0,0,0,0.15);
    flex-shrink: 0;
  }
  .mobile-overlay.show .left-aside {
    transform: translateX(0);
  }
  .tabs-bar {
    display: none;
  }
  .content-main {
    padding: 8px !important;
  }
}
.hamburger-btn {
  display: none;
}
</style>
