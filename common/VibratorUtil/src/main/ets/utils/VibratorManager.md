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
