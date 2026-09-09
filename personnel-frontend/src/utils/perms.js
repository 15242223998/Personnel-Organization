// ========== 模块级权限常量（与后端 sys_user.permissions 逗号分隔值对应） ==========
export const PERM_KEYS = [
  { key: 'organization', label: '组织机构管理' },
  { key: 'cadre', label: '干部信息管理' },
  { key: 'transfer', label: '干部调配管理' },
  { key: 'promotion', label: '职级晋升管理' },
  { key: 'appointment', label: '干部任免管理' },
  { key: 'evaluation', label: '干部考察评价管理' },
  { key: 'supervision', label: '干部监督管理' },
  { key: 'assessment', label: '干部考核管理' },
  { key: 'daily', label: '日常事务管理' },
  { key: 'system', label: '系统管理' }
]

// 每个权限 key 覆盖的路由前缀
const PERM_PREFIX_MAP = [
  { key: 'organization', prefixes: ['/organization', '/position-level', '/rank'] },
  { key: 'cadre', prefixes: ['/cadre'] },
  { key: 'transfer', prefixes: ['/transfer'] },
  { key: 'promotion', prefixes: ['/promotion'] },
  { key: 'appointment', prefixes: ['/appointment'] },
  { key: 'evaluation', prefixes: ['/evaluation'] },
  { key: 'supervision', prefixes: ['/supervision'] },
  { key: 'assessment', prefixes: ['/assessment'] },
  { key: 'daily', prefixes: ['/daily'] },
  { key: 'system', prefixes: ['/system'] }
]

// 默认放行路径（无需任何模块权限）
const OPEN_PATHS = ['/dashboard', '/profile']

/**
 * 命中判断：路由 path 以某 key 对应前缀开头，返回前缀最长匹配的权限 key；
 * 默认放行路径或未命中任何模块时返回 null（null 表示不拦截）。
 */
export function matchPermKey(path) {
  if (!path) return null
  if (OPEN_PATHS.some(p => path === p || path.startsWith(p + '/'))) return null
  let best = null
  let bestLen = -1
  PERM_PREFIX_MAP.forEach(({ key, prefixes }) => {
    prefixes.forEach(pre => {
      if (path === pre || path.startsWith(pre + '/')) {
        if (pre.length > bestLen) {
          bestLen = pre.length
          best = key
        }
      }
    })
  })
  return best
}

// 由 key 反查模块名称
export function permLabel(key) {
  const item = PERM_KEYS.find(p => p.key === key)
  return item ? item.label : ''
}
