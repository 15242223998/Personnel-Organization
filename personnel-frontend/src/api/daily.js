import request from '../utils/request'

export function getDailyList(params) {
  return request({ url: '/daily/list', method: 'get', params })
}

export function addDaily(data) {
  return request({ url: '/daily', method: 'post', data })
}

export function updateDaily(id, data) {
  return request({ url: `/daily/${id}`, method: 'put', data })
}

export function deleteDaily(id) {
  return request({ url: `/daily/${id}`, method: 'delete' })
}
