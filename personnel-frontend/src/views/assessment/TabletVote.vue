<template>
  <div class="tablet-page">
    <!-- 顶部：姓名 + 退出 -->
    <header class="tp-header">
      <div class="tp-header-left" @click="goHome">
        <div class="tp-logo">
          <svg viewBox="0 0 24 24" width="26" height="26" fill="#fff">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
          </svg>
        </div>
        <span class="tp-sys-name">平板投票 · 民主测评</span>
      </div>
      <div class="tp-header-right">
        <span class="tp-user-name">{{ realName }}</span>
        <button class="tp-logout" @click="handleLogout">退出</button>
      </div>
    </header>

    <main class="tp-main" v-loading="loading" element-loading-text="加载中...">
      <!-- ========== 列表页：进行中方案 ========== -->
      <section v-if="view === 'list'" class="tp-section list-section">
        <div class="sec-title">
          <span class="sec-title-text">进行中的测评方案</span>
          <button class="ghost-btn" @click="loadList">刷新列表</button>
        </div>

        <div v-if="schemes.length === 0 && !loading" class="tp-empty">
          <div class="empty-icon">🗳️</div>
          <div class="empty-text">暂无可投票的测评方案</div>
          <button class="ghost-btn big" @click="loadList">点击刷新</button>
        </div>

        <div v-else class="scheme-grid">
          <div
            v-for="s in schemes"
            :key="s.id"
            class="scheme-card"
            :class="{ disabled: isSigned(s) }"
            @click="enterScheme(s)"
          >
            <div class="scheme-card-head">
              <div class="scheme-name">{{ s.schemeName }}</div>
              <span class="mode-tag" :class="s.voteMode === 'BALLOT' ? 'tag-ballot' : 'tag-score'">
                {{ s.voteMode === 'BALLOT' ? '表决式' : '评分式' }}
              </span>
            </div>
            <div class="scheme-year">测评年度：{{ s.schemeYear || '-' }}</div>
            <div class="scheme-progress">
              <div class="progress-row">
                <span>投票进度</span>
                <span class="progress-num">已投 {{ s.votedTargetCount ?? 0 }} / 共 {{ s.targetTotal ?? 0 }}</span>
              </div>
              <div class="progress-track">
                <div
                  class="progress-fill"
                  :style="{ width: progressWidth(s.votedTargetCount, s.targetTotal) }"
                ></div>
              </div>
            </div>
            <div class="scheme-card-foot">
              <span v-if="isSigned(s)" class="signed-tag">✓ 已完成留证，不可再修改</span>
              <button v-else class="primary-btn big" @click.stop="enterScheme(s)">开始投票 →</button>
            </div>
          </div>
        </div>
      </section>

      <!-- ========== 投票/签字页 ========== -->
      <section v-else-if="view === 'vote'" class="tp-section vote-section">
        <div class="vote-head">
          <button class="back-btn" @click="goHome">‹</button>
          <div class="vote-head-main">
            <div class="vote-title">{{ currentName }}</div>
            <div class="vote-sub">
              <span class="mode-tag" :class="mode === 'BALLOT' ? 'tag-ballot' : 'tag-score'">
                {{ mode === 'BALLOT' ? '表决式' : '评分式' }}
              </span>
              <span v-if="detail.signed" class="signed-tag">已完成留证</span>
              <span v-else-if="detail.needSign" class="need-sign-tag">需签字留证</span>
              <span class="vote-year" v-if="currentYear">测评年度：{{ currentYear }}</span>
            </div>
          </div>
          <div class="vote-progress">
            <div class="progress-num">已投 {{ votedCount }} / {{ targets.length }}</div>
            <div class="progress-track small">
              <div class="progress-fill" :style="{ width: votedPercent }"></div>
            </div>
          </div>
        </div>

        <!-- 无测评对象 -->
        <div v-if="targets.length === 0" class="tp-empty">
          <div class="empty-text">该方案暂无测评对象</div>
        </div>

        <!-- SCORE：逐对象评分 -->
        <template v-if="mode === 'SCORE' && targets.length > 0">
          <div v-if="dimRows.length === 0" class="dim-empty-tip">
            该方案未配置维度/指标，无需逐项打分
          </div>
          <div
            v-for="t in targets"
            :key="t.cadreId"
            class="target-card"
            :class="{ expanded: t.expanded }"
          >
            <div class="target-card-head" @click="toggleScoreTarget(t)">
              <div class="target-idx">{{ targets.indexOf(t) + 1 }}</div>
              <div class="target-info">
                <div class="target-name-line">
                  <span class="target-name">{{ t.cadreName }}</span>
                  <span v-if="t.deptName" class="target-dept">{{ t.deptName }}</span>
                  <span v-if="t.position" class="target-pos">{{ t.position }}</span>
                </div>
                <div class="target-meta" v-if="t.materialTitle">材料：{{ t.materialTitle }}</div>
              </div>
              <div class="target-head-right">
                <button
                  v-if="t.materialTitle"
                  class="ghost-btn"
                  @click.stop="openMaterial(t)"
                >查看材料</button>
                <span v-if="t.voted" class="voted-tag">✓ 已投</span>
                <span v-else class="not-voted-tag">未投票</span>
              </div>
            </div>

            <div v-show="t.expanded" class="target-score-body">
              <template v-if="dimRows.length > 0">
                <div v-for="dim in dims" :key="dim.id" class="dim-block">
                  <div class="dim-title">
                    {{ dim.dimensionName }}
                    <span v-if="dim.dimensionWeight != null" class="dim-weight">（权重 {{ dim.dimensionWeight }}）</span>
                  </div>
                  <div class="ind-rows">
                    <div v-for="ind in dim.indicators" :key="ind.id" class="ind-row">
                      <div class="ind-info">
                        <span class="ind-name">{{ ind.indicatorName }}</span>
                        <span class="ind-max">满分 {{ ind.maxScore }} 分</span>
                      </div>
                      <el-input-number
                        v-model="t.input[ind.id]"
                        :min="0"
                        :max="Number(ind.maxScore) || 100"
                        :step="1"
                        :disabled="t.voted"
                        :controls="false"
                        class="ind-score"
                      />
                    </div>
                  </div>
                </div>
              </template>
              <template v-else>
                <div class="dim-empty-tip">无维度指标，无需评分</div>
              </template>

              <div class="score-submit-row">
                <template v-if="!t.voted">
                  <button
                    v-if="dimRows.length > 0"
                    class="primary-btn big"
                    :disabled="scoreSubmitting === t.cadreId"
                    @click="submitScore(t)"
                  >
                    {{ scoreSubmitting === t.cadreId ? '提交中...' : '提交该对象评分' }}
                  </button>
                  <span v-else class="muted-text">（无需打分，已可进行下一对象）</span>
                </template>
                <span v-else class="voted-tag large">✓ 已投，不可修改</span>
              </div>
            </div>
          </div>
        </template>

        <!-- BALLOT：逐对象三选一 -->
        <template v-else-if="mode === 'BALLOT' && targets.length > 0">
          <div
            v-for="t in targets"
            :key="t.cadreId"
            class="target-card ballot-card"
          >
            <div class="target-card-head ballot-head">
              <div class="target-idx">{{ targets.indexOf(t) + 1 }}</div>
              <div class="target-info">
                <div class="target-name-line">
                  <span class="target-name">{{ t.cadreName }}</span>
                  <span v-if="t.deptName" class="target-dept">{{ t.deptName }}</span>
                  <span v-if="t.position" class="target-pos">{{ t.position }}</span>
                </div>
              </div>
              <div class="target-head-right">
                <span v-if="t.locked" class="voted-tag">✓ 已表决</span>
                <span v-else-if="choices[t.cadreId]" class="chosen-tag">已选择</span>
              </div>
            </div>
            <div class="ballot-body">
              <div class="ballot-hint" v-if="t.materialTitle">可先查看该对象的测评材料：{{ t.materialTitle }}</div>
              <div class="choice-group">
                <button
                  class="choice-btn choice-approve"
                  :class="{ active: choices[t.cadreId] === 'APPROVE' }"
                  :disabled="t.locked"
                  @click="choose(t, 'APPROVE')"
                >赞成</button>
                <button
                  class="choice-btn choice-disapprove"
                  :class="{ active: choices[t.cadreId] === 'DISAPPROVE' }"
                  :disabled="t.locked"
                  @click="choose(t, 'DISAPPROVE')"
                >反对</button>
                <button
                  class="choice-btn choice-abstain"
                  :class="{ active: choices[t.cadreId] === 'ABSTAIN' }"
                  :disabled="t.locked"
                  @click="choose(t, 'ABSTAIN')"
                >弃权</button>
              </div>
              <div class="ballot-meta" v-if="t.materialTitle">
                <button class="ghost-btn" @click="openMaterial(t)">查看材料</button>
              </div>
            </div>
          </div>

          <div class="ballot-submit-bar">
            <span class="chosen-count">已选择 {{ chosenCount }} / {{ targets.length }} 人</span>
            <button
              v-if="!allDone"
              class="primary-btn big wide"
              :disabled="submitting"
              @click="submitBallotVote"
            >{{ submitting ? '提交中...' : '提交表决' }}</button>
            <span v-else class="voted-tag large">✓ 表决已提交</span>
          </div>
        </template>

        <!-- 全部投完后：签字留证 或 完成提示 -->
        <div v-if="targets.length > 0 && allDone" class="finish-zone" ref="finishZone">
          <div v-if="detail.needSign && !detail.signed" class="sign-panel">
            <div class="sign-title">✍️ 手写签字并完成留证</div>
            <div class="sign-sub">您已完成全部投票，请在下框中签字确认，作为本次投票的留证依据。</div>
            <div class="sign-box">
              <canvas
                ref="canvasRef"
                class="sign-canvas"
                width="900"
                height="360"
                @pointerdown="onPadDown"
                @pointermove="onPadMove"
                @pointerup="onPadUp"
                @pointercancel="onPadUp"
                @contextmenu.prevent
              ></canvas>
            </div>
            <div class="sign-actions">
              <button class="ghost-btn big" :disabled="signSubmitting" @click="clearPad">清空重签</button>
              <button class="primary-btn big" :disabled="signSubmitting" @click="submitSignPad">
                {{ signSubmitting ? '提交中...' : '确认签字提交' }}
              </button>
            </div>
          </div>

          <div v-else class="done-mini">
            <div class="done-mini-icon">✅</div>
            <div class="done-mini-text">{{ detail.needSign ? '投票已全部完成，等待完成签字留证' : '您已完成该方案的全部投票' }}</div>
            <button class="primary-btn big" @click="goHome">返回方案列表</button>
          </div>
        </div>
      </section>

      <!-- ========== 完成/留证成功页 ========== -->
      <section v-else-if="view === 'done'" class="tp-section done-section">
        <div class="done-card">
          <div class="done-circle">
            <svg viewBox="0 0 24 24" width="64" height="64" fill="none" stroke="#fff" stroke-width="2.6">
              <path d="M4 12.5l5 5L20 6.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <div class="done-title">{{ doneTitle }}</div>
          <div class="done-lines">
            <div class="done-line" v-if="doneName">投票人：<b>{{ doneName }}</b></div>
            <div class="done-line" v-if="doneTime">完成时间：<b>{{ doneTime }}</b></div>
            <div class="done-line muted">方案：{{ currentName }}</div>
          </div>
          <button class="primary-btn big wide" @click="goHome">返回方案列表</button>
        </div>
      </section>
    </main>

    <!-- 查看材料弹层 -->
    <el-dialog
      :title="'测评材料 - ' + (materialTarget?.cadreName || '')"
      v-model="materialDialog"
      width="600px"
      append-to-body
    >
      <div v-if="materialTarget" class="material-content">
        <div class="material-title">{{ materialTarget.materialTitle || '（无标题）' }}</div>
        <div class="material-text">{{ materialTarget.materialText || '暂无材料内容' }}</div>
      </div>
      <template #footer>
        <el-button type="primary" size="large" @click="materialDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, nextTick, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import {
  getTabletSchemes,
  getTabletSchemeDetail,
  submitVote,
  submitBallot,
  submitSign
} from '@/api/assessment'

