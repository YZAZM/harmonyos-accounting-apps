import { AccessibilityExtensionAbility, AccessibilityElementInfo } from '@kit.AccessibilityKit'
import { PaymentDetector } from './PaymentDetector'
import { FloatWindowManager } from './FloatWindowManager'
import { promptAction } from '@kit.ArkUI'

export default class AutoRecordAccessibilityAbility extends AccessibilityExtensionAbility {
  private paymentDetector: PaymentDetector = new PaymentDetector()
  private floatWindowManager: FloatWindowManager = new FloatWindowManager()

  onConnect(): void {
    console.info('无障碍服务已连接')
    
    // 注册页面变化监听
    this.registerEventListeners()
  }

  onDisconnect(): void {
    console.info('无障碍服务已断开')
  }

  onPageUpdate(pageInfo: AccessibilityElementInfo): void {
    // 检测是否为支付页面
    if (this.paymentDetector.isPaymentPage(pageInfo)) {
      console.info('检测到支付页面:', pageInfo.bundleName)
      
      // 提取支付信息
      const paymentInfo = this.paymentDetector.extractPaymentInfo(pageInfo)
      
      if (paymentInfo && paymentInfo.amount > 0) {
        console.info('提取到支付信息:', JSON.stringify(paymentInfo))
        
        // 显示悬浮确认窗
        this.showConfirmWindow(paymentInfo)
      }
    }
  }

  onPageContentUpdate(pageInfo: AccessibilityElementInfo): void {
    // 页面内容变化时的处理
    this.onPageUpdate(pageInfo)
  }

  private registerEventListeners(): void {
    // 监听页面变化
    this.on('pageUpdate', (pageInfo: AccessibilityElementInfo) => {
      this.onPageUpdate(pageInfo)
    })

    this.on('pageContentUpdate', (pageInfo: AccessibilityElementInfo) => {
      this.onPageContentUpdate(pageInfo)
    })
  }

  private async showConfirmWindow(paymentInfo: any): Promise<void> {
    try {
      // 检查是否有权限显示悬浮窗
      const hasPermission = await this.checkFloatWindowPermission()
      if (!hasPermission) {
        console.warn('没有悬浮窗权限')
        return
      }

      // 显示确认窗
      await this.floatWindowManager.show(paymentInfo)
      
    } catch (err) {
      console.error('显示确认窗失败:', err)
    }
  }

  private async checkFloatWindowPermission(): Promise<boolean> {
    // 检查悬浮窗权限
    try {
      // 这里需要根据鸿蒙实际API实现权限检查
      return true
    } catch {
      return false
    }
  }
}