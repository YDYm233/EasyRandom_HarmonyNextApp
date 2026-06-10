# ⌚ 随易 EasyRandom — 手表端（Wearable）实现方案

> 文档版本：v4.0 | 日期：2026-06-10 | 基于项目 v1.0.19 开发中状态
> **v4.0 重构**：§2.7.4 数据持久化策略全面重写为两阶段方案（本地 Preferences → 分布式 KV Store），引入 `docs/wearable-sync-plan.md` 作为跨设备同步的正式规划文档；§1.1 已有基础表新增同步规划引用
> **v3.9 新增**：新增 §4.5 P0 功能优先级规划（幸运转盘 / 祝福木鱼 / 真心话大冒险）；新增 §4.6 真心话大冒险手表端适配方案（参考手机端 `HonestOrChallenge`）；§4.2 功能组件表新增优先级列（P0/P1/P2）；§5 文件架构新增 `WearTruthOrDare.ets`；§7 Step3 新增真心话大冒险实施项；§8.2 新增对应文件清单
> **v3.8 补充**：新增 §2.9 横阔屏适配（超新星 X1，480×408 横阔 AMOLED）；§2.3 WearScreenUtil 新增 `isWideScreen()` 方法；§2.1 方屏典型分辨率补充 480×408 px；§2.3 尺寸分级表补充超新星 X1 到 standard 典型设备
> **v3.7 补充**：全面补充约束维度 — §2.1 补充应用包大小限制(10MB)和内存澄清；§2.2 补充不支持的组件黑名单(Web/Video/TextArea等)；新增 §2.7 手表端运行约束(后台任务/网络/性能指标/数据持久化)；新增 §2.8 暗黑模式适配；§2.4 补充触控尺寸 vp/px 换算标注；§6 问题1 修正为经实测验证的方案(不加 targets)；§6 问题4 更新为实测结论；§7 Step1 更新操作描述；删除重复的尺寸分级表
> **v3.6 修正**：修正方案文档中的关键缺陷 — §2.2 修正 PanGesture 支持描述、§6 问题4 修正 minAPIVersion 架构错误（compatibleSdkVersion 是 app 级配置）、§6 问题6 修正 disableSwipe(true) UX 极差方案、§3.5 修正"子组件零分支"原则为"尽量减少分支"、新增 §2.6 功耗优化策略、统一 ArcButton 导入路径为 @kit.ArkUI
> **v3.5 修正**：SDK 实测验证 ArcSwiper/ArcDotIndicator 实际 API — import 统一使用 `@kit.ArkUI`（kit 入口 re-export，更规范）；ArcDotIndicator 方法名为 `.itemColor()` / `.selectedItemColor()`（非 `.color()` / `.selectedColor()`），无 `.itemShadow()` 方法；ArcSwiper 构造函数仅接受 `controller` 参数，indicator 通过 `.indicator()` 链式设置；`ArcSwiperAttribute` 由 `@kit.ArkUI` 自动 re-export 无需手动导入
> **v3.4 修正**：SDK 实测验证所有 Arc 组件 import 路径 — ArcSwiper→`@ohos.arkui.ArcSwiper`、ArcButton→`@ohos.arkui.advanced.ArcButton`（非 `@kit.ArkUI`）；确认 display→`@ohos.display`；CrownSensitivity 为全局枚举无需 import
> **v3.3 修复**：架构评审 7 项修复 — §4.2 统一 Token 引用、§8 编号修正、display 导入待确认、Token large 分支显式化、ArcButton 示例补充、getter 去冗余、scaledSize 偏向注释
> **v3.2 增强**：§3 适配架构重组为四层模型（检测层→容器层→内容层→工具层），新增关键设计原则
> **v3.1 修正**：ArcSwiper 是真实存在的独立组件（API 18+, `@kit.ArkUI`），废弃之前"标准 Swiper + Circle 裁切"的错误方案

---

## 1. 现状分析

### 1.1 已有基础

| 项目 | 状态 | 说明 |
|------|------|------|
| `product/wearable/` 目录 | ✅ 已创建 | 包含完整的 HAP 骨架文件 |
| `module.json5` | 🔒 被注释 | 手表模块配置完整但处于禁用状态 |
| `build-profile.json5` (顶层) | 🔒 被注释 | wearable 模块注册被注释 |
| `WearableAbility.ets` | ✅ 可用 | 标准 UIAbility，加载 `pages/Index` |
| `Index.ets` | 🧪 原型 | 仅包含一个 ABCD 卡片的 Hello World |
| `ABCDCard.ets` | 🧪 原型 | 从手机端 CardDisplay 复制的简化版 |
| `oh-package.json5` | ✅ 可用 | 已依赖 `@ohos/common` |
| 已构建 .hap | ✅ 存在 | `wearable-default-signed.hap` |

### 1.2 部分功能参考手机端default模块内的实现

手表端**不直接复用**手机端，ABCD和幸运转盘可以参考 `form_display/` 下的 CardDisplay 组件，不直接导入CardDisplay而是**参考它们的交互逻辑，在 wearable 模块内单独建立适配手表屏的组件文件**。以下是各 CardDisplay 的核心逻辑摘要，供开发时参照：

| 组件 | 文件 | 核心交互 | 关键状态 | 参考要点 |
|------|------|---------|---------|---------|
| `RollDiceCardDisplay` | `form_display/RollDiceCardDisplay.ets` | 点击随机切换骰子图片 | `diceImageArray` + `diceImageIndex` | 最简单：Image + onClick + Random，手表端几乎不用改 |
| `FlipCoinCardDisplay` | `form_display/FlipCoinCardDisplay.ets` | 点击旋转硬币（Y 轴旋转） | `coinImageIndex` + `angle` | Stack 叠放正反面 + rotate({x:1})，手表端缩小尺寸即可 |
| `ABCDCardDisplay` | `form_display/ABCDCardDisplay.ets` | 点击旋转指针选 ABCD | `angle` + `colors[]` + `fontColors[]` | 四格 position 布局 + needle 指针旋转，手表端可去掉指针改为四格直铺点击 |
| `BaGuaCardDisplay` | `form_display/BaGuaCardDisplay.ets` | 点击旋转八卦图 | `rotateAngle` | Image + rotate，最简单，手表端几乎不用改 |
| `RollWheelCardDisplay` | `form_display/RollWheelCardDisplay.ets` | 纵向 Swiper 切换转盘 + 点击旋转 | `dataList` + `rotateAngle` + `RollBox(Canvas)` | 最复杂：Canvas 绘制 + Swiper + RollDataManager，手表端需精简 |
| `RandomColorsCardDisplay` | `form_display/RandomColorsCardDisplay.ets` | 点击生成随机色 | `rgba` + `color` + `title` | Text 全屏着色 + ExColor，手表端几乎不用改 |
| `BlessingMuyuCardDisplay` | `form_display/BlessingMuyuCardDisplay.ets` | 点击敲木鱼 + 计数持久化 | `blessingText` + `tapCount` + `Preferences` | 有 Preferences 持久化 + 动画，手表端可简化动画 |

### 1.3 依赖链

```
手表端新建组件
├── @ohos/common (Random, ExColor 等)        ← 已有依赖，直接可用
├── WearRollWheel (手表端转盘)
│   └── RollDataManager (Roll, RollItem, defaultRolls, initRollsData)
│       └── @kit.ArkData (preferences)       ← 需在手表端同步引入
├── WearBlessingMuyu (手表端木鱼)
│   └── @kit.ArkData (preferences)
│   └── @kit.PerformanceAnalysisKit (hilog)
├── WearTruthOrDare (手表端真心话大冒险)          ← 🆕 P0 新增，手机端已有 HonestOrChallenge
│   └── static_datas/challenges.ets (数据源) ← 共用手机端数据文件或独立复制
│   └── @ohos/vibratorutil (震动)           ← 结果反馈震动
└── 图片资源 ($r("app.media.xxx"))
    ├── dice1~6, coin1~2, needle, BaGua, MuYu, pointer_m 等
    └── 颜色资源 ($r("app.color.xxx"))
```

---

## 2. 手表端约束

### 2.1 硬件约束

| 约束项 | 圆形手表 | 方形手表 | 影响 |
|--------|---------|---------|------|
| **屏幕尺寸** | 1.4 ~ 1.5 英寸 | 1.4 ~ 1.6 英寸 | 单屏信息量极有限，每次只展示一个核心内容 |
| **典型分辨率** | 466×466 px（华为 Watch GT / Watch 4） | 320×320 px、368×448 px（华为 Watch D）或 480×408 px（华为超新星 X1 横阔屏 1.82" AMOLED） | Canvas/图片按分辨率分级加载 |
| **屏幕形状** | 圆形（主流） | 方形/类方形 | **核心差异**：圆屏四角被裁切，方屏可利用全屏 |
| **输入方式** | 触摸 + 滑动 + 物理表冠 | 同左 | 无键盘输入、无右键、无长按菜单 |
| **内存（设备总）** | 2GB ~ 4GB | 同左 | 应用内存限制 < 100MB（推荐），避免同时加载大图/复杂 Canvas |
| **电池** | 300~600mAh | 同左 | 动画完成后必须停止，避免持续重绘 |
| **震动马达** | 线性马达 | 同左 | 需 `ohos.permission.VIBRATE` 权限 |
| **存储可用空间** | 4~16 GB | 同左 | 应用包大小应控制在 **10MB 以内**（含资源），超出可能无法安装或影响系统性能 |
| **应用内存限制** | < 100MB（推荐） | 同左 | 2~4GB 为设备总内存，应用实际可用远小于此值；避免同时加载大图/复杂 Canvas |

### 2.2 ArkUI 约束（圆/方屏差异核心）

#### 通用约束（圆形+方形共有）

| 约束项 | 说明 | 应对 |
|--------|------|------|
| 部分组件不可用 | 手表端 ArkUI 组件子集 < 手机端（如部分弹窗、输入组件） | 开发前先在模拟器验证每个组件是否可用 |
| 无软键盘 | 手表无文本输入弹窗 | 所有功能零文本输入，用预设列表/选择器代替 |
| 无复杂输入 | 手表无文本输入弹窗 | 所有功能零文本输入，用预设列表/选择器代替 |
| 手势支持 | PanGesture 从 API 7 开始支持 | 优先使用 onClick + Swiper 滑动，复杂手势需实测验证 |
| Navigation 限制 | 手表端推荐用原生 Navigation | 单页面 + Swiper，不使用 router 多页面导航 |
| Swiper 性能 | 手表端 Swiper 页面数不宜超过 10 个 | 横向 Swiper 8 个功能页 |

#### 手表端不支持的组件黑名单

根据官方文档和社区实践，手表端明确不支持或强烈不推荐以下组件：

| 组件 | 支持程度 | 原因 | EasyRandom 影响 |
|------|:--------:|------|:--------------:|
| `Web` | ❌ 不支持 | 手表端无 WebView 能力 | 无影响（本项目无网页） |
| `Video` | ❌ 不支持 | 手表端无视频播放能力 | 无影响 |
| `TextArea` | ❌ 不支持 | 手表无软键盘，输入组件无意义 | 无影响（本项目零输入） |
| `TextInput` | ⚠️ 受限 | 同上，不推荐使用 | 无影响 |
| `RichText` | ⚠️ 受限 | 复杂富文本渲染可能卡顿，不建议大段使用 | 无影响 |
| `Search` | ⚠️ 受限 | 手表屏幕太小，不适合搜索场景 | 无影响 |
| `TextAreaDialog` | ❌ 不支持 | 无输入能力 | 无影响 |
| `DatePickerDialog` | ⚠️ 受限 | 弹窗类组件需实测可用性 | 无影响 |
| `TimePickerDialog` | ⚠️ 受限 | 弹窗类组件需实测可用性 | 无影响 |
| `Marquee` | ⚠️ 受限 | 官方文档未明确标注 wearable 支持 | 无影响 |
| `MultiSelect` | ⚠️ 受限 | 交互太复杂，不适合手表 | 无影响 |

