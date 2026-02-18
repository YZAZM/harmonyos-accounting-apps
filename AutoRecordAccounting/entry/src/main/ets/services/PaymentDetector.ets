import { AccessibilityElementInfo } from '@kit.AccessibilityKit'
import { PaymentInfo } from '../models/Transaction'
import { CategoryClassifier } from '../utils/CommonUtils'
import { SUPPORTED_APPS } from '../constants/DatabaseConstants'

export class PaymentDetector {
  // 支付成功页面的特征
  private readonly PAYMENT_SUCCESS_KEYWORDS = [
    '支付成功',
    '付款成功', 
    '交易成功',
    '支付完成',
    '转账成功',
    '收款成功',
    '支付凭证',
    '交易详情'
  ]

  // 金额相关的控件类型
  private readonly AMOUNT_VIEW_TYPES = ['Text', 'Button', 'View']

  // 检测是否为支付页面
  isPaymentPage(pageInfo: AccessibilityElementInfo): boolean {
    // 检查应用包名是否在支持列表
    if (!this.isSupportedApp(pageInfo.bundleName)) {
      return false
    }

    // 检查页面是否包含支付成功特征
    const pageText = this.extractAllText(pageInfo)
    
    for (const keyword of this.PAYMENT_SUCCESS_KEYWORDS) {
      if (pageText.includes(keyword)) {
        return true
      }
    }

    // 针对特定App的特殊检测
    if (this.isWeChatPayPage(pageInfo)) return true
    if (this.isAlipayPage(pageInfo)) return true

    return false
  }

  // 提取支付信息
  extractPaymentInfo(pageInfo: AccessibilityElementInfo): PaymentInfo | null {
    const paymentInfo = new PaymentInfo()
    paymentInfo.sourceApp = pageInfo.bundleName

    // 提取金额
    paymentInfo.amount = this.extractAmount(pageInfo)
    if (paymentInfo.amount === 0) {
      return null
    }

    // 提取商户信息
    paymentInfo.merchant = this.extractMerchant(pageInfo)
    
    // 提取支付方式
    paymentInfo.payMethod = this.extractPayMethod(pageInfo)

    // 记录原始文本用于调试
    paymentInfo.rawText = this.extractAllText(pageInfo)

    return paymentInfo
  }

  // 检查是否为支持的App
  private isSupportedApp(bundleName: string): boolean {
    return SUPPORTED_APPS.some(app => bundleName.includes(app))
  }

  // 微信支付页面检测
  private isWeChatPayPage(pageInfo: AccessibilityElementInfo): boolean {
    if (!pageInfo.bundleName.includes('com.tencent.mm')) {
      return false
    }

    const pageText = this.extractAllText(pageInfo)
    return pageText.includes('支付成功') && pageText.includes('￥')
  }

  // 支付宝页面检测
  private isAlipayPage(pageInfo: AccessibilityElementInfo): boolean {
    if (!pageInfo.bundleName.includes('Alipay')) {
      return false
    }

    const pageText = this.extractAllText(pageInfo)
    return pageText.includes('支付成功') || pageText.includes('付款成功')
  }

  // 提取金额
  private extractAmount(pageInfo: AccessibilityElementInfo): number {
    const text = this.extractAllText(pageInfo)
    
    // 匹配金额的正则表达式
    const patterns = [
      /[¥￥]\s*(\d+\.?\d{0,2})/,  // ¥123.45 或 ￥123
      /(\d+\.\d{2})\s*元/,          // 123.45元
      /金额[：:]\s*(\d+\.?\d{0,2})/, // 金额：123.45
      /合计[：:]\s*[¥￥]?\s*(\d+\.?\d{0,2})/, // 合计：¥123.45
      /(\d+\.\d{2})/                // 通用数字匹配
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match && match[1]) {
        const amount = parseFloat(match[1])
        if (amount > 0 && amount < 1000000) {  // 合理性检查
          return amount
        }
      }
    }

    return 0
  }

  // 提取商户信息
  private extractMerchant(pageInfo: AccessibilityElementInfo): string {
    const text = this.extractAllText(pageInfo)
    
    // 商户名提取规则
    const patterns = [
      /商户[名称]*[：:]\s*([^\n]+)/,
      /商家[：:]\s*([^\n]+)/,
      /向(.+?)付款/,
      /收款方[：:]\s*([^\n]+)/,
      /转账给\s*([^\n]+)/
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match && match[1]) {
        return match[1].trim()
      }
    }

    // 尝试从控件文本中提取
    const merchant = this.findMerchantFromControls(pageInfo)
    if (merchant) {
      return merchant
    }

    return '未知商户'
  }

  // 从控件中提取商户
  private findMerchantFromControls(pageInfo: AccessibilityElementInfo): string | null {
    // 遍历子控件查找可能的商户名
    if (pageInfo.children) {
      for (const child of pageInfo.children) {
        const text = child.text || ''
        // 商户名通常是较短的文本，且不包含数字
        if (text.length > 2 && text.length < 20 && !/\d/.test(text)) {
          // 排除常见的非商户文本
          if (!this.isCommonExclusion(text)) {
            return text
          }
        }
      }
    }
    return null
  }

  // 提取支付方式
  private extractPayMethod(pageInfo: AccessibilityElementInfo): string {
    const text = this.extractAllText(pageInfo)
    
    if (text.includes('零钱') || text.includes('余额')) {
      return '余额'
    } else if (text.includes('信用卡')) {
      return '信用卡'
    } else if (text.includes('储蓄卡') || text.includes('借记卡')) {
      return '储蓄卡'
    } else if (text.includes('花呗')) {
      return '花呗'
    }

    return '其他'
  }

  // 提取所有文本
  private extractAllText(element: AccessibilityElementInfo): string {
    let text = element.text || ''
    
    if (element.contentDescription) {
      text += ' ' + element.contentDescription
    }

    if (element.children) {
      for (const child of element.children) {
        text += ' ' + this.extractAllText(child)
      }
    }

    return text
  }

  // 常见排除文本
  private isCommonExclusion(text: string): boolean {
    const exclusions = [
      '支付成功', '付款成功', '交易成功', '完成', '返回',
      '确定', '取消', '关闭', '详情', '查看更多'
    ]
    return exclusions.some(ex => text.includes(ex))
  }
}