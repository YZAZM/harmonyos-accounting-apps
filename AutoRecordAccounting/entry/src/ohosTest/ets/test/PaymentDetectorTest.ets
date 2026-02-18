// PaymentDetector 单元测试

import { describe, it, Assert } from './TestFramework'
import { PaymentDetector } from '../../main/ets/services/PaymentDetector'
import { TestDataFactory } from './TestDataFactory'

describe('PaymentDetector Tests', () => {
  let detector: PaymentDetector

  it('should create PaymentDetector instance', () => {
    detector = new PaymentDetector()
    Assert.notNull(detector)
  })

  it('should detect WeChat payment success page', () => {
    detector = new PaymentDetector()
    const pageText = TestDataFactory.getWeChatPayText()
    
    // Mock page info
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const isPaymentPage = detector.isPaymentPage(pageInfo)
    Assert.true(isPaymentPage, 'Should detect WeChat payment page')
  })

  it('should detect Alipay payment success page', () => {
    detector = new PaymentDetector()
    const pageText = TestDataFactory.getAlipayText()
    
    const pageInfo = {
      bundleName: 'com.eg.android.AlipayGphone',
      text: pageText,
      children: []
    } as any

    const isPaymentPage = detector.isPaymentPage(pageInfo)
    Assert.true(isPaymentPage, 'Should detect Alipay payment page')
  })

  it('should not detect non-payment page', () => {
    detector = new PaymentDetector()
    
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: '这是普通聊天页面，不包含支付信息',
      children: []
    } as any

    const isPaymentPage = detector.isPaymentPage(pageInfo)
    Assert.false(isPaymentPage, 'Should not detect non-payment page')
  })

  it('should not detect unsupported app', () => {
    detector = new PaymentDetector()
    
    const pageInfo = {
      bundleName: 'com.example.unsupported',
      text: '支付成功 ￥100.00',
      children: []
    } as any

    const isPaymentPage = detector.isPaymentPage(pageInfo)
    Assert.false(isPaymentPage, 'Should not detect unsupported app')
  })
})

describe('Payment Amount Extraction Tests', () => {
  let detector: PaymentDetector

  beforeAll(() => {
    detector = new PaymentDetector()
  })

  it('should extract amount from ¥ format', () => {
    const pageText = '支付成功 ¥128.50 收款方：星巴克'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.amount, 128.50)
  })

  it('should extract amount from ￥ format', () => {
    const pageText = '支付成功 ￥256.00 商家：麦当劳'
    const pageInfo = {
      bundleName: 'com.eg.android.AlipayGphone',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.amount, 256.00)
  })

  it('should extract amount with 元 suffix', () => {
    const pageText = '支付金额：99.99元'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.amount, 99.99)
  })

  it('should handle amount without decimal', () => {
    const pageText = '支付成功 ¥100 商户：测试'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.amount, 100)
  })

  it('should return 0 for invalid amount', () => {
    const pageText = '支付成功，但没有金额信息'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.null(paymentInfo)
  })
})

describe('Merchant Extraction Tests', () => {
  let detector: PaymentDetector

  beforeAll(() => {
    detector = new PaymentDetector()
  })

  it('should extract merchant from 收款方', () => {
    const pageText = '支付成功 ¥100 收款方：星巴克咖啡'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.merchant, '星巴克咖啡')
  })

  it('should extract merchant from 商家', () => {
    const pageText = '支付成功 ￥200 商家：麦当劳'
    const pageInfo = {
      bundleName: 'com.eg.android.AlipayGphone',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.merchant, '麦当劳')
  })

  it('should extract merchant from 向...付款', () => {
    const pageText = '支付成功 ¥50 向滴滴出行付款'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.merchant, '滴滴出行')
  })

  it('should return 未知商户 when merchant not found', () => {
    const pageText = '支付成功 ¥100'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.merchant, '未知商户')
  })
})

describe('Payment Method Extraction Tests', () => {
  let detector: PaymentDetector

  beforeAll(() => {
    detector = new PaymentDetector()
  })

  it('should detect 零钱 payment method', () => {
    const pageText = '支付成功 ¥100 支付方式：零钱 商户：测试'
    const pageInfo = {
      bundleName: 'com.tencent.mm',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.payMethod, '余额')
  })

  it('should detect 余额 payment method', () => {
    const pageText = '支付成功 ￥200 付款方式：余额 商家：测试'
    const pageInfo = {
      bundleName: 'com.eg.android.AlipayGphone',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.payMethod, '余额')
  })

  it('should detect 花呗 payment method', () => {
    const pageText = '支付成功 ¥300 付款方式：花呗 商户：测试'
    const pageInfo = {
      bundleName: 'com.eg.android.AlipayGphone',
      text: pageText,
      children: []
    } as any

    const paymentInfo = detector.extractPaymentInfo(pageInfo)
    Assert.notNull(paymentInfo)
    Assert.equal(paymentInfo?.payMethod, '花呗')
  })
})