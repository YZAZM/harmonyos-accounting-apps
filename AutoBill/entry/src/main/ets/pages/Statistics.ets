import { router } from '@kit.ArkUI';
import { TransactionDao, TransactionType } from '../data/Dao';
import { DateTimeUtil, MoneyUtil } from '../utils/Utils';

@Entry
@Component
struct Statistics {
  @State selectedTab: number = 0; // 0-支出 1-收入
  @State selectedPeriod: number = 0; // 0-本周 1-本月 2-本年
  @State categoryData: Map<string, number> = new Map();
  @State totalAmount: number = 0;
  @State isLoading: boolean = true;
  @State trendData: number[] = [];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    
    let startTime: number;
    let endTime: number;
    
    const now = new Date();
    
    switch (this.selectedPeriod) {
      case 0: // 本周
        const dayOfWeek = now.getDay() || 7;
        startTime = now.getTime() - (dayOfWeek - 1) * 24 * 60 * 60 * 1000;
        startTime = new Date(startTime).setHours(0, 0, 0, 0);
        endTime = Date.now();
        break;
      case 1: // 本月
        startTime = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
        endTime = Date.now();
        break;
      case 2: // 本年
        startTime = new Date(now.getFullYear(), 0, 1).getTime();
        endTime = Date.now();
        break;
      default:
        startTime = DateTimeUtil.getMonthStart();
        endTime = DateTimeUtil.getMonthEnd();
    }

    // 获取分类统计数据
    this.categoryData = await TransactionDao.getCategorySummary(startTime, endTime);
    
    // 计算总额
    this.totalAmount = 0;
    for (const amount of this.categoryData.values()) {
      this.totalAmount += amount;
    }

    // 生成趋势数据（最近7天）
    await this.loadTrendData();
    
