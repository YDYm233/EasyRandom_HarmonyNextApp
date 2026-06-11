# ⌚ 随易 EasyRandom — 手表端页面实现规格

> 文档版本：v1.3 | 日期：2026-06-11 | P0 三功能 + 负一屏导航 + 主入口页面 + 后续扩展占位

---

## 🚫 设备约束声明（v1.3 新增）

> **本文档仅适用于标准 Wearable（智能手表），不适用于 Lite Wearable（轻量级智能穿戴）。**

### 设备类型对比

| 维度 | **标准 Wearable（智能手表）** | ~~Lite Wearable（轻量级）~~ |
|------|--------------------------------|---------------------------|
| **系统** | HarmonyOS NEXT（API 10+） | HarmoneyOS 轻量（API 8-9） |
| **开发模型** | Stage 模型（ArkTS） | FA 模型（JS/HML/CSS） |
| **UI 框架** | ArkUI（声明式） | JS UI（类 Vue） |
| **设备示例** | Watch 3/4/Ultimate/GT 4 | GT 5 Pro / GT Runner |
| **本项目管理** | ✅ **支持** | ❌ **不支持** |

### 标准 Wearable 开发约束（华为官方）

根据华为开发者联盟官方文档，标准 Wearable（智能手表）应用开发存在以下约束：

| 约束类别 | 限制内容 | 说明 |
|---------|---------|------|
| **UI 组件** | 不支持 `Tabs` / `TabContent` | 用 `Swiper` / `ArcSwiper` 替代 |
| **路由** | 不支持 `router.pushUrl()` | 零路由，单 Entry 页面 + Swiper 切页 |
| **页面数量** | Swiper 内子页面 ≤ 10 | 超过需分页或动态加载 |
| **后台任务** | 受限，不支持长时后台 | 仅支持短时任务（≤ 3 分钟） |
| **动画时长** | 建议 ≤ 1000ms | 过长会导致帧率下降 |
| **内存** | 通常 ≤ 2GB RAM | 避免大图、大列表 |
| **存储** | 应用沙箱受限 | 不依赖外部存储 |
| **传感器** | 取决于设备型号 | 需运行时检测 `@ohos.sensor` 可用性 |
| **振动** | `VibratorManager` 需权限声明 | `module.json5` 中声明 `ohos.permission.VIBRATE` |
| **网络** | 受限，依赖手机代理 | 穿戴设备通常无独立网络 |
| **通知** | 需通过手机侧推送 | 穿戴设备通知能力受限 |

### 本项目适配策略

| 策略 | 实现方式 |
|------|---------|
| 零路由 | `Index.ets` 唯一 Entry，Swiper 切页 |
| 无 Tabs | `ArcSwiper`（圆形屏）/ `Swiper`（方形屏）横向切页 |
| 动画 ≤ 1000ms | `animateTo({ duration: 1000 })` 上限 |
| 功耗优化 | `aboutToDisappear()` 释放 Canvas/定时器 |
| 形状适配 | `WearScreenUtil.isRoundScreen()` 检测一次，Token 自动适配 |

---

## 1. 概述

本文档描述随易 EasyRandom 手表端（product/wearable）中 **P0 优先级三个功能页面** 的详细实现规格，涵盖组件结构、状态管理、交互流程、圆/方屏适配、数据结构与边界处理。

**适用范围**：本文档供工程师（寇豆码）按规格实现代码使用。架构级决策（Token 系统、容器分叉、功耗策略）见 [wearable-plan.md](./wearable-plan.md)。

### 1.1 功能与文件对应

| 优先级 | 功能 | 组件 | 文件路径 | 当前状态 |
|:------:|------|------|---------|:------:|
| P0 | 主入口页面 | `Index` | `product/wearable/src/main/ets/pages/Index.ets` | 📋 规格完毕，待实现 |
| P0 | 负一屏导航 | `WearNavPanel` | `product/wearable/src/main/ets/sub_pages/WearNavPanel.ets` | 📋 规格完毕，待实现 |
| P0 | 幸运转盘 | `WearRollWheel` | `product/wearable/src/main/ets/sub_pages/WearRollWheel.ets` | 📋 规格完毕，待实现 |
| P0 | 祝福木鱼 | `WearBlessingMuyu` | `product/wearable/src/main/ets/sub_pages/WearBlessingMuyu.ets` | 📋 规格完毕，待实现 |
| P0 | 真心话大冒险 | `WearTruthOrDare` | `product/wearable/src/main/ets/sub_pages/WearTruthOrDare.ets` | 📋 规格完毕，待实现 |

### 1.2 通用依赖

所有组件统一依赖以下工具模块，避免重复引用：

```typescript
// 通用 import（每个组件按需使用）
import { Random } from '@ohos/common';                        // 随机数
import WearScreenUtil from '../utils/WearScreenUtil';         // 形状检测 + Token
import { VibratorManager } from '@ohos/vibratorutil';        // 震动反馈（部分组件）
import { hilog } from '@kit.PerformanceAnalysisKit';          // 调试日志（部分组件）
```

### 1.3 通用适配原则

