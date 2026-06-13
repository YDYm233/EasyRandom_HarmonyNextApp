name: "EasyRandom 分包分类管理规划"
overview: "按职责将公共代码分入不同HAR模块，方便个人维护管理，不追求过度复用"
todos:
- content: "撰写规划文档到 /docs/package-restructure-plan.md"
  priority: high
  status: in_progress
- content: "Phase 1: 创建新HAR模块骨架 + 配置注册"
  priority: high
  status: pending
- content: "Phase 2: 迁移文件到新模块"
  priority: high
  status: pending
- content: "Phase 3: 更新消费方import + 删除旧模块"
  priority: high
  status: pending
- content: "Phase 4: default模块内部目录规范化"
  priority: medium
  status: pending
- content: "编译验证"
  priority: high
  status: pending
---
# EasyRandom 分包分类管理规划
## 1. 分包分类原则
根据您的描述，公共代码按**职责性质**分为以下类别：
| 类别 | 说明 | 举例 | 特点 |
|------|------|------|------|
| **自定义UI组件** | 自己开发的ArkUI组件 | ColorPicker、PieChart、RoseChart | 有UI渲染、有`@Component` |
| **系统能力封装** | 基于系统API的二次封装 | VibratorManager、BreakPointSystem、ApiVersionUtil | 调用`@kit.*`，无UI |
| **通用工具** | 初学时从官方文档拷贝/基础工具 | Logger、CommonConstants、GlobalContext | 极度通用、几乎每个模块都用到 |
| **自定义业务逻辑** | 自己写的业务复用逻辑 | Random/Randoms/ExColor | 纯逻辑函数，与具体业务相关 |
## 2. 分包方案
### 2.1 新模块结构
```
common/
├── BasicKit/          # 通用工具包 — 最底层的通用基础设施
│   └── src/main/ets/
│       ├── Logger.ets
│       ├── CommonConstants.ets
│       └── GlobalContext.ets
│
├── SystemKit/         # 系统能力封装包 — 基于系统API的集成封装
│   └── src/main/ets/
│       ├── VibratorManager.ets      # ← @kit.SensorServiceKit
│       ├── BreakPointSystem.ets     # ← @ohos.mediaquery
│       └── ApiVersionUtil.ets       # ← @kit.BasicServicesKit
│
├── CoreKit/           # 自定义业务逻辑包 — 自己写的复用逻辑函数
│   └── src/main/ets/
│       ├── Math.ets                 # Random/Randoms/ExColor
│       └── ColorCode.ets            # ← VitalUI的同名工具（与Math.ets中ExColor重复，需合并）
│
├── VitalUI/           # 自定义UI组件包 — 自己开发的ArkUI组件
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
├── (删除 basic/)      # 原 basic 模块内容已全部分迁出
├── (删除 HarmonySystemUtils/)  # 内容迁入 SystemKit
```
### 2.2 模块命名与包名映射
| 模块目录 | 包名(oh-package.json5的name) | 消费方import路径 |
|----------|------------------------------|------------------|
| `common/BasicKit` | `@ohos/basic-kit` | `import { Logger } from '@ohos/basic-kit'` |
| `common/SystemKit` | `@ohos/system-kit` | `import { VibratorManager } from '@ohos/system-kit'` |
| `common/CoreKit` | `@ohos/core-kit` | `import { Random } from '@ohos/core-kit'` |
| `common/VitalUI` | `@ohos/vital-ui` | `import { ColorPickerButton } from '@ohos/vital-ui'` |
### 2.3 模块依赖关系
```
default (HAP) ──→ CoreKit, SystemKit, VitalUI, BasicKit
wearable (HAP) ──→ CoreKit, BasicKit
VitalUI ──→ CoreKit    (ColorPickerDialog内部使用ExColor颜色转换)
SystemKit ──→ BasicKit  (VibratorManager内部使用Logger日志)
CoreKit ──→ (无依赖)   (纯逻辑，不依赖其他自定义模块)
BasicKit ──→ (无依赖)  (最底层基础设施)
```
> **注意**：HAR 不支持传递依赖。如果 VitalUI 依赖 CoreKit，则 default 模块即使 import 了 VitalUI，也无法直接使用 CoreKit 的导出——需要 default 显式声明对 CoreKit 的依赖。这是 HAR 的正常行为，符合"按需引入"的管理理念。
### 2.4 各模块详细内容与导出
#### BasicKit — 通用工具包
```
common/BasicKit/
├── Index.ets
├── oh-package.json5       { name: "@ohos/basic-kit", main: "Index.ets" }
├── build-profile.json5
├── consumer-rules.txt
├── obfuscation-rules.txt
├── hvigorfile.ts
└── src/main/
    ├── module.json5        { type: "har", deviceTypes: ["default","tablet","2in1","car","wearable"] }
    └── ets/
        ├── Logger.ets
        ├── CommonConstants.ets
        └── GlobalContext.ets
```
**Index.ets 导出：**
```typescript
export { default as Logger } from './src/main/ets/Logger'
export { default as CommonConstants } from './src/main/ets/CommonConstants'
export { GlobalContext } from './src/main/ets/GlobalContext'
```
**deviceTypes**: 全设备类型（Logger/Constants 是最通用的基础设施）
---
#### SystemKit — 系统能力封装包
```
common/SystemKit/
├── Index.ets
├── oh-package.json5       { name: "@ohos/system-kit", main: "Index.ets", dependencies: { "@ohos/basic-kit": "file:../BasicKit" } }
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
---
#### CoreKit — 自定义业务逻辑包
```
common/CoreKit/
├── Index.ets
├── oh-package.json5       { name: "@ohos/core-kit", main: "Index.ets" }
├── build-profile.json5
├── consumer-rules.txt
├── obfuscation-rules.txt
├── hvigorfile.ts
└── src/main/
    ├── module.json5        { type: "har", deviceTypes: ["default","tablet","2in1","car","wearable"] }
    └── ets/
        └── Math.ets              # Random + Randoms + ExColor + rgbaToHex8 + 所有颜色转换函数
