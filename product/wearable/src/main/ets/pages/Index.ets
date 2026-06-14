// product/wearable/src/main/ets/pages/Index.ets
import {
  ArcSwiper,
  ArcSwiperController,
  ArcDotIndicator,
  ArcDirection
} from '@kit.ArkUI'
import WearScreenUtil from '../utils/WearScreenUtil'
import { WearNavPanelRound } from '../sub_pages/WearNavPanelRound'
import { WearNavPanelSquare } from '../sub_pages/WearNavPanelSquare'
import { WearRollWheel } from '../sub_pages/WearRollWheel'
import { WearBlessingMuyu } from '../sub_pages/WearBlessingMuyu'
import { WearTruthOrDare } from '../sub_pages/WearTruthOrDare'
import { WearRollDices } from '../sub_pages/WearRollDices'
import { WearFlipCoin } from '../sub_pages/WearFlipCoin'
import { WearRandomABCD } from '../sub_pages/WearRandomABCD'
import { WearDevineBaGua } from '../sub_pages/WearDevineBaGua'
import { WearRandomColors } from '../sub_pages/WearRandomColors'
import { AppLinkQR } from '../sub_pages/AppLinkQR'

// ════════════════════════════════════════
//  页面索引常量
// ════════════════════════════════════════
interface PageIndexMap {
  NAV: number
  ROLL_WHEEL: number
  MUYU: number
  TRUTH_DARE: number
  FLIP_COIN: number
  RANDOM_ABCD: number
  DEVINE_BAGUA: number
  RANDOM_COLORS: number
  APP_LINK_QR: number
}

const PAGE_INDEX: PageIndexMap = {
  NAV: 0,
  ROLL_WHEEL: 1,
  MUYU: 2,
  TRUTH_DARE: 3,
  FLIP_COIN: 4,
  RANDOM_ABCD:5,
  DEVINE_BAGUA: 6,
  RANDOM_COLORS: 7,
  APP_LINK_QR: 8,
}

// 指示器颜色（与圆形屏系统 ArcDotIndicator 保持一致）
const INDICATOR_SELECTED: number = 0xFF007AFF  // 应用主题蓝
const INDICATOR_NORMAL: number   = 0x66FFFFFF

/**
 * 手表端主页 — 圆/方屏双适配 + 自动隐藏导航点
 *
 * - 圆形屏：使用系统 ArcDotIndicator，onGestureSwipe 即时显示
 * - 方形屏：使用系统 DotIndicator，onGestureSwipe 即时显示
 * - 圆形屏每页外包圆形裁切，避免方形页面切换时突兀
 * - 首次加载：显示 1.5s 后隐藏
 * - 滑动/表冠：即时淡入，停止后 1.5s 淡出
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

  // 方形屏系统指示器
  private squareIndicator: DotIndicator = new DotIndicator()
    .color(INDICATOR_NORMAL)
    .selectedColor(INDICATOR_SELECTED)

  // 圆形屏系统指示器（maskColor 全透明 → 去除 ArcSwiper 环形阴影）
  private arcIndicator: ArcDotIndicator = new ArcDotIndicator()
    .arcDirection(ArcDirection.SIX_CLOCK_DIRECTION)
    .itemColor(INDICATOR_NORMAL)
    .selectedItemColor(INDICATOR_SELECTED)
    .maskColor(new LinearGradient([
      { color: '#00000000', offset: 0 },
      { color: '#00000000', offset: 1 },
    ]))

  aboutToAppear(): void {
    this.isRound = WearScreenUtil.isRoundScreen()
    this.scheduleHide(1500)
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

  // ════════════════════════════════════════
  //  导航回调
  // ════════════════════════════════════════
  private onNavigate = (targetIndex: number): void => {
    this.scheduleHide(1500)
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

  // ════════════════════════════════════════
  //  圆形屏布局：ArcSwiper + 系统 ArcDotIndicator
  //  每页外包圆形裁切，避免方形页面切换突兀
  // ════════════════════════════════════════
  @Builder
  buildRoundLayout() {
    Stack() {
      ArcSwiper(this.arcController) {
        this.buildRoundPages()
      }
      .width('100%')
      .height('100%')
      .index(this.currentIndex)
      .vertical(false)
      .duration(300)
      .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
      .effectMode(EdgeEffect.Spring)
      .disableSwipe(false)
      .indicator(this.showIndicator ? this.arcIndicator : false)
      .onGestureSwipe((index: number) => {
        this.showIndicator = true
        if (this.hideTimer) {
          clearTimeout(this.hideTimer)
        }
      })
      .onAnimationEnd(() => {
        this.scheduleHide(1500)
      })
      .onChange((index: number) => {
        if (index === this.currentIndex) {
          return  // 跳过重建触发的重复回调
        }
        this.currentIndex = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0x00000000)
  }

  // ════════════════════════════════════════
  //  方形屏布局：Swiper + 系统 DotIndicator
  // ════════════════════════════════════════
  @Builder
  buildSquareLayout() {
    Swiper(this.swiperController) {
      this.buildSquarePages()
    }
    .loop(false)
    .index(this.currentIndex)
    .itemSpace(0)
    .duration(300)
    .indicator(this.showIndicator ? this.squareIndicator : false)
    .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
      this.showIndicator = true
      if (this.hideTimer) {
        clearTimeout(this.hideTimer)
      }
    })
    .onAnimationEnd(() => {
      this.scheduleHide(1500)
    })
    .onChange((index: number) => {
      if (index === this.currentIndex) {
        return
      }
      this.currentIndex = index
    })
  }

  // ════════════════════════════════════════
  //  圆形屏页面：每页外包圆形裁切容器
  // ════════════════════════════════════════
  @Builder
  buildRoundPages() {
    // 导航面板（圆形屏 ArcList 版本）
    Stack() { WearNavPanelRound({ onNavigate: this.onNavigate }) }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // 幸运转盘
    Stack() { WearRollWheel() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // 祝福木鱼
    Stack() { WearBlessingMuyu() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // 真心话大冒险
    Stack() { WearTruthOrDare() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // 掷骰子
    // 丢硬币
    Stack() { WearFlipCoin() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // ABCD 选择
    Stack() { WearRandomABCD() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // 八卦占卜
    Stack() { WearDevineBaGua() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // 随机颜色
    Stack() { WearRandomColors() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)

    // 随易 App 二维码
    Stack() { AppLinkQR() }
      .width('100%')
      .height('100%')
      .borderRadius(WearScreenUtil.screenWidth / 2)
      .clip(true)
  }

  // ════════════════════════════════════════
  //  方形屏页面：不裁切
  // ════════════════════════════════════════
  @Builder
  buildSquarePages() {
    WearNavPanelSquare({ onNavigate: this.onNavigate })
    WearRollWheel()
    WearBlessingMuyu()
    WearTruthOrDare()
    WearFlipCoin()
    WearRandomABCD()
    WearDevineBaGua()
    WearRandomColors()
    AppLinkQR()
  }
}