所有组件遵循 [wearable-plan.md §3](./wearable-plan.md#3-适配架构) 的四层模型中的**第 3 层（内容层）**原则：

- **容器分叉交给 Index.ets**：组件内部不需要判断 `isRound()` 以决定用 ArcSwiper 还是 Swiper（那由 Index.ets 负责）
- **组件内部仅做微适配**：按钮类型（ArcButton vs Button）、字号/间距等通过 WearScreenUtil Token 解决
- **组件不感知父容器**：无论被 ArcSwiper 还是 Swiper 包裹，组件行为一致
- **aboutToDisappear 释放资源**：Canvas 上下文、动画、定时器必须在此生命周期中清理

---

## 2. 主入口页面（Index.ets）

### 2.1 概览

| 维度 | 说明 |
|------|------|
| **文件路径** | `product/wearable/src/main/ets/pages/Index.ets` |
| **装饰器** | `@Entry` + `@Component` |
| **设计模型** | [wearable-plan.md §3](./wearable-plan.md#3-适配架构) 四层模型中「第 2 层：容器层」的**唯一分叉点** |
| **核心职责** | 检测屏幕形状 → 选择容器类型 → 注册全部页面（含负一屏） → 配置默认起始页 → 配置指示器与表冠交互 |
| **关键约束** | **整个 wearable 模块唯一的 `@Entry` 页面**，零路由、零页面跳转 |
| **默认起始页** | **Swiper index = 1 → 幸运转盘**（index 0 为负一屏，左侧滑动进入） |

### 2.2 页面结构

```
┌──────────────────────────────────────────────────────┐
│                    Index.ets                          │
│                                                      │
│  aboutToAppear()                                     │
│    └── isRound = WearScreenUtil.isRoundScreen()      │
│                                                      │
│  build()                                             │
│    ├── if (this.isRound)                             │
│    │     └── buildRoundLayout()     ← ArcSwiper      │
│    │           .index(1)             ← 默认幸运转盘   │
│    └── else                                          │
│          └── buildSquareLayout()    ← Swiper         │
│                .index(1)             ← 默认幸运转盘   │
│                                                      │
│  buildAllPages()  ← 全部页面（共用的内容 Builder）    │
│    ├── [0] WearNavPanel()      ← 负一屏（左滑进入）  │
│    ├── [1] WearRollWheel()     P0 幸运转盘（默认）    │
│    ├── [2] WearBlessingMuyu()  P0 祝福木鱼           │
│    ├── [3] WearTruthOrDare()   P0 真心话大冒险       │
│    ├── [4] WearRollDices()     P1                    │
│    ├── [5] WearFlipCoin()      P1                    │
│    ├── [6] WearRandomABCD()    P1                    │
│    ├── [7] WearDevineBaGua()   P2                    │
│    └── [8] WearRandomColors()  P2                    │
│                                                      │
│  导航回调：onNavigate(index) → controller.changeIndex │
│  (由 WearNavPanel 调用，Index.ets 执行跳转)          │
└──────────────────────────────────────────────────────┘
```

**交互模型**：

```
 ←── 左滑                     右滑 ──→
┌───────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│ 负一屏 │← │ 幸运转盘 │→│ 祝福木鱼 │→│ 真心话  │→ ...
│ [0]   │  │  [1] ★  │  │  [2]    │  │  [3]    │
└───────┘  └─────────┘  └─────────┘  └─────────┘
  ↑ 导航页     ↑ 默认进入             ↑ ...
  快速跳转任意页面
```

### 2.3 架构决策：为什么是 Index.ets 而非子组件自己做分叉

| 方案 | 描述 | 判定 |
|------|------|:----:|
| A：每个子组件内 `if(isRound)` | 每个组件自己判断形状，自己选 ArcXxx/Swiper | ❌ 重复代码 ×9，子组件职责过重 |
| **B：Index.ets 统一分叉** | Index.ets 判断一次形状，选择 ArcSwiper 或 Swiper 作为所有子组件的容器 | ✅ 零重复，子组件零感知 |

**铁律**：子组件内部**永远不出现 `isRound()` 判断**。形状差异通过 WearScreenUtil Token 的数值差异自动消解。

### 2.4 状态管理

| 状态 | 类型 | 来源 | 说明 |
|------|------|------|------|
| `isRound` | `boolean` | `aboutToAppear()` 中调用 `WearScreenUtil.isRoundScreen()` | 决定走圆形屏还是方形屏布局分支 |
| `NAV_INDEX` | `const 0` | 硬编码常量 | 负一屏的 Swiper 索引 |
| `DEFAULT_INDEX` | `const 1` | 硬编码常量 | 默认起始页（幸运转盘）的 Swiper 索引 |

**不需要的状态**：

| 不需要 | 原因 |
|--------|------|
| ❌ `taskId` / 后台任务 ID | 无后台任务需求 |
| ❌ 路由参数 | 零路由，不需要 `router.getParams()` |
| ❌ 生命周期标志 | 用原生 `aboutToAppear` / `aboutToDisappear` 已足够 |

**页面索引常量**（负一屏跳转依据）：

```typescript
// 定义在 Index.ets 顶部，供 WearNavPanel 的 onNavigate 回调引用
const PAGE_INDEX = {
  NAV: 0,              // 负一屏
  ROLL_WHEEL: 1,       // 幸运转盘（默认起始页）
  MUYU: 2,             // 祝福木鱼
  TRUTH_DARE: 3,       // 真心话大冒险
  ROLL_DICES: 4,       // 掷骰子
  FLIP_COIN: 5,        // 丢硬币
  RANDOM_ABCD: 6,      // ABCD 选择
  DEVINE_BAGUA: 7,     // 八卦占卜
  RANDOM_COLORS: 8,    // 随机颜色
  // 未来扩展（Swiper 上限约 10）：
  // ANNOUNCEMENT: 9,  // 公告
  // SETTINGS: 10,     // 设置
} as const;
```

**导航回调设计**（Index.ets → WearNavPanel）：

```
                    ┌─────────────────────────┐
                    │       Index.ets          │
                    │                          │
                    │  onNavigate(target) {    │
                    │    arcController         │
                    │      .changeIndex(target)│ ←── WearNavPanel 调用此回调
                    │  }                       │
                    │       ↑                  │
                    │       │ callback         │
                    │  ┌────┴──────────────┐   │
                    │  │   WearNavPanel    │   │
                    │  │                    │   │
                    │  │  点击「祝福木鱼」   │   │
                    │  │  → onNavigate(2)   │   │
                    │  └───────────────────┘   │
                    └─────────────────────────┘
```

> **为什么不用 @Provide/@Consume？** ArkUI 中 `@Provide` 对引用类型（如 Controller）支持有限，且 Builder 传参更直观。回调模式是最小侵入方案：负一屏只负责「声明想跳哪里」，Index.ets 负责「执行跳转」。

### 2.5 容器层分叉：完整 Build 逻辑

#### 2.5.1 圆形屏 → ArcSwiper

```
条件：this.isRound === true
├── 容器：ArcSwiper(controller)
│   ├── .index(1)                       ← 默认显示幸运转盘（index 1）
│   ├── .indicator(ArcDotIndicator)     ← 弧形圆点，自动贴合圆弧边缘
│   ├── .vertical(false)                ← 横向排列（左右滑动切功能）
│   ├── .duration(300)                  ← 切换动画 300ms
│   ├── .digitalCrownSensitivity(MEDIUM) ← 表冠旋转切换
│   ├── .effectMode(EdgeEffect.Spring)  ← 边界弹簧效果
│   └── .disableSwipe(false)            ← 允许手指滑动
└── 子组件：this.buildAllPages()
```

**ArcDotIndicator 配置**：

| 属性 | 值 | 说明 |
|------|-----|------|
| `itemColor` | `0x66FFFFFF` | 未激活点：半透白色 |
| `selectedItemColor` | `0xFFD4A017` | 激活点：金色 |

#### 2.5.2 方形屏 → Swiper

```
条件：this.isRound === false
├── 容器：Swiper()
│   ├── .index(1)               ← 默认显示幸运转盘（index 1）
│   ├── .loop(false)            ← ⚠️ 不循环（负一屏在最左侧不应循环到最右侧）
│   ├── .indicator(DotIndicator)← 标准矩形圆点指示器
│   ├── .itemSpace(0)           ← 页面间距为 0（全屏切页）
│   └── .duration(300)          ← 切换动画 300ms
└── 子组件：this.buildAllPages()
```

**DotIndicator 配置**：

| 属性 | 值 | 说明 |
|------|-----|------|
| `color` | `0x33FFFFFF` | 未激活点：极浅半透白 |
| `selectedColor` | `0xFFD4A017` | 激活点：金色 |

### 2.6 子组件注册（buildAllPages）

`@Builder buildAllPages()` 是 Index.ets 中唯一一处**列出全部页面**的地方。**Swiper 子元素顺序 = 页面排列顺序**（从左到右）：

```
buildAllPages() {
  [0] WearNavPanel({ onNavigate: this.onNavigate })  // 负一屏（左滑进入）
  [1] WearRollWheel()       // P0: 幸运转盘 ★ 默认起始页
  [2] WearBlessingMuyu()    // P0: 祝福木鱼
  [3] WearTruthOrDare()     // P0: 真心话大冒险
  [4] WearRollDices()       // P1: 掷骰子
  [5] WearFlipCoin()        // P1: 丢硬币
  [6] WearRandomABCD()      // P1: ABCD 选择
  [7] WearDevineBaGua()     // P2: 八卦占卜
  [8] WearRandomColors()    // P2: 随机颜色
}
```

**`onNavigate` 回调方法**（Index.ets 中实现）：

```typescript
// Index.ets 的成员方法
private onNavigate = (targetIndex: number): void => {
  if (this.isRound) {
    this.arcController.changeIndex(targetIndex);
  } else {
    this.swiperController.changeIndex(targetIndex);
  }
}
```

> ⚠️ **回调必须用箭头函数**（`= (targetIndex) => {}`），确保 `this` 指向 Index 组件实例。普通方法 `onNavigate(targetIndex)` 在作为回调传递时 `this` 会丢失。

> ⚠️ **渐进实现策略**：初期 Index.ets 只 import 已实现的组件。随着组件逐个开发，逐步加入 import + buildAllPages。

**页面顺序约定**：

| 位置 | 页面 | 原因 |
|:----:|------|------|
| [0] | 负一屏导航 | 最左侧，左滑进入，符合手机桌面负一屏的肌肉记忆 |
| [1] | 幸运转盘 ★ | 默认起始页，用户打开 App 第一眼看到 |
| [2]~[3] | P0 功能 | 紧随默认页之后，右滑即达 |
| [4]~[6] | P1 功能 | 再往右 |
| [7]~[8] | P2 功能 | 最右侧 |

### 2.7 完整骨架代码

```typescript
// product/wearable/src/main/ets/pages/Index.ets
import { ArcSwiper, ArcDotIndicator, ArcSwiperController } from '@kit.ArkUI';
import WearScreenUtil from '../utils/WearScreenUtil';

// ═══════════════════════════════════════════════════
//  页面索引常量（供负一屏导航 + buildAllPages 引用）
// ═══════════════════════════════════════════════════
const PAGE_INDEX = {
  NAV: 0,
  ROLL_WHEEL: 1,
  MUYU: 2,
  TRUTH_DARE: 3,
  ROLL_DICES: 4,
  FLIP_COIN: 5,
  RANDOM_ABCD: 6,
  DEVINE_BAGUA: 7,
  RANDOM_COLORS: 8,
} as const;

// ═══════════════════════════════════════════════════
//  子组件 import（随开发逐步加入）
// ═══════════════════════════════════════════════════
import { WearNavPanel } from '../sub_pages/WearNavPanel';
import { WearRollWheel } from '../sub_pages/WearRollWheel';
import { WearBlessingMuyu } from '../sub_pages/WearBlessingMuyu';
import { WearTruthOrDare } from '../sub_pages/WearTruthOrDare';
import { WearRollDices } from '../sub_pages/WearRollDices';
import { WearFlipCoin } from '../sub_pages/WearFlipCoin';
import { WearRandomABCD } from '../sub_pages/WearRandomABCD';
import { WearDevineBaGua } from '../sub_pages/WearDevineBaGua';
import { WearRandomColors } from '../sub_pages/WearRandomColors';

/**
 * 手表端主页 — 圆/方屏双适配 + 负一屏导航
 *
 * 四层适配模型中「第 2 层：容器层」的唯一分叉点。
 * 圆形屏 → ArcSwiper（弧形轮播 + 表冠交互）
 * 方形屏 → Swiper（标准线性轮播）
 *
 * 页面排列：[0]负一屏 ← [1]幸运转盘★(默认) → [2]木鱼 → [3]真心话 → ...
 * API < 18 的设备默认走方形屏路线。
 */
@Entry
@Component
struct Index {
  @State isRound: boolean = false;

  // ArcSwiper 控制器（仅圆形屏使用）
  private arcController: ArcSwiperController = new ArcSwiperController();
  // Swiper 控制器（仅方形屏使用，用于负一屏导航跳转）
  private swiperController: SwiperController = new SwiperController();

  // ═══════════ 圆形屏 ArcDotIndicator ═══════════
  private arcIndicator: ArcDotIndicator = new ArcDotIndicator()
    .itemColor(0x66FFFFFF)                // 未激活：半透白
    .selectedItemColor(0xFFD4A017);       // 激活：金色

  aboutToAppear(): void {
    this.isRound = WearScreenUtil.isRoundScreen();
  }

  build() {
    if (this.isRound) {
      this.buildRoundLayout();
    } else {
      this.buildSquareLayout();
    }
  }

  // ═══════════════════════════════════════════════
  //  导航回调（传给 WearNavPanel，供其跳转页面）
  //  用箭头函数确保 this 指向 Index 组件实例
  // ═══════════════════════════════════════════════
  private onNavigate = (targetIndex: number): void => {
    if (this.isRound) {
      this.arcController.changeIndex(targetIndex);
    } else {
      this.swiperController.changeIndex(targetIndex);
    }
  };

  // ═══════════════════════════════════════════════
  //  圆形屏布局（ArcSwiper）
  // ═══════════════════════════════════════════════
  @Builder
  buildRoundLayout() {
    ArcSwiper(this.arcController) {
      this.buildAllPages();
    }
    .width('100%')
    .height('100%')
    .index(PAGE_INDEX.ROLL_WHEEL)          // 默认显示幸运转盘
    .indicator(this.arcIndicator)
    .vertical(false)
    .duration(300)
    .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
    .effectMode(EdgeEffect.Spring)
    .disableSwipe(false)
  }

  // ═══════════════════════════════════════════════
  //  方形屏布局（标准 Swiper）
  // ═══════════════════════════════════════════════
  @Builder
  buildSquareLayout() {
    Swiper(this.swiperController) {
      this.buildAllPages();
    }
    .loop(false)                             // ⚠️ 不循环（负一屏不应循环到最右侧）
    .index(PAGE_INDEX.ROLL_WHEEL)            // 默认显示幸运转盘
    .indicator(
      new DotIndicator()
        .color(0x33FFFFFF)
        .selectedColor(0xFFD4A017)
    )
    .itemSpace(0)
    .duration(300)
  }

  // ═══════════════════════════════════════════════
  //  共用的 9 个页面（按 Swiper 从左到右排列）
  // ═══════════════════════════════════════════════
  @Builder
  buildAllPages() {
    WearNavPanel({ onNavigate: this.onNavigate })   // [0] 负一屏
    WearRollWheel()        // [1] P0: 幸运转盘 ★ 默认
    WearBlessingMuyu()     // [2] P0: 祝福木鱼
    WearTruthOrDare()      // [3] P0: 真心话大冒险
    WearRollDices()        // [4] P1: 掷骰子
    WearFlipCoin()         // [5] P1: 丢硬币
    WearRandomABCD()       // [6] P1: ABCD 选择
    WearDevineBaGua()      // [7] P2: 八卦占卜
    WearRandomColors()     // [8] P2: 随机颜色
  }
}
```

### 2.8 边界处理

| # | 场景 | 处理方式 |
|---|------|---------|
| 1 | `isRoundScreen()` 在 API < 18 时抛异常 | `WearScreenUtil` 内部 try-catch，返回 `false`，自动降级为方形屏 |
| 2 | 子组件未实现时编译报错 | 渐进策略：未实现的组件暂不 import，用占位 `// TODO` 标记 |
| 3 | Swiper 内子组件数量 >10 | 当前 9 个，<10 限制，无需处理；未来新增公告/设置后刚好 10 个上限 |
| 4 | 快速滑动导致 ArcSwiper 动画冲突 | `duration(300)` 足够短，`EdgeEffect.Spring` 吸收边界动能 |
| 5 | 方形屏设备没有 `CrownSensitivity` | 该属性仅在 ArcSwiper 分支使用，方形屏代码路径不涉及 |
| 6 | 负一屏导航回已销毁的页面 | Swiper 懒加载机制自动处理（页面离开视口后可能被回收，返回时重建） |
| 7 | 从负一屏跳转到当前已在显示的页面 | `changeIndex` 不会重复触发 `onChange`（Swiper 内部去重） |
| 8 | Swiper 不循环后左右边界的交互 | 方形屏 `.loop(false)` → 左边界无法继续左滑，右边界无法继续右滑（符合预期） |

### 2.9 与 wearable-plan.md 的关系

| 维度 | [wearable-plan.md](./wearable-plan.md) | 本文档 §2 |
|------|--------------------------------------|-----------|
| 关注点 | 架构层面（为什么分叉、四层模型） | 实现层面（怎么分叉、具体配置值） |
| 粒度 | 设计决策 + Token 系统 | 完整骨架代码 + 每行注释 |
| 适用方 | 架构师（高见远）审阅 | 工程师（寇豆码）直接照写 |

---

## 3. 负一屏导航（WearNavPanel）

### 3.1 概览

| 维度 | 说明 |
|------|------|
| **文件路径** | `product/wearable/src/main/ets/sub_pages/WearNavPanel.ets` |
| **装饰器** | `@Component`（非 @Entry，作为 Swiper 子页面） |
| **核心职责** | 展示全部功能页的快捷入口网格 + 未来扩展入口占位（公告/设置/拉取数据） |
| **交互模式** | 接收 `onNavigate` 回调 → 用户点击任意入口 → 回调传入目标页面索引 → Index.ets 执行 `controller.changeIndex()` |
| **特殊地位** | Swiper 唯一一个不直接执行随机逻辑的页面，而是作为「交通枢纽」存在 |

### 3.2 页面结构

```
┌──────────────────────────────────┐
│          负一屏 (WearNavPanel)     │
│                                  │
│  ┌──────────────────────────┐   │
│  │    功能导航区（网格）      │   │
│  │  ┌────────┐ ┌────────┐   │   │
│  │  │ 🎡     │ │ 🪵     │   │   │
│  │  │幸运转盘│ │祝福木鱼│   │   │
│  │  └────────┘ └────────┘   │   │
│  │  ┌────────┐ ┌────────┐   │   │
│  │  │ 💬     │ │ 🎲     │   │   │
│  │  │真心话  │ │掷骰子   │   │   │
│  │  └────────┘ └────────┘   │   │
│  │  ┌────────┐ ┌────────┐   │   │
│  │  │ 🪙     │ │ 🔤     │   │   │
│  │  │丢硬币  │ │ ABCD   │   │   │
│  │  └────────┘ └────────┘   │   │
│  │  ┌────────┐ ┌────────┐   │   │
│  │  │ ☯      │ │ 🎨     │   │   │
│  │  │ 八卦   │ │随机颜色│   │   │
│  │  └────────┘ └────────┘   │   │
│  └──────────────────────────┘   │
│                                  │
│  ┌──────────────────────────┐   │
│  │   未来扩展区（灰色占位）    │   │
│  │  ┌────────┐ ┌────────┐   │   │
│  │  │ 📢     │ │ ⚙️     │   │   │
│  │  │ 公告   │ │ 设置   │   │   │
│  │  └────────┘ └────────┘   │   │
│  │  ┌────────┐              │   │
│  │  │ 🔄     │              │   │
│  │  │拉取数据│              │   │
│  │  └────────┘              │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
```

> **为什么需要负一屏？** 8 个功能在横向 Swiper 上无法一览。负一屏提供类似手机桌面的图标网格，一屏概览所有功能，点击直接跳转。未来公告/设置/拉取数据也是独立页面，负一屏自然承载。

### 3.3 状态管理

```typescript
@Component
export struct WearNavPanel {
  // === 外部回调（由 Index.ets 传入）===
  // 不要用 @Prop（函数类型 ArkUI 受限），直接用普通属性
  onNavigate: (index: number) => void = () => {};

  // === 内部状态：无 ===
  // 负一屏自身不需要 @State（没有动画、没有持久化、没有可变数据）

  // === 导航项配置（静态数据）===
  // 未来扩展区项目单独管理，方便迭代
}
```

### 3.4 导航项数据结构

```typescript
// 导航项配置（定义在 WearNavPanel.ets 内部）
interface NavItem {
  label: string;          // 显示名称
  icon: string;           // Emoji 图标（手表端小屏，纯文字/emoji 比图片清晰）
  targetIndex: number;    // 对应的 Swiper 页面索引（引用 Index.ets 的 PAGE_INDEX）
  enabled: boolean;       // 是否可点击（未来扩展区暂用 false 占位）
  section: 'function' | 'extension';  // 分组：功能导航 vs 未来扩展
}

// ⚠️ targetIndex 必须与 Index.ets 中的 PAGE_INDEX 常量保持一致
private readonly NAV_ITEMS: NavItem[] = [
  // ── 功能导航区 ──
  { label: '幸运转盘', icon: '🎡', targetIndex: 1, enabled: true, section: 'function' },
  { label: '祝福木鱼', icon: '🪵', targetIndex: 2, enabled: true, section: 'function' },
  { label: '真心话',   icon: '💬', targetIndex: 3, enabled: true, section: 'function' },
  { label: '掷骰子',   icon: '🎲', targetIndex: 4, enabled: true, section: 'function' },
  { label: '丢硬币',   icon: '🪙', targetIndex: 5, enabled: true, section: 'function' },
  { label: 'ABCD',     icon: '🔤', targetIndex: 6, enabled: true, section: 'function' },
  { label: '八卦',     icon: '☯',  targetIndex: 7, enabled: true, section: 'function' },
  { label: '随机颜色', icon: '🎨', targetIndex: 8, enabled: true, section: 'function' },

  // ── 未来扩展区（灰色占位，不可点击）──
  { label: '公告',     icon: '📢', targetIndex: -1, enabled: false, section: 'extension' },
  { label: '设置',     icon: '⚙️', targetIndex: -1, enabled: false, section: 'extension' },
  { label: '拉取数据', icon: '🔄', targetIndex: -1, enabled: false, section: 'extension' },
];
```

### 3.5 交互流程

```
用户左滑 → 进入负一屏 [index 0]
  │
  └─→ 看到全部功能网格 + 灰色扩展区占位

用户点击「祝福木鱼」
  │
  ├─→ if (!navItem.enabled) → 无反应（未来扩展区占位不响应点击）
  │
  ├─→ this.onNavigate(navItem.targetIndex)   // → Index.ets.onNavigate(2)
  │
  └─→ Index.ets 中 controller.changeIndex(2)  // → Swiper 切换到祝福木鱼

用户从功能页左滑
  │
  └─→ 回到负一屏（正常 Swiper 滑动手势，不走 onNavigate）
```

### 3.6 圆/方屏适配

负一屏不涉及 ArcButton/ArcSwiper，适配仅靠 WearScreenUtil Token：

| 维度 | 圆形屏 | 方形屏 | 说明 |
|------|--------|--------|------|
| **网格列数** | 2 列 | 2 列 | 手表屏太窄，3 列放不下文字 |
| **卡片尺寸** | `WearScreenUtil.scaledSize(90)` × `scaledSize(64)` | 同左 | 正方形卡片，宽高比例适配 |
| **卡片圆角** | `scaledSize(8)` | `scaledSize(8)` | |
| **图标字号** | `WearScreenUtil.buttonFontSize`（~16fp） | 同左 | Emoji 用字体而非图片，省资源 |
| **标签字号** | `WearScreenUtil.subFontSize`（~14fp） | 同左 | |
| **内边距** | `WearScreenUtil.safePadding`（24vp） | `WearScreenUtil.safePadding`（12vp） | |
| **滚动** | `Scroll()` 包裹（圆形屏 9+3=12 项可能溢出） | 同左 | 方形屏空间更大，但也加 Scroll 统一处理 |

### 3.7 组件实现骨架

```typescript
// product/wearable/src/main/ets/sub_pages/WearNavPanel.ets
import WearScreenUtil from '../utils/WearScreenUtil';

interface NavItem {
  label: string;
  icon: string;
  targetIndex: number;
  enabled: boolean;
  section: 'function' | 'extension';
}

@Component
export struct WearNavPanel {
  // Index.ets 通过 Builder 传入导航回调
  onNavigate: (index: number) => void = () => {};

  private readonly NAV_ITEMS: NavItem[] = [
    // ── 功能导航区 ──
    { label: '幸运转盘', icon: '🎡', targetIndex: 1, enabled: true, section: 'function' },
    { label: '祝福木鱼', icon: '🪵', targetIndex: 2, enabled: true, section: 'function' },
    { label: '真心话',   icon: '💬', targetIndex: 3, enabled: true, section: 'function' },
    { label: '掷骰子',   icon: '🎲', targetIndex: 4, enabled: true, section: 'function' },
    { label: '丢硬币',   icon: '🪙', targetIndex: 5, enabled: true, section: 'function' },
    { label: 'ABCD',     icon: '🔤', targetIndex: 6, enabled: true, section: 'function' },
    { label: '八卦',     icon: '☯',  targetIndex: 7, enabled: true, section: 'function' },
    { label: '随机颜色', icon: '🎨', targetIndex: 8, enabled: true, section: 'function' },

    // ── 未来扩展区 ──
    { label: '公告',     icon: '📢', targetIndex: -1, enabled: false, section: 'extension' },
    { label: '设置',     icon: '⚙️', targetIndex: -1, enabled: false, section: 'extension' },
    { label: '拉取数据', icon: '🔄', targetIndex: -1, enabled: false, section: 'extension' },
  ];

  build() {
    Scroll() {
      Column() {
        // ── 功能导航区标题 ──
        Text('快捷导航')
          .fontSize(WearScreenUtil.buttonFontSize)
          .fontColor(0xFFD4A017)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: WearScreenUtil.safePadding, bottom: 8 })

        // ── 功能网格 ──
        Grid() {
          ForEach(
            this.NAV_ITEMS.filter(item => item.section === 'function'),
            (item: NavItem) => {
              GridItem() {
                this.buildNavCard(item)
              }
            },
            (item: NavItem) => item.targetIndex.toString()
          )
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(WearScreenUtil.safePadding)
        .rowsGap(WearScreenUtil.safePadding)
        .padding(WearScreenUtil.safePadding)

        // ── 分隔线 ──
        Divider()
          .color(0x33FFFFFF)
          .width('90%')
          .margin({ top: 16, bottom: 8 })

        // ── 未来扩展区标题 ──
        Text('更多')
          .fontSize(WearScreenUtil.subFontSize)
          .fontColor(0x66FFFFFF)
          .width('100%')
          .padding({ left: WearScreenUtil.safePadding, bottom: 8 })

        // ── 未来扩展网格（灰色不可点）──
        Grid() {
          ForEach(
            this.NAV_ITEMS.filter(item => item.section === 'extension'),
            (item: NavItem) => {
              GridItem() {
                this.buildExtensionCard(item)
              }
            },
            (item: NavItem) => item.label
          )
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(WearScreenUtil.safePadding)
        .rowsGap(WearScreenUtil.safePadding)
        .padding(WearScreenUtil.safePadding)
      }
      .width('100%')
      .padding({ top: WearScreenUtil.safePadding, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)  // 手表屏不显示滚动条
  }

  @Builder
  buildNavCard(item: NavItem) {
    Column() {
      Text(item.icon)
        .fontSize(WearScreenUtil.buttonFontSize)
      Text(item.label)
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0xFFCCCCCC)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(WearScreenUtil.scaledSize(64))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(0x22FFFFFF)
    .borderRadius(WearScreenUtil.scaledSize(8))
    .onClick(() => {
      if (item.enabled) {
        this.onNavigate(item.targetIndex);
      }
    })
  }

  @Builder
  buildExtensionCard(item: NavItem) {
    Column() {
      Text(item.icon)
        .fontSize(WearScreenUtil.buttonFontSize)
        .opacity(0.3)
      Text(item.label)
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0x44FFFFFF)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(WearScreenUtil.scaledSize(64))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(0x11FFFFFF)
    .borderRadius(WearScreenUtil.scaledSize(8))
    .border({ width: 1, color: 0x22FFFFFF, style: BorderStyle.Dashed })
    // ⚠️ 无 onClick — 未来扩展区不响应点击
  }
}
```

### 3.8 边界处理

| # | 场景 | 处理方式 |
|---|------|---------|
| 1 | 导航项 `enabled: false` 被点击 | 不绑定 `onClick`，自然无响应 |
| 2 | `onNavigate` 回调未传入 | 默认空函数 `() => {}`，点击无效果但不崩溃 |
| 3 | `targetIndex` 超出 Swiper 范围 | Index.ets 的 `controller.changeIndex()` 内部会 clamp 到有效范围 |
| 3 | 滚动内容超出圆形屏可视区域 | `Scroll()` 包裹 + `.scrollBar(BarState.Off)` 隐藏滚动条 |
| 5 | 未来扩展区新增 Swiper 页 | 1) Index.ets 中 `buildAllPages` 加子组件 2) 本组件 `NAV_ITEMS` 中改 `enabled: true` + `targetIndex` |

