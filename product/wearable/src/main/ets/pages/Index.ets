import { ArcSwiper, ArcDotIndicator, ArcSwiperController } from '@kit.ArkUI';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 手表端主页 — 圆/方屏双适配
 *
 * 四层适配模型中「第 2 层：容器层」的唯一分叉点。
 * 圆形屏 → ArcSwiper（弧形轮播 + 表冠交互）
 * 方形屏 → Swiper（标准线性轮播）
 *
 * API < 18 的设备默认走方形屏路线。
 */
@Entry
@Component
struct Index {
  @State isRound: boolean = false;
  // ArcSwiper 控制器（仅圆形屏使用）
  private arcController: ArcSwiperController = new ArcSwiperController();

  aboutToAppear(): void {
    this.isRound = WearScreenUtil.isRoundScreen();
  }

  build() {
    if (this.isRound) {
      this.buildRoundLayout();
    } else {
      this.buildSquareLayout();
    }
  }

  // ═══════════════════════════════════════════
  //  圆形屏布局（ArcSwiper）
  // ═══════════════════════════════════════════
  @Builder
  buildRoundLayout() {
    ArcSwiper(this.arcController) {
      this.buildAllPages();
    }
    .width('100%')
    .height('100%')
    .indicator(
      new ArcDotIndicator()
        .itemColor(0x66FFFFFF)            // 未激活色（半透白）
        .selectedItemColor(0xFFD4A017)    // 激活色（金色）
    )
    .vertical(false)                      // 横向排列
    .duration(400)
    .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
    .effectMode(EdgeEffect.Spring)
    .disableSwipe(false)
  }

  // ═══════════════════════════════════════════
  //  方形屏布局（标准 Swiper）
  // ═══════════════════════════════════════════
  @Builder
  buildSquareLayout() {
    Swiper() {
      this.buildAllPages();
    }
    .loop(true)
    .indicator(
      new DotIndicator()
        .color(0x33FFFFFF)
        .selectedColor(0xFFD4A017)
    )
    .itemSpace(0)
    .duration(400)
  }

  // ═══════════════════════════════════════════
  //  共用的 7 个功能页面
  // ═══════════════════════════════════════════
  @Builder
  buildAllPages() {

  }
}
