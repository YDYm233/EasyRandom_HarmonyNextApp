# EasyRandom 分包分类管理规划

## 1. 分包分类原则

公共代码按**职责性质**分为以下类别：

| 类别 | 说明 | 举例 | 特点 |
|------|------|------|------|
| **基础工具** | 通用基础设施，几乎每个模块都用到 | Logger、CommonConstants、GlobalContext | 极度通用、无业务逻辑、无系统API调用 |
| **系统能力封装** | 基于系统API的二次封装 | VibratorManager、BreakPointSystem、ApiVersionUtil | 调用`@kit.*`，无UI |
| **自定义UI组件** | 自己开发的ArkUI组件 | ColorPicker、PieChart、RoseChart | 有UI渲染、有`@Component` |

> **设计决策**：将"通用基础设施"与"自定义业务逻辑（Random/Randoms/ExColor）"合并为 BasicUtils，
> 通过子目录 `utils/` 与 `algo/` 区分职责。原因：轻量个人应用，分包目的是**分类管理**而非最大化复用，
> 4包过度拆分增加维护成本，3包足够清晰。

---

## 2. 分包方案

### 2.1 新模块结构

```
common/
├── BasicUtils/             # 基础工具包 — 通用基础设施 + 自定义业务逻辑
│   └── src/main/ets/
│       ├── utils/          # 通用基础设施
│       │   ├── Logger.ets
│       │   ├── CommonConstants.ets
│       │   └── GlobalContext.ets
│       └── algo/           # 自定义业务逻辑
│           └── Math.ets    # Random/Randoms/ExColor/rgbaToHex8 + 合并ColorCode内容
│
├── SystemUtils/            # 系统能力封装包 — 基于系统API的集成封装
│   └── src/main/ets/
│       ├── VibratorManager.ets      # ← @kit.SensorServiceKit
│       ├── BreakPointSystem.ets     # ← @ohos.mediaquery
│       └── ApiVersionUtil.ets       # ← @kit.BasicServicesKit
│
├── VitalUI/                # 自定义UI组件包 — 自己开发的ArkUI组件
│   └── src/main/ets/
│       ├── components/
│       │   ├── ColorPickerComponent/
│       │   │   └── ColorPickerDialog.ets   # ← 从basic迁入
│       │   └── chart/
│       │       ├── PieChart.ets
│       │       ├── PieChart_V3.ets
│       │       ├── QuarterRoseChart.ets
│       │       ├── RadarChart.ets
│       │       └── RoseChart.ets
│       └── Demo/                    # 组件演示页（保留）
│           ├── Demo.ets
│           ├── DemoRadarChart.ets
│           ├── DemoRoseChart.ets
│           └── MainPage.ets
│
├── (删除 basic/)               # 原 basic 模块内容已全部分迁出
├── (删除 HarmonySystemUtils/)  # 内容迁入 SystemUtils
```

### 2.2 模块命名与包名映射

| 模块目录 | 包名(oh-package.json5的name) | 消费方import路径 |
|----------|------------------------------|------------------|
| `common/BasicUtils` | `@ohos/basic-utils` | `import { Logger } from '@ohos/basic-utils'` |
| `common/SystemUtils` | `@ohos/system-utils` | `import { VibratorManager } from '@ohos/system-utils'` |
| `common/VitalUI` | `@ohos/vital-ui` | `import { ColorPickerButton } from '@ohos/vital-ui'` |

### 2.3 模块依赖关系

```
default (HAP) ──→ BasicUtils, SystemUtils, VitalUI
wearable (HAP) ──→ BasicUtils
VitalUI ──→ (暂无依赖)   # ColorPickerDialog内部自带HSL/RGB转换，不依赖外部
SystemUtils ──→ BasicUtils  # VibratorManager内部使用Logger日志
BasicUtils ──→ (无依赖)    # 最底层，纯逻辑+基础工具
```

