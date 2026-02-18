import { TransactionType } from '../data/Dao';

// 智能分类器
export class SmartCategorizer {
  // 分类关键词映射表
  private static categoryKeywords: Map<string, string[]> = new Map([
    ['餐饮', ['餐厅', '饭店', '美食', '咖啡', '奶茶', '肯德基', '麦当劳', '星巴克', '海底捞', '火锅', '烧烤', '小吃', '面馆', '食堂', '外卖', '美团', '饿了么', '瑞幸', '喜茶', '奈雪']],
    ['交通', ['地铁', '公交', '打车', '滴滴', '高德', '出租车', '加油站', '停车', '高速费', '火车票', '机票', '携程', '滴滴出行', '曹操', 'T3']],
    ['购物', ['超市', '便利店', '京东', '淘宝', '天猫', '拼多多', '商场', '购物中心', '沃尔玛', '永辉', '盒马', '便利店', '美宜佳', '全家', '7-11', '罗森']],
    ['娱乐', ['电影票', '影院', '游戏', 'KTV', '游乐场', '会员', '腾讯视频', '爱奇艺', '优酷', '网易云', 'QQ音乐', 'B站', '抖音', '快手']],
    ['居住', ['房租', '水电', '电费', '水费', '燃气', '物业', '宽带', '话费', '移动', '联通', '电信']],
    ['医疗', ['医院', '药店', '诊所', '挂号', '体检', '医保', '药房']],
    ['教育', ['学费', '培训', '课程', '教材', '考试', '补习班', '网课', '知乎', '得到', '喜马拉雅']],
    ['数码', ['手机', '电脑', '配件', '苹果', '华为', '小米', '京东数码', '苏宁']],
    ['美容', ['美容', '美发', '美甲', 'SPA', '护肤', '化妆品', '丝芙兰', '屈臣氏']],
    ['宠物', ['宠物', '狗粮', '猫粮', '宠物医院', '宠物店']]
  ]);

  // 根据商户名称自动分类
  static categorize(merchant: string): string {
    if (!merchant || merchant.trim().length === 0) {
      return '其他';
    }

    const lowerMerchant = merchant.toLowerCase();
    
    for (const [category, keywords] of this.categoryKeywords.entries()) {
      for (const keyword of keywords) {
        if (lowerMerchant.includes(keyword.toLowerCase())) {
          return category;
        }
      }
    }

    // 根据商户名称长度和特征做简单判断
    if (lowerMerchant.includes('银行') || lowerMerchant.includes('保险')) {
      return '金融';
    }

    return '其他';
  }

  // 根据交易时间判断（可用于辅助分类）
  static categorizeByTime(merchant: string, hour: number): string {
    const baseCategory = this.categorize(merchant);
    
    // 深夜时段的餐饮可能是夜宵
    if (baseCategory === '餐饮' && (hour >= 22 || hour <= 4)) {
      return '餐饮-夜宵';
    }

    return baseCategory;
  }

  // 添加自定义分类规则
  static addCategoryRule(category: string, keywords: string[]): void {
    const existingKeywords = this.categoryKeywords.get(category) || [];
    const mergedKeywords = [...new Set([...existingKeywords, ...keywords])];
    this.categoryKeywords.set(category, mergedKeywords);
  }

  // 获取所有分类列表
  static getAllCategories(): string[] {
    return Array.from(this.categoryKeywords.keys());
  }
}

// 支付信息解析器
export class PaymentParser {
  // 解析金额（支持多种格式）
  static parseAmount(text: string): number | null {
    if (!text) return null;

    // 匹配金额模式
    const patterns = [
      /¥\s*(\d+\.?\d*)/,
      /(\d+\.?\d*)\s*元/,
      /金额[：:]\s*(\d+\.?\d*)/,
      /(\d+\.\d{2})/  // 简单的两位小数
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match) {
        const amount = parseFloat(match[1]);
        if (!isNaN(amount) && amount > 0) {
          return amount;
        }
      }
    }

    return null;
  }

  // 解析商户名称
  static parseMerchant(text: string): string | null {
    if (!text) return null;

    // 常见商户名称提取规则
    const patterns = [
      /商户[：:]\s*([^\s]+)/,
      /商家[：:]\s*([^\s]+)/,
      /向(.+?)付款/,
      /收款方[：:]\s*([^\s]+)/,
      /(.+?)(?:旗舰店|专卖店|官方店)/
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match && match[1]) {
        return match[1].trim();
      }
    }

    return null;
  }

  // 解析时间
  static parseTime(text: string): number | null {
    if (!text) return null;

    // 匹配常见时间格式
    const patterns = [
      /(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})/,
      /(\d{4}\/\d{2}\/\d{2}\s+\d{2}:\d{2}:\d{2})/,
      /(\d{4}年\d{2}月\d{2}日\s+\d{2}:\d{2})/,
      /(\d{2}:\d{2}:\d{2})/  // 只有时间，默认今天
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match) {
        const date = new Date(match[1].replace(/年|月/g, '-').replace(/日/, ''));
        if (!isNaN(date.getTime())) {
          return date.getTime();
        }
      }
    }

    return null;
  }

  // 判断是否为支付成功页面特征
  static isPaymentSuccess(text: string): boolean {
    const successKeywords = [
      '支付成功', '付款成功', '交易成功', '支付完成', '扫码成功',
      '收款成功', '转账成功', '充值成功', '交易完成', 'success',
      '支付凭证', '交易凭证', '账单详情', '订单详情'
    ];

    const lowerText = text.toLowerCase();
    return successKeywords.some(keyword => lowerText.includes(keyword.toLowerCase()));
  }
}

// 应用识别配置
export const AppRecognitionConfig = {
  // 微信
  'com.tencent.mm': {
    name: '微信',
    successPagePatterns: ['支付成功', '收付款', '转账', '二维码收款'],
    amountSelectors: ['amount', 'money'],
    merchantSelectors: ['merchant', 'shop']
  },
  // 支付宝
  'com.eg.android.AlipayGphone': {
    name: '支付宝',
    successPagePatterns: ['支付成功', '付款成功', '扫一扫', '收款码'],
    amountSelectors: ['amount', 'money'],
    merchantSelectors: ['merchant', 'shop']
  },
  // 各大银行
  'com.icbc': {
    name: '工商银行',
    successPagePatterns: ['交易成功', '支付成功', '转账成功'],
    amountSelectors: ['amount'],
    merchantSelectors: ['merchant']
  },
  'com.chinamworld.main': {
    name: '建设银行',
    successPagePatterns: ['交易成功', '支付成功'],
    amountSelectors: ['amount'],
    merchantSelectors: ['merchant']
  },
  'cmb.pb': {
    name: '招商银行',
    successPagePatterns: ['支付成功', '转账成功'],
    amountSelectors: ['amount'],
    merchantSelectors: ['merchant']
  }
};
