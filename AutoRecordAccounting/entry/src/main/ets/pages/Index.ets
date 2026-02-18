import { DatabaseManager } from '../database/DatabaseManager'
import { Transaction, TransactionType } from '../models/Transaction'
import { DateUtil, MoneyUtil } from '../utils/CommonUtils'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  @State todayExpense: number = 0
  @State todayIncome: number = 0
  @State monthExpense: number = 0
  @State monthIncome: number = 0
  @State recentTransactions: Transaction[] = []
  @State isLoading: boolean = true

  aboutToAppear() {
    this.loadData()
  }

  async loadData() {
    this.isLoading = true
    try {
      // 加载今日收支
      const todayStart = DateUtil.getTodayStart()
      const todayEnd = DateUtil.getTodayEnd()
      const todayTransactions = await DatabaseManager.getInstance().queryTransactions(todayStart, todayEnd)
      
      this.todayExpense = todayTransactions
        .filter(t => t.type === TransactionType.EXPENSE)
        .reduce((sum, t) => sum + t.amount, 0)
      this.todayIncome = todayTransactions
        .filter(t => t.type === TransactionType.INCOME)
        .reduce((sum, t) => sum + t.amount, 0)

      // 加载本月收支
      const now = new Date()
      const monthStats = await DatabaseManager.getInstance().getMonthlyStats(now.getFullYear(), now.getMonth() + 1)
      this.monthExpense = monthStats.expense
      this.monthIncome = monthStats.income

      // 加载最近交易
      this.recentTransactions = await DatabaseManager.getInstance().queryTransactions(undefined, undefined, undefined, undefined)
      this.recentTransactions = this.recentTransactions.slice(0, 5)

    } catch (err) {
      console.error('加载数据失败:', err)
    }
    this.isLoading = false
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('自动记账')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Button({ type: ButtonType.Circle }) {
          Text('+')
            .fontSize(24)
            .fontColor(Color.White)
        }
        .width(44)
        .height(44)
        .backgroundColor('#FF6B6B')
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddTransactionPage' })
        })
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column({ space: 16 }) {
          // 今日概览卡片
          TodayCard({
            expense: this.todayExpense,
            income: this.todayIncome
          })

          // 本月概览
          MonthCard({
            expense: this.monthExpense,
            income: this.monthIncome
          })

          // 最近交易
          RecentTransactions({ transactions: this.recentTransactions })
        }
        .padding(16)
      }
      .layoutWeight(1)

      // 底部导航
      BottomNavigation()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

// 今日概览卡片
@Component
struct TodayCard {
  @Prop expense: number
  @Prop income: number

  build() {
    Column({ space: 12 }) {
      Text('今日收支')
        .fontSize(16)
        .fontColor('#666')
        .alignSelf(ItemAlign.Start)

      Row() {
        Column({ space: 4 }) {
          Text('支出')
            .fontSize(14)
            .fontColor('#999')
          Text(MoneyUtil.format(this.expense))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(40)
          .color('#E0E0E0')

        Column({ space: 4 }) {
          Text('收入')
            .fontSize(14)
            .fontColor('#999')
          Text(MoneyUtil.format(this.income))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
  }
}

// 本月概览卡片
@Component
struct MonthCard {
  @Prop expense: number
  @Prop income: number

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('本月收支')
          .fontSize(16)
          .fontColor('#666')
        
        Blank()
        
        Text('查看更多 >')
          .fontSize(14)
          .fontColor('#999')
      }
      .width('100%')

      // 进度条展示
      Column({ space: 8 }) {
        Row() {
          Text('支出')
            .fontSize(14)
            .fontColor('#666')
          Text(MoneyUtil.format(this.expense))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF6B6B')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Progress({ value: this.expense, total: Math.max(this.expense + this.income, 1), type: ProgressType.Linear })
          .width('100%')
          .color('#FF6B6B')
          .backgroundColor('#FFE0E0')

        Row() {
          Text('收入')
            .fontSize(14)
            .fontColor('#666')
          Text(MoneyUtil.format(this.income))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4CAF50')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Progress({ value: this.income, total: Math.max(this.expense + this.income, 1), type: ProgressType.Linear })
          .width('100%')
          .color('#4CAF50')
          .backgroundColor('#E0F2E0')
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
  }
}

// 最近交易列表
@Component
struct RecentTransactions {
  @Prop transactions: Transaction[]

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('最近交易')
          .fontSize(16)
          .fontColor('#666')
        
        Blank()
        
        Text('查看全部 >')
          .fontSize(14)
          .fontColor('#999')
      }
      .width('100%')

      if (this.transactions.length === 0) {
        Column() {
          Text('暂无交易记录')
            .fontSize(14)
            .fontColor('#999')
        }
        .padding(32)
        .width('100%')
      } else {
        Column({ space: 8 }) {
          ForEach(this.transactions, (transaction: Transaction) => {
            TransactionItem({ transaction: transaction })
          })
        }
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
  }
}

// 交易项
@Component
struct TransactionItem {
  @Prop transaction: Transaction

  build() {
    Row() {
      // 图标
      Text(this.getCategoryIcon())
        .fontSize(24)
        .margin({ right: 12 })

      // 信息
      Column({ space: 4 }) {
        Text(this.transaction.merchant || this.transaction.category)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(DateUtil.formatDateTime(this.transaction.transactionTime))
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 金额
      Text(MoneyUtil.formatWithSign(this.transaction.amount, this.transaction.type))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.transaction.type === 1 ? '#4CAF50' : '#FF6B6B')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F9F9F9')
    .borderRadius(8)
  }

  private getCategoryIcon(): string {
    const iconMap: Record<string, string> = {
      '餐饮': '🍔',
      '交通': '🚗',
      '购物': '🛍️',
      '娱乐': '🎮',
      '居住': '🏠',
      '医疗': '🏥',
      '教育': '📚',
      '其他': '📦',
      '工资': '💰',
      '奖金': '🎁',
      '投资': '📈',
      '兼职': '💼'
    }
    return iconMap[this.transaction.category] || '💰'
  }
}

// 底部导航
@Component
struct BottomNavigation {
  build() {
    Row() {
      NavItem({ icon: '🏠', label: '首页', isActive: true, url: '' })
      NavItem({ icon: '📊', label: '统计', isActive: false, url: 'pages/StatisticsPage' })
      NavItem({ icon: '📋', label: '账单', isActive: false, url: 'pages/TransactionListPage' })
      NavItem({ icon: '⚙️', label: '设置', isActive: false, url: 'pages/SettingsPage' })
    }
    .width('100%')
    .height(64)
    .backgroundColor(Color.White)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
  }
}

// 导航项
@Component
struct NavItem {
  @Prop icon: string
  @Prop label: string
  @Prop isActive: boolean
  @Prop url: string

  build() {
    Column({ space: 4 }) {
      Text(this.icon)
        .fontSize(20)
      Text(this.label)
        .fontSize(12)
        .fontColor(this.isActive ? '#FF6B6B' : '#999')
    }
    .layoutWeight(1)
    .onClick(() => {
      if (this.url && !this.isActive) {
        router.pushUrl({ url: this.url })
      }
    })
  }
}