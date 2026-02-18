import { router } from '@kit.ArkUI';
import { TransactionDao, Transaction, TransactionType, CategoryDao, Category } from '../data/Dao';
import { SmartCategorizer } from '../utils/SmartCategorizer';
import { DateTimeUtil } from '../utils/Utils';

@Entry
@Component
struct AddTransaction {
  @State amount: string = '';
  @State type: TransactionType = TransactionType.EXPENSE;
  @State category: string = '餐饮';
  @State merchant: string = '';
  @State remark: string = '';
  @State selectedDate: Date = new Date();
  @State showDatePicker: boolean = false;
  @State expenseCategories: Category[] = [];
  @State incomeCategories: Category[] = [];
  @State isLoading: boolean = true;

  private amountButtons: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'];

  async aboutToAppear() {
    this.expenseCategories = await CategoryDao.queryAll(TransactionType.EXPENSE);
    this.incomeCategories = await CategoryDao.queryAll(TransactionType.INCOME);
    if (this.expenseCategories.length > 0) {
      this.category = this.expenseCategories[0].name;
    }
    this.isLoading = false;
  }

  // 智能识别商户分类
  onMerchantChange(value: string) {
    this.merchant = value;
    if (value.length > 1) {
      const detectedCategory = SmartCategorizer.categorize(value);
      if (detectedCategory !== '其他') {
        this.category = detectedCategory;
      }
    }
  }

  // 保存交易
  async saveTransaction() {
    if (!this.amount || parseFloat(this.amount) <= 0) {
      // 提示请输入金额
      return;
    }

    const transaction: Transaction = {
      amount: parseFloat(this.amount),
      type: this.type,
      category: this.category,
      merchant: this.merchant,
      transactionTime: this.selectedDate.getTime(),
      remark: this.remark,
      sourceApp: 'manual'
    };

    const id = await TransactionDao.add(transaction);
    if (id > 0) {
      router.back();
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('×')
          .fontSize(28)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })
        
        Text(this.type === TransactionType.EXPENSE ? '记支出' : '记收入')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        
        Text('保存')
          .fontSize(16)
          .fontColor('#4CAF50')
          .onClick(() => {
            this.saveTransaction();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 收支类型切换
      Row({ space: 0 }) {
        Column() {
          Text('支出')
            .fontSize(15)
            .fontWeight(this.type === TransactionType.EXPENSE ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.type === TransactionType.EXPENSE ? '#FF5722' : '#999999')
            .height(40)
            .onClick(() => {
              this.type = TransactionType.EXPENSE;
              if (this.expenseCategories.length > 0) {
                this.category = this.expenseCategories[0].name;
              }
            })
          
          if (this.type === TransactionType.EXPENSE) {
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
            .fontWeight(this.type === TransactionType.INCOME ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.type === TransactionType.INCOME ? '#4CAF50' : '#999999')
            .height(40)
            .onClick(() => {
              this.type = TransactionType.INCOME;
              if (this.incomeCategories.length > 0) {
                this.category = this.incomeCategories[0].name;
              }
            })
          
          if (this.type === TransactionType.INCOME) {
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
      .margin({ top: 8, bottom: 16 })

      // 金额显示
      Row() {
        Text('¥')
          .fontSize(32)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ right: 8 })
        
        Text(this.amount || '0.00')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(80)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 24 })

      // 分类选择
      Column({ space: 12 }) {
        Text('选择分类')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)
        
        if (!this.isLoading) {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.type === TransactionType.EXPENSE ? this.expenseCategories : this.incomeCategories, (item: Category) => {
              Column({ space: 4 }) {
                Text(item.icon)
                  .fontSize(24)
                
                Text(item.name)
                  .fontSize(12)
                  .fontColor(this.category === item.name ? '#FFFFFF' : '#666666')
              }
              .width(64)
              .height(64)
              .backgroundColor(this.category === item.name ? (this.type === TransactionType.EXPENSE ? '#FF5722' : '#4CAF50') : '#F5F5F5')
              .borderRadius(12)
              .margin(6)
              .onClick(() => {
                this.category = item.name;
              })
            }, (item: Category) => item.id?.toString())
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 16 })

      // 详细信息输入
      Column({ space: 16 }) {
        // 商户
        Row({ space: 12 }) {
          Text('商户')
            .fontSize(14)
            .fontColor('#666666')
            .width(60)
          
          TextInput({ placeholder: '选填，如：星巴克', text: $$this.merchant })
            .fontSize(14)
            .placeholderColor('#CCCCCC')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .onChange((value) => {
              this.onMerchantChange(value);
            })
        }
        .width('100%')

        // 时间
        Row({ space: 12 }) {
          Text('时间')
            .fontSize(14)
            .fontColor('#666666')
            .width(60)
          
          Row() {
            Text(DateTimeUtil.formatDateTime(this.selectedDate.getTime()))
              .fontSize(14)
              .fontColor('#1A1A1A')
            
            Blank()
            
            Text('📅')
              .fontSize(16)
          }
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.showDatePicker = true;
          })
        }
        .width('100%')

        // 备注
        Row({ space: 12 }) {
          Text('备注')
            .fontSize(14)
            .fontColor('#666666')
            .width(60)
          
          TextInput({ placeholder: '添加备注...', text: $$this.remark })
            .fontSize(14)
            .placeholderColor('#CCCCCC')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })

      Blank()

      // 数字键盘
      Grid() {
        ForEach(this.amountButtons, (btn: string, index: number) => {
          GridItem() {
            Column() {
              Text(btn)
                .fontSize(btn === '⌫' ? 20 : 24)
                .fontColor('#1A1A1A')
            }
            .width('100%')
            .height(64)
            .backgroundColor('#FFFFFF')
            .border({ width: 0.5, color: '#E0E0E0' })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.onNumberClick(btn);
            })
          }
        }, (btn: string) => btn)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .width('100%')
      .height(256)
      .backgroundColor('#F5F5F5')

      // 日期选择器弹窗
      if (this.showDatePicker) {
        Column() {
          DatePicker({
            selected: this.selectedDate
          })
            .onDateChange((value: Date) => {
              this.selectedDate = value;
            })
          
          Row({ space: 16 }) {
            Button('取消')
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .onClick(() => {
                this.showDatePicker = false;
              })
            
            Button('确定')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#4CAF50')
              .onClick(() => {
                this.showDatePicker = false;
              })
          }
          .margin({ top: 16 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 20, topRight: 20 })
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private onNumberClick(btn: string) {
    if (btn === '⌫') {
      if (this.amount.length > 0) {
        this.amount = this.amount.slice(0, -1);
      }
    } else if (btn === '.') {
      if (!this.amount.includes('.')) {
        this.amount += btn;
      }
    } else {
      if (this.amount.length < 10) {
        if (this.amount === '0' && btn !== '.') {
          this.amount = btn;
        } else {
          this.amount += btn;
        }
      }
    }
  }
}
