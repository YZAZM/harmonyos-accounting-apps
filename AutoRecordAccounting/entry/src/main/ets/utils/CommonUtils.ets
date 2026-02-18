// 日期格式化工具
export class DateUtil {
  // 格式化日期为 yyyy-MM-dd
  static formatDate(timestamp: number): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // 格式化日期时间
  static formatDateTime(timestamp: number): string {
    const date = new Date(timestamp)
    const dateStr = this.formatDate(timestamp)
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    return `${dateStr} ${hours}:${minutes}`
  }

  // 获取今天的开始时间
  static getTodayStart(): number {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
  }

  // 获取今天的结束时间
  static getTodayEnd(): number {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1).getTime() - 1
  }

  // 获取本月的开始时间
  static getMonthStart(): number {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth(), 1).getTime()
  }

  // 获取本月的结束时间
  static getMonthEnd(): number {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth() + 1, 0).getTime()
  }
}

// 金额格式化
export class MoneyUtil {
  // 格式化为人民币格式
  static format(amount: number): string {
    return `¥ ${amount.toFixed(2)}`
  }

  // 格式化为带符号的人民币
  static formatWithSign(amount: number, type: number): string {
    const sign = type === 1 ? '+' : '-'
    return `${sign}¥ ${amount.toFixed(2)}`
  }
}

// 商户分类映射
export class CategoryClassifier {
  private static readonly CATEGORY_KEYWORDS: Record<string, string[]> = {
    '餐饮': ['餐厅','饭店','美食','咖啡','奶茶','肯德基','麦当劳','星巴克','海底捞','火锅','烧烤','小吃','快餐','面包','蛋糕','甜品'],
    '交通': ['地铁','公交','打车','滴滴','高德','加油站','停车','地铁','高速费','充电站','保养','维修'],
    '购物': ['超市','便利店','京东','淘宝','天猫','拼多多','商场','超市','便利店','优衣库','永辉','盒马'],
    '娱乐': ['电影票','游戏','KTV','游乐场','会员','视频','音乐','爱奇艺','腾讯','B站','Netflix'],
    '居住': ['房租','水电','燃气','物业','宽带','暖气','维修','搬家'],
    '医疗': ['医院','药店','诊所','挂号','体检','牙科','眼科','中医'],
    '教育': ['培训','课程','学费','教材','考试','学习','书籍'],
    '通讯': ['话费','流量','移动','联通','电信','宽带']
  }

  // 根据商户名称自动分类
  static classify(merchant: string): string {
    const lowerMerchant = merchant.toLowerCase()
    
    for (const [category, keywords] of Object.entries(this.CATEGORY_KEYWORDS)) {
      for (const keyword of keywords) {
        if (lowerMerchant.includes(keyword.toLowerCase())) {
          return category
        }
      }
    }
    
    return '其他'
  }
}