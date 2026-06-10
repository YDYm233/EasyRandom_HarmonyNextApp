# ⌚ 随易 EasyRandom — Lite Wearable（轻量级手表）实现方案

> 文档版本：v1.0 | 日期：2026-06-10 | 基于 wearable-plan.md v4.0 适配
> **v1.0 初始**：FA 模式 + JS API 方案定义，适配 Huawei Watch GT 5 Pro（liteWearable 设备类型），P0 三功能实现规格。

---

## 1. 为什么需要单独的 Lite Wearable 模块

### 1.1 设备差异

| 维度 | wearable (ArkTS) | lite wearable (JS API) |
|------|:---:|:---:|
| 典型设备 | Huawei Watch 4 / Ultimate | **Huawei Watch GT 5 Pro** |
| 运行时 | ArkTS + ArkUI | JavaScript (QuickJS) |
| UI 框架 | 声明式 UI (`@Component` / Builder) | 类 Web 模板 (`.hml` + `.css` + `.js`) |
| Canvas | CanvasRenderingContext2D | 仅 `canvas` 标签基础功能 |
| 自定义组件 | `@Component` | hml 模板 + js 逻辑分离 |
| 页面路由 | `@Entry` / windowStage.loadContent | `router.push/back` |
| API 类型 | stageMode | faMode |
| `ArcSwiper` | ✅ 支持 | ❌ 不支持（无此概念） |
| 表冠交互 | CrownSensitivity | ❌ 不支持 |
| Swiper | 标准 ArkUI Swiper | `swiper` 标签（功能子集） |

### 1.2 模块关系

```
EasyRandom 工程
├── product/default/        ← 手机端 (ArkTS, stageMode, phone/tablet)
├── product/wearable/       ← 标准手表 (ArkTS, stageMode, wearable)
│      ArkTS + ArcSwiper + Canvas 2D
│      适用于: Watch 4 / Ultimate / 支持 ArkUI 的手表
│
└── product/lite-wearable/  ← 🆕 轻量手表 (JS, faMode, liteWearable)
       .hml + .css + .js
       适用于: Watch GT 5 Pro / 所有 LiteOS / 轻鸿蒙手表
```

### 1.3 bundleName 一致性

两个穿戴模块使用相同的 `bundleName`（继承自 `AppScope/app.json5`），AppGallery 会根据 `deviceTypes` 自动向不同设备推送对应的 HAP：
- `deviceTypes: ["wearable"]` → 标准手表收到 wearable.hap
- `deviceTypes: ["liteWearable"]` → GT 5 Pro 收到 lite-wearable.hap

---

## 2. Lite Wearable 模块架构

### 2.1 目录结构

```
product/lite-wearable/
├── .gitignore
├── build-profile.json5           ← apiType: "faMode"
├── oh-package.json5              ← 依赖声明
├── hvigorfile.ts                 ← 构建钩子（可留空）
├── build/                        ← 构建产物（gitignore）
└── src/main/
    ├── module.json5              ← 模块描述（deviceTypes: ["liteWearable"]）
    ├── js/                       ← JS API 源代码根目录
    │   └── default/              ← default 实例
    │       ├── app.js            ← 应用生命周期
    │       ├── i18n/             ← 国际化
    │       │   ├── zh-CN.json
    │       │   └── en-US.json
    │       ├── common/           ← 共享工具
    │       │   ├── data.js       ← 转盘数据 / 颜色预设
    │       │   ├── random.js     ← 随机数工具
    │       │   └── screen.js     ← 屏幕适配（圆/方）
    │       └── pages/            ← 页面目录
    │           ├── index/        ← 主入口
    │           │   ├── index.hml
    │           │   ├── index.css
    │           │   └── index.js
    │           ├── nav/          ← 负一屏导航
    │           │   ├── nav.hml
    │           │   ├── nav.css
    │           │   └── nav.js
    │           ├── rollwheel/    ← 幸运转盘（P0）
    │           │   ├── rollwheel.hml
    │           │   ├── rollwheel.css
    │           │   └── rollwheel.js
    │           ├── muyu/         ← 祝福木鱼（P0）
    │           │   ├── muyu.hml
    │           │   ├── muyu.css
    │           │   └── muyu.js
    │           ├── truthdare/    ← 真心话大冒险（P0）
    │           │   ├── truthdare.hml
    │           │   ├── truthdare.css
    │           │   └── truthdare.js
    │           ├── rolldices/    ← 掷骰子（P1）
    │           │   ├── rolldices.hml
    │           │   ├── rolldices.css
    │           │   └── rolldices.js
    │           ├── flipcoin/     ← 丢硬币（P1）
    │           │   ├── flipcoin.hml
    │           │   ├── flipcoin.css
    │           │   └── flipcoin.js
    │           ├── abcd/         ← ABCD（P1）
    │           │   ├── abcd.hml
    │           │   ├── abcd.css
    │           │   └── abcd.js
    │           ├── bagua/        ← 八卦占卜（P2）
    │           │   ├── bagua.hml
    │           │   ├── bagua.css
    │           │   └── bagua.js
    │           └── colors/       ← 随机颜色（P2）
    │               ├── colors.hml
    │               ├── colors.css
    │               └── colors.js
    └── resources/               ← 资源文件（可复用 wearable 的资源）
        └── base/
            ├── element/
            │   ├── string.json
            │   ├── color.json
            │   └── float.json
            ├── media/            ← 图片资源
            │   ├── background.png
            │   ├── coin1.png  ... coin2.png
            │   ├── dice1.png  ... dice6.png
            │   ├── MuYu.png
            │   ├── BaGua.png
            │   ├── layered_image.json
            │   └── startIcon.png
            └── profile/
                └── backup_config.json
```

