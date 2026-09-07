import request from '../utils/request'

// ================= 年度考核 =================
export function getAnnualPage(params) {
  return request({ url: '/annual/page', method: 'get', params })
}

export function addAnnual(data) {
  return request({ url: '/annual', method: 'post', data })
}

export function updateAnnual(data) {
  return request({ url: '/annual', method: 'put', data })
}

export function deleteAnnual(id) {
  return request({ url: `/annual/${id}`, method: 'delete' })
}

export function getAnnualStats(year) {
  return request({ url: '/annual/stats', method: 'get', params: { year } })
}

export function getAnnualStatsAll() {
  return request({ url: '/annual/stats-all', method: 'get' })
}

// ================= 测评方案 =================
export function getSchemePage(params) {
  return request({ url: '/assessment-scheme/page', method: 'get', params })
}

export function getSchemeDetail(id) {
  return request({ url: `/assessment-scheme/${id}/detail`, method: 'get' })
}

export function addScheme(data) {
  return request({ url: '/assessment-scheme', method: 'post', data })
}

export function updateScheme(data) {
  return request({ url: '/assessment-scheme', method: 'put', data })
}

export function deleteScheme(id) {
  return request({ url: `/assessment-scheme/${id}`, method: 'delete' })
}

export function publishScheme(id) {
  return request({ url: `/assessment-scheme/${id}/publish`, method: 'put' })
}

export function closeScheme(id) {
  return request({ url: `/assessment-scheme/${id}/close`, method: 'put' })
}

export function generateTargets(id, cadreIds) {
  return request({ url: `/assessment-scheme/${id}/targets`, method: 'put', data: cadreIds })
}

// ================= 投票计票 =================
export function submitVote(data) {
  return request({ url: '/vote/submit', method: 'post', data })
}

export function getVoteResult(schemeId) {
  return request({ url: `/vote/result/${schemeId}`, method: 'get' })
}

export function hasMyVote(params) {
  return request({ url: '/vote/my', method: 'get', params })
}

// ================= 平板投票 / 票决 / 签字留证 =================
export function getTabletSchemes() {
  return request({ url: '/vote/tablet/list', method: 'get' })
}

export function getTabletSchemeDetail(id) {
  return request({ url: `/vote/tablet/detail/${id}`, method: 'get' })
}

export function submitBallot(data) {
  return request({ url: '/vote/ballot', method: 'post', data })
}

export function submitSign(data) {
  return request({ url: '/vote/sign', method: 'post', data })
}

export function getSignatures(schemeId) {
  return request({ url: `/vote/tablet/signatures/${schemeId}`, method: 'get' })
}

export function getBallotResult(schemeId) {
  return request({ url: `/vote/ballot-result/${schemeId}`, method: 'get' })
}

/** 更新测评对象材料（id 为 assessment_target 记录 id） */
export function updateTargetMaterial(id, data) {
  return request({ url: `/assessment-target/${id}`, method: 'put', data })
}

/** 方案的测评对象（target 记录）列表，含 materialTitle/materialText */
export function getSchemeTargets(schemeId) {
  return request({ url: '/assessment-target/list', method: 'get', params: { schemeId } })
}

// ================= 维度/指标（方案模板维护） =================
export function getDimensionList(params) {
  return request({ url: '/dimension/list', method: 'get', params })
}

export function getIndicatorList(params) {
  return request({ url: '/indicator/list', method: 'get', params })
}
