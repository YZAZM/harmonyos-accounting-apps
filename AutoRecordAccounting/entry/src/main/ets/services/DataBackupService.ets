import { DatabaseManager } from '../database/DatabaseManager'
import { Transaction } from '../models/Transaction'
import { fileIo } from '@kit.CoreFileKit'
import { DateUtil } from '../utils/CommonUtils'

export class DataBackupService {
  private static readonly BACKUP_FOLDER = 'AutoRecord/Backups'

  // 导出数据为JSON
  async exportToJSON(): Promise<string> {
    try {
      // 查询所有交易记录
      const transactions = await DatabaseManager.getInstance().queryTransactions()
      
      // 构建导出数据
      const exportData = {
        version: '1.0.0',
        exportTime: Date.now(),
        transactionCount: transactions.length,
        transactions: transactions
      }

      // 转换为JSON字符串
      const jsonString = JSON.stringify(exportData, null, 2)
      
      // 生成文件名
      const fileName = `backup_${DateUtil.formatDate(Date.now())}_${Date.now()}.json`
      const filePath = `${this.getBackupDir()}/${fileName}`

      // 写入文件
      const file = await fileIo.open(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
      await fileIo.write(file.fd, jsonString)
      await fileIo.close(file.fd)

      console.info('数据导出成功:', filePath)
      return filePath

    } catch (err) {
      console.error('数据导出失败:', err)
      throw err
    }
  }

  // 导入JSON数据
  async importFromJSON(filePath: string): Promise<{ success: boolean, count: number }> {
    try {
      // 读取文件
      const file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY)
      const stat = await fileIo.stat(file.fd)
      const buffer = new ArrayBuffer(stat.size)
      await fileIo.read(file.fd, buffer)
      await fileIo.close(file.fd)

      // 解析JSON
      const decoder = new TextDecoder()
      const jsonString = decoder.decode(buffer)
      const importData = JSON.parse(jsonString)

      // 验证数据格式
      if (!importData.transactions || !Array.isArray(importData.transactions)) {
        throw new Error('无效的备份文件格式')
      }

      // 导入交易记录
      let successCount = 0
      for (const transactionData of importData.transactions) {
        try {
          const transaction = new Transaction(transactionData)
          await DatabaseManager.getInstance().insertTransaction(transaction)
          successCount++
        } catch (err) {
          console.error('导入单条记录失败:', err)
        }
      }

      console.info(`数据导入完成，成功导入 ${successCount} 条记录`)
      return { success: true, count: successCount }

    } catch (err) {
      console.error('数据导入失败:', err)
      throw err
    }
  }

  // 导出为CSV格式
  async exportToCSV(): Promise<string> {
    try {
      const transactions = await DatabaseManager.getInstance().queryTransactions()
      
      // CSV头部
      let csvContent = 'ID,金额,类型,分类,商户,支付方式,交易时间,备注,来源\n'

      // 数据行
      for (const t of transactions) {
        const row = [
          t.id,
          t.amount,
          t.type === 0 ? '支出' : '收入',
          t.category,
          t.merchant,
          t.payMethod,
          DateUtil.formatDateTime(t.transactionTime),
          t.remark,
          t.sourceApp
        ].map(field => `"${field}"`).join(',')

        csvContent += row + '\n'
      }

      // 保存文件
      const fileName = `export_${DateUtil.formatDate(Date.now())}.csv`
      const filePath = `${this.getBackupDir()}/${fileName}`

      const file = await fileIo.open(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
      const encoder = new TextEncoder()
      await fileIo.write(file.fd, encoder.encode(csvContent))
      await fileIo.close(file.fd)

      console.info('CSV导出成功:', filePath)
      return filePath

    } catch (err) {
      console.error('CSV导出失败:', err)
      throw err
    }
  }

  // 获取备份目录
  private getBackupDir(): string {
    // 返回应用的文件目录
    return getContext().filesDir + '/' + this.BACKUP_FOLDER
  }

  // 列出所有备份文件
  async listBackups(): Promise<string[]> {
    try {
      const dirPath = this.getBackupDir()
      const files = await fileIo.listFile(dirPath)
      return files.filter(file => file.endsWith('.json'))
    } catch (err) {
      console.error('列出备份文件失败:', err)
      return []
    }
  }
}