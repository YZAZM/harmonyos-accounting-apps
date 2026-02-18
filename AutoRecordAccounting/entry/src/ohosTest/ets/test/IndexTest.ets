// 单元测试主入口

import { TestRunner, TestResult } from './TestFramework'

// 导入所有测试模块
import './UtilsTest'
import './PaymentDetectorTest'
import './DatabaseManagerTest'
import './ModelTest'

// 测试报告生成器
class TestReportGenerator {
  
  static generate(results: TestResult[]): string {
    const total = results.length
    const passed = results.filter(r => r.passed).length
    const failed = total - passed
    const passRate = total > 0 ? ((passed / total) * 100).toFixed(2) : '0.00'
    
    let report = ''
    report += '='.repeat(80) + '\n'
    report += '                    自动记账 App - 单元测试报告\n'
    report += '='.repeat(80) + '\n\n'
    
    report += `测试时间: ${new Date().toLocaleString()}\n`
    report += `测试总数: ${total}\n`
    report += `通过数量: ${passed} ` + (passed === total ? '' : '') + '\n'
    report += `失败数量: ${failed} ` + (failed > 0 ? '' : '') + '\n'
    report += `通过率: ${passRate}%\n\n`
    
    // 按测试套件分组
    const suiteResults = this.groupBySuite(results)
    
    report += '-'.repeat(80) + '\n'
    report += '详细结果:\n'
    report += '-'.repeat(80) + '\n\n'
    
    for (const [suiteName, tests] of Object.entries(suiteResults)) {
      report += `[${suiteName}]\n`
      
      for (const test of tests) {
        const status = test.passed ? 'PASS' : 'FAIL'
        const symbol = test.passed ? '' : ''
        report += `  ${symbol} ${test.testName} (${test.duration}ms)\n`
        
        if (!test.passed && test.error) {
          report += `    Error: ${test.error}\n`
        }
      }
      
      report += '\n'
    }
    
    // 失败用例汇总
    const failedTests = results.filter(r => !r.passed)
    if (failedTests.length > 0) {
      report += '-'.repeat(80) + '\n'
      report += '失败的测试用例:\n'
      report += '-'.repeat(80) + '\n\n'
      
      for (const test of failedTests) {
        report += `[${test.suiteName}] ${test.testName}\n`
        report += `  Error: ${test.error}\n\n`
      }
    }
    
    report += '='.repeat(80) + '\n'
    report += failed === 0 
      ? '  所有测试通过！' 
      : `  有 ${failed} 个测试失败，请检查并修复`
    report += '\n'
    report += '='.repeat(80) + '\n'
    
    return report
  }
  
  private static groupBySuite(results: TestResult[]): Record<string, TestResult[]> {
    const groups: Record<string, TestResult[]> = {}
    
    for (const result of results) {
      if (!groups[result.suiteName]) {
        groups[result.suiteName] = []
      }
      groups[result.suiteName].push(result)
    }
    
    return groups
  }
  
  static saveToFile(report: string, filename: string = 'test_report.txt'): void {
    try {
      // 在实际环境中这里会写入文件
      console.info(`Test report saved to: ${filename}`)
      console.info('\n' + report)
    } catch (err) {
      console.error('Failed to save test report:', err)
    }
  }
  
  static exportToJSON(results: TestResult[], filename: string = 'test_results.json'): string {
    const data = {
      timestamp: new Date().toISOString(),
      summary: {
        total: results.length,
        passed: results.filter(r => r.passed).length,
        failed: results.filter(r => !r.passed).length,
        duration: results.reduce((sum, r) => sum + r.duration, 0)
      },
      results: results
    }
    
    return JSON.stringify(data, null, 2)
  }
}

// 主测试函数
export async function runAllTests(): Promise<void> {
  console.info('\n')
  console.info('='.repeat(80))
  console.info('           开始执行自动记账 App 单元测试')
  console.info('='.repeat(80))
  console.info('\n')
  
  const runner = new TestRunner()
  const results = await runner.run()
  
  // 生成报告
  const report = TestReportGenerator.generate(results)
  TestReportGenerator.saveToFile(report)
  
  // 导出JSON格式（便于CI/CD集成）
  const jsonReport = TestReportGenerator.exportToJSON(results)
  console.info('\nJSON Report:')
  console.info(jsonReport)
  
  // 返回测试结果
  const failed = results.filter(r => !r.passed).length
  if (failed > 0) {
    console.error(`\n测试失败: ${failed} 个用例未通过`)
  } else {
    console.info('\n所有测试通过！')
  }
}

// 如果直接运行此文件，执行测试
if (require.main === module) {
  runAllTests().catch(err => {
    console.error('Test execution failed:', err)
    process.exit(1)
  })
}