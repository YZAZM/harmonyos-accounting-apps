// DateUtil 单元测试

import { describe, it, beforeAll, afterAll, Assert } from './TestFramework'
import { DateUtil, MoneyUtil, CategoryClassifier } from '../../main/ets/utils/CommonUtils'

describe('DateUtil Tests', () => {
  
  it('should format date correctly', () => {
    const timestamp = new Date(2026, 1, 16, 14, 30, 0).getTime() // 2026-02-16 14:30:00
    const formatted = DateUtil.formatDate(timestamp)
    Assert.equal(formatted, '2026-02-16')
  })

  it('should format date time correctly', () => {
    const timestamp = new Date(2026, 1, 16, 14, 30, 0).getTime()
    const formatted = DateUtil.formatDateTime(timestamp)
    Assert.equal(formatted, '2026-02-16 14:30')
  })

  it('should get today start time', () => {
    const todayStart = DateUtil.getTodayStart()
    const now = new Date()
    const expected = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
    Assert.equal(todayStart, expected)
  })

  it('should get today end time', () => {
    const todayEnd = DateUtil.getTodayEnd()
    const now = new Date()
    const expected = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1).getTime() - 1
    Assert.equal(todayEnd, expected)
  })

  it('should get month start time', () => {
    const monthStart = DateUtil.getMonthStart()
    const now = new Date()
    const expected = new Date(now.getFullYear(), now.getMonth(), 1).getTime()
    Assert.equal(monthStart, expected)
  })
})

describe('MoneyUtil Tests', () => {
  
  it('should format money with ¥ symbol', () => {
    const formatted = MoneyUtil.format(128.50)
    Assert.equal(formatted, '¥ 128.50')
  })

  it('should format money with two decimal places', () => {
    const formatted = MoneyUtil.format(100)
    Assert.equal(formatted, '¥ 100.00')
  })

  it('should format expense with - sign', () => {
    const formatted = MoneyUtil.formatWithSign(128.50, 0) // 0 = EXPENSE
    Assert.equal(formatted, '-¥ 128.50')
  })

  it('should format income with + sign', () => {
    const formatted = MoneyUtil.formatWithSign(5000, 1) // 1 = INCOME
    Assert.equal(formatted, '+¥ 5000.00')
  })

  it('should handle zero amount', () => {
    const formatted = MoneyUtil.format(0)
    Assert.equal(formatted, '¥ 0.00')
  })
})

describe('CategoryClassifier Tests', () => {
  
  it('should classify food category', () => {
    const category = CategoryClassifier.classify('星巴克咖啡')
    Assert.equal(category, '餐饮')
  })

  it('should classify transport category', () => {
    const category = CategoryClassifier.classify('滴滴出行')
    Assert.equal(category, '交通')
  })

  it('should classify shopping category', () => {
    const category = CategoryClassifier.classify('京东商城')
    Assert.equal(category, '购物')
  })

  it('should classify entertainment category', () => {
    const category = CategoryClassifier.classify('电影院')
    Assert.equal(category, '娱乐')
  })

  it('should classify medical category', () => {
    const category = CategoryClassifier.classify('协和医院')
    Assert.equal(category, '医疗')
  })

  it('should return 其他 for unknown merchant', () => {
    const category = CategoryClassifier.classify('未知商户')
    Assert.equal(category, '其他')
  })

  it('should be case insensitive', () => {
    const category1 = CategoryClassifier.classify('STARBUCKS')
    const category2 = CategoryClassifier.classify('starbucks')
    Assert.equal(category1, category2)
  })
})