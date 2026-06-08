# ⌚ 随易 EasyRandom — 手表端（Wearable）实现方案

> 文档版本：v3.5 | 日期：2026-06-08 | 基于项目 v1.0.19 开发中状态
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

### 1.2 手机端 CardDisplay 组件（参考用）

手表端**不直接复用**手机端 `form_display/` 下的 CardDisplay 组件，而是**参考它们的交互逻辑，在 wearable 模块内单独建立适配手表屏的组件文件**。以下是各 CardDisplay 的核心逻辑摘要，供开发时参照：

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
├── RollWheel (手表端转盘)
│   └── RollDataManager (Roll, RollItem, defaultRolls, initRollsData)
│       └── @kit.ArkData (preferences)       ← 需在手表端同步引入
├── BlessingMuyu (手表端木鱼)
│   └── @kit.ArkData (preferences)
│   └── @kit.PerformanceAnalysisKit (hilog)
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
| **典型分辨率** | 466×466 px（华为 Watch GT / Watch 4） | 320×320 px 或 368×448 px（华为 Watch D 等） | Canvas/图片按分辨率分级加载 |
| **屏幕形状** | 圆形（主流） | 方形/类方形 | **核心差异**：圆屏四角被裁切，方屏可利用全屏 |
| **输入方式** | 触摸 + 滑动 + 物理表冠 | 同左 | 无键盘输入、无右键、无长按菜单 |
| **内存** | 2GB ~ 4GB | 同左 | 避免同时加载大图/复杂 Canvas |
| **电池** | 300~600mAh | 同左 | 动画完成后必须停止，避免持续重绘 |
| **震动马达** | 线性马达 | 同左 | 需 `ohos.permission.VIBRATE` 权限 |

### 2.2 ArkUI 约束（圆/方屏差异核心）

#### 通用约束（圆形+方形共有）

| 约束项 | 说明 | 应对 |
|--------|------|------|
| 部分组件不可用 | 手表端 ArkUI 组件子集 < 手机端（如部分弹窗、输入组件） | 开发前先在模拟器验证每个组件是否可用 |
| 无软键盘 | 手表无文本输入弹窗 | 所有功能零文本输入，用预设列表/选择器代替 |
| 无拖拽手势 | 手表端不支持 PanGesture 等复杂手势 | 仅用 onClick + Swiper 滑动 |
| Navigation 限制 | 手表端推荐用原生 Navigation | 单页面 + Swiper，不使用 router 多页面导航 |
| Swiper 性能 | 手表端 Swiper 页面数不宜超过 10 个 | 横向 Swiper 7 个功能页 |

#### 圆形屏专用组件（API 18+）

| 组件 | 导入方式 | 用途 | 方形屏可用？ |
|------|---------|------|:----------:|
| **ArcSwiper** | `import { ArcSwiper, ArcSwiperController, ArcDotIndicator, ArcDirection } from '@kit.ArkUI'` | 弧形轮播容器，子组件沿圆弧排列，支持表冠交互、弧形指示器、自定义切换动画 | ⚠️ API 22+ 支持非 Wearable，但方形屏体验差 |
| **ArcList** | `import { ArcListAttribute } from '@ohos.arkui.ArcList'` | 弧形滚动列表，列表项接近边缘时自动缩放 | ❌ 不建议 |
| **ArcButton** | `import { ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton'` | 贴合圆形屏边缘的弧形按钮（TOP_EDGE / BOTTOM_EDGE） | ❌ 不适用 |
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
| 最小触摸区域 | 48×48 vp | 48×48 vp | 手指精度低，按钮必须够大 |
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
| `standard` | 340 ~ 460 | Watch GT 4 (466×466), Watch Fit (368×448) | 主流手表 |
| `large` | > 460 | 未来大屏手表 | 目前无此设备，预留 |

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
    │   共用的 Wear 功能组件（7 个）         │
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
import { ArcButtonOptions, ArcButtonPosition } from '@ohos.arkui.advanced.ArcButton';
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

**原则二：子组件零分支**

