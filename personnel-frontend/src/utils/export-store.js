import { reactive } from 'vue'

export const exportDialog = reactive({
  visible: false,
  data: [],
  columns: [],
  fileName: '',
  resolve: null
})

export function showExportDialog(data, columns, fileName) {
  return new Promise((resolve) => {
    exportDialog.data = data
    exportDialog.columns = columns
    exportDialog.fileName = fileName
    exportDialog.resolve = resolve
    exportDialog.visible = true
  })
}
