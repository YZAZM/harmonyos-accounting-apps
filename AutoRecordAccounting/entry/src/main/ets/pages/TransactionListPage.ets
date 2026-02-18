import { DatabaseManager } from '../database/DatabaseManager'
import { Transaction, TransactionType } from '../models/Transaction'
import { DateUtil, MoneyUtil } from '../utils/CommonUtils'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct TransactionListPage {
  @State transactions: Transaction[] = []
  @State isLoading: boolean = true
  @State selectedMonth: Date = new Date()

  aboutToAppear() {
    this.loadTransactions()
  }

  async loadTransactions() {
    this.isLoading = true
    try {
      const startTime = new Date(this.selectedMonth.getFullYear(), this.selectedMonth.getMonth(), 1).getTime()
      const endTime = new Date(this.selectedMonth.getFullYear(), this.selectedMonth.getMonth() + 1, 0).getTime()
      
      this.transactions = await DatabaseManager.getInstance().queryTransactions(startTime, endTime)
    } catch (err) {
      console.error('加载账单失败:', err)
    }
    this.isLoading = false
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#333')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back()
        })

        Text('账单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(44)
      }
      .width('100%')
      .padding(16)

      // 月份选择器
      MonthSelector({
        currentMonth: this.selectedMonth,
        onChange: (month) => {
          this.selectedMonth = month
          this.loadTransactions()
        }
      })

      // 账单列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF6B6B')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.transactions.length === 0) {
        Column() {
          Text('本月暂无账单')
            .fontSize(16)
            .fontColor('#999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.transactions, (transaction: Transaction) => {
            ListItem() {
              TransactionListItem({ transaction: transaction })
            }
          })
        }
        .padding(16)
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

// 月份选择器
@Component
struct MonthSelector {
  @Prop currentMonth: Date
  onChange: (month: Date) => void = () => {}

  build() {
    Row() {
      Button() {
        Text('◀')
          .fontSize(16)
          .fontColor('#666')
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        const newMonth = new Date(this.currentMonth)
        newMonth.setMonth(newMonth.getMonth() - 1)
        this.onChange(newMonth)
      })

      Text(`${this.currentMonth.getFullYear()}年${this.currentMonth.getMonth() + 1}月`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button() {
        Text('▶')
          .fontSize(16)
          .fontColor('#666')
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        const newMonth = new Date(this.currentMonth)
        newMonth.setMonth(newMonth.getMonth() + 1)
        this.onChange(newMonth)
      })
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }
}

// 账单列表项
@Component
struct TransactionListItem {
  @Prop transaction: Transaction

  build() {
    Row() {
      // 图标
      Column() {
        Text(this.getCategoryIcon())
          .fontSize(28)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F5F5F5')
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)

      // 信息
      Column({ space: 4 }) {
        Text(this.transaction.merchant || this.transaction.category)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(`${this.transaction.category} · ${DateUtil.formatDate(this.transaction.transactionTime)}`)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 金额
      Text(MoneyUtil.formatWithSign(this.transaction.amount, this.transaction.type))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.transaction.type === 1 ? '#4CAF50' : '#FF6B6B')
    }
    .width('100%')
    .height(72)
    .padding(12)
    .backgroundColor(Color.White)
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