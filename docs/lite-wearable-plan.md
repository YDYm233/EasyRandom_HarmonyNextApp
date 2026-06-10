# ⌚ 随易 EasyRandom — Lite Wearable（轻量级手表）实现方案

> 文档版本：**v1.3** | 日期：2026-06-10
> **v1.0**：FA 模式 + JS API 方案（❌ 已废弃——HarmonyOS NEXT IDE 不再提供 FA 模板）
> **v1.1**：Stage 模式 + ArkTS 方案（❌ 已废弃——GT 5 Pro 是 Lite Wearable，只支持 JS，不是 ArkTS）
> **v1.2**：独立 JS FA 工程方案。假设同一 bundleName 可在 AGC 共享（❌ 不成立——Stage(.app) vs FA(.hap) 包格式不同）
> **v1.3**：两个独立 AGC 应用方案（✅ 当前）——工程 A（Stage） + 工程 B（FA），不同 bundleName，两个 AGC App

---

## 1. 核心结论（v1.3）

### 1.1 三个关键约束

| # | 约束 | 来源 |
|---|------|------|
| A | **FA 模型 (JS) 与 Stage 模型 (ArkTS) 不能在同一工程中混合** | 华为官方文档明确声明 |
| B | **GT 5 Pro 是 Lite Wearable，仅支持 JS API**（HML/CSS/JS + config.json） | 华为官方文档 + 用户实测 |
| C | **Stage 模型的 .app 包和 FA 模型的 .hap 包格式不同，不能在同一 AGC AppID 下共存** | 调研结论（包格式、签名 profile 不兼容） |

### 1.2 结论：两个独立 AGC 应用

```
AGC 应用 A                            AGC 应用 B（新建）
bundleName: ydy.App.EasyRandom       bundleName: ydy.App.EasyRandom.Watch
包格式: .app (App Pack)               包格式: .hap (FA 单包)
设备: 手机 + 标准手表 (Watch 3/4)      设备: 轻量手表 (GT 5 Pro / GT Runner 等)
运行时: Stage + ArkTS                 运行时: FA + JS (HML/CSS/JS)
目标: Watch 4 / Ultimate 等           目标: GT 5 Pro / GT 系列 / Fit 系列
AppGallery 名称: "随易"               AppGallery 名称: "随易 手表版"
```

---

## 3. JS FA 工程完整结构

> 注：DevEco Studio 5.0.1+ 已移除 `[Lite] Empty Ability` 模板，需手动创建。

### 3.1 目录结构

```
EasyRandom-Lite/                   ← 独立工程根目录
├── .gitignore
├── build-profile.json5            ← 构建配置（需适配 FA 模型）
├── entry/                         ← 入口模块
│   └── src/main/
│       ├── config.json            ← FA 模型配置文件（核心！）
│       ├── app.js                 ← 应用生命周期
│       ├── i18n/                  ← 国际化
│       │   └── zh-CN.json
│       └── js/
│           └── MainAbility/       ← Ability 目录（与 config.json 中 srcPath 对应）
│               ├── app.js         ← Ability 级生命周期（可选）
│               └── pages/
│                   └── index/     ← 页面目录
│                       ├── index.hml      ← UI 布局
│                       ├── index.css      ← 样式
│                       └── index.js       ← 逻辑
```

### 3.2 config.json（FA 模型核心配置）