### 3.9 未来扩展路线

| 阶段 | 扩展入口 | 实现 |
|:----:|---------|------|
| v1.1 | 公告 | 新增 Swiper 子页面 `WearAnnouncement.ets`（index 9），`NAV_ITEMS[8].enabled = true`，`targetIndex = 9` |
| v1.2 | 设置 | 新增 `WearSettings.ets`（index 10），连接 `@ohos.data.preferences` 操作 |
| v1.3 | 拉取数据 | 新增 `WearDataSync.ets`（index 11），触发 `SyncManager.pull()` → 分布式 KV Store 同步 |

---

## 4. 幸运转盘（WearRollWheel）

### 4.1 概览

| 维度 | 说明 |
|------|------|
| **手机端参考** | `product/default/.../form_display/RollWheelCardDisplay.ets` |
| **数据管理器** | `WearRollDataManager.ets`（已创建，包含 `Roll`/`RollItem` 模型 + 2 个预设转盘） |
| **核心交互** | 点击触发 Canvas 转盘旋转 → 指针指示结果；纵向 Swiper 切换不同转盘 |
| **独特价值** | 唯一支持多数据切换的 P0 功能（纵向 Swiper 内多个转盘） |

### 4.2 页面结构

```
┌──────────────────────────────────┐
│          WearRollWheel           │
├──────────────────────────────────┤
│  ┌──────────────────────────┐   │
│  │    纵向 Swiper 容器       │   │
│  │  (round: ArcSwiper垂直)   │   │
│  │  (square: Swiper垂直)    │   │
│  │                          │   │
│  │  ┌────────────────────┐  │   │
│  │  │  单个转盘页 (×n)   │  │   │
│  │  │  ┌──────────────┐  │  │   │
│  │  │  │ Canvas 转盘   │  │  │   │  ← 点击此处旋转
│  │  │  │ +            │  │  │   │
│  │  │  │ 中心指针      │  │  │   │
│  │  │  │ +            │  │  │   │
│  │  │  │ 转盘名称      │  │  │   │
│  │  │  └──────────────┘  │  │   │
│  │  └────────────────────┘  │   │
│  └──────────────────────────┘   │
│                                  │
│  [指示器] 显示当前第几个转盘      │
└──────────────────────────────────┘
```

