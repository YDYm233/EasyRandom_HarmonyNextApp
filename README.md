# 🎲 随易 EasyRandom

<p align="center">
  <img src="./preview/应用图标.png" width="120" alt="随易应用图标"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="./preview/应用元服务图标.png" width="120" alt="随易元服务图标"/>
</p>

<p align="center">
  <strong>面向生活的随机工具箱 · 纯血鸿蒙原生应用</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HarmonyOS-NEXT%205.0-blue" alt="HarmonyOS"/>
  <img src="https://img.shields.io/badge/API-12-brightgreen" alt="API 12"/>
  <img src="https://img.shields.io/badge/Version-1.0.16-orange" alt="Version"/>
  <img src="https://img.shields.io/badge/License-Apache%202.0-lightgrey" alt="License"/>
</p>

---

## 📖 项目简介

> 随易是一款基于 **HarmonyOS NEXT（纯血鸿蒙）** 原生开发的日常生活随机工具箱应用。
>
> 集成各个功能的工具箱，例如：抽签、掷骰子、丢硬币、随机数等。
>
> 同时提供一些有趣的功能，例如：幸运转盘、真心话大冒险、答案之书、祝福木鱼等。
>
> ⚠️ **注意**：本应用某些功能如**答案之书**由随机算法生成结果，不会偏向任何结果，请勿过度依赖随机结果。

**目标**：打造一个覆盖手机、平板、折叠屏、车机、手表等多形态设备的全场景鸿蒙工具箱，充分利用 HarmonyOS 新特性（服务卡片、元服务、多设备协同等）。

---

## ✨ 核心特性

| 特性 | 说明                       |
|------|--------------------------|
| 🧩 **多设备适配** | 支持手机、平板、2in1、车机，【手表端开发中】 |
| 📱 **服务卡片** | 7 种桌面服务卡片，无需打开应用即可使用     |
| 🔗 **元服务** | 提供轻量级元服务版本，即点即用          |
| 🌐 **多语言** | 支持中文简体、English           |
| 🌙 **暗夜模式** | 完整适配深色主题                 |
| 📐 **响应式布局** | 基于断点系统的自适应栅格布局           |
| 🔒 **隐私合规** | 内置隐私政策弹窗，符合应用市场审核要求      |
| 📊 **VitalUI 图表库** | 自研图表组件库（饼图、玫瑰图、雷达图等）     |

---

## 🏗️ 技术架构

### 技术栈

- **语言**：ArkTS（TypeScript 超集）
- **UI 框架**：ArkUI（声明式 UI）
- **SDK 版本**：HarmonyOS 5.0.0 (API 12)
- **构建工具**：hvigor
- **模块化方案**：HAP + HAR 多模块架构

### 模块架构

```
app_EasyRandom
├── product/default         # 主入口模块 (HAP)  — 手机/平板/2in1/车机
├── product/wearable        # 手表模块 (HAP)   — 开发中，暂未启用
├── common/basic            # 公共基础库 (HAR)  — 通用组件、工具函数
└── common/VitalUI          # 图表组件库 (HAR)  — 饼图、玫瑰图、雷达图
```

### 依赖关系

```
product/default  ──→  @ohos/common (basic)
                  ──→  @ohos/vitalui (VitalUI)
product/wearable  ──→  @ohos/common (basic)
```

---

## 📁 项目结构