> **注意**：HAR 不支持传递依赖。如果 SystemUtils 依赖 BasicUtils，则 default 模块即使 import 了 SystemUtils，
> 也无法直接使用 BasicUtils 的导出——需要 default **显式声明**对 BasicUtils 的依赖。
> 这是 HAR 的正常行为，符合"按需引入"的管理理念。

---

## 2.4 各模块详细内容与导出

### BasicUtils — 基础工具包

```
common/BasicUtils/
├── Index.ets
├── oh-package.json5       { name: "@ohos/basic-utils", main: "Index.ets" }
├── build-profile.json5
├── consumer-rules.txt
├── obfuscation-rules.txt
├── hvigorfile.ts
└── src/main/
    ├── module.json5        { type: "har", deviceTypes: ["default","tablet","2in1","car","wearable"] }
    └── ets/
        ├── utils/
        │   ├── Logger.ets
        │   ├── CommonConstants.ets
        │   └── GlobalContext.ets
        └── algo/
            └── Math.ets    # Random/Randoms/ExColor/rgbaToHex8 + 合并ColorCode中的独有函数
```

**Index.ets 导出：**
```typescript
// 通用基础设施
export { default as Logger } from './src/main/ets/utils/Logger'
export { default as CommonConstants } from './src/main/ets/utils/CommonConstants'
export { GlobalContext } from './src/main/ets/utils/GlobalContext'
// 自定义业务逻辑
export { Random, Randoms, ExColor, rgbaToHex8 } from './src/main/ets/algo/Math'
```

**deviceTypes**: 全设备类型（Logger/Constants 是最通用的基础设施，Random 在 wearable 也在用）

**重要：合并 VitalUI/ColorCode.ets 到 Math.ets**
- `ColorCode.ets` 中的 `rgbaToHex8`、`ExColor` 与 `Math.ets` 中的**完全重复**（逐行对比一致）
- `ColorCode.ets` 中 `rgbaToHsla`、`hexToHsla`、`hue2rgb`、`hslaToRgba` 也与 `Math.ets` 中的完全重复
- 合并策略：以 `Math.ets` 为基础（已是完整版），**直接删除 `ColorCode.ets`**，无需补入任何内容
- `ColorPickerDialog.ets` 内部自带完整的 HSL/RGB 转换工具函数（不依赖外部），不受影响

---

### SystemUtils — 系统能力封装包

```
common/SystemUtils/
├── Index.ets
├── oh-package.json5       { name: "@ohos/system-utils", main: "Index.ets", dependencies: { "@ohos/basic-utils": "file:../BasicUtils" } }
├── build-profile.json5
├── consumer-rules.txt
├── obfuscation-rules.txt
├── hvigorfile.ts
└── src/main/
    ├── module.json5        { type: "har", deviceTypes: ["default","tablet","2in1","car","wearable"] }
    └── ets/
        ├── VibratorManager.ets
        ├── BreakPointSystem.ets
        └── ApiVersionUtil.ets
```

**Index.ets 导出：**
```typescript
export { VibratorManager, VibrationUsage, HapticEffect } from './src/main/ets/VibratorManager'
export { BreakpointSystem, Breakpoint, BreakpointOptions, BreakpointType, BreakpointState } from './src/main/ets/BreakPointSystem'
export { ApiVersionUtil, ToolWithApiVersion } from './src/main/ets/ApiVersionUtil'
```

**deviceTypes**: 全设备类型
- VibratorManager: wearable 已声明 VIBRATE 权限，可用
- BreakPointSystem: 基于 mediaquery，全设备可用
- ApiVersionUtil: 基于 deviceInfo，全设备可用

**依赖**：SystemUtils → BasicUtils（VibratorManager 内部使用 Logger）

---

### VitalUI — 自定义UI组件包

