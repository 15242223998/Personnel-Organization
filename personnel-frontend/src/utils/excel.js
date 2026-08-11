import * as XLSX from 'xlsx'
import { ElMessage } from 'element-plus'

const FORMAT_CONFIG = {
  xlsx: { ext: '.xlsx', bookType: 'xlsx', mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' },
  xls: { ext: '.xls', bookType: 'biff8', mime: 'application/vnd.ms-excel' },
  csv: { ext: '.csv', bookType: 'csv', mime: 'text/csv;charset=utf-8' }
}

function downloadBlob(content, fileName, mime) {
  const blob = new Blob([content], { type: mime })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = fileName
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

/**
 * 导出数据为文件
 * @param {Array} data - 数据数组
 * @param {Array} columns - 列定义 [{prop, label}]
 * @param {string} fileName - 文件名(不含扩展名)
 * @param {string} format - 导出格式: 'xlsx' | 'xls' | 'csv' (默认 xlsx)
 */
export function exportExcel(data, columns, fileName, format = 'xlsx') {
  if (!data || data.length === 0) {
    ElMessage.warning('没有数据可导出')
    return
  }
  const config = FORMAT_CONFIG[format] || FORMAT_CONFIG.xlsx
  const exportData = data.map(row => {
    const obj = {}
    columns.forEach(col => {
      let val = row[col.prop]
      if (val === null || val === undefined) val = ''
      obj[col.label] = val
    })
    return obj
  })

  const ws = XLSX.utils.json_to_sheet(exportData)

  if (format === 'csv') {
    const csvContent = XLSX.utils.sheet_to_csv(ws, { forceQuotes: true })
    downloadBlob('\uFEFF' + csvContent, fileName + config.ext, config.mime)
  } else {
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')
    const buf = XLSX.write(wb, { bookType: config.bookType, type: 'array' })
    downloadBlob(new Uint8Array(buf), fileName + config.ext, config.mime)
  }

  ElMessage.success(`已导出 ${data.length} 条记录 (${format.toUpperCase()})`)
}

/**
 * 解析Excel文件为JSON数组
 * @param {File} file - 上传的Excel文件
 * @returns {Promise<Array>} 解析后的数据数组
 */
export function importExcel(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const wb = XLSX.read(e.target.result, { type: 'array' })
        const sheetName = wb.SheetNames[0]
        const ws = wb.Sheets[sheetName]
        const json = XLSX.utils.sheet_to_json(ws)
        resolve(json)
      } catch (err) {
        reject(new Error('Excel文件解析失败：' + err.message))
      }
    }
    reader.onerror = () => reject(new Error('文件读取失败'))
    reader.readAsArrayBuffer(file)
  })
}

/**
 * 根据列映射导入数据
 * @param {Array} importData - 从Excel解析的原始数据
 * @param {Object} columnMap - 列名映射 { Excel表头: 数据字段prop }
 * @returns {Array} 映射后的数据数组
 */
export function mapImportData(importData, columnMap) {
  return importData.map(row => {
    const mapped = {}
    Object.entries(columnMap).forEach(([excelKey, propKey]) => {
      const val = row[excelKey]
      mapped[propKey] = val !== undefined && val !== null ? val : ''
    })
    return mapped
  })
}