```
├── AppScope/                          # 应用全局配置
│   ├── app.json5                      # 应用包名、版本信息
│   └── resources/                     # 全局资源（多语言字符串、颜色等）
│       ├── base/                      # 默认语言 (zh-CN)
│       ├── en/                        # 英文资源
│       ├── ja/                        # 日文资源
│       └── dark/                      # 暗夜模式颜色
│
├── build-profile.json5                # 顶层构建配置（签名、产品、模块注册）
│
├── common/                            # 共享库目录
│   ├── basic/                         # 公共基础库 (HAR)
│   │   └── src/main/ets/
│   │       ├── components/            # 公共组件（MainPage、ColorPickerDialog）
│   │       └── utils/                 # 工具函数（断点系统、日志、数学工具、全局上下文）
│   └── VitalUI/                       # 图表组件库 (HAR)
│       └── src/main/ets/
│           ├── chart/                 # 图表组件（PieChart、RoseChart、RadarChart）
│           └── utils/                 # 颜色工具、随机算法
│
├── product/                           # 产品模块目录
│   ├── default/                       # 主入口模块
│   │   └── src/main/
│   │       ├── ets/
│   │       │   ├── entryability/      # 主 Ability
│   │       │   ├── defaultformability/# 服务卡片 Ability
│   │       │   ├── pages/             # 主页面
│   │       │   │   ├── Index.ets      # 首页（Tab 导航）
│   │       │   │   ├── AnswerPage.ets # 答案之书
│   │       │   │   ├── MorePage.ets   # 工具箱列表
│   │       │   │   ├── AllasOne.ets   # 功能卡片（服务卡片预览）
│   │       │   │   ├── RollPage/      # 幸运转盘模块
│   │       │   │   ├── SettingPage/   # 设置模块
│   │       │   │   ├── RandomPage.ets # 随机功能
│   │       │   │   └── ToolsPage.ets  # 工具页
│   │       │   ├── sub_pages/         # 子功能页面
│   │       │   │   ├── random_colors/ # 随机颜色
│   │       │   │   ├── random_names/  # 抽签
│   │       │   │   ├── random_numbers/# 随机数
│   │       │   │   ├── random_foods/  # 吃什么
│   │       │   │   ├── random_places/ # 人生必去的100个地方
│   │       │   │   ├── random_abcd/   # ABCD 选择器
│   │       │   │   ├── flip_coin/     # 丢硬币
│   │       │   │   ├── flip_dices/    # 掷骰子
│   │       │   │   ├── blessing_muyu/ # 祝福木鱼
│   │       │   │   ├── devine_bagua/  # 八卦占卜
│   │       │   │   ├── honest_or_challenge/ # 真心话大冒险
│   │       │   │   ├── trans_qr/      # 二维码转换
│   │       │   │   └── text_marquee/  # 手持弹幕
│   │       │   ├── form_cards/        # 服务卡片组件
│   │       │   └── static_datas/      # 静态数据（答案库、食物库等）
│   │       └── resources/             # 模块资源
│   │           └── base/profile/
│   │               ├── main_pages.json # 页面路由注册
│   │               ├── route_map.json  # 路由映射
│   │               └── form.json       # 服务卡片配置
│   │
│   └── wearable/                      # 手表模块（开发中）
│
├── preview/                           # 应用预览截图
└── hvigor/                            # hvigor 构建配置
```

---

## 🎯 功能模块

### 🏠 首页 Tab

| Tab | 名称 | 说明 |
|-----|------|------|
| 1 | 幸运转盘 | 自定义转盘抽奖，支持编辑轮盘项 |
| 2 | 功能卡片 | 预览服务卡片效果，支持一键添加到桌面 |
| 3 | 答案之书 | 默念问题，翻开属于你的答案 |
| 4 | 工具箱 | 全部功能入口列表 |

### 🧰 工具箱功能

| 功能 | 状态 | 页面路径 | 说明 |
|------|:----:|----------|------|
| 🎡 幸运转盘 | ✅ | RollPage/RollWheelPage | 自定义轮盘抽奖，可视化编辑 |
| 📖 答案之书 | ✅ | AnswerPage | 经典翻书式随机答案 |
| 🎲 掷骰子 | ✅ | flip_dices/RollDices | 多骰子组合投掷 |
| 🪙 丢硬币 | ✅ | flip_coin/FlipCoin | 硬币翻转动画 |
| 🔢 随机数 | ✅ | random_numbers/RandomNumbers | 自定义范围随机数生成 |
| 🍜 吃什么 | ✅ | random_foods/RandomFoods | 随机推荐美食 |
| 🎨 颜色搭配 | ✅ | random_colors/RandomColors | 随机色彩搭配灵感 |
| ✍️ 抽签 | ✅ | random_names/RandomNames | 自定义名单抽取 |
| 🎯 真心话大冒险 | ✅ | honest_or_challenge/HonestOrChallenge | 双模式挑战 |
| ☯️ 八卦占卜 | ✅ | devine_bagua/DevineBaGua | 传统八卦占卜 |
| 🐟 祝福木鱼 | ✅ | blessing_muyu/BlessingMuyu_V2 | 敲击木鱼积累功德 |
| 🌍 人生必去的100个地方 | ✅ | random_places/RandomPlaces | 旅行灵感随机推荐 |
| 🔤 ABCD 选择器 | ✅ | random_abcd/RandomABCD | 快速四选一决策 |
| 📱 手持弹幕 | ✅ | text_marquee/TextMarquee | LED 滚动字幕 |
| 🔄 二维码转换 | ✅ | trans_qr/TransQR | 文字/链接转二维码 |

