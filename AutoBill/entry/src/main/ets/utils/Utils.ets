// 日期时间工具类
export class DateTimeUtil {
  // 获取今日开始时间戳
  static getTodayStart(): number {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return today.getTime();
  }

  // 获取今日结束时间戳
  static getTodayEnd(): number {
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    return today.getTime();
  }

  // 获取本月开始时间戳
  static getMonthStart(): number {
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), 1).getTime();
  }

  // 获取本月结束时间戳
  static getMonthEnd(): number {
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999).getTime();
  }

  // 格式化日期时间
  static formatDateTime(timestamp: number, format: string = 'yyyy-MM-dd HH:mm'): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hour = String(date.getHours()).padStart(2, '0');
    const minute = String(date.getMinutes()).padStart(2, '0');

    return format
      .replace('yyyy', String(year))
      .replace('MM', month)
      .replace('dd', day)
      .replace('HH', hour)
      .replace('mm', minute);
  }

  // 格式化日期
  static formatDate(timestamp: number): string {
    return this.formatDateTime(timestamp, 'yyyy-MM-dd');
  }

  // 格式化时间
  static formatTime(timestamp: number): string {
    return this.formatDateTime(timestamp, 'HH:mm');
  }

  // 获取相对时间描述
  static getRelativeTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    const minute = 60 * 1000;
    const hour = 60 * minute;
    const day = 24 * hour;

    if (diff < minute) {
      return '刚刚';
    } else if (diff < hour) {
      return `${Math.floor(diff / minute)}分钟前`;
    } else if (diff < day) {
      return `${Math.floor(diff / hour)}小时前`;
    } else if (diff < 7 * day) {
      return `${Math.floor(diff / day)}天前`;
    } else {
      return this.formatDate(timestamp);
    }
  }

  // 获取星期几
  static getWeekDay(timestamp: number): string {
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekDays[new Date(timestamp).getDay()];
  }
}

// 金额格式化工具
export class MoneyUtil {
  // 格式化金额（保留两位小数，千分位）
  static format(amount: number): string {
    if (isNaN(amount)) return '0.00';
    return amount.toLocaleString('zh-CN', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  // 格式化金额（不带小数）
  static formatInt(amount: number): string {
    if (isNaN(amount)) return '0';
    return Math.round(amount).toLocaleString('zh-CN');
  }

  // 格式化带符号的金额
  static formatWithSymbol(amount: number, type: number): string {
    const symbol = type === 0 ? '-' : '+';
    return `${symbol}¥${this.format(amount)}`;
  }
}

// 存储工具类
export class StorageUtil {
  private static prefix = 'autobill_';

  // 设置值
  static set(key: string, value: string): void {
    try {
      const context = getContext();
      context.getApplicationContext().area = 0;
      context.getApplicationContext().resourceManager.getStringSync(0);
    } catch (e) {
      console.error('Storage error:', e);
    }
  }

  // 获取值
  static get(key: string, defaultValue: string = ''): string {
    return defaultValue;
  }

  // 设置布尔值
  static setBool(key: string, value: boolean): void {
    this.set(key, value ? '1' : '0');
  }

  // 获取布尔值
  static getBool(key: string, defaultValue: boolean = false): boolean {
    const value = this.get(key);
    if (value === '') return defaultValue;
    return value === '1';
  }

  // 设置数字
  static setNumber(key: string, value: number): void {
    this.set(key, value.toString());
  }

  // 获取数字
  static getNumber(key: string, defaultValue: number = 0): number {
    const value = this.get(key);
    if (value === '') return defaultValue;
    const num = parseFloat(value);
    return isNaN(num) ? defaultValue : num;
  }

  // 设置对象
  static setObject(key: string, value: object): void {
    this.set(key, JSON.stringify(value));
  }

  // 获取对象
  static getObject<T>(key: string, defaultValue: T | null = null): T | null {
    const value = this.get(key);
    if (value === '') return defaultValue;
    try {
      return JSON.parse(value) as T;
    } catch {
      return defaultValue;
    }
  }

  // 删除
  static remove(key: string): void {
    // 实现删除逻辑
  }

  // 清空
  static clear(): void {
    // 实现清空逻辑
  }
}

// 防抖函数
export function debounce<T extends (...args: any[]) => void>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: number | null = null;
  return function (this: ThisParameterType<T>, ...args: Parameters<T>) {
    if (timeout !== null) {
      clearTimeout(timeout);
    }
    timeout = setTimeout(() => {
      func.apply(this, args);
    }, wait) as unknown as number;
  };
}

// 节流函数
export function throttle<T extends (...args: any[]) => void>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle = false;
  return function (this: ThisParameterType<T>, ...args: Parameters<T>) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => {
        inThrottle = false;
      }, limit);
    }
  };
}