    this.isLoading = false;
  }

  async loadTrendData() {
    this.trendData = [];
    const now = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      
      const startTime = date.getTime();
      const endTime = startTime + 24 * 60 * 60 * 1000;
      
      const summary = await TransactionDao.getCategorySummary(startTime, endTime);
      let dayTotal = 0;
      for (const amount of summary.values()) {
        dayTotal += amount;
      }
      this.trendData.push(dayTotal);
    }
  }

  // 获取排序后的分类数据
  getSortedCategories(): Array<[string, number]> {
    return Array.from(this.categoryData.entries())
      .sort((a, b) => b[1] - a[1]);
  }

  // 获取分类颜色
  getCategoryColor(index: number): string {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD', '#98D8C8', '#F7DC6F'];
    return colors[index % colors.length];
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
        
        Text('收支统计')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 收支切换
      Row({ space: 0 }) {
        Column() {
          Text('支出')
            .fontSize(15)
            .fontWeight(this.selectedTab === 0 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === 0 ? '#FF5722' : '#999999')
            .height(40)
            .onClick(() => {
              this.selectedTab = 0;
              this.loadData();
            })
          
          if (this.selectedTab === 0) {
            Row()
              .width(24)
              .height(3)
              .backgroundColor('#FF5722')
              .borderRadius(2)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('收入')
            .fontSize(15)
            .fontWeight(this.selectedTab === 1 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === 1 ? '#4CAF50' : '#999999')
            .height(40)
            .onClick(() => {
              this.selectedTab = 1;
              this.loadData();
            })
          
          if (this.selectedTab === 1) {
            Row()
              .width(24)
              .height(3)
              .backgroundColor('#4CAF50')
              .borderRadius(2)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 时间周期选择
      Row({ space: 24 }) {
        ForEach(['本周', '本月', '本年'], (period: string, index: number) => {
          Text(period)
            .fontSize(14)
            .fontWeight(this.selectedPeriod === index ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedPeriod === index ? '#1A1A1A' : '#999999')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.selectedPeriod === index ? '#F0F0F0' : '#FFFFFF')
            .borderRadius(16)
            .onClick(() => {
              this.selectedPeriod = index;
              this.loadData();
            })
        }, (period: string) => period)
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .margin({ top: 100 })
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 总支出/收入卡片
            this.SummaryCard()

            // 饼图区域
            this.PieChartCard()

            // 趋势图区域
            this.TrendChartCard()

            // 分类明细
            this.CategoryListCard()
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
  SummaryCard() {
    Column({ space: 8 }) {
      Text(this.selectedTab === 0 ? '总支出' : '总收入')
        .fontSize(14)
        .fontColor('#999999')
      
      Text(`¥${MoneyUtil.formatInt(this.totalAmount)}`)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedTab === 0 ? '#FF5722' : '#4CAF50')
      
      Text(`${this.categoryData.size}个分类`)
        .fontSize(12)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  PieChartCard() {
    Column({ space: 12 }) {
      Text('分类占比')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .alignSelf(ItemAlign.Start)
      
      if (this.categoryData.size === 0) {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 40, bottom: 40 })
      } else {
        // 简易饼图展示
        Row({ space: 0 }) {
          ForEach(this.getSortedCategories().slice(0, 5), (item: [string, number], index: number) => {
            Row()
              .width((item[1] / this.totalAmount * 100) + '%')
              .height(20)
              .backgroundColor(this.getCategoryColor(index))
          }, (item: [string, number]) => item[0])
        }
        .width('100%')
        .height(20)
        .borderRadius(10)
        .clip(true)
        .margin({ top: 8, bottom: 8 })

        // 图例
        Column({ space: 8 }) {
          ForEach(this.getSortedCategories().slice(0, 5), (item: [string, number], index: number) => {
            Row({ space: 8 }) {
              Row()
                .width(12)
                .height(12)
                .backgroundColor(this.getCategoryColor(index))
                .borderRadius(2)
              
              Text(item[0])
                .fontSize(13)
                .fontColor('#666666')
                .layoutWeight(1)
              
              Text(`${(item[1] / this.totalAmount * 100).toFixed(1)}%`)
                .fontSize(13)
                .fontColor('#999999')
              
              Text(`¥${MoneyUtil.formatInt(item[1])}`)
                .fontSize(13)
                .fontColor('#1A1A1A')
            }
            .width('100%')
            .height(28)
          }, (item: [string, number]) => item[0])
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  TrendChartCard() {
    Column({ space: 12 }) {
      Text('7日趋势')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .alignSelf(ItemAlign.Start)
      
      if (this.trendData.length === 0 || this.trendData.every(v => v === 0)) {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 40, bottom: 40 })
      } else {
        // 简易柱状图
        Row({ space: 8 }) {
          ForEach(this.trendData, (value: number, index: number) => {
            Column() {
              Row()
                .width(24)
                .height(value > 0 ? Math.max(value / Math.max(...this.trendData) * 100, 4) : 4)
                .backgroundColor(this.selectedTab === 0 ? '#FF5722' : '#4CAF50')
                .borderRadius({ topLeft: 4, topRight: 4 })
              
              Text(['一', '二', '三', '四', '五', '六', '日'][index])
                .fontSize(10)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.End)
            .height(120)
          }, (value: number, index: number) => index.toString())
        }
        .width('100%')
        .height(140)
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  CategoryListCard() {
    Column({ space: 12 }) {
      Text('分类明细')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .alignSelf(ItemAlign.Start)
      
      if (this.categoryData.size === 0) {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 40, bottom: 40 })
      } else {
        Column({ space: 0 }) {
          ForEach(this.getSortedCategories(), (item: [string, number], index: number) => {
            Row({ space: 12 }) {
              Text(this.getCategoryIcon(item[0]))
                .fontSize(20)
              
              Column({ space: 2 }) {
                Text(item[0])
                  .fontSize(14)
                  .fontColor('#1A1A1A')
                
                Row() {
                  Row()
                    .width(Math.min(item[1] / this.totalAmount * 200, 200))
                    .height(4)
                    .backgroundColor(this.getCategoryColor(index))
                    .borderRadius(2)
                }
                .width(200)
                .height(4)
                .backgroundColor('#F0F0F0')
                .borderRadius(2)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              
              Column({ space: 2 }) {
                Text(`¥${MoneyUtil.formatInt(item[1])}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')
                
                Text(`${(item[1] / this.totalAmount * 100).toFixed(1)}%`)
                  .fontSize(11)
                  .fontColor('#999999')
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .height(56)
            .border({
              width: { bottom: index === this.categoryData.size - 1 ? 0 : 1 },
              color: '#F0F0F0'
            })
          }, (item: [string, number]) => item[0])
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
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
