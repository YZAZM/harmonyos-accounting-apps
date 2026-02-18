import { router } from '@kit.ArkUI';
import { TransactionDao, Transaction, TransactionType, CategoryDao, Category } from '../data/Dao';
import { DateTimeUtil, MoneyUtil } from '../utils/Utils';

@Entry
@Component
struct Index {
  @State todayExpense: number = 0;
  @State todayIncome: number = 0;
  @State monthExpense: number = 0;
  @State monthIncome: number = 0;
  @State recentTransactions: Transaction[] = [];
  @State isLoading: boolean = true;
  @State selectedTab: number = 0;

  private tabs: string[] = ['首页', '账单', '统计', '我的'];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    
    // 加载今日数据
    const todaySummary = await TransactionDao.getTodaySummary();
    this.todayExpense = todaySummary.expense;
    this.todayIncome = todaySummary.income;

    // 加载本月数据
    const now = new Date();
    const monthSummary = await TransactionDao.getMonthSummary(now.getFullYear(), now.getMonth() + 1);
    this.monthExpense = monthSummary.expense;
    this.monthIncome = monthSummary.income;

    // 加载最近5笔交易
    this.recentTransactions = await TransactionDao.queryAll(5);

    this.isLoading = false;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('自动记账')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        
        Blank()
        
        Button() {
          Text('+ 记一笔')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Capsule)
        .backgroundColor('#4CAF50')
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddTransaction' });
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .margin({ top: 100 })
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 今日收支卡片
            this.TodayCard()

            // 本月概览卡片
            this.MonthCard()

            // 最近交易列表
            this.RecentTransactionsCard()
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  TodayCard() {
    Column({ space: 12 }) {
      Text('今日收支')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)

      Row() {
        // 支出
        Column({ space: 4 }) {
          Text('支出')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${MoneyUtil.formatInt(this.todayExpense)}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Divider()
          .vertical(true)
          .height(40)
          .color('#E0E0E0')

        // 收入
        Column({ space: 4 }) {
          Text('收入')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${MoneyUtil.formatInt(this.todayIncome)}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  MonthCard() {
    Column({ space: 12 }) {
      Row() {
        Text('本月概览')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666666')
        
        Blank()
        
        Text(DateTimeUtil.formatDateTime(Date.now(), 'yyyy年MM月'))
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')

      // 结余
      Row() {
        Text('本月结余')
          .fontSize(12)
          .fontColor('#999999')
        
        Text(`¥${MoneyUtil.formatInt(this.monthIncome - this.monthExpense)}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.monthIncome >= this.monthExpense ? '#4CAF50' : '#FF5722')
      }
      .width('100%')
      .margin({ top: 8, bottom: 8 })

      // 收支进度条
      Row({ space: 8 }) {
        Text('支出')
          .fontSize(11)
          .fontColor('#999999')
          .width(40)
        
        Stack() {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('#F0F0F0')
            .borderRadius(4)
          
          Row()
            .width(Math.min(this.monthExpense / Math.max(this.monthIncome + this.monthExpense, 1) * 100 + '%'))
            .height(8)
            .backgroundColor('#FF5722')
            .borderRadius(4)
            .alignSelf(ItemAlign.Start)
        }
        .width('60%')
        .height(8)
        
        Text(`¥${MoneyUtil.formatInt(this.monthExpense)}`)
          .fontSize(11)
          .fontColor('#666666')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')

      Row({ space: 8 }) {
        Text('收入')
          .fontSize(11)
          .fontColor('#999999')
          .width(40)
        
        Stack() {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('#F0F0F0')
            .borderRadius(4)
          
          Row()
            .width(Math.min(this.monthIncome / Math.max(this.monthIncome + this.monthExpense, 1) * 100 + '%'))
            .height(8)
            .backgroundColor('#4CAF50')
            .borderRadius(4)
            .alignSelf(ItemAlign.Start)
        }
        .width('60%')
        .height(8)
        
        Text(`¥${MoneyUtil.formatInt(this.monthIncome)}`)
          .fontSize(11)
          .fontColor('#666666')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  RecentTransactionsCard() {
    Column({ space: 12 }) {
      Row() {
        Text('最近交易')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666666')
        
        Blank()
        
        Text('查看全部 >')
          .fontSize(12)
          .fontColor('#4CAF50')
          .onClick(() => {
            router.pushUrl({ url: 'pages/TransactionList' });
          })
      }
      .width('100%')

      if (this.recentTransactions.length === 0) {
        Column({ space: 8 }) {
          Text('暂无交易记录')
            .fontSize(14)
            .fontColor('#999999')
          Text('点击右上角"记一笔"开始记账')
            .fontSize(12)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(40)
      } else {
        Column({ space: 0 }) {
          ForEach(this.recentTransactions, (transaction: Transaction, index: number) => {
            this.TransactionItem(transaction, index === this.recentTransactions.length - 1)
          }, (transaction: Transaction) => transaction.id?.toString())
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
  }

  @Builder
  TransactionItem(transaction: Transaction, isLast: boolean) {
    Row() {
      // 图标
      Column() {
        Text(this.getCategoryIcon(transaction.category))
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor('#F5F5F5')
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)

      // 信息
      Column({ space: 4 }) {
        Text(transaction.merchant || transaction.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row({ space: 8 }) {
          Text(transaction.category)
            .fontSize(11)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getCategoryColor(transaction.category))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
          
          Text(DateTimeUtil.formatTime(transaction.transactionTime))
            .fontSize(11)
            .fontColor('#999999')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      // 金额
      Text(MoneyUtil.formatWithSymbol(transaction.amount, transaction.type))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(transaction.type === TransactionType.EXPENSE ? '#1A1A1A' : '#4CAF50')
    }
    .width('100%')
    .height(72)
    .border({
      width: { bottom: isLast ? 0 : 1 },
      color: '#F0F0F0'
    })
  }

  private getCategoryIcon(category: string): string {
    const iconMap: Map<string, string> = new Map([
      ['餐饮', '🍽️'],
      ['交通', '🚗'],
      ['购物', '🛍️'],
      ['娱乐', '🎮'],
      ['居住', '🏠'],
      ['医疗', '🏥'],
      ['教育', '📚'],
      ['工资', '💰'],
      ['奖金', '🎁'],
      ['投资', '📈'],
      ['其他', '📋']
    ]);
    return iconMap.get(category) || '📋';
  }

  private getCategoryColor(category: string): string {
    const colorMap: Map<string, string> = new Map([
      ['餐饮', '#FF6B6B'],
      ['交通', '#4ECDC4'],
      ['购物', '#45B7D1'],
      ['娱乐', '#96CEB4'],
      ['居住', '#FFEAA7'],
      ['医疗', '#DDA0DD'],
      ['教育', '#98D8C8'],
      ['工资', '#4CAF50'],
      ['奖金', '#FFD93D'],
      ['投资', '#6C5CE7'],
      ['其他', '#A0A0A0']
    ]);
    return colorMap.get(category) || '#A0A0A0';
  }
}