```
common/VitalUI/
├── Index.ets
├── oh-package.json5       { name: "@ohos/vital-ui", main: "Index.ets" }
├── build-profile.json5
├── consumer-rules.txt
├── obfuscation-rules.txt
├── hvigorfile.ts
└── src/main/
    ├── module.json5        { type: "har", deviceTypes: ["default","tablet","2in1","car"] }
    ├── resources/          # 组件所需资源（如有）
    └── ets/
        ├── components/
        │   ├── ColorPickerComponent/
        │   │   └── ColorPickerDialog.ets   # ← 从 basic 迁入
        │   └── chart/
        │       ├── PieChart.ets
        │       ├── PieChart_V3.ets
        │       ├── QuarterRoseChart.ets
        │       ├── RadarChart.ets
        │       └── RoseChart.ets
        └── Demo/
            ├── Demo.ets
            ├── DemoRadarChart.ets
            ├── DemoRoseChart.ets
            └── MainPage.ets
```

**Index.ets 导出：**
```typescript
// UI Components
export { ColorPickerView, ColorPickerButton } from './src/main/ets/components/ColorPickerComponent/ColorPickerDialog'
// Chart Components
export { PieChartData, Chart as PieChartBase, PieChart } from './src/main/ets/components/chart/PieChart'
export { PieChartData as PieChartData_V3, Chart as PieChartBaseV3, PieChart_V3 } from './src/main/ets/components/chart/PieChart_V3'
export { ChartData as RoseData, Chart as RoseBase, RoseChartClass, QRoseChart } from './src/main/ets/components/chart/QuarterRoseChart'
export { ChartData as RadarData, ChartClass, RadarChartClass, RoseChart as RadarRoseChart } from './src/main/ets/components/chart/RadarChart'
export { ChartData as RoseChartData, Chart as RoseChartBase, RoseChartClass as RoseChartCore, RoseChart } from './src/main/ets/components/chart/RoseChart'
// Demo
export { MainPage } from './src/main/ets/Demo/MainPage'
```

**deviceTypes**: 暂不含 wearable
- ColorPicker: 使用了 `TextInput`、`SymbolGlyph`、`bindPopup` 等，当前穿戴设备不一定支持
- Chart 组件: 使用 Canvas，穿戴设备理论可用，但 Demo 页面不适用
- 后续如需穿戴版组件，可扩展 deviceTypes

**依赖说明**：VitalUI → (暂无)
- ColorPickerDialog 内部**已自带**完整的 HSL/RGB 转换函数，实际上不依赖 BasicUtils 的 ExColor
- 但未来新增组件可能需要 BasicUtils 的工具函数
- **暂不声明依赖**，待实际需要时再加

---

## 2.5 不迁入共享模块的内容（保留在各 HAP 内部）

| 内容 | 保留位置 | 原因 |
|------|----------|------|
| RollDataManager.ets | `product/default/src/main/ets/pages/RollPage/` | 手机端特有（含 Preferences 持久化） |
| WearRollDataManager.ets | `product/wearable/src/main/ets/utils/` | 穿戴端特有（轻量版，无持久化） |
| RollItem/Roll 模型 | 各 HAP 内部 | 两端差异可能增大，不适合强耦合到共享包 |
| static_datas/ | `product/default/src/main/ets/static_datas/` | 仅 default 使用，无需共享 |
| WearScreenUtil.ets | `product/wearable/src/main/ets/utils/` | 穿戴端设备适配专用 |
| WearTruthOrDareData.ets | `product/wearable/src/main/ets/utils/` | 穿戴端特有数据 |
| form_cards/ form_display/ | `product/default/src/main/ets/` | 卡片仅手机端使用 |
| MainPage.ets (basic旧) | **删除** | 仅含 Hello World 模板，无实际用途 |
| Random.ets (VitalUI旧) | **删除** | 与 basic/Math.ets 重复，VitalUI 不应包含非UI逻辑 |

---

## 3. 执行步骤

### Phase 1: 创建新模块骨架

1. 创建 `common/BasicUtils/` 完整骨架（Index.ets, oh-package.json5, build-profile.json5, module.json5, hvigorfile.ts）
2. 创建 `common/SystemUtils/` 完整骨架
3. 更新 `common/VitalUI/` 骨架（已存在，需更新 Index.ets、oh-package.json5、module.json5）
4. 在根 `build-profile.json5` 的 modules 中注册 BasicUtils、SystemUtils，取消 VitalUI 注释
5. 在根 `oh-package.json5` 中注册新模块

