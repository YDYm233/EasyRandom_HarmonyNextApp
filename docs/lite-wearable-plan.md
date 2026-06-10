# ⌚ 随易 EasyRandom — Lite Wearable（轻量级手表）实现方案

> 文档版本：v1.1 | 日期：2026-06-10 | 基于 wearable-plan.md v4.0 适配
> **v1.0 初始**：FA 模式 + JS API 方案（❌ 已废弃——HarmonyOS NEXT 不支持 FA 模式）
> **v1.1 修正**：Stage 模式 + ArkTS 方案，liteWearable 设备使用受限 API 子集。

---

## 1. 为什么需要单独的 Lite Wearable 模块

### 1.1 设备差异

| 维度 | wearable (ArkTS 全功能) | lite wearable (ArkTS 受限) |
|------|:---:|:---:|
| 典型设备 | Huawei Watch 4 / Ultimate | **Huawei Watch GT 5 Pro** |
| 运行时 | ArkTS + ArkUI（完整） | ArkTS + ArkUI（API 子集） |
| apiType | `stageMode` | `stageMode`（相同） |
| deviceTypes | `["wearable"]` | `["liteWearable"]` |
| `ArcSwiper` / `ArcButton` | ✅ 支持 | ❌ 不支持 |
| `CanvasRenderingContext2D` | ✅ 支持 | ❌ 不支持 |
| `CrownSensitivity` 表冠 | ✅ 支持 | ❌ 不支持 |
| `Swiper` 基础组件 | ✅ | ✅（功能子集） |
| `Column` / `Text` / `Button` / `Stack` | ✅ | ✅ |
| `@State` / `@Prop` / `@Watch` | ✅ | ✅ |
| `@Builder` / `@Component` | ✅ | ✅ |
| `ForEach` 循环渲染 | ✅ | ✅ |
| CSS `animation` / `transition` | ✅ | ✅ |
| 震动 `@ohos.vibrator` | ✅ | ⚠️ 可能不支持（待验证） |

### 1.2 核心结论

**HarmonyOS NEXT（SDK 5.0.1/API 13+）已完全移除 FA 模式（JS API）。** liteWearable 和 wearable 使用相同的 `stageMode` + ArkTS 开发，区别仅在于：

- `module.json5` 中 `deviceTypes` 不同（`"liteWearable"` vs `"wearable"`）
- Lite wearable 可用的 ArkUI API 是子集——不能使用 ArcSwiper、Canvas 2D、表冠等高级 API
- 基础布局组件（Column/Text/Button/Swiper/Stack）均可正常使用

### 1.3 模块关系

```
EasyRandom 工程
├── product/default/        ← 手机端 (ArkTS, stageMode, phone/tablet)
├── product/wearable/       ← 标准手表 (ArkTS, stageMode, wearable)
│      使用 ArcSwiper + Canvas 2D + 表冠交互
│      适用于: Watch 4 / Ultimate
│
└── product/wear_lite/      ← 轻量手表 (ArkTS, stageMode, liteWearable)
       使用 基础 Swiper + CSS 动画 + 简化组件
       适用于: Watch GT 5 Pro / 轻鸿蒙手表
```

### 1.4 bundleName 一致性

两个穿戴模块使用相同的 `bundleName`（继承自 `AppScope/app.json5`），AppGallery 会根据 `deviceTypes` 自动向不同设备推送对应的 HAP：
- `deviceTypes: ["wearable"]` → 标准手表收到 wearable.hap
- `deviceTypes: ["liteWearable"]` → GT 5 Pro 收到 wear_lite.hap

---

## 2. Lite Wearable 模块架构

### 2.1 最终目录结构