const router = useRouter()
const userStore = useUserStore()

// token 守卫（与路由守卫保持一致）
if (!localStorage.getItem('token')) {
  router.replace('/login')
}

const realName = localStorage.getItem('realName') || localStorage.getItem('username') || '用户'

const loading = ref(false)
const view = ref('list') // list | vote | done
const schemes = ref([])

// 当前进入的方案
const currentId = ref(null)
const currentName = ref('')
const currentYear = ref('')
const mode = ref('SCORE')
const detail = reactive({ signed: false, needSign: false })
const targets = ref([]) // {cadreId,cadreName,deptName,position,materialTitle,materialText,voted,input,locked,expanded}
const dims = ref([]) // 维度节点 {id,dimensionName,dimensionWeight,indicators:[...]}
const dimRows = ref([]) // 展开后的指标扁平行

const choices = reactive({}) // cadreId -> APPROVE/DISAPPROVE/ABSTAIN

const scoreSubmitting = ref('')
const submitting = ref(false)
const ballotDone = ref(false)

// ================= 列表 =================
async function loadList() {
  loading.value = true
  try {
    const res = await getTabletSchemes()
    schemes.value = (res.data && (res.data.records || res.data)) || []
  } catch {
    schemes.value = []
  } finally {
    loading.value = false
  }
}

