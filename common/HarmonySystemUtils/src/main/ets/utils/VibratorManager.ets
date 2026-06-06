import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'VibratorManager';
const DOMAIN = 0xFF00;

/**
 * 振动反馈场景类型
 */
export enum VibrationUsage {
  /** 无明确场景，最低优先级，受触感开关管控 */
  UNKNOWN = 'unknown',
  /** 警报场景，受三态开关管控 */
  ALARM = 'alarm',
  /** 铃声场景，受三态开关管控 */
  RING = 'ring',
  /** 通知场景，受三态开关管控 */
  NOTIFICATION = 'notification',
  /** 通信场景，受三态开关管控 */
  COMMUNICATION = 'communication',
  /** 触摸场景，受触感开关管控 */
  TOUCH = 'touch',
  /** 多媒体场景，受触感开关管控 */
  MEDIA = 'media',
  /** 物理反馈场景，受触感开关管控 */
  PHYSICAL_FEEDBACK = 'physicalFeedback',
}

/**
 * 系统预置振动效果ID
 */
export enum HapticEffect {
  /** 松散的弱振动 */
  SOFT = 'haptic.effect.soft',
  /** 沉重的中等振动 */
  HARD = 'haptic.effect.hard',
  /** 尖锐的强振动 */
  SHARP = 'haptic.effect.sharp',
}

/**
 * 振动管理器
 * 封装 @ohos.vibrator 系统振动API，提供常用振动方法
 */
export class VibratorManager {
  /** 木鱼高频防抖：距上次振动不足此值(ms)则跳过 */
  private static readonly DEBOUNCE_MS = 50;
  /** 上次震动时间戳(ms)，用于防抖 */
  private static lastVibrateMs: number = 0;

  /**
   * 记录振动方法执行日志
   * @param methodName 调用方法名
   */
  private static logExecution(methodName: string): void {
    hilog.info(DOMAIN, TAG, `${methodName} executed`);
  }

  /**
   * 统一错误日志输出
   * @param methodName 调用方法名
   * @param err 错误对象
   */
  private static logError(methodName: string, err: BusinessError | Error): void {
    const businessErr = err as BusinessError;
    hilog.error(DOMAIN, TAG, `${methodName} failed: ${businessErr.code ?? ''}, ${businessErr.message}`);
  }

  /**
   * 创建标准异步错误回调：统一日志格式，避免重复代码
   * @param methodName 方法名，用于日志标识
   */
  private static createCallback(methodName: string): (error: BusinessError) => void {
    return (error: BusinessError) => {
      if (error) {
        VibratorManager.logError(methodName, error);
      }
    };
  }

  /**
   * 高频防抖检查：返回 true 表示应跳过本次振动
   */
  private static shouldDebounce(): boolean {
    const now = Date.now();
    if (now - VibratorManager.lastVibrateMs < VibratorManager.DEBOUNCE_MS) {
      return true;
    }
    VibratorManager.lastVibrateMs = now;
    return false;
  }

  /**
   * 按指定时长触发振动
   * @param duration 振动时长，单位ms
   * @param usage 振动场景，默认TOUCH
   */
  static vibrateTime(duration: number, usage: VibrationUsage = VibrationUsage.TOUCH): void {
    VibratorManager.logExecution(`vibrateTime(${duration}ms)`);
    try {
      vibrator.startVibration(
        { type: 'time', duration },
        { usage },
        VibratorManager.createCallback('vibrateTime')
      );
    } catch (err) {
      VibratorManager.logError('vibrateTime', err as Error);
    }
  }

  /**
   * 按预置效果触发振动
   * @param effectId 预置效果ID，如 haptic.effect.soft
   * @param count 重复次数，默认1
   * @param intensity 强度 0-100，默认100
   * @param usage 振动场景，默认TOUCH
   */
  static vibratePreset(
    effectId: string,
    count: number = 1,
    intensity: number = 100,
    usage: VibrationUsage = VibrationUsage.TOUCH
  ): void {
    VibratorManager.logExecution(`vibratePreset(${effectId}, count=${count}, intensity=${intensity})`);
    try {
      vibrator.startVibration(
        { type: 'preset', effectId, count, intensity },
        { usage },
        VibratorManager.createCallback('vibratePreset')
      );
    } catch (err) {
      VibratorManager.logError('vibratePreset', err as Error);
    }
  }

