// 账目数据模型
export class Transaction {
  id: number = 0
  amount: number = 0
  type: TransactionType = TransactionType.EXPENSE
  category: string = ''
  merchant: string = ''
  payMethod: string = ''
  transactionTime: number = Date.now()
  remark: string = ''
  sourceApp: string = ''
  createdAt: number = Date.now()
  updatedAt: number = Date.now()

  constructor(init?: Partial<Transaction>) {
    if (init) {
      Object.assign(this, init)
    }
  }
}

// 交易类型
export enum TransactionType {
  EXPENSE = 0,  // 支出
  INCOME = 1    // 收入
}

// 分类数据模型
export class Category {
  id: number = 0
  name: string = ''
  icon: string = ''
  type: TransactionType = TransactionType.EXPENSE
  sortOrder: number = 0
  isDefault: boolean = false

  constructor(init?: Partial<Category>) {
    if (init) {
      Object.assign(this, init)
    }
  }
}

// 自动识别规则
export class AutoRule {
  id: number = 0
  appPackage: string = ''
  pagePattern: string = ''
  amountSelector: string = ''
  merchantSelector: string = ''
  isActive: boolean = true

  constructor(init?: Partial<AutoRule>) {
    if (init) {
      Object.assign(this, init)
    }
  }
}

// 支付识别结果
export class PaymentInfo {
  amount: number = 0
  merchant: string = ''
  payMethod: string = ''
  sourceApp: string = ''
  timestamp: number = Date.now()
  rawText: string = ''

  constructor(init?: Partial<PaymentInfo>) {
    if (init) {
      Object.assign(this, init)
    }
  }
}