> ✅ **EasyRandom 影响评估**：本项目所有功能均为"点击触发随机"的纯展示 + 简单交互模式，**不受以上组件黑名单影响**。但新功能开发时需注意此列表。

#### 圆形屏专用组件（API 18+）

| 组件 | 导入方式 | 用途 | 方形屏可用？ |
|------|---------|------|:----------:|
| **ArcSwiper** | `import { ArcSwiper, ArcSwiperController, ArcDotIndicator, ArcDirection } from '@kit.ArkUI'` | 弧形轮播容器，子组件沿圆弧排列，支持表冠交互、弧形指示器、自定义切换动画 | ⚠️ API 22+ 支持非 Wearable，但方形屏体验差 |
| **ArcList** | `import { ArcListAttribute } from '@ohos.arkui.ArcList'` | 弧形滚动列表，列表项接近边缘时自动缩放 | ❌ 不建议 |
| **ArcButton** | `import { ArcButtonPosition } from '@kit.ArkUI'` | 贴合圆形屏边缘的弧形按钮（TOP_EDGE / BOTTOM_EDGE） | ❌ 不适用 |
| **ArcScrollBar** | `import { ArcScrollBarAttribute } from '@ohos.arkui.ArcScrollBar'` | 弧形滚动条，配合 ArcList 使用 | ❌ 不适用 |
| **ArcAlphabetIndexer** | `import ... from '@ohos.arkui.ArcAlphabetIndexer'` | 弧形索引条 | ❌ 不适用 |

> ⚠️ **v3.5 修正**：导入可使用 `@kit.ArkUI`（推荐，kit 入口 re-export）或 `@ohos.arkui.ArcSwiper`（直接路径），两者等效。`@kit.ArkUI` 会自动 re-export `ArcSwiper`（组件）、`ArcSwiperAttribute`、`ArcSwiperController`、`ArcDotIndicator`、`ArcDirection` 等全部类型，无需单独手动导入 `ArcSwiperAttribute`。`CrownSensitivity` 为全局枚举，API 18+ 自动可用，无需 import。
> **v3.4 勘误**：之前认为 Arc 组件无法从 `@kit.ArkUI` 导入，实测 `@kit.ArkUI` 的 .d.ts 确实包含 `import { ArcSwiper, ArcSwiperAttribute, ArcDotIndicator, ArcDirection, ArcSwiperController } from '@ohos.arkui.ArcSwiper'` 的 re-export，两个路径均可用。
> **v3.0 勘误**：之前错误地声称"ArcSwiper 不存在"，现已纠正。ArcSwiper 是 **API 18+ 正式提供的独立组件**，定位为圆形屏幕穿戴设备的专用轮播容器。

### ArcSwiper 完整 API 参考

**导入**（`@kit.ArkUI` 统一入口，全部类型自动 re-export，无需手动导入 `ArcSwiperAttribute`）：

```typescript
// v3.5 推荐：从 @kit.ArkUI 导入（全部类型自动 re-export）
import {
  ArcSwiper,              // 弧形轮播组件
  ArcSwiperAttribute,     // @kit.ArkUI 自动 re-export，无需手动导入
  ArcSwiperController,    // 编程式控制器
  ArcDotIndicator,        // 弧形圆点指示器
  ArcDirection            // 指示器方向枚举
} from '@kit.ArkUI';
// CrownSensitivity 为全局枚举，API 18+ 自动可用，无需 import
```

**属性一览**：

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `index` | `Optional<number>` | `0` | 当前显示子组件索引。超出范围按 0 处理 |
| `indicator` | `Optional<ArcDotIndicator \| boolean>` | `true` | 弧形圆点指示器。`false` 关闭 |
| `duration` | `Optional<number>` | `400` | 切换动画时长(ms) |
| `vertical` | `Optional<boolean>` | `false` | 是否纵向滑动 |
| `disableSwipe` | `Optional<boolean>` | `false` | 禁用手势滑动，仅控制器翻页 |
| `digitalCrownSensitivity` | `Optional<CrownSensitivity>` | `MEDIUM` | 旋转表冠灵敏度：`LOW` / `MEDIUM` / `HIGH` |
| `effectMode` | `Optional<EdgeEffect>` | `Spring` | 边缘效果：`None` / `Spring` / `Fade` |
| `disableTransitionAnimation` | `Optional<boolean>` | `false` | 关闭特殊弧形动效 |

**事件一览**：

| 事件 | 回调签名 | 触发时机 |
|------|---------|---------|
| `onChange` | `(index: number) => void` | 页面索引变化时 |
| `onAnimationStart` | `(index, targetIndex, event: SwiperAnimationEvent) => void` | 动画开始时 |
| `onAnimationEnd` | `(index, event: SwiperAnimationEvent) => void` | 动画结束时（含手势中断） |
| `onGestureSwipe` | `(index, event: SwiperAnimationEvent) => void` | 跟手滑动逐帧触发 |
| `customContentTransition` | `SwiperContentAnimatedTransition` | 自定义切换动画（透明度/缩放/位移） |

**ArcSwiperController 方法**：

| 方法 | 说明 |
|------|------|
| `showNext()` | 翻到下一页 |
| `showPrevious()` | 翻到上一页 |
| `finishAnimation(callback?)` | 停止动画，可选回调 |

**ArcDotIndicator（弧形指示器）**：

| 属性 | 默认值 | 说明 |
|------|--------|------|
| `arcDirection` | `ArcDirection.SIX_CLOCK_DIRECTION` | `THREE_CLOCK_DIRECTION`(右) / `SIX_CLOCK_DIRECTION`(下) / `NINE_CLOCK_DIRECTION`(左) |
| `itemColor` | `'#A9FFFFFF'` | 未选中点颜色 |
| `selectedItemColor` | `'#FF5EA1FF'` | 选中点颜色 |
| `backgroundColor` | `'#FF404040'` | 长按指示器时背景色 |
| `maskColor` | 透明→黑渐变 | 弧形指示器遮罩渐变色 |

**ArcSwiper vs 普通 Swiper 核心差异**：

| 维度 | 普通 Swiper | ArcSwiper |
|------|-----------|-----------|
| 适用设备 | 手机/平板（矩形屏） | 仅 Wearable（圆形屏），API 22+ 扩展到全设备 |
| 排列方式 | 线性排列（水平/垂直） | **弧形排列**，子组件沿圆弧分布 |
| API 起始版本 | API 7 | **API 18** |
| 指示器 | 通用点状 | **ArcDotIndicator**，可设 3/6/9 点钟方向 |
| 表冠交互 | 不支持 | 支持 `digitalCrownSensitivity` |
| 系统能力 | `SystemCapability.ArkUI.ArkUI.Full` | `SystemCapability.ArkUI.ArkUI.Circle` |

#### 圆/方屏组件选择对照表

| 功能需求 | 圆形屏 | 方形屏 |
|---------|--------|--------|
| 功能页切换 | `ArcSwiper` + `ArcSwiperController` + `ArcDotIndicator` | `Swiper`（标准矩形容器） |
| 列表滚动 | `ArcList` + `ArcListItem` | `List` + `ListItem` |
| 操作按钮 | `ArcButton`（弧形贴合边缘） | `Button`（标准矩形） |
| 滚动条 | `ArcScrollBar` | `ScrollBar` |
| 转盘数据切换 | 纵向 `ArcSwiper({ vertical: true })` 或 ArcList | `Swiper({ direction: Axis.Vertical })` |
| 表冠交互 | `digitalCrownSensitivity`（ArcSwiper 属性） | 不适用（方形手表通常无表冠） |

### 2.3 屏幕形状检测

**核心 API**：`display.getDefaultDisplaySync().screenShape`

```typescript
import { display } from '@ohos.display';  // ✅ v3.4 确认：实际路径为 @ohos.display（非 @kit.ArkUI）

// 获取屏幕形状（API 18+）
const screenShape: display.ScreenShape = display.getDefaultDisplaySync().screenShape;

// 判断是否圆形屏
const isRound: boolean = (screenShape === display.ScreenShape.ROUND);
```

| 属性 | 类型 | 值 | 说明 |
|------|------|-----|------|
| `ScreenShape.RECTANGLE` | enum | 0 | 矩形屏（默认值） |
| `ScreenShape.ROUND` | enum | 1 | 圆形屏 |

> ⚠️ **待官方文档确认**：`ScreenShape` API 的最低 API 版本标注为 API 18+，但尚未找到官方文档直接确认。实际使用时需在代码中做 try-catch 兼容处理（见 WearScreenUtil 代码示例）。

**封装为全局工具**：

