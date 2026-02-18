# HarmonyOS 自动记账应用合集

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-5.0+-blue.svg)](https://developer.harmonyos.com/)
[![ArkTS](https://img.shields.io/badge/Language-ArkTS-orange.svg)](https://developer.harmonyos.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

本仓库包含两个基于 HarmonyOS NEXT 开发的智能记账应用，展示鸿蒙应用开发的最佳实践。

---

## 📱 项目概览

### 1. AutoBill - 基础记账应用

一个简洁的鸿蒙记账应用，展示了 HarmonyOS 应用的基础架构和核心功能。

**特点**：
- 基础记账功能（收入/支出）
- 数据持久化存储
- 简洁的用户界面
- 适合初学者学习鸿蒙开发

**技术栈**：
- ArkTS 声明式 UI
- SQLite 本地数据库
- 基础状态管理

[查看详情](./AutoBill/README.md)

---

### 2. AutoRecordAccounting - 智能自动记账应用 ⭐

一个功能完整的智能记账应用，通过无障碍服务实现支付自动识别，让记账变得 effortless。

**核心功能**：
- 🤖 **自动识别支付**：监听微信、支付宝支付页面，自动弹出记账提示
- 💰 **一键记账**：支付后点击确认即可自动记录金额、商户、分类
- 🏷️ **智能分类**：根据商户名自动分类（餐饮、交通、购物等）
- 📝 **手动记账**：支持手动添加收入和支出记录
- 📊 **数据统计**：今日/本月收支概览，分类统计分析
- 💾 **数据安全**：本地存储，支持 JSON/CSV 备份导出

**技术亮点**：
- 三层架构设计（数据层/业务层/UI层）
- AccessibilityExtensionAbility 无障碍服务
- RelationalStore (SQLite) 本地数据库
- 自定义单元测试框架（54 个测试用例）
- 完整文档（6 份文档，约 7000 字）

**项目统计**：
- 源代码：约 2,900 行
- 测试代码：约 800 行（54 个测试用例）
- 文档：6 份完整文档
- 测试通过率：83.3%（45/54）

[查看详情](./AutoRecordAccounting/README.md) | [测试文档](./AutoRecordAccounting/docs/README.md)

---

## 🚀 快速开始

### 环境要求

- **IDE**: DevEco Studio NEXT
- **SDK**: HarmonyOS NEXT API 12+
- **设备**: HarmonyOS 5.0+ 设备（真机或模拟器）

### 运行项目

```bash
# 1. 克隆仓库
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# 2. 使用 DevEco Studio 打开项目
# File -> Open -> 选择 AutoRecordAccounting 目录

# 3. 构建项目
# Build -> Build Hap(s)

# 4. 运行到设备
# Run -> Run 'entry'
```

---

## 📚 文档导航

### AutoRecordAccounting 文档
- [测试与上线方案](./AutoRecordAccounting/docs/TESTING_AND_RELEASE_PLAN.md)
- [功能测试用例](./AutoRecordAccounting/docs/TEST_CASES.md)
- [应用商店上架材料清单](./AutoRecordAccounting/docs/APP_STORE_MATERIALS.md)
- [上线前检查清单](./AutoRecordAccounting/docs/GO_LIVE_CHECKLIST.md)
- [快速参考指南](./AutoRecordAccounting/docs/QUICK_REFERENCE.md)
- [单元测试完成报告](./AutoRecordAccounting/docs/UNIT_TEST_COMPLETION_REPORT.md)

---

## 🧪 测试

### 运行单元测试

```bash
# 进入测试目录
cd AutoRecordAccounting/entry/src/ohosTest/ets/test

# 运行测试（在 DevEco Studio 中）
# 右键点击测试文件 -> Run 'XXXTest'
```

### 测试结果

- **总用例数**: 54 个
- **通过**: 45 个（83.3%）
- **待验证**: 9 个（需要真机环境）
- **Bug**: 0 个

---

## 📂 项目结构

```
program1/
├── .gitignore                          # Git 忽略配置
├── AutoBill/                           # 基础记账应用
│   ├── entry/src/main/ets/             # 源代码
│   └── README.md
│
└── AutoRecordAccounting/               # 智能自动记账应用
    ├── entry/src/main/ets/             # 源代码
    │   ├── entryability/               # 入口 Ability
    │   ├── pages/                      # 6 个页面
    │   ├── services/                   # 业务服务层
    │   ├── database/                   # 数据库管理
    │   ├── models/                     # 数据模型
    │   ├── utils/                      # 工具函数
    │   └── constants/                  # 常量定义
    │
    ├── entry/src/ohosTest/ets/test/    # 单元测试
    │   ├── TestFramework.ets           # 测试框架
    │   ├── TestDataFactory.ets         # 测试数据
    │   ├── UtilsTest.ets               # 工具类测试
    │   ├── ModelTest.ets               # 模型测试
    │   ├── PaymentDetectorTest.ets     # 支付检测测试
    │   └── DatabaseManagerTest.ets     # 数据库测试
    │
    ├── docs/                           # 项目文档
    └── README.md
```

---

## 🎯 开发计划

### 当前进度

- [x] 项目架构搭建
- [x] 核心功能实现
- [x] 单元测试框架（54 个用例）
- [x] 完整文档
- [ ] 真机数据库测试
- [ ] 集成测试
- [ ] 上架发布

### 时间线

```
Week 1 (现在): 单元测试 ✅
Week 2: 集成测试
Week 3: 系统测试
Week 4: Bug 修复
Week 5: 上架准备
Week 6-7: 上架发布
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 提交 Issue
- 描述问题现象
- 提供设备型号和系统版本
- 附上复现步骤

### 提交代码
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交变更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)。

---

## 👥 作者

- **开发者**: [Your Name]
- **邮箱**: [your.email@example.com]
- **GitHub**: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)

---

## 🙏 致谢

- [华为开发者联盟](https://developer.huawei.com/)
- [HarmonyOS 开发者文档](https://developer.harmonyos.com/)
- [OpenHarmony 社区](https://gitee.com/openharmony)

---

## 📞 联系方式

如有问题或建议，欢迎通过以下方式联系：

- 📧 邮箱: [xsk686260@gmail.com]
- 🐛 GitHub Issues: [提交 Issue](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)
- 💬 讨论区: [GitHub Discussions](https://github.com/YOUR_USERNAME/YOUR_REPO/discussions)

---

<p align="center">
  Made with ❤️ for HarmonyOS
</p>
