import request from '../utils/request'

export function getUserList(params) {
  return request({ url: '/user/page', method: 'get', params })
}

// 注册审批：待审核账号分页
export function getPendingRegistrations(params) {
  return request({ url: '/user/page', method: 'get', params })
}

export function approveRegistration(id) {
  return request({ url: `/user/register/${id}/approve`, method: 'put' })
}

export function rejectRegistration(id) {
  return request({ url: `/user/register/${id}/reject`, method: 'put' })
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

// 用户模块级权限保存：body 传 { permissions: ["cadre", ...] }
export function putUserPermissions(id, data) {
  return request({ url: `/user/${id}/permissions`, method: 'put', data })
}

// 修改用户类型（1系统管理员 ~ 6普通干部）
export function putUserType(id, userType) {
  return request({ url: `/user/${id}/type`, method: 'put', params: { userType } })
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

// ===== 政策法规管理（policy_document） =====
export function getPolicyDocumentPage(params) {
  return request({ url: '/policy-document/page', method: 'get', params })
}

export function getPolicyDocumentList() {
  return request({ url: '/policy-document/list', method: 'get' })
}

export function getPolicyDocument(id) {
  return request({ url: `/policy-document/${id}`, method: 'get' })
}

export function addPolicyDocument(data) {
  return request({ url: '/policy-document', method: 'post', data })
}

export function updatePolicyDocument(data) {
  return request({ url: '/policy-document', method: 'put', data })
}

export function deletePolicyDocument(id) {
  return request({ url: `/policy-document/${id}`, method: 'delete' })
}
