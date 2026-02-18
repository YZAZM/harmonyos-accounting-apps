# 自动记账 - AutoBill

## 项目概述

基于 **HarmonyOS NEXT** 开发的智能自动记账应用，支持自动识别支付页面并快速记账。

## 核心功能

### 1. 自动识别记账 ⭐
- 监听微信、支付宝、银行App支付页面
- 自动提取金额、商户、时间信息
- 弹出悬浮确认窗，一键记账
- 支持OCR文字识别作为备用方案

### 2. 智能分类
- 自动识别商户类型并分类
- 支持10+种预设分类（餐饮、交通、购物等）
- 分类关键词可扩展

### 3. 账目管理
- 手动记账（支出/收入）
- 查看历史账单
- 按月筛选统计
- 左滑删除记录

### 4. 数据可视化
- 今日/本月收支概览
- 分类占比饼图
- 7日趋势柱状图
- 分类明细排行

### 5. 数据安全
- 纯本地数据库存储
- 支持数据导出/导入
- 隐私政策合规

## 技术架构

```
HarmonyOS NEXT (API 12+)
├── ArkTS (开发语言)
├── ArkUI (UI框架)
├── RelationalStore (SQLite数据库)
├── Accessibility Kit (无障碍服务)
├── Core Vision Kit (OCR识别)
└── 悬浮窗 (WindowManager)
```

## 项目结构

```
AutoBill/
├── build-profile.json5          # 构建配置
├── oh-package.json5             # 项目配置
└── entry/
    ├── src/main/ets/
    │   ├── entryability/
    │   │   └── EntryAbility.ets # 应用入口
    │   ├── pages/
    │   │   ├── Index.ets        # 首页
    │   │   ├── AddTransaction.ets   # 添加记账
    │   │   ├── TransactionList.ets  # 账单列表
    │   │   ├── Statistics.ets       # 统计页面
    │   │   └── Settings.ets         # 设置页面
    │   ├── services/
    │   │   ├── AutoRecordAbility.ets    # 无障碍服务
    │   │   └── OCRManager.ets           # OCR识别
    │   ├── data/
    │   │   ├── DatabaseManager.ets  # 数据库管理
    │   │   └── Dao.ets              # 数据访问对象
    │   ├── utils/
    │   │   ├── SmartCategorizer.ets # 智能分类
    │   │   └── Utils.ets            # 工具函数
    │   └── components/
    │       └── FloatingConfirmWindow.ets  # 悬浮确认窗
    └── src/main/resources/        # 资源文件
```

## 核心模块说明

### 1. 无障碍服务 (AutoRecordAbility.ets)
- 监听系统页面变化
- 识别支付成功页面
- 提取支付信息
- 触发悬浮确认窗

### 2. 数据库 (DatabaseManager.ets / Dao.ets)
- SQLite关系型数据库
- 三表结构：账目表、分类表、自动规则表
- 支持复杂查询和事务

### 3. 智能分类 (SmartCategorizer.ets)
- 基于关键词的分类算法
- 支持100+商户关键词匹配
- 可扩展的分类规则

### 4. OCR识别 (OCRManager.ets)
- Core Vision Kit端侧识别
- 无需联网，保护隐私
- 支持图片和屏幕截图

### 5. 悬浮窗 (FloatingConfirmWindow.ets)
- 自定义确认界面
- 支持修改分类和备注
- 3秒自动消失

## 使用方法

### 1. 开启自动记账
1. 进入【设置】页面
2. 开启"自动记账"开关
3. 按提示开启"无障碍服务"权限
4. 开启"悬浮窗"权限

### 2. 使用自动记账
1. 正常进行支付（微信/支付宝/银行App）
2. 支付成功后，悬浮窗自动弹出
3. 检查金额和分类是否正确
4. 点击"确认记账"完成记录

### 3. 手动记账
1. 点击首页右上角"+ 记一笔"
2. 输入金额，选择分类
3. 填写商户和备注（可选）
4. 点击"保存"

### 4. 查看统计
1. 切换到"统计"标签
2. 选择时间周期（本周/本月/本年）
3. 查看分类占比和趋势

## 技术亮点

1. **纯原生HarmonyOS开发**：使用ArkTS语言，性能最优
2. **端侧AI识别**：OCR无需联网，保护用户隐私
3. **智能防抖机制**：避免重复识别，提升体验
4. **模块化架构**：代码结构清晰，易于维护
5. **响应式UI**：ArkUI声明式开发，界面流畅

## 开发环境

- **操作系统**：HarmonyOS NEXT
- **最低版本**：API 12 (HarmonyOS 5.0)
- **开发工具**：DevEco Studio 5.0+
- **开发语言**：ArkTS
- **构建工具**：Hvigor

## 权限说明

应用需要以下权限才能正常工作：

1. **无障碍服务** (`ohos.permission.ACCESSIBILITY_ABILITY`)
   - 用途：监听支付页面
   
2. **悬浮窗** (`ohos.permission.FLOATING_WINDOW`)
   - 用途：显示确认窗口
   
3. **后台运行** (`ohos.permission.KEEP_BACKGROUND_RUNNING`)
   - 用途：持续监听支付

4. **屏幕内容读取** (`ohos.permission.READ_SCREEN_CONTENT`)
   - 用途：识别屏幕文字

## 后续优化方向

### Phase 4（已完成基础版）
- [ ] 数据备份/恢复功能完善
- [ ] 图表库优化（使用HarmonyCharts）
- [ ] 应用商店上架准备

### 未来版本
- [ ] 语音记账
- [ ] 账单导入（微信/支付宝账单）
- [ ] 多设备数据同步
- [ ] 预算管理
- [ ] 记账提醒

## 开发团队

项目负责人：AI开发助手
开发周期：17周（完整产品级）

## 许可协议

MIT License

---

**注意**：本应用为演示项目，实际开发中需要根据华为官方文档调整API调用。
