import { router } from '@kit.ArkUI';
import { TransactionDao, Transaction, TransactionType, CategoryDao, Category } from '../data/Dao';
import { DateTimeUtil, MoneyUtil } from '../utils/Utils';

@Entry
@Component
struct TransactionList {
  @State transactions: Transaction[] = [];
  @State groupedTransactions: Map<string, Transaction[]> = new Map();
  @State isLoading: boolean = true;
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedYear: number = new Date().getFullYear();
  @State monthExpense: number = 0;
  @State monthIncome: number = 0;

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    
    // 加载当月交易
    const startDate = new Date(this.selectedYear, this.selectedMonth - 1, 1);
    const endDate = new Date(this.selectedYear, this.selectedMonth, 0, 23, 59, 59);
    
    this.transactions = await TransactionDao.queryByTimeRange(startDate.getTime(), endDate.getTime());
    
    // 计算月度收支
    const summary = await TransactionDao.getMonthSummary(this.selectedYear, this.selectedMonth);
    this.monthExpense = summary.expense;
    this.monthIncome = summary.income;
    
    // 按日期分组
    this.groupTransactions();
    
    this.isLoading = false;
  }

  // 按日期分组交易
  groupTransactions() {
    this.groupedTransactions.clear();
    
    for (const transaction of this.transactions) {
      const dateKey = DateTimeUtil.formatDate(transaction.transactionTime);
      const group = this.groupedTransactions.get(dateKey) || [];
      group.push(transaction);
      this.groupedTransactions.set(dateKey, group);
    }
  }

  // 删除交易
  async deleteTransaction(id: number) {
    await TransactionDao.delete(id);
    await this.loadData();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('＜')
          .fontSize(24)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })
        
        Text('账单明细')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        
        Blank()
        
        Text('+')
          .fontSize(28)
          .fontColor('#4CAF50')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddTransaction' });
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 月份选择器
      Row() {
        Text('＜')
          .fontSize(20)
          .fontColor('#666666')
          .onClick(() => {
            this.selectedMonth--;
            if (this.selectedMonth < 1) {
              this.selectedMonth = 12;
              this.selectedYear--;
            }
            this.loadData();
          })
        
        Text(`${this.selectedYear}年${this.selectedMonth}月`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 16, right: 16 })
        
        Text('＞')
          .fontSize(20)
          .fontColor('#666666')
          .onClick(() => {
            this.selectedMonth++;
            if (this.selectedMonth > 12) {
              this.selectedMonth = 1;
              this.selectedYear++;
            }
            this.loadData();
          })
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')

      // 月度汇总
      Row({ space: 24 }) {
        Column({ space: 4 }) {
          Text('收入')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${MoneyUtil.formatInt(this.monthIncome)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4CAF50')
        }
        
        Divider()
          .vertical(true)
          .height(32)
          .color('#E0E0E0')
        
        Column({ space: 4 }) {
          Text('支出')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${MoneyUtil.formatInt(this.monthExpense)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF5722')
        }
        
        Divider()
          .vertical(true)
          .height(32)
          .color('#E0E0E0')
        
        Column({ space: 4 }) {
          Text('结余')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${MoneyUtil.formatInt(this.monthIncome - this.monthExpense)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.monthIncome >= this.monthExpense ? '#4CAF50' : '#FF5722')
        }
      }
      .width('100%')
      .height(64)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 8 })

      // 交易列表
      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .margin({ top: 100 })
      } else if (this.transactions.length === 0) {
        Column({ space: 12 }) {
          Text('本月暂无交易')
            .fontSize(16)
            .fontColor('#999999')
          
          Button('记一笔')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(20)
            .padding({ left: 24, right: 24 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddTransaction' });
            })
        }
        .margin({ top: 100 })
      } else {
        List({ space: 8 }) {
          ForEach(Array.from(this.groupedTransactions.entries()), (group: [string, Transaction[]]) => {
            ListItem() {
              this.DayGroup(group[0], group[1])
            }
          }, (group: [string, Transaction[]]) => group[0])
        }
        .width('100%')
        .padding(16)
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  DayGroup(dateKey: string, transactions: Transaction[]) {
    Column({ space: 0 }) {
      // 日期标题
      Row() {
        Column({ space: 2 }) {
          Text(dateKey)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
          
          Text(DateTimeUtil.getWeekDay(new Date(dateKey).getTime()))
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        // 计算当日收支
        Row({ space: 12 }) {
          let dayExpense = 0;
          let dayIncome = 0;
          for (const t of transactions) {
            if (t.type === TransactionType.EXPENSE) {
              dayExpense += t.amount;
            } else {
              dayIncome += t.amount;
            }
          }
          
          if (dayIncome > 0) {
            Text(`+${MoneyUtil.formatInt(dayIncome)}`)
              .fontSize(12)
              .fontColor('#4CAF50')
          }
          
          if (dayExpense > 0) {
            Text(`-${MoneyUtil.formatInt(dayExpense)}`)
              .fontSize(12)
              .fontColor('#FF5722')
          }
        }
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FAFAFA')

      // 交易列表
      Column({ space: 0 }) {
        ForEach(transactions, (transaction: Transaction, index: number) => {
          this.TransactionItem(transaction, index === transactions.length - 1)
        }, (transaction: Transaction) => transaction.id?.toString())
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .clip(true)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 1
    })
  }

  @Builder
  TransactionItem(transaction: Transaction, isLast: boolean) {
    Row() {
      // 图标
      Column() {
        Text(this.getCategoryIcon(transaction.category))
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor('#F5F5F5')
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      // 信息
      Column({ space: 4 }) {
        Text(transaction.merchant || transaction.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(transaction.category)
          .fontSize(11)
          .fontColor('#999999')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 金额
      Column({ space: 2 }) {
        Text(MoneyUtil.formatWithSymbol(transaction.amount, transaction.type))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(transaction.type === TransactionType.EXPENSE ? '#1A1A1A' : '#4CAF50')
        
        Text(DateTimeUtil.formatTime(transaction.transactionTime))
          .fontSize(10)
          .fontColor('#CCCCCC')
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 16 })
    .border({
      width: { bottom: isLast ? 0 : 1 },
      color: '#F0F0F0'
    })
    .swipeAction({
      end: this.DeleteButton(transaction.id || 0)
    })
  }

  @Builder
  DeleteButton(id: number) {
    Row() {
      Text('删除')
        .fontSize(14)
        .fontColor('#FFFFFF')
    }
    .width(60)
    .height('100%')
    .backgroundColor('#FF5722')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.deleteTransaction(id);
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
}