```typescript
// product/wearable/src/main/ets/utils/WearScreenUtil.ets
import { display } from '@ohos.display';  // ✅ v3.4 确认：实际路径

/** 手表屏幕尺寸分级 */
export type WearScreenSize = 'small' | 'standard' | 'large';

export class WearScreenUtil {
  private static _isRound: boolean | null = null;
  private static _screenWidth: number = 0;
  private static _screenHeight: number = 0;
  private static _screenSize: WearScreenSize | null = null;

  // ========== 屏幕形状 ==========

  static isRoundScreen(): boolean {
    if (this._isRound === null) {
      try {
        const shape = display.getDefaultDisplaySync().screenShape;
        this._isRound = (shape === display.ScreenShape.ROUND);
      } catch (e) {
        // API < 18 不支持 ScreenShape，默认方形
        this._isRound = false;
      }
    }
    return this._isRound;
  }

  static isSquareScreen(): boolean {
    return !this.isRoundScreen();
  }

  /**
   * 是否横阔屏（宽 > 高，如超新星 X1 的 480×408）
   * 横阔屏是方屏的一种特殊形态，内容区域更宽、高度更窄
   */
  static isWideScreen(): boolean {
    return this.screenWidth > this.screenHeight;
  }

  // ========== 屏幕尺寸 ==========

  /** 懒加载初始化屏幕尺寸（宽度+高度一起设，避免重复获取） */
  private static _initDimensions(): void {
    if (this._screenWidth === 0 && this._screenHeight === 0) {
      const d = display.getDefaultDisplaySync();
      this._screenWidth = px2vp(d.width);
      this._screenHeight = px2vp(d.height);
    }
  }

  /** 获取屏幕宽度 (vp) */
  static get screenWidth(): number {
    this._initDimensions();
    return this._screenWidth;
  }

  /** 获取屏幕高度 (vp) */
  static get screenHeight(): number {
    this._initDimensions();
    return this._screenHeight;
  }

  /**
   * 手表屏幕尺寸分级
   * - small:  < 340vp（如 Watch D 320×320）
   * - standard: 340~460vp（如 Watch GT 4 466×466）
   * - large:  > 460vp（未来更大屏手表）
   */
  static get screenSize(): WearScreenSize {
    if (this._screenSize === null) {
      const minDim = Math.min(this.screenWidth, this.screenHeight);
      if (minDim < 340) {
        this._screenSize = 'small';
      } else if (minDim > 460) {
        this._screenSize = 'large';
      } else {
        this._screenSize = 'standard';
      }
    }
    return this._screenSize;
  }

  static isSmallScreen(): boolean {
    return this.screenSize === 'small';
  }

  // ========== 设计 Token（尺寸自适应）==========

  /** 安全边距 (vp) — 圆形屏更大 */
  static get safePadding(): number {
    if (this.isRoundScreen()) {
      if (this.screenSize === 'small') return 18;
      if (this.screenSize === 'large') return 28;   // 暂无此设备，预留
      return 24;  // standard
    }
    if (this.screenSize === 'small') return 8;
    if (this.screenSize === 'large') return 16;      // 暂无此设备，预留
    return 12;  // standard
  }

  /** 内容区宽度占比 — 圆形屏更窄 */
  static get contentWidthRatio(): string {
    if (this.isRoundScreen()) {
      if (this.screenSize === 'small') return '65%';
      if (this.screenSize === 'large') return '75%';   // 暂无此设备，预留
      return '70%';  // standard
    }
    if (this.screenSize === 'small') return '88%';
    if (this.screenSize === 'large') return '92%';      // 暂无此设备，预留
    return '90%';  // standard
  }

  /** 主图/主元素宽度占比 */
  static get mainImageWidth(): string {
    if (this.isRoundScreen()) {
      if (this.screenSize === 'small') return '48%';
      if (this.screenSize === 'large') return '60%';   // 暂无此设备，预留
      return '55%';  // standard
    }
    if (this.screenSize === 'small') return '62%';
    if (this.screenSize === 'large') return '75%';      // 暂无此设备，预留
    return '70%';  // standard
  }

  /** 结果字号 (fp) */
  static get resultFontSize(): number {
    if (this.screenSize === 'small') return 40;
    if (this.screenSize === 'large') return 56;   // 暂无此设备，预留
    return 48;  // standard
  }

  /** 辅助字号 (fp) */
  static get subFontSize(): number {
    if (this.screenSize === 'small') return 12;
    if (this.screenSize === 'large') return 16;   // 暂无此设备，预留
    return 14;  // standard
  }

  /** 按钮字号 (fp) */
  static get buttonFontSize(): number {
    if (this.screenSize === 'small') return 14;
    if (this.screenSize === 'large') return 18;   // 暂无此设备，预留
    return 16;  // standard
  }

  /** 列表项间距 (vp) */
  static get listItemSpace(): number {
    if (this.isRoundScreen()) {
      if (this.screenSize === 'small') return 12;
      if (this.screenSize === 'large') return 20;   // 暂无此设备，预留
      return 16;  // standard
    }
    if (this.screenSize === 'small') return 8;
    if (this.screenSize === 'large') return 14;      // 暂无此设备，预留
    return 12;  // standard
  }

  /** 按钮最小触摸区域 (vp) */
  static get minTouchSize(): number {
    // 无论屏幕大小，触摸区域不能缩小
    return 48;
  }

  /**
   * 按屏幕尺寸计算比例值
   * 用法：WearScreenUtil.scaledSize(200) — 在 standard 屏返回 200vp
   *       在 small 屏自动缩小，在 large 屏自动放大
   *
   * ⚠️ 设计说明：
   * - 基准 466vp 取自 Watch GT 4（圆形 standard 屏），对圆形屏更友好
   * - 方形小屏（320×320）下比例 ~0.687，受 70% 下限保护
   * - 该函数仅用于 Canvas 等需要精确 vp 值的场景（如转盘绘制）
   * - 一般布局尺寸优先使用百分比 Token（mainImageWidth 等），不依赖此函数
   */
  static scaledSize(standardValue: number): number {
    const scale = this.screenWidth / 466; // 以 466vp（Watch GT 4 圆形屏）为基准
    return Math.max(standardValue * scale, standardValue * 0.7); // 最小缩到 70%
  }
}
```

**设计 Token 查速表**：

| Token | small 圆形 | standard 圆形 | large 圆形 | small 方形 | standard 方形 | large 方形 |
|-------|-----------|-------------|----------|-----------|-------------|----------|
| 典型设备 | — | Watch GT 4 (466×466) | 未来大屏 | Watch D (320×320) | Watch Fit (368×448) | 未来大屏 |
| safePadding | 18 vp | 24 vp | 28 vp | 8 vp | 12 vp | 16 vp |
| mainImageWidth | 48% | 55% | 60% | 62% | 70% | 75% |
| resultFontSize | 40 fp | 48 fp | 56 fp | 40 fp | 48 fp | 56 fp |
| subFontSize | 12 fp | 14 fp | 16 fp | 12 fp | 14 fp | 16 fp |
| listItemSpace | 12 vp | 16 vp | 20 vp | 8 vp | 12 vp | 14 vp |
| minTouchSize | 48 vp | 48 vp | 48 vp | 48 vp | 48 vp | 48 vp |

> ⚠️ `large` 列数值为预留值（暂无对应设备），当前与 `standard` 行为相同但预留独立分支。

### 2.4 交互约束

| 约束项 | 圆形屏 | 方形屏 | 规范 |
|--------|--------|--------|------|
| 最小触摸区域 | 48×48 vp | 48×48 vp | 手指精度低，按钮必须够大（48vp @2x = 96px） |
| 单屏单任务 | ✅ 严格执行 | ✅ 严格执行 | 一个屏幕只做一件事 |
| 返回操作 | 系统侧滑返回 | 系统侧滑返回 | 不放置 UI 返回键 |
| 动画时长 | ≤ 500ms | ≤ 500ms | 手表要求快速反馈 |
| 侧滑冲突 | ⚠️ 高风险 | ⚠️ 中风险 | 圆形屏侧滑返回更容易误触发横向 Swiper |
| 表冠交互 | ✅ 支持 | ❌ 通常无 | 圆形手表可用 `digitalCrownSensitivity` |
| 四角内容 | ❌ 会被裁切 | ✅ 可利用 | 圆形屏核心内容必须在中心安全区 |

### 2.5 设计 Token（形状×尺寸 四象限）

> 核心原则：**形状决定组件选择（Arc/List/ArcButton/Button），尺寸决定数值大小（字号/间距/边距）**

| 属性 | 圆形 standard | 圆形 small | 圆形 large | 方形 standard | 方形 small | 方形 large | Token 名 |
|------|:------------:|:---------:|:---------:|:------------:|:---------:|:---------:|----------|
| 安全边距 | 24 vp | 18 vp | 28 vp | 12 vp | 8 vp | 16 vp | `safePadding` |
| 内容宽度比 | 70% | 65% | 75% | 90% | 88% | 92% | `contentWidthRatio` |
| 主图宽度 | 55% | 48% | 60% | 70% | 62% | 75% | `mainImageWidth` |
| 结果字号 | 48 fp | 40 fp | 56 fp | 48 fp | 40 fp | 56 fp | `resultFontSize` |
| 辅助字号 | 14 fp | 12 fp | 16 fp | 14 fp | 12 fp | 16 fp | `subFontSize` |
| 按钮字号 | 16 fp | 14 fp | 18 fp | 16 fp | 14 fp | 18 fp | `buttonFontSize` |
| 列表项间距 | 16 vp | 12 vp | 20 vp | 12 vp | 8 vp | 14 vp | `listItemSpace` |
| Swiper 组件 | `ArcSwiper` | `ArcSwiper` | `ArcSwiper` | `Swiper` | `Swiper` | `Swiper` | 代码条件判断 |
| 指示器样式 | `ArcDotIndicator` (6点方向) | 同左 | 同左 | `Swiper indicator` | 同左 | 同左 | 代码条件判断 |
| 表冠灵敏度 | `CrownSensitivity.MEDIUM` | 同左 | 同左 | 不支持 | 不支持 | 不支持 | `digitalCrownSensitivity` |
| 按钮样式 | `ArcButton` | `ArcButton` | `ArcButton` | `Button` | `Button` | `Button` | 代码条件判断 |
| 列表样式 | `ArcList` | `ArcList` | `ArcList` | `List` | `List` | `List` | 代码条件判断 |
| Swiper 指示点 | ArcDotIndicator 弧形 | 同左 | 同左 | 6×6 vp 线形 | 同左 | 同左 | 组件不同 |
| 屏幕裁切 | `clipShape(CircleShape)` | 同左 | 同左 | 不需要 | 不需要 | 不需要 | 代码条件判断 |
| 触摸区域下限 | 48×48 vp | 48×48 vp | 48×48 vp | 48×48 vp | 48×48 vp | 48×48 vp | `minTouchSize` |

> ⚠️ `large` 列数值为预留值（暂无对应设备，不影响当前开发）。

**尺寸分级标准**：

| 级别 | 短边 (vp) | 典型设备 | 说明 |
|------|----------|---------|------|
| `small` | < 340 | Watch D (320×320) | 方形小屏，元素需缩小但触摸区不缩 |
| `standard` | 340 ~ 460 | Watch GT 4 (466×466), Watch Fit (368×448), 超新星 X1 (480×408 横阔屏) | 主流手表 |
| `large` | > 460 | 未来大屏手表 | 目前无此设备，预留 |

### 2.6 功耗优化策略（P1 补充）

手表端 300-600mAh 的电池约束比手机严格 10 倍以上。以下优化策略**必须**在开发中落实：

| 优化方向 | 实施要点 | 代码示例 |
|---------|---------|---------|
| **动画帧率控制** | 动画完成后立即停止渲染 | `animateTo({ duration: 300 })` + 动画结束后停止 |
| **传感器释放** | 使用完传感器立即调用 `off()` / `release()` | `sensor.off(sensor.SensorId.ACCELEROMETER)` |
| **页面不可见时暂停** | `aboutToDisappear` 中停止所有动画/定时器 | `clearInterval(this.timer)` |
| **帧率降级** | 非活跃页面降低帧率 | `preferredFrameRate: 30` |
| **Canvas 离屏渲染** | 静态内容使用 `OffscreenCanvas` | 减少主线程绘制开销 |
| **图片资源优化** | 按屏幕尺寸分级加载 | `scaledSize()` 按比例缩放 |

**关键代码模式**：

```typescript
// ✅ 正确：页面销毁时释放资源
aboutToDisappear() {
  // 停止定时器
  if (this.timer !== undefined) {
    clearInterval(this.timer);
    this.timer = undefined;
  }
  
  // 停止动画
  this.animating = false;
  
  // 释放传感器
  try {
    sensor.off(sensor.SensorId.ACCELEROMETER);
  } catch (e) {
    Logger.warn('Sensor release failed', e);
  }
}

// ✅ 正确：动画结束后停止持续渲染
animateTo({
  duration: 300,
  onFinish: () => {
    this.animating = false;  // 通知框架停止重绘
  }
}, () => {
  this.angle = this.targetAngle;
});
```

### 2.7 手表端运行约束（P0+P1 补充）

#### 2.7.1 后台任务约束

HarmonyOS 后台任务管理对手表端有严格限制。手表应用在进入后台后**极短时间内就会被系统挂起/冻结**，不能假设后台持续运行。

| 任务类型 | 时间限制 | 每日配额 | 手表端影响 |
|---------|---------|---------|-----------|
| 短时任务（Short Task） | 单次最多 3 分钟（低电量 1 分钟） | 每日约 10 分钟 | 手表电池小，低电量更频繁触发限制 |
| 长时任务（Continuous Task） | 需申请 `ContinuousTaskExtensionAbility` | 系统审批 | 手表端审批更严格，一般不授予 |
| 代理提醒（Reminder Agent） | 需申请 | 系统审批 | 可用于闹钟/倒计时等场景 |

> **对 EasyRandom 的影响**：本项目无后台任务需求（纯前台交互），但需确保 `aboutToDisappear` 中释放所有资源（定时器、动画、传感器），避免被系统冻结前未正确清理。

#### 2.7.2 网络能力限制

手表端网络能力与手机差异显著：