### 4.3 状态管理

```typescript
@Component
export struct WearRollWheel {
  // === 数据 ===
  @State dataList: Roll[] = defaultRolls;       // 转盘列表（未来从 Preferences 加载）
  @State dataVersion: number = 0;               // 数据变更版本（触发 ForEach 重建）

  // === 动画 ===
  @State rotateAngle: number = 0;               // 当前转盘的旋转角度（累积值）
  @State currentRollIndex: number = 0;          // 当前纵向 Swiper 选中的转盘索引

  // === 控制器 ===
  private arcController: ArcSwiperController = new ArcSwiperController(); // 圆形屏用
  private swiperController: SwiperController = new SwiperController();    // 方形屏用
}
```

### 4.4 交互流程

```
用户点击 Canvas 转盘
  │
  ├─→ 计算随机旋转角度
  │     rotateAngle += random(0, 360) + 360 * 8   // 8 圈旋转 + 随机偏移
  │
  ├─→ animateTo(duration: 1000ms, curve: Ease)
  │     触发 Canvas 重绘（通过 @State rotateAngle 变化）
  │
  └─→ 旋转结束 → 指针所指扇区 = 本次结果
        （指针固定在上方 12 点方向，由当前转盘朝向决定命中扇区）

用户纵向滑动
  │
  ├─→ 切换 currentRollIndex
  │     圆形屏：ArcSwiper.vertical(true) 自动处理
  │     方形屏：Swiper.direction(Axis.Vertical) 自动处理
  │
  └─→ ForEach 重建当前页的 Canvas
```