```typescript
// ✅ 正确：组件内部没有 if(isRound)
.width(WearScreenUtil.mainImageWidth)   // 圆形=55%，方形=70%
.fontSize(WearScreenUtil.resultFontSize) // small=40，standard=48

// ❌ 错误：组件内部判断形状
if (WearScreenUtil.isRoundScreen()) {
  .width('55%')   // 分支爆炸，每个组件都要写
} else {
  .width('70%')
}
```

所有差异通过 Token 的**数值**差异来表达，而非**代码逻辑**分支。这保证了 7 个 Wear 组件可以在两个屏幕上零修改运行。

**原则三：新增设备只需补 Token**

未来如果出现新的屏幕类型（如 480×480 的圆形屏、超大方屏），只需：

1. `WearScreenUtil.screenSize` 增加分级条件
2. 所有 Token 的 getter 增加相应分支的数值
3. 完成后，现有的 7 个 Wear 组件、Index.ets 全部自动适配，不需要改动任何业务代码

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

| 横向页签 | 手表端组件（新建） | 参考来源 | 纵向数据 | 圆形屏适配要点 | 方形屏适配要点 |
|---------|-------------------|---------|---------|---------------|---------------|
| 掷骰子 | `WearRollDices` | `RollDiceCardDisplay` | 单页 | `mainImageWidth`(55%) + `safePadding`(24vp) | `mainImageWidth`(70%) + `safePadding`(12vp) |
| 丢硬币 | `WearFlipCoin` | `FlipCoinCardDisplay` | 单页 | `mainImageWidth`(55%)，旋转动画保持 | `mainImageWidth`(70%) |
| ABCD | `WearRandomABCD` | `ABCDCardDisplay` | 单页 | 去掉指针，四格直铺点击，`resultFontSize`(48fp) | 四格直铺，`resultFontSize`(48fp) |
| 八卦 | `WearDevineBaGua` | `BaGuaCardDisplay` | 单页 | `mainImageWidth`(55%) | `mainImageWidth`(70%) |
| 幸运转盘 | `WearRollWheel` | `RollWheelCardDisplay` | 多个转盘 | Canvas `scaledSize(260)`，纵向 Swiper 切转盘 | Canvas `scaledSize(260)` |
| 随机颜色 | `WearRandomColors` | `RandomColorsCardDisplay` | 单页 | 全屏着色 + `safePadding` 安全区内文字 | 全屏着色 |
| 祝福木鱼 | `WearBlessingMuyu` | `BlessingMuyuCardDisplay` | 单页 | `mainImageWidth`(55%) + `ArcButton` | `mainImageWidth`(70%) + `Button` |

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
│   ├── WearRollWheel.ets            # 幸运转盘（参考 RollWheelCardDisplay，含纵向Swiper+Canvas）
│   ├── WearRandomColors.ets         # 随机颜色（参考 RandomColorsCardDisplay）
│   └── WearBlessingMuyu.ets         # 祝福木鱼（参考 BlessingMuyuCardDisplay）
└── utils/
    ├── WearScreenUtil.ets           # 🆕 屏幕形状检测 + 适配工具类
    └── WearRollDataManager.ets      # 转盘数据管理（参考 RollDataManager，精简版）
