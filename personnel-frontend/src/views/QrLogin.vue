<template>
  <div class="qr-page">
    <header class="qr-header">
      <div class="qr-logo">
        <svg viewBox="0 0 24 24" width="24" height="24" fill="#fff">
          <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
        </svg>
      </div>
      <div class="qr-title">辽宁某某大学 · 组织人事档案管理系统</div>
    </header>

    <main class="qr-main">
      <div class="qr-card">
        <!-- 加载 -->
        <template v-if="state === 'loading'">
          <div class="loading"><span class="spinner"></span> 加载中...</div>
        </template>

        <!-- 待确认 -->
        <template v-else-if="state === 'asking'">
          <div class="card-title">登录确认</div>
          <p class="ask-account">请求登录的账号：{{ account }}</p>
          <p class="ask-ask">是否允许该设备登录？</p>
          <div class="ask-btns">
            <button class="btn reject" :disabled="submitting" @click="submit('reject')">拒绝</button>
            <button class="btn confirm" :disabled="submitting" @click="submit('confirm')">确认登录</button>
          </div>
        </template>

        <!-- 已确认 -->
        <template v-else-if="state === 'confirmed'">
          <div class="big-icon ok">✔</div>
          <p class="result-text ok-text">已确认，请在电脑上继续</p>
        </template>

        <!-- 已拒绝 -->
        <template v-else-if="state === 'rejected'">
          <div class="big-icon gray">✖</div>
          <p class="result-text gray-text">已拒绝登录</p>
        </template>

        <!-- 失效 -->
        <template v-else>
          <div class="big-icon fail">✖</div>
          <p class="result-text fail-text">二维码已失效</p>
        </template>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import request from '../utils/request'

const route = useRoute()
const ticket = (route.query.ticket || '').toString()
const state = ref('loading') // loading / asking / confirmed / rejected / invalid
const account = ref('')
const submitting = ref(false)

async function loadStatus() {
  if (!ticket) {
    state.value = 'invalid'
    return
  }
  try {
    const res = await request({ url: '/qr-login/status', method: 'get', params: { ticket }, showError: false })
    const d = res.data || {}
    if (d.status === 'waiting') {
      account.value = d.account || '未知账号'
      state.value = 'asking'
    } else if (d.status === 'confirmed') {
      state.value = 'confirmed'
    } else if (d.status === 'rejected') {
      state.value = 'rejected'
    } else {
      state.value = 'invalid'
    }
  } catch {
    state.value = 'invalid'
  }
}

async function submit(action) {
  if (submitting.value) return
  submitting.value = true
  try {
    await request({ url: '/qr-login/confirm', method: 'post', data: { ticket, action }, showError: false })
    state.value = action === 'reject' ? 'rejected' : 'confirmed'
  } catch {
    state.value = 'invalid'
  } finally {
    submitting.value = false
  }
}

onMounted(loadStatus)
</script>

<style scoped>
.qr-page {
  min-height: 100vh;
  background: #eef2f7;
  display: flex;
  flex-direction: column;
}
.qr-header {
  background: linear-gradient(90deg, #1565C0 0%, #1E88E5 100%);
  color: #fff;
  padding: 16px 18px;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 2px 8px rgba(21, 101, 192, 0.25);
}
.qr-logo {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 0 0 auto;
}
.qr-title {
  font-size: 15px;
  font-weight: 600;
  line-height: 1.4;
}
.qr-main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px 16px;
}
.qr-card {
  width: 100%;
  max-width: 380px;
  background: #fff;
  border-radius: 14px;
  padding: 32px 22px;
  box-shadow: 0 8px 28px rgba(30, 60, 90, 0.12);
  text-align: center;
}
.card-title {
  font-size: 20px;
  font-weight: 700;
  color: #1a3352;
  margin-bottom: 16px;
}
.ask-account {
  font-size: 16px;
  color: #43536b;
  line-height: 1.7;
  margin: 0 0 8px;
  word-break: break-all;
}
.ask-ask {
  font-size: 15px;
  color: #8a97a8;
  margin: 0 0 26px;
}
.ask-btns {
  display: flex;
  gap: 12px;
}
.btn {
  flex: 1;
  border: none;
  border-radius: 10px;
  padding: 14px 0;
  font-size: 17px;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.2s;
}
.btn:active {
  opacity: 0.85;
}
.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}
.btn.reject {
  background: #fff;
  color: #6b7a8d;
  border: 1px solid #d5dce6;
}
.btn.confirm {
  background: #07C160;
  color: #fff;
}
.big-icon {
  font-size: 52px;
  font-weight: 700;
  line-height: 1;
  margin-bottom: 16px;
}
.big-icon.ok {
  color: #07C160;
}
.big-icon.fail {
  color: #E53935;
}
.big-icon.gray {
  color: #9aa7b5;
}
.result-text {
  font-size: 16px;
  line-height: 1.7;
  margin: 0;
}
.ok-text {
  color: #07C160;
  font-weight: 600;
}
.fail-text {
  color: #E53935;
  font-weight: 600;
}
.gray-text {
  color: #6b7a8d;
  font-weight: 600;
}
.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 15px;
  color: #6b7a8d;
}
.spinner {
  width: 18px;
  height: 18px;
  border: 2px solid #d5e2f0;
  border-top-color: #1976D2;
  border-radius: 50%;
  animation: qr-spin 0.8s linear infinite;
}
@keyframes qr-spin {
  to { transform: rotate(360deg); }
}
</style>