### Phase 2: 迁移文件

| 源 | 目标 | 操作 |
|----|------|------|
| `basic/src/main/ets/utils/Logger.ets` | `BasicUtils/src/main/ets/utils/Logger.ets` | 移动 |
| `basic/src/main/ets/utils/CommonConstants.ets` | `BasicUtils/src/main/ets/utils/CommonConstants.ets` | 移动 |
| `basic/src/main/ets/utils/GlobalContext.ets` | `BasicUtils/src/main/ets/utils/GlobalContext.ets` | 移动 |
| `basic/src/main/ets/utils/Math.ets` | `BasicUtils/src/main/ets/algo/Math.ets` | 移动（注意目录变化 utils→algo） |
| `HarmonySystemUtils/src/main/ets/utils/VibratorManager.ets` | `SystemUtils/src/main/ets/VibratorManager.ets` | 移动 |
| `basic/src/main/ets/utils/BreakPointSystem.ets` | `SystemUtils/src/main/ets/BreakPointSystem.ets` | 移动 |
| `default/src/main/ets/utils/ApiVersionUtil.ets` | `SystemUtils/src/main/ets/ApiVersionUtil.ets` | 移动 |
| `basic/src/main/ets/components/ColorPickerComponent/` | `VitalUI/src/main/ets/components/ColorPickerComponent/` | 移动 |
| `VitalUI/src/main/ets/chart/` | `VitalUI/src/main/ets/components/chart/` | 重命名目录（chart→components/chart） |
| `VitalUI/src/main/ets/utils/ColorCode.ets` | — | **删除**（与Math.ets完全重复，无需合并） |
| `VitalUI/src/main/ets/utils/Random.ets` | — | **删除**（与Math.ets重复，VitalUI不应含非UI逻辑） |
| `basic/src/main/ets/components/MainPage.ets` | — | **删除**（Hello World模板） |

### Phase 3: 更新消费方 import 语句

**product/default/oh-package.json5 新依赖：**
```json5
"dependencies": {
  "@ohos/basic-utils": "file:../../common/BasicUtils",
  "@ohos/system-utils": "file:../../common/SystemUtils",
  "@ohos/vital-ui": "file:../../common/VitalUI"
}
```

**product/wearable/oh-package.json5 新依赖：**
```json5
"dependencies": {
  "@ohos/basic-utils": "file:../../common/BasicUtils"
}
```

**default 中 import 变更对照表：**

| 旧 import | 新 import | 影响文件数 |
|-----------|-----------|-----------|
| `import { Random } from '@ohos/common'` | `import { Random } from '@ohos/basic-utils'` | ~30 |
| `import { Randoms } from '@ohos/common'` | `import { Randoms } from '@ohos/basic-utils'` | 2 |
| `import { ExColor, Random } from '@ohos/common'` | `import { ExColor, Random } from '@ohos/basic-utils'` | 4 |
| `import { VibratorManager } from '@ohos/vibratorutil'` | `import { VibratorManager } from '@ohos/system-utils'` | 9 |
| `import { BreakpointState, BreakpointSystem } from '@ohos/common'` | `import { BreakpointState, BreakpointSystem } from '@ohos/system-utils'` | 7 |
| `import { CommonConstants } from '@ohos/common'` | `import { CommonConstants } from '@ohos/basic-utils'` | 2 |
| `import { GlobalContext, Logger } from '@ohos/common'` | `import { GlobalContext, Logger } from '@ohos/basic-utils'` | 1 |
| `import { ColorPickerButton } from '@ohos/common'` | `import { ColorPickerButton } from '@ohos/vital-ui'` | 2 |

**wearable 中 import 变更对照表：**

