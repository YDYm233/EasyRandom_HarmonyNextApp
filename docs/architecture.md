# 随易 EasyRandom — 工程架构文档

> **版本**: 1.0.20 | **SDK**: HarmonyOS 6.1.0 (API 23) | **更新**: 2026-06-14

---

## 1. 项目概览

- **应用名**: 随易 (EasyRandom)
- **包名**: `ydy.App.EasyRandom`
- **类型**: 多设备随机决策工具（手机/平板/穿戴设备）
- **框架**: HarmonyOS ArkTS (ArkUI 声明式开发)
- **架构模式**: 分层模块化（common 共享层 + product 产品层）

---

## 2. 顶层目录结构

```
app_EasyRandom/
├── AppScope/              # 应用级配置与全局资源
│   ├── app.json5          #   bundleName / versionCode / icon / label
│   └── resources/         #   全局多语言、多分辨率资源 (base/en/ja/dark)
│
├── common/                # 共享层 — 3 个 HAR 静态共享包
│   ├── BasicUtils/        #   基础工具包 @ohos/basic-utils
│   ├── SystemUtils/       #   系统能力封装包 @ohos/system-utils
│   └── VitalUI/           #   自定义 UI 组件包 @ohos/vital-ui
│
├── product/               # 产品层 — 2 个 HAP 入口模块
│   ├── default/           #   手机/平板/2in1 主入口
│   └── wearable/          #   穿戴设备主入口
│
├── features/              # 预留 — 未来 FeatureKit 模块
├── docs/                  # 项目文档
├── preview/               # 预览配置
├── hvigor/                # 构建工具配置
├── build-profile.json5    # 工程级构建配置（签名 / products / modules）
├── oh-package.json5       # 工程级依赖
└── hvigorfile.ts          # 构建脚本入口
```

---

## 3. 模块依赖关系

```
┌───────────────────────────────────────────────────┐
│                    product 层 (HAP)                  │
│                                                     │
│   ┌───────────┐              ┌──────────────┐       │
│   │  default   │              │  wearable    │       │
│   │ phone/     │              │  wearable    │       │
│   │ tablet/    │              │              │       │
│   │ 2in1/car   │              │              │       │
│   └─────┬──────┘              └──────┬───────┘       │
│         │ import                     │ import        │
└─────────┼────────────────────────────┼───────────────┘
          │                            │
          ▼                            ▼
┌───────────────────────────────────────────────────┐
│                    common 层 (HAR)                   │
│                                                     │
│  ┌──────────┐   ┌──────────────┐   ┌────────────┐  │
│  │BasicUtils│   │ SystemUtils  │   │  VitalUI   │  │
│  │@ohos/    │   │ @ohos/       │   │ @ohos/     │  │
│  │basic-utils│  │ system-utils │   │ vital-ui   │  │
│  │          │◄──│              │   │            │  │
│  │ (无依赖) │   │ 依赖         │   │ (暂无依赖) │  │
│  └──────────┘   └──────────────┘   └────────────┘  │
│                                                     │
│  default ──→ BasicUtils, SystemUtils, VitalUI       │
│  wearable ──→ BasicUtils                             │
│  SystemUtils ──→ BasicUtils                          │
│  VitalUI ──→ (暂无依赖)                              │
└────────────────────────────────────────────────────┘
```

> **HAR 不支持传递依赖**：即使 SystemUtils 依赖 BasicUtils，消费方（如 default）仍需显式声明对 BasicUtils 的依赖。

---

## 4. 共享层详解 — common/

### 4.1 BasicUtils — 基础工具包

| 属性 | 值 |
|------|-----|
| **包名** | `@ohos/basic-utils` |
| **类型** | HAR |
| **设备** | default, tablet, 2in1, car, wearable (全设备) |
| **依赖** | 无 (最底层) |

