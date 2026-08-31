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
          <h1>辽宁工业大学 - 组织人事档案管理系统</h1>
          <p>辽宁工业大学 · 智慧组织人事管理平台</p>
        </div>
        <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form">
          <el-form-item prop="username">
            <el-input v-model="loginForm.username" placeholder="用户名" size="large">
              <template #prefix><el-icon><User /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item prop="password">
            <el-input v-model="loginForm.password" type="password" placeholder="密码（任意）" size="large" @keyup.enter="handleLogin" show-password>
              <template #prefix><el-icon><Lock /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" size="large" style="width:100%" :loading="loading" @click="handleLogin">登 录</el-button>
          </el-form-item>
        </el-form>
        <div class="demo-accounts">
          <span style="color:#999;font-size:12px">演示账号：</span>
          <span class="demo-tag" @click="loginForm.username='admin'" :style="{background: loginForm.username==='admin'?'#1976D2':'#e8e8e8', color: loginForm.username==='admin'?'#fff':'#666'}">admin</span>
          <span class="demo-tag" @click="loginForm.username='zhangjg'" :style="{background: loginForm.username==='zhangjg'?'#1976D2':'#e8e8e8', color: loginForm.username==='zhangjg'?'#fff':'#666'}">张建国</span>
          <span class="demo-tag" @click="loginForm.username='lixiuying'" :style="{background: loginForm.username==='lixiuying'?'#1976D2':'#e8e8e8', color: loginForm.username==='lixiuying'?'#fff':'#666'}">李秀英</span>
          <span class="demo-tag" @click="loginForm.username='wangzq'" :style="{background: loginForm.username==='wangzq'?'#1976D2':'#e8e8e8', color: loginForm.username==='wangzq'?'#fff':'#666'}">王志强</span>
          <span class="demo-tag" @click="loginForm.username='liudeming'" :style="{background: loginForm.username==='liudeming'?'#1976D2':'#e8e8e8', color: loginForm.username==='liudeming'?'#fff':'#666'}">刘德明</span>
          <span class="demo-tag" @click="loginForm.username='chenlh'" :style="{background: loginForm.username==='chenlh'?'#1976D2':'#e8e8e8', color: loginForm.username==='chenlh'?'#fff':'#666'}">陈丽华</span>
        </div>
        <div class="login-footer">© 2026 辽宁工业大学 - 组织人事档案管理系统 版权所有</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'

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
    setTimeout(() => {
      const accounts = {
        'admin':     { token: 'mock-token-admin',     name: '系统管理员', id: '1',   real: '系统管理员', type: 'admin' },
        'zhangjg':   { token: 'mock-token-zhangjg',   name: '张建国',     id: '100', real: '张建国',     type: 'cadre' },
        'lixiuying': { token: 'mock-token-lixiuying', name: '李秀英',     id: '101', real: '李秀英',     type: 'cadre' },
        'wangzq':    { token: 'mock-token-wangzq',    name: '王志强',     id: '102', real: '王志强',     type: 'cadre' },
        'liudeming': { token: 'mock-token-liudeming', name: '刘德明',     id: '103', real: '刘德明',     type: 'cadre' },
        'chenlh':    { token: 'mock-token-chenlh',    name: '陈丽华',     id: '104', real: '陈丽华',     type: 'cadre' }
      }
      const acc = accounts[loginForm.username]
      if (acc) {
        localStorage.setItem('token', acc.token)
        userStore.setUser(acc.name, acc.id, acc.real, acc.type)
        ElMessage.success(`欢迎，${acc.real}`)
        router.push('/')
      } else {
        ElMessage.error('用户名或密码错误')
      }
      loading.value = false
    }, 500)
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
.login-footer {
  text-align: center;
  font-size: 12px;
  color: #bbb;
  margin-top: 16px;
}
.demo-accounts { text-align: center; margin-top: 8px; display: flex; flex-wrap: wrap; align-items: center; justify-content: center; gap: 6px; }
.demo-tag { font-size: 11px; padding: 2px 8px; border-radius: 10px; cursor: pointer; transition: all 0.2s; user-select: none; }
.demo-tag:hover { opacity: 0.85; }
</style>
