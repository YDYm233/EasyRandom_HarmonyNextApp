# VibratorManager

> 封装 `@ohos.vibrator` 系统振动 API 的静态工具类，提供 **34 个开箱即用的振动方法**，覆盖点击反馈、场景语义、振动序列、趣味交互和通知提醒五大类。每个方法均输出执行/失败日志，内置高频防抖机制。

---

## 📦 包名

```typescript
import { VibratorManager, VibrationUsage, HapticEffect } from '@ohos/vibratorutil';
```

## ⚙️ 前置要求

| 条件 | 说明 |
|------|------|
| 权限 | `ohos.permission.VIBRATE` |
| API Level | ≥ 9 |
| 设备 | 需硬件支持振动马达 |

---

## 🪵 日志

每个振动方法在**执行时**输出 `INFO` 级别日志，在**失败时**输出 `ERROR` 级别日志。

```
[INFO]  VibratorManager: vibrateMuyu executed
[ERROR] VibratorManager: vibrateMuyu failed: 201, Permission denied
```

---

## 📖 API 参考

### 1. 核心振动方法

| 方法 | 参数 | 说明 |
|------|------|------|
| `vibrateTime(dur, usage?)` | `dur: number`, `usage: VibrationUsage` | 按时长振动 |
| `vibratePreset(id, cnt?, int?, usage?)` | `effectId, count, intensity, usage` | 按预置效果振动 |
| `vibratePattern(durs, cnt?, usage?)` | `durations: number[], count, usage` | 按序列振动 |

```typescript
VibratorManager.vibrateTime(500);                                  // 振动500ms
VibratorManager.vibratePreset(HapticEffect.SOFT, 2, 80);          // 轻柔双振
VibratorManager.vibratePattern([100, 50, 200], 3);                // 序列重复3次
```

---

### 2. 快捷时长方

| 方法 | 时长 | 使用场景 |
|------|------|----------|
| `vibrateShort()` | ~100ms | 按钮点击反馈 |
| `vibrateMedium()` | ~300ms | 操作确认 |
| `vibrateLong()` | ~600ms | 强调提醒 |

---

### 3. 预设效果快捷法

| 方法 | 效果 | 使用场景 |
|------|------|----------|
| `vibrateTap()` | 轻柔单振 | 轻触/列表点击 |
| `vibrateKeyPress()` | 尖锐按键感 | 物理按键模拟 |
| `vibrateDoubleTap()` | 两次轻柔振 | 双击反馈 |
| `vibrateHeavyClick()` | 沉重单振 | 强力点击 |
| `vibrateTick()` | 极短 20ms | 时钟滴答 |
| `vibrateConfirm()` | 中等确认 | 操作确认 |
| `vibrateReject()` | 两次尖锐 | 拒绝/失败 |

---

### 4. 场景语义快捷法

| 方法 | 效果 | 使用场景 |
|------|------|----------|
| `vibrateSuccess()` | 两次短振 | 操作成功 |
| `vibrateError()` | 三次振动 | 错误反馈 |
| `vibrateWarning()` | 强振动 | 警告提醒 |

---

### 5. 振动序列快捷法

| 方法 | 描述 | 序列 |
|------|------|------|
| `vibrateHeartbeat()` | 模拟心跳 | `[80,200,80]` |
| `vibrateSOS()` | 三短三长三短 | `[100,100,100,...]` |
| `vibrateRipple()` | 涟漪衰减 | `[150,50,100,50,60,50,30]` |
| `vibrateBuzz()` | 连续短振 | `[60,40,60,40,60,40,60]` |
| `vibratePulse()` | 科技感脉冲 | `[40,80,40,80,40]` |
| `vibrateKnock()` | 三连敲门 | `[50,120,50,120,50]` |
| `vibrateDramatic()` | 逐渐增强悬念 | `[60,60,100,60,200,60,400]` |

---

### 6. 趣味场景快捷法 🎮

> 专为「随易 EasyRandom」等趣味应用设计

