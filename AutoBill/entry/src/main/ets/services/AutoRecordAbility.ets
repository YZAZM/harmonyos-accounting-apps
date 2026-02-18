import { AccessibilityExtensionAbility, AccessibilityEvent, AccessibilityElementInfo } from '@kit.AccessibilityKit';
import { promptAction } from '@kit.ArkUI';
import { TransactionDao, Transaction, TransactionType } from '../data/Dao';
import { PaymentParser, SmartCategorizer, AppRecognitionConfig } from '../utils/SmartCategorizer';
import { window } from '@kit.ArkUI';

// 自动记账无障碍服务
export default class AutoRecordAbility extends AccessibilityExtensionAbility {
  private isEnabled: boolean = true;
  private lastTriggerTime: number = 0;
  private readonly DEBOUNCE_TIME: number = 3000; // 防抖时间3秒
  private windowStage: window.WindowStage | null = null;

  onConnect(): void {
    console.info('AutoRecordAbility onConnect');
    // 初始化悬浮窗
    this.initFloatingWindow();
  }

  onDisconnect(): void {
    console.info('AutoRecordAbility onDisconnect');
  }

  onAccessibilityEvent(accessibilityEvent: AccessibilityEvent): void {
    if (!this.isEnabled) {
      return;
    }

    const eventType = accessibilityEvent.eventType;
    
    // 监听页面变化事件
    if (eventType === 'pageStateUpdate' || eventType === 'windowUpdate') {
      const elementInfo = accessibilityEvent.elementInfo;
      if (elementInfo) {
        this.processPageChange(elementInfo);
      }
    }
  }

  // 处理页面变化
  private processPageChange(elementInfo: AccessibilityElementInfo): void {
    const currentTime = Date.now();
    
    // 防抖处理
    if (currentTime - this.lastTriggerTime < this.DEBOUNCE_TIME) {
      return;
    }

    // 获取包名和页面信息
    const bundleName = elementInfo.bundleName;
    const pageText = this.extractPageText(elementInfo);

    console.info(`检测到页面变化: ${bundleName}`);
    console.info(`页面文本: ${pageText.substring(0, 200)}`);

    // 检查是否是支付页面
    if (this.isPaymentPage(bundleName, pageText)) {
      this.lastTriggerTime = currentTime;
      const paymentInfo = this.extractPaymentInfo(elementInfo, pageText);
      
      if (paymentInfo.amount > 0) {
        this.showConfirmWindow(paymentInfo);
      }
    }
  }

  // 检查是否是支付页面
  private isPaymentPage(bundleName: string, pageText: string): boolean {
    // 检查是否是目标App
    const isTargetApp = Object.keys(AppRecognitionConfig).some(pkg => 
      bundleName.includes(pkg)
    );

    if (!isTargetApp) {
      return false;
    }

    // 检查是否包含支付成功特征
    return PaymentParser.isPaymentSuccess(pageText);
  }

  // 提取页面文本
  private extractPageText(elementInfo: AccessibilityElementInfo): string {
    let text = '';
    
    // 提取当前元素文本
    if (elementInfo.text) {
      text += elementInfo.text + ' ';
    }
    if (elementInfo.content) {
      text += elementInfo.content + ' ';
    }

    // 递归提取子元素文本
    if (elementInfo.children && elementInfo.children.length > 0) {
      for (const child of elementInfo.children) {
        text += this.extractPageText(child);
      }
    }

    return text;
  }

  // 提取支付信息
  private extractPaymentInfo(elementInfo: AccessibilityElementInfo, pageText: string): PaymentInfo {
    const amount = PaymentParser.parseAmount(pageText) || 0;
    const merchant = PaymentParser.parseMerchant(pageText) || '';
    const time = PaymentParser.parseTime(pageText) || Date.now();
    const category = SmartCategorizer.categorize(merchant);

    // 尝试从控件层级提取更精确的信息
    const extractedInfo = this.extractFromElementTree(elementInfo);

    return {
      amount: extractedInfo.amount || amount,
      merchant: extractedInfo.merchant || merchant,
      category: extractedInfo.category || category,
      time: time,
      sourceApp: elementInfo.bundleName
    };
  }

  // 从控件树提取信息
  private extractFromElementTree(elementInfo: AccessibilityElementInfo): Partial<PaymentInfo> {
    const result: Partial<PaymentInfo> = {};

    // 递归查找包含金额和商户信息的控件
    const findInfo = (element: AccessibilityElementInfo) => {
      const text = element.text || element.content || '';
      
      // 查找金额
      if (!result.amount) {
        const amount = PaymentParser.parseAmount(text);
        if (amount && amount > 0) {
          result.amount = amount;
        }
      }

      // 查找商户
      if (!result.merchant) {
        const merchant = PaymentParser.parseMerchant(text);
        if (merchant) {
          result.merchant = merchant;
        }
      }

      // 递归查找子元素
      if (element.children) {
        for (const child of element.children) {
          findInfo(child);
        }
      }
    };

    findInfo(elementInfo);
    return result;
  }

  // 初始化悬浮窗
  private async initFloatingWindow(): Promise<void> {
    try {
      // 创建悬浮窗窗口
      // 注意：实际实现需要根据鸿蒙API调整
      console.info('初始化悬浮窗');
    } catch (err) {
      console.error('初始化悬浮窗失败:', JSON.stringify(err));
    }
  }

  // 显示确认窗口
  private showConfirmWindow(paymentInfo: PaymentInfo): void {
    console.info('显示确认窗口:', JSON.stringify(paymentInfo));
    
    // 实际实现需要创建悬浮窗显示确认界面
    // 这里简化处理，实际应该创建Window并显示UI
    promptAction.showToast({
      message: `检测到支付: ¥${paymentInfo.amount} - ${paymentInfo.merchant || paymentInfo.category}`,
      duration: 3000
    });

    // 自动保存（可以改为弹出确认对话框）
    this.autoSaveTransaction(paymentInfo);
  }

  // 自动保存交易
  private async autoSaveTransaction(paymentInfo: PaymentInfo): Promise<void> {
    const transaction: Transaction = {
      amount: paymentInfo.amount,
      type: TransactionType.EXPENSE,
      category: paymentInfo.category,
      merchant: paymentInfo.merchant,
      transactionTime: paymentInfo.time,
      sourceApp: paymentInfo.sourceApp
    };

    try {
      const id = await TransactionDao.add(transaction);
      console.info(`自动记账成功，ID: ${id}`);
      
      promptAction.showToast({
        message: `已自动记录: ¥${paymentInfo.amount}`,
        duration: 2000
      });
    } catch (err) {
      console.error('自动记账失败:', JSON.stringify(err));
    }
  }

  onKeyEvent(): void {
    // 处理按键事件（可选）
  }
}

// 支付信息接口
interface PaymentInfo {
  amount: number;
  merchant: string;
  category: string;
  time: number;
  sourceApp: string;
}
