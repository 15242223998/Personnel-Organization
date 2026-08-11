<template>
  <el-container class="layout-container">
    <!-- 顶部蓝色导航栏 -->
    <el-header class="top-header">
      <div class="header-left">
        <div class="logo-icon">
          <svg viewBox="0 0 24 24" width="28" height="28" fill="white">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
          </svg>
        </div>
        <span class="sys-name">组织人事档案系统</span>
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
              <span class="msg-read-all" @click="markAllRead">全部已读</span>
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
                  <div class="msg-time">{{ item.time }}</div>
                </div>
              </div>
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
              <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </el-header>

    <el-container class="main-container">
      <!-- 左侧菜单 -->
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
          <el-sub-menu index="org">
            <template #title>
              <el-icon><OfficeBuilding /></el-icon><span>组织机构管理</span>
            </template>
            <el-menu-item index="/organization">机构管理</el-menu-item>
            <el-menu-item index="/position-level">职务层次</el-menu-item>
            <el-menu-item index="/rank">职级管理</el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="cadre">
            <template #title>
              <el-icon><UserFilled /></el-icon><span>干部信息管理</span>
            </template>
            <el-menu-item index="/cadre">干部信息</el-menu-item>
            <el-menu-item index="/cadre-reserve">后备干部库</el-menu-item>
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
          <el-menu-item index="/supervision">
            <el-icon><WarningFilled /></el-icon><span>干部监督管理</span>
          </el-menu-item>
          <el-menu-item index="/assessment">
            <el-icon><DataAnalysis /></el-icon><span>干部考核管理</span>
          </el-menu-item>
          <el-menu-item index="/daily">
            <el-icon><Calendar /></el-icon><span>日常事务管理</span>
          </el-menu-item>
          <el-menu-item index="/statistics">
            <el-icon><PieChart /></el-icon><span>统计分析</span>
          </el-menu-item>
          <el-sub-menu index="sys">
            <template #title>
              <el-icon><Setting /></el-icon><span>系统管理</span>
            </template>
            <el-menu-item index="/system/user">用户管理</el-menu-item>
            <el-menu-item index="/system/role">角色管理</el-menu-item>
            <el-menu-item index="/system/dict">字典管理</el-menu-item>
            <el-menu-item index="/system/log">系统日志</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>

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
          <router-view />
        </el-main>
      </el-container>
    </el-container>

    <ExportDialog />
  </el-container>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../stores/user'
import ExportDialog from '../components/ExportDialog.vue'
import { Bell, UserFilled, ArrowDown, Close, HomeFilled, OfficeBuilding, Switch, Top, Stamp, WarningFilled, DataAnalysis, Calendar, PieChart, Setting, Document, User, CircleCheck, Warning } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const openedGroups = ['org', 'cadre', 'sys']

const notifications = ref([
  { id: 1, title: '任免流程待审批', desc: '机械工程学院副院长任免流程进入讨论决定环节，需您审批', time: '10分钟前', read: false, icon: Stamp, color: '#1976D2', path: '/appointment' },
  { id: 2, title: '考核预警提醒', desc: '电子信息学院3名干部年度考核材料尚未提交', time: '1小时前', read: false, icon: Warning, color: '#E53935', path: '/assessment' },
  { id: 3, title: '调配申请待处理', desc: '王志强提交轮岗调配申请，请及时处理', time: '2小时前', read: false, icon: Switch, color: '#FB8C00', path: '/transfer' },
  { id: 4, title: '证照到期提醒', desc: '刘德明等2人的因公护照将于30日内到期', time: '昨天', read: true, icon: Document, color: '#43A047', path: '/daily' },
  { id: 5, title: '休假审批通过', desc: '您提交的年休假申请已审批通过', time: '2天前', read: true, icon: CircleCheck, color: '#9C27B0', path: '/daily' }
])

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
}

function handleMsgClick(item) {
  item.read = true
  if (item.path) {
    router.push(item.path)
  }
}

function viewAllMessages() {
  // 可跳转到消息中心页面，目前跳转到dashboard
  router.push('/dashboard')
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
  max-height: 380px;
  overflow-y: auto;
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
  padding-left: 42px !important;
  background-color: #fafcff;
  min-width: auto;
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
</style>
