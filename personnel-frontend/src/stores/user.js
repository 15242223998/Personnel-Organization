import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const username = ref(localStorage.getItem('username') || '管理员')
  const userId = ref(localStorage.getItem('userId') || '')

  function setUser(name, id) {
    username.value = name
    userId.value = id
    localStorage.setItem('username', name)
    localStorage.setItem('userId', id)
  }

  function clearUser() {
    username.value = ''
    userId.value = ''
    localStorage.removeItem('username')
    localStorage.removeItem('userId')
  }

  return { username, userId, setUser, clearUser }
})
