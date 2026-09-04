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
        <div class="login-footer">© 2026 辽宁工业大学 - 组织人事档案管理系统 版权所有</div>
      </div>
    </div>

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
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '../stores/user'
import { login, register } from '../api/auth'

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
        userStore.setUser(user.username, String(user.id), user.realName, isAdmin ? 'admin' : 'cadre')
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
.login-footer {
  text-align: center;
  font-size: 12px;
  color: #bbb;
  margin-top: 16px;
}
</style>
