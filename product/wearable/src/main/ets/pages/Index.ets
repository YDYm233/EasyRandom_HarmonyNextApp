// product/wearable/src/main/ets/pages/Index.ets
import {
  ArcSwiper,
  ArcSwiperController
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

// ══════════════════════════════════════════════════
//  页面索引常量
// ══════════════════════════════════════════════════
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

const TOTAL_PAGES: number = 9

/**
 * 手表端主页 — 圆/方屏双适配 + 自动隐藏导航点
 *
 * 指示器用自定义圆点实现（非内置 ArcDotIndicator / DotIndicator），
 * 通过 opacity 动画控制显隐，响应 @State showIndicator 变化。
 *
 * - 首次加载：显示 3 秒后淡出
 * - 滑动/表冠转动：立即淡入，停止后 2 秒淡出
 */
@Entry
@Component
struct Index {
  @State isRound: boolean = false
  @State currentIndex: number = PAGE_INDEX.ROLL_WHEEL
  @State showIndicator: boolean = true
  private hideTimer: number = 0

  private arcController: ArcSwiperController = new ArcSwiperController()
  private swiperController: SwiperController = new SwiperController()

  aboutToAppear(): void {
    this.isRound = WearScreenUtil.isRoundScreen()
    this.scheduleHide(3000)
  }

  aboutToDisappear(): void {
    if (this.hideTimer) {
      clearTimeout(this.hideTimer)
    }
  }

  private scheduleHide(delay: number = 2000): void {
    if (this.hideTimer) {
      clearTimeout(this.hideTimer)
    }
    this.showIndicator = true
    this.hideTimer = setTimeout(() => {
      this.showIndicator = false
    }, delay) as number
  }

  build() {
    if (this.isRound) {
      this.buildRoundLayout()
    } else {
      this.buildSquareLayout()
    }
  }

  // ═══════════════════════════════════════════
  //  导航回调
  // ═══════════════════════════════════════════
  private onNavigate = (targetIndex: number): void => {
    this.scheduleHide(2000)
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
      this.swiperController.changeIndex(targetIndex, true)
    }
  }

  // ═══════════════════════════════════════════
  //  自定义指示器（9 个圆点）
  //  opacity 绑定 @State showIndicator，带动画
  // ═══════════════════════════════════════════
  @Builder
  buildCustomIndicator() {
    Row({ space: 4 }) {
      ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8], (i: number) => {
        Circle()
          .width(6)
          .height(6)
          .fill(i === this.currentIndex ? 0xFFD4A017 : 0x33FFFFFF)
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .opacity(this.showIndicator ? 1 : 0)
    .animation({ duration: 400, curve: Curve.EaseOut })
  }

  // ═══════════════════════════════════════════
  //  圆形屏布局：ArcSwiper + 自定义指示器
  // ═══════════════════════════════════════════
  @Builder
  buildRoundLayout() {
    Stack() {
      ArcSwiper(this.arcController) {
        this.buildAllPages()
      }
      .width('100%')
      .height('100%')
      .index(PAGE_INDEX.ROLL_WHEEL)
      .vertical(false)
      .duration(300)
      .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
      .effectMode(EdgeEffect.Spring)
      .disableSwipe(false)
      .onChange((index: number) => {
        this.currentIndex = index
        this.scheduleHide(2000)
      })

      // 自定义指示器：6 点钟方向
      Stack() {
        this.buildCustomIndicator()
      }
      .position({ x: '50%', y: '89%' })
      .translate({ x: '-50%', y: 0 })
    }
  }

  // ═══════════════════════════════════════════
  //  方形屏布局：Swiper + 自定义指示器
  // ═══════════════════════════════════════════
  @Builder
  buildSquareLayout() {
    Stack() {
      Swiper(this.swiperController) {
        this.buildAllPages()
      }
      .loop(false)
      .index(PAGE_INDEX.ROLL_WHEEL)
      .itemSpace(0)
      .duration(300)
      .onAnimationStart(() => {
        // 滑动开始：立即显示
        this.showIndicator = true
        if (this.hideTimer) clearTimeout(this.hideTimer)
      })
      .onAnimationEnd(() => {
        // 滑动结束：2 秒后隐藏
        this.scheduleHide(2000)
      })
      .onChange((index: number) => {
        this.currentIndex = index
      })

      // 自定义指示器：底部
      Stack() {
        this.buildCustomIndicator()
      }
      .position({ x: '50%', y: '92%' })
      .translate({ x: '-50%', y: 0 })
    }
  }

  // ═══════════════════════════════════════════
  //  共用的 9 个页面
  // ═══════════════════════════════════════════
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
