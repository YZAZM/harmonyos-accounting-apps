import { window } from '@kit.ArkUI';
import { TransactionDao, Transaction, TransactionType } from '../data/Dao';
import { SmartCategorizer } from '../utils/SmartCategorizer';
import { MoneyUtil, DateTimeUtil } from '../utils/Utils';

// 悬浮确认窗管理器
export class FloatingWindowManager {
  private static instance: FloatingWindowManager;
  private floatingWindow: window.Window | null = null;
  private isShowing: boolean = false;
  private currentPaymentInfo: PaymentInfo | null = null;

  static getInstance(): FloatingWindowManager {
    if (!FloatingWindowManager.instance) {
      FloatingWindowManager.instance = new FloatingWindowManager();
    }
    return FloatingWindowManager.instance;
  }

  // 创建悬浮窗
  async createFloatingWindow(): Promise<void> {
    if (this.floatingWindow) {
      return;
    }

    try {
      // 创建悬浮窗窗口
      this.floatingWindow = await window.createWindow({
        name: 'AutoRecordConfirmWindow',
        windowType: window.WindowType.TYPE_FLOAT,
        ctx: getContext()
      });

      // 设置窗口属性
      await this.floatingWindow.setWindowLayoutFullScreen(false);
      await this.floatingWindow.setWindowBackgroundColor('#00000000');
      
      // 设置窗口大小和位置
      const displayInfo = await window.getLastWindow(getContext()).getWindowProperties();
      const windowWidth = 320;
      const windowHeight = 280;
      const posX = (displayInfo.windowRect.width - windowWidth) / 2;
      const posY = 120;

      await this.floatingWindow.moveWindowTo(posX, posY);
      await this.floatingWindow.resize(windowWidth, windowHeight);
      
      console.info('悬浮窗创建成功');
    } catch (err) {
      console.error('创建悬浮窗失败:', JSON.stringify(err));
    }
  }

  // 显示确认窗口
  async showConfirmWindow(paymentInfo: PaymentInfo): Promise<void> {
    if (this.isShowing) {
      return;
    }

    this.currentPaymentInfo = paymentInfo;
    this.isShowing = true;

    try {
      await this.createFloatingWindow();
      
      if (!this.floatingWindow) {
        return;
      }

      // 加载UI内容
      // 实际实现需要绑定UI组件
      await this.floatingWindow.showWindow();
      
      // 3秒后自动隐藏
      setTimeout(() => {
        this.hideWindow();
      }, 3000);

    } catch (err) {
      console.error('显示悬浮窗失败:', JSON.stringify(err));
      this.isShowing = false;
    }
  }

  // 隐藏窗口
  async hideWindow(): Promise<void> {
    if (!this.floatingWindow || !this.isShowing) {
      return;
    }

    try {
      await this.floatingWindow.hideWindow();
      this.isShowing = false;
      this.currentPaymentInfo = null;
    } catch (err) {
      console.error('隐藏悬浮窗失败:', JSON.stringify(err));
    }
  }

  // 确认记账
  async confirmRecord(modifiedInfo?: Partial<PaymentInfo>): Promise<void> {
    if (!this.currentPaymentInfo) {
      return;
    }

    const info = { ...this.currentPaymentInfo, ...modifiedInfo };
    
    const transaction: Transaction = {
      amount: info.amount,
      type: TransactionType.EXPENSE,
      category: info.category,
      merchant: info.merchant,
      transactionTime: info.time,
      remark: info.remark,
      sourceApp: info.sourceApp
    };

    try {
      const id = await TransactionDao.add(transaction);
      console.info(`确认记账成功，ID: ${id}`);
      this.hideWindow();
    } catch (err) {
      console.error('确认记账失败:', JSON.stringify(err));
    }
  }

  // 取消记账
  cancelRecord(): void {
    console.info('用户取消记账');
    this.hideWindow();
  }

  // 销毁悬浮窗
  async destroy(): Promise<void> {
    await this.hideWindow();
    if (this.floatingWindow) {
      await this.floatingWindow.destroyWindow();
      this.floatingWindow = null;
    }
  }
}

// 支付信息接口
interface PaymentInfo {
  amount: number;
  merchant: string;
  category: string;
  time: number;
  sourceApp: string;
  remark?: string;
}

// 悬浮确认窗UI组件
@Component
export struct ConfirmFloatingWindow {
  @Prop amount: number = 0;
  @Prop merchant: string = '';
  @Prop category: string = '其他';
  @Prop sourceApp: string = '';
  @State selectedCategory: string = '';
  @State remark: string = '';
  @State showCategoryPicker: boolean = false;

  private categories: string[] = ['餐饮', '交通', '购物', '娱乐', '居住', '医疗', '教育', '其他'];

  aboutToAppear() {
    this.selectedCategory = this.category;
  }

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row({ space: 8 }) {
        Text('💰')
          .fontSize(20)
        
        Text('检测到一笔支出')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        
        Blank()
        
        Text('×')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => {
            FloatingWindowManager.getInstance().cancelRecord();
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F5F5F5')

      // 金额
      Column({ space: 4 }) {
        Text(`¥${MoneyUtil.format(this.amount)}`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF5722')
        
        if (this.merchant) {
          Text(this.merchant)
            .fontSize(14)
            .fontColor('#666666')
        }
      }
      .width('100%')
      .padding(16)

      // 分类选择
      Row({ space: 8 }) {
        Text('分类：')
          .fontSize(14)
          .fontColor('#666666')
        
        Row({ space: 4 }) {
          Text(this.getCategoryIcon(this.selectedCategory))
            .fontSize(16)
          
          Text(this.selectedCategory)
            .fontSize(14)
            .fontColor('#1A1A1A')
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#F0F0F0')
        .borderRadius(16)
        .onClick(() => {
          this.showCategoryPicker = true;
        })
        
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 备注输入
      Row({ space: 8 }) {
        Text('备注：')
          .fontSize(14)
          .fontColor('#666666')
        
        TextInput({ placeholder: '添加备注（选填）', text: $$this.remark })
          .fontSize(14)
          .placeholderColor('#CCCCCC')
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .height(36)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })

      // 按钮组
      Row({ space: 12 }) {
        Button('忽略')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .layoutWeight(1)
          .onClick(() => {
            FloatingWindowManager.getInstance().cancelRecord();
          })
        
        Button('✓ 确认记账')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .layoutWeight(2)
          .onClick(() => {
            FloatingWindowManager.getInstance().confirmRecord({
              category: this.selectedCategory,
              remark: this.remark
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width(320)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 16,
      color: 'rgba(0,0,0,0.2)',
      offsetX: 0,
      offsetY: 4
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
      ['其他', '📋']
    ]);
    return iconMap.get(category) || '📋';
  }
}

export default FloatingWindowManager.getInstance();
