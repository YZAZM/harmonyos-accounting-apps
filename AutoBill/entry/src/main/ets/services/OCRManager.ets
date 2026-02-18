import { textRecognition } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

// OCR识别管理器
export class OCRManager {
  private static instance: OCRManager;
  private isInitialized: boolean = false;

  static getInstance(): OCRManager {
    if (!OCRManager.instance) {
      OCRManager.instance = new OCRManager();
    }
    return OCRManager.instance;
  }

  // 初始化OCR服务
  async init(): Promise<void> {
    if (this.isInitialized) {
      return;
    }
    
    try {
      // 预加载OCR模型
      console.info('OCR服务初始化成功');
      this.isInitialized = true;
    } catch (err) {
      console.error('OCR服务初始化失败:', JSON.stringify(err));
      throw err;
    }
  }

  // 从图片URI识别文字
  async recognizeFromUri(imageUri: string): Promise<OCRResult> {
    try {
      // 打开图片文件
      const file = await fileIo.open(imageUri, fileIo.OpenMode.READ_ONLY);
      
      // 创建图片源
      const imageSource = image.createImageSource(file.fd);
      
      // 创建PixelMap
      const pixelMap = await imageSource.createPixelMap({
        editable: false
      });

      // 关闭文件
      fileIo.close(file);

      // 执行OCR识别
      const result = await this.recognizeFromPixelMap(pixelMap);
      
      // 释放PixelMap
      pixelMap.release();
      
      return result;
    } catch (err) {
      console.error('OCR识别失败:', JSON.stringify(err));
      throw err;
    }
  }

  // 从PixelMap识别文字
  async recognizeFromPixelMap(pixelMap: image.PixelMap): Promise<OCRResult> {
    try {
      // 构建VisionInfo对象
      const visionInfo: textRecognition.VisionInfo = {
        pixelMap: pixelMap
      };

      // 配置识别参数
      const config: textRecognition.TextRecognitionConfiguration = {
        isDirectionDetectionSupported: true
      };

      // 执行识别
      const result = await textRecognition.recognizeText(visionInfo, config);

      // 解析结果
      return this.parseOCRResult(result);
    } catch (err) {
      console.error('OCR识别失败:', JSON.stringify(err));
      throw err;
    }
  }

  // 解析OCR结果
  private parseOCRResult(result: textRecognition.TextRecognitionResult): OCRResult {
    const blocks: TextBlock[] = [];
    let fullText = '';

    if (result.blocks && result.blocks.length > 0) {
      for (const block of result.blocks) {
        const text = block.text || '';
        fullText += text + ' ';
        
        blocks.push({
          text: text,
          confidence: block.confidence || 0,
          rect: block.rect
        });
      }
    }

    return {
      fullText: fullText.trim(),
      blocks: blocks,
      blockCount: blocks.length
    };
  }

  // 释放OCR资源
  release(): void {
    try {
      textRecognition.release();
      this.isInitialized = false;
      console.info('OCR资源已释放');
    } catch (err) {
      console.error('释放OCR资源失败:', JSON.stringify(err));
    }
  }

  // 识别支付信息（从OCR文本中提取）
  extractPaymentInfo(ocrText: string): PaymentInfoFromOCR {
    const lines = ocrText.split(/\n|\s+/);
    
    let amount: number | null = null;
    let merchant: string | null = null;
    let time: string | null = null;
    let isPaymentSuccess = false;

    for (const line of lines) {
      const trimmedLine = line.trim();
      
      // 识别金额
      if (!amount) {
        amount = this.extractAmount(trimmedLine);
      }
      
      // 识别商户
      if (!merchant) {
        merchant = this.extractMerchant(trimmedLine);
      }
      
      // 识别时间
      if (!time) {
        time = this.extractTime(trimmedLine);
      }
      
      // 检查支付成功标识
      if (this.isPaymentSuccessText(trimmedLine)) {
        isPaymentSuccess = true;
      }
    }

    return {
      amount,
      merchant,
      time,
      isPaymentSuccess,
      rawText: ocrText
    };
  }

  // 提取金额
  private extractAmount(text: string): number | null {
    // 匹配常见金额格式
    const patterns = [
      /[¥￥]\s*(\d+\.?\d*)/,
      /(\d+\.?\d*)\s*[元¥￥]/,
      /金额[：:]\s*(\d+\.?\d*)/,
      /(\d+\.\d{2})/  // 两位小数
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match) {
        const value = parseFloat(match[1]);
        if (!isNaN(value) && value > 0) {
          return value;
        }
      }
    }

    return null;
  }

  // 提取商户
  private extractMerchant(text: string): string | null {
    const patterns = [
      /商户[：:]\s*([^\s]+)/,
      /商家[：:]\s*([^\s]+)/,
      /向(.+?)付款/,
      /收款方[：:]\s*([^\s]+)/,
      /交易对象[：:]\s*([^\s]+)/
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match && match[1]) {
        return match[1].trim();
      }
    }

    return null;
  }
  
  // 提取时间
  private extractTime(text: string): string | null {
    const patterns = [
      /(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})/,
      /(\d{4}\/\d{2}\/\d{2}\s+\d{2}:\d{2}:\d{2})/,
      /(\d{4}年\d{2}月\d{2}日\s+\d{2}:\d{2})/,
      /(\d{2}:\d{2}:\d{2})/
    ];

    for (const pattern of patterns) {
      const match = text.match(pattern);
      if (match) {
        return match[1];
      }
    }

    return null;
  }

  // 检查支付成功标识
  private isPaymentSuccessText(text: string): boolean {
    const successKeywords = [
      '支付成功', '付款成功', '交易成功', '支付完成', '扫码成功',
      '收款成功', '转账成功', '充值成功', '交易完成'
    ];

    const lowerText = text.toLowerCase();
    return successKeywords.some(keyword => 
      lowerText.includes(keyword.toLowerCase())
    );
  }
}

// OCR结果接口
interface OCRResult {
  fullText: string;
  blocks: TextBlock[];
  blockCount: number;
}

// 文字块接口
interface TextBlock {
  text: string;
  confidence: number;
  rect?: image.Rect;
}

// 从OCR提取的支付信息
interface PaymentInfoFromOCR {
  amount: number | null;
  merchant: string | null;
  time: string | null;
  isPaymentSuccess: boolean;
  rawText: string;
}

export default OCRManager.getInstance();