### 2.2 JS API 与 ArkTS 的关键区别

| 概念 | ArkTS (wearable) | JS API (lite-wearable) |
|------|-----------------|------------------------|
| 入口 | `@Entry @Component struct Index` | `pages/index/index.hml`（HTML 片段） |
| 状态管理 | `@State` / `@Prop` / `@Watch` | JS 对象 + 手动 DOM 更新 |
| 组件通信 | props 传递 | `router.push({ params })` 页面参数 |
| 动画 | `.animation()` / `.rotate()` | CSS `transition` / `animation` / JS `requestAnimationFrame` |
| Canvas | CanvasRenderingContext2D API | `<canvas>` 标签 + `getContext('2d')`（功能子集） |
| 随机数 | `Random()` from `@ohos/common` | `Math.random()` + 自定义封装 |
| 页面切换 | Swiper 容器（单页内） | `router.push/back`（页面栈） |
| 列表 | List / ForEach | `<list>` 标签 |
| 数据持久化 | `@kit.ArkData` (preferences) | `@ohos.data.storage` |
| 震动 | `@ohos.vibratorutil.VibratorManager` | `@ohos.vibrator` |
| 表冠 | CrownSensitivity | ❌ 不支持 |

### 2.3 共享策略

lite-wearable **不能 import ArkTS (.ets) 文件**，但可以**复制数据常量**和**共用资源目录**。

| 资源 | 共享方式 |
|------|---------|
| 图片资源 (dice/coin/muyu/BaGua) | **软链接** 或直接 `cp` 复用 `wearable` 的 media/ |
| 转盘数据 (Roll/RollItem) | 用 JSON 对象重新定义在 `common/data.js` |
| 颜色预设 (COLOR_PRESETS) | 数组直接写在 `common/data.js` |
| 随机工具 (Random) | 重新封装在 `common/random.js` |
| 字符串/颜色常量 | 各自维护独立的 `element/string.json` |
| `@ohos/common` 包 | ❌ 不能依赖（ArkTS 编译产物） |


## 3. P0 功能在 Lite Wearable 中的实现方案

### 3.1 幸运转盘（rollwheel）

**核心挑战**：lite wearable 的 `<canvas>` 标签功能有限，无法像 ArkTS 那样用 Canvas 2D 绘制扇区。

**替代方案 A（推荐：CSS Conic Gradient）**：

```
.hml：div 叠加（扇形圆盘 + 指针 div + 中心按钮）
.css：background: conic-gradient(...) 绘制扇形
     transform: rotate(Xdeg) 驱动旋转
     transition: transform 1s ease-out 动画
.js：  Math.random() → 目标角度 → 更新 rotate 变量 → setTimeout 判定结果
```

结构示意：
```
div.wheel-container
├── div.wheel-disc        ← background: conic-gradient(各扇区颜色)
│     transform: rotate({{rotateAngle}}deg)
│     transition: transform 1s cubic-bezier(0.17,0.67,0.12,0.99)
├── div.pointer           ← 12点方向的固定三角 (CSS border trick)
└── input[type=button]    ← 点击旋转
```

> ⚠️ conic-gradient 在低版本 QuickJS 上可能不支持。备选方案：用预渲染的转盘 PNG 图片 + `transform: rotate` 模拟，每个转盘主题一张图。

**数据**：从 `common/data.js` 读取 `wheelData` 数组。