| 约束项 | 说明 | EasyRandom 对应 |
|--------|------|:--------------:|
| 蜂窝数据 | 少数手表支持 eSIM，不普遍 | — |
| Wi-Fi | 多数手表无独立 Wi-Fi | — |
| 网络中转 | 依赖蓝牙 → 手机中转，延迟 >300ms | — |
| BLE 带宽 | 低功耗蓝牙带宽有限 | — |
| **离线优先** | **手表应用应完全离线工作**，网络为增强功能 | ✅ 已满足（本项目纯本地随机） |

> **对 EasyRandom 的影响**：本项目所有功能均为纯本地随机运算，不依赖网络，完全符合手表端"离线优先"原则。

#### 2.7.3 性能指标要求

官方对穿戴应用有明确的性能要求：

| 指标 | 要求 | EasyRandom 对应 | 备注 |
|------|------|:--------------:|------|
| 冷启动时间 | < 1 秒 | ✅ 轻量单页面 | 避免在启动时做重计算 |
| 内存占用 | < 100MB | ✅ 无大内存操作 | Canvas 转盘需注意释放 |
| 帧率 | 稳定 60fps | ⚠️ Canvas 动画需优化 | 转盘旋转/硬币翻转需关注 |
| 安装包 | < 10MB | ⚠️ 需控制图片资源量 | 图片按需压缩/分级加载 |
| 页面数量 | 尽量少 | ✅ 单页面 | ArcSwiper 内 8 个子组件 |

#### 2.7.4 数据持久化策略（两阶段演进）

> 📄 **关联文档**：跨设备同步的完整方案见 [`docs/wearable-sync-plan.md`](./wearable-sync-plan.md)，本小节仅简述策略演进的路线图。

##### 阶段概览

```
Phase 1（当前）                     Phase 2（规划）
 ┌──────────────────┐              ┌──────────────────────────────────┐
 │  Preferences（本地）│    ──→     │  Distributed KV Store（跨设备）    │
 │  • 木鱼计数        │              │  • 转盘数据 手机→手表 自动同步     │
 │  • 转盘自定义数据   │              │  • 木鱼计数 双向同步 + 冲突合并   │
 │  • 零网络依赖       │              │  • 离线队列 + 联网自动重放       │
 └──────────────────┘              └──────────────────────────────────┘
```

##### Phase 1：本地持久化（当前实现）

手表端直接使用轻量 KV 存储，与手机端 API 一致：

| 维度 | 约束 | EasyRandom 实现 |
|------|------|:--------------:|
| **存储引擎** | `@ohos.data.preferences`，不用 `RelationalStore`（过重） | ✅ 木鱼计数 + 转盘自定义数据 |
| **数据量** | 仅木鱼计数和转盘自定义数据，< 10 KB | ✅ Preferences 足够 |
| **加密** | 非敏感数据 | ✅ 无需加密 |
| **网络** | 零依赖 | ✅ 完全离线可用 |

**实现位置**：

| 数据 | 存储 Key | 读写组件 | 说明 |
|------|---------|---------|------|
| 木鱼敲击计数 | `muyu_tap_count` | `WearBlessingMuyu.ets` | `aboutToAppear` 加载，每次敲击写入 |
| 转盘自定义数据 | `turntable_custom_data` | `WearRollDataManager.ets` | JSON 序列化存储，包含选项列表 |

```typescript
// 木鱼计数持久化示例（WearBlessingMuyu.ets 中）
import preferences from '@ohos.data.preferences';

private async loadTapCount(): Promise<void> {
  const prefs = preferences.getPreferencesSync(getContext(this), { name: 'muyu_prefs' });
  this.tapCount = prefs.getSync('tap_count', 0) as number;
}

private async saveTapCount(): Promise<void> {
  const prefs = preferences.getPreferencesSync(getContext(this), { name: 'muyu_prefs' });
  prefs.putSync('tap_count', this.tapCount);
  prefs.flush();
}
```

##### Phase 2：手机端数据导入（规划，P1）

用户在手机端编辑转盘数据后，需要手表端能同步使用。详见 [`docs/wearable-sync-plan.md`](./wearable-sync-plan.md)。

**核心方案**：`@ohos.data.distributedKVStore`（Distributed KV Store）

| 目标 | 说明 | 优先级 |
|------|------|:------:|
| 转盘数据同步 | 手机编辑 → 手表自动同步 | P0 |
| 木鱼计数同步 | 多设备敲击计数合并 | P1 |
| 离线支持 | 离线时本地缓存，联网后自动重放 | P2 |
| 冲突处理 | 多设备同时编辑时的数据一致性 | P1 |

**数据流**：

```
手机端                             手表端
  │                                  │
  ├─ 编辑转盘/敲木鱼                  │
  │                                  │
  ▼                                  │
┌─────────────────┐                  │
│   Preferences    │                  │
│     (本地)       │                  │
└────────┬────────┘                  │
         │                            │
         ▼                            ▼
┌─────────────────────────────────────────┐
│      Distributed KV Store              │
│      "EasyRandom_Sync"                │
│    • autoSync: true                   │
│    • 同华为账号自动发现 & 同步          │
└─────────────────────────────────────────┘
         │                            │
         ▼                            ▼
    手机端监听                    手表端监听
    dataChange                   dataChange
         │                            │
         ▼                            ▼
    更新 UI                     更新 UI
```

**同步的 KV 键值设计**：

| Key | 类型 | 方向 | 说明 |
|-----|------|:----:|------|
| `turntable_data` | JSON string | 手机 → 手表 | 转盘列表 + 选中状态 |
| `muyu_data` | JSON string | 双向 | 各设备敲击计数（按 deviceId 拆分） |

**Phase 2 需要的前置条件**：

| 条件 | 状态 | 说明 |
|------|:----:|------|
| `common/SyncManager` 模块 | ⏳ 待创建 | 单例管理器，封装 KV Store 初始化/读写/监听 |
| 权限 `DISTRIBUTED_DATASYNC` | ⏳ 待配置 | 手机端 + 手表端 `module.json5` 均需添加 |
| 权限 `ACCESS_SERVICE_DM` | ⏳ 待配置 | 设备发现所需 |
| 数据模型对齐 | ⚠️ 需确认 | 手机端 `Roll`/`RollItem` → 同步格式 `SyncRoll` 的序列化逻辑 |
| 手机端写入接入 | ⏳ 待开发 | 在 `RollPage` 保存转盘时同步写入 KV Store |

**演进路线**：

```
v1.0.19（当前）
  └── Phase 1：Preferences 本地存储 ✅
        └── 木鱼计数可离线使用，转盘数据手表端独立

v1.1.x（下一版本）
  └── Phase 2.1：SyncManager 基础设施
        └── common/ 下创建模块，手机+手表双端接入

v1.2.x
  └── Phase 2.2：转盘数据 P0 同步
        └── 手机编辑 → 手表端自动刷新

v1.3.x
  └── Phase 2.3：木鱼计数 P1 + 离线 P2
        └── 双向同步 + 冲突合并 + 离线队列
```

> ⚠️ **重要约束**：Distributed KV Store 必须同华为账号 + 同 Wi-Fi 网络，首次同步需要网络。手表端始终保留 Preferences 作为本地缓存，即使离线也能使用缓存数据。

### 2.8 暗黑模式适配（P1 补充）

手表端默认通常为**深色背景**（省电、AMOLED 屏特性），但文档完全没有讨论暗黑模式：

| 需求 | 说明 | 实施要点 |
|------|------|---------|
| 手表默认深色 | 系统默认为深色主题，节省 AMOLED 电量 | 手表端 UI 应以深色为默认基调设计 |
| 颜色 Token 分离 | `resources/base/element/color.json` 需同时定义 light 和 dark 资源 | 在 `resources/dark/element/color.json` 中定义深色色值 |
| 避免硬编码颜色 | 当前代码中部分颜色直接硬编码（如 `'#FF5EA1FF'`） | 改用 `$r('app.color.xxx')` 引用资源色 |
| 系统字体令牌 | 优先使用系统字体令牌实现自动缩放 | 使用 `$r('sys.font.xxx')` 引用系统字体 |
| prefersDarkMode | 可通过 `AppStorage` 监听系统暗黑模式变化 | `AppStorage.watch('colorMode', callback)` |

**实施原则**：

```typescript
// ❌ 避免：硬编码颜色（暗黑模式下不协调）
Text('Hello').fontColor('#333333')

// ✅ 推荐：使用资源颜色（自动适配 light/dark）
Text('Hello').fontColor($r('app.color.font_primary'))

// ✅ 推荐：使用系统颜色（自动跟随系统主题）
Text('Hello').fontColor($r('sys.color.ohos_id_color_text_primary'))
```

> **对 EasyRandom 的影响**：当前 `ArcDotIndicator` 等颜色使用硬编码（如 `'#FF5EA1FF'`），需迁移为资源颜色。建议手表端 UI 直接按深色主题设计，light 模式作为次要适配。

### 2.9 横阔屏适配（超新星 X1）

部分儿童手表采用**横阔屏**设计（屏幕宽度 > 高度），典型代表为**华为超新星 X1**（1.82" AMOLED，480×408 px，可 360° 旋转表体）。

#### 横阔屏与方屏的核心差异

| 维度 | 普通方屏（近似正方形） | 横阔屏（如超新星 X1） | 影响 |
|------|----------------------|----------------------|------|
| 宽高比 | ~1:1 | **>1.1:1**（X1 约 1.18:1） | 内容被横向拉伸，纵向空间更紧张 |
| 按钮区域 | 上下均可放置操作按钮 | 更宽，适合横向排列按钮 | 布局方向需调整 |
| 屏幕旋转 | 固定佩戴方向 | 表体可 360° 旋转 + 上下翻转 | 需确保布局在任何方向都可用 |
| Swiper 方向 | 横向为主 | 横阔屏横向 space 更大，也可考虑纵向 | 手势区域宽度更大，更易操作 |

#### 适配策略

**Step 1：在 WearScreenUtil 中新增 `isWideScreen()` 判断**

```typescript
// ✅ 已在 §2.3 WearScreenUtil 中新增
static isWideScreen(): boolean {
  return this.screenWidth > this.screenHeight;
}
```

**Step 2：横阔屏专属布局调整**

```typescript
// product/wearable/src/main/ets/pages/Index.ets
aboutToAppear() {
  this.isRound = WearScreenUtil.isRoundScreen();
  this.isWide = WearScreenUtil.isWideScreen();  // 新增
}

build() {
  if (this.isRound) {
    // 圆屏：ArcSwiper 弧形排列
    this.buildRoundLayout();
  } else if (this.isWide) {
    // 横阔屏：横向空间充足，按钮可横排
    this.buildWideLayout();
  } else {
    // 普通方屏：标准 Swiper
    this.buildSquareLayout();
  }
}

@Builder
buildWideLayout() {
  Swiper({ controller: this.swiperController }) {
    // 横阔屏：主内容区可以更宽
    Column() {
      Image($r('app.media.dice1'))
        .width('65%')   // 比普通方屏（55%）更宽
      Text('随机结果')
        .fontSize(52)   // 横阔屏字号可稍大
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

**Step 3：避免硬编码宽高**

```typescript
// ❌ 避免：硬编码宽高，横阔屏上表现差
Component() {
  Image($r('app.media.xxx'))
    .width(180)   // 180vp 在横阔屏上显得很小
}

