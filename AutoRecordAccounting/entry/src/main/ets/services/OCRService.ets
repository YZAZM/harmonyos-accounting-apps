import { textRecognition } from '@kit.CoreVisionKit'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'

export class OCRService {
  private static instance: OCRService

  static getInstance(): OCRService {
    if (!OCRService.instance) {
      OCRService.instance = new OCRService()
    }
    return OCRService.instance
  }

  // 从图片识别文字
  async recognizeTextFromImage(imageUri: string): Promise<string> {
    try {
      // 读取图片文件
      const fileSource = await fileIo.open(imageUri, fileIo.OpenMode.READ_ONLY)
      const imageSource = image.createImageSource(fileSource.fd)
      const pixelMap = await imageSource.createPixelMap()

      // 配置识别参数
      const config: textRecognition.TextRecognitionConfiguration = {
        isDirectionDetectionSupported: true
      }

      // 执行文字识别
      const visionInfo: textRecognition.VisionInfo = {
        pixelMap: pixelMap
      }

      const result = await textRecognition.recognizeText(visionInfo, config)
      
      // 释放资源
      pixelMap.release()
      await fileIo.close(fileSource.fd)

      if (result.value) {
        return this.extractTextFromResult(result.value)
      }

      return ''

    } catch (err) {
      console.error('OCR识别失败:', err)
      throw err
    }
  }

  // 从屏幕截图识别支付信息
  async recognizeFromScreenshot(): Promise<{ amount: number, merchant: string } | null> {
    try {
      // 获取屏幕截图（需要系统权限）
      // 这里需要根据鸿蒙实际API实现
      
      // 临时返回null，等待实际实现
      return null

    } catch (err) {
      console.error('屏幕截图识别失败:', err)
      return null
    }
  }

  // 解析识别结果
  private extractTextFromResult(result: textRecognition.TextRecognitionResult): string {
    if (!result.blocks) {
      return ''
    }

    let fullText = ''
    for (const block of result.blocks) {
      if (block.text) {
        fullText += block.text + ' '
      }
    }

    return fullText.trim()
  }

  // 从OCR文本中提取金额
  extractAmountFromText(text: string): number {
    const patterns = [
      /[¥￥]\s*(\d+\.?\d{0,2})/,
      /(\d+\.\d{2})\s*元/,
      /金额[：:]\s*(\d+\.?\d{0,2})/,
      /合计[：:]\s*[¥￥]?\s*(\d+\.?\d{0,2})/,
      /(\d+\.\d{2})/
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match && match[1]) {
        const amount = parseFloat(match[1])
        if (amount > 0 && amount < 1000000) {
          return amount
        }
      }
    }

    return 0
  }

  // 从OCR文本中提取商户
  extractMerchantFromText(text: string): string {
    const patterns = [
      /商户[名称]*[：:]\s*([^\n]+)/,
      /商家[：:]\s*([^\n]+)/,
      /向(.+?)付款/,
      /收款方[：:]\s*([^\n]+)/,
      /转账给\s*([^\n]+)/,
      /付款给\s*([^\n]+)/
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match && match[1]) {
        return match[1].trim()
      }
    }

    return ''
  }
}