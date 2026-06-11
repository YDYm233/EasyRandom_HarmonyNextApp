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

// ══════════════════════════════════════════
//  页面索引常量
// ══════════════════════════════════════════
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

// 指示器颜色（与圆形屏系统 ArcDotIndicator 保持一致）
const INDICATOR_SELECTED: number = 0xFFD4A017
const INDICATOR_NORMAL: number   = 0x66FFFFFF

/**
 * 手表端主页 — 圆/方屏双适配 + 自动隐藏导航点
 *
 * - 圆形屏：使用系统 ArcDotIndicator，6 点钟方向
 * - 方形屏：自定义圆点指示器，颜色/动效对齐系统
 * - 首次加载：显示 3 秒后淡出
 * - 滑动/表冠：立即淡入，停止后 2 秒淡出
 */
@Entry
@Component
struct Index {
  @State isRound: boolean = false
  @State currentIndex: number = PAGE_INDEX.ROLL_WHEEL
  @State showIndicator: boolean = true
  private hideTimer: number = 0

  // 方形屏指示器 spring 动效
  @State private dotScale: number = 1.0
  private springLock: boolean = false

  private arcController: ArcSwiperController = new ArcSwiperController()
  private swiperController: SwiperController = new SwiperController()

  // 圆形屏系统指示器
  private arcIndicator: ArcDotIndicator = new ArcDotIndicator()
    .arcDirection(ArcDirection.SIX_CLOCK_DIRECTION)
    .itemColor(INDICATOR_NORMAL)
    .selectedItemColor(INDICATOR_SELECTED)

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

  // 方形屏指示器：触发 spring 动效（先跳到峰值，再 animateTo 回弹）
  private triggerSpring(): void {
    if (this.isRound || this.springLock) {
      return
    }
    this.springLock = true
    // 立即跳到峰值（无动画）
    this.dotScale = 1.8
    // 下一帧开始 spring 回弹到 1.0
    animateTo({
      duration: 500,
      curve: Curve.Spring,
    }, () => {
      this.dotScale = 1.0
      this.springLock = false
    })
  }

  build() {
    if (this.isRound) {
      this.buildRoundLayout()
    } else {
      this.buildSquareLayout()
    }
  }

  // ══════════════════════════════════════════
  //  导航回调
  // ══════════════════════════════════════════
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
      // changeIndex 会触发 onChange → triggerSpring()
    }
  }

  // ══════════════════════════════════════════
  //  圆形屏布局：ArcSwiper + 系统 ArcDotIndicator
  // ══════════════════════════════════════════
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
      .indicator(this.arcIndicator)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
  }

  // ══════════════════════════════════════════
  //  方形屏布局：Swiper + 自定义指示器（spring 动效）
  // ══════════════════════════════════════════
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
      .indicator(false)
      .onAnimationStart(() => {
        this.showIndicator = true
        if (this.hideTimer) clearTimeout(this.hideTimer)
      })
      .onAnimationEnd(() => {
        this.scheduleHide(2000)
      })
      .onChange((index: number) => {
        this.currentIndex = index
        this.triggerSpring()
      })

      // 自定义指示器：颜色/动效对齐圆形屏系统指示器
      Row({ space: 5 }) {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8], (i: number) => {
          Circle()
            .width(i === this.currentIndex ? 7 : 5)
            .height(i === this.currentIndex ? 7 : 5)
            .fill(i === this.currentIndex ? INDICATOR_SELECTED : INDICATOR_NORMAL)
            .scale({
              x: i === this.currentIndex ? this.dotScale : 1.0,
              y: i === this.currentIndex ? this.dotScale : 1.0,
            })
        }, (i: number) => i.toString())
      }
      .opacity(this.showIndicator ? 1 : 0)
      .animation({ duration: 400, curve: Curve.EaseOut })
      .alignSelf(ItemAlign.End)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })
    }
  }

  // ══════════════════════════════════════════
  //  共用的 9 个页面
  // ══════════════════════════════════════════
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
