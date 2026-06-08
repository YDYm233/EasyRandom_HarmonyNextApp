# VibratorManager 振动方案文档

## 概述

基于 `@ohos/vibratorutil` 封装统一振动管理器，为各随机互动页面提供触觉反馈，增强用户体验。

---

## 前置依赖

### 1. 权限声明 (`module.json5`)

```json5
{
  "name": "ohos.permission.VIBRATE",
  "reason": "$string:VIBRATE_REASON",
  "usedScene": {
    "abilities": ["EntryAbility"],
    "when": "inuse"
  }
}
```

### 2. 依赖引入 (`oh-package.json5`)

```json5
"@ohos/vibratorutil": "file:../vibratorutil"
```

### 3. 偏好设置 Key (`CommonConstants.ets`)

```ts
static readonly PREFERENCES_KEY_VIBRATION = 'isVibrationEnabled'
```

---

## 设计原则

| 原则 | 说明 |
|------|------|
| **场景耦合** | 振动方法专为各页面操作场景设计，直接体现"开始/结果/揭示"等用户认知模型 |
| **无侵入** | 仅在 `.onClick()` 入口追加一行静态调用，不改动原有业务逻辑 |
| **单例复用** | 全局复用同一个 `@ohos.vibrator` 实例，避免重复初始化 |
| **偏好联动** | 所有振动自动受 `Preferences` 中 `isVibrationEnabled` 开关控制 |

---

## 方法映射

| 方法 | 振动策略 | 适用场景 | 调用页面 |
|------|----------|----------|----------|
| `vibrateMuyu()` | 单次短振 | 敲击木鱼 | `BlessingMuyu.ets` |
| `vibrateTap()` | 单次轻振 | 硬币点击翻转 | `FlipCoin.ets` |
| `vibrateRoll()` | 单次中振 | 开始随机滚动/旋转 | `RollDices.ets` / `RollWheelPage.ets` |
| `vibrateVictory()` | 中振×3 间隔 | 转盘结果揭晓（胜利/完成） | `RollWheelPage.ets` |
| `vibrateResult()` | 单次重振 | 随机结果产出 | `RollDices.ets` / `FlipCoin.ets` / `HonestOrChallenge.ets` |
| `vibrateReveal()` | 轻→中渐强 | 答案/卦象揭示 | `AnswerPage.ets` / `DevineBaGua.ets` |
| `vibrateMagic()` | 连续长振 | 神秘/魔法类操作 | `DevineBaGua.ets` / `RandomColors.ets` |

---

## 接入模式（统一模板）

每个页面仅需两处改动：

```diff
+ import { VibratorManager } from '@ohos/vibratorutil';

  .onClick(() => {
+   VibratorManager.vibrateXxx();
    // ... 原有逻辑不动
  })
```

---

## 分页面接入详情

### 1. 木鱼 (`BlessingMuyu.ets`)

- **触发点**: 木鱼图片 `onClick` 入口
- **调用**: `VibratorManager.vibrateMuyu()`
- **位置**: `RollBlessingsBox` → `Image($r("app.media.MuYu"))` → `.onClick()` 第1行

### 2. 骰子 (`RollDices.ets`)

- **触发点**: "开始"按钮 `onClick`
- **调用**:
  - `onClick` 入口 → `VibratorManager.vibrateRoll()`
  - `clearInterval` 后 → `VibratorManager.vibrateResult()`
- **位置**: `RollDiceBox` → `Button('开始')`

### 3. 转盘 (`RollWheelPage.ets`)

- **触发点**: "开始"按钮 `onClick`
- **调用**:
  - `onClick` 入口 → `VibratorManager.vibrateRoll()`
  - `setTimeout` 回调尾 → `VibratorManager.vibrateVictory()`
- **位置**: `RollWheelsShow` → 底部控制区 `Button`

### 4. 硬币 (`FlipCoin.ets`)

- **触发点**: "开始"按钮 `onClick`
- **调用**:
  - `onClick` 入口 → `VibratorManager.vibrateTap()`
  - 最终 `setTimeout` → `VibratorManager.vibrateResult()`
- **位置**: `Coin` → `Button`

### 5. 答案之书 (`AnswerPage.ets`)

- **触发点**: 卡片翻转 `onClick`
- **调用**: `VibratorManager.vibrateReveal()`
- **位置**: `AnswerBook` → 卡片组件 `.onClick()` 第1行

### 6. 八卦占卜 (`DevineBaGua.ets`)

- **触发点**: "开始"按钮 `onClick`
- **调用**:
  - `onClick` 入口 → `VibratorManager.vibrateMagic()`
  - `setTimeout` 结果弹窗 → `VibratorManager.vibrateReveal()`
- **位置**: `BaGuaBox` → `Button`

### 7. 真心话 (`HonestOrChallenge.ets`)

- **触发点**: 指针旋转 / 直接点击区域
- **调用**:
  - 指针旋转结果 `setTimeout` → `VibratorManager.vibrateResult()`
  - "真心话"区域 `onClick` → `VibratorManager.vibrateResult()`
  - "大冒险"区域 `onClick` → `VibratorManager.vibrateResult()`
- **位置**: `HonestOrChallenge` → 指针/Grid 面板

### 8. 随机颜色 (`RandomColors.ets`)

- **触发点**: RGBA 文本点击随机换色
- **调用**: `VibratorManager.vibrateMagic()`
- **位置**: `ColorsBox` → `Text(this.RGBA)` → `.onClick()`

---

## 修改文件清单

| # | 文件 | 改动行 |
|---|------|--------|
| 1 | `product/default/src/main/ets/sub_pages/blessing_muyu/BlessingMuyu.ets` | +import, +1 行调用 |
| 2 | `product/default/src/main/ets/sub_pages/flip_dices/RollDices.ets` | +import, +2 行调用 |
| 3 | `product/default/src/main/ets/pages/RollPage/RollWheelPage.ets` | +import, +2 行调用 |
| 4 | `product/default/src/main/ets/sub_pages/flip_coin/FlipCoin.ets` | +import, +2 行调用 |
| 5 | `product/default/src/main/ets/pages/AnswerPage.ets` | +import, +1 行调用 |
| 6 | `product/default/src/main/ets/sub_pages/devine_bagua/DevineBaGua.ets` | +import, +2 行调用 |
| 7 | `product/default/src/main/ets/sub_pages/honest_or_challenge/HonestOrChallenge.ets` | +import, +3 行调用 |
| 8 | `product/default/src/main/ets/sub_pages/random_colors/RandomColors.ets` | +import, +1 行调用 |

---

## 控制流程

```
用户开启振动开关
    │
    ▼
Preferences.set('isVibrationEnabled', true)
    │
    ▼
各页面 onClick
    │
    ▼
VibratorManager.vibrateXxx()
    │
    ▼
内部检查 isVibrationEnabled
    │
    ├── false → 跳过振动
    │
    └── true → vibrator.startVibration(effectId, 'time')
```

---

## 注意事项

1. **权限**: `ohos.permission.VIBRATE` 已在 `module.json5` 中声明
2. **性能**: 所有振动调用为同步静态方法，零开销
3. **兼容**: 所有页面语法校验零错误 ✅
4. **可维护**: 所有振动逻辑集中在 `VibratorManager` 中，页面仅一行调用
