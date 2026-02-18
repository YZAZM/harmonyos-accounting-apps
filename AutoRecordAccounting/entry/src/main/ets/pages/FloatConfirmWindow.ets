import { PaymentInfo } from '../models/Transaction'
import { MoneyUtil, CategoryClassifier } from '../utils/CommonUtils'

@Entry
@Component
struct FloatConfirmWindow {
  @LocalStorageLink('paymentInfo') paymentInfo: PaymentInfo = new PaymentInfo()
  @LocalStorageLink('onConfirm') onConfirm: (confirmed: boolean, modifiedInfo?: any) => void = () => {}
  
  @State selectedCategory: string = ''
  @State remark: string = ''
  @State countdown: number = 5
  private timer: number = 0

  aboutToAppear() {
    this.selectedCategory = CategoryClassifier.classify(this.paymentInfo.merchant)
    
    // 启动倒计时
    this.timer = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        this.handleIgnore()
      }
    }, 1000)
  }

  aboutToDisappear() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  build() {
    Column({ space: 16 }) {
      // 标题
      Row() {
        Text('💰 检测到支付')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Text(`${this.countdown}s`)
          .fontSize(14)
          .fontColor('#FF6B6B')
      }
      .width('100%')

      // 金额显示
      Text(MoneyUtil.format(this.paymentInfo.amount))
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF6B6B')

      // 详情信息
      Column({ space: 8 }) {
        InfoRow({ label: '商户', value: this.paymentInfo.merchant })
        InfoRow({ label: '分类', value: this.selectedCategory })
        InfoRow({ label: '方式', value: this.paymentInfo.payMethod })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F9F9F9')
      .borderRadius(8)

      // 操作按钮
      Row({ space: 12 }) {
        Button('忽略', { type: ButtonType.Capsule })
          .width(80)
          .height(36)
          .fontSize(14)
          .fontColor('#666')
          .backgroundColor('#E0E0E0')
          .onClick(() => this.handleIgnore())

        Button('修改', { type: ButtonType.Capsule })
          .width(80)
          .height(36)
          .fontSize(14)
          .fontColor('#FF6B6B')
          .backgroundColor('#FFE0E0')
          .onClick(() => this.handleModify())

        Button('确认', { type: ButtonType.Capsule })
          .width(100)
          .height(36)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#FF6B6B')
          .onClick(() => this.handleConfirm())
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.2)' })
  }

  private handleConfirm() {
    if (this.timer) {
      clearInterval(this.timer)
    }
    this.onConfirm(true, {
      ...this.paymentInfo,
      category: this.selectedCategory,
      remark: this.remark
    })
  }

  private handleIgnore() {
    if (this.timer) {
      clearInterval(this.timer)
    }
    this.onConfirm(false)
  }

  private handleModify() {
    // 展开修改选项
    // 这里可以展开分类选择器等
  }
}

// 信息行组件
@Component
struct InfoRow {
  @Prop label: string
  @Prop value: string

  build() {
    Row() {
      Text(this.label)
        .fontSize(14)
        .fontColor('#666')
      
      Blank()
      
      Text(this.value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
    }
    .width('100%')
  }
}