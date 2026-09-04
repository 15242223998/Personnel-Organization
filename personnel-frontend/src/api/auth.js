import request from '../utils/request'

export function login(data, config = {}) {
  return request({ url: '/user/login', method: 'post', data, ...config })
}

export function register(data) {
  return request({ url: '/user/register', method: 'post', data })
}