function progressWidth(voted, total) {
  if (!total) return '0%'
  const p = Math.min(100, Math.round(((Number(voted) || 0) / Number(total)) * 100))
  return p + '%'
}

function isSigned(s) {
  return !!s.signed
}

function goHome() {
  view.value = 'list'
  loadList()
}

function handleLogout() {
  localStorage.removeItem('token')
  userStore.clearUser()
  router.replace('/login')
}

// ================= 进入方案 =================
async function enterScheme(s) {
  if (isSigned(s)) {
    ElMessage.warning('该方案您已完成留证，不可再投票或修改')
    return
  }
  loading.value = true
  try {
    const res = await getTabletSchemeDetail(s.id)
    const data = res.data || {}
    if (data.signed) {
      ElMessage.warning('您已完成该方案的投票与签字留证，不可再修改')
      return
    }
    currentId.value = s.id
    currentName.value = data.scheme?.schemeName || s.schemeName || ''
    currentYear.value = data.scheme?.schemeYear || s.schemeYear || ''
    mode.value = data.voteMode || s.voteMode || 'SCORE'
    detail.signed = !!data.signed
    detail.needSign = !!data.needSign

    // 清理上一个方案的选择/笔迹状态
    Object.keys(choices).forEach(k => delete choices[k])
    hasInk.value = false
    drawingNow = false

    dims.value = (data.dimensions || []).map(d => ({
      id: d.id,
      dimensionName: d.dimensionName,
      dimensionWeight: d.dimensionWeight,
      indicators: (d.indicators || []).map(i => ({ id: i.id, indicatorName: i.indicatorName, maxScore: i.maxScore }))
    }))
    const rows = []
    for (const d of dims.value) {
      for (const i of d.indicators || []) rows.push({ dimensionName: d.dimensionName, ...i })
    }
    dimRows.value = rows

    targets.value = (data.targets || []).map(t => {
      const voted = !!t.voted
      const rawScores = (t.scores && typeof t.scores === 'object') ? t.scores : {}
      return {
        cadreId: t.cadreId,
        cadreName: t.cadreName || ('干部#' + t.cadreId),
        deptName: t.deptName || '',
        position: t.position || '',
        materialTitle: t.materialTitle || '',
        materialText: t.materialText || '',
        voted,
        locked: mode.value === 'BALLOT' ? voted : false,
        expanded: false,
        input: voted ? { ...rawScores } : {}
      }
    })
    // 预填已投对象的已选表决
    targets.value.forEach(t => {
      if (t.locked && t.choice) choices[t.cadreId] = t.choice
    })
    ballotDone.value = false
    view.value = 'vote'
  } catch {
    // 请求拦截器已提示
  } finally {
    loading.value = false
  }
}