```
**Index.ets 导出：**
```typescript
export { Random, Randoms, ExColor, rgbaToHex8 } from './src/main/ets/Math'
```
**重要：合并 VitalUI/ColorCode.ets 到 Math.ets**
- ColorCode.ets 中的 `rgbaToHex8`、`ExColor` 与 Math.ets 中的完全重复
- 合并策略：以 Math.ets 为基础，将 ColorCode.ets 中 Math.ets 缺失的辅助函数补入，删除 ColorCode.ets
- ColorPickerDialog.ets 内部自带完整的 HSL/RGB 转换工具函数（不依赖外部），不受影响
---
#### VitalUI — 自定义UI组件包
```
common/VitalUI/
├── Index.ets
├── oh-package.json5       { name: "@ohos/vital-ui", main: "Index.ets", dependencies: { "@ohos/core-kit": "file:../CoreKit" } }
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
```
**deviceTypes**: 暂不含 wearable
- ColorPicker: 使用了 `TextInput`、`SymbolGlyph`、`bindPopup` 等，当前穿戴设备不一定支持
- Chart 组件: 使用 Canvas，穿戴设备理论可用，但 Demo 页面不适用
- 后续如需穿戴版组件，可扩展 deviceTypes
  **依赖说明**：VitalUI → CoreKit
- ColorPickerDialog 内部**已自带**完整的 HSL/RGB 转换函数，实际上不依赖 CoreKit 的 ExColor
- 但未来新增组件可能需要 CoreKit 的工具函数
- **暂不声明依赖**，待实际需要时再加
---
### 2.5 不迁入共享模块的内容（保留在各 HAP 内部）
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
## 3. 执行步骤
### Phase 1: 创建新模块骨架
1. 创建 `common/BasicKit/` 完整骨架（Index.ets, oh-package.json5, build-profile.json5, module.json5, hvigorfile.ts）
2. 创建 `common/SystemKit/` 完整骨架
3. 创建 `common/CoreKit/` 完整骨架
4. 保留 `common/VitalUI/` 骨架（已存在，需更新 Index.ets 和 oh-package.json5）
5. 在根 `build-profile.json5` 的 modules 中注册 BasicKit、SystemKit、CoreKit，取消 VitalUI 注释
6. 在根 `oh-package.json5` 中注册新模块
### Phase 2: 迁移文件
| 源 | 目标 | 操作 |
|----|------|------|
| `basic/src/main/ets/utils/Logger.ets` | `BasicKit/src/main/ets/Logger.ets` | 移动 |
| `basic/src/main/ets/utils/CommonConstants.ets` | `BasicKit/src/main/ets/CommonConstants.ets` | 移动 |
| `basic/src/main/ets/utils/GlobalContext.ets` | `BasicKit/src/main/ets/GlobalContext.ets` | 移动 |
| `HarmonySystemUtils/src/main/ets/utils/VibratorManager.ets` | `SystemKit/src/main/ets/VibratorManager.ets` | 移动 |
| `basic/src/main/ets/utils/BreakPointSystem.ets` | `SystemKit/src/main/ets/BreakPointSystem.ets` | 移动 |
| `default/src/main/ets/utils/ApiVersionUtil.ets` | `SystemKit/src/main/ets/ApiVersionUtil.ets` | 移动 |
| `basic/src/main/ets/utils/Math.ets` | `CoreKit/src/main/ets/Math.ets` | 移动 + 合并 ColorCode |
| `VitalUI/src/main/ets/utils/ColorCode.ets` | 合并入 `CoreKit/src/main/ets/Math.ets` | 合并后删除 |
| `basic/src/main/ets/components/ColorPickerComponent/` | `VitalUI/src/main/ets/components/ColorPickerComponent/` | 移动 |
| `VitalUI/src/main/ets/Demo/` | 保留在 VitalUI | 不动 |
| `VitalUI/src/main/ets/chart/` | `VitalUI/src/main/ets/components/chart/` | 重命名目录（chart→components/chart） |
### Phase 3: 更新消费方 import 语句
**product/default/oh-package.json5 新依赖：**
```json5
"dependencies": {
  "@ohos/basic-kit": "file:../../common/BasicKit",
  "@ohos/system-kit": "file:../../common/SystemKit",
  "@ohos/core-kit": "file:../../common/CoreKit",
  "@ohos/vital-ui": "file:../../common/VitalUI"
}
```
**product/wearable/oh-package.json5 新依赖：**
```json5
"dependencies": {
  "@ohos/basic-kit": "file:../../common/BasicKit",
  "@ohos/core-kit": "file:../../common/CoreKit"
}
```
**default 中 import 变更对照表：**
| 旧 import | 新 import | 影响文件数 |
|-----------|-----------|-----------|
| `import { Random } from '@ohos/common'` | `import { Random } from '@ohos/core-kit'` | ~30 |
| `import { Randoms } from '@ohos/common'` | `import { Randoms } from '@ohos/core-kit'` | 2 |
| `import { ExColor, Random } from '@ohos/common'` | `import { ExColor, Random } from '@ohos/core-kit'` | 4 |
| `import { VibratorManager } from '@ohos/vibratorutil'` | `import { VibratorManager } from '@ohos/system-kit'` | 9 |
| `import { BreakpointState, BreakpointSystem } from '@ohos/common'` | `import { BreakpointState, BreakpointSystem } from '@ohos/system-kit'` | 7 |
| `import { CommonConstants } from '@ohos/common'` | `import { CommonConstants } from '@ohos/basic-kit'` | 2 |
| `import { GlobalContext, Logger } from '@ohos/common'` | `import { GlobalContext, Logger } from '@ohos/basic-kit'` | 1 |
| `import { ColorPickerButton } from '@ohos/common'` | `import { ColorPickerButton } from '@ohos/vital-ui'` | 2 |
**wearable 中 import 变更对照表：**
| 旧 import | 新 import | 影响文件数 |
|-----------|-----------|-----------|
| `import { Random } from '@ohos/common'` | `import { Random } from '@ohos/core-kit'` | ~9 |
| `import { ExColor } from '@ohos/common'` | `import { ExColor } from '@ohos/core-kit'` | 1 |
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
    "name": "BasicKit",
    "srcPath": "./common/BasicKit"
  },
  {
    "name": "SystemKit",
    "srcPath": "./common/SystemKit"
  },
  {
    "name": "CoreKit",
    "srcPath": "./common/CoreKit"
  },
  {
    "name": "VitalUI",
    "srcPath": "./common/VitalUI"
  }
]
```
## 5. 验证矩阵
| 验证项 | 方法 | 预期结果 |
|--------|------|----------|
| 编译检查 | `hvigorw assembleApp` | BUILD SUCCESSFUL |
| default 功能完整 | 手动启动模拟器，遍历功能页 | 所有功能正常 |
| wearable 功能完整 | 启动穿戴模拟器 | 所有穿戴页正常 |
| 模块分类正确 | 检查各模块 Index.ets | 导出内容与模块职责一致 |
| 无遗留旧依赖 | grep '@ohos/common' + grep '@ohos/vibratorutil' | 零匹配 |
## 6. 风险与兼容性
| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| VitalUI chart 组件使用 `string \| number \| CanvasGradient \| CanvasPattern` 联合类型 | ArkTS 严格模式可能报错 | 编译时检查，必要时调整类型 |
| ColorPickerDialog 内部自带的 HSL 工具函数与 CoreKit/Math.ets 重复 | 无功能影响，仅代码冗余 | 可接受，ColorPicker 是自包含组件 |
| HAR 不支持传递依赖，消费方需显式声明所有需要的包 | 开发者需要知道该 import 哪个包 | 按职责分类本身就是为了方便记忆 |
| RollItem/Roll 模型在 default 和 wearable 中重复定义 | 模型不一致风险 | 当前可接受，未来差异大时再考虑抽取 |
## 7. 回滚方案
- 所有改动通过 Git 版本控制，`git checkout` 即可回滚
- 模块迁移是文件移动+配置修改，无数据丢失风险
- 建议每个 Phase 单独提交，便于精确回滚
  ]
  规划已重写，核心变化：
  4 个 HAR 模块按职责分类：
  模块	职责	内容
  BasicKit	通用基础设施	Logger、CommonConstants、GlobalContext
  SystemKit	系统能力封装	VibratorManager、BreakPointSystem、ApiVersionUtil
  CoreKit	自定义业务逻辑	Random/Randoms/ExColor（含合并ColorCode）
  VitalUI	自定义UI组件	ColorPicker、各Chart图表
  依赖链： BasicKit ← SystemKit ← CoreKit ← VitalUI（单向，HAR 不传递依赖需显式声明）
  删除的模块： basic、HarmonySystemUtils（内容全部分迁）