| 方法 | 效果 | 场景 | 特性 |
|------|------|------|------|
| `vibrateMuyu()` | 极短 20ms 敲击 | 🪵 木鱼敲击 | **内置 50ms 防抖**，高频连击不重叠 |
| `vibrateRoll()` | 渐强短振序列 | 🎲 骰子滚动 / 转盘旋转 | 模拟滚动加速感 |
| `vibrateResult()` | 中等双振 | 🎯 通用结果揭晓 | 比 success 更中性 |
| `vibrateReveal()` | 悬念→揭示 | 📖 答案之书 / 八卦占卜 | 停顿+揭示的戏剧感 |
| `vibrateMagic()` | 三次轻柔振 | ✨ 魔法/闪光效果 | 占卜、祝福类场景 |
| `vibrateVictory()` | 三短一长 | 🏆 胜利庆祝 | 庆祝节奏 |

```typescript
// 木鱼敲击（自动防抖，50ms 内重复触发静默跳过）
onClick(() => { VibratorManager.vibrateMuyu(); });

// 骰子开始滚动
VibratorManager.vibrateRoll();

// 结果出来
VibratorManager.vibrateResult();

// 答案之书翻牌揭晓
VibratorManager.vibrateReveal();

// 八卦占卜
VibratorManager.vibrateMagic();
```

---

### 7. 通知/提醒类 📳

| 方法 | 效果 | 场景 | 序列 |
|------|------|------|------|
| `vibrateIncoming()` | 长振间隔循环 | 来电提醒 | `[400,200,400,200,400]` |
| `vibrateAlarm()` | 急促重复 | 闹钟提醒 | `[200,100,200,100,200,100,200]` |
| `vibrateMessage()` | 两次短振 | 新消息通知 | `[100,100,100]` |

---

### 8. 停止控制

| 方法 | 说明 |
|------|------|
| `stop(mode?)` | 异步停止振动 |
| `stopSync()` | 同步停止所有振动 |

### 9. 能力检测

| 方法 | 说明 |
|------|------|
| `isEffectSupported(id)` | 是否支持指定效果 |
| `isHdSupported()` | 是否支持高清振动 |

---

## 🧭 完整方法速查表（34 个）

| 方法 | 分类 | 日志 | 防抖 |
|------|------|:--:|:--:|
| `vibrateTime()` | 核心 | ✅ | — |
| `vibratePreset()` | 核心 | ✅ | — |
| `vibratePattern()` | 核心 | ✅ | — |
| `vibrateShort()` | 时长方 | ✅ | — |
| `vibrateMedium()` | 时长方 | ✅ | — |
| `vibrateLong()` | 时长方 | ✅ | — |
| `vibrateTap()` | 预设 | ✅ | — |
| `vibrateKeyPress()` | 预设 | ✅ | — |
| `vibrateDoubleTap()` | 预设 | ✅ | — |
| `vibrateHeavyClick()` | 预设 | ✅ | — |
| `vibrateTick()` | 时长方 | ✅ | — |
| `vibrateConfirm()` | 预设 | ✅ | — |
| `vibrateReject()` | 预设 | ✅ | — |
| `vibrateSuccess()` | 场景语义 | ✅ | — |
| `vibrateError()` | 场景语义 | ✅ | — |
| `vibrateWarning()` | 场景语义 | ✅ | — |
| `vibrateHeartbeat()` | 序列 | ✅ | — |
| `vibrateSOS()` | 序列 | ✅ | — |
| `vibrateRipple()` | 序列 | ✅ | — |
| `vibrateBuzz()` | 序列 | ✅ | — |
| `vibratePulse()` | 序列 | ✅ | — |
| `vibrateKnock()` | 序列 | ✅ | — |
| `vibrateDramatic()` | 序列 | ✅ | — |
| **`vibrateMuyu()`** | 趣味 | ✅ | ✅ 50ms |
| **`vibrateRoll()`** | 趣味 | ✅ | — |
| **`vibrateResult()`** | 趣味 | ✅ | — |
| **`vibrateReveal()`** | 趣味 | ✅ | — |
| **`vibrateMagic()`** | 趣味 | ✅ | — |
| **`vibrateVictory()`** | 趣味 | ✅ | — |
| **`vibrateIncoming()`** | 通知 | ✅ | — |
| **`vibrateAlarm()`** | 通知 | ✅ | — |
| **`vibrateMessage()`** | 通知 | ✅ | — |
| `stop()` | 控制 | — | — |
| `stopSync()` | 控制 | — | — |
| `isEffectSupported()` | 检测 | — | — |
| `isHdSupported()` | 检测 | — | — |