**目录结构**:
```
common/BasicUtils/
├── Index.ets                    # 统一导出入口
├── oh-package.json5
├── build-profile.json5
└── src/main/ets/
    ├── utils/                   # 通用基础设施
    │   ├── Logger.ets           # 日志工具 (封装 hilog)
    │   ├── CommonConstants.ets  # 全局常量
    │   └── GlobalContext.ets    # 页面间数据桥接
    └── algo/                    # 自定义业务逻辑
        └── Math.ets             # Random / Randoms / ExColor / rgbaToHex8
```

**Index.ets 导出**:
```typescript
export { default as Logger } from './src/main/ets/utils/Logger'
export { default as CommonConstants } from './src/main/ets/utils/CommonConstants'
export { GlobalContext } from './src/main/ets/utils/GlobalContext'
export { Random, Randoms, ExColor, rgbaToHex8 } from './src/main/ets/algo/Math'
```

---

### 4.2 SystemUtils — 系统能力封装包

| 属性 | 值 |
|------|-----|
| **包名** | `@ohos/system-utils` |
| **类型** | HAR |
| **设备** | default, tablet, 2in1, car, wearable (全设备) |
| **依赖** | `@ohos/basic-utils` (VibratorManager 内部使用 Logger) |

**目录结构**:
```
common/SystemUtils/
├── Index.ets
├── oh-package.json5             # dependencies: { "@ohos/basic-utils": "file:../BasicUtils" }
├── build-profile.json5
└── src/main/ets/
    └── utils/
        ├── VibratorManager.ets  # 震动控制 (封装 @kit.SensorServiceKit)
        ├── BreakPointSystem.ets # 响应式断点系统 (封装 @ohos.mediaquery)
        └── ApiVersionUtil.ets   # API 版本兼容工具 (封装 @kit.BasicServicesKit)
```

**Index.ets 导出**:
```typescript
export { VibratorManager, VibrationUsage, HapticEffect } from './src/main/ets/utils/VibratorManager'
export { BreakpointSystem, Breakpoint, BreakpointOptions, BreakpointType, BreakpointState } from './src/main/ets/utils/BreakPointSystem'
export { ApiVersionUtil, ToolWithApiVersion } from './src/main/ets/utils/ApiVersionUtil'
```

---

### 4.3 VitalUI — 自定义 UI 组件包

| 属性 | 值 |
|------|-----|
| **包名** | `@ohos/vital-ui` |
| **类型** | HAR |
| **设备** | default, tablet, 2in1, car (暂不含 wearable) |
| **依赖** | 暂无 |

**目录结构**:
```
common/VitalUI/
├── Index.ets
├── oh-package.json5
├── build-profile.json5
├── CHANGELOG.md
└── src/main/
    ├── ets/
    │   ├── components/
    │   │   ├── ColorPickerComponent/
    │   │   │   └── ColorPickerDialog.ets   # 颜色选择器 (自含 HSL/RGB 转换)
    │   │   └── chart/
    │   │       ├── PieChart.ets            # 饼图
    │   │       ├── PieChart_V3.ets         # 饼图 V3
    │   │       ├── QuarterRoseChart.ets    # 季度玫瑰图
    │   │       ├── RadarChart.ets          # 雷达图
    │   │       └── RoseChart.ets           # 玫瑰图
    │   └── Demo/                           # 组件演示页
    │       ├── Demo.ets
    │       ├── DemoRadarChart.ets
    │       ├── DemoRoseChart.ets
    │       └── MainPage.ets
    └── resources/
        ├── base/
        ├── en_US/
        └── zh_CN/
```

**Index.ets 导出**:
```typescript
// UI 交互组件
export { ColorPickerView, ColorPickerButton } from './src/main/ets/components/ColorPickerComponent/ColorPickerDialog'
// 图表组件
export { PieChartData, Chart as PieChartBase, PieChart } from './src/main/ets/components/chart/PieChart'
export { PieChartData as PieChartData_V3, Chart as PieChartBaseV3, PieChart_V3 } from './src/main/ets/components/chart/PieChart_V3'
export { ChartData as RoseData, Chart as RoseBase, RoseChartClass, QRoseChart } from './src/main/ets/components/chart/QuarterRoseChart'
export { ChartData as RadarData, ChartClass, RadarChartClass, RoseChart as RadarRoseChart } from './src/main/ets/components/chart/RadarChart'
export { ChartData as RoseChartData, Chart as RoseChartBase, RoseChartClass as RoseChartCore, RoseChart } from './src/main/ets/components/chart/RoseChart'
```