// ================= SCORE =================
function toggleScoreTarget(t) {
  t.expanded = !t.expanded
}

async function submitScore(t) {
  const missing = dimRows.value.find(r => t.input[r.id] === undefined || t.input[r.id] === null || t.input[r.id] === '')
  if (missing) {
    ElMessage.warning(`请为【${t.cadreName}】填写指标“${missing.indicatorName}”的评分`)
    return
  }
  if (dimRows.value.length === 0) {
    ElMessage.warning('该方案无维度指标，无需评分')
    return
  }
  const scores = {}
  dimRows.value.forEach(r => { scores[r.id] = Number(t.input[r.id]) })
  scoreSubmitting.value = t.cadreId
  try {
    await submitVote({ schemeId: currentId.value, targetCadreId: t.cadreId, scores })
    ElMessage.success(`【${t.cadreName}】评分已提交`)
    t.voted = true
    t.expanded = false
    afterVoted()
  } finally {
    scoreSubmitting.value = ''
  }
}

// ================= BALLOT =================
function choose(t, val) {
  if (t.locked) return
  choices[t.cadreId] = val
}

async function submitBallotVote() {
  const unChosen = targets.value.find(t => !choices[t.cadreId])
  if (unChosen) {
    ElMessage.warning(`请先为【${unChosen.cadreName}】选择赞成/反对/弃权`)
    return
  }
  submitting.value = true
  try {
    await submitBallot({
      schemeId: currentId.value,
      choices: targets.value.map(t => ({ targetCadreId: t.cadreId, choice: choices[t.cadreId] }))
    })
    ElMessage.success('表决已提交')
    targets.value.forEach(t => { t.locked = true })
    ballotDone.value = true
    afterVoted()
  } finally {
    submitting.value = false
  }
}

