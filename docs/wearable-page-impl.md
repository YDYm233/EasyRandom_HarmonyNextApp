# ⌚ 随易 EasyRandom — 手表端页面实现文档

> 版本: v1.0.19 (V0.0.1) | 更新: 2026-06-15 | 状态: ✅ 已发布

---

## 1. 概述

本文档描述随易 EasyRandom 手表端（`product/wearable`）当前已实现的全部页面结构、交互流程与关键实现细节。

### 1.1 已实现页面清单

| 文件 | 功能 | 页面索引 | 备注 |
|------|------|:--------:|------|
| `WearNavPanelRound.ets` | 导航面板（圆） | 0 | ArcList 列表式入口 |
| `WearNavPanelSquare.ets` | 导航面板（方） | 0 | Grid 网格式入口 |
| `WearRollWheel.ets` | 幸运转盘 | 1 | Canvas + 纵向 Swiper 切换 |
| `WearBlessingMuyu.ets` | 祝福木鱼 | 2 | 持久化计数 |
| `WearTruthOrDare.ets` | 真心话大冒险 | 3 | 上下分屏 |
| `WearRollDices.ets` | 掷骰子 | 4 | — |
| `WearFlipCoin.ets` | 抛硬币 | 5 | — |
| `WearRandomABCD.ets` | ABCD 选择 | 6 | — |
| `WearDevineBaGua.ets` | 八卦占卜 | 7 | — |
| `WearRandomColors.ets` | 随机颜色 | 8 | — |
| `AppLinkQR.ets` | AppLink 二维码 | 9 | 随易应用商店跳转 |

### 1.2 通用依赖

```typescript
// 通用 import
import { Random } from '@ohos/basic-utils'
import WearScreenUtil from '../utils/WearScreenUtil'
import { VibratorManager } from '@ohos/system-utils'
```

---

## 2. 主页入口（Index.ets）

### 2.1 架构

整个手表端仅一个 `@Entry` 页面。四层适配模型：

| 层 | 职责 | 对应文件 |
|---|------|---------|
| 检测层 | 判断圆/方屏 | `WearScreenUtil.isRoundScreen()` |
| 容器层 | 选择 ArcSwiper / Swiper | Index.ets |
| 内容层 | 功能组件（不感知容器） | `sub_pages/*` |
| 工具层 | 设计 Token | `WearScreenUtil` |

### 2.2 页面排列

```
 负一屏  ← 幸运转盘 ★ → 木鱼 → 真心话 → 骰子 → 硬币 → ABCD → 八卦 → 随机颜色 → AppLink
  [0]       [1] 默认      [2]    [3]     [4]    [5]    [6]    [7]      [8]       [9]
```

### 2.3 关键实现差异

#### 实际实现 vs 原设计文档差异

| 方面 | 原文档设计 | 实际实现 |
|------|-----------|---------|
| 导航面板 | 单一 `WearNavPanel` 组件 | 拆分为 `Round` / `Square` 两个文件 |
| 页面构建 | 共用 `buildAllPages()` | 分离 `buildRoundPages()` + `buildSquarePages()` |
| 指示器 | 始终显示 | **自动隐藏**：首次显示 1.5s → 淡出，滑动/表冠操作时重新显示 |
| 圆形屏裁切 | 依赖 ArcSwiper 自带弧形排列 | 每页外包 `Stack` + `borderRadius(width/2)` + `clip(true)` 做圆形裁切 |
| 页面数 | 8 个功能 + 1 个负一屏 | 10 个页面（含 AppLinkQR） |

#### 自动隐藏指示器机制

```typescript
// Index.ets
@State showIndicator: boolean = true
private hideTimer: number = 0

aboutToAppear(): void {
  this.isRound = WearScreenUtil.isRoundScreen()
  this.scheduleHide(1500)  // 首次加载 1.5s 后隐藏
}

private scheduleHide(delay: number): void {
  this.showIndicator = true
  // 清除旧定时器
  clearTimeout(this.hideTimer)
  this.hideTimer = setTimeout(() => {
    this.showIndicator = false
  }, delay) as number
}

// 滑动时重新显示
.onGestureSwipe(() => {
  this.showIndicator = true
  clearTimeout(this.hideTimer)
})
.onAnimationEnd(() => {
  this.scheduleHide(1500)
})
```

---

## 3. 导航面板

### 3.1 圆形屏（WearNavPanelRound）

| 维度 | 实现 |
|------|------|
| 容器 | `ArcList` + `ArcListItem` |
| 布局 | 纵向列表，每项 emoji + 标签 + 箭头 |
| 跳转 | 通过 `onNavigate` 回调通知 Index.ets |

