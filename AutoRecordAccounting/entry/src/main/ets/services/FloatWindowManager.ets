import { window } from '@kit.ArkUI'
import { PaymentInfo } from '../models/Transaction'
import { DatabaseManager } from '../database/DatabaseManager'
import { Transaction, TransactionType } from '../models/Transaction'
import { CategoryClassifier, MoneyUtil } from '../utils/CommonUtils'

export class FloatWindowManager {
  private floatWindow: window.Window | null = null
  private isShowing: boolean = false

  // 显示确认窗
  async show(paymentInfo: PaymentInfo): Promise<void> {
    if (this.isShowing) {
      console.info('确认窗已在显示中')
      return
    }

    try {
      // 创建悬浮窗
      this.floatWindow = await window.createWindow({
        name: 'ConfirmFloatWindow',
        windowType: window.WindowType.TYPE_FLOAT,
        ctx: getContext()
      })

      // 设置窗口大小和位置
      await this.floatWindow.resize(360, 280)
      await this.floatWindow.moveWindowTo(60, 400)

      // 设置窗口内容
      this.floatWindow.setUIContent('pages/FloatConfirmWindow', (err) => {
        if (err) {
          console.error('加载悬浮窗内容失败:', err)
          return
        }

        // 传递支付信息到悬浮窗
        const storage = LocalStorage.getShared()
        storage.setOrCreate('paymentInfo', paymentInfo)
        storage.setOrCreate('onConfirm', (confirmed: boolean, modifiedInfo?: any) => {
          this.handleConfirm(confirmed, modifiedInfo || paymentInfo)
        })
      })

      // 显示窗口
      await this.floatWindow.showWindow()
      this.isShowing = true

      // 5秒后自动关闭
      setTimeout(() => {
        this.hide()
      }, 5000)

    } catch (err) {
      console.error('显示悬浮窗失败:', err)
      throw err
    }
  }

  // 隐藏悬浮窗
  async hide(): Promise<void> {
    if (this.floatWindow && this.isShowing) {
      await this.floatWindow.destroyWindow()
      this.floatWindow = null
      this.isShowing = false
    }
  }

  // 处理确认结果
  private async handleConfirm(confirmed: boolean, paymentInfo: PaymentInfo): Promise<void> {
    if (confirmed) {
      try {
        // 保存到数据库
        const transaction = new Transaction({
          amount: paymentInfo.amount,
          type: TransactionType.EXPENSE,
          category: CategoryClassifier.classify(paymentInfo.merchant),
          merchant: paymentInfo.merchant,
          payMethod: paymentInfo.payMethod,
          transactionTime: paymentInfo.timestamp,
          sourceApp: paymentInfo.sourceApp
        })

        await DatabaseManager.getInstance().insertTransaction(transaction)
        console.info('自动记账成功:', JSON.stringify(transaction))

      } catch (err) {
        console.error('自动记账失败:', err)
      }
    }

    // 关闭悬浮窗
    await this.hide()
  }
}