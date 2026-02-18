# 自动记账 - 鸿蒙版

基于 HarmonyOS NEXT 开发的智能自动记账应用，通过无障碍服务监听支付页面，实现一键自动记账。

## 功能特性

### 核心功能
- **自动识别支付**：通过无障碍服务监听微信、支付宝、银行App的支付页面
- **悬浮确认窗**：支付完成后自动弹出确认窗口，一键记账
- **智能分类**：根据商户名称自动分类（餐饮、交通、购物等）
- **手动记账**：支持手动添加收入和支出记录

### 数据管理
- **本地存储**：使用 RelationalStore (SQLite) 存储数据
- **数据备份**：支持导出/导入 JSON 和 CSV 格式
- **月度统计**：按月查看收支统计和分类占比

### UI界面
- 首页：今日/本月收支概览，最近交易列表
- 账单页：按月查看详细交易记录
- 统计页：收支趋势图，分类统计
- 设置页：自动记账开关，数据管理

## 技术架构

### 开发环境
- **IDE**: DevEco Studio NEXT
- **SDK**: HarmonyOS NEXT API 12+
- **语言**: ArkTS
- **最低版本**: HarmonyOS 5.0

### 项目结构
```
entry/src/main/ets/
├── entryability/          # 入口Ability
├── pages/                 # 页面
│   ├── Index.ets         # 首页
│   ├── AddTransactionPage.ets    # 记账页
│   ├── TransactionListPage.ets   # 账单列表
│   ├── StatisticsPage.ets        # 统计页
│   ├── SettingsPage.ets          # 设置页
│   └── FloatConfirmWindow.ets    # 悬浮确认窗
├── components/            # 公共组件
├── services/              # 服务层
│   ├── AutoRecordAccessibilityAbility.ets  # 无障碍服务
│   ├── PaymentDetector.ets                 # 支付检测器
│   ├── FloatWindowManager.ets              # 悬浮窗管理
│   ├── OCRService.ets                      # OCR识别
│   └── DataBackupService.ets               # 数据备份
├── database/              # 数据层
│   └── DatabaseManager.ets                 # 数据库管理
├── models/                # 数据模型
│   └── Transaction.ets                     # 交易模型
├── utils/                 # 工具函数
│   └── CommonUtils.ets                     # 通用工具
└── constants/             # 常量定义
    ├── AppConstants.ets
    └── DatabaseConstants.ets
```

### 核心模块

#### 1. 无障碍服务 (AccessibilityExtensionAbility)
- 监听页面变化和内容变化
- 检测支付成功页面
- 提取支付信息（金额、商户、时间）

#### 2. 支付检测器 (PaymentDetector)
- 支持微信、支付宝、各大银行App
- 正则表达式提取金额
- 控件解析提取商户信息

#### 3. 悬浮确认窗
- 5秒倒计时自动关闭
- 一键确认/修改/忽略
- 支持修改分类和备注

#### 4. 数据库管理 (RelationalStore)
- 账目表：存储交易记录
- 分类表：收支分类管理
- 自动规则表：识别规则配置

## 权限声明

```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.ACCESSIBILITY_ABILITY",
      "reason": "监听支付页面实现自动记账"
    },
    {
      "name": "ohos.permission.SYSTEM_FLOAT_WINDOW",
      "reason": "显示记账确认弹窗"
    },
    {
      "name": "ohos.permission.KEEP_BACKGROUND_RUNNING",
      "reason": "保持后台运行持续监听"
    }
  ]
}
```

## 支持的支付平台

| 平台 | 支持场景 | 识别方式 |
|------|---------|---------|
| 微信支付 | 扫码支付、转账、商家付款 | 页面控件解析 |
| 支付宝 | 付款码、转账、账单详情 | 页面控件解析 |
| 工商银行 | 转账、支付 | 页面控件解析 |
| 建设银行 | 转账、支付 | 页面控件解析 |
| 招商银行 | 转账、支付 | 页面控件解析 |

## 快速开始

### 1. 环境准备
- 安装 DevEco Studio NEXT
- 配置 HarmonyOS SDK
- 开启开发者模式

### 2. 构建项目
```bash
# 进入项目目录
cd AutoRecordAccounting

# 安装依赖
ohpm install

# 编译项目
hvigorw assembleHap
```

### 3. 运行应用
- 连接鸿蒙设备或启动模拟器
- 点击 Run 按钮部署应用

### 4. 开启自动记账
1. 进入设置页面
2. 开启"自动识别支付"开关
3. 按引导开启无障碍服务权限
4. 开启悬浮窗权限

## 使用说明

### 自动记账流程
1. 在支持的应用中完成支付
2. 系统自动检测支付成功页面
3. 弹出悬浮确认窗（显示金额、商户、分类）
4. 点击"确认"自动记账，或点击"修改"调整信息

### 手动记账
1. 点击首页右下角"+"按钮
2. 选择收支类型（支出/收入）
3. 输入金额和选择分类
4. 填写商户和备注（可选）
5. 点击保存

### 数据备份
1. 进入设置页面
2. 点击"数据备份"
3. 选择导出格式（JSON/CSV）
4. 备份文件保存到本地存储

## 开发计划

- [x] 项目架构搭建
- [x] 数据库设计与实现
- [x] 基础UI框架开发
- [x] 手动记账功能
- [x] 无障碍监听服务
- [x] 支付页面识别
- [x] 悬浮确认窗
- [x] 智能分类系统
- [x] 统计报表功能
- [x] OCR文字识别
- [x] 数据备份导出
- [ ] 性能优化
- [ ] 图表库集成
- [ ] 更多银行适配

## 注意事项

1. **无障碍权限**：必须手动在系统设置中开启
2. **后台保活**：建议在电池优化中将应用加入白名单
3. **隐私说明**：所有数据本地存储，不上传云端
4. **识别准确度**：受App版本更新影响，可能需要调整规则

## 技术难点

### 1. 无障碍服务权限
- 需要用户手动在系统设置中开启
- 首次使用需引导用户完成权限开启

### 2. 页面识别适配
- 不同App版本UI可能变化
- 需要持续维护和更新识别规则

### 3. 后台保活
- 鸿蒙系统对后台服务有限制
- 需要配置电池优化白名单

## 贡献指南

欢迎提交 Issue 和 Pull Request！

### 提交Issue
- 描述问题现象
- 提供设备型号和系统版本
- 附上复现步骤

### 提交代码
1. Fork 本仓库
2. 创建特性分支
3. 提交代码变更
4. 创建 Pull Request

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎通过以下方式联系：
- 邮箱：your.email@example.com
- GitHub Issues

---

**注意**：本项目仅供学习交流使用，请遵守相关平台的使用规范。