```typescript
// 菜单项定义
interface QuickEntry {
  emoji: string
  label: string
  targetIndex: number
}

const QUICK_ENTRIES: QuickEntry[] = [
  { emoji: '🎡', label: '幸运转盘', targetIndex: 1 },
  { emoji: '🐟', label: '祝福木鱼', targetIndex: 2 },
  { emoji: '💬', label: '真心话',   targetIndex: 3 },
  { emoji: '🎲', label: '掷骰子',   targetIndex: 4 },
  { emoji: '🪙', label: '丢硬币',   targetIndex: 5 },
  { emoji: '🔤', label: 'ABCD',     targetIndex: 6 },
  { emoji: '☯️', label: '八卦',     targetIndex: 7 },
  { emoji: '🎨', label: '随机颜色', targetIndex: 8 },
  { emoji: '🔗', label: 'AppLink',  targetIndex: 9 },
]
```

### 3.2 方形屏（WearNavPanelSquare）

| 维度 | 实现 |
|------|------|
| 容器 | `Scroll` + `Grid` |
| 布局 | 2 列网格 |
| 支持滚动 | 超出屏幕时 `Scroll` 自动滚动 |

---

## 4. 幸运转盘（WearRollWheel）

| 维度 | 实现 |
|------|------|
| 绘制 | Canvas 扇形绘制 + `rotate` 动画 |
| 数据源 | `WearRollDataManager`（内置 2 个预设转盘） |
| 切换 | 纵向 `ArcSwiper`（圆）/ `Swiper`（方）切换不同转盘 |
| 旋转 | 点击触发 `animateTo({ duration: 1000 })` |
| 指针 | 固定 12 点方向 |
| 震动 | 旋转结束时调用 `VibratorManager.vibrateResult()` |

核心状态:

```typescript
@Component
export struct WearRollWheel {
  @State rotateAngles: number[] = Array(defaultRolls.length).fill(0)
  @State isSpinning: boolean = false
  @State currentIndex: number = 0
  @State showResults: string[] = Array(defaultRolls.length).fill('')
  @State spinningIndex: number = -1
}
```

---

## 5. 祝福木鱼（WearBlessingMuyu）

| 维度 | 实现 |
|------|------|
| 交互 | 点击木鱼图片 → 敲击动画 + 祝福语随机弹窗 |
| 祝福语 | 从预设祝福词数组中随机选取（如「幸福 +3」「财力 +2」） |
| 持久化 | `Preferences` 存储敲击总次数 |
| 震动 | `VibratorManager.vibrateResult()` |

关键流程:

```
aboutToAppear → 加载 Preferences 计数
用户点击 → 随机祝福语 → 气泡动画 (scale 0→1.2→1) → 计数+1 → 持久化
aboutToDisappear → 释放 Preferences 句柄
```

---

## 6. 真心话大冒险（WearTruthOrDare）

| 维度 | 实现 |
|------|------|
| 数据源 | `utils/WearTruthOrDareData.ets`（独立题库，每类 10 条） |
| 布局 | 上下分屏：上半真心话 / 下半大冒险 |
| 交互 | 点击区域 → 随机出题 → 直接替换文字 → 震动 |
| 去重 | 连续两次不出同一题目 |

---

## 7. 其余功能组件

| 组件 | 交互 | 适配要点 |
|------|------|---------|
| `WearRollDices` | 点击随机切换骰子图片 | `WearScreenUtil.mainImageWidth` |
| `WearFlipCoin` | 点击硬币 Y 轴旋转动画 | Stack 叠放正反面 + `rotate({x:1})` |
| `WearRandomABCD` | 四格分屏，点击随机选中一项 | Grid 2×2，高亮选中项 |
| `WearDevineBaGua` | 点击旋转八卦图 | Image + `rotate` 动画 |
| `WearRandomColors` | 点击生成随机背景色 + 显示色值 | 全屏着色 |

---

## 8. 圆/方屏适配对照

| 维度 | 圆形屏 | 方形屏 |
|------|--------|--------|
| 主页容器 | `ArcSwiper` + `ArcSwiperController` | `Swiper` + `SwiperController` |
| 指示器 | `ArcDotIndicator`（6 点方向） | `DotIndicator` |
| 表冠 | `digitalCrownSensitivity(MEDIUM)` | 不支持 |
| 导航面板 | `ArcList` 列表式 | `Grid` 网格式 |
| 页面裁切 | `borderRadius(width/2)` 圆形遮罩 | 无裁切 |
| 安全间距 | `safePadding` 24vp（standard） | `safePadding` 12vp（standard） |

---

## 9. 调试要点

| 场景 | 方法 |
|------|------|
| 圆形屏模拟 | 选择圆形手表模拟器（如 Watch GT Pro） |
| 方形屏模拟 | 选择方形手表模拟器（如 Watch D） |
| 屏幕形状检测 | 在 `WearScreenUtil` 中加 `Logger.info` 输出 `isRound` 值 |
| 页面索引验证 | 滑动时观察 `currentIndex` 变化 |
| 持久化验证 | 在 DevTools 中查看 Preferences |

---

<p align="center">
  <sub>对应项目 v1.0.19 · 随易手表端 V0.0.1</sub>
</p>
