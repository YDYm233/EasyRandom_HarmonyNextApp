import display from '@ohos.display';

/**
 * 手表屏幕适配工具类
 *
 * 四层适配模型中的「第 4 层：工具层」
 * 封装屏幕形状检测、尺寸分级、设计 Token，供所有 Wear 组件使用。
 *
 * 使用方式：
 *   WearScreenUtil.isRoundScreen()  — 判断圆/方屏
 *   WearScreenUtil.mainImageWidth   — 获取自适应宽度 Token
 *   WearScreenUtil.scaledSize(200)  — Canvas 精确缩放
 *
 * ⚠️ 需配合 wearable 模块 compatibleSdkVersion ≥ 5.0.2(18)
 */
export default class WearScreenUtil {
  // ==================== 缓存字段 ====================

  private static _screenWidth: number = 0;
  private static _screenHeight: number = 0;
  private static _isRound: boolean | null = null;
  private static _screenSize: string | null = null;
  private static _shapeDetected: boolean = false;

  // ==================== 形状检测 ====================

  /**
   * 是否为圆形屏
   * 基于 display.ScreenShape 检测（API 18+）
   * 低于 API 18 或检测失败 → 默认方形屏
   */
  static isRoundScreen(): boolean {
    if (!WearScreenUtil._shapeDetected) {
      WearScreenUtil._detectShape();
    }
    return WearScreenUtil._isRound === true;
  }

  /** 是否为方形屏（isRoundScreen 的反值，方便条件判断） */
  static isSquareScreen(): boolean {
    return !WearScreenUtil.isRoundScreen();
  }

  private static _detectShape(): void {
    WearScreenUtil._shapeDetected = true;
    try {
      const d = display.getDefaultDisplaySync();
      // ScreenShape.ROUND = 1, ScreenShape.RECTANGLE = 0
      const shape = d.screenShape;
      if (shape === 1) {
        WearScreenUtil._isRound = true;
      } else {
        WearScreenUtil._isRound = false;
      }
    } catch (e) {
      // 低版本 API 或获取失败 → 默认方形
      WearScreenUtil._isRound = false;
    }
  }

  // ==================== 屏幕尺寸 ====================

  /** 懒加载初始化屏幕尺寸（宽度+高度一起设，避免重复获取） */
  private static _initDimensions(): void {
    if (WearScreenUtil._screenWidth === 0 && WearScreenUtil._screenHeight === 0) {
      try {
        const d = display.getDefaultDisplaySync();
        WearScreenUtil._screenWidth = px2vp(d.width);
        WearScreenUtil._screenHeight = px2vp(d.height);
      } catch (e) {
        // 兜底：使用常见手表分辨率
        WearScreenUtil._screenWidth = 466;
        WearScreenUtil._screenHeight = 466;
      }
    }
  }

  /** 获取屏幕宽度 (vp) */
  static get screenWidth(): number {
    WearScreenUtil._initDimensions();
    return WearScreenUtil._screenWidth;
  }

  /** 获取屏幕高度 (vp) */
  static get screenHeight(): number {
    WearScreenUtil._initDimensions();
    return WearScreenUtil._screenHeight;
  }

  // ==================== 尺寸分级 ====================

  /**
   * 屏幕尺寸分级
   * small:  < 340 vp（如 Watch D 320×320）
   * standard: 340-460 vp（如 Watch GT 4 466×466）
   * large:  > 460 vp（未来大屏手表）
   */
  static get screenSize(): string {
    if (WearScreenUtil._screenSize === null) {
      const w = WearScreenUtil.screenWidth; // 触发 _initDimensions
      if (w < 340) {
        WearScreenUtil._screenSize = 'small';
      } else if (w > 460) {
        WearScreenUtil._screenSize = 'large';
      } else {
        WearScreenUtil._screenSize = 'standard';
      }
    }
    return WearScreenUtil._screenSize;
  }

  // ==================== 设计 Token ====================