### 4.5 Canvas 绘制（RollBox 子组件）

参考手机端 `RollBox` 结构，手表端适配要点：

```typescript
@Component
struct RollBox {
  @Prop data: Roll;
  @Prop @Watch('onAngleChange') rotateAngle: number;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  // 手表端核心差异：Canvas 尺寸由 WearScreenUtil.scaledSize() 控制
  private get canvasSize(): number {
    return WearScreenUtil.scaledSize(260);  // 基准 260vp（Watch GT 4 圆形屏）
  }

  aboutToDisappear(): void {
    // ⚠️ 释放 Canvas 资源（功耗优化关键）
    this.canvasContext = null!;
  }

  // drawWheel() 逻辑与手机端基本一致，差异在：
  //   1. 使用 this.canvasSize 而非 100% 撑满
  //   2. 字体大小按 WearScreenUtil.subFontSize 计算
  //   3. 颜色来自 data.rollItems[].color（与手机端一致）
}
```

### 4.6 圆/方屏适配

| 维度 | 圆形屏 | 方形屏 |
|------|--------|--------|
| **纵向容器** | `ArcSwiper(controller).vertical(true)` | `Swiper(controller).vertical(true)` |
| **指示器** | `.indicator(false)`（纵向模式指示器不直观） | `.indicator(true)` |
| **表冠** | `.digitalCrownSensitivity(MEDIUM)` 支持旋转切换 | 无 |
| **Canvas 尺寸** | `scaledSize(260)` ≈ 260vp（圆形屏更小） | `scaledSize(260)` 平方屏同基准 |
| **指针位置** | 12 点方向，`position({ top: '35%', left: '35%' })` | 同左 |