// ================= 进度 / 完成判断 =================
const votedCount = computed(() => targets.value.filter(t => t.voted).length)
const votedPercent = computed(() => {
  if (!targets.value.length) return '0%'
  return progressWidth(votedCount.value, targets.value.length)
})
const chosenCount = computed(() => Object.values(choices).filter(Boolean).length)
const allDone = computed(() => {
  if (!targets.value.length) return false
  if (mode.value === 'BALLOT') return targets.value.every(t => t.locked) || ballotDone.value
  return targets.value.every(t => t.voted)
})

function afterVoted() {
  if (!allDone.value) return
  if (detail.needSign && !detail.signed) {
    nextTick(() => {
      finishZoneRef.value && finishZoneRef.value.scrollIntoView({ behavior: 'smooth', block: 'start' })
    })
  } else {
    finishAll()
  }
}

function finishAll() {
  view.value = 'done'
  doneTitle.value = detail.needSign ? '留证成功' : '投票完成'
  doneName.value = realName
  doneTime.value = new Date().toLocaleString('zh-CN')
}

const doneTitle = ref('')
const doneName = ref('')
const doneTime = ref('')

// ================= 查看材料 =================
const materialDialog = ref(false)
const materialTarget = ref(null)
function openMaterial(t) {
  materialTarget.value = t
  materialDialog.value = true
}

// ================= 签字板 =================
const canvasRef = ref(null)
const finishZoneRef = ref(null)
const signSubmitting = ref(false)
let drawingNow = false
let lastPoint = null
const hasInk = ref(false)

function padPoint(e) {
  const canvas = canvasRef.value
  const rect = canvas.getBoundingClientRect()
  return {
    x: (e.clientX - rect.left) * (canvas.width / rect.width),
    y: (e.clientY - rect.top) * (canvas.height / rect.height)
  }
}

function onPadDown(e) {
  e.preventDefault()
  const canvas = canvasRef.value
  if (!canvas) return
  canvas.setPointerCapture && canvas.setPointerCapture(e.pointerId)
  drawingNow = true
  lastPoint = padPoint(e)
}

function onPadMove(e) {
  if (!drawingNow) return
  e.preventDefault()
  const canvas = canvasRef.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  const p = padPoint(e)
  if (lastPoint) {
    ctx.beginPath()
    ctx.moveTo(lastPoint.x, lastPoint.y)
    ctx.lineTo(p.x, p.y)
    const rect = canvas.getBoundingClientRect()
    ctx.strokeStyle = '#1a2333'
    ctx.lineWidth = Math.max(2.5, (canvas.width / rect.width) * 3)
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.stroke()
    hasInk.value = true
  }
  lastPoint = p
}

function onPadUp() {
  drawingNow = false
  lastPoint = null
}

function clearPad() {
  const canvas = canvasRef.value
  if (!canvas) return
  canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height)
  hasInk.value = false
}