  /** 安全边距 (vp) — 圆形屏更大（需避开弧形裁切区域） */
  static get safePadding(): number {
    const screenSize = WearScreenUtil.screenSize;
    if (WearScreenUtil.isRoundScreen()) {
      if (screenSize === 'small') return 18;
      if (screenSize === 'large') return 28;   // 暂无此设备，预留
      return 24;  // standard
    }
    if (screenSize === 'small') return 8;
    if (screenSize === 'large') return 16;      // 暂无此设备，预留
    return 12;  // standard
  }

  /** 内容区宽度占比 — 圆形屏更窄（内接正方形） */
  static get contentWidthRatio(): string {
    const screenSize = WearScreenUtil.screenSize;
    if (WearScreenUtil.isRoundScreen()) {
      if (screenSize === 'small') return '65%';
      if (screenSize === 'large') return '75%';   // 暂无此设备，预留
      return '70%';  // standard
    }
    if (screenSize === 'small') return '88%';
    if (screenSize === 'large') return '92%';      // 暂无此设备，预留
    return '90%';  // standard
  }

  /** 主图/主元素宽度占比 */
  static get mainImageWidth(): string {
    const screenSize = WearScreenUtil.screenSize;
    if (WearScreenUtil.isRoundScreen()) {
      if (screenSize === 'small') return '48%';
      if (screenSize === 'large') return '60%';   // 暂无此设备，预留
      return '55%';  // standard
    }
    if (screenSize === 'small') return '62%';
    if (screenSize === 'large') return '75%';      // 暂无此设备，预留
    return '70%';  // standard
  }

  /** 结果字号 (fp) */
  static get resultFontSize(): number {
    const screenSize = WearScreenUtil.screenSize;
    if (screenSize === 'small') return 40;
    if (screenSize === 'large') return 56;   // 暂无此设备，预留
    return 48;  // standard
  }

  /** 辅助字号 (fp) */
  static get subFontSize(): number {
    const screenSize = WearScreenUtil.screenSize;
    if (screenSize === 'small') return 12;
    if (screenSize === 'large') return 16;   // 暂无此设备，预留
    return 14;  // standard
  }

  /** 按钮字号 (fp) */
  static get buttonFontSize(): number {
    const screenSize = WearScreenUtil.screenSize;
    if (screenSize === 'small') return 14;
    if (screenSize === 'large') return 18;   // 暂无此设备，预留
    return 16;  // standard
  }

  /** 列表项间距 (vp) */
  static get listItemSpace(): number {
    const screenSize = WearScreenUtil.screenSize;
    if (WearScreenUtil.isRoundScreen()) {
      if (screenSize === 'small') return 12;
      if (screenSize === 'large') return 20;   // 暂无此设备，预留
      return 16;  // standard
    }
    if (screenSize === 'small') return 8;
    if (screenSize === 'large') return 14;      // 暂无此设备，预留
    return 12;  // standard
  }

  /** 最小触摸区域 (vp) — 手表平台强制 48vp，所有屏幕统一 */
  static get minTouchSize(): number {
    return 48;
  }

  // ==================== 缩放工具 ====================

  /**
   * 按屏幕尺寸计算比例值
   * 用法：WearScreenUtil.scaledSize(200) — 在 standard 屏返回 200vp
   *       在 small 屏自动缩小，在 large 屏自动放大
   *
   * ⚠️ 设计说明：
   * - 基准 466vp 取自 Watch GT 4（圆形 standard 屏），对圆形屏更友好
   * - 方形小屏（320×320）下比例 ~0.687，受 70% 下限保护
   * - 该函数仅用于 Canvas 等需要精确 vp 值的场景（如转盘绘制）
   * - 一般布局尺寸优先使用百分比 Token（mainImageWidth 等），不依赖此函数
   */
  static scaledSize(standardValue: number): number {
    const scale = WearScreenUtil.screenWidth / 466; // 以 466vp（Watch GT 4 圆形屏）为基准
    return Math.max(standardValue * scale, standardValue * 0.7); // 最小缩到 70%
  }
}
