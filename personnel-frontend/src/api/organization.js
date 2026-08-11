import request from '../utils/request'

export function getDeptTree() {
  return request({ url: '/dept/tree', method: 'get' })
}

export function addDept(data) {
  return request({ url: '/dept', method: 'post', data })
}

export function updateDept(id, data) {
  return request({ url: `/dept/${id}`, method: 'put', data })
}

export function deleteDept(id) {
  return request({ url: `/dept/${id}`, method: 'delete' })
}

export function getQuotaList() {
  return request({ url: '/dept/quota/list', method: 'get' })
}

export function updateQuota(id, data) {
  return request({ url: `/dept/quota/${id}`, method: 'put', data })
}

export function getPositionLevels(params) {
  return request({ url: '/position-level/list', method: 'get', params })
}

export function addPositionLevel(data) {
  return request({ url: '/position-level', method: 'post', data })
}

export function updatePositionLevel(id, data) {
  return request({ url: `/position-level/${id}`, method: 'put', data })
}

export function deletePositionLevel(id) {
  return request({ url: `/position-level/${id}`, method: 'delete' })
}

export function getRanks(params) {
  return request({ url: '/rank/list', method: 'get', params })
}

export function addRank(data) {
  return request({ url: '/rank', method: 'post', data })
}

export function updateRank(id, data) {
  return request({ url: `/rank/${id}`, method: 'put', data })
}

export function deleteRank(id) {
  return request({ url: `/rank/${id}`, method: 'delete' })
}
