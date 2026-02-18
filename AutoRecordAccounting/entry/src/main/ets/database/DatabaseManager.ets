import { relationalStore } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { Transaction, Category, AutoRule } from '../models/Transaction'
import { 
  CREATE_TRANSACTIONS_TABLE, 
  CREATE_CATEGORIES_TABLE, 
  CREATE_AUTO_RULES_TABLE,
  DEFAULT_CATEGORIES 
} from '../constants/DatabaseConstants'

export class DatabaseManager {
  private static instance: DatabaseManager
  private rdbStore: relationalStore.RdbStore | null = null
  private readonly DB_NAME = 'AutoRecord.db'
  private readonly DB_VERSION = 1

  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager()
    }
    return DatabaseManager.instance
  }

  // 初始化数据库
  async init(): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: this.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    try {
      this.rdbStore = await relationalStore.getRdbStore(getContext(), config)
      await this.createTables()
      await this.initDefaultData()
      console.info('数据库初始化成功')
    } catch (err) {
      console.error('数据库初始化失败:', err)
      throw err
    }
  }

  // 创建表
  private async createTables(): Promise<void> {
    if (!this.rdbStore) return

    try {
      await this.rdbStore.executeSql(CREATE_TRANSACTIONS_TABLE)
      await this.rdbStore.executeSql(CREATE_CATEGORIES_TABLE)
      await this.rdbStore.executeSql(CREATE_AUTO_RULES_TABLE)
      console.info('表创建成功')
    } catch (err) {
      console.error('创建表失败:', err)
      throw err
    }
  }

  // 初始化默认数据
  private async initDefaultData(): Promise<void> {
    const count = await this.getCategoriesCount()
    if (count === 0) {
      for (const category of DEFAULT_CATEGORIES) {
        await this.insertCategory(category as Category)
      }
      console.info('默认分类数据初始化完成')
    }
  }

  // 获取分类数量
  private async getCategoriesCount(): Promise<number> {
    if (!this.rdbStore) return 0
    
    const predicates = new relationalStore.RdbPredicates('categories')
    const resultSet = await this.rdbStore.query(predicates)
    const count = resultSet.rowCount
    resultSet.close()
    return count
  }

  // 插入账目
  async insertTransaction(transaction: Transaction): Promise<number> {
    if (!this.rdbStore) throw new Error('数据库未初始化')

    const values: relationalStore.ValuesBucket = {
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      merchant: transaction.merchant,
      pay_method: transaction.payMethod,
      transaction_time: transaction.transactionTime,
      remark: transaction.remark,
      source_app: transaction.sourceApp,
      created_at: Date.now(),
      updated_at: Date.now()
    }

    try {
      const id = await this.rdbStore.insert('transactions', values)
      console.info('账目插入成功, ID:', id)
      return id
    } catch (err) {
      console.error('插入账目失败:', err)
      throw err
    }
  }

  // 查询账目列表
  async queryTransactions(
    startTime?: number, 
    endTime?: number,
    category?: string,
    type?: number
  ): Promise<Transaction[]> {
    if (!this.rdbStore) throw new Error('数据库未初始化')

    const predicates = new relationalStore.RdbPredicates('transactions')
    
    if (startTime && endTime) {
      predicates.between('transaction_time', startTime, endTime)
    }
    if (category) {
      predicates.equalTo('category', category)
    }
    if (type !== undefined) {
      predicates.equalTo('type', type)
    }
    
    predicates.orderByDesc('transaction_time')

    const resultSet = await this.rdbStore.query(predicates)
    const transactions: Transaction[] = []

    while (resultSet.goToNextRow()) {
      transactions.push(this.parseTransaction(resultSet))
    }
    resultSet.close()

    return transactions
  }

  // 解析账目数据
  private parseTransaction(resultSet: relationalStore.ResultSet): Transaction {
    return new Transaction({
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
      type: resultSet.getLong(resultSet.getColumnIndex('type')),
      category: resultSet.getString(resultSet.getColumnIndex('category')),
      merchant: resultSet.getString(resultSet.getColumnIndex('merchant')),
      payMethod: resultSet.getString(resultSet.getColumnIndex('pay_method')),
      transactionTime: resultSet.getLong(resultSet.getColumnIndex('transaction_time')),
      remark: resultSet.getString(resultSet.getColumnIndex('remark')),
      sourceApp: resultSet.getString(resultSet.getColumnIndex('source_app')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
    })
  }

  // 插入分类
  async insertCategory(category: Category): Promise<number> {
    if (!this.rdbStore) throw new Error('数据库未初始化')

    const values: relationalStore.ValuesBucket = {
      name: category.name,
      icon: category.icon,
      type: category.type,
      sort_order: category.sortOrder,
      is_default: category.isDefault ? 1 : 0
    }

    return await this.rdbStore.insert('categories', values)
  }

  // 查询所有分类
  async queryCategories(type?: number): Promise<Category[]> {
    if (!this.rdbStore) throw new Error('数据库未初始化')

    const predicates = new relationalStore.RdbPredicates('categories')
    if (type !== undefined) {
      predicates.equalTo('type', type)
    }
    predicates.orderByAsc('sort_order')

    const resultSet = await this.rdbStore.query(predicates)
    const categories: Category[] = []

    while (resultSet.goToNextRow()) {
      categories.push(new Category({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        type: resultSet.getLong(resultSet.getColumnIndex('type')),
        sortOrder: resultSet.getLong(resultSet.getColumnIndex('sort_order')),
        isDefault: resultSet.getLong(resultSet.getColumnIndex('is_default')) === 1
      }))
    }
    resultSet.close()

    return categories
  }

  // 统计月度收支
  async getMonthlyStats(year: number, month: number): Promise<{income: number, expense: number}> {
    if (!this.rdbStore) throw new Error('数据库未初始化')

    const startTime = new Date(year, month - 1, 1).getTime()
    const endTime = new Date(year, month, 0).getTime()

    const sql = `
      SELECT 
        SUM(CASE WHEN type = 1 THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN type = 0 THEN amount ELSE 0 END) as expense
      FROM transactions
      WHERE transaction_time BETWEEN ? AND ?
    `

    const resultSet = await this.rdbStore.querySql(sql, [startTime.toString(), endTime.toString()])
    
    let income = 0
    let expense = 0
    
    if (resultSet.goToFirstRow()) {
      income = resultSet.getDouble(resultSet.getColumnIndex('income')) || 0
      expense = resultSet.getDouble(resultSet.getColumnIndex('expense')) || 0
    }
    resultSet.close()

    return { income, expense }
  }

  // 关闭数据库
  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close()
      this.rdbStore = null
      console.info('数据库已关闭')
    }
  }
}