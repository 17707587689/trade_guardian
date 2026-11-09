# TradeGuardian

TradeGuardian 是一款专注于“交易计划 + 交易纪律 + 执行复盘”的 Flutter 应用，帮助交易者在下单前明确计划、执行前遵守规则，并在交易后对执行结果进行统计复盘。

它不是简单的行情工具，而是一个帮助减少冲动交易、提高纪律性和可复盘性的交易辅助应用。

## 项目定位

TradeGuardian 的核心目标是：

- 制定交易计划，而不是只记录结果
- 在交易前确认是否违反纪律
- 跟踪计划状态：待生效 / 执行中 / 生效中 / 已完成 / 已取消
- 对近 7 / 30 / 90 天已完成交易命中率做统计分析
- 本地持久化存储，支持导出与导入

---

## 主要功能

### 1. 交易计划管理

支持新增、编辑、删除和状态管理交易计划，覆盖以下核心要素：

- 股票代码 / 股票名称
- 计划买入价、止损价、止盈目标价
- 仓位比例
- 建仓理由
- 买入条件 / 卖出条件
- 最大买入数量 / 最大买入金额
- 是否允许做 T
- 计划建立日期
- 执行备注
- 执行价格、卖出价格、是否命中目标等

计划状态包括：

- `draft`
- `pendingeffective`
- `executing`
- `effective`
- `completed`
- `cancelled`

### 2. 交易纪律管理

内置默认交易原则，并支持自定义编辑、删除和排序：

- 我不会追涨。
- 买入前必须设置止损。
- 单只股票仓位不得超过计划比例。
- 每笔交易必须提前一天制定计划。

用户可以在关键交易前进行纪律确认，避免因情绪驱动而违反规则。

### 3. 执行统计与复盘

首页已经内置近 7 / 30 / 90 天已完成交易命中率统计，便于复盘和自我修正。

通过统计已完成计划中的命中情况，帮助用户评估自己的交易系统是否稳定。 

### 4. 数据导出 / 导入

支持本地数据备份和恢复，包括：

- JSON 导出
- CSV 导出
- JSON 导入
- 覆盖导入 / 追加导入

这有利于数据迁移、备份与后续分析。

### 5. 本地 SQLite 存储

项目使用 SQLite 进行本地数据持久化，数据保存在设备本地，无需后端服务。

### 6. 交易软件快捷入口

首页提供“登陆交易软件”入口，支持直接打开东方财富 App（Android 平台）。

---

## 技术栈

- Flutter
- Dart
- SQLite
- path_provider
- sqflite
- file_picker
- share_plus

---

## 项目结构

```text
trade_guardian/
├── android/
├── ios/
├── lib/
│   ├── app/
│   ├── database/
│   ├── models/
│   ├── pages/
│   ├── repositories/
│   ├── services/
│   ├── widgets/
│   ├── main.dart
│   └── ...
├── test/
├── pubspec.yaml
├── README.md
├── analysis_options.yaml
└── ...
```

关键文件：

- `lib/models/trade_plan.dart`：交易计划模型
- `lib/repositories/trading_rule_repository.dart`：交易原则仓储层
- `lib/pages/home_page.dart`：首页与统计入口
- `lib/pages/data_manage_page.dart`：数据管理页面
- `lib/services/data_export_service.dart`：导出服务
- `lib/services/data_import_service.dart`：导入服务
- `lib/database/database_helper.dart`：数据库初始化

---

## 运行方式

### 1. 准备环境

确保已安装：

- Flutter SDK
- Android Studio / VS Code + Flutter 插件
- JDK 17
- Android SDK

检查环境：

```bash
flutter --version
flutter doctor
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 启动调试版

```bash
flutter run
```

如果需要指定设备：

```bash
flutter devices
flutter run -d <device_id>
```

---

## 打包成 APK

### 方式一：命令行直接打包

在项目根目录执行：

```bash
flutter clean
flutter pub get
flutter build apk --release
```

成功后，APK 一般会输出到：

```text
build/app/outputs/flutter-apk/app-release.apk
```

如果需要调试包：

```bash
flutter build apk --debug
```

### 方式二：Android Studio 打包

1. 打开项目到 Android Studio
2. 选择 `Build > Generate Signed Bundle / APK`
3. 选择 `APK`
4. 如果还没有密钥，创建新的 keystore
5. 选择 `Release` 构建类型
6. 点击 `Finish` 完成打包

生成的 APK 通常位于：

```text
android/app/release/
```

### 方式三：正式发布签名

当前项目的 Android 配置默认使用 debug 签名，适合本地测试；正式发布建议配置 release 签名。

可在 `android/app/build.gradle.kts` 中配置：

```kotlin
signingConfigs {
    create("release") {
        storeFile = file("key.jks")
        storePassword = "your-store-password"
        keyAlias = "your-key-alias"
        keyPassword = "your-key-password"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

然后重新执行：

```bash
flutter build apk --release
```

> 注意：正式发布前请妥善保管 keystore，避免将密码等敏感信息提交到代码仓库中。

---

## 设计原则

TradeGuardian 关注的是“交易计划”和“交易纪律”，而不是单纯的交易结果。

一份计划应在交易发生前就制定，记录：

- 交易理由
- 买卖逻辑
- 风险控制
- 资金管理
- 交易纪律

通过执行统计和复盘，不断优化自己的交易体系。

---

## 说明

这是一个偏“交易纪律辅助型”应用，定位不是股票行情软件本身，而是帮助交易者减少冲动决策、强化规则执行和完善交易体系。

如果后续需要扩展功能，可以在现有结构上继续增强，例如：

- 行情数据对接
- 收益率可视化
- 图表分析
- 执行提醒
- 交易日报生成

---

## 版本信息

- 当前版本：`v0.1.1`

---

## 相关链接

- `README.md`
- `pubspec.yaml`
- `lib/main.dart`
- `lib/pages/home_page.dart`
- `lib/pages/data_manage_page.dart`
- `android/app/build.gradle.kts`
