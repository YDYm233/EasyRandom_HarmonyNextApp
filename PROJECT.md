# EasyRandom — 项目分包架构设计

> 基于 HarmonyOS 官方三层分层模型（公共能力层 → 基础特性层 → 产品定制层）

---

## 整体架构

```
EasyRandom/
├── common/                    ← 公共能力层 (Commons)
│   ├── foundation/            HAR  基础工具
│   ├── data_assets/           HAR  静态数据
│   └── ui_components/         HAR  共享UI组件 (原 VitalUI)
│
├── features/                  ← 基础特性层 (Features)
│   ├── random_engine/         HAR  核心随机引擎
│   ├── haptic_feedback/       HAR  震动反馈抽象层
│   └── distributed_sync/     HSP  跨设备协同
│
└── product/                   ← 产品定制层 (Products)
    ├── phone_tablet/          HAP entry  手机 + 平板 (原 default)
    ├── tv/                    HAP entry  电视
    └── wearable/              HAP entry  手表 (暂注释)
```

---

## 依赖关系图

```
                    ┌──────────────────────────┐
                    │   product/phone_tablet    │
                    │     (HAP entry)           │
                    └──────┬───────┬───────────┘
                           │       │
              ┌────────────┤       ├────────────┐
              ▼            ▼       ▼            ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐
    │foundation│  │data_     │  │ui_       │  │random_engine     │
    │  (HAR)   │  │assets(HAR)│ │components│  │    (HAR)         │
    └──────────┘  └──────────┘  │  (HAR)   │  └────────┬─────────┘
                                └──────────┘           │
                    ┌──────────────────────────┐       │
                    │    product/tv             │       │
                    │    (HAP entry)            │◄──────┤
                    └──────────┬───────────────┘       │
                               │                       │
                               ├───────────────────────┘
                               │
                    ┌──────────▼───────────────┐
                    │   distributed_sync       │
                    │        (HSP)             │
                    └──────────────────────────┘

haptic_feedback (HAR) — 按需被 phone_tablet、wearable 引用
```

---

## 分层详解

### 一、公共能力层 `common/`

该层只被上层依赖，不反向依赖产品层或特性层。

#### 1. `common/foundation/` — 基础工具 (HAR)

```
common/foundation/
├── Index.ets
└── src/main/ets/
    ├── utils/
    │   ├── Math.ets              # Random, Randoms, ExColor
    │   ├── BreakPointSystem.ets  # 响应式断点
    │   ├── CommonConstants.ets   # 全局常量
    │   ├── GlobalContext.ets     # 全局上下文
    │   └── Logger.ets           # 日志
    └── types/
        └── CommonTypes.ets       # 公共类型定义
```

**选型理由**：纯工具类，无状态，编译进每个 HAP 成本小，不会有 HAR 单例失效问题。

#### 2. `common/data_assets/` — 静态数据 (HAR)

```
common/data_assets/
├── Index.ets
└── src/main/ets/
    ├── answers.ets      # 答案数据
    ├── challenges.ets   # 真心话大冒险
    ├── foods.ets        # 食物
    ├── names.ets        # 名字
    ├── places.ets       # 地点
    └── rolls.ets        # 转盘选项
```

**选型理由**：纯静态导出数据，从 `product/default` 迁出，TV / 手表均可引用。

#### 3. `common/ui_components/` — 共享 UI 组件 (HAR)

```
common/ui_components/
├── Index.ets
└── src/main/ets/
    ├── chart/
    │   ├── PieChart.ets
    │   ├── PieChart_V3.ets
    │   ├── RadarChart.ets
    │   ├── RoseChart.ets
    │   └── QuarterRoseChart.ets
    └── common/
        ├── RandomCard.ets       # 通用随机卡片
        └── ResultDisplay.ets    # 结果展示组件
```

**选型理由**：原 VitalUI 模块。图表组件是纯 UI，无运行时共享状态需求，HAR 即可。

---

### 二、基础特性层 `features/`

业务特性模块，高内聚低耦合，被产品层依赖。

#### 4. `features/random_engine/` — 核心随机引擎 (HAR)

```
features/random_engine/
├── Index.ets
└── src/main/ets/
    ├── RandomEngine.ets         # 统一随机入口
    ├── strategies/
    │   ├── WeightedRandom.ets   # 加权随机
    │   ├── ShuffleRandom.ets    # 洗牌随机
    │   └── SeedRandom.ets       # 种子随机（可复现）
    └── models/
        └── RandomResult.ets     # 随机结果模型
```

**目的**：将散落在各页面中的随机逻辑收敛，方便维护与多设备复用。

#### 5. `features/haptic_feedback/` — 震动反馈 (HAR)

```
features/haptic_feedback/
├── Index.ets
└── src/main/ets/
    ├── HapticEngine.ets         # 统一震动 API
    └── adapters/
        ├── PhoneHaptic.ets      # 线性马达
        ├── WatchHaptic.ets      # 基础震动
        └── TvHaptic.ets         # 降级为空实现
```

