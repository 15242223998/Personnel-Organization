<template>
  <div class="login-page">
    <div class="login-bg">
      <div class="login-box">
        <div class="login-title">
          <div class="logo-area">
            <svg viewBox="0 0 24 24" width="42" height="42" fill="white">
              <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
            </svg>
          </div>
          <h1>辽宁某某大学 - 组织人事档案管理系统</h1>
          <p>辽宁某某大学 · 智慧组织人事管理平台</p>
        </div>
        <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form">
          <el-form-item prop="username">
            <el-input v-model="loginForm.username" placeholder="用户名" size="large">
              <template #prefix><el-icon><User /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item prop="password">
            <el-input v-model="loginForm.password" type="password" placeholder="密码" size="large" @keyup.enter="handleLogin" show-password>
              <template #prefix><el-icon><Lock /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" size="large" style="width:100%" :loading="loading" @click="handleLogin">登 录</el-button>
          </el-form-item>
        </el-form>
        <div class="register-link">
          <span @click="openRegister">没有账号？立即注册</span>
        </div>
        <div class="conn-link">
          <span @click="openConn"><el-icon style="vertical-align:-2px"><Connection /></el-icon> 连接到服务器</span>
        </div>
        <div class="login-footer">© 2026 辽宁某某大学 - 组织人事档案管理系统 版权所有</div>
      </div>
    </div>

    <el-dialog title="连接到服务器" v-model="connVisible" width="560px">
      <el-tabs v-model="connTab">
        <!-- 面板一：数据库连接（数据库热切换为主） -->
        <el-tab-pane label="数据库连接" name="db">
          <el-form label-width="92px">
            <el-form-item label="服务器地址" required>
              <el-input v-model="dbHost" placeholder="MySQL 主机（后端可达），如 localhost / 192.168.1.100" />
            </el-form-item>
            <el-form-item label="端口" required>
              <el-input-number v-model="dbPort" :min="1" :max="65535" controls-position="right" style="width:100%" />
            </el-form-item>
            <el-form-item label="数据库名" required>
              <el-input v-model="dbName" placeholder="POP" />
            </el-form-item>
            <el-form-item label="账号" required>
              <el-input v-model="dbUser" placeholder="root" />
            </el-form-item>
            <el-form-item label="密码" required>
              <el-input v-model="dbPass" type="password" placeholder="数据库密码" show-password />
            </el-form-item>
            <div class="conn-tip">
              <p>用于把后端主数据源热切换到该 MySQL 实例/库（不改动已有数据库的数据；全新库可一键对齐建表）。</p>
              <p>默认值：localhost : 3306，库 POP，账号 root，密码 666666。</p>
            </div>
          </el-form>
        </el-tab-pane>
        <!-- 面板二：API 服务器（原有 serverConn 功能，仅改前端请求指向） -->
        <el-tab-pane label="API 服务器" name="api">
          <el-form label-width="96px">
            <el-form-item label="自定义服务器">
              <el-switch v-model="connEnabled" active-text="启用" inactive-text="使用系统默认" />
            </el-form-item>
            <template v-if="connEnabled">
              <el-form-item label="服务器地址" required>
                <el-input v-model="connAddress" placeholder="例如 http://192.168.1.100 或 http://localhost" />
              </el-form-item>
              <el-form-item label="端口">
                <el-input-number v-model="connPort" :min="1" :max="65535" controls-position="right" style="width:100%" />
              </el-form-item>
            </template>
            <div class="conn-tip">
              <template v-if="connEnabled">
                连接效果：{{ buildBase() }}<span v-if="connPort">:{{ connPort }}</span>/api（保存后即时生效，无需重启）
              </template>
              <template v-else>
                当前使用系统默认连接（开发环境自动代理到后端 8080；数据库切换默认也打到该后端）
              </template>
            </div>
          </el-form>
        </el-tab-pane>
      </el-tabs>
      <template #footer>
        <template v-if="connTab === 'db'">
          <el-button @click="resetDbForm">恢复默认</el-button>
          <el-button :loading="dbBusy" @click="checkDb">检查连接</el-button>
          <el-button type="primary" :loading="dbAligning" @click="alignAndConnect">对齐并连接</el-button>
        </template>
        <template v-else>
          <el-button @click="resetConn">恢复默认</el-button>
          <el-button :loading="connTesting" @click="testConn">测试连接</el-button>
          <el-button type="primary" @click="saveConn">保存并连接</el-button>
        </template>
      </template>
    </el-dialog>

    <el-dialog title="注册账号" v-model="registerVisible" width="440px" @close="resetRegister">
      <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" label-width="80px">
        <el-form-item label="账号" prop="username">
          <el-input v-model="registerForm.username" placeholder="请输入登录账号" />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="registerForm.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="registerForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="registerForm.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="registerForm.confirmPassword" type="password" placeholder="请再次输入密码" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="registerVisible = false">取消</el-button>
        <el-button type="primary" :loading="registerLoading" @click="handleRegister">提交申请</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, h } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Connection } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { login, register } from '../api/auth'
