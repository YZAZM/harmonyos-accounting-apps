import { relationalStore } from '@kit.ArkData';
import DatabaseManager, { TABLE_TRANSACTIONS, TABLE_CATEGORIES } from './DatabaseManager';

// 账目类型：0支出 1收入
export enum TransactionType {
  EXPENSE = 0,
  INCOME = 1
}

// 账目数据模型
export interface Transaction {
  id?: number;
  amount: number;
  type: TransactionType;
  category: string;
  merchant?: string;
  payMethod?: string;
  transactionTime: number;
  remark?: string;
  sourceApp?: string;
  createdAt?: number;
  updatedAt?: number;
}

// 分类数据模型
export interface Category {
  id?: number;
  name: string;
  icon: string;
  type: TransactionType;
  sortOrder: number;
  isDefault: boolean;
}

// 账目数据访问对象
export class TransactionDao {
  // 添加账目
  static async add(transaction: Transaction): Promise<number> {
    const values = {
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      merchant: transaction.merchant || '',
      pay_method: transaction.payMethod || '',
      transaction_time: transaction.transactionTime,
      remark: transaction.remark || '',
      source_app: transaction.sourceApp || 'manual',
      created_at: Date.now(),
      updated_at: Date.now()
    };
    return await DatabaseManager.insert(TABLE_TRANSACTIONS, values);
  }

  // 更新账目
  static async update(transaction: Transaction): Promise<number> {
    if (!transaction.id) return 0;
    const values = {
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      merchant: transaction.merchant || '',
      pay_method: transaction.payMethod || '',
      transaction_time: transaction.transactionTime,
      remark: transaction.remark || '',
      updated_at: Date.now()
    };
    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.equalTo('id', transaction.id);
    return await DatabaseManager.update(TABLE_TRANSACTIONS, values, predicates);
  }

  // 删除账目
  static async delete(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.equalTo('id', id);
    return await DatabaseManager.delete(predicates);
  }

  // 查询所有账目（按时间倒序）
  static async queryAll(limit?: number, offset?: number): Promise<Transaction[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.orderByDesc('transaction_time');
    if (limit !== undefined) {
      predicates.limit(limit);
    }
    if (offset !== undefined) {
      predicates.offset(offset);
    }
    return await this.query(predicates);
  }

  // 按时间范围查询
  static async queryByTimeRange(startTime: number, endTime: number): Promise<Transaction[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.between('transaction_time', startTime, endTime);
    predicates.orderByDesc('transaction_time');
    return await this.query(predicates);
  }

  // 按分类查询
  static async queryByCategory(category: string, type?: TransactionType): Promise<Transaction[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.equalTo('category', category);
    if (type !== undefined) {
      predicates.equalTo('type', type);
    }
    predicates.orderByDesc('transaction_time');
    return await this.query(predicates);
  }

  // 获取今日收支统计
  static async getTodaySummary(): Promise<{ expense: number; income: number }> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const startTime = today.getTime();
    const endTime = startTime + 24 * 60 * 60 * 1000;

    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.between('transaction_time', startTime, endTime);
    
    const resultSet = await DatabaseManager.query(predicates);
    let expense = 0;
    let income = 0;

    while (resultSet.goToNextRow()) {
      const type = resultSet.getLong(resultSet.getColumnIndex('type'));
      const amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
      if (type === TransactionType.EXPENSE) {
        expense += amount;
      } else {
        income += amount;
      }
    }
    resultSet.close();

    return { expense, income };
  }

  // 获取月度统计
  static async getMonthSummary(year: number, month: number): Promise<{ expense: number; income: number }> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);
    
    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.between('transaction_time', startDate.getTime(), endDate.getTime());
    
    const resultSet = await DatabaseManager.query(predicates);
    let expense = 0;
    let income = 0;

    while (resultSet.goToNextRow()) {
      const type = resultSet.getLong(resultSet.getColumnIndex('type'));
      const amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
      if (type === TransactionType.EXPENSE) {
        expense += amount;
      } else {
        income += amount;
      }
    }
    resultSet.close();

    return { expense, income };
  }

  // 获取分类统计
  static async getCategorySummary(startTime: number, endTime: number): Promise<Map<string, number>> {
    const predicates = new relationalStore.RdbPredicates(TABLE_TRANSACTIONS);
    predicates.between('transaction_time', startTime, endTime);
    predicates.equalTo('type', TransactionType.EXPENSE);
    
    const resultSet = await DatabaseManager.query(predicates);
    const categoryMap = new Map<string, number>();

    while (resultSet.goToNextRow()) {
      const category = resultSet.getString(resultSet.getColumnIndex('category'));
      const amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
      const current = categoryMap.get(category) || 0;
      categoryMap.set(category, current + amount);
    }
    resultSet.close();

    return categoryMap;
  }

  // 通用查询方法
  private static async query(predicates: relationalStore.RdbPredicates): Promise<Transaction[]> {
    const resultSet = await DatabaseManager.query(predicates);
    const transactions: Transaction[] = [];

    while (resultSet.goToNextRow()) {
      transactions.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
        type: resultSet.getLong(resultSet.getColumnIndex('type')) as TransactionType,
        category: resultSet.getString(resultSet.getColumnIndex('category')),
        merchant: resultSet.getString(resultSet.getColumnIndex('merchant')),
        payMethod: resultSet.getString(resultSet.getColumnIndex('pay_method')),
        transactionTime: resultSet.getLong(resultSet.getColumnIndex('transaction_time')),
        remark: resultSet.getString(resultSet.getColumnIndex('remark')),
        sourceApp: resultSet.getString(resultSet.getColumnIndex('source_app')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      });
    }
    resultSet.close();
    return transactions;
  }
}

// 分类数据访问对象
export class CategoryDao {
  // 获取所有分类
  static async queryAll(type?: TransactionType): Promise<Category[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_CATEGORIES);
    if (type !== undefined) {
      predicates.equalTo('type', type);
    }
    predicates.orderByAsc('sort_order');
    
    const resultSet = await DatabaseManager.query(predicates);
    const categories: Category[] = [];

    while (resultSet.goToNextRow()) {
      categories.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        type: resultSet.getLong(resultSet.getColumnIndex('type')) as TransactionType,
        sortOrder: resultSet.getLong(resultSet.getColumnIndex('sort_order')),
        isDefault: resultSet.getLong(resultSet.getColumnIndex('is_default')) === 1
      });
    }
    resultSet.close();
    return categories;
  }

  // 添加分类
  static async add(category: Category): Promise<number> {
    const values = {
      name: category.name,
      icon: category.icon,
      type: category.type,
      sort_order: category.sortOrder,
      is_default: category.isDefault ? 1 : 0
    };
    return await DatabaseManager.insert(TABLE_CATEGORIES, values);
  }
}
