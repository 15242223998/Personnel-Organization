import axios from 'axios'
import { ElMessage } from 'element-plus'

const DEFAULT_BASE = '/api'

/**
 * 读取登录页"连接到服务器"保存的自定义后端地址。
 * 返回 null 表示使用系统默认（内置代理 /api）；
 * 返回非空绝对地址（如 http://192.168.1.100:8080）则请求全部指向该服务器。
 */
export function getServerBase() {
  try {
    const raw = localStorage.getItem('serverConn')
    if (!raw) return null
    const obj = JSON.parse(raw)
    const v = (obj && obj.baseUrl ? String(obj.baseUrl).trim() : '')
    return v ? v.replace(/\/+$/, '') : null
  } catch {
    return null
  }
}

const request = axios.create({
  baseURL: DEFAULT_BASE,
  timeout: 30000
})

request.interceptors.request.use(config => {
  const server = getServerBase()
  if (server) {
    config.baseURL = server + '/api'
  } else {
    config.baseURL = DEFAULT_BASE
  }
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

request.interceptors.response.use(
  response => {
    const data = response.data
    if (data.code !== 200) {
      const err = new Error(data.message || '请求失败')
      err.code = data.code
      err.data = data.data
      if (response.config.showError !== false) {
        ElMessage.error(data.message || '请求失败')
      }
      return Promise.reject(err)
    }
    return data
  },
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    ElMessage.error(error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default request
