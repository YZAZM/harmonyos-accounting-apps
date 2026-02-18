// 测试数据工厂 - 生成测试数据

import { Transaction, TransactionType, Category, PaymentInfo } from '../../main/ets/models/Transaction'

export class TestDataFactory {
  
  // 创建测试交易记录
  static createTransaction(overrides?: Partial<Transaction>): Transaction {
    return new Transaction({
      id: 1,
      amount: 128.50,
      type: TransactionType.EXPENSE,
      category: '餐饮',
      merchant: '星巴克',
      payMethod: '余额',
      transactionTime: Date.now(),
      remark: '测试备注',
      sourceApp: 'com.tencent.mm',
      createdAt: Date.now(),
      updatedAt: Date.now(),
      ...overrides
    })
  }

  // 创建批量测试交易记录
  static createTransactions(count: number): Transaction[] {
    const transactions: Transaction[] = []
    const categories = ['餐饮', '交通', '购物', '娱乐', '居住']
    const merchants = ['星巴克', '麦当劳', '滴滴', '淘宝', '超市']
    
    for (let i = 0; i < count; i++) {
      transactions.push(this.createTransaction({
        id: i + 1,
        amount: Math.random() * 500 + 10,
        category: categories[i % categories.length],
        merchant: merchants[i % merchants.length],
        transactionTime: Date.now() - i * 86400000 // 每天一条
      }))
    }
    
    return transactions
  }

  // 创建测试分类
  static createCategory(overrides?: Partial<Category>): Category {
    return new Category({
      id: 1,
      name: '餐饮',
      icon: '🍔',
      type: TransactionType.EXPENSE,
      sortOrder: 1,
      isDefault: true,
      ...overrides
    })
  }

  // 创建批量测试分类
  static createCategories(): Category[] {
    return [
      this.createCategory({ id: 1, name: '餐饮', icon: '🍔', sortOrder: 1 }),
      this.createCategory({ id: 2, name: '交通', icon: '🚗', sortOrder: 2 }),
      this.createCategory({ id: 3, name: '购物', icon: '🛍️', sortOrder: 3 }),
      this.createCategory({ id: 4, name: '娱乐', icon: '🎮', sortOrder: 4 }),
      this.createCategory({ id: 5, name: '居住', icon: '🏠', sortOrder: 5 }),
      this.createCategory({ id: 6, name: '工资', icon: '💰', type: TransactionType.INCOME, sortOrder: 1 }),
      this.createCategory({ id: 7, name: '奖金', icon: '🎁', type: TransactionType.INCOME, sortOrder: 2 })
    ]
  }

  // 创建测试支付信息
  static createPaymentInfo(overrides?: Partial<PaymentInfo>): PaymentInfo {
    return new PaymentInfo({
      amount: 99.99,
      merchant: '测试商户',
      payMethod: '余额',
      sourceApp: 'com.tencent.mm',
      timestamp: Date.now(),
      rawText: '支付成功 ￥99.99 商户：测试商户',
      ...overrides
    })
  }

  // 微信支付页面文本
  static getWeChatPayText(): string {
    return `
      支付成功
      ￥128.50
      收款方：星巴克咖啡
      支付方式：零钱
      支付时间：2026-02-16 14:30:25
      交易单号：4200001234567890123456789012
    `
  }

  // 支付宝支付页面文本
  static getAlipayText(): string {
    return `
      付款成功
      -￥256.00
      商家：麦当劳（国贸店）
      付款方式：余额
      创建时间：2026-02-16 12:15:30
      订单号：2026021620001156789012345678
    `
  }

  // 银行支付页面文本
  static getBankPayText(): string {
    return `
      交易成功
      支出金额：￥588.00 元
      商户名称：京东商城
      交易时间：2026-02-16 10:20:15
      交易卡号：6222 **** **** 8888
      交易流水号：ICBC202602161020150001
    `
  }
}