  /**
   * 按自定义振动序列触发振动（pattern模式）
   * 可实现长短交替、渐强渐弱等复杂振动效果
   * @param durations 振动时长序列，单位ms，例如 [100, 50, 200] 表示振100ms→停50ms→振200ms
   * @param count 序列重复次数，默认1；-1表示无限重复（需手动stop）
   * @param usage 振动场景，默认TOUCH
   */
  static vibratePattern(
    durations: number[],
    count: number = 1,
    usage: VibrationUsage = VibrationUsage.TOUCH
  ): void {
    VibratorManager.logExecution(`vibratePattern([${durations.join(',')}], count=${count})`);
    if (!durations || durations.length === 0) {
      hilog.warn(DOMAIN, TAG, 'vibratePattern: durations is empty, skipped');
      return;
    }
    // 限制重复次数，防止无限递归
    const repeat = count < 0 ? 1 : count;
    const execPattern = (cycle: number): void => {
      if (cycle >= repeat) {
        return;
      }
      let elapsed = 0;
      for (let i = 0; i < durations.length; i++) {
        const delay = elapsed;
        if (i % 2 === 0) {
          // 偶数下标：振动段
          setTimeout(() => {
            vibrator.startVibration(
              { type: 'time', duration: durations[i] },
              { usage },
              VibratorManager.createCallback('vibratePattern')
            );
          }, delay);
        }
        // 奇数下标：静默段，仅累加时间不做操作
        elapsed += durations[i];
      }
      // 当前周期结束后触发下一周期
      if (repeat > 1) {
        setTimeout(() => {
          execPattern(cycle + 1);
        }, elapsed);
      }
    };
    execPattern(0);
  }

  // ═══════════════════════════════════════════════════════════════
  //  快捷时长方
  // ═══════════════════════════════════════════════════════════════

  /** 短振动 ~100ms，常用于按钮点击反馈 */
  static vibrateShort(): void {
    VibratorManager.logExecution('vibrateShort');
    VibratorManager.vibrateTime(100, VibrationUsage.TOUCH);
  }