```json
{
  "app": {
    "bundleName": "ydy.App.EasyRandom.Watch",
    "vendor": "goods",
    "version": {
      "code": 1000001,
      "name": "1.0.0"
    }
  },
  "deviceConfig": {},
  "module": {
    "package": "ydy.App.EasyRandom.Watch",
    "name": ".MainAbility",
    "mainAbility": ".MainAbility",
    "deviceType": [
      "liteWearable"
    ],
    "distro": {
      "deliveryWithInstall": true,
      "moduleName": "entry",
      "moduleType": "entry"
    },
    "abilities": [
      {
        "name": ".MainAbility",
        "srcLanguage": "js",
        "srcPath": "MainAbility",
        "icon": "$media:icon",
        "description": "$string:MainAbility_desc",
        "label": "$string:MainAbility_label",
        "type": "page",
        "launchType": "standard"
      }
    ],
    "js": [
      {
        "pages": [
          "pages/index/index"
        ],
        "name": ".MainAbility"
      }
    ],
    "distroFilter": {
      "screenShape": {
        "policy": "include",
        "value": ["circle", "rect"]
      }
    }
  }
}
```

### 3.3 app.js（应用生命周期）

```javascript
// entry/src/main/app.js
export default {
    onCreate() {
        console.info('[EasyRandom-Lite] Application onCreate');
    },
    onDestroy() {
        console.info('[EasyRandom-Lite] Application onDestroy');
    }
};
```

### 3.4 页面代码骨架

**index.hml**（布局）：
```html
<div class="container" onswipe="onSwipe">
    <text class="title">随易</text>
    <text class="subtitle">{{ message }}</text>
</div>
```

**index.css**（样式）：
```css
.container {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 100%;
    background-color: #1a1a2e;
}
.title {
    font-size: 48px;
    color: #e94560;
    margin-bottom: 20px;
}
.subtitle {
    font-size: 24px;
    color: #ffffff;
}
```

**index.js**（逻辑）：
```javascript
import app from '@system.app';

export default {
    data: {
        message: '你好，GT 5 Pro!'
    },
    onInit() {
        console.info('[EasyRandom-Lite] Page onInit');
    },
    onSwipe(e) {
        if (e.direction === 'right') {
            app.terminate(); // 右滑退出
        }
    }
};
```

---

## 4. 工程 A 需要清理的内容

当前工程中的 `product/wear_lite/` 模块是 v1.1 时期错误创建的 Stage 模型模块，**对 GT 5 Pro 无效**。

```bash
# 删除 wear_lite 模块（或移到别处以备后用）
rm -rf product/wear_lite/
```

---

## 5. 工程 B 创建方式

### 方式一：使用旧版 DevEco Studio（推荐）

安装 DevEco Studio 3.x 或 4.x（与 5.0.1 可共存），用 `[Lite] Empty Ability` 模板创建 JS FA 工程，然后修改 bundleName。

**优点**：自动生成完整的工程骨架、hvigor 构建配置  
**缺点**：需要额外安装一个 IDE 版本

### 方式二：纯手动创建（备选）

如果不想安装旧版 IDE：

1. 手动创建 3.1 节的目录结构
2. 从网上获取一个 Lite Wearable JS FA 工程模板的完整 build-profile.json5 和 hvigor 配置
3. 在 DevEco Studio 5.0.1 中"导入项目"

**优点**：不需要额外 IDE  
**缺点**：构建配置可能不完全兼容，需要调试

### 方式三：Canvas Kit 方案（备选方案，侧载）

如果华为提供了 Canvas Kit 侧载途径（类似第三方运行时），可以在 GT 5 Pro 上运行 ArkTS HAP。  
**⚠️ 此方案暂未确认可行性，作为长期备选。**

---

## 6. AGC 操作指南

### 6.1 操作路径（AGC 控制台）

```
1. 登录 AppGallery Connect → https://developer.huawei.com/consumer/cn/service/josp/agc/index.html
2. 进入「我的项目」→ 选择现有项目（如 "EasyRandom"）
3. 点击「添加应用」
4. 平台选择: HarmonyOS
5. 应用类型: 应用（App）
6. 填写:
   ├── 应用名称: "随易 手表版"（或 "随易 Lite"）
   ├── 包名 (bundleName): ydy.App.EasyRandom.Watch
   └── 应用分类: 工具
7. 创建完成后 →「开发」→「证书管理」→ 生成签名证书
   ├── 可复用现有 EasyRandom.p12 密钥库
   └── 但 CSR → 证书 .p7b 对应当前 AppID（需重新生成）
8. 「开发」→「Profile管理」→ 添加调试/发布 Profile
   ├── 设备类型: 穿戴设备 (Lite Wearable)
   └── API 级别: 8 或 9（不是 13）
```