---

## 🏷️ 枚举参考

### `VibrationUsage`

| 值 | 管控开关 | 典型用途 |
|----|----------|----------|
| `UNKNOWN` | 触感开关 | 未分类 |
| `ALARM` | 三态开关 | 闹钟/紧急告警 |
| `RING` | 三态开关 | 来电铃声 |
| `NOTIFICATION` | 三态开关 | 通知提醒 |
| `COMMUNICATION` | 三态开关 | 通信消息 |
| `TOUCH` | 触感开关 | 触摸交互 |
| `MEDIA` | 触感开关 | 音视频 |
| `PHYSICAL_FEEDBACK` | 触感开关 | 物理键/手势 |

### `HapticEffect`

| 值 | ID | 描述 |
|----|-----|------|
| `SOFT` | `haptic.effect.soft` | 松散弱振 |
| `HARD` | `haptic.effect.hard` | 沉重中振 |
| `SHARP` | `haptic.effect.sharp` | 尖锐强振 |

---

## 🔧 架构设计

```
┌──────────────────────────────────────────────┐
│              VibratorManager                 │
├──────────────────────────────────────────────┤
│  - logExecution()    [执行日志 INFO]         │
│  - logError()        [失败日志 ERROR]        │
│  - createCallback()  [异步回调工厂]          │
│  - shouldDebounce()  [高频防抖 50ms]         │
│  - lastVibrateMs     [防抖时间戳]            │
├──────────────────────────────────────────────┤
│  核心层 (3)                                  │
│  vibrateTime / vibratePreset / vibratePattern│
├──────────────────────────────────────────────┤
│  时长方 (3)        预设效果 (7)              │
│  Short/Medium/Long  Tap/KeyPress/DoubleTap   │
│  +Tick              HeavyClick/Confirm/Reject│
├──────────────────────────────────────────────┤
│  场景语义 (3)      振动序列 (7)              │
│  Success/Error/     Heartbeat/SOS/Ripple     │
│  Warning            Buzz/Pulse/Knock/Dramatic│
├──────────────────────────────────────────────┤
│  趣味场景 (6)      通知提醒 (3)              │
│  Muyu★/Roll/Result  Incoming/Alarm/Message   │
│  Reveal/Magic/Victory                        │
├──────────────────────────────────────────────┤
│  控制 (2)          检测 (2)                  │
│  stop/stopSync      isEffectSupported        │
│                     isHdSupported             │
└──────────┬───────────────────────────────────┘
           │ 依赖
┌──────────▼───────────────────────────────────┐
│     @kit.SensorServiceKit → vibrator API     │
└──────────────────────────────────────────────┘

★ = 内置 50ms 防抖
```

---

## 💡 EasyRandom 页面集成建议

| 页面 | 交互时机 | 推荐方法 |
|------|----------|----------|
| 🪵 木鱼 | 点击敲击 | `vibrateMuyu()` |
| 🎲 骰子 | 开始滚动 → 结果 | `vibrateRoll()` → `vibrateResult()` |
| 🎡 转盘 | 开始旋转 → 结果 | `vibrateRoll()` → `vibrateVictory()` |
| 🪙 硬币 | 开始翻转 → 结果 | `vibrateTap()` → `vibrateResult()` |
| 📖 答案之书 | 翻牌揭晓 | `vibrateReveal()` |
| ☯️ 八卦占卜 | 揭晓卦象 | `vibrateMagic()` + `vibrateReveal()` |
| 🎭 真心话 | 抽取结果 | `vibrateResult()` |
| 🎨 随机颜色 | 生成结果 | `vibrateMagic()` |
| ⚙️ 设置开关 | 开关切换 | `vibrateTap()` |

```typescript
import { VibratorManager } from '@ohos/vibratorutil';

// 木鱼 — 自动防抖
onClick(() => VibratorManager.vibrateMuyu());

// 骰子 — 开始滚动
onClick(() => {
  VibratorManager.vibrateRoll();
  // ... 开始 setInterval 切换骰面
});

// 骰子 — 结果揭晓
setTimeout(() => {
  VibratorManager.vibrateResult();
  // ... 显示最终骰面
}, 1600);
```
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