```

---

## 6. 需要解决的问题

| # | 问题 | 影响范围 | 推荐方案 |
|---|------|---------|---------|
| 1 | **`module.json5` + `build-profile.json5` 被注释** | 整个模块 | 取消注释 + 添加 VIBRATE 权限 |
| 2 | **RollDataManager 在 `product/default` 里，手表端无法直接 import** | 转盘功能 | 在 `wearable/utils/` 下新建 `WearRollDataManager.ets`，参考手机端逻辑独立实现 |
| 3 | **图片资源需在 wearable resources 中补一份** | 全部有图片的组件 | 复制必要图片到 `product/wearable/src/main/resources/base/media/` |
| 4 | **ArcSwiper / ArcList / ArcButton / ScreenShape 需要 API 18+** | 圆形屏全部 Arc 组件 + 屏幕形状检测 | 当前项目 API 13+，手表端 `minAPIVersion` 设为 18；低版本手表回退到标准 Swiper + 方形屏 |
| 5 | ~~ArcSwiperAttribute 需手动导入~~ → **v3.5 已解决** | — | `@kit.ArkUI` 自动 re-export，无需手动导入 |
| 6 | **横向 ArcSwiper 与系统侧滑返回的手势冲突** | 主页交互 | 实测验证；为防冲突可设 `.disableSwipe(true)` 仅用表冠翻页，或限制触控区域 |
| 7 | **`display` 模块 import 来源已确认** | 全部屏幕检测代码 | ✅ v3.4 确认：实际路径为 `@ohos.display`（手机端 DisplayMarquee.ets 已验证），非 `@kit.ArkUI` |

---

## 7. 实施步骤

### Step 1: 启用模块

取消注释，让 wearable 模块回到编译体系。

```
操作清单：
├── build-profile.json5 (顶层)
│   └── 取消 wearable 模块注册注释
├── product/wearable/src/main/module.json5
│   └── 取消注释 + 添加 ohos.permission.VIBRATE
└── 验证项目可编译
```

**module.json5 需额外修改**：
- 添加 `ohos.permission.VIBRATE` 权限（震动反馈）
- 确认 `deviceTypes: ["wearable"]`
- 确认 `minAPIVersion` ≥ 18（ArcList/ArcButton/ScreenShape 依赖）

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

在 `product/wearable/src/main/ets/sub_pages/` 下逐个创建 7 个 Wear 组件：

```
新建文件清单：
├── sub_pages/WearRollDices.ets          # 参考 RollDiceCardDisplay
├── sub_pages/WearFlipCoin.ets           # 参考 FlipCoinCardDisplay
├── sub_pages/WearRandomABCD.ets         # 参考 ABCDCardDisplay（去掉指针，四格直铺）
├── sub_pages/WearDevineBaGua.ets        # 参考 BaGuaCardDisplay
├── sub_pages/WearRollWheel.ets          # 参考 RollWheelCardDisplay（含纵向Swiper+Canvas）
├── sub_pages/WearRandomColors.ets       # 参考 RandomColorsCardDisplay
├── sub_pages/WearBlessingMuyu.ets       # 参考 BlessingMuyuCardDisplay
└── utils/WearRollDataManager.ets        # 参考 RollDataManager（精简版）
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
| `build-profile.json5` | 取消 wearable 模块注释 |
| `product/wearable/src/main/module.json5` | 取消注释 + 添加 VIBRATE 权限 |
| `product/wearable/src/main/ets/pages/Index.ets` | 重写为横向 Swiper 主页 |
| `product/wearable/src/main/resources/base/profile/main_pages.json` | 只保留 Index |
| `product/wearable/oh-package.json5` | 确认 @ohos/common 依赖（@kit.ArkUI 为 SDK 内置，无需额外添加） |

### 8.2 新建的文件

| 文件路径 | 说明 | 参考来源 |
|---------|------|---------|
| `product/wearable/src/main/ets/sub_pages/WearRollDices.ets` | 掷骰子 | `form_display/RollDiceCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearFlipCoin.ets` | 丢硬币 | `form_display/FlipCoinCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearRandomABCD.ets` | ABCD选择 | `form_display/ABCDCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearDevineBaGua.ets` | 八卦占卜 | `form_display/BaGuaCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearRollWheel.ets` | 幸运转盘 | `form_display/RollWheelCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearRandomColors.ets` | 随机颜色 | `form_display/RandomColorsCardDisplay.ets` |
| `product/wearable/src/main/ets/sub_pages/WearBlessingMuyu.ets` | 祝福木鱼 | `form_display/BlessingMuyuCardDisplay.ets` |
| `product/wearable/src/main/ets/utils/WearRollDataManager.ets` | 转盘数据管理 | `pages/RollPage/RollDataManager.ets` |
| `product/wearable/src/main/ets/utils/WearScreenUtil.ets` | 🆕 屏幕形状检测 + 设计 Token 适配 | `@ohos.display` API 18+ |

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
| 横向 ArcSwiper 与侧滑返回手势冲突 | 左右滑动可能触发系统返回 | 设 `.disableSwipe(true)` 仅用表冠翻页，或限制触控区域 |
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
