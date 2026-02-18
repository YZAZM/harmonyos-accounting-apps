// 数据库表结构定义

// 账目表SQL
export const CREATE_TRANSACTIONS_TABLE = `
  CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount DECIMAL(10,2) NOT NULL,
    type INTEGER NOT NULL,
    category TEXT NOT NULL,
    merchant TEXT,
    pay_method TEXT,
    transaction_time INTEGER NOT NULL,
    remark TEXT,
    source_app TEXT,
    created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
    updated_at INTEGER DEFAULT (strftime('%s', 'now') * 1000)
  )
`

// 分类表SQL
export const CREATE_CATEGORIES_TABLE = `
  CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    icon TEXT,
    type INTEGER NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_default INTEGER DEFAULT 0
  )
`

// 自动识别规则表SQL
export const CREATE_AUTO_RULES_TABLE = `
  CREATE TABLE IF NOT EXISTS auto_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    app_package TEXT NOT NULL,
    page_pattern TEXT,
    amount_selector TEXT,
    merchant_selector TEXT,
    is_active INTEGER DEFAULT 1
  )
`

// 默认分类数据
export const DEFAULT_CATEGORIES = [
  // 支出分类
  { name: '餐饮', icon: '🍔', type: 0, sortOrder: 1, isDefault: 1 },
  { name: '交通', icon: '🚗', type: 0, sortOrder: 2, isDefault: 1 },
  { name: '购物', icon: '🛍️', type: 0, sortOrder: 3, isDefault: 1 },
  { name: '娱乐', icon: '🎮', type: 0, sortOrder: 4, isDefault: 1 },
  { name: '居住', icon: '🏠', type: 0, sortOrder: 5, isDefault: 1 },
  { name: '医疗', icon: '🏥', type: 0, sortOrder: 6, isDefault: 1 },
  { name: '教育', icon: '📚', type: 0, sortOrder: 7, isDefault: 1 },
  { name: '其他', icon: '📦', type: 0, sortOrder: 8, isDefault: 1 },
  // 收入分类
  { name: '工资', icon: '💰', type: 1, sortOrder: 1, isDefault: 1 },
  { name: '奖金', icon: '🎁', type: 1, sortOrder: 2, isDefault: 1 },
  { name: '投资', icon: '📈', type: 1, sortOrder: 3, isDefault: 1 },
  { name: '兼职', icon: '💼', type: 1, sortOrder: 4, isDefault: 1 },
  { name: '其他收入', icon: '💵', type: 1, sortOrder: 5, isDefault: 1 }
]

// 支持的App包名
export const SUPPORTED_APPS = [
  'com.tencent.mm',           // 微信
  'com.eg.android.AlipayGphone', // 支付宝
  'com.android.bank',         // 通用银行
  'com.icbc',                 // 工行
  'com.ccb',                  // 建行
  'com.cmbchina',             // 招行
  'com.bankcomm',             // 交行
  'com.chinamworld.main'      // 中行
]