// ✅ 推荐：使用百分比 + 条件渲染
Component() {
  Image($r('app.media.xxx'))
    .width(this.isWide ? '65%' : '55%')
}
```

#### 超新星 X1 专项注意

| 注意点 | 说明 | 应对措施 |
|--------|------|---------|
| **表体可旋转** | 用户可能横戴、竖戴、倒戴 | 所有布局用百分比/自适应，不用硬编码方向 |
| **480×408 短边 408vp** | 归为 `standard` 尺寸，但纵向空间更紧张 | 纵向内容控制在 5 行以内，超出则滚动 |
| **横阔屏手势区域更大** | 横向滑动手势更容易触发 | Swiper 的 `indicator` 区域注意不遮挡内容 |
| **儿童手表** | 目标用户为儿童，交互需更简单 | 按钮尺寸不低于 `minTouchSize`（48vp） |

> ⚠️ **待验证**：在 DevEco 模拟器中添加 480×408 自定义设备，运行现有 prototype 验证布局表现，再根据实测结果调整 Token 值。

---

## 3. 圆/方屏适配架构

### 3.1 适配架构：四层模型

**一句话总结**：容器层分叉（ArcSwiper vs Swiper），内容层共用（同一套 Wear 组件），所有差异收敛到数值 Token。

```
                    第 1 层：检测层
    ┌──────────────────────────────────────┐
    │   display.getDefaultDisplaySync()    │
    │   .screenShape                       │
    │                                      │
    │   ScreenShape.ROUND → 圆形路线       │
    │   ScreenShape.RECTANGLE → 方形路线   │
    │   (API < 18 → 默认方形)               │
    └──────┬───────────┬───────────────────┘
           │           │
           ▼           ▼
    第 2 层：容器层（唯一分叉的地方）
    ┌───────────────┐ ┌───────────────────┐
    │  圆形屏容器    │ │  方形屏容器        │
    │               │ │                   │
    │  ArcSwiper    │ │  Swiper           │
    │  ArcDotIndi-  │ │  indicator(true)  │
    │  cator (6点)  │ │  loop(true)       │
    │  表冠灵敏度    │ │  无表冠            │
    │  EdgeEffect.  │ │  Stretch模式      │
    │  Spring       │ │  四角全利用        │
    │  自动弧形裁切  │ │                   │
    └──────┬────────┘ └────────┬──────────┘
           │                   │
           └────────┬──────────┘
                    ▼
    第 3 层：内容层（完全共用，零分支）
    ┌──────────────────────────────────────┐
    │   共用的 Wear 功能组件（8 个）         │
    │                                      │
    │   WearRollDices    WearFlipCoin      │
    │   WearRandomABCD   WearDevineBaGua   │
    │   WearRollWheel    WearRandomColors  │
    │   WearBlessingMuyu                   │
    │                                      │
    │   每个组件自己不判断圆/方，             │
    │   只读 WearScreenUtil 的 Token        │
    └──────────────────┬───────────────────┘
                       ▼
    第 4 层：工具层（Token 中枢）
    ┌──────────────────────────────────────┐
    │   WearScreenUtil                     │
    │                                      │
    │   isRoundScreen()  ← 形状            │
    │   screenSize       ← 尺寸分级        │
    │   safePadding      ← Token           │
    │   mainImageWidth   ← Token           │
    │   resultFontSize   ← Token           │
    │   scaledSize(基准)  ← Canvas 缩放     │
    └──────────────────────────────────────┘
```

**为什么这样设计**：

- **四层职责清晰**：检测层判断走哪条路，容器层做分叉，内容层专注功能逻辑，工具层提供自适应数值
- **圆形屏**：ArcSwiper 让子组件沿圆弧排列，自带弧形裁切和 ArcDotIndicator，表冠旋转翻页。所有"手表专属"行为收敛在容器层
- **方形屏**：标准 Swiper 线性排列，四角区域可以充分利用，不需要裁切
- **子组件零分支**：Wear 组件内部没有 `if (isRound)` 判断，所有差异收敛到 Token 的数值差异

### 3.2 Index.ets 双屏适配实现

```typescript
// product/wearable/src/main/ets/pages/Index.ets
import {
  ArcSwiper,              // v3.5：@kit.ArkUI 自动 re-export，无需手动注册
  ArcSwiperController,
  ArcDotIndicator,
  ArcDirection
} from '@kit.ArkUI';
// CrownSensitivity 为全局枚举，API 18+ 自动可用，无需 import
import { WearScreenUtil } from '../utils/WearScreenUtil';
import { WearRollDices } from '../sub_pages/WearRollDices';
import { WearFlipCoin } from '../sub_pages/WearFlipCoin';
import { WearRandomABCD } from '../sub_pages/WearRandomABCD';
import { WearDevineBaGua } from '../sub_pages/WearDevineBaGua';
import { WearRollWheel } from '../sub_pages/WearRollWheel';
import { WearRandomColors } from '../sub_pages/WearRandomColors';
import { WearBlessingMuyu } from '../sub_pages/WearBlessingMuyu';
import { WearTruthOrDare } from '../sub_pages/WearTruthOrDare';

@Entry
@Component
struct Index {
  @State isRound: boolean = WearScreenUtil.isRoundScreen();
  @State currentIndex: number = 0;

  // 弧形指示器（圆形屏专用）
  private arcIndicator: ArcDotIndicator = new ArcDotIndicator()
    .arcDirection(ArcDirection.SIX_CLOCK_DIRECTION)
    .itemColor('#A9FFFFFF')
    .selectedItemColor('#FF5EA1FF');

  // ArcSwiper 专用控制器（圆形屏）
  private arcController: ArcSwiperController = new ArcSwiperController();