import { getServerBase } from '../utils/request'
import request from '../utils/request'

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: 'admin',
  password: '123456'
})

const loginRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

function handleLogin() {
  loginFormRef.value.validate((valid) => {
    if (!valid) return
    loading.value = true
    login(loginForm, { showError: false })
      .then(res => {
        const user = res.data
        const isAdmin = user.userType === 1
        localStorage.setItem('token', user.token)
        userStore.setUser(user.username, String(user.id), user.realName, isAdmin ? 'admin' : 'cadre', user.permissions)
        ElMessage.success(`欢迎，${user.realName || user.username}`)
        router.push('/')
      })
      .catch(err => {
        if (err.code === 4001 || err.code === 4002 || err.code === 4003) {
          ElMessageBox.alert(err.message, '登录提示', {
            type: 'warning',
            confirmButtonText: '知道了'
          })
        } else {
          ElMessage.error(err.message || '用户名或密码错误')
        }
      })
      .finally(() => {
        loading.value = false
      })
  })
}

const registerVisible = ref(false)
const registerLoading = ref(false)
const registerFormRef = ref(null)

// ============ 连接到服务器：数据库连接(热切换) + API服务器 ============
const connVisible = ref(false)
const connTab = ref('db')
const connEnabled = ref(false)
const connAddress = ref('http://localhost')
const connPort = ref(8080)
const connTesting = ref(false)
const CONN_KEY = 'serverConn'

// ---- 数据库连接面板（数据库热切换：probe/align/switch）----
const dbHost = ref('localhost')
const dbPort = ref(3306)
const dbName = ref('POP')
const dbUser = ref('root')
const dbPass = ref('666666')
const dbBusy = ref(false)
const dbAligning = ref(false)

function dbParams() {
  return {
    host: (dbHost.value || '').trim(),
    port: Number(dbPort.value) || 3306,
    db: (dbName.value || '').trim() || 'POP',
    username: (dbUser.value || '').trim(),
    password: dbPass.value || ''
  }
}

function resetDbForm() {
  dbHost.value = 'localhost'
  dbPort.value = 3306
  dbName.value = 'POP'
  dbUser.value = 'root'
  dbPass.value = '666666'
  ElMessage.success('已恢复数据库连接默认值')
}

