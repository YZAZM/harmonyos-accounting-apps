import { DatabaseManager } from '../database/DatabaseManager'
import { Transaction, TransactionType } from '../models/Transaction'
import { DateUtil, MoneyUtil } from '../utils/CommonUtils'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct StatisticsPage {
  @State selectedTab: number = 0 // 0-月度, 1-年度
  @State selectedMonth: Date = new Date()
  @State monthlyIncome: number = 0
  @State monthlyExpense: number = 0
  @State categoryStats: CategoryStat[] = []
  @State isLoading: boolean = true

  aboutToAppear() {
    this.loadMonthlyStats()
  }

  async loadMonthlyStats() {
    this.isLoading = true
    try {
      // 获取月度统计
      const stats = await DatabaseManager.getInstance().getMonthlyStats(
        this.selectedMonth.getFullYear(),
        this.selectedMonth.getMonth() + 1
      )
      this.monthlyIncome = stats.income
      this.monthlyExpense = stats.expense

      // 获取分类统计
      await this.loadCategoryStats()

    } catch (err) {
      console.error('加载统计数据失败:', err)
    }
    this.isLoading = false
  }

  async loadCategoryStats() {
    const startTime = new Date(this.selectedMonth.getFullYear(), this.selectedMonth.getMonth(), 1).getTime()
    const endTime = new Date(this.selectedMonth.getFullYear(), this.selectedMonth.getMonth() + 1, 0).getTime()
    
    const transactions = await DatabaseManager.getInstance().queryTransactions(startTime, endTime)
    
    // 按分类统计
    const categoryMap = new Map<string, number>()
    for (const t of transactions) {
      if (t.type === TransactionType.EXPENSE) {
        const current = categoryMap.get(t.category) || 0
        categoryMap.set(t.category, current + t.amount)
      }
    }

    // 转换为数组并排序
    this.categoryStats = Array.from(categoryMap.entries())
      .map(([name, amount]) => ({ name, amount, percentage: 0 }))
      .sort((a, b) => b.amount - a.amount)

    // 计算百分比
    const total = this.monthlyExpense
    this.categoryStats.forEach(stat => {
      stat.percentage = total > 0 ? Math.round((stat.amount / total) * 100) : 0
    })
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

        Text('统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(44)
      }
      .width('100%')
      .padding(16)

      // Tab切换
      TabSelector({
        selectedIndex: this.selectedTab,
        tabs: ['月度', '年度'],
        onChange: (index) => {
          this.selectedTab = index
        }
      })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF6B6B')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 月度概览
            MonthlyOverviewCard({
              income: this.monthlyIncome,
              expense: this.monthlyExpense
            })

            // 分类统计
            CategoryStatsCard({ stats: this.categoryStats })

            // 趋势图（简化版）
            TrendChartCard()
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

// 分类统计数据结构
interface CategoryStat {
  name: string
  amount: number
  percentage: number
}

// Tab选择器
@Component
struct TabSelector {
  @Prop selectedIndex: number
  @Prop tabs: string[]
  onChange: (index: number) => void = () => {}

  build() {
    Row({ space: 0 }) {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(16)
            .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedIndex === index ? '#FF6B6B' : '#666')
        }
        .layoutWeight(1)
        .height(44)
        .backgroundColor(this.selectedIndex === index ? '#FFE0E0' : Color.White)
        .onClick(() => {
          this.onChange(index)
        })
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 8 })
  }
}

// 月度概览卡片
@Component
struct MonthlyOverviewCard {
  @Prop income: number
  @Prop expense: number

  build() {
    Column({ space: 16 }) {
      Text('本月概览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)

      Row() {
        Column({ space: 8 }) {
          Text('总支出')
            .fontSize(14)
            .fontColor('#666')
          Text(MoneyUtil.format(this.expense))
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(60)
          .color('#E0E0E0')

        Column({ space: 8 }) {
          Text('总收入')
            .fontSize(14)
            .fontColor('#666')
          Text(MoneyUtil.format(this.income))
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
        }
        .layoutWeight(1)
      }
      .width('100%')

      // 结余
      Row() {
        Text('本月结余')
          .fontSize(14)
          .fontColor('#666')
        
        Blank()
        
        Text(MoneyUtil.format(this.income - this.expense))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.income >= this.expense ? '#4CAF50' : '#FF6B6B')
      }
      .width('100%')
      .padding({ top: 12 })
      .border({ width: { top: 1 }, color: '#F0F0F0' })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
  }
}

// 分类统计卡片
@Component
struct CategoryStatsCard {
  @Prop stats: CategoryStat[]

  build() {
    Column({ space: 12 }) {
      Text('支出分类')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)

      if (this.stats.length === 0) {
        Column() {
          Text('暂无支出数据')
            .fontSize(14)
            .fontColor('#999')
        }
        .padding(32)
        .width('100%')
      } else {
        Column({ space: 12 }) {
          ForEach(this.stats, (stat: CategoryStat, index: number) => {
            CategoryStatItem({ stat: stat, rank: index + 1 })
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

// 分类统计项
@Component
struct CategoryStatItem {
  @Prop stat: CategoryStat
  @Prop rank: number

  build() {
    Column({ space: 8 }) {
      Row() {
        Row({ space: 8 }) {
          Text(`${this.rank}`)
            .fontSize(12)
            .fontColor(Color.White)
            .width(20)
            .height(20)
            .backgroundColor(this.getRankColor())
            .borderRadius(10)
            .textAlign(TextAlign.Center)

          Text(this.stat.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }

        Blank()

        Text(MoneyUtil.format(this.stat.amount))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Row({ space: 8 }) {
        Progress({ value: this.stat.percentage, total: 100, type: ProgressType.Linear })
          .layoutWeight(1)
          .height(6)
          .color(this.getRankColor())
          .backgroundColor('#F0F0F0')

        Text(`${this.stat.percentage}%`)
          .fontSize(12)
          .fontColor('#999')
          .width(36)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  private getRankColor(): string {
    const colors = ['#FF6B6B', '#FF9F43', '#FECA57', '#48DBFB', '#1DD1A1']
    return colors[this.rank - 1] || '#95A5A6'
  }
}

// 趋势图卡片（简化版）
@Component
struct TrendChartCard {
  build() {
    Column({ space: 12 }) {
      Text('支出趋势')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)

      // 这里可以集成图表库显示趋势
      Column() {
        Text('趋势图功能开发中...')
          .fontSize(14)
          .fontColor('#999')
      }
      .width('100%')
      .height(200)
      .backgroundColor('#F9F9F9')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
  }
}