---

## 5. 产品层详解 — product/

### 5.1 default — 手机/平板主入口

| 属性 | 值 |
|------|-----|
| **模块名** | `default` |
| **类型** | entry (HAP) |
| **设备** | phone, tablet, 2in1, car |
| **主 Ability** | `EntryAbility` |
| **卡片 Ability** | `DefaultFormAbility` |
| **依赖** | `@ohos/basic-utils`, `@ohos/system-utils`, `@ohos/vital-ui` |
| **权限** | `ohos.permission.INTERNET`, `ohos.permission.VIBRATE` |

**目录结构**:
```
product/default/src/main/ets/
├── entryability/               # 入口 Ability 生命周期
│   └── EntryAbility.ets
├── entrybackupability/         # 备份 Ability
├── defaultformability/         # 服务卡片 Ability
│   └── DefaultFormAbility.ets
├── pages/                      # 主导航页面
│   ├── IndexPage/              #   首页 Tab 容器
│   │   ├── Index.ets           #     TabBar 入口
│   │   ├── HdsMainPage.ets     #     HDS 设计规范主页
│   │   └── LegacyMainPage.ets  #     旧版主页
│   ├── RandomPage.ets          #   随机功能 Tab
│   ├── RollPage/               #   转盘功能
│   │   ├── RollWheelPage.ets   #     转盘主页面
│   │   ├── RollWheel.ets       #     转盘组件
│   │   ├── RollEditor.ets      #     编辑器
│   │   ├── RollDetailEditor.ets#     详情编辑
│   │   ├── RollDataManager.ets #     转盘数据持久化
│   │   └── RollWheelCardAddSheet.ets
│   ├── AnswerPage.ets          #   答案之书
│   ├── CardsPage.ets           #   卡片展示 Tab
│   ├── ToolsPage.ets           #   工具 Tab
│   ├── MorePage.ets            #   更多 Tab
│   └── SettingPage/            #   设置页面组 (Navigation 导航)
│       ├── SettingPage.ets     #     设置主页
│       ├── Options.ets         #     选项页
│       ├── MoreOpt.ets         #     更多选项
│       ├── AboutUs.ets         #     关于我们
│       ├── ContactUs.ets       #     联系我们
│       ├── CopyRight.ets       #     版权声明
│       ├── PrivacyPolicy.ets   #     隐私政策
│       └── AnnouncementPage.ets#     公告页
├── sub_pages/                  # 功能子页面 (router 跳转)
│   ├── a_standard/             #   A标抽取
│   ├── answer_book/            #   答案之书
│   ├── blessing_muyu/          #   电子木鱼
│   ├── devine_bagua/           #   八卦占卜
│   ├── flip_coin/              #   抛硬币
│   ├── flip_dices/             #   掷骰子
│   ├── honest_or_challenge/    #   真心话大冒险
│   ├── random_abcd/            #   ABCD 随机
│   ├── random_colors/          #   随机颜色
│   ├── random_foods/           #   随机美食
│   ├── random_names/           #   随机抽签
│   ├── random_numbers/         #   随机数字
│   ├── random_places/          #   随机旅行
│   ├── roll_wheel/             #   转盘子页面
│   ├── text_marquee/           #   文字跑马灯
│   └── trans_qr/               #   转码二维码
├── form_cards/                 # 服务卡片 (桌面小部件)
│   ├── ABCDCard.ets
│   ├── BaGuaCard.ets
│   ├── BlessingMuyuCard.ets
│   ├── FlipCoinCard.ets
│   ├── RandomColorsCard.ets
│   ├── RollDiceCard.ets
│   └── RollWheelCard.ets
├── form_display/               # 卡片预览展示页
│   ├── ABCDCardDisplay.ets
│   ├── BaGuaCardDisplay.ets
│   ├── BlessingMuyuCardDisplay.ets
│   ├── FlipCoinCardDisplay.ets
│   ├── RandomColorsCardDisplay.ets
│   ├── RollDiceCardDisplay.ets
│   └── RollWheelCardDisplay.ets
├── static_datas/               # 静态题库数据
│   ├── answers.ets             #   答案之书题库
│   ├── challenges.ets          #   真心话大冒险题库
│   ├── foods.ets               #   美食推荐库
│   ├── names.ets               #   抽签名单库
│   └── places.ets              #   旅行目的库
├── utils/                      # 模块内工具
│   └── ApiVersionUtil.ets      #   (待迁移至 SystemUtils)
└── design_privew/              # 设计预览 (拼写待修正)
```

