import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// permissions 兼容：后端登录返回逗号串 / 前端以 JSON 数组存 localStorage / 直接数组
function parsePerms(val) {
  if (Array.isArray(val)) return val.slice()
  if (!val) return []
  return String(val).split(',').map(s => s.trim()).filter(Boolean)
}

export const useUserStore = defineStore('user', () => {
  const username = ref(localStorage.getItem('username') || '管理员')
  const userId = ref(localStorage.getItem('userId') || '')
  const realName = ref(localStorage.getItem('realName') || '')
  const userType = ref(localStorage.getItem('userType') || 'admin')
  // 模块级权限 key 数组（userType=1 系统管理员不受限，isAdmin 直接放行）
  const permissions = ref(parsePerms(localStorage.getItem('permissions')))

  // 系统管理员：登录时 userType===1 会映射为 'admin'（与 Layout 现有 isAdmin 判断一致）
  const isAdmin = computed(() => userType.value === 'admin')

  function hasPerm(key) {
    return isAdmin.value || permissions.value.includes(key)
  }

  function setUser(name, id, real, type, perms) {
    username.value = name
    userId.value = id
    realName.value = real || name
    userType.value = type || 'admin'
    permissions.value = parsePerms(perms)
    localStorage.setItem('username', name)
    localStorage.setItem('userId', id)
    localStorage.setItem('realName', real || name)
    localStorage.setItem('userType', type || 'admin')
    localStorage.setItem('permissions', JSON.stringify(permissions.value))
  }

  function clearUser() {
    username.value = ''
    userId.value = ''
    realName.value = ''
    userType.value = 'admin'
    permissions.value = []
    localStorage.removeItem('username')
    localStorage.removeItem('userId')
    localStorage.removeItem('realName')
    localStorage.removeItem('userType')
    localStorage.removeItem('permissions')
  }

  const isCadre = () => userType.value === 'cadre'

  // 统一角色判断：管理职能账号=系统管理员/校级领导/部长/组织员；其余视为干部/教职工账号
  const isManagerRole = computed(() => isAdmin.value || ['2', '3', '4'].includes(String(userType.value)))
  const isStaffRole = computed(() => !isManagerRole.value && ['cadre', '5', '6'].includes(String(userType.value)))

  return { username, userId, realName, userType, permissions, isAdmin, hasPerm, setUser, clearUser, isCadre, isManagerRole, isStaffRole }
})