```typescript
// HapticEngine.ets — 设计示意
export enum HapticPreset {
  ROLL_START,
  ROLL_TICK,
  ROLL_RESULT,
  DICE_SHAKE,
  CARD_FLIP,
}

export class HapticEngine {
  static play(preset: HapticPreset): void {
    // 运行时判断设备能力
    if (canIUse('SystemCapability.Sensors.MiscDevice')) {
      // 调用实际震动
    }
  }
}
```

**选型理由**：震动是无状态调用，HAR 编译进各 HAP 即可。TV 遥控器可能不支持震动，降级为空。

#### 6. `features/distributed_sync/` — 跨设备协同 (HSP) ⭐

```
features/distributed_sync/
├── Index.ets
└── src/main/ets/
    ├── DistributedRandom.ets    # 多人协同随机
    ├── DeviceDiscovery.ets      # 设备发现
    ├── SyncSession.ets         # 同步会话管理
    └── models/
        └── SyncMessage.ets      # 同步消息体
```

**选型理由**：跨设备协同需要维护连接状态、设备列表等共享状态。若用 HAR 被多个 HAP 引用，会产生多份实例导致状态不一致。HSP 运行时只保留一份代码和状态，手机端与 TV 端可共享同一协同会话。

**module.json5 需声明权限**：
```json5

```

---

### 三、产品定制层 `product/`

不同设备形态的个性化业务，编译为独立 Entry HAP。

#### 7. `product/phone_tablet/` (HAP entry) — 手机+平板

**决策**：共包。

| 维度 | 手机 | 平板 | 差异化 |
|------|------|------|--------|
| 交互方式 | 触屏 | 触屏 | 无 |
| 屏幕比例 | 竖屏为主 | 横竖皆可 | 用 BreakpointSystem 响应式处理 |
| 布局结构 | 单列 | 双列 | BreakpointSystem 已覆盖 |

```json5
// module.json5
{
  "module": {
    "name": "phone_tablet",
    "type": "entry",
    "deviceTypes": ["phone", "tablet"]
  }
}
```

#### 8. `product/tv/` (HAP entry) — 电视 ⭐

**决策**：独立 Entry HAP。

| 维度 | 手机/平板 | 电视 | 差异 |
|------|----------|------|------|
| 交互方式 | 触屏 | 遥控器 (方向键+OK) | 完全不同 |
| 屏幕比例 | 竖/横 | 16:9 横屏 | 布局差异大 |
| 焦点管理 | 无 | D-Pad 焦点导航 | 全新机制 |

```
product/tv/src/main/ets/
├── pages/
│   ├── Index.ets              # TV 首页：大卡片网格
│   ├── RandomPage.ets         # 横屏随机选择器
│   └── settings/
│       └── SettingPage.ets    # 遥控器设置
├── components/
│   ├── FocusCard.ets          # 可获焦卡片
│   └── DPadNavigator.ets      # 方向键导航
└── tvability/
    └── TvAbility.ets
```

#### 9. `product/wearable/` (HAP entry) — 手表

已存在，暂注释。手表端极度精简：保留核心随机功能，一个页面搞定。

---

## HAR vs HSP vs Feature HAP 选型速查

| 决策维度 | HAR | HSP | Feature HAP |
|----------|-----|-----|-------------|
| 独立安装运行 | ❌ | ❌ | ✅ |
| 按需加载 | ❌ | ✅ | ✅ |
| 跨 HAP 共享状态 (单例) | ❌ | ✅ | — |
| 多包引用且包体积敏感 | ❌ | ✅ | — |
| 纯工具类 / 静态数据 | ✅ | ❌ | — |
| 导出接口给其他模块 | ✅ | ✅ | ❌ |
| 声明 ExtensionAbility | ❌ | ❌ | ✅ |

---

## 迁移路线

| 阶段 | 操作 | 影响 |
|------|------|------|
| ✅ 阶段1 | `product/default` 启用 VitalUI、注释 wearable | 已完成 |
| 阶段2 | `common/basic` → 改名 `common/foundation` | 更新所有 `@ohos/common` 依赖路径 |
| 阶段3 | 新建 `common/data_assets`，迁入 static_datas | 引用 static_datas 的文件改 import |
| 阶段4 | 新建 `common/ui_components`，迁入 VitalUI | 更新 default 依赖 |
| 阶段5 | 创建 `features/random_engine` | 收敛随机逻辑 |
| 阶段6 | 创建 `features/haptic_feedback` | 统一震动 API |
| 阶段7 | 创建 `product/tv` entry HAP | TV 专用 UI |
| 阶段8 | 创建 `features/distributed_sync` HSP | 跨设备协同 |

---

## 注意事项

- **TV 端权限**：TV 不支持震动、NFC 等传感器，使用前用 `canIUse()` 检测
- **HSP 版本一致性**：`distributed_sync` 的 versionCode 须与所有依赖它的 HAP 保持一致
- **deviceTypes 限制**：`phone` 和 `default` 不能同时出现，编译会报错
- **HAR 单例风险**：若未来 `haptic_feedback` 需在多 HAP 间共享震动状态，应改为 HSP
- **TV 焦点管理**：用 `focusable(true)` + `onFocus()` 替代 `onClick()`