  build() {
    if (this.isRound) {
      // ========== 圆形屏布局：ArcSwiper ==========
      ArcSwiper(this.arcController) {
        WearRollDices()
        WearFlipCoin()
        WearRandomABCD()
        WearDevineBaGua()
        WearRollWheel()
        WearRandomColors()
        WearBlessingMuyu()
        WearTruthOrDare()
      }
      .width('100%')
      .height('100%')
      .index(0)
      .duration(300)
      .indicator(this.arcIndicator)
      .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
      .effectMode(EdgeEffect.Spring)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    } else {
      // ========== 方形屏布局：标准 Swiper ==========
      Column() {
        Swiper() {
          WearRollDices()
          WearFlipCoin()
          WearRandomABCD()
          WearDevineBaGua()
          WearRollWheel()
          WearRandomColors()
          WearBlessingMuyu()
          WearTruthOrDare()
        }
        .indicator(true)
        .loop(true)
        .duration(300)
        .displayMode(SwiperDisplayMode.Stretch)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}
```

**圆形屏 ArcSwiper 关键配置说明**：
- `ArcSwiper` 自带弧形排列，无需手动 `.clip(true).borderRadius('50%')` 裁切
- `ArcDotIndicator` 设在 6 点钟方向（底部），符合手表自然阅读方位
- `digitalCrownSensitivity(CrownSensitivity.MEDIUM)` 开启表冠旋转翻页
- `effectMode(EdgeEffect.Spring)` 滑动到达边缘时弹簧回弹，体验优于 Fade
- `duration(300)` 比默认 400ms 稍快，手表端更敏捷

**方形屏 Swiper 关键配置**：
- 标准 `Swiper` 组件，无弧形排列、无表冠交互、无 ArcDotIndicator
- `indicator(true)` 使用默认线形指示器
- `loop(true)` 无限循环，与 ArcSwiper 行为保持一致

### 3.3 Wear 功能组件内部适配模式

**适配策略：三层递进**

```
第一层：vp/fp 单位          → ArkUI 框架自动处理 DPI 缩放（基线保障）
第二层：百分比布局           → 容器/图片宽度自适应屏幕（'55%' / '70%'）
第三层：WearScreenUtil Token → 字号/间距/边距按屏幕分级取值（精细控制）
```

每个 Wear 组件内部通过 `WearScreenUtil` 读取当前屏幕的形状+尺寸，统一取值：

```typescript
// 以 WearRollDices 为例
@Component
export struct WearRollDices {
  build() {
    Column() {
      Image(this.diceImage)
        .width(WearScreenUtil.mainImageWidth)   // 圆形屏 55%/48%，方形屏 70%/62%
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      left: WearScreenUtil.safePadding,         // 圆形屏 24/18vp，方形屏 12/8vp
      right: WearScreenUtil.safePadding
    })
  }
}
```

```typescript
// 以 WearRandomABCD 为例（有字号的组件）
@Component
export struct WearRandomABCD {
  build() {
    Column() {
      Row() {
        Text('A').fontSize(WearScreenUtil.resultFontSize)  // small 40fp, standard 48fp
        Text('B').fontSize(WearScreenUtil.resultFontSize)
      }
      Row() {
        Text('C').fontSize(WearScreenUtil.resultFontSize)
        Text('D').fontSize(WearScreenUtil.resultFontSize)
      }
    }
    .width(WearScreenUtil.contentWidthRatio)
    .height(WearScreenUtil.contentWidthRatio)
  }
}
```

```typescript
// 以 WearRollWheel 为例（Canvas 需要精确尺寸）
@Component
export struct WearRollWheel {
  build() {
    Column() {
      Canvas(this.context)
        .width(WearScreenUtil.scaledSize(260))    // 基准 260vp，按屏幕比例缩放
        .height(WearScreenUtil.scaledSize(260))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

```typescript
// 以 WearBlessingMuyu 为例（圆形屏用 ArcButton 贴合边缘）
import { ArcButtonPosition } from '@kit.ArkUI';
// ArcButton 组件名在 import 后自动注册

@Component
export struct WearBlessingMuyu {
  // 圆形屏下 ArcButton 沿底部弧形边缘排列
  @Builder
  buildRoundButton() {
    ArcButton({
      position: ArcButtonPosition.BOTTOM_EDGE  // 贴合底部弧形边缘
    }) {
      Text('敲')
        .fontSize(WearScreenUtil.buttonFontSize)
        .fontColor(Color.White)
    }
    .width(WearScreenUtil.minTouchSize)        // 最小触摸区 48vp
    .height(WearScreenUtil.minTouchSize)
    .onClick(() => this.tapMuyu())
  }

  // 方形屏下用标准 Button
  @Builder
  buildSquareButton() {
    Button('敲')
      .fontSize(WearScreenUtil.buttonFontSize)
      .fontColor(Color.White)
      .width(WearScreenUtil.minTouchSize)
      .height(WearScreenUtil.minTouchSize)
      .borderRadius(WearScreenUtil.minTouchSize / 2)  // 圆形按钮
      .onClick(() => this.tapMuyu())
  }

  build() {
    Stack() {
      Image($r('app.media.MuYu'))
        .width(WearScreenUtil.mainImageWidth)  // 圆形=55%，方形=70%
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)

      // 圆形屏：ArcButton 贴底部弧形边缘；方形屏：标准 Button 在右下角
      // （容器层通过 isRound() 选择使用 buildRoundButton / buildSquareButton）
    }
    .width('100%')
    .height('100%')
  }
}
```

> ⚠️ **ArcButton 使用要点**：
> - `ArcButtonPosition.TOP_EDGE` / `BOTTOM_EDGE`：仅圆形屏有效，方形屏下会退化为普通 Button
> - `ArcButtonOptions`：圆形屏可设弧形按钮的弧度和位置偏移
> - 建议按钮放在 `Stack` 布局中，不影响中心内容区的布局

**适配规则**：
- **容器宽度**：用百分比（`'100%'`），Swiper 会自动撑满
- **主元素尺寸**：用 `WearScreenUtil.mainImageWidth`（百分比 Token，按形状+尺寸分级）
- **字号**：用 `WearScreenUtil.resultFontSize` / `subFontSize`（fp 值 Token）
- **间距/边距**：用 `WearScreenUtil.safePadding` / `listItemSpace`（vp 值 Token）
- **Canvas 精确尺寸**：用 `WearScreenUtil.scaledSize(基准值)`（自动按屏幕比例缩放，下限 70%）
- **触摸区域**：用 `WearScreenUtil.minTouchSize`（恒定 48vp，不随屏幕缩小）
- **交互逻辑**：完全一致，零适配

### 3.4 圆形屏专用 Arc 组件使用场景

| 场景 | 是否使用 Arc 组件 | 说明 |
|------|:---------------:|------|
| 主页功能切换（横向轮播） | ✅ **必须** | 圆形屏用 `ArcSwiper`（弧形排列+表冠+ArcDotIndicator），方形屏用标准 `Swiper` |
| 幸运转盘内部纵向滚动 | ⚠️ 可选 | 转盘数量 >5 时用 `ArcSwiper({ vertical: true })` 或 `ArcList`；数量少则纵向 Swiper 足够 |
| 功能页内的操作按钮 | ✅ 推荐 | 圆形屏用 `ArcButton` 贴合边缘（如"再来一次"按钮），方形屏用 `Button` |
| 设置页/列表页（未来） | ✅ 必须 | 列表滚动场景，圆形屏必须用 `ArcList` |

### 3.5 关键设计原则

以上架构遵循三条铁律：

**原则一：形状决定组件选择，尺寸决定数值大小**

```
选 ArcSwiper 还是 Swiper？  → 看 isRound()（形状）
safePadding 是 24vp 还是 12vp？ → 看 isRound()（形状）
字号是 40fp 还是 48fp？       → 看 screenSize（尺寸）
```

一个 Token 的取值路径：`isRound() ? roundValue : squareValue`，再按 `screenSize` 微调。代码逻辑本身完全一样，只是取到的数值不同。

**原则二：子组件尽量减少分支**

```typescript
// ✅ 推荐：组件内部尽量通过 Token 消除分支
.width(WearScreenUtil.mainImageWidth)   // 圆形=55%，方形=70%
.fontSize(WearScreenUtil.resultFontSize) // small=40，standard=48

// ⚠️ 允许有限分支：当组件类型本身存在圆形/方形本质差异时
// 例：圆形屏用 ArcButton，方形屏用 Button
@Builder
buildRoundButton() {
  ArcButton({ position: ArcButtonPosition.BOTTOM_EDGE }) { ... }
}

@Builder
buildSquareButton() {
  Button('敲') { ... }
}
```

**修正说明**：当组件差异大到 `ArcButton` vs `Button` 这种程度时，"零分支"是不现实的。**容器层**已经做了分叉（ArcSwiper vs Swiper），但按钮这种局部差异强行压入"零分支"会导致代码扭曲。修正后的原则：子组件尽量避免形状分支，但当组件类型本身存在圆形/方形差异时（ArcButton vs Button），允许在组件内部做有限分支，分支逻辑集中在 `@Builder` 方法中。

**原则三：新增设备只需补 Token**

未来如果出现新的屏幕类型（如 480×480 的圆形屏、超大方屏），只需：

1. `WearScreenUtil.screenSize` 增加分级条件
2. 所有 Token 的 getter 增加相应分支的数值
3. 完成后，现有的 8 个 Wear 组件、Index.ets 全部自动适配，不需要改动任何业务代码

```
工作量对比：
  传统方案：改 7 个组件 + Index.ets + 测试 → 8+ 个文件
  本方案：  改 1 个 WearScreenUtil 文件 → 1 个文件
```

---

## 4. 交互设计

### 4.1 核心交互模型：横向切换 + 纵向浏览

**圆形屏**：
```
┌─────────────────────────────┐
│  ╭──── 圆形手表屏 ────╮     │
│  │                    │     │
│  │    ←  掷骰子  →    │     │  ← ArcSwiper：弧形排列的轮播容器
│  │    (点击摇骰)      │     │    子组件沿圆弧轨迹分布
│  │                    │     │    ArcDotIndicator (6点方向)
│  │  表冠旋转翻页       │     │    digitalCrownSensitivity
│  ╰────────────────────╯     │
└─────────────────────────────┘
```

**方形屏**：
```
┌──────────────────┐
│                  │
│  ←  掷骰子  →    │  ← 标准 Swiper：线性排列
│  (点击摇骰)      │    indicator (底部线形)
│                  │
│                  │
└──────────────────┘
```

**设计理念**：
- **横向 Swiper**：左右滑动切换不同的随机工具（掷骰子 → 硬币 → ABCD → …）。圆形屏用 `ArcSwiper`（弧形排列+表冠），方形屏用标准 `Swiper`
- **纵向 Swiper**：在支持多数据的功能内（如幸运转盘），上下滑动切换不同数据实例
- **点击交互**：每个组件本身就是"点击触发随机"的，天然适配手表操作
- **圆/方屏差异**：容器层组件完全不同（ArcSwiper vs Swiper），但功能组件共用

### 4.2 功能组件映射

| 优先级 | 横向页签 | 手表端组件（新建） | 参考来源 | 纵向数据 | 圆形屏适配要点 | 方形屏适配要点 |
|:-----:|---------|-------------------|---------|---------|---------------|---------------|
| **P0** | 幸运转盘 | `WearRollWheel` | `RollWheelCardDisplay` | 多个转盘 | Canvas `scaledSize(260)`，纵向 Swiper 切转盘 | Canvas `scaledSize(260)` |
| **P0** | 祝福木鱼 | `WearBlessingMuyu` | `BlessingMuyuCardDisplay` | 单页 | `mainImageWidth`(55%) + `ArcButton` | `mainImageWidth`(70%) + `Button` |
| **P0** | 真心话大冒险 | `WearTruthOrDare` 🆕 | `HonestOrChallenge` | 单页（两模式内切换） | 上下分屏（真心话上/大冒险下），点击选用透明背景包裹文字区域 | 同左，标准 Button |
| P1 | 掷骰子 | `WearRollDices` | `RollDiceCardDisplay` | 单页 | `mainImageWidth`(55%) + `safePadding`(24vp) | `mainImageWidth`(70%) + `safePadding`(12vp) |
| P1 | 丢硬币 | `WearFlipCoin` | `FlipCoinCardDisplay` | 单页 | `mainImageWidth`(55%)，旋转动画保持 | `mainImageWidth`(70%) |
| P1 | ABCD | `WearRandomABCD` | `ABCDCardDisplay` | 单页 | 去掉指针，四格直铺点击，`resultFontSize`(48fp) | 四格直铺，`resultFontSize`(48fp) |
| P2 | 八卦 | `WearDevineBaGua` | `BaGuaCardDisplay` | 单页 | `mainImageWidth`(55%) | `mainImageWidth`(70%) |
| P2 | 随机颜色 | `WearRandomColors` | `RandomColorsCardDisplay` | 单页 | 全屏着色 + `safePadding` 安全区内文字 | 全屏着色 |

> ⚠️ 上表中括号内的数值为 **standard 尺寸**下的参考值（small 尺寸会自动缩小，见 §2.5 Token 查速表）。开发时直接引用 Token 名，不要硬编码数值。

### 4.3 手表主页架构

整个手表端**只需要一个页面** `Index.ets`，通过 `WearScreenUtil` 自动适配圆/方屏。完整代码见 [§3.2 Index.ets 双屏适配实现](#32-indexets-双屏适配实现)。核心差异：

| 维度 | 圆形屏 | 方形屏 |
|------|--------|--------|
| 轮播容器 | `ArcSwiper` | `Swiper` |
| 控制器 | `ArcSwiperController` | 内置 |
| 指示器 | `ArcDotIndicator` (弧形，6点方向) | `indicator(true)` (线形) |
| 表冠 | `digitalCrownSensitivity(MEDIUM)` | 不支持 |
| 边缘效果 | `EdgeEffect.Spring` | 默认 |
| 裁切 | ArcSwiper 自带弧形排列 | 无需裁切 |

### 4.4 关键优势

1. **零页面路由** — 只有一个 `pages/Index`，不需要 router 导航
2. **参考而非复用** — 手表端组件独立建立，可针对手表屏做充分适配，不受手机端代码约束
3. **纵向 Swiper 已验证** — `RollWheelCardDisplay` 的纵向 Swiper 模式已在线上跑通
4. **解耦维护** — 手机端改 CardDisplay 不影响手表端，手表端适配不污染手机端
5. **圆/方屏双适配** — 容器层分叉 + 内容层共用，一套功能组件代码覆盖两种屏幕

### 4.5 P0 功能优先级规划

**决策时间**：2026-06-10

#### 优先级定义

| 级别 | 含义 | 判定标准 |
|:----:|------|---------|
| **P0** | 核心必做 | 有独立交互模型、不可被其他功能替代、用户高频使用 |
| P1 | 重要增强 | 与已有功能交互模式相近、实现成本低 |
| P2 | 选择优化 | 锦上添花、或与 P0/P1 功能模式重复度高 |

#### P0 功能一览

| 功能 | 组件 | 当前状态 | 核心交互 | 手机端参考 |
|------|------|:------:|---------|----------|
| **幸运转盘** | `WearRollWheel` | ✅ 已实现 | 点击旋转 Canvas 转盘，纵向 Swiper 切换多个转盘 | `RollWheelCardDisplay` |
| **祝福木鱼** | `WearBlessingMuyu` | ✅ 已实现 | 点击敲木鱼 + 计数持久化 + 祝福语气泡动画 | `BlessingMuyuCardDisplay` |
| **真心话大冒险** | `WearTruthOrDare` 🆕 | 📋 规划中 | 上下分屏双模式，点击直接出结果 | `HonestOrChallenge` |

#### 为什么这三个是 P0？

```
幸运转盘 ─── 唯一支持多数据切换的功能（纵向 Swiper）
              手机端累计使用数据最高

祝福木鱼 ─── 唯一有持久化计数的功能（Preferences）
              适合碎片化、重复性操作场景

真心话大冒险 ─ 唯一基于文本题库的功能（纯文字展示）
               社交聚会场景的杀手功能
```

三个功能分别覆盖了手表随机工具的三个差异化维度：**多数据**（转盘）、**持久化**（木鱼）、**纯文本**（真心话大冒险）。

#### P0 已实现优化项

| 优化项 | 涉及文件 | 状态 | 说明 |
|--------|---------|:----:|------|
| RollWheel 内部 Swiper 纵向化 | `WearRollWheel.ets` | ✅ v3.8 | 圆形屏 ArcSwiper(vertical) + 方形屏 Swiper(.vertical(true)) |
| 圆/方屏双适配 | `Index.ets` + 全部子组件 | ✅ v3.5 | 容器层分叉，内容层共用 Token |
| 功耗优化 | 各组件 `aboutToDisappear` | ⚠️ 部分 | 需在全部组件中补充 `aboutToDisappear` 资源释放 |

#### P0 待实现

| 任务 | 优先级 | 说明 |
|------|:------:|------|
| 🆕 **WearTruthOrDare 组件开发** | P0 | 见 §4.6 详细方案 |
| 🔧 RollWheel Canvas 旋转动画性能优化 | P0 | 当前动画可能掉帧，需 `OffscreenCanvas` + 帧率控制 |
| 🔧 Muyu 震动反馈对接 | P0 | VIBRATE 权限已配置，需接入 `VibratorManager` |
| ⚠️ 全部 P0 组件补充 `aboutToDisappear` 资源释放 | P0 | 遵循 §2.6 功耗优化策略 |
| ⚠️ Index.ets 侧滑手势冲突验证 | P0 | 遵循 §6 问题6 方案验证 |

### 4.6 真心话大冒险手表端适配方案 🆕

#### 4.6.1 手机端现状（参考）

| 维度 | 手机端 `HonestOrChallenge` | 手表端需改动 |
|------|--------------------------|------------|
| 数据源 | `static_datas/challenges.ets` — `honests[]` (真心话) + `challenges[]` (大冒险) | **共用同一数据文件**（从 `@ohos/common` 或独立复制） |
| 选择方式 | 旋转指针 + 双按钮（真心话/大冒险） | 简化为 **单手点击**（手表旋转指针不实用） |
| 结果展示 | `promptAction.openCustomDialog` 弹窗 | **直接展示**在屏幕中央（手表无弹窗） |
| 页面结构 | 独立路由页面 + header + 返回键 | **嵌入 Swiper**，与其它功能页同级 |
| 震动反馈 | `VibratorManager.vibrateResult()` | 同左（权限已预留） |

#### 4.6.2 手表端交互设计

```
┌──────────────────────────┐   ┌──────────────────────────┐
│     圆形屏 (ArcSwiper)    │   │     方形屏 (Swiper)       │
│                          │   │                          │
│   ╭──────────────────╮   │   │   ┌──────────────────┐   │
│   │    ┌─────────┐   │   │   │   │    真心话        │   │
│   │    │ 真心话   │   │   │   │   │  (点击出题)      │   │
│   │    └─────────┘   │   │   │   │                  │   │
│   │         x         │   │   │   │──────────────   │   │
│   │    ┌─────────┐   │   │   │   │                  │   │
│   │    │ 大冒险   │   │   │   │   │    大冒险        │   │
│   │    └─────────┘   │   │   │   │  (点击出题)      │   │
│   ╰──────────────────╯   │   │   └──────────────────┘   │
│                          │   │                          │
│  [结果文字直接展示在中央]  │   │  [结果文字直接展示在中央]  │
└──────────────────────────┘   └──────────────────────────┘
```

**核心交互流程**：

1. 页面加载 → 上半屏"真心话"区域、下半屏"大冒险"区域（或左右分屏，视屏幕形状而定）
2. 点击"真心话"区域 → 从 `honests[]` 随机取一条 → **直接替换**该区域显示结果文字 → 震动反馈
3. 点击"大冒险"区域 → 从 `challenges[]` 随机取一条 → **直接替换**该区域显示结果文字 → 震动反馈
4. 再次点击同一区域 → 重新随机（避免连续重复同一结果）

**手表端简化原则**：

| 简化项 | 说明 |
|--------|------|
| **无旋转指针** | 手机端转盘指针在手表上操作精度不够，改为直接分屏点击 |
| **无弹窗** | `promptAction.openCustomDialog` 在手表端不可用/不推荐，结果直接替换显示 |
| **无路由** | 作为 Swiper 的一个子页面，不需要 `router.pushUrl` |
| **无 header** | 手表屏太小，不浪费空间放标题栏 |
| **文本自适应** | 结果文字过长时自动缩小字号或滚动（`maxLines` + `textOverflow`），手表屏幕文字区域极小 |
| **防止重复** | 连续两次不出同一结果（简单去重逻辑） |

#### 4.6.3 数据源策略

```
方案 A：腕表端独立复制 challenges.ets
  优点：解耦，手表端可独立控制题库
  缺点：数据重复维护

方案 B：从 @ohos/common 共享导出（推荐）
  优点：单一数据源，手机手表同步更新
  缺点：需在 @ohos/common 中新建数据文件或扩展导出
```

**当前建议**：先使用方案 A（独立复制），快速实现。后续手机端题库更新时，手动同步到手表端。

#### 4.6.4 数据结构

```typescript
// product/wearable/src/main/ets/utils/WearTruthOrDareData.ets (手表端独立数据文件)
export const honests: string[] = [
  "你最近一次撒谎是什么时候？说的是什么？",
  "你最害怕失去什么？",
  "你做过最尴尬的事情是什么？",
  "你暗恋过谁？",
  "你最想改掉的坏习惯是什么？",
  "你在公共场合做过最丢脸的事是什么？",
  "你做过最冒险的事情是什么？",
  "如果可以回到过去，你最想改变什么？",
  "你最不想让别人知道的秘密是什么？",
  "你上一次哭是什么时候？为什么？",
];

export const challenges: string[] = [
  "用新闻联播的腔调进行一分钟即兴演讲",
  "给未在场的朋友的朋友圈点赞，从第一条开始，一直点到最新的一条",
  "用方言给 1 个人打电话聊一分钟",
  "做一个大家都觉得很丑的鬼脸，并保持 10 秒钟",
  "蒙眼涂口红",
  "单脚站立 3 分钟",
  "给朋友打电话，唱《青藏高原》的高音部分",
  "一口气喝完一瓶矿泉水",
  "和在场的一位异性对视 10 秒",
  "模仿一位在场的人，让大家猜是谁",
];
```

#### 4.6.5 伪代码骨架

```typescript
// product/wearable/src/main/ets/sub_pages/WearTruthOrDare.ets
import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';
import { honests, challenges } from '../utils/WearTruthOrDareData';
import { VibratorManager } from '@ohos/vibratorutil';

@Component
export struct WearTruthOrDare {
  @State honestText: string = '真心话';
  @State challengeText: string = '大冒险';
  @State lastHonestIndex: number = -1;
  @State lastChallengeIndex: number = -1;

  private getRandomText(source: string[], lastIndex: number): { text: string, index: number } {
    let idx = Random(0, source.length - 1, true);
    if (idx === lastIndex && source.length > 1) {
      idx = (idx + 1) % source.length; // 避免重复
    }
    return { text: source[idx], index: idx };
  }

  build() {
    Column() {
      // 上半区 — 真心话
      Column() {
        Text(this.honestText)
          .fontSize(this.honestText === '真心话'
            ? WearScreenUtil.buttonFontSize
            : WearScreenUtil.subFontSize)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height('50%')
      .backgroundColor(this.honestText === '真心话' ? '#FF7299' : '#CC5A7A')
      .justifyContent(FlexAlign.Center)
      .padding(WearScreenUtil.safePadding)
      .onClick(() => {
        const result = this.getRandomText(honests, this.lastHonestIndex);
        this.honestText = result.text;
        this.lastHonestIndex = result.index;
        VibratorManager.vibrateResult();
      })

      // 下半区 — 大冒险
      Column() {
        Text(this.challengeText)
          .fontSize(this.challengeText === '大冒险'
            ? WearScreenUtil.buttonFontSize
            : WearScreenUtil.subFontSize)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height('50%')
      .backgroundColor(this.challengeText === '大冒险' ? '#23ADE5' : '#1A8AB8')
      .justifyContent(FlexAlign.Center)
      .padding(WearScreenUtil.safePadding)
      .onClick(() => {
        const result = this.getRandomText(challenges, this.lastChallengeIndex);
        this.challengeText = result.text;
        this.lastChallengeIndex = result.index;
        VibratorManager.vibrateResult();
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

#### 4.6.6 待确认问题

| # | 问题 | 建议 |
|---|------|------|
| 1 | 数据源使用方案 A（独立复制）还是方案 B（common 共享）？ | 先用 A，快速落地 |
| 2 | 初始题库需要多少条？ | 真心话和大冒险各 10 条起步，后续可扩展 |
| 3 | 连续随机是否允许重复？ | 简单去重：与上次不同即可 |
| 4 | 是否需要"再来一次"按钮，还是直接再次点击区域？ | 直接再次点击区域（零额外 UI 元素） |
| 5 | `VibratorManager` 是否在手表端可用？ | VIBRATE 权限已配置，需实测验证 |

---

## 5. 手表端文件架构

```
product/wearable/src/main/ets/
├── wearableability/
│   └── WearableAbility.ets          # 已有：生命周期管理
├── wearablebackupability/
│   └── WearableBackupAbility.ets    # 已有：备份恢复
├── pages/
│   └── Index.ets                    # 重写：圆/方屏双适配 Swiper 主页
├── sub_pages/                       # 手表端功能组件（参考手机端 CardDisplay 新建）
│   ├── WearRollDices.ets            # 掷骰子（参考 RollDiceCardDisplay）
│   ├── WearFlipCoin.ets             # 丢硬币（参考 FlipCoinCardDisplay）
│   ├── WearRandomABCD.ets           # ABCD选择（参考 ABCDCardDisplay，去掉指针）
│   ├── WearDevineBaGua.ets          # 八卦占卜（参考 BaGuaCardDisplay）
│   ├── WearRollWheel.ets            # 🅿️ 幸运转盘（参考 RollWheelCardDisplay，含纵向Swiper+Canvas）
│   ├── WearBlessingMuyu.ets         # 🅿️ 祝福木鱼（参考 BlessingMuyuCardDisplay）
│   ├── WearTruthOrDare.ets          # 🆕 🅿️ 真心话大冒险（参考 HonestOrChallenge，简化分屏模式）
│   └── WearRandomColors.ets         # 随机颜色（参考 RandomColorsCardDisplay）
└── utils/
    ├── WearScreenUtil.ets           # 🆕 屏幕形状检测 + 适配工具类
    ├── WearRollDataManager.ets      # 转盘数据管理（参考 RollDataManager，精简版）
    └── WearTruthOrDareData.ets      # 🆕 真心话大冒险题库数据（独立复制手机端 challenges.ets）
```

---

## 6. 需要解决的问题

| # | 问题 | 影响范围 | 推荐方案 |
|---|------|---------|---------|
| 1 | **`build-profile.json5` 缺少 wearable 模块注册** | 整个模块 | **正确解决方案**：在顶层 `build-profile.json5` 的 `modules` 数组中添加 `{ "name": "wearable", "srcPath": "./product/wearable" }`（**不加 `targets` 字段**，与 `basic`、`VitalUI` 等公共模块一致，所有 product 构建都会自动包含）。注意：不要使用 `targets` 字段做 product 绑定，hvigor 在构建时会对 `targets` 做严格校验，容易报错（`Unknown target` 或 `target不能为空`） |
| 2 | **RollDataManager 在 `product/default` 里，手表端无法直接 import** | 转盘功能 | 在 `wearable/utils/` 下新建 `WearRollDataManager.ets`，参考手机端逻辑独立实现 |
| 3 | **图片资源需在 wearable resources 中补一份** | 全部有图片的组件 | 复制必要图片到 `product/wearable/src/main/resources/base/media/` |
| 4 | **ArcSwiper / ArcList / ArcButton / ScreenShape 需要 API 18+** | 圆形屏全部 Arc 组件 + 屏幕形状检测 | **架构修正**：`compatibleSdkVersion` 是 app 级配置（products[].compatibleSdkVersion），不能为不同模块设置不同最低 API 版本。经实测验证，最简方案为 wearable 模块**不加 `targets`**（以通用模块模式参与构建），在 `WearScreenUtil` 里做运行时 try-catch 检测（低于 API 18 走标准 Swiper 方案），无需改动 `compatibleSdkVersion` |
| 5 | ~~ArcSwiperAttribute 需手动导入~~ → **v3.5 已解决** | — | `@kit.ArkUI` 自动 re-export，无需手动导入 |
| 6 | **横向 ArcSwiper 与系统侧滑返回的手势冲突** | 主页交互 | **UX 修正**：避免直接使用 `.disableSwipe(true)`（会完全禁用触摸滑动，体验极差）。推荐方案：① 缩小 ArcSwiper 触控热区（只在屏幕中部区域响应横滑，边缘留给系统侧滑返回）；② 提高手势识别阈值（通过 `gesture` 包裹，设置更大 `distance` 参数）；③ 接受侧滑返回（部分产品选择"放弃横向滑动，改用表冠+点击切换"） |
| 7 | **`display` 模块 import 来源已确认** | 全部屏幕检测代码 | ✅ v3.4 确认：实际路径为 `@ohos.display`（手机端 DisplayMarquee.ets 已验证），非 `@kit.ArkUI` |

---

## 7. 实施步骤

### Step 1: 注册 wearable 模块

在顶层 `build-profile.json5` 的 `modules` 数组中添加 wearable 模块注册。

```
操作清单：
├── build-profile.json5 (顶层)
│   └── 在 modules 数组中添加 { "name": "wearable", "srcPath": "./product/wearable" }
│       ⚠️ 不加 targets 字段！与 basic/VitalUI 等公共模块一致
├── product/wearable/src/main/module.json5
│   └── 确认 deviceTypes 包含 "wearable"，确认 VIBRATE 权限已添加
├── product/wearable/oh-package.json5
│   └── 确认 @ohos/common 依赖已声明
└── DevEco Studio 中构建，验证可编译
```

**配置示例（build-profile.json5 modules 数组）**：

```json5
// 在 modules 数组中添加（与 basic、VitalUI 同级）
{
  "name": "wearable",
  "srcPath": "./product/wearable"
  // ← 注意：不要加 targets 字段！
  // targets 会导致 hvigor 构建时严格校验 product 绑定，
  // 容易报错 "Unknown target" 或 "target不能为空"
}
```

> **重要说明**：经实测验证，hvigor 构建系统对 `targets` 字段有严格校验——`targets[].name` 必须匹配模块自身 `build-profile.json5` 里定义的 target 名称（仅有 `"default"` 和 `"ohosTest"`），而 `applyToProducts` 不包含当前 product 时会报 `target不能为空`。最简方案是**不加 `targets`**，让模块以"通用模块"模式参与所有 product 构建。

### Step 2: 新建屏幕适配工具类

```
新建文件：
└── utils/WearScreenUtil.ets    # 屏幕形状 + 尺寸分级 + 设计 Token
```

`WearScreenUtil` 封装：
- `isRoundScreen()` — 基于 `display.ScreenShape` 检测（API 18+，低版本默认方形）
- `screenSize` — 基于 `display.width/height` 计算尺寸分级：small(<340vp) / standard / large(>460vp)
- `screenWidth / screenHeight` — 屏幕物理尺寸 (vp)
- 设计 Token（全部按 形状×尺寸 四象限取值）：
  - `safePadding` / `contentWidthRatio` / `mainImageWidth` — 布局类
  - `resultFontSize` / `subFontSize` / `buttonFontSize` — 字号类
  - `listItemSpace` / `minTouchSize` — 间距类
  - `scaledSize(基准值)` — Canvas 精确尺寸，按屏幕比例缩放

### Step 3: 新建手表端功能组件

在 `product/wearable/src/main/ets/sub_pages/` 下逐个创建功能组件（按 P0→P1→P2 优先级）：

```
新建文件清单（按优先级）：
├── sub_pages/WearRollWheel.ets          # 🅿️ 参考 RollWheelCardDisplay（含纵向Swiper+Canvas）
├── sub_pages/WearBlessingMuyu.ets       # 🅿️ 参考 BlessingMuyuCardDisplay
├── sub_pages/WearTruthOrDare.ets        # 🆕 🅿️ 参考 HonestOrChallenge（简化分屏，见 §4.6）
├── sub_pages/WearRollDices.ets          # 参考 RollDiceCardDisplay
├── sub_pages/WearFlipCoin.ets           # 参考 FlipCoinCardDisplay
├── sub_pages/WearRandomABCD.ets         # 参考 ABCDCardDisplay（去掉指针，四格直铺）
├── sub_pages/WearDevineBaGua.ets        # 参考 BaGuaCardDisplay
├── sub_pages/WearRandomColors.ets       # 参考 RandomColorsCardDisplay
├── utils/WearRollDataManager.ets        # 参考 RollDataManager（精简版）
└── utils/WearTruthOrDareData.ets        # 🆕 真心话大冒险题库（独立复制手机端 challenges.ets）
```

每个组件内部使用 `WearScreenUtil` 适配尺寸，圆形/方形屏自适应。

### Step 4: 搭建手表主页

重写手表端 Index.ets，实现 ArcSwiper（圆形屏）/ Swiper（方形屏）双适配布局。

```
操作清单：
├── 重写 Index.ets → ArcSwiper（圆形）vs Swiper（方形）双布局
├── 圆形屏配置：ArcSwiperController + ArcDotIndicator + CrownSensitivity
├── 方形屏配置：标准 Swiper + indicator + loop
├── main_pages.json 只保留 "pages/Index"
├── oh-package.json5 确认依赖 @ohos/common（@kit.ArkUI 为系统 SDK，无需添加）
└── 复制必要图片资源到 wearable/resources/base/media/
```

### Step 5: 适配手表端细节

```
适配清单：
├── ArcSwiper 弧形排列效果验证（子组件分布、滑动路径）
├── ArcDotIndicator 方向与颜色验证（6点钟方向，与背景对比度）
├── digitalCrownSensitivity 表冠灵敏度微调（LOW/MEDIUM/HIGH）
├── ArcButton 在圆形屏上贴合效果验证（如有操作按钮）
├── 震动反馈接入（每次随机结果时 haptic）
├── 验证 ArcSwiper 横向滑动与侧滑返回无冲突
├── 方形屏 Swiper 布局验证（无裁切，四角可用）
└── 圆/方屏尺寸 Token 数值微调（按实际设备调优）
```

### Step 6: 调试打包

```
操作清单：
├── DevEco Studio 选择 wearable target 构建
├── 圆形手表模拟器测试（Watch GT Pro 模拟器）
├── 方形手表模拟器测试（Watch D 模拟器）
└── 签名打包 .hap
```

---

## 8. 文件变更清单

### 8.1 修改的现有文件

| 文件路径 | 变更内容 |
|---------|---------|
| `build-profile.json5` | 在 modules 数组中添加 wearable 模块注册（不加 targets） |
| `product/wearable/src/main/module.json5` | 取消注释 + 添加 VIBRATE 权限 |
| `product/wearable/src/main/ets/pages/Index.ets` | 重写为横向 Swiper 主页 |
| `product/wearable/src/main/resources/base/profile/main_pages.json` | 只保留 Index |
| `product/wearable/oh-package.json5` | 确认 @ohos/common 依赖（@kit.ArkUI 为 SDK 内置，无需额外添加） |

### 8.2 新建的文件

| 文件路径 | 优先级 | 说明 | 参考来源 |
|---------|:-----:|------|---------|
| `product/wearable/src/main/ets/sub_pages/WearRollWheel.ets` | P0 | 幸运转盘 | `form_display/RollWheelCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearBlessingMuyu.ets` | P0 | 祝福木鱼 | `form_display/BlessingMuyuCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearTruthOrDare.ets` | 🆕 P0 | 真心话大冒险 | `sub_pages/honest_or_challenge/HonestOrChallenge.ets` |
| `product/wearable/src/main/ets/utils/WearTruthOrDareData.ets` | 🆕 P0 | 真心话大冒险题库 | `static_datas/challenges.ets` |
| `product/wearable/src/main/ets/sub_pages/WearRollDices.ets` | P1 | 掷骰子 | `form_display/RollDiceCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearFlipCoin.ets` | P1 | 丢硬币 | `form_display/FlipCoinCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearRandomABCD.ets` | P1 | ABCD选择 | `form_display/ABCDCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearDevineBaGua.ets` | P2 | 八卦占卜 | `form_display/BaGuaCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearRandomColors.ets` | P2 | 随机颜色 | `form_display/RandomColorsCardDisplay.ets` |
| `product/wearable/src/main/ets/utils/WearRollDataManager.ets` | P0 | 转盘数据管理 | `pages/RollPage/RollDataManager.ets` |
| `product/wearable/src/main/ets/utils/WearScreenUtil.ets` | P0 | 🆕 屏幕形状检测 + 设计 Token 适配 | `@ohos.display` API 18+ |

### 8.3 需要复制的资源文件

手表端需要独立拥有一份图片资源，以下资源需复制到 `product/wearable/src/main/resources/base/media/`：

```
dice1.png ~ dice6.png     # 骰子图片
coin1.png, coin2.png      # 硬币图片
needle.svg                # ABCD 指针（如保留指针模式则需要）
pointer_m.svg             # 转盘指针
BaGua.png                 # 八卦图
MuYu.png                  # 木鱼图片
```

颜色资源需复制到 `product/wearable/src/main/resources/base/element/`：

```
color.json                # 颜色 token（Comp_Bg1~4, Brand, FontIcon_Fore1~2 等）
string.json               # 字符串资源
```

---

## 9. 风险与注意事项

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| ArcSwiper / ArcList / ArcButton / ScreenShape 需要 API 18+ | 低于 API 18 的手表设备无法使用弧形组件和屏幕形状检测 | `WearScreenUtil` 内做 API 版本检查，低于 18 默认方形屏 + 标准 Swiper |
| ~~ArcSwiperAttribute 需手动导入~~ → **v3.5 已解决** | — | `@kit.ArkUI` 自动 re-export，无需手动导入 |
| 方形屏用 ArcSwiper 体验差 | 弧形排列在方形屏上视觉违和 | 方形屏统一用标准 `Swiper`，不做 ArcSwiper 回退 |
| HarmonyOS wearable API 支持不完整 | 部分 ArkUI 组件在手表端可能不可用 | 先在模拟器验证 ArcSwiper、Canvas 等核心组件 |
| ArcSwiper 弧形裁切 | 超出弧形可视区域的子组件内容不可见 | 子组件内容放在安全区（见 §2.5 Design Token） |
| 手表端内存有限 | Canvas 绘制转盘可能卡顿 | 降低 Canvas 分辨率或简化绘制 |
| 横向 ArcSwiper 与侧滑返回手势冲突 | 左右滑动可能触发系统返回 | 缩小触控热区、提高手势阈值、或接受侧滑返回（见 §6 问题6），避免使用 `.disableSwipe(true)` |
| 手机端迭代后手表端不同步 | 两端代码独立演进，功能差异可能增大 | 在 CHANGELOG 中标注手表端功能对齐状态 |
| `@ohos/hypium` 是测试框架依赖 | ABCDCardDisplay / BaGuaCardDisplay 中 import 了 `@ohos/hypium` | 手表端新建组件中**不要引入**此依赖，属于冗余 import |

---

## 10. 后续迭代方向

- **服务卡片**：手表端的服务卡片（表盘小组件，2×2 / 4×1 尺寸），圆形屏卡片需特殊裁切
- **更多功能**：随机数、吃什么、抽签等适配手表端
- **数据同步**：手机端与手表端的数据互通（分布式数据/跨设备同步）
- **表冠交互**：利用物理表冠做更精细的交互控制（`digitalCrownSensitivity`，旋转切换 Swiper 页面）
- **摇一摇**：加速度传感器触发随机（"摇手机"变"摇手腕"）
- **震动反馈**：每次随机结果时震动反馈（已预留 VIBRATE 权限）
- **`ArcSwiper` 自定义动画**：利用 `customContentTransition` 实现页面切换时的透明度渐变 + 缩放效果，提升手表端视觉品质
- **ArcList 转盘列表**：当转盘数据量 >5 时，将纵向 Swiper 替换为 ArcList（更好的圆形屏滚动体验+自动缩放）
- **ArcSwiper 纵向浏览**：幸运转盘内部用 `ArcSwiper({ vertical: true })` 代替标准纵向 Swiper，保持与主页一致的弧形滑动体验
- **方形手表专项测试**：确保在 Watch D 等方形手表上 Swiper 布局不出现空白/溢出