**资源目录**:
```
product/default/src/main/resources/
├── base/element/               # 默认中文资源
├── base/media/                 # 默认图片资源
├── dark/element/               # 暗夜模式颜色覆盖
├── en/element/                 # 英文资源
└── rawfile/                    # 原始文件 (privacypolicy.html 等)
```

---

### 5.2 wearable — 穿戴设备主入口

| 属性 | 值 |
|------|-----|
| **模块名** | `wearable` |
| **类型** | entry (HAP) |
| **设备** | wearable |
| **主 Ability** | `WearableAbility` |
| **依赖** | `@ohos/basic-utils` |
| **权限** | `ohos.permission.VIBRATE` |

**目录结构**:
```
product/wearable/src/main/ets/
├── wearableability/            # 穿戴入口 Ability
│   └── WearableAbility.ets
├── wearablebackupability/      # 备份 Ability
├── pages/                      # 主页面
│   └── Index.ets               #   穿戴首页
├── sub_pages/                  # 穿戴功能子页面
│   ├── WearFlipCoin.ets        #   抛硬币
│   ├── WearRollDices.ets       #   掷骰子
│   ├── WearRandomABCD.ets      #   ABCD 随机
│   ├── WearRandomColors.ets    #   随机颜色
│   ├── WearRollWheel.ets       #   转盘
│   ├── WearBlessingMuyu.ets    #   电子木鱼
│   ├── WearDevineBaGua.ets     #   八卦占卜
│   ├── WearTruthOrDare.ets     #   真心话大冒险
│   ├── WearNavPanelRound.ets   #   圆形导航面板
│   └── WearNavPanelSquare.ets  #   方形导航面板
└── utils/                      # 穿戴专用工具
    ├── WearRollDataManager.ets #   转盘数据管理 (轻量版, 无持久化)
    ├── WearScreenUtil.ets      #   穿戴屏幕适配
    └── WearTruthOrDareData.ets #   真心话大冒险数据
```

---

## 6. 分层设计原则

### 6.1 分层标准

| 层 | 目录 | 职责 | 约束 |
|----|------|------|------|
| **应用全局** | `AppScope/` | 应用级配置与全局资源 | 仅 1 份，所有 HAP 共享 |
| **共享层** | `common/` | 跨 HAP 复用的工具/组件 | HAR 类型，无 Ability，无页面路由 |
| **产品层** | `product/` | 各设备形态的入口与业务页面 | HAP 类型，依赖共享层，可含设备特有逻辑 |
| **功能层** | `features/` | (预留) 领域专属 FeatureKit | 独立 HAR，按领域边界拆分 |

### 6.2 共享包分类原则

| 包 | 分类依据 | 特征 |
|----|----------|------|
| **BasicUtils** | 通用基础设施 + 业务算法 | 无系统 API 调用 (utils/)，有自定义算法 (algo/) |
| **SystemUtils** | 系统能力二次封装 | 调用 `@kit.*` / `@ohos.*`，无 UI 渲染 |
| **VitalUI** | 自定义 UI 组件 | 含 `@Component`，有 UI 渲染，自含工具函数 |

### 6.3 依赖方向

```
product/*  ──→  common/*  ──→  (无更底层)
                SystemUtils ──→ BasicUtils
                VitalUI ──→ (暂无，按需声明)
                BasicUtils ──→ (无依赖)
```

