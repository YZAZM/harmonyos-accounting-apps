import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

// 数据库配置
const DB_NAME = 'autobill.db';
const DB_VERSION = 1;

// 表名常量
export const TABLE_TRANSACTIONS = 'transactions';
export const TABLE_CATEGORIES = 'categories';
export const TABLE_AUTO_RULES = 'auto_rules';

// 数据库管理类
export class DatabaseManager {
  private static instance: DatabaseManager;
  private rdbStore: relationalStore.RelationalStore | null = null;

  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  // 初始化数据库
  async init(): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1,
      encrypt: false
    };

    try {
      this.rdbStore = await relationalStore.getRdbStore(getContext(), config);
      await this.createTables();
      await this.initDefaultCategories();
      console.info('数据库初始化成功');
    } catch (err) {
      console.error('数据库初始化失败:', JSON.stringify(err));
      throw err;
    }
  }

  // 创建表
  private async createTables(): Promise<void> {
    // 账目表
    const createTransactionsSQL = `
      CREATE TABLE IF NOT EXISTS ${TABLE_TRANSACTIONS} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL,
        merchant TEXT,
        pay_method TEXT,
        transaction_time INTEGER NOT NULL,
        remark TEXT,
        source_app TEXT,
        created_at INTEGER DEFAULT CURRENT_TIMESTAMP,
        updated_at INTEGER
      )
    `;

    // 分类表
    const createCategoriesSQL = `
      CREATE TABLE IF NOT EXISTS ${TABLE_CATEGORIES} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        type INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0
      )
    `;

    // 自动识别规则表
    const createAutoRulesSQL = `
      CREATE TABLE IF NOT EXISTS ${TABLE_AUTO_RULES} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_package TEXT NOT NULL,
        page_pattern TEXT,
        amount_selector TEXT,
        merchant_selector TEXT,
        is_active INTEGER DEFAULT 1
      )
    `;

    await this.executeSQL(createTransactionsSQL);
    await this.executeSQL(createCategoriesSQL);
    await this.executeSQL(createAutoRulesSQL);
  }

  // 初始化默认分类
  private async initDefaultCategories(): Promise<void> {
    const count = await this.queryCount(TABLE_CATEGORIES);
    if (count > 0) return;

    const defaultCategories = [
      { name: '餐饮', icon: '🍽️', type: 0, sort_order: 1, is_default: 1 },
      { name: '交通', icon: '🚗', type: 0, sort_order: 2, is_default: 1 },
      { name: '购物', icon: '🛍️', type: 0, sort_order: 3, is_default: 1 },
      { name: '娱乐', icon: '🎮', type: 0, sort_order: 4, is_default: 1 },
      { name: '居住', icon: '🏠', type: 0, sort_order: 5, is_default: 1 },
      { name: '医疗', icon: '🏥', type: 0, sort_order: 6, is_default: 1 },
      { name: '教育', icon: '📚', type: 0, sort_order: 7, is_default: 1 },
      { name: '工资', icon: '💰', type: 1, sort_order: 1, is_default: 1 },
      { name: '奖金', icon: '🎁', type: 1, sort_order: 2, is_default: 1 },
      { name: '投资', icon: '📈', type: 1, sort_order: 3, is_default: 1 }
    ];

    for (const category of defaultCategories) {
      await this.insert(TABLE_CATEGORIES, category as ValuesBucket);
    }
  }

  // 执行SQL
  private async executeSQL(sql: string): Promise<void> {
    if (!this.rdbStore) return;
    try {
      await this.rdbStore.execute(sql);
    } catch (err) {
      console.error('执行SQL失败:', sql, JSON.stringify(err));
    }
  }

  // 插入数据
  async insert(table: string, values: ValuesBucket): Promise<number> {
    if (!this.rdbStore) return -1;
    try {
      const rowId = await this.rdbStore.insert(table, values);
      return rowId;
    } catch (err) {
      console.error('插入数据失败:', JSON.stringify(err));
      return -1;
    }
  }

  // 更新数据
  async update(table: string, values: ValuesBucket, predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.rdbStore) return 0;
    try {
      const count = await this.rdbStore.update(values, predicates);
      return count;
    } catch (err) {
      console.error('更新数据失败:', JSON.stringify(err));
      return 0;
    }
  }

  // 删除数据
  async delete(predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.rdbStore) return 0;
    try {
      const count = await this.rdbStore.delete(predicates);
      return count;
    } catch (err) {
      console.error('删除数据失败:', JSON.stringify(err));
      return 0;
    }
  }

  // 查询数据
  async query(predicates: relationalStore.RdbPredicates, columns?: string[]): Promise<relationalStore.ResultSet> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }
    return await this.rdbStore.query(predicates, columns);
  }

  // 查询数量
  private async queryCount(table: string): Promise<number> {
    if (!this.rdbStore) return 0;
    const predicates = new relationalStore.RdbPredicates(table);
    const resultSet = await this.rdbStore.query(predicates, ['COUNT(*) as count']);
    let count = 0;
    if (resultSet.goToFirstRow()) {
      count = resultSet.getLong(0);
    }
    resultSet.close();
    return count;
  }

  // 关闭数据库
  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = null;
    }
  }
}

export default DatabaseManager.getInstance();