```typescript
@Builder
buildContent() {
  if (WearScreenUtil.isRoundScreen()) {
    ArcSwiper(this.arcController) {
      ForEach(this.dataList, (roll: Roll) => {
        this.buildSingleWheel(roll)
      }, (roll: Roll) => `${roll.index}_v${this.dataVersion}`)
    }
    .vertical(true)
    .indicator(false)
    .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
  } else {
    Swiper(this.swiperController) {
      ForEach(this.dataList, (roll: Roll) => {
        this.buildSingleWheel(roll)
      }, (roll: Roll) => `${roll.index}_v${this.dataVersion}`)
    }
    .vertical(true)
    .indicator(true)
  }
}

@Builder
buildSingleWheel(roll: Roll) {
  Row() {
    RollBox({ data: roll, rotateAngle: this.rotateAngle })
      .width(WearScreenUtil.scaledSize(260))
      .aspectRatio(1)
      .rotate({ angle: this.rotateAngle })
      .animation({ duration: 1000, curve: Curve.Ease })
    Image($r("app.media.pointer_m"))
      .zIndex(8)
      .width(WearScreenUtil.scaledSize(260) * 0.3)
      .aspectRatio(1)
      .fillColor($r("app.color.FontIcon_Back1"))
      .position({ top: '35%', left: '35%' })
  }
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
  .width('100%')
  .height('100%')
  .onClick(() => {
    this.rotateAngle += Random(0, 360, true) + 360 * 8;
  })
}
```

### 4.7 边界处理

| 边界场景 | 处理方式 |
|---------|---------|
| 转盘列表为空 | `dataList.length === 0` → 显示「暂无转盘，请编辑」占位文字 |
| 转盘只有一个 | 纵向 Swiper 只有一页，但不隐藏指示器（用户需知道当前无更多页） |
| 旋转动画未完成再次点击 | 允许叠加角度（`rotateAngle += ...`），动画自然衔接 |
| 角度溢出 | 不做 `% 360`，保留累积值（Canvas 旋转无上限问题）；若担心精度丢失，在超过 3600000 时归零 |
| Canvas 未就绪点击 | `onClick` 中检测 `canvasContext.width > 0`，未就绪跳过（无操作） |
| 资源释放 | `aboutToDisappear` 中将 `canvasContext` 置 null |

### 4.8 结果判定

旋转结束后，指针固定指向 12 点方向。命中扇区的判定方式（Canvas 绘制阶段即记录扇区映射，无需运行时计算）：

```
扇区起始角度 + 扇区角度范围 → 12 点方向（-90°）落在哪个扇区 → 该扇区对应 RollItem
```

> 注：手机端 `RollWheelCardDisplay` 没有显式的结果展示逻辑（结果即指针指向的扇区）。手表端保持相同行为 — 结果由视觉指示（指针），不需要额外弹窗。

---

## 5. 祝福木鱼（WearBlessingMuyu）

### 5.1 概览

| 维度 | 说明 |
|------|------|
| **手机端参考** | `product/default/.../form_display/BlessingMuyuCardDisplay.ets` |
| **核心交互** | 点击木鱼图片 → 敲击动画 + 祝福语气泡弹出 + 计数持久化 |
| **独特价值** | 唯一有 Preferences 持久化计数的 P0 功能 |
| **震动反馈** | VIBRATE 权限已配置，需对接 `VibratorManager` |

### 5.2 页面结构

```
┌──────────────────────────────────┐
│       WearBlessingMuyu           │
├──────────────────────────────────┤
│                                  │
│   ┌────────────────────────┐    │
│   │   祝福语气泡（居中）     │    │  ← 弹出动画
│   │   "幸福 +3"             │    │    scale: 0.6→1.08→1.0
│   │   随机颜色 + 字号        │    │    translateY: 15→-2→0
│   └────────────────────────┘    │
│                                  │
│   ┌────────────────────────┐    │
│   │                        │    │
│   │   木鱼图片（居中）       │    │  ← 点击触发
│   │   宽 55-70%            │    │    敲击动画
│   │                        │    │
│   └────────────────────────┘    │
│                                  │
│   [底部按钮区域]                 │
│   round: ArcButton(底部边缘)     │
│   square: Button('敲')          │
│                                  │
│   累计: 42 次                    │  ← Preferences 持久化计数
└──────────────────────────────────┘
```

### 5.3 状态管理

```typescript
@Component
export struct WearBlessingMuyu {
  // === 数据常量 ===
  private readonly BLESSINGS: string[] = [
    '幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐'
  ];
  private readonly LUCK: number[] = [
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,2,
    3,3,3,3,3,
    5,5,
    0    // 0 = 特殊祝福「功德无量」
  ];
  private readonly COLOR_PRESETS: string[] = [
    '#D4A017', '#FF6B6B', '#FF8C00', '#FF1493', '#00CED1',
    '#7B68EE', '#FF4500', '#32CD32', '#FF69B4', '#00BFFF'
  ];

  // === 动画状态 ===
  @State blessingText: string = '点击木鱼';
  @State blessingColor: string = this.COLOR_PRESETS[0];
  @State bubbleScale: number = 1;
  @State bubbleTranslateY: number = 0;
  @State tapVersion: number = 0;      // 动画版本号（防止异步动画冲突）

  // === 持久化状态 ===
  @State tapCount: number = 0;        // 累计敲击次数（Preferences 读写）

  // === Preferences ===
  private pref?: preferences.Preferences;
  private appCtx?: Context;
}
```

