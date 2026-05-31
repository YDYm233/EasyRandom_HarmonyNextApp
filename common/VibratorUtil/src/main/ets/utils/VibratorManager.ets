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
   * 按指定时长触发振动
   * @param duration 振动时长，单位ms
   * @param usage 振动场景，默认TOUCH
   */
  static vibrateTime(duration: number, usage: VibrationUsage = VibrationUsage.TOUCH): void {
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
    if (!durations || durations.length === 0) {
      hilog.warn(DOMAIN, TAG, 'vibratePattern: durations is empty, skipped');
      return;
    }
    try {
      vibrator.startVibration(
        { type: 'time', duration: durations[0] },
        { usage, parameters: { pattern: durations, count } },
        VibratorManager.createCallback('vibratePattern')
      );
    } catch (err) {
      VibratorManager.logError('vibratePattern', err as Error);
    }
  }

  /** 短振动 ~100ms，常用于按钮点击反馈 */
  static vibrateShort(): void {
    VibratorManager.vibrateTime(100, VibrationUsage.TOUCH);
  }

  /** 中等振动 ~300ms，常用于操作确认 */
  static vibrateMedium(): void {
    VibratorManager.vibrateTime(300, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 长振动 ~600ms，常用于强调提醒 */
  static vibrateLong(): void {
    VibratorManager.vibrateTime(600, VibrationUsage.NOTIFICATION);
  }

  /** 成功反馈 — 两次短振 */
  static vibrateSuccess(): void {
    VibratorManager.vibratePreset(HapticEffect.SOFT, 2, 100, VibrationUsage.TOUCH);
  }

  /** 错误反馈 — 三次振动 */
  static vibrateError(): void {
    VibratorManager.vibratePreset(HapticEffect.SHARP, 3, 100, VibrationUsage.PHYSICAL_FEEDBACK);
  }

  /** 警告反馈 — 强振动 */
  static vibrateWarning(): void {
    VibratorManager.vibratePreset(HapticEffect.HARD, 1, 100, VibrationUsage.ALARM);
  }

  /** 轻触反馈 — 预设轻柔效果 */
  static vibrateTap(): void {
    VibratorManager.vibratePreset(HapticEffect.SOFT, 1, 30, VibrationUsage.TOUCH);
  }

  /** 按键反馈 — 预设尖锐效果 */
  static vibrateKeyPress(): void {
    VibratorManager.vibratePreset(HapticEffect.SHARP, 1, 50, VibrationUsage.TOUCH);
  }

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
