import request from '../utils/request'

export function getSupervisionList(params) {
  return request({ url: '/supervision/list', method: 'get', params })
}

export function addSupervision(data) {
  return request({ url: '/supervision', method: 'post', data })
}

export function updateSupervision(id, data) {
  return request({ url: `/supervision/${id}`, method: 'put', data })
}

export function deleteSupervision(id) {
  return request({ url: `/supervision/${id}`, method: 'delete' })
}
