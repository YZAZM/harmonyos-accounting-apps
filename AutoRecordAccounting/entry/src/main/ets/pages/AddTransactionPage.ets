import { DatabaseManager } from '../database/DatabaseManager'
import { Transaction, TransactionType, Category } from '../models/Transaction'
import { DateUtil, MoneyUtil, CategoryClassifier } from '../utils/CommonUtils'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct AddTransactionPage {
  @State amount: string = ''
  @State type: TransactionType = TransactionType.EXPENSE
  @State selectedCategory: string = ''
  @State merchant: string = ''
  @State remark: string = ''
  @State categories: Category[] = []
  @State isLoading: boolean = false

  aboutToAppear() {
    this.loadCategories()
  }

  async loadCategories() {
    try {
      this.categories = await DatabaseManager.getInstance().queryCategories(this.type)
      if (this.categories.length > 0) {
        this.selectedCategory = this.categories[0].name
      }
    } catch (err) {
      console.error('加载分类失败:', err)
    }
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

        Text('记一笔')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(44)
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column({ space: 24 }) {
          // 收支类型切换
          TypeSelector({
            type: this.type,
            onTypeChange: (newType) => {
              this.type = newType
              this.loadCategories()
            }
          })

          // 金额输入
          AmountInput({ amount: this.amount })

          // 分类选择
          CategorySelector({
            categories: this.categories,
            selectedCategory: this.selectedCategory,
            onSelect: (category) => {
              this.selectedCategory = category
            }
          })

          // 商户输入
          FormInput({
            label: '商户',
            placeholder: '请输入商户名称',
            value: this.merchant,
            onChange: (val) => this.merchant = val
          })

          // 备注输入
          FormInput({
            label: '备注',
            placeholder: '添加备注（选填）',
            value: this.remark,
            onChange: (val) => this.remark = val
          })

          // 保存按钮
          Button('保存', { type: ButtonType.Capsule })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor(this.type === TransactionType.EXPENSE ? '#FF6B6B' : '#4CAF50')
            .enabled(!this.isLoading && this.amount !== '' && this.selectedCategory !== '')
            .onClick(() => this.saveTransaction())
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private async saveTransaction() {
    if (!this.amount || parseFloat(this.amount) <= 0) {
      return
    }

    this.isLoading = true

    try {
      const transaction = new Transaction({
        amount: parseFloat(this.amount),
        type: this.type,
        category: this.selectedCategory,
        merchant: this.merchant || this.selectedCategory,
        remark: this.remark,
        transactionTime: Date.now()
      })

      await DatabaseManager.getInstance().insertTransaction(transaction)
      
      // 返回上一页
      router.back()

    } catch (err) {
      console.error('保存失败:', err)
    } finally {
      this.isLoading = false
    }
  }
}

// 收支类型选择器
@Component
struct TypeSelector {
  @Prop type: TransactionType
  onTypeChange: (type: TransactionType) => void = () => {}

  build() {
    Row({ space: 0 }) {
      Column() {
        Text('支出')
          .fontSize(16)
          .fontWeight(this.type === TransactionType.EXPENSE ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.type === TransactionType.EXPENSE ? '#FF6B6B' : '#666')
      }
      .layoutWeight(1)
      .height(44)
      .backgroundColor(this.type === TransactionType.EXPENSE ? '#FFE0E0' : Color.White)
      .borderRadius({ topLeft: 8, bottomLeft: 8 })
      .onClick(() => {
        this.onTypeChange(TransactionType.EXPENSE)
      })

      Column() {
        Text('收入')
          .fontSize(16)
          .fontWeight(this.type === TransactionType.INCOME ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.type === TransactionType.INCOME ? '#4CAF50' : '#666')
      }
      .layoutWeight(1)
      .height(44)
      .backgroundColor(this.type === TransactionType.INCOME ? '#E0F2E0' : Color.White)
      .borderRadius({ topRight: 8, bottomRight: 8 })
      .onClick(() => {
        this.onTypeChange(TransactionType.INCOME)
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
  }
}

// 金额输入
@Component
struct AmountInput {
  @Prop amount: string

  build() {
    Column({ space: 8 }) {
      Text('金额')
        .fontSize(14)
        .fontColor('#666')
        .alignSelf(ItemAlign.Start)

      Row() {
        Text('¥')
          .fontSize(24)
          .fontColor('#333')
          .margin({ right: 8 })

        TextInput({ placeholder: '0.00', text: this.amount })
          .type(InputType.Number)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .backgroundColor(Color.Transparent)
          .onChange((val) => {
            this.amount = val
          })
      }
      .width('100%')
      .height(80)
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
    }
    .width('100%')
  }
}

// 分类选择器
@Component
struct CategorySelector {
  @Prop categories: Category[]
  @Prop selectedCategory: string
  onSelect: (category: string) => void = () => {}

  build() {
    Column({ space: 8 }) {
      Text('分类')
        .fontSize(14)
        .fontColor('#666')
        .alignSelf(ItemAlign.Start)

      Wrap({ spacing: 8, runSpacing: 8 }) {
        ForEach(this.categories, (category: Category) => {
          Column() {
            Text(category.icon)
              .fontSize(24)
            Text(category.name)
              .fontSize(12)
              .fontColor(this.selectedCategory === category.name ? Color.White : '#666')
          }
          .width(72)
          .height(72)
          .backgroundColor(this.selectedCategory === category.name ? '#FF6B6B' : Color.White)
          .borderRadius(8)
          .onClick(() => {
            this.onSelect(category.name)
          })
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)' })
    }
    .width('100%')
  }
}

// 表单项
@Component
struct FormInput {
  @Prop label: string
  @Prop placeholder: string
  @Prop value: string
  onChange: (val: string) => void = () => {}

  build() {
    Column({ space: 8 }) {
      Text(this.label)
        .fontSize(14)
        .fontColor('#666')
        .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: this.placeholder, text: this.value })
        .height(48)
        .fontSize(16)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .onChange((val) => {
          this.onChange(val)
        })
    }
    .width('100%')
  }
}