| 旧 import | 新 import | 影响文件数 |
|-----------|-----------|-----------|
| `import { Random } from '@ohos/common'` | `import { Random } from '@ohos/basic-utils'` | ~9 |
| `import { ExColor } from '@ohos/common'` | `import { ExColor } from '@ohos/basic-utils'` | 1 |

### Phase 4: 删除旧模块

1. 删除 `common/basic/` 目录（所有内容已迁出）
2. 删除 `common/HarmonySystemUtils/` 目录（所有内容已迁出）
3. 从根 `build-profile.json5` modules 中移除 basic、HarmonySystemUtils 的配置

### Phase 5（可选）: default 模块内部目录规范化

| 操作 | 说明 |
|------|------|
| `design_privew/` → `design_preview/` | 修正拼写 |
| 删除 `sub_pages/roll_wheel/` | 空目录 |
| static_datas/ 保留原位置 | 仅 default 使用，不必迁移 |

---

## 4. 根配置最终状态

### build-profile.json5 modules

```json5
"modules": [
  {
    "name": "default",
    "srcPath": "./product/default",
    "targets": [{ "name": "default", "applyToProducts": ["default"] }]
  },
  {
    "name": "wearable",
    "srcPath": "./product/wearable",
    "targets": [{ "name": "default", "applyToProducts": ["default"] }]
  },
  {
    "name": "BasicUtils",
    "srcPath": "./common/BasicUtils"
  },
  {
    "name": "SystemUtils",
    "srcPath": "./common/SystemUtils"
  },
  {
    "name": "VitalUI",
    "srcPath": "./common/VitalUI"
  }
]
```

---

## 5. 验证矩阵

| 验证项 | 方法 | 预期结果 |
|--------|------|----------|
| 编译检查 | `hvigorw assembleApp` | BUILD SUCCESSFUL |
| default 功能完整 | 手动启动模拟器，遍历功能页 | 所有功能正常 |
| wearable 功能完整 | 启动穿戴模拟器 | 所有穿戴页正常 |
| 模块分类正确 | 检查各模块 Index.ets | 导出内容与模块职责一致 |
| 无遗留旧依赖 | grep '@ohos/common' + grep '@ohos/vibratorutil' | 零匹配 |
| 无遗留旧文件 | 检查 common/ 下无 basic/、HarmonySystemUtils/ | 目录已删除 |

---

## 6. 风险与兼容性

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| VitalUI chart 组件使用 `string \| number \| CanvasGradient \| CanvasPattern` 联合类型 | ArkTS 严格模式可能报错 | 编译时检查，必要时调整类型 |
| ColorPickerDialog 内部自带的 HSL 工具函数与 BasicUtils/Math.ets 重复 | 无功能影响，仅代码冗余 | 可接受，ColorPicker 是自包含组件 |
| HAR 不支持传递依赖，消费方需显式声明所有需要的包 | 开发者需要知道该 import 哪个包 | 按职责分类本身就是为了方便记忆 |
| RollItem/Roll 模型在 default 和 wearable 中重复定义 | 模型不一致风险 | 当前可接受，未来差异大时再考虑抽取 |
| basic 模块 module.json5 缺少 wearable deviceType | 迁移前 wearable 编译依赖 basic 时受限 | 迁移到 BasicUtils 后将声明全设备类型，问题自动解决 |

---

## 7. 回滚方案

- 所有改动通过 Git 版本控制，`git checkout` 即可回滚
- 模块迁移是文件移动+配置修改，无数据丢失风险
- 建议每个 Phase 单独提交，便于精确回滚

---

## 8. 未来扩展约定

- **FeatureKit 模式**：未来如出现领域专属业务逻辑（如同步协议），新建独立 FeatureKit 包，不放入 BasicUtils
- **VitalUI 依赖增长**：当 VitalUI 新增组件确实需要 BasicUtils 工具时，再在 VitalUI 的 oh-package.json5 中声明依赖
- **wearable UI 支持**：当穿戴设备支持所需组件 API 时，扩展 VitalUI 的 deviceTypes 加入 wearable