### 5.4 交互流程

```
aboutToAppear()
  │
  ├─→ 从 Preferences 加载 tapCount
  │     pref.getSync('muyu_tap_count', 0)
  │
  └─→ display toast: '上次功德: XX'

用户点击木鱼
  │
  ├─→ tapVersion++（动画版本递增）
  │
  ├─→ 随机选取
  │     blessingText = BLESSINGS[idx] + ' +' + LUCK[idx2]
  │     blessingColor = COLOR_PRESETS[random]
  │
  ├─→ 气泡弹出动画（三段式）
  │     animateTo(300ms, EaseOut):
  │       bubbleScale: 0.6 → 1.08
  │       bubbleTranslateY: 15 → -2
  │     animateTo(150ms, EaseIn, onFinish):
  │       bubbleScale: 1.08 → 1.0
  │       bubbleTranslateY: -2 → 0
  │     ⚠️ onFinish 中校验 tapVersion 防止旧动画覆盖
  │
  ├─→ 震动反馈
  │     VibratorManager.vibrateResult()  // 或 vibrateHaptic()
  │
  └─→ 持久化计数
        tapCount++
        pref.putSync('muyu_tap_count', tapCount)
        pref.flushSync()
        hilog.info(0x0000, 'Muyu', '总敲击: %{public}d', tapCount)
  │
aboutToDisappear()
  │
  └─→ pref = null  // 释放 Preferences 句柄
```

### 5.5 圆/方屏适配

| 维度 | 圆形屏 | 方形屏 |
|------|--------|--------|
| **木鱼图片宽度** | `WearScreenUtil.mainImageWidth` → 55% | `WearScreenUtil.mainImageWidth` → 70% |
| **按钮类型** | `ArcButton({ position: BOTTOM_EDGE })` | `Button('敲')` |
| **按钮字号** | `WearScreenUtil.buttonFontSize` | 同左 |
| **祝福文字字号** | `WearScreenUtil.subFontSize`（14~16fp） | 同左 |
| **内边距** | `WearScreenUtil.safePadding`（24vp） | `WearScreenUtil.safePadding`（12vp） |

**按钮分支实现**：

```typescript
@Builder
buildMuyuButton() {
  if (WearScreenUtil.isRoundScreen()) {
    ArcButton({ position: ArcButtonPosition.BOTTOM_EDGE }) {
      Text('敲')
        .fontSize(WearScreenUtil.buttonFontSize)
        .fontColor(Color.White)
    }
    .onClick(() => this.onTapMuyu())
  } else {
    Button('敲')
      .fontSize(WearScreenUtil.buttonFontSize)
      .onClick(() => this.onTapMuyu())
  }
}
```

### 5.6 边界处理

| 边界场景 | 处理方式 |
|---------|---------|
| Preferences 读取失败 | try-catch，tapCount 保持 0 |
| Preferences 写入失败 | try-catch 吞掉异常，不影响动画执行 |
| 动画冲突（快速连敲） | `tapVersion` 版本号机制，旧动画 `onFinish` 检测版本不匹配则跳过 |
| LUCK 随机到 0 | 「功德无量」特殊文案（不显示 +N，清空 bubbleText 短暂显示特殊提示） |
| 首次使用（无 Preferences 数据） | `getSync(key, 0)` 默认值 0 |
| 资源释放 | `aboutToDisappear` 中将 `pref` 置 null |

### 5.7 与手机端差异

| 维度 | 手机端 | 手表端 |
|------|--------|--------|
| CardsPage 中的嵌入式位置 | 在 `CardsPage` 的 `<Tabs>` 内作为 TabContent | 在 Index.ets 的 Swiper 内作为子页 |
| 背景 | `$r('app.color.Comp_Bg1')` + `borderRadius(8)` | 无额外背景（手表屏全黑底色更省电） |
| 按钮 | 图片本身可点击 | 额外提供 ArcButton/Button 作为触控区域（手表触控精度低） |
| hilog | ✅ 完整输出 | ✅ 同上（用户数据共享分析口径） |
| 布局 | `padding({ top: 12, bottom: 12 })` | `WearScreenUtil.safePadding` 动态间距 |

---

## 6. 真心话大冒险（WearTruthOrDare）

### 6.1 概览

| 维度 | 说明 |
|------|------|
| **手机端参考** | `product/default/.../sub_pages/honest_or_challenge/HonestOrChallenge.ets` |
| **数据源** | `product/wearable/.../utils/WearTruthOrDareData.ets`（独立复制手机端 `static_datas/challenges.ets`，10 条精简版起步） |
| **核心交互** | 上下分屏双模式，上半屏「真心话」下半屏「大冒险」，点击区域直接出题、直接展示结果 |
| **独特价值** | 唯一基于文本题库的 P0 功能；社交聚会杀手场景 |
| **与手机端最大差异** | 无旋转指针、无弹窗、无路由、无 header（纯极致简化） |

### 6.2 页面结构

```
┌──────────────────────────────┐   ┌──────────────────────────────┐
│        初始状态               │   │        点击后状态              │
│                              │   │                              │
│  ┌────────────────────────┐  │   │  ┌────────────────────────┐  │
│  │     💗 真心话          │  │   │  │ "你上一次哭是什么       │  │
│  │    (点击出题)           │  │   │  │  时候？为什么？"        │  │
│  │                        │  │   │  │                        │  │
│  │    红色背景 #FF7299     │  │   │  │  暗红色背景 #CC5A7A     │  │
│  └────────────────────────┘  │   │  └────────────────────────┘  │
│  ──────────────────────────  │   │  ──────────────────────────  │
│  ┌────────────────────────┐  │   │  ┌────────────────────────┐  │
│  │     🔥 大冒险          │  │   │  │                        │  │
│  │    (点击出题)           │  │   │  │      🔥 大冒险         │  │
│  │                        │  │   │  │    (点击出新题)          │  │
│  │    蓝色背景 #23ADE5     │  │   │  │                        │  │
│  └────────────────────────┘  │   │  │    浅蓝背景 #1A8AB8      │  │
│                              │   │  └────────────────────────┘  │
└──────────────────────────────┘   └──────────────────────────────┘
```

> 交互规则：点击某区域 → 该区域显示结果 + 变暗表明已出题。可再次点击出下一题（不与上一题重复）。另一个区域不受影响，独立操作。

### 6.3 状态管理

```typescript
@Component
export struct WearTruthOrDare {
  // === 真心话状态 ===
  @State honestText: string = '真心话';
  @State honestActive: boolean = false;       // 是否已出题（控制背景色变化）
  @State lastHonestIndex: number = -1;        // 上次题号（防止连续重复）

  // === 大冒险状态 ===
  @State challengeText: string = '大冒险';
  @State challengeActive: boolean = false;
  @State lastChallengeIndex: number = -1;

  // === 配色 ===
  private readonly HONEST_COLOR_ACTIVE: string = '#FF7299';
  private readonly HONEST_COLOR_RESULT: string = '#CC5A7A';
  private readonly CHALLENGE_COLOR_ACTIVE: string = '#23ADE5';
  private readonly CHALLENGE_COLOR_RESULT: string = '#1A8AB8';
}
```

### 6.4 交互流程