```
product/wear_lite/
├── .gitignore
├── build-profile.json5           ← apiType: "stageMode"
├── oh-package.json5
├── hvigorfile.ts
├── build/                        ← 构建产物（gitignore）
└── src/main/
    ├── module.json5              ← deviceTypes: ["liteWearable"], abilities 结构
    ├── ets/                      ← ArkTS 源码（与 wearable 相同语言）
    │   ├── entryability/
    │   │   └── EntryAbility.ets  ← 应用入口 Ability
    │   ├── pages/
    │   │   └── Index.ets         ← 主入口（基础 Swiper）
    │   ├── sub_pages/            ← 各功能页面（后续实现）
    │   │   ├── WearLiteNavPanel.ets
    │   │   ├── WearLiteRollWheel.ets
    │   │   ├── WearLiteMuyu.ets
    │   │   └── ...
    │   └── utils/
    │       └── WearLiteDataManager.ets  ← 共享数据
    └── resources/
        └── base/
            ├── element/
            │   ├── string.json
            │   └── color.json
            ├── media/            ← 图片资源（复用 wearable）
            └── profile/
                └── main_pages.json
```

### 2.2 与 wearable 模块的 API 对比

| 特性 | wearable (全功能) | wear_lite (受限) |
|------|:---:|:---:|
| 容器组件 | ArcSwiper（圆屏）\| Swiper（方屏） | **仅 Swiper**（圆/方统一） |
| Canvas 转盘 | CanvasRenderingContext2D 绘制扇形 | **CSS 动画 + div 旋转模拟** |
| 页面切换 | Swiper 横向滑动（单页内） | 同（Swiper 横向滑动） |
| 转盘切换 | ArcSwiper 纵向（圆）\| Swiper 纵向（方） | **仅 Swiper 纵向** |
| 表冠交互 | CrownSensitivity.MEDIUM | **不支持** |
| 震动反馈 | `@ohos.vibratorutil.VibratorManager` | 待验证，fallback 可跳过 |
| 数据持久化 | `@kit.ArkData` (preferences) | 同 API |
| 圆/方屏适配 | `WearScreenUtil.isRoundScreen()` | 同，用 display 模块 |

### 2.3 共享策略

两个模块都是 ArkTS，**数据模型可以直接共享**（通过 common 模块的编译产物）：

| 资源 | 共享方式 |
|------|---------|
| 图片资源 (dice/coin/muyu/BaGua) | 复制 `wearable/src/main/resources/base/media/` |
| 转盘数据 (defaultRolls) | 可依赖 `@ohos/common`（同为 ArkTS 编译产物） |
| 随机工具 (Random) | 直接 import from `@ohos/common` |
| 颜色常量 (ExColor) | 直接 import from `@ohos/common` |
| 屏幕适配 | 各自维护，因 token 系统可能不同 |
| 字符串 | 各自维护 `element/string.json` |

---

## 3. P0 功能在 Lite Wearable 中的实现方案

### 3.1 幸运转盘（WearLiteRollWheel）

**核心挑战**：lite wearable **无 Canvas 2D**，不能像 wearable 模块那样用 `CanvasRenderingContext2D` 绘制扇区。

**替代方案：CSS Conic Gradient + div 旋转**

```
架构：
Column
├── Text (转盘名称)
├── Stack
│   ├── div 圆盘 — CSS conic-gradient() 绘制扇形
│   │     animation: rotate(x deg) 1s ease-out
│   └── Text '▼' (12点指针)
├── Text (结果)
└── Text (点击提示)

关键：用 CSS animation 驱动旋转，而非 Canvas 重绘
```

**实现要点**：
- 扇区颜色用 `conic-gradient(red 0° 60°, blue 60° 120°, ...)` 模拟
- 旋转用 `.animation({ duration: 1000, curve: Curve.Ease })` 驱动 `rotate` 属性
- 结果判定同 wearable：`360° / itemCount` 扇区除法
- 纵向 Swiper 切换不同转盘（与 wearable 一致）

### 3.2 祝福木鱼（WearLiteMuyu）

实现最简单——纯 Column + onclick + 计数器。

```
Column
├── Image (木鱼图片)
├── Text (计数)
├── Text (祝福语)
└── 点击缩放动画: `.scale({ x: 0.9, y: 0.9 })` + 回弹
```

### 3.3 真心话大冒险（WearLiteTruthDare）

同 wearable 方案，使用标准 ArkUI 布局：

