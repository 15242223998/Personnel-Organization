import request from '../utils/request'

// ================= 证照台账 =================
export function getCertificatePage(params) {
  return request({ url: '/certificate/page', method: 'get', params })
}

export function addCertificate(data) {
  return request({ url: '/certificate', method: 'post', data })
}

export function updateCertificate(data) {
  return request({ url: '/certificate', method: 'put', data })
}

export function deleteCertificate(id) {
  return request({ url: `/certificate/${id}`, method: 'delete' })
}

// ================= 出境记录 =================
export function getAbroadPage(params) {
  return request({ url: '/abroad/page', method: 'get', params })
}

// 供证照领用选择：该干部已批准且尚未出发的出国(境)记录
export function getApprovedTrips(cadreId) {
  return request({ url: '/abroad/approved', method: 'get', params: { cadreId } })
}

export function addAbroad(data) {
  return request({ url: '/abroad', method: 'post', data })
}

export function updateAbroad(data) {
  return request({ url: '/abroad', method: 'put', data })
}

export function deleteAbroad(id) {
  return request({ url: `/abroad/${id}`, method: 'delete' })
}

// ================= 休假台账 =================
export function getLeavePage(params) {
  return request({ url: '/leave/page', method: 'get', params })
}

export function addLeave(data) {
  return request({ url: '/leave', method: 'post', data })
}

export function updateLeave(data) {
  return request({ url: '/leave', method: 'put', data })
}

export function deleteLeave(id) {
  return request({ url: `/leave/${id}`, method: 'delete' })
}

// ================= 教育培训 =================
export function getTrainingPage(params) {
  return request({ url: '/training/page', method: 'get', params })
}

export function addTraining(data) {
  return request({ url: '/training', method: 'post', data })
}

export function updateTraining(data) {
  return request({ url: '/training', method: 'put', data })
}

export function deleteTraining(id) {
  return request({ url: `/training/${id}`, method: 'delete' })
}

// 参训干部
export function getTrainingCadreList(params) {
  return request({ url: '/training-cadre/list', method: 'get', params })
}

export function addTrainingCadre(data) {
  return request({ url: '/training-cadre', method: 'post', data })
}

export function deleteTrainingCadre(id) {
  return request({ url: `/training-cadre/${id}`, method: 'delete' })
}

// ================= 挂职锻炼 =================
export function getSecondmentPage(params) {
  return request({ url: '/secondment/page', method: 'get', params })
}

export function addSecondment(data) {
  return request({ url: '/secondment', method: 'post', data })
}

export function updateSecondment(data) {
  return request({ url: '/secondment', method: 'put', data })
}

export function deleteSecondment(id) {
  return request({ url: `/secondment/${id}`, method: 'delete' })
}

// ================= 干部自助申报 =================
export function getSelfApplicationPage(params) {
  return request({ url: '/self-application/page', method: 'get', params })
}

export function addSelfApplication(data) {
  return request({ url: '/self-application', method: 'post', data })
}

export function updateSelfApplication(data) {
  return request({ url: '/self-application', method: 'put', data })
}

export function deleteSelfApplication(id) {
  return request({ url: `/self-application/${id}`, method: 'delete' })
}

export function submitSelfApplication(id) {
  return request({ url: `/self-application/${id}/submit`, method: 'put' })
}

export function approveSelfApplication(id, params) {
  return request({ url: `/self-application/${id}/approve`, method: 'put', params })
}

export function rejectSelfApplication(id, params) {
  return request({ url: `/self-application/${id}/reject`, method: 'put', params })
}

// ================= 用户-干部绑定 =================
export function getUserProfile() {
  return request({ url: '/user/profile', method: 'get' })
}

export function bindUserCadre(userId, cadreId) {
  return request({ url: `/user/${userId}/bind-cadre/${cadreId}`, method: 'put' })
}

export function unbindUserCadre(userId) {
  return request({ url: `/user/${userId}/unbind-cadre`, method: 'put' })
}