async function submitSignPad() {
  if (!hasInk.value) {
    ElMessage.warning('请先在签字板上签名')
    return
  }
  const canvas = canvasRef.value
  signSubmitting.value = true
  try {
    const signImage = canvas.toDataURL('image/png')
    await submitSign({ schemeId: currentId.value, signImage })
    detail.signed = true
    ElMessage.success('签字留证成功')
    finishAll()
  } finally {
    signSubmitting.value = false
  }
}

onBeforeUnmount(() => {
  drawingNow = false
})

loadList()
</script>

<style scoped>
.tablet-page {
  height: 100vh;
  width: 100%;
  background: #eef2f7;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  font-size: 16px;
  color: #333;
}

/* ============ 顶栏 ============ */
.tp-header {
  height: 64px;
  background: linear-gradient(90deg, #1565C0 0%, #1E88E5 100%);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 22px;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
  z-index: 10;
}
.tp-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}
.tp-logo {
  width: 42px;
  height: 42px;
  background: rgba(255, 255, 255, 0.18);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.tp-sys-name {
  font-size: 20px;
  font-weight: bold;
  letter-spacing: 1px;
}
.tp-header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}
.tp-user-name {
  font-size: 18px;
}
.tp-logout {
  font-size: 17px;
  color: #fff;
  background: rgba(255, 255, 255, 0.16);
  border: 1px solid rgba(255, 255, 255, 0.45);
  border-radius: 8px;
  padding: 8px 24px;
  cursor: pointer;
}
.tp-logout:active {
  background: rgba(0, 0, 0, 0.18);
}

/* ============ 主体 ============ */
.tp-main {
  flex: 1;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  padding: 20px;
  box-sizing: border-box;
}
.tp-section {
  max-width: 1060px;
  margin: 0 auto;
}
.sec-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}
.sec-title-text {
  font-size: 24px;
  font-weight: bold;
  color: #1a3352;
}

/* 按钮 */
.primary-btn {
  background: #1976D2;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 17px;
  padding: 12px 26px;
  cursor: pointer;
  font-weight: 600;
}
.primary-btn.big {
  min-height: 52px;
  padding: 0 30px;
}
.primary-btn.wide {
  width: 100%;
}
.primary-btn:active {
  background: #1565C0;
}
.primary-btn:disabled {
  background: #b0c4da;
  cursor: not-allowed;
}
.ghost-btn {
  background: #fff;
  color: #1976D2;
  border: 1px solid #1976D2;
  border-radius: 10px;
  font-size: 16px;
  padding: 10px 22px;
  cursor: pointer;
}
.ghost-btn.big {
  min-height: 48px;
}
.ghost-btn:active {
  background: #E3F2FD;
}
.ghost-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

/* 空状态 */
.tp-empty {
  background: #fff;
  border: 1px dashed #c9d6e2;
  border-radius: 12px;
  padding: 70px 20px;
  text-align: center;
  color: #8a9bb0;
}
.empty-icon { font-size: 52px; margin-bottom: 14px; }
.empty-text { font-size: 18px; margin-bottom: 20px; }