// 规范化服务器地址（无协议自动补 http://，去尾部斜杠），不含端口
function buildBase() {
  let v = (connAddress.value || '').trim().replace(/\s/g, '')
  if (!v) return ''
  if (!/^https?:\/\//i.test(v)) v = 'http://' + v
  return v.replace(/\/+$/, '')
}

function openConn() {
  connTab.value = 'db'
  const saved = getServerBase()
  if (saved) {
    connEnabled.value = true
    try {
      const u = new URL(saved)
      connAddress.value = u.protocol + '//' + u.hostname
      connPort.value = Number(u.port) || 8080
    } catch {
      connAddress.value = saved
      connPort.value = 8080
    }
  } else {
    connEnabled.value = false
    connAddress.value = 'http://localhost'
    connPort.value = 8080
  }
  connVisible.value = true
}

function currentConn() {
  if (!connEnabled.value) return ''
  const base = buildBase()
  if (!base) return ''
  return connPort.value ? base + ':' + connPort.value : base
}

function saveConn() {
  if (!connEnabled.value) {
    localStorage.removeItem(CONN_KEY)
    connVisible.value = false
    ElMessage.success('已使用系统默认服务器连接')
    return
  }
  if (!buildBase()) {
    ElMessage.warning('请填写服务器地址')
    return
  }
  const full = currentConn()
  localStorage.setItem(CONN_KEY, JSON.stringify({ baseUrl: full }))
  connVisible.value = false
  ElMessage.success('已保存：后续请求将连接到 ' + full + '/api')
}

function resetConn() {
  localStorage.removeItem(CONN_KEY)
  connEnabled.value = false
  connAddress.value = 'http://localhost'
  connPort.value = 8080
  ElMessage.success('已恢复系统默认服务器连接')
}

// ---- 数据库连接：探测/对齐/切换 分支流程 ----

// 可滚动列表样式（缺表清单 / 即将创建表清单）
function listMessage(hint, items) {
  return h('div', null, [
    hint ? h('div', { style: 'color:#606266;font-size:13px;margin-bottom:6px;line-height:1.6;word-break:break-all' }, hint) : null,
    h('div', {
      style: 'max-height:200px;overflow-y:auto;border:1px solid #ebeef5;border-radius:4px;padding:6px 10px;background:#fafbfc'
    }, (items || []).map(n =>
      h('div', { style: 'font-size:12px;color:#303133;line-height:1.9;font-family:Consolas,Menlo,monospace' }, String(n))
    ))
  ])
}

function friendlyDbError(err) {
  if (err && err.code === 401) return '未登录或登录已过期：请先以系统管理员账号登录后，再执行数据库对齐/切换'
  if (err && err.code === 403) return '无权限：仅系统管理员可执行数据库对齐/切换'
  return (err && err.message) || '操作失败，请检查后端服务是否可用'
}

// 切换到目标库（热切换）
async function callSwitch() {
  try {
    await request({ url: '/db/switch', method: 'post', data: dbParams(), showError: false })
    ElMessage.success('已切换到 ' + (dbName.value || 'POP') + ' 库，请登录')
    connVisible.value = false
    return true
  } catch (err) {
    ElMessage.error(friendlyDbError(err))
    return false
  }
}

// 先对齐（创建库+执行 init.sql）再自动切换
async function alignAndSwitch() {
  let res
  try {
    res = await request({ url: '/db/align', method: 'post', data: dbParams(), showError: false })
  } catch (err) {
    ElMessage.error(friendlyDbError(err))
    return false
  }
  const db = dbName.value || 'POP'
  const created = res && res.data ? res.data.createdTableCount : null
  if (created != null) {
    ElMessage.success('数据库 ' + db + ' 对齐成功：建表 ' + created + ' 张')
  } else {
    ElMessage.success('数据库 ' + db + ' 对齐完成')
  }
  return callSwitch()
}

// [检查连接]：探测后按 结果 a/b/c 分支弹窗
async function checkDb() {
  const p = dbParams()
  if (!p.host || !p.username) {
    ElMessage.warning('请填写服务器地址与账号')
    return
  }
  dbBusy.value = true
  try {
    const res = await request({ url: '/db/probe', method: 'post', data: p, showError: false })
    const info = res.data || {}
    const db = dbName.value || 'POP'

    // 分支 c：库不存在 / 无任何项目表 → 数据对齐确认
    if (!info.hasDb || !info.hasProjectTables) {
      const tables = info.createTables || []
      let ok
      try {
        ok = await ElMessageBox.confirm(
          listMessage('目标 MySQL 实例上不存在可用的数据库「' + db + '」。' +
            (info.hasDb ? '（该库中无任何本项目表）' : '（该库不存在）') +
            '数据对齐将新建数据库并整份执行初始化脚本（建表+种子账号）。即将创建的表清单如下：', tables),
          '数据库出错，是否进行数据对齐',
          { type: 'warning', confirmButtonText: '确认对齐', cancelButtonText: '取消，只登录前端系统', closeOnClickModal: false }
        )
      } catch {
        return // 取消：关闭弹窗不切换，仍用当前已连库登录
      }
      if (ok === 'confirm') {
        dbAligning.value = true
        try {
          await alignAndSwitch()
        } finally {
          dbAligning.value = false
        }
      }
      return
    }

    // 分支 b：库存在但结构有差异 → 差异清单（缺表）
    if (info.missingTables && info.missingTables.length) {
      let ok
      try {
        ok = await ElMessageBox.confirm(
          listMessage('数据库「' + db + '」与项目结构不一致（当前后端基线表 ' + info.createTables.length + ' 张），缺少以下 ' + info.missingTables.length + ' 张表。仍连接将直接使用该库、不改动其中数据：', info.missingTables),
          '结构差异',
          { type: 'warning', confirmButtonText: '仍连接', cancelButtonText: '取消', closeOnClickModal: false }
        )
      } catch {
        return // 取消：不切换
      }
      if (ok === 'confirm') {
        await callSwitch()
      }
      return
    }

    // 分支 a：存在且结构完全一致
    ElMessage.success('连接正常：数据库 ' + db + ' 与项目结构完全一致')
    let ok
    try {
      ok = await ElMessageBox.confirm('是否立即切换到该数据库并登录？', '连接正常', {
        type: 'success', confirmButtonText: '连接', cancelButtonText: '取消'
      })
    } catch {
      return
    }
    if (ok === 'confirm') {
      await callSwitch()
    }
  } catch (err) {
    ElMessage.error(friendlyDbError(err))
  } finally {
    dbBusy.value = false
  }
}

// [对齐并连接]：一站式 对齐+切换（后端将拒绝"已含项目表"的库，防误清）
async function alignAndConnect() {
  const p = dbParams()
  if (!p.host || !p.username) {
    ElMessage.warning('请填写服务器地址与账号')
    return
  }
  const db = dbName.value || 'POP'
  let ok
  try {
    ok = await ElMessageBox.confirm(
      '将在目标 MySQL 实例上创建数据库「' + db + '」并整份执行初始化脚本（建表+种子账号）。' +
      '若该库已存在项目表将被后端拒绝执行，不会破坏已有数据。是否继续？',
      '数据对齐并连接',
      { type: 'warning', confirmButtonText: '确认对齐', cancelButtonText: '取消', closeOnClickModal: false }
    )
  } catch {
    return
  }
  if (ok !== 'confirm') return
  dbAligning.value = true
  try {
    await alignAndSwitch()
  } finally {
    dbAligning.value = false
  }
}

async function testConn() {
  if (connEnabled.value && !buildBase()) {
    ElMessage.warning('请先填写服务器地址')
    return
  }
  const target = connEnabled.value ? currentConn() + '/api/user/profile' : '/api/user/profile'
  connTesting.value = true
  try {
    const resp = await fetch(target, { method: 'GET' })
    if (resp.status === 401 || resp.status === 200 || resp.status === 403) {
      ElMessage.success('连接成功：服务器可正常访问（' + (resp.status === 200 ? '已返回登录用户信息' : '服务器在线，等待登录') + '）')
    } else {
      ElMessage.success('服务器可访问（HTTP ' + resp.status + '）')
    }
  } catch {
    ElMessage.error('无法连接到该服务器，请检查地址、端口与网络')
  } finally {
    connTesting.value = false
  }
}

const registerForm = reactive({
  username: '',
  realName: '',
  phone: '',
  password: '',
  confirmPassword: ''
})

const registerRules = {
  username: [{ required: true, message: '请输入登录账号', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

function openRegister() {
  registerVisible.value = true
}

function resetRegister() {
  registerFormRef.value?.resetFields()
}

function handleRegister() {
  registerFormRef.value.validate((valid) => {
    if (!valid) return
    registerLoading.value = true
    register({
      username: registerForm.username,
      realName: registerForm.realName,
      phone: registerForm.phone,
      password: registerForm.password
    })
      .then(() => {
        ElMessage.success('注册申请已提交，请等待系统管理员审批')
        registerVisible.value = false
      })
      .finally(() => {
        registerLoading.value = false
      })
  })
}
</script>

<style scoped>
.login-page {
  height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #0D47A1 0%, #1976D2 50%, #42A5F5 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}
.login-page::before {
  content: '';
  position: absolute;
  width: 600px;
  height: 600px;
  background: rgba(255,255,255,0.05);
  border-radius: 50%;
  top: -200px;
  right: -200px;
}
.login-page::after {
  content: '';
  position: absolute;
  width: 400px;
  height: 400px;
  background: rgba(255,255,255,0.05);
  border-radius: 50%;
  bottom: -100px;
  left: -100px;
}
.login-box {
  width: 380px;
  background: #fff;
  border-radius: 6px;
  padding: 40px 36px 24px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
  position: relative;
  z-index: 1;
}
.login-title {
  text-align: center;
  margin-bottom: 28px;
}
.logo-area {
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #1976D2, #42A5F5);
  border-radius: 12px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
}
.login-title h1 {
  font-size: 18px;
  color: #1976D2;
  margin: 0 0 8px 0;
  font-weight: bold;
  line-height: 1.4;
}
.login-title p {
  font-size: 13px;
  color: #999;
  margin: 0;
}
.login-form {
  margin-top: 20px;
}
.register-link {
  text-align: right;
  margin-top: 4px;
}
.register-link span {
  font-size: 12px;
  color: #1976D2;
  cursor: pointer;
}
.register-link span:hover {
  color: #42A5F5;
  text-decoration: underline;
}
.conn-link {
  text-align: right;
  margin-top: 6px;
}
.conn-link span {
  font-size: 12px;
  color: #888;
  cursor: pointer;
}
.conn-link span:hover {
  color: #1976D2;
  text-decoration: underline;
}
.conn-tip {
  font-size: 12px;
  color: #999;
  line-height: 1.7;
  background: #f6f8fb;
  border-radius: 4px;
  padding: 8px 10px;
  word-break: break-all;
}
.login-footer {
  text-align: center;
  font-size: 12px;
  color: #bbb;
  margin-top: 16px;
}
</style>