  /** 中等振动 ~300ms，常用于操作确认 */
  static vibrateMedium(): void {
    VibratorManager.logExecution('vibrateMedium');
    VibratorManager.vibrateTime(300, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 长振动 ~600ms，常用于强调提醒 */
  static vibrateLong(): void {
    VibratorManager.logExecution('vibrateLong');
    VibratorManager.vibrateTime(600, VibrationUsage.NOTIFICATION);
  }

  // ═══════════════════════════════════════════════════════════════
  //  预设效果快捷法
  // ═══════════════════════════════════════════════════════════════

  /** 轻触反馈 — 预设轻柔效果 */
  static vibrateTap(): void {
    VibratorManager.logExecution('vibrateTap');
    VibratorManager.vibratePreset(HapticEffect.SOFT, 1, 30, VibrationUsage.TOUCH);
  }

  /** 按键反馈 — 预设尖锐效果 */
  static vibrateKeyPress(): void {
    VibratorManager.logExecution('vibrateKeyPress');
    VibratorManager.vibratePreset(HapticEffect.SHARP, 1, 50, VibrationUsage.TOUCH);
  }

  /** 双击反馈 — 两次轻柔短振，模拟双击 */
  static vibrateDoubleTap(): void {
    VibratorManager.logExecution('vibrateDoubleTap');
    VibratorManager.vibratePreset(HapticEffect.SOFT, 2, 40, VibrationUsage.TOUCH);
  }

  /** 重击反馈 — 单次沉重振动，模拟强力点击 */
  static vibrateHeavyClick(): void {
    VibratorManager.logExecution('vibrateHeavyClick');
    VibratorManager.vibratePreset(HapticEffect.HARD, 1, 100, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 滴答反馈 — 极短轻柔振动，模拟时钟滴答 */
  static vibrateTick(): void {
    VibratorManager.logExecution('vibrateTick');
    VibratorManager.vibrateTime(20, VibrationUsage.TOUCH);
  }

  /** 确认反馈 — 中等强度单次振动，表示操作已确认 */
  static vibrateConfirm(): void {
    VibratorManager.logExecution('vibrateConfirm');
    VibratorManager.vibratePreset(HapticEffect.HARD, 1, 60, VibrationUsage.TOUCH);
  }

  /** 拒绝反馈 — 两次尖锐振动，表示操作被拒绝或失败 */
  static vibrateReject(): void {
    VibratorManager.logExecution('vibrateReject');
    VibratorManager.vibratePreset(HapticEffect.SHARP, 2, 80, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  // ═══════════════════════════════════════════════════════════════
  //  场景语义快捷法
  // ═══════════════════════════════════════════════════════════════

  /** 成功反馈 — 两次短振 */
  static vibrateSuccess(): void {
    VibratorManager.logExecution('vibrateSuccess');
    VibratorManager.vibratePreset(HapticEffect.SOFT, 2, 100, VibrationUsage.TOUCH);
  }

  /** 错误反馈 — 三次振动 */
  static vibrateError(): void {
    VibratorManager.logExecution('vibrateError');
    VibratorManager.vibratePreset(HapticEffect.SHARP, 3, 100, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 警告反馈 — 强振动 */
  static vibrateWarning(): void {
    VibratorManager.logExecution('vibrateWarning');
    VibratorManager.vibratePreset(HapticEffect.HARD, 1, 100, VibrationUsage.ALARM);
  }

  // ═══════════════════════════════════════════════════════════════
  //  振动序列快捷法
  // ═══════════════════════════════════════════════════════════════

  /** 心跳振动 — 模拟心跳节奏 (咚咚) */
  static vibrateHeartbeat(): void {
    VibratorManager.logExecution('vibrateHeartbeat');
    VibratorManager.vibratePattern([80, 200, 80], 1, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** SOS求救信号 — 三短三长三短 (··· −−− ···) */
  static vibrateSOS(): void {
    VibratorManager.logExecution('vibrateSOS');
    VibratorManager.vibratePattern(
      [100, 100, 100, 100, 100, 300, 300, 100, 300, 100, 300, 300, 100, 100, 100, 100, 100],
      1,
      VibrationUsage.ALARM
    );
  }

  /** 涟漪振动 — 由强到弱的衰减振动，模拟水波扩散 */
  static vibrateRipple(): void {
    VibratorManager.logExecution('vibrateRipple');
    VibratorManager.vibratePattern([150, 50, 100, 50, 60, 50, 30], 1, VibrationUsage.TOUCH);
  }

  /** 连振反馈 — 连续短振序列，适合吸引注意但不打扰 */
  static vibrateBuzz(): void {
    VibratorManager.logExecution('vibrateBuzz');
    VibratorManager.vibratePattern([60, 40, 60, 40, 60, 40, 60], 1, VibrationUsage.NOTIFICATION);
  }

  /** 脉冲振动 — 短促脉冲节奏，模拟科技感扫描 */
  static vibratePulse(): void {
    VibratorManager.logExecution('vibratePulse');
    VibratorManager.vibratePattern([40, 80, 40, 80, 40], 1, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 敲门振动 — 三连敲击 (咚咚咚)，模拟敲门 */
  static vibrateKnock(): void {
    VibratorManager.logExecution('vibrateKnock');
    VibratorManager.vibratePattern([50, 120, 50, 120, 50], 1, VibrationUsage.TOUCH);
  }

  /** 戏剧性振动 — 逐渐增强的悬念感，适合揭晓重大结果 */
  static vibrateDramatic(): void {
    VibratorManager.logExecution('vibrateDramatic');
    VibratorManager.vibratePattern([60, 60, 100, 60, 200, 60, 400], 1, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  // ═══════════════════════════════════════════════════════════════
  //  趣味场景快捷法（适配 EasyRandom 应用）
  // ═══════════════════════════════════════════════════════════════

  /**
   * 木鱼敲击反馈 — 极短振动 20ms，内置 50ms 防抖
   * 专为高频连击场景设计，自动跳过过快的重复触发，避免振动重叠
   */
  static vibrateMuyu(): void {
    if (VibratorManager.shouldDebounce()) {
      return;
    }
    VibratorManager.logExecution('vibrateMuyu');
    try {
      vibrator.startVibration(
        { type: 'time', duration: 20 },
        { usage: VibrationUsage.TOUCH },
        VibratorManager.createCallback('vibrateMuyu')
      );
    } catch (err) {
      VibratorManager.logError('vibrateMuyu', err as Error);
    }
  }

  /** 滚动振动 — 渐强短振序列，模拟骰子滚动/转盘旋转 */
  static vibrateRoll(): void {
    VibratorManager.logExecution('vibrateRoll');
    VibratorManager.vibratePattern([40, 30, 55, 30, 70, 30, 90, 30, 110], 1, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 结果揭晓 — 中等力度双振，通用结果反馈 */
  static vibrateResult(): void {
    VibratorManager.logExecution('vibrateResult');
    VibratorManager.vibratePreset(HapticEffect.HARD, 2, 70, VibrationUsage.TOUCH);
  }

  /** 神秘揭晓 — 悬念积聚后揭示，适合答案之书、八卦占卜等 */
  static vibrateReveal(): void {
    VibratorManager.logExecution('vibrateReveal');
    VibratorManager.vibratePattern([30, 120, 50, 120, 80, 250, 150], 1, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 魔法振动 — 三次轻柔振动，模拟魔法/闪光效果 */
  static vibrateMagic(): void {
    VibratorManager.logExecution('vibrateMagic');
    VibratorManager.vibratePreset(HapticEffect.SOFT, 3, 60, VibrationUsage.TOUCH);
  }

  /** 胜利振动 — 三短一长的庆祝节奏 */
  static vibrateVictory(): void {
    VibratorManager.logExecution('vibrateVictory');
    VibratorManager.vibratePattern([80, 60, 80, 60, 80, 60, 400], 1, VibrationUsage.TOUCH);
  }

  // ═══════════════════════════════════════════════════════════════
  //  通知/提醒类快捷法
  // ═══════════════════════════════════════════════════════════════

  /** 来电振动 — 长振间隔循环，模拟来电提醒 */
  static vibrateIncoming(): void {
    VibratorManager.logExecution('vibrateIncoming');
    VibratorManager.vibratePattern([400, 200, 400, 200, 400], 1, VibrationUsage.RING);
  }

  /** 闹钟振动 — 急促重复振动，模拟闹钟提醒 */
  static vibrateAlarm(): void {
    VibratorManager.logExecution('vibrateAlarm');
    VibratorManager.vibratePattern([200, 100, 200, 100, 200, 100, 200], 1, VibrationUsage.ALARM);
  }

  /** 消息振动 — 两次短振，模拟新消息通知 */
  static vibrateMessage(): void {
    VibratorManager.logExecution('vibrateMessage');
    VibratorManager.vibratePattern([100, 100, 100], 1, VibrationUsage.NOTIFICATION);
  }

  // ═══════════════════════════════════════════════════════════════
  //  停止控制
  // ═══════════════════════════════════════════════════════════════

  /**
   * 停止指定模式的振动
   * @param stopMode 停止模式：VIBRATOR_STOP_MODE_TIME / VIBRATOR_STOP_MODE_PRESET
   */
  static stop(stopMode?: string): void {
    try {
      if (stopMode) {
        vibrator.stopVibration(stopMode as vibrator.VibratorStopMode, VibratorManager.createCallback('stop'));
      } else {
        vibrator.stopVibration(VibratorManager.createCallback('stop'));
      }
    } catch (err) {
      VibratorManager.logError('stop', err as Error);
    }
  }

  /**
   * 同步停止所有振动
   */
  static stopSync(): void {
    try {
      vibrator.stopVibrationSync();
    } catch (err) {
      VibratorManager.logError('stopSync', err as Error);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  能力检测
  // ═══════════════════════════════════════════════════════════════

  /**
   * 查询是否支持指定预置振动效果
   * @param effectId 振动效果ID
   * @returns 同步查询结果，支持返回true
   */
  static isEffectSupported(effectId: string): boolean {
    try {
      return vibrator.isSupportEffectSync(effectId);
    } catch (err) {
      VibratorManager.logError('isEffectSupported', err as Error);
      return false;
    }
  }

  /**
   * 查询当前设备是否支持高清振动（可调节强度）
   * @returns true表示支持高清振动
   */
  static isHdSupported(): boolean {
    try {
      return vibrator.isHdHapticSupported();
    } catch (err) {
      VibratorManager.logError('isHdSupported', err as Error);
      return false;
    }
  }
}
