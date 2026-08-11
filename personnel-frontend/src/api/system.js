import request from '../utils/request'

export function getUserList(params) {
  return request({ url: '/sys/user/list', method: 'get', params })
}

export function addUser(data) {
  return request({ url: '/sys/user', method: 'post', data })
}

export function updateUser(id, data) {
  return request({ url: `/sys/user/${id}`, method: 'put', data })
}

export function deleteUser(id) {
  return request({ url: `/sys/user/${id}`, method: 'delete' })
}

export function resetUserPwd(id) {
  return request({ url: `/sys/user/${id}/reset-pwd`, method: 'put' })
}

export function getRoleList(params) {
  return request({ url: '/sys/role/list', method: 'get', params })
}

export function addRole(data) {
  return request({ url: '/sys/role', method: 'post', data })
}

export function updateRole(id, data) {
  return request({ url: `/sys/role/${id}`, method: 'put', data })
}

export function deleteRole(id) {
  return request({ url: `/sys/role/${id}`, method: 'delete' })
}

export function getDictTypeList() {
  return request({ url: '/sys/dict/type/list', method: 'get' })
}

export function addDictType(data) {
  return request({ url: '/sys/dict/type', method: 'post', data })
}

export function updateDictType(id, data) {
  return request({ url: `/sys/dict/type/${id}`, method: 'put', data })
}

export function deleteDictType(id) {
  return request({ url: `/sys/dict/type/${id}`, method: 'delete' })
}

export function getDictDataList(typeId) {
  return request({ url: `/sys/dict/data/list/${typeId}`, method: 'get' })
}

export function addDictData(data) {
  return request({ url: '/sys/dict/data', method: 'post', data })
}

export function updateDictData(id, data) {
  return request({ url: `/sys/dict/data/${id}`, method: 'put', data })
}

export function deleteDictData(id) {
  return request({ url: `/sys/dict/data/${id}`, method: 'delete' })
}

export function getLogList(params) {
  return request({ url: '/sys/log/list', method: 'get', params })
}

// 操作日志
export function getOperLogPage(params) {
  return request({ url: '/oper-log/page', method: 'get', params })
}
export function deleteOperLog(id) {
  return request({ url: `/oper-log/${id}`, method: 'delete' })
}
export function cleanOperLog() {
  return request({ url: '/oper-log/clean', method: 'delete' })
}

// 登录日志
export function getLoginLogPage(params) {
  return request({ url: '/login-log/page', method: 'get', params })
}
export function deleteLoginLog(id) {
  return request({ url: `/login-log/${id}`, method: 'delete' })
}
export function cleanLoginLog() {
  return request({ url: '/login-log/clean', method: 'delete' })
}
