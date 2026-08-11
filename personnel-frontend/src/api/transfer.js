import request from '../utils/request'

export function getTransferList(params) {
  return request({ url: '/transfer/list', method: 'get', params })
}

export function addTransfer(data) {
  return request({ url: '/transfer', method: 'post', data })
}

export function updateTransfer(id, data) {
  return request({ url: `/transfer/${id}`, method: 'put', data })
}

export function deleteTransfer(id) {
  return request({ url: `/transfer/${id}`, method: 'delete' })
}

export function getPromotionList(params) {
  return request({ url: '/transfer/promotion/list', method: 'get', params })
}

export function addPromotion(data) {
  return request({ url: '/transfer/promotion', method: 'post', data })
}

export function updatePromotion(id, data) {
  return request({ url: `/transfer/promotion/${id}`, method: 'put', data })
}

export function deletePromotion(id) {
  return request({ url: `/transfer/promotion/${id}`, method: 'delete' })
}
