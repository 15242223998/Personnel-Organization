import request from '../utils/request'

export function getAssessmentList(params) {
  return request({ url: '/assessment/list', method: 'get', params })
}

export function addAssessment(data) {
  return request({ url: '/assessment', method: 'post', data })
}

export function updateAssessment(id, data) {
  return request({ url: `/assessment/${id}`, method: 'put', data })
}

export function deleteAssessment(id) {
  return request({ url: `/assessment/${id}`, method: 'delete' })
}

export function getSchemeList() {
  return request({ url: '/assessment/scheme/list', method: 'get' })
}

export function addScheme(data) {
  return request({ url: '/assessment/scheme', method: 'post', data })
}

export function updateScheme(id, data) {
  return request({ url: `/assessment/scheme/${id}`, method: 'put', data })
}

export function deleteScheme(id) {
  return request({ url: `/assessment/scheme/${id}`, method: 'delete' })
}
