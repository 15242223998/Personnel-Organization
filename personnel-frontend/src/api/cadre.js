import request from '../utils/request'

export function getCadreList(params) {
  return request({ url: '/cadre/list', method: 'get', params })
}

export function getCadreDetail(id) {
  return request({ url: `/cadre/${id}`, method: 'get' })
}

export function addCadre(data) {
  return request({ url: '/cadre', method: 'post', data })
}

export function updateCadre(id, data) {
  return request({ url: `/cadre/${id}`, method: 'put', data })
}

export function deleteCadre(id) {
  return request({ url: `/cadre/${id}`, method: 'delete' })
}

export function getReserveList(params) {
  return request({ url: '/cadre/reserve/list', method: 'get', params })
}

export function addReserve(data) {
  return request({ url: '/cadre/reserve', method: 'post', data })
}

export function updateReserve(id, data) {
  return request({ url: `/cadre/reserve/${id}`, method: 'put', data })
}

export function deleteReserve(id) {
  return request({ url: `/cadre/reserve/${id}`, method: 'delete' })
}
