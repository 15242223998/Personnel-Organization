import request from '../utils/request'

export function getAppointmentList(params) {
  return request({ url: '/appointment/list', method: 'get', params })
}

export function addAppointment(data) {
  return request({ url: '/appointment', method: 'post', data })
}

export function deleteAppointment(id) {
  return request({ url: `/appointment/${id}`, method: 'delete' })
}

export function updateAppointmentStep(id, data) {
  return request({ url: `/appointment/${id}/step`, method: 'put', data })
}
