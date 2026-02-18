// 应用常量
export const APP_CONSTANTS = {
  APP_NAME: '自动记账',
  VERSION: '1.0.0',
  DB_NAME: 'AutoRecord.db',
  MAX_FLOAT_WINDOW_DURATION: 5000  // 悬浮窗最大显示时间（毫秒）
}

// 存储键名
export const STORAGE_KEYS = {
  AUTO_RECORD_ENABLED: 'auto_record_enabled',
  FIRST_LAUNCH: 'first_launch',
  USER_SETTINGS: 'user_settings'
}

// 默认设置
export const DEFAULT_SETTINGS = {
  autoRecordEnabled: false,
  floatWindowEnabled: true,
  vibrationEnabled: true,
  soundEnabled: false
}