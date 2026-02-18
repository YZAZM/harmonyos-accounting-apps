// 单元测试框架 - 轻量级测试工具

export interface TestCase {
  name: string
  fn: () => void | Promise<void>
}

export interface TestSuite {
  name: string
  tests: TestCase[]
  beforeEach?: () => void | Promise<void>
  afterEach?: () => void | Promise<void>
  beforeAll?: () => void | Promise<void>
  afterAll?: () => void | Promise<void>
}

export interface TestResult {
  suiteName: string
  testName: string
  passed: boolean
  error?: string
  duration: number
}

export class TestRunner {
  private suites: TestSuite[] = []
  private results: TestResult[] = []

  describe(name: string, fn: () => void): void {
    const suite: TestSuite = {
      name,
      tests: []
    }
    
    // 临时存储当前suite
    const currentSuite = this.currentSuite
    this.currentSuite = suite
    
    try {
      fn()
    } finally {
      this.currentSuite = currentSuite
    }
    
    this.suites.push(suite)
  }

  it(name: string, fn: () => void | Promise<void>): void {
    if (this.currentSuite) {
      this.currentSuite.tests.push({ name, fn })
    }
  }

  beforeEach(fn: () => void | Promise<void>): void {
    if (this.currentSuite) {
      this.currentSuite.beforeEach = fn
    }
  }

  afterEach(fn: () => void | Promise<void>): void {
    if (this.currentSuite) {
      this.currentSuite.afterEach = fn
    }
  }

  beforeAll(fn: () => void | Promise<void>): void {
    if (this.currentSuite) {
      this.currentSuite.beforeAll = fn
    }
  }

  afterAll(fn: () => void | Promise<void>): void {
    if (this.currentSuite) {
      this.currentSuite.afterAll = fn
    }
  }

  private currentSuite: TestSuite | null = null

  async run(): Promise<TestResult[]> {
    this.results = []
    
    for (const suite of this.suites) {
      console.info(`\n Running Test Suite: ${suite.name}`)
      
      // 执行 beforeAll
      if (suite.beforeAll) {
        try {
          await suite.beforeAll()
        } catch (err) {
          console.error(` beforeAll failed: ${err}`)
        }
      }
      
      // 执行测试用例
      for (const test of suite.tests) {
        const startTime = Date.now()
        
        // 执行 beforeEach
        if (suite.beforeEach) {
          try {
            await suite.beforeEach()
          } catch (err) {
            console.error(` beforeEach failed: ${err}`)
          }
        }
        
        try {
          await test.fn()
          const duration = Date.now() - startTime
          this.results.push({
            suiteName: suite.name,
            testName: test.name,
            passed: true,
            duration
          })
          console.info(`  PASS: ${test.name} (${duration}ms)`)
        } catch (err) {
          const duration = Date.now() - startTime
          this.results.push({
            suiteName: suite.name,
            testName: test.name,
            passed: false,
            error: String(err),
            duration
          })
          console.error(`  FAIL: ${test.name}`)
          console.error(`    Error: ${err}`)
        }
        
        // 执行 afterEach
        if (suite.afterEach) {
          try {
            await suite.afterEach()
          } catch (err) {
            console.error(` afterEach failed: ${err}`)
          }
        }
      }
      
      // 执行 afterAll
      if (suite.afterAll) {
        try {
          await suite.afterAll()
        } catch (err) {
          console.error(` afterAll failed: ${err}`)
        }
      }
    }
    
    this.printSummary()
    return this.results
  }

  private printSummary(): void {
    const total = this.results.length
    const passed = this.results.filter(r => r.passed).length
    const failed = total - passed
    
    console.info('\n' + '='.repeat(50))
    console.info('Test Summary:')
    console.info(`  Total:  ${total}`)
    console.info(`  Passed: ${passed} `)
    console.info(`  Failed: ${failed} `)
    console.info(`  Duration: ${this.results.reduce((sum, r) => sum + r.duration, 0)}ms`)
    console.info('='.repeat(50))
  }
}

// 断言工具
export class Assert {
  static equal(actual: any, expected: any, message?: string): void {
    if (actual !== expected) {
      throw new Error(message || `Expected ${expected}, but got ${actual}`)
    }
  }

  static notEqual(actual: any, expected: any, message?: string): void {
    if (actual === expected) {
      throw new Error(message || `Expected not ${expected}, but got ${actual}`)
    }
  }

  static true(value: boolean, message?: string): void {
    if (value !== true) {
      throw new Error(message || `Expected true, but got ${value}`)
    }
  }

  static false(value: boolean, message?: string): void {
    if (value !== false) {
      throw new Error(message || `Expected false, but got ${value}`)
    }
  }

  static null(value: any, message?: string): void {
    if (value !== null) {
      throw new Error(message || `Expected null, but got ${value}`)
    }
  }

  static notNull(value: any, message?: string): void {
    if (value === null || value === undefined) {
      throw new Error(message || `Expected not null, but got ${value}`)
    }
  }

  static throws(fn: () => void, message?: string): void {
    let threw = false
    try {
      fn()
    } catch (err) {
      threw = true
    }
    if (!threw) {
      throw new Error(message || 'Expected function to throw')
    }
  }

  static async throwsAsync(fn: () => Promise<void>, message?: string): Promise<void> {
    let threw = false
    try {
      await fn()
    } catch (err) {
      threw = true
    }
    if (!threw) {
      throw new Error(message || 'Expected async function to throw')
    }
  }

  static contains(array: any[], item: any, message?: string): void {
    if (!array.includes(item)) {
      throw new Error(message || `Expected array to contain ${item}`)
    }
  }

  static greaterThan(actual: number, expected: number, message?: string): void {
    if (!(actual > expected)) {
      throw new Error(message || `Expected ${actual} to be greater than ${expected}`)
    }
  }

  static lessThan(actual: number, expected: number, message?: string): void {
    if (!(actual < expected)) {
      throw new Error(message || `Expected ${actual} to be less than ${expected}`)
    }
  }
}

// 导出便捷函数
export const test = new TestRunner()
export const describe = test.describe.bind(test)
export const it = test.it.bind(test)
export const beforeEach = test.beforeEach.bind(test)
export const afterEach = test.afterEach.bind(test)
export const beforeAll = test.beforeAll.bind(test)
export const afterAll = test.afterAll.bind(test)