### 3.2 祝福木鱼（muyu）

**实现最简单**——纯 div + onclick + 计数器。

```
.hml：div 布局（木鱼图片 + 计数文字 + 祝福语）
.css：点击缩放动画 (animation: tap 0.2s)
     @keyframes tap { 0%{transform:scale(1)} 50%{transform:scale(0.9)} 100%{transform:scale(1)} }
.js：tapCount++ → 结果判定（随机祝福语）
```

### 3.3 真心话大冒险（truthdare）

```
.hml：上下分屏 div
     ├── div.truth-section  （真心话按钮 + 结果区域）
     └── div.dare-section    （大冒险按钮 + 结果区域）
.css：Grid / flex 布局
.js：点击 → 问题库随机 → 显示结果 + 去重逻辑
```

### 3.4 负一屏导航（nav）

```
.hml：grid 布局的菜单列表
     ├── div.nav-item (幸运转盘)    → onclick: goToPage('rollwheel')
     ├── div.nav-item (祝福木鱼)    → onclick: goToPage('muyu')
     ├── div.nav-item (真心话大冒险) → onclick: goToPage('truthdare')
     └── ...
.js：每个 goToPage(page) 调用 router.push({ uri: 'pages/' + page + '/' + page })
```

### 3.5 P1/P2 功能

| 功能 | 难度 | 实现思路 |
|------|:---:|---------|
| 掷骰子 | 🟢 低 | 显示骰子图片 + onclick 随机切换 + CSS动画 |
| 丢硬币 | 🟢 低 | 显示硬币图片 + onclick 旋转 + CSS 3D flip |
| ABCD | 🟢 低 | 四个 div 底色变化 + 指针旋转 |
| 八卦占卜 | 🟢 低 | 显示八卦图 + rotate 动画 |
| 随机颜色 | 🟢 低 | 全屏 div 背景色随机变化 |


## 4. 路由与页面切换

### 4.1 FA 模式路由

FA 模式使用 `@ohos.router`（非 ArkUI 的 Router）：

```javascript
// common/router.js
import router from '@ohos.router';

export function goToPage(pageName) {
  router.push({
    uri: 'pages/' + pageName + '/' + pageName
  });
}

export function goBack() {
  router.back();
}
```

### 4.2 页面注册

在 `src/main/module.json5` 中注册所有页面：

```json
{
  "module": {
    "name": "lite-wearable",
    "type": "entry",
    "deviceTypes": ["liteWearable"],
    "js": [
      {
        "name": "default",
        "pages": [
          "pages/index/index",
          "pages/nav/nav",
          "pages/rollwheel/rollwheel",
          "pages/muyu/muyu",
          "pages/truthdare/truthdare",
          "pages/rolldices/rolldices",
          "pages/flipcoin/flipcoin",
          "pages/abcd/abcd",
          "pages/bagua/bagua",
          "pages/colors/colors"
        ]
      }
    ]
  }
}
```

### 4.3 页面间通信

```javascript
// 跳转时传参
router.push({
  uri: 'pages/rollwheel/rollwheel',
  params: { wheelIndex: 0 }  // 指定转盘主题
});

// 接收参数
export default {
  data: {
    wheelIndex: 0
  },
  onInit() {
    this.wheelIndex = this.wheelIndex || 0;
  }
};
```


## 5. 屏幕适配（圆/方）

lite wearable 无 `@ohos.display` 的完整 API，但可以通过 JS 获取屏幕信息：

```javascript
// common/screen.js
import device from '@system.device';

export default {
  isRoundScreen() {
    // lite wearable 设备通常通过型号判断圆/方
    // GT 5 Pro = 圆形屏
    return true;  // 可先硬编码，后续优化
  }
};
```

圆屏适配通过 CSS 实现：圆形屏用 `border-radius: 50%` 裁切父容器。


## 6. 数据持久化

lite wearable 使用 `@ohos.data.storage`：

```javascript
import storage from '@ohos.data.storage';

const store = storage.getStorageSync('/misc/wearable_data');

// 读
function loadCount() {
  return store.getSync('muyu_tap_count', 0);
}

// 写
function saveCount(count) {
  store.putSync('muyu_tap_count', count);
  store.flushSync();
}
```

数据与 wearable (ArkTS) 模块**不互通**——各自独立的持久化空间。


## 7. 与 ArkTS wearable 模块的对照表

| 功能 | ArkTS wearable | Lite wearable (JS) |
|------|---------------|-------------------|
| 主入口 | `Index.ets` (Swiper/ArcSwiper 容器) | `index/index.hml` (swiper 标签) |
| 负一屏 | `WearNavPanel.ets` (子组件) | `nav/nav.hml` (独立页面, router.push) |
| 幸运转盘 | `WearRollWheel.ets` (Canvas + ArcSwiper v) | `rollwheel/` (conic-gradient + CSS rotate) |
| 祝福木鱼 | `WearBlessingMuyu.ets` | `muyu/` (div + onclick + counter) |
| 真心话大冒险 | `WearTruthOrDare.ets` | `truthdare/` (上下分屏 div) |
| 页面切换 | Swiper 横向滑动 | router.push/back 页面跳转 |
| 表冠交互 | CrownSensitivity.MEDIUM | ❌ 不支持 |


## 8. 实施计划

### 8.1 总体顺序

```
Phase 1: 模块骨架（1 天）
  ├── 手动创建 product/lite-wearable/ 目录结构
  ├── 配置 build-profile.json5 / module.json5 / oh-package.json5
  ├── 注册到顶层 build-profile.json5
  ├── 创建 app.js 入口 + index 主页（Swiper 容器）
  └── 编译验证

Phase 2: P0 功能实现（3 天）
  ├── Step 1: nav 负一屏 + router 跳转框架
  ├── Step 2: muyu 祝福木鱼（最简单，练手）
  ├── Step 3: truthdare 真心话大冒险
  └── Step 4: rollwheel 幸运转盘（最复杂，CSS 转盘）

Phase 3: P1/P2 补充（1 天）
  ├── rolldices（骰子）
  ├── flipcoin（硬币）
  ├── abcd（ABCD选择）
  ├── bagua（八卦）
  └── colors（随机颜色）

Phase 4: 真机调试（1 天）
  ├── GT 5 Pro 连接 DevEco Studio
  ├── 构建 lite-wearable debug 包
  └── 全功能走查 + 修复
```

### 8.2 文件清单（预计 ~35 个源文件）

| 文件 | 类型 | 说明 |
|------|:---:|------|
| `build-profile.json5` | 配置 | faMode 构建配置 |
| `oh-package.json5` | 配置 | 依赖声明 |
| `src/main/module.json5` | 配置 | 模块描述 + 页面注册 |
| `src/main/js/default/app.js` | JS | 应用生命周期 |
| `src/main/js/default/common/data.js` | JS | 转盘数据 + 颜色预设 |
| `src/main/js/default/common/random.js` | JS | 随机工具 |
| `src/main/js/default/common/screen.js` | JS | 屏幕适配 |
| `src/main/js/default/pages/index/*` | hml+css+js | 主入口（Swiper） |
| `src/main/js/default/pages/nav/*` | hml+css+js | 负一屏导航 |
| `src/main/js/default/pages/rollwheel/*` | hml+css+js | 幸运转盘 |
| `src/main/js/default/pages/muyu/*` | hml+css+js | 祝福木鱼 |
| `src/main/js/default/pages/truthdare/*` | hml+css+js | 真心话大冒险 |
| `src/main/js/default/pages/rolldices/*` | hml+css+js | 掷骰子 |
| `src/main/js/default/pages/flipcoin/*` | hml+css+js | 丢硬币 |
| `src/main/js/default/pages/abcd/*` | hml+css+js | ABCD |
| `src/main/js/default/pages/bagua/*` | hml+css+js | 八卦占卜 |
| `src/main/js/default/pages/colors/*` | hml+css+js | 随机颜色 |
| `src/main/resources/base/element/*` | JSON | 字符串/颜色/尺寸 |

---

## 9. 附录：Lite Wearable 限制清单

以下是 lite wearable 中**不可用**的 API（相对于 ArkTS wearable）：

| API | 替代方案 |
|-----|---------|
| `ArcSwiper / ArcButton / ArcDotIndicator` | 用 `swiper` / `input[type=button]` 标签 |
| `CanvasRenderingContext2D`（完整版） | `<canvas>` 标签基础版 或 CSS 方案 |
| `@Component` / `@State` / `@Prop` | JS 对象 + 手动更新 |
| `@Builder` / `@BuilderParam` | hml 模板 include |
| `ForEach` / `LazyForEach` | `<list>` + `<list-item>` 或 JS 循环渲染 |
| `@ohos/common` (ArkTS 编译产物) | 重新用纯 JS 实现 |
| `CrownSensitivity` | 不支持表冠 |
| `@ohos.vibratorutil` | `@ohos.vibrator` (FA 模式对应 API) |
| `.animation()` (ArkUI) | CSS transition / animation / keyframes |