### 6.2 与工程 A 的关系

| 项目 | 工程 A (EasyRandom) | 工程 B (EasyRandom-Lite) |
|------|:---:|:---:|
| AGC 项目 | 同一个项目（或独立项目均可） | 同 |
| AGC 应用 | 已有 App: ydy.App.EasyRandom | **新建** App: ydy.App.EasyRandom.Watch |
| .p12 密钥 | EasyRandom.p12 | **可复用**同一份 |
| .p7b 证书 | 对应 AppID A | **需重新生成**（对应 AppID B） |
| Profile | API 13 profile | **需重新生成**（API 8~9） |
| bundleName | ydy.App.EasyRandom | ydy.App.EasyRandom.Watch |

---

## 7. 构建与调试流程

### 6.1 构建

```bash
# 在工程 B 根目录
hvigor assembleHap
# 输出: entry/build/outputs/hap/entry-lite-signed.hap
```

### 6.2 安装到 GT 5 Pro

由于 GT 5 Pro 不能直接 USB/WiFi 连接 DevEco Studio，需通过手机中转：

1. **签名**：必须使用手动签名（不支持 DevEco 自动化签名）
2. **拷贝 HAP**：将 `.hap` 文件拷贝到手机 `/sdcard/haps/` 目录
3. **手机端工具**：安装最新版**运动健康** + **应用调测助手**
4. **蓝牙配对**：将 GT 5 Pro 与手机配对
5. **安装**：在"应用调测助手"中选择 HAP 包安装到手表

### 6.3 签名要点

工程 A 和工程 B 必须使用**同一套签名文件**（同一个 `.p12` + `.p7b`），保证两个 HAP 在 AGC 上被识别为同一应用。

---

## 8. 功能适配矩阵

| 功能 | 工程 A (wearable ArkTS) | 工程 B (lite JS) |
|------|:---:|:---:|
| 幸运转盘 | Canvas 2D 扇形绘制 | CSS conic-gradient / 图片帧 |
| 祝福木鱼 | Column + onclick + 缩放动画 | div + onclick + CSS animation |
| 随机骰子 | ArkUI 动画 | CSS 动画 |
| 抛硬币 | ArkUI 3D 翻转 | CSS 翻转动画 |
| ABCD选择 | ArkUI 布局 | HML 布局 |
| 八卦占卜 | ArkUI 布局 | HML 布局 |
| 随机颜色 | ArkUI 布局 | HML 布局 |
| 右滑退出 | @Builder + transition | onswipe + app.terminate() |
| 页面导航 | ArcSwiper（圆）/ Swiper（方） | Swiper 列表 |
| 震动反馈 | @ohos.vibrator | ⚠️ 待验证 |
| 数据持久化 | @kit.ArkData preferences | @ohos.data.preferences（JS API 版本） |

---

## 9. 下一步行动清单

| # | 行动 | 优先级 |
|---|------|:---:|
| 1 | 确认使用哪个创建方式（旧版 IDE / 手动） | P0 |
| 2 | 创建 EasyRandom-Lite 独立工程 | P0 |
| 3 | 实现首页框架（Index + Swiper 导航） | P0 |
| 4 | 实现 P0 核心：幸运转盘（CSS版） | P0 |
| 5 | 实现 P0 核心：祝福木鱼 | P0 |
| 6 | 真机 GT 5 Pro 调试 | P0 |
| 7 | 清理工程 A 中无效的 `wear_lite` 模块 | P1 |
| 8 | AGC 双 HAP 发布配置 | P1 |