```
页面加载
  │
  ├─ honestText = '真心话'（占位文案）
  ├─ challengeText = '大冒险'（占位文案）
  ├─ honestActive = false（初始色亮）
  └─ challengeActive = false

用户点击上半屏（真心话区域）
  │
  ├─→ 从 honests[] 随机取一条
  │     idx = Random(0, honests.length-1)
  │     if (idx === lastHonestIndex && honests.length > 1):
  │       idx = (idx + 1) % honests.length   // 防止连续重复
  │     honestText = honests[idx]
  │     lastHonestIndex = idx
  │
  ├─→ honestActive = true（背景变暗红 #CC5A7A）
  │
  └─→ VibratorManager.vibrateResult() // 震动反馈

用户再次点击上半屏
  │
  └─→ 重新随机（同上逻辑，同样防止与上次重复）

用户点击下半屏（大冒险区域）
  │
  └─→ 同上逻辑，数据源为 challenges[]
        challengeActive = true（背景变暗蓝 #1A8AB8）
```

### 6.5 圆/方屏适配

真心话大冒险不涉及 ArcButton/ArcSwiper，适配仅靠 WearScreenUtil Token：

| 维度 | 值 | 说明 |
|------|-----|------|
| **标题字号** | `WearScreenUtil.buttonFontSize`（16fp） | 用于「真心话」/「大冒险」占位文案 |
| **结果字号** | `WearScreenUtil.subFontSize`（14fp） | 结果文字较长时用小号字体 |
| **内边距** | `WearScreenUtil.safePadding` | 文字不贴边 |
| **最大行数** | `maxLines(4)` | 超出 4 行自动截断 + 省略号 |
| **文字溢出** | `textOverflow({ overflow: TextOverflow.Ellipsis })` | 超长文字省略号处理 |

> 注意：手表端不区分圆形/方形屏的布局差异（上下分屏在两种屏幕都适用）。但如果未来有其他形状需求（如椭圆屏），可通过 `WearScreenUtil.screenWidth/screenHeight` 比例判断是否改为左右分屏。

### 6.6 数据源

```typescript
// product/wearable/src/main/ets/utils/WearTruthOrDareData.ets
// 方案 A：独立复制（初期快速落地），后续可迁移到 @ohos/common 共享
export const honests: string[] = [
  '你最近一次撒谎是什么时候？说的是什么？',
  '你最害怕失去什么？',
  '你做过最尴尬的事情是什么？',
  '你暗恋过谁？',
  '你最想改掉的坏习惯是什么？',
  '你在公共场合做过最丢脸的事是什么？',
  '你做过最冒险的事情是什么？',
  '如果可以回到过去，你最想改变什么？',
  '你最不想让别人知道的秘密是什么？',
  '你上一次哭是什么时候？为什么？',
];

export const challenges: string[] = [
  '用新闻联播的腔调进行一分钟即兴演讲',
  '给未在场的朋友的朋友圈点赞，从第一条开始，一直点到最新的一条',
  '用方言给 1 个人打电话聊一分钟',
  '做一个大家都觉得很丑的鬼脸，并保持 10 秒钟',
  '蒙眼涂口红',
  '单脚站立 3 分钟',
  '给朋友打电话，唱《青藏高原》的高音部分',
  '一口气喝完一瓶矿泉水',
  '和在场的一位异性对视 10 秒',
  '模仿一位在场的人，让大家猜是谁',
];
```

### 6.7 组件实现骨架

```typescript
// product/wearable/src/main/ets/sub_pages/WearTruthOrDare.ets
import { Random } from '@ohos/common';
import { VibratorManager } from '@ohos/vibratorutil';
import WearScreenUtil from '../utils/WearScreenUtil';
import { honests, challenges } from '../utils/WearTruthOrDareData';

@Component
export struct WearTruthOrDare {
  @State honestText: string = '真心话';
  @State honestActive: boolean = false;
  @State lastHonestIndex: number = -1;

  @State challengeText: string = '大冒险';
  @State challengeActive: boolean = false;
  @State lastChallengeIndex: number = -1;

  private getRandomText(source: string[], lastIndex: number): { text: string; index: number } {
    let idx = Random(0, source.length - 1, true);
    if (idx === lastIndex && source.length > 1) {
      idx = (idx + 1) % source.length;
    }
    return { text: source[idx], index: idx };
  }

  build() {
    Column() {
      // === 上半区：真心话 ===
      Column() {
        Text(this.honestText)
          .fontSize(
            this.honestActive
              ? WearScreenUtil.subFontSize    // 结果文字小号
              : WearScreenUtil.buttonFontSize // 占位文字中号
          )
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(
        this.honestActive ? '#CC5A7A' : '#FF7299'
      )
      .justifyContent(FlexAlign.Center)
      .padding(WearScreenUtil.safePadding)
      .onClick(() => {
        const result = this.getRandomText(honests, this.lastHonestIndex);
        this.honestText = result.text;
        this.lastHonestIndex = result.index;
        this.honestActive = true;
        VibratorManager.vibrateResult();
      })

      // === 下半区：大冒险 ===
      Column() {
        Text(this.challengeText)
          .fontSize(
            this.challengeActive
              ? WearScreenUtil.subFontSize
              : WearScreenUtil.buttonFontSize
          )
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(
        this.challengeActive ? '#1A8AB8' : '#23ADE5'
      )
      .justifyContent(FlexAlign.Center)
      .padding(WearScreenUtil.safePadding)
      .onClick(() => {
        const result = this.getRandomText(challenges, this.lastChallengeIndex);
        this.challengeText = result.text;
        this.lastChallengeIndex = result.index;
        this.challengeActive = true;
        VibratorManager.vibrateResult();
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

### 6.8 边界处理

| 边界场景 | 处理方式 |
|---------|---------|
| 题库只有 1 条 | 去重逻辑 `if (source.length > 1)` 保护，直接返回唯一那条 |
| 题库为空 | `Random(0, -1, true)` 会导致错误 → `source.length === 0` 时提前返回 `{ text: '暂无题目', index: -1 }` |
| 文字超长（> 4 行） | `maxLines(4)` + `textOverflow(Ellipsis)` 省略号截断 |
| `VibratorManager` 不可用 | try-catch 包裹震动调用，失败静默 |
| `aboutToDisappear` | 无 Canvas/动画资源需清理，但遵循规范保留空方法（未来扩展用） |

---

## 7. 后续扩展占位

以下 P1/P2 功能组件规格将在后续补充：

| 优先级 | 功能 | 组件 | 预计补充时间 |
|:------:|------|------|:-----------:|
| P1 | 掷骰子 | `WearRollDices` | P0 三组件编译通过后 |
| P1 | 丢硬币 | `WearFlipCoin` | P0 三组件编译通过后 |
| P1 | ABCD | `WearRandomABCD` | P0 三组件编译通过后 |
| P2 | 八卦 | `WearDevineBaGua` | P1 组件完成后 |
| P2 | 随机颜色 | `WearRandomColors` | P1 组件完成后 |

---

## 8. 索引：需新建/修改的文件

| 文件 | 操作 | 说明 |
|------|:----:|------|
| `docs/wearable-page-impl.md` | 🆕 新建 | 本文档 |
| `product/wearable/src/main/ets/pages/Index.ets` | 🔧 重写 | 新增负一屏子页 [0]、`PAGE_INDEX` 常量、`onNavigate` 回调、`.index(1)` 默认起始、方形屏 `.loop(false)` |
| `product/wearable/src/main/ets/sub_pages/WearNavPanel.ets` | 🆕 新建 | 负一屏导航组件 |
| `product/wearable/src/main/ets/sub_pages/WearRollWheel.ets` | 🆕 新建 | 幸运转盘组件 |
| `product/wearable/src/main/ets/sub_pages/WearBlessingMuyu.ets` | 🆕 新建 | 祝福木鱼组件 |
| `product/wearable/src/main/ets/sub_pages/WearTruthOrDare.ets` | 🆕 新建 | 真心话大冒险组件 |
| `product/wearable/src/main/ets/utils/WearTruthOrDareData.ets` | 🆕 新建 | 题库数据（10条精简版） |