### 🧩 服务卡片（桌面小组件）

| 11| 卡片 | 尺寸 | 说明 |
|- | -----|:----:|------|
| ✅ | 🎲 骰子卡片 | 2×2 | 点击投掷骰子 |
|✅ |  🪙 硬币卡片 | 2×2 | 点击抛硬币 |
| ✅ | 🎡 转盘卡片 | 2×2 / 4×4 | 迷你幸运转盘 |
| ✅ | ☯️ 八卦卡片 | 2×2 / 4×4 | 八卦占卜结果 |
| ✅ | 🎨 颜色卡片 | 2×2 | 随机颜色展示 |
|✅ |  🔤 ABCD 卡片 | 2×2 | 四选一抽选 |
| ✅ | 🐟 木鱼卡片 | 2×2 | 敲木鱼快捷入口 |

---

## 🚀 快速开始

### 环境要求

- **DevEco Studio**：5.0.0 及以上版本
- **HarmonyOS SDK**：API 12 (5.0.0)
- **设备系统**：HarmonyOS NEXT 5.0.0+

### 构建运行

```bash
# 1. 克隆项目
git clone <仓库地址>

# 2. 使用 DevEco Studio 打开项目

# 3. 配置签名（参考 build-profile.json5）

# 4. 选择产品 target 为 default

# 5. 点击运行或使用命令行构建
hvigorw assembleHap
```

### 项目配置

- **应用包名**：`ydy.App.EasyRandom`
- **元服务包名**：`com.atomicservice.5765880207854873613`
- **签名配置**：`build-profile.json5` → `app.signingConfigs`

---

## 📸 应用预览

### 主界面

<p align="center">
  <img src="./preview/页面展示1.jpg" width="30%" alt="主界面展示"/>
  <img src="./preview/页面展示2.jpg" width="30%" alt="主界面展示"/>
</p>

### 功能介绍

<p align="center">
  <img src="./preview/介绍图%20(1).png" width="30%" alt="功能介绍"/>
  <img src="./preview/介绍图%20(2).png" width="30%" alt="功能介绍"/>
</p>

### 暗夜模式 & 多语言

<p align="center">
  <img src="./preview/暗夜模式适配.jpg" width="30%" alt="暗夜模式"/>
  <img src="./preview/多语言适配[测试中].jpg" width="30%" alt="多语言"/>
</p>

### 服务卡片

<p align="center">
  <img src="./preview/卡片%20(1).png" width="22%" alt="硬币卡片"/>
  <img src="./preview/卡片%20(2).png" width="22%" alt="木鱼卡片"/>
  <img src="./preview/卡片%20(3).png" width="22%" alt="颜色卡片"/>
  <img src="./preview/卡片%20(4).png" width="22%" alt="转盘卡片"/>
</p>

---

## 🗺️ 路线图

### 近期计划

- [ ] 抽卡 RandomCards — 模拟抽卡体验
- [ ] 圣杯 — 传统掷筊占卜
- [ ] 64卦 — 完整易经六十四卦
- [ ] 单位转换 — 多类型单位换算
- [ ] 进制转换 — 二进制/八进制/十进制/十六进制
- [ ] 液态玻璃效果适配
- [ ] 震动反馈

### 长期规划

- [ ] 电子宠物模块（可能独立为单独应用）
- [ ] 折叠屏深度适配
- [ ] 手表端 (wearable) 完整适配
- [ ] PC 端 (2in1) 大屏适配
- [ ] 主页面 UI 重构

---

## 👥 开发团队

### 软件开发

| 角色 | 成员 |
|------|------|
| 主程 / 架构 | 闫东阳 |

### 美术设计

| 角色 | 成员 |
|------|------|
| UI / UX 设计 | 岑纯阳、宋婷婷、王浩铭、王璞 |

### 测试

| 角色 | 成员 |
|------|------|
| 质量保证 | Sallauknoe、金浩翔、阿拉灯神丁 |

---

## 📄 开源协议

本项目基于 [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) 开源。

---

## 🔗 相关链接

- **随易元服务**：应用内可跳转元服务版本（`com.atomicservice.5765880207854873613`）
- **隐私政策**：应用内设置页可查看
- **问题反馈**：应用内「设置 > 问题反馈」提交

---

<p align="center">
  <sub>Built with ❤️ using HarmonyOS ArkTS | © 2024-2025 闫东阳</sub>
</p>