```
Column
├── Row
│   ├── Column (真心话区)
│   └── Column (大冒险区)
└── Text (结果/提示)
```

### 3.4 负一屏导航（WearLiteNavPanel）

在 Index.ets 的 Swiper index=0 位置直接实现，无需独立页面：

```
Grid (2列) + Scroll
├── GridItem (🎡 幸运转盘) → swiperController.changeIndex(1)
├── GridItem (🪵 祝福木鱼) → swiperController.changeIndex(2)
├── ...
└── 预留: 公告/设置/拉取数据（disabled 占位）
```

---

## 4. 屏幕适配（圆/方）

lite wearable 仍然可以通过 `@kit.ArkUI` 获取屏幕信息：

```typescript
import { display } from '@kit.ArkUI';

function isRoundScreen(): boolean {
  try {
    const displayClass = display.getDefaultDisplaySync();
    // 手表屏幕宽高相等 → 圆形屏
    return Math.abs(displayClass.width - displayClass.height) < 10;
  } catch (e) {
    return false;
  }
}
```

圆屏适配通过父容器 `borderRadius: '50%'` 裁切。

---

## 5. 实施计划

### 5.1 总体顺序

```
Phase 1: 模块骨架 ✅ 已完成
  ├── DevEco Studio 创建 wear_lite 模块
  ├── 配置 build-profile.json5（stageMode）
  ├── 配置 module.json5（deviceTypes: liteWearable）
  ├── 创建 EntryAbility + Index 主入口
  └── 编译验证

Phase 2: P0 功能实现（待开始）
  ├── Step 1: Index 主框架 + 负一屏导航
  ├── Step 2: WearLiteMuyu 祝福木鱼（最简单）
  ├── Step 3: WearLiteTruthDare 真心话大冒险
  └── Step 4: WearLiteRollWheel 幸运转盘（CSS 转盘）

Phase 3: P1/P2 补充（待开始）
  ├── WearLiteDices（骰子）
  ├── WearLiteFlipCoin（硬币）
  ├── WearLiteABCD（ABCD选择）
  ├── WearLiteBaGua（八卦占卜）
  └── WearLiteColors（随机颜色）

Phase 4: 真机调试（待开始）
  ├── GT 5 Pro 连接 DevEco Studio
  ├── 构建 wear_lite debug 包
  └── 全功能走查 + 修复
```

### 5.2 预计文件数

| 类型 | 数量 |
|------|:---:|
| 配置文件 | 4（已创建） |
| 入口 Ability | 1（已创建） |
| 主入口 Index | 1（已创建，占位） |
| P0 子页面 | 3 |
| P1 子页面 | 3 |
| P2 子页面 | 2 |
| 工具类 | 1 |
| 资源文件 | 4+ |
| **合计** | **~18 个文件** |

---

## 6. 附录：Lite Wearable API 限制清单

以下是在 lite wearable 中**不可用或受限**的 ArkUI API：

| API | 状态 | 替代方案 |
|-----|:---:|---------|
| `ArcSwiper` / `ArcButton` | ❌ | 使用 `Swiper` / `Button` |
| `ArcSwiperController` | ❌ | 使用 `SwiperController` |
| `ArcDotIndicator` | ❌ | 使用 `DotIndicator` 或自定义 |
| `CanvasRenderingContext2D` | ❌ | CSS conic-gradient 或图片序列帧 |
| `CrownSensitivity` | ❌ | 不支持表冠，改用触摸滑动 |
| `@ohos.vibratorutil` | ⚠️ 待验证 | 如不可用则跳过震动 |
| `@ohos/common`依赖 | ✅ | ArkTS 编译产物可共享 |
| `@Component` / `@State` | ✅ | 正常使用 |
| `Swiper` 基础版 | ✅ | 功能子集（可能无 `.vertical()` 等） |
| `Column` / `Text` / `Button` / `Stack` | ✅ | 正常使用 |
| `ForEach` / `@Builder` | ✅ | 正常使用 |
| `.animation()` / `.rotate()` | ✅ | 正常使用 |