/* ============ 方案卡片 ============ */
.scheme-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
}
.scheme-card {
  background: #fff;
  border: 1px solid #e0e6ec;
  border-radius: 14px;
  padding: 22px;
  cursor: pointer;
  transition: box-shadow 0.15s;
}
.scheme-card:active {
  box-shadow: 0 4px 16px rgba(25, 118, 210, 0.18);
}
.scheme-card.disabled {
  opacity: 0.55;
  cursor: not-allowed;
}
.scheme-card-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 10px;
}
.scheme-name {
  font-size: 20px;
  font-weight: bold;
  color: #1a3352;
  line-height: 1.4;
}
.scheme-year {
  color: #6b7a8d;
  font-size: 16px;
  margin-bottom: 14px;
}
.scheme-progress .progress-row {
  display: flex;
  justify-content: space-between;
  color: #5a6b7d;
  margin-bottom: 8px;
}
.progress-num { font-weight: 600; }
.progress-track {
  height: 10px;
  background: #e7ecf2;
  border-radius: 6px;
  overflow: hidden;
}
.progress-track.small { height: 8px; }
.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #1976D2, #42A5F5);
  border-radius: 6px;
  transition: width 0.3s;
}
.scheme-card-foot {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
.signed-tag {
  background: #eceff1;
  color: #607080;
  border-radius: 8px;
  font-size: 15px;
  padding: 8px 14px;
}

/* 标签 */
.mode-tag {
  border-radius: 8px;
  font-size: 15px;
  padding: 6px 14px;
  white-space: nowrap;
}
.tag-score { background: #E3F2FD; color: #1565C0; }
.tag-ballot { background: #FFF3E0; color: #E65100; }
.voted-tag {
  background: #E8F5E9;
  color: #2E7D32;
  border-radius: 8px;
  font-size: 15px;
  padding: 6px 12px;
  white-space: nowrap;
}
.voted-tag.large { font-size: 17px; padding: 10px 18px; }
.not-voted-tag {
  background: #FFEBEE;
  color: #C62828;
  border-radius: 8px;
  font-size: 15px;
  padding: 6px 12px;
  white-space: nowrap;
}
.need-sign-tag {
  background: #FFF3E0;
  color: #E65100;
  border-radius: 8px;
  font-size: 14px;
  padding: 4px 12px;
  white-space: nowrap;
}
.chosen-tag {
  background: #E8F5E9;
  color: #2E7D32;
  border-radius: 8px;
  font-size: 15px;
  padding: 6px 12px;
  white-space: nowrap;
}

/* ============ 投票页头 ============ */
.vote-head {
  background: #fff;
  border-radius: 14px;
  padding: 18px 22px;
  display: flex;
  align-items: center;
  gap: 18px;
  margin-bottom: 18px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}
.back-btn {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  border: 1px solid #d4dde6;
  background: #fff;
  color: #1976D2;
  font-size: 30px;
  line-height: 1;
  cursor: pointer;
  flex-shrink: 0;
}
.vote-head-main { flex: 1; min-width: 0; }
.vote-title {
  font-size: 22px;
  font-weight: bold;
  color: #1a3352;
  margin-bottom: 8px;
}
.vote-sub {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.vote-year { color: #6b7a8d; font-size: 15px; }
.vote-progress {
  min-width: 150px;
  flex-shrink: 0;
}
.vote-progress .progress-num { margin-bottom: 8px; text-align: right; }

/* ============ 目标卡片 ============ */
.target-card {
  background: #fff;
  border-radius: 14px;
  border: 1px solid #e0e6ec;
  margin-bottom: 16px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}
.target-card.expanded {
  border-color: #90CAF9;
}
.target-card-head {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 18px 20px;
  cursor: pointer;
  min-height: 76px;
}
.target-idx {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: #E3F2FD;
  color: #1976D2;
  font-size: 20px;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.target-info { flex: 1; min-width: 0; }
.target-name-line { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.target-name { font-size: 20px; font-weight: bold; color: #1a3352; }
.target-dept, .target-pos {
  background: #f2f5f8;
  color: #5a6b7d;
  border-radius: 6px;
  font-size: 14px;
  padding: 4px 10px;
}
.target-meta {
  color: #8a9bb0;
  font-size: 14px;
  margin-top: 6px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.target-head-right {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}

/* SCORE 展开区 */
.target-score-body {
  border-top: 1px dashed #e0e6ec;
  background: #fafcff;
  padding: 20px 22px;
}
.dim-empty-tip {
  background: #FFF8E1;
  color: #8d6e00;
  border-radius: 8px;
  padding: 10px 16px;
  margin-bottom: 14px;
}
.dim-block { margin-bottom: 18px; }
.dim-title {
  font-size: 17px;
  font-weight: bold;
  color: #1565C0;
  border-left: 4px solid #1976D2;
  padding-left: 10px;
  margin-bottom: 12px;
}
.dim-weight { color: #8a9bb0; font-weight: normal; font-size: 15px; }
.ind-rows {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 12px;
}
.ind-row {
  background: #fff;
  border: 1px solid #e3e9f0;
  border-radius: 10px;
  padding: 14px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
}
.ind-name { font-size: 17px; color: #333; }
.ind-max { color: #9aa7b5; font-size: 14px; margin-left: 8px; }
.ind-score {
  width: 150px;
  flex-shrink: 0;
}
.ind-score :deep(.el-input__inner) {
  font-size: 22px;
  height: 48px;
  text-align: center;
}
.score-submit-row {
  display: flex;
  justify-content: flex-end;
  padding-top: 8px;
}
.muted-text { color: #8a9bb0; }

/* BALLOT */
.ballot-head { cursor: default; }
.ballot-body {
  border-top: 1px dashed #e0e6ec;
  background: #fafcff;
  padding: 18px 20px 20px;
}
.ballot-hint {
  color: #6b7a8d;
  font-size: 15px;
  margin-bottom: 14px;
}
.choice-group {
  display: flex;
  gap: 16px;
  margin-bottom: 12px;
}
.choice-btn {
  flex: 1;
  min-height: 76px;
  border-radius: 12px;
  border: 2px solid transparent;
  font-size: 22px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.1s;
}
.choice-btn:disabled { opacity: 0.85; cursor: default; }
.choice-approve { background: #E8F5E9; color: #2E7D32; border-color: #A5D6A7; }
.choice-approve.active { background: #2E7D32; color: #fff; border-color: #2E7D32; }
.choice-disapprove { background: #FFEBEE; color: #C62828; border-color: #EF9A9A; }
.choice-disapprove.active { background: #C62828; color: #fff; border-color: #C62828; }
.choice-abstain { background: #ECEFF1; color: #546E7A; border-color: #CFD8DC; }
.choice-abstain.active { background: #607D8B; color: #fff; border-color: #607D8B; }
.ballot-meta { text-align: right; }

.ballot-submit-bar {
  background: #fff;
  border-radius: 14px;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}
.chosen-count { font-size: 17px; color: #5a6b7d; }

/* 完成区 / 签字 */
.finish-zone { margin-top: 24px; }
.sign-panel {
  background: #fff;
  border: 1px solid #e0e6ec;
  border-radius: 14px;
  padding: 24px;
}
.sign-title {
  font-size: 22px;
  font-weight: bold;
  color: #1a3352;
  margin-bottom: 8px;
}
.sign-sub { color: #6b7a8d; margin-bottom: 16px; }
.sign-box {
  border: 2px dashed #b8c6d4;
  border-radius: 12px;
  background: #fff;
  padding: 6px;
  margin-bottom: 16px;
}
.sign-canvas {
  width: 100%;
  height: auto;
  aspect-ratio: 900 / 360;
  display: block;
  touch-action: none;
  background: #fff;
  border-radius: 8px;
  cursor: crosshair;
}
.sign-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
}

.done-mini {
  background: #fff;
  border-radius: 14px;
  padding: 26px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  text-align: center;
}
.done-mini-icon { font-size: 48px; }
.done-mini-text { font-size: 20px; color: #2E7D32; font-weight: 600; }

/* ============ 完成页 ============ */
.done-section {
  display: flex;
  justify-content: center;
  padding-top: 8vh;
}
.done-card {
  background: #fff;
  border-radius: 20px;
  width: 520px;
  max-width: 100%;
  padding: 48px 40px;
  text-align: center;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
}
.done-circle {
  width: 110px;
  height: 110px;
  border-radius: 50%;
  background: linear-gradient(135deg, #2E7D32, #43A047);
  margin: 0 auto 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.done-title {
  font-size: 30px;
  font-weight: bold;
  color: #1a3352;
  margin-bottom: 26px;
}
.done-lines {
  text-align: left;
  background: #f7fafc;
  border-radius: 10px;
  padding: 18px 20px;
  margin-bottom: 30px;
}
.done-line {
  font-size: 18px;
  color: #333;
  padding: 6px 0;
}
.done-line b { color: #1565C0; }
.done-line.muted { color: #8a9bb0; font-size: 16px; }

/* ============ 材料弹层 ============ */
.material-content { max-height: 60vh; overflow-y: auto; }
.material-title {
  font-size: 18px;
  font-weight: bold;
  color: #1a3352;
  margin-bottom: 12px;
}
.material-text {
  font-size: 16px;
  line-height: 1.8;
  white-space: pre-wrap;
  color: #444;
}

@media (max-width: 768px) {
  .tp-main { padding: 12px; }
  .tp-sys-name { font-size: 16px; }
  .tp-user-name { font-size: 15px; }
  .scheme-grid { grid-template-columns: 1fr; }
  .ind-rows { grid-template-columns: 1fr; }
  .vote-head { flex-wrap: wrap; }
  .vote-progress { width: 100%; }
  .vote-progress .progress-num { text-align: left; }
}
</style>
