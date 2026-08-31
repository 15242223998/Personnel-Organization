import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const username = ref(localStorage.getItem('username') || '管理员')
  const userId = ref(localStorage.getItem('userId') || '')
  const realName = ref(localStorage.getItem('realName') || '')
  const userType = ref(localStorage.getItem('userType') || 'admin')

  function setUser(name, id, real, type) {
    username.value = name
    userId.value = id
    realName.value = real || name
    userType.value = type || 'admin'
    localStorage.setItem('username', name)
    localStorage.setItem('userId', id)
    localStorage.setItem('realName', real || name)
    localStorage.setItem('userType', type || 'admin')
  }

  function clearUser() {
    username.value = ''
    userId.value = ''
    realName.value = ''
    userType.value = 'admin'
    localStorage.removeItem('username')
    localStorage.removeItem('userId')
    localStorage.removeItem('realName')
    localStorage.removeItem('userType')
  }

  const isCadre = () => userType.value === 'cadre'

  return { username, userId, realName, userType, setUser, clearUser, isCadre }
})