**规则**: 依赖只能从上层指向下层，禁止反向依赖。common 层内部，BasicUtils 是最底层，SystemUtils 可依赖 BasicUtils，VitalUI 暂不依赖其他包。

---

## 7. 数据流与关键机制

### 7.1 服务卡片 ↔ 应用同步

```
[桌面卡片] ──click──→ DefaultFormAbility.onFormEvent()
                           │
                           ▼
                     Preferences.write() ──flush──→ 持久存储
                                                    │
[打开应用] ──onPageShow()──→ Preferences.read() ◄──┘
                                │
                                ▼
                          @State 更新 → UI 刷新
```

### 7.2 响应式布局

```
BreakpointSystem (SystemUtils)
    │
    ├── xs: 0px      (极小屏)
    ├── sm: 320px    (手机竖屏)
    ├── md: 600px    (手机横屏/平板竖屏)
    └── lg: 840px    (平板横屏/2in1)
    │
    ▼
页面通过 @State currentBreakpoint: BreakpointState<string> 订阅
布局通过 GridRow/GridCol span/offset 响应
```

### 7.3 状态管理策略

| 场景 | 方案 | 示例 |
|------|------|------|
| 组件内部状态 | `@State` | 点击计数、当前索引 |
| 父→子单向 | `@Prop` | 子组件配置项 |
| 父↔子双向 | `@Link` | 转盘编辑数据 |
| 跨层级共享 | `@Provide/@Consume` | Navigation NavPathStack |
| 全局持久 | `Preferences + @StorageLink` | 主题模式、隐私协议 |
| 页面间临时 | `GlobalContext` | 跳转标记 (isJumpPrivacy) |

---

## 8. 模块配置速查

### 8.1 build-profile.json5 模块注册

```json5
"modules": [
  { "name": "default",     "srcPath": "./product/default" },
  { "name": "wearable",    "srcPath": "./product/wearable" },
  { "name": "BasicUtils",  "srcPath": "./common/BasicUtils" },
  { "name": "SystemUtils", "srcPath": "./common/SystemUtils" },
  { "name": "VitalUI",     "srcPath": "./common/VitalUI" }
]
```

### 8.2 包名与 import 映射

| 模块 | 包名 (oh-package.json5) | import 示例 |
|------|-------------------------|-------------|
| BasicUtils | `@ohos/basic-utils` | `import { Random, Logger } from '@ohos/basic-utils'` |
| SystemUtils | `@ohos/system-utils` | `import { VibratorManager, BreakpointSystem } from '@ohos/system-utils'` |
| VitalUI | `@ohos/vital-ui` | `import { PieChart_V3, ColorPickerButton } from '@ohos/vital-ui'` |

### 8.3 设备类型矩阵

| 模块 | phone | tablet | 2in1 | car | wearable |
|------|:-----:|:------:|:----:|:---:|:--------:|
| default (HAP) | ✅ | ✅ | ✅ | ✅ | ❌ |
| wearable (HAP) | ❌ | ❌ | ❌ | ❌ | ✅ |
| BasicUtils (HAR) | ✅ | ✅ | ✅ | ✅ | ✅ |
| SystemUtils (HAR) | ✅ | ✅ | ✅ | ✅ | ✅ |
| VitalUI (HAR) | ✅ | ✅ | ✅ | ✅ | ❌ |

---

## 9. 待优化项

| 项目 | 当前状态 | 建议 |
|------|----------|------|
| `design_privew/` | 拼写错误 | 重命名为 `design_preview/` |
| `ApiVersionUtil.ets` (default/utils/) | 与 SystemUtils 重复 | 迁移至 SystemUtils，删除 default 内副本 |
| VitalUI 不含 wearable | 穿戴设备缺少图表组件 | 待穿戴设备支持 Canvas/TextInput 后扩展 |
| `features/` 目录 | 空目录预留 | 未来新增领域专属 FeatureKit 时启用 |
| RollItem/Roll 模型 | default/wearable 各自定义 | 差异增大时可抽取共享模型包 |

---

<p align="center">
  <sub>Built with HarmonyOS ArkTS | © 2024-2026 闫东阳</sub>
</p>
