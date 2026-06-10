// product/wearable/src/main/ets/pages/Index.ets
import {
  ArcSwiper,
  ArcSwiperController,
  ArcDotIndicator,
  ArcDirection
} from '@kit.ArkUI'
import WearScreenUtil from '../utils/WearScreenUtil'
import { WearNavPanel } from '../sub_pages/WearNavPanel'
import { WearRollWheel } from '../sub_pages/WearRollWheel'
import { WearBlessingMuyu } from '../sub_pages/WearBlessingMuyu'
import { WearTruthOrDare } from '../sub_pages/WearTruthOrDare'
import { WearRollDices } from '../sub_pages/WearRollDices'
import { WearFlipCoin } from '../sub_pages/WearFlipCoin'
import { WearRandomABCD } from '../sub_pages/WearRandomABCD'
import { WearDevineBaGua } from '../sub_pages/WearDevineBaGua'
import { WearRandomColors } from '../sub_pages/WearRandomColors'

// ═══════════════════════════════════════════════════
//  页面索引常量（供负一屏导航 + buildAllPages 引用）
// ═══════════════════════════════════════════════════
interface PageIndexMap {
  NAV: number
  ROLL_WHEEL: number
  MUYU: number
  TRUTH_DARE: number
  ROLL_DICES: number
  FLIP_COIN: number
  RANDOM_ABCD: number
  DEVINE_BAGUA: number
  RANDOM_COLORS: number
}

const PAGE_INDEX: PageIndexMap = {
  NAV: 0,
  ROLL_WHEEL: 1,
  MUYU: 2,
  TRUTH_DARE: 3,
  ROLL_DICES: 4,
  FLIP_COIN: 5,
  RANDOM_ABCD: 6,
  DEVINE_BAGUA: 7,
  RANDOM_COLORS: 8,
}

/**
 * 手表端主页 — 圆/方屏双适配 + 负一屏导航
 *
 * 四层适配模型中「第 2 层：容器层」的唯一分叉点。
 * 圆形屏 → ArcSwiper（弧形轮播 + 表冠交互）
 * 方形屏 → Swiper（标准线性轮播）
 *
 * 页面排列：[0]负一屏 ← [1]幸运转盘★(默认) → [2]木鱼 → [3]真心话 → ...
 * API < 18 的设备默认走方形屏路线。
 */
@Entry
@Component
struct Index {
  @State isRound: boolean = false
  @State currentIndex: number = PAGE_INDEX.ROLL_WHEEL

  // ArcSwiper 控制器（仅圆形屏使用）
  private arcController: ArcSwiperController = new ArcSwiperController()
  // Swiper 控制器（仅方形屏使用，用于负一屏导航跳转）
  private swiperController: SwiperController = new SwiperController()

  // ═══════════ 圆形屏 ArcDotIndicator ═══════════
  private arcIndicator: ArcDotIndicator = new ArcDotIndicator()
    .arcDirection(ArcDirection.SIX_CLOCK_DIRECTION)
    .itemColor(0x66FFFFFF)
    .selectedItemColor(0xFFD4A017)

  aboutToAppear(): void {
    this.isRound = WearScreenUtil.isRoundScreen()
  }

  build() {
    if (this.isRound) {
      this.buildRoundLayout()
    } else {
      this.buildSquareLayout()
    }
  }

  // ═══════════════════════════════════════════════
  //  导航回调（传给 WearNavPanel，供其跳转页面）
  //  ArcSwiperController 无 changeIndex，用 showNext/showPrevious 模拟
  // ═══════════════════════════════════════════════
  private onNavigate = (targetIndex: number): void => {
    if (this.isRound) {
      const diff = targetIndex - this.currentIndex
      if (diff > 0) {
        for (let i = 0; i < diff; i++) {
          this.arcController.showNext()
        }
      } else if (diff < 0) {
        for (let i = 0; i < -diff; i++) {
          this.arcController.showPrevious()
        }
      }
      this.currentIndex = targetIndex
    } else {
      this.swiperController.changeIndex(targetIndex)
    }
  }

  // ═══════════════════════════════════════════════
  //  圆形屏布局（ArcSwiper）
  // ═══════════════════════════════════════════════
  @Builder
  buildRoundLayout() {
    ArcSwiper(this.arcController) {
      this.buildAllPages()
    }
    .width('100%')
    .height('100%')
    .index(PAGE_INDEX.ROLL_WHEEL)
    .indicator(this.arcIndicator)
    .vertical(false)
    .duration(300)
    .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
    .effectMode(EdgeEffect.Spring)
    .disableSwipe(false)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }

  // ═══════════════════════════════════════════════
  //  方形屏布局（标准 Swiper）
  // ═══════════════════════════════════════════════
  @Builder
  buildSquareLayout() {
    Swiper(this.swiperController) {
      this.buildAllPages()
    }
    .loop(false)
    .index(PAGE_INDEX.ROLL_WHEEL)
    .indicator(
      new DotIndicator()
        .color(0x33FFFFFF)
        .selectedColor(0xFFD4A017)
    )
    .itemSpace(0)
    .duration(300)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }

  // ═══════════════════════════════════════════════
  //  共用的 9 个页面（按 Swiper 从左到右排列）
  // ═══════════════════════════════════════════════
  @Builder
  buildAllPages() {
    WearNavPanel({ onNavigate: this.onNavigate })
    WearRollWheel()
    WearBlessingMuyu()
    WearTruthOrDare()
    WearRollDices()
    WearFlipCoin()
    WearRandomABCD()
    WearDevineBaGua()
    WearRandomColors()
  }
}
