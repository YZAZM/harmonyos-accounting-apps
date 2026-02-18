// Transaction Model 单元测试

import { describe, it, Assert } from './TestFramework'
import { Transaction, TransactionType, Category, PaymentInfo, AutoRule } from '../../main/ets/models/Transaction'
import { TestDataFactory } from './TestDataFactory'

describe('Transaction Model Tests', () => {
  
  it('should create Transaction with default values', () => {
    const transaction = new Transaction()
    
    Assert.equal(transaction.id, 0)
    Assert.equal(transaction.amount, 0)
    Assert.equal(transaction.type, TransactionType.EXPENSE)
    Assert.equal(transaction.category, '')
    Assert.equal(transaction.merchant, '')
    Assert.notNull(transaction.transactionTime)
    Assert.notNull(transaction.createdAt)
    Assert.notNull(transaction.updatedAt)
  })

  it('should create Transaction with provided values', () => {
    const transaction = new Transaction({
      id: 1,
      amount: 128.50,
      type: TransactionType.INCOME,
      category: '工资',
      merchant: '公司',
      payMethod: '银行卡',
      remark: '月工资'
    })
    
    Assert.equal(transaction.id, 1)
    Assert.equal(transaction.amount, 128.50)
    Assert.equal(transaction.type, TransactionType.INCOME)
    Assert.equal(transaction.category, '工资')
    Assert.equal(transaction.merchant, '公司')
    Assert.equal(transaction.payMethod, '银行卡')
    Assert.equal(transaction.remark, '月工资')
  })

  it('should create Transaction from partial object', () => {
    const transaction = new Transaction({
      amount: 99.99,
      category: '餐饮'
    })
    
    Assert.equal(transaction.amount, 99.99)
    Assert.equal(transaction.category, '餐饮')
    Assert.equal(transaction.type, TransactionType.EXPENSE) // 默认值
  })
})

describe('Category Model Tests', () => {
  
  it('should create Category with default values', () => {
    const category = new Category()
    
    Assert.equal(category.id, 0)
    Assert.equal(category.name, '')
    Assert.equal(category.icon, '')
    Assert.equal(category.type, TransactionType.EXPENSE)
    Assert.equal(category.sortOrder, 0)
    Assert.false(category.isDefault)
  })

  it('should create Category with provided values', () => {
    const category = new Category({
      id: 1,
      name: '餐饮',
      icon: '🍔',
      type: TransactionType.EXPENSE,
      sortOrder: 1,
      isDefault: true
    })
    
    Assert.equal(category.id, 1)
    Assert.equal(category.name, '餐饮')
    Assert.equal(category.icon, '🍔')
    Assert.equal(category.type, TransactionType.EXPENSE)
    Assert.equal(category.sortOrder, 1)
    Assert.true(category.isDefault)
  })
})

describe('PaymentInfo Model Tests', () => {
  
  it('should create PaymentInfo with default values', () => {
    const paymentInfo = new PaymentInfo()
    
    Assert.equal(paymentInfo.amount, 0)
    Assert.equal(paymentInfo.merchant, '')
    Assert.equal(paymentInfo.payMethod, '')
    Assert.equal(paymentInfo.sourceApp, '')
    Assert.notNull(paymentInfo.timestamp)
    Assert.equal(paymentInfo.rawText, '')
  })

  it('should create PaymentInfo with provided values', () => {
    const paymentInfo = new PaymentInfo({
      amount: 128.50,
      merchant: '星巴克',
      payMethod: '余额',
      sourceApp: 'com.tencent.mm',
      rawText: '支付成功 ¥128.50'
    })
    
    Assert.equal(paymentInfo.amount, 128.50)
    Assert.equal(paymentInfo.merchant, '星巴克')
    Assert.equal(paymentInfo.payMethod, '余额')
    Assert.equal(paymentInfo.sourceApp, 'com.tencent.mm')
    Assert.equal(paymentInfo.rawText, '支付成功 ¥128.50')
  })
})

describe('AutoRule Model Tests', () => {
  
  it('should create AutoRule with default values', () => {
    const rule = new AutoRule()
    
    Assert.equal(rule.id, 0)
    Assert.equal(rule.appPackage, '')
    Assert.equal(rule.pagePattern, '')
    Assert.equal(rule.amountSelector, '')
    Assert.equal(rule.merchantSelector, '')
    Assert.true(rule.isActive)
  })

  it('should create AutoRule with provided values', () => {
    const rule = new AutoRule({
      id: 1,
      appPackage: 'com.tencent.mm',
      pagePattern: '支付成功',
      amountSelector: '//Text[contains(text(),"¥")]',
      merchantSelector: '//Text[contains(text(),"收款方")]',
      isActive: true
    })
    
    Assert.equal(rule.id, 1)
    Assert.equal(rule.appPackage, 'com.tencent.mm')
    Assert.equal(rule.pagePattern, '支付成功')
    Assert.equal(rule.amountSelector, '//Text[contains(text(),"¥")]')
    Assert.equal(rule.merchantSelector, '//Text[contains(text(),"收款方")]')
    Assert.true(rule.isActive)
  })
})

describe('TransactionType Enum Tests', () => {
  
  it('should have correct enum values', () => {
    Assert.equal(TransactionType.EXPENSE, 0)
    Assert.equal(TransactionType.INCOME, 1)
  })

  it('should use correct type in Transaction', () => {
    const expenseTransaction = new Transaction({ type: TransactionType.EXPENSE })
    Assert.equal(expenseTransaction.type, 0)

    const incomeTransaction = new Transaction({ type: TransactionType.INCOME })
    Assert.equal(incomeTransaction.type, 1)
  })
})