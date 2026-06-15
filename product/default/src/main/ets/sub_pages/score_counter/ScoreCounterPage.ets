import router from '@ohos.router';
import { display } from '@kit.ArkUI';
import { BreakpointSystem, BreakpointState } from '@ohos/system-utils';
import { VibratorManager } from '@ohos/system-utils';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct ScoreCounterPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  // Scores
  @State scoreA: number = 0
  @State scoreB: number = 0

  // Display scores (updated at flip midpoint for smooth transition)
  @State displayA: number = 0
  @State displayB: number = 0

  // Flip animation angles (X-axis rotation degrees)
  @State flipAngleA: number = 0
  @State flipAngleB: number = 0

  // Orientation
  @State isPortrait: boolean = false

  // Lead indicator
  @State leadVisibleA: boolean = false
  @State leadVisibleB: boolean = false

  // Breakpoint
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  private displayChangeCallback: Callback<number> | null = null
  private isFlippingA: boolean = false
  private isFlippingB: boolean = false

  // ==================== Lifecycle ====================

  aboutToAppear(): void {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
    this.detectOrientation()
    this.listenOrientation()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
    if (this.displayChangeCallback !== null) {
      display.off('change', this.displayChangeCallback)
    }
  }

  // ==================== Orientation ====================

  private detectOrientation(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync()
      this.isPortrait = displayInfo.height > displayInfo.width
    } catch (e) {
      this.isPortrait = false
    }
  }

  private listenOrientation(): void {
    try {
      this.displayChangeCallback = (id: number) => {
        this.detectOrientation()
      }
      display.on('change', this.displayChangeCallback)
    } catch (e) {
      // Orientation change not available
    }
  }

  // ==================== Score Logic ====================

  private addScore(team: string): void {
    if (team === 'A') {
      this.scoreA++
      this.flipScore('A')
    } else {
      this.scoreB++
      this.flipScore('B')
    }
    this.updateLeadIndicator()
    VibratorManager.vibrateTap()
  }

  private subtractScore(team: string): void {
    if (team === 'A') {
      if (this.scoreA <= 0) return
      this.scoreA--
      this.flipScore('A')
    } else {
      if (this.scoreB <= 0) return
      this.scoreB--
      this.flipScore('B')
    }
    this.updateLeadIndicator()
    VibratorManager.vibrateTap()
  }

  // ==================== Flip Animation ====================
  // Mechanical flip counter: rotate on X-axis with perspective.
  // Phase 1: old number rotates from 0° to -90° (flips away)
  // At midpoint: edge-on = invisible, swap displayed number, jump angle to 90°
  // Phase 2: new number rotates from 90° to 0° (flips in)

  private flipScore(team: string): void {
    const isA = team === 'A'
    if (isA && this.isFlippingA) return
    if (!isA && this.isFlippingB) return

    if (isA) {
      this.isFlippingA = true
    } else {
      this.isFlippingB = true
    }

    // Phase 1: flip out
    animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      if (isA) {
        this.flipAngleA = -90
      } else {
        this.flipAngleB = -90
      }
    })

    setTimeout(() => {
      // Midpoint: swap displayed number, jump angle (still edge-on)
      if (isA) {
        this.displayA = this.scoreA
        this.flipAngleA = 90
      } else {
        this.displayB = this.scoreB
        this.flipAngleB = 90
      }

      // Phase 2: flip in
      animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
        if (isA) {
          this.flipAngleA = 0
        } else {
          this.flipAngleB = 0
        }
      })

      setTimeout(() => {
        if (isA) {
          this.isFlippingA = false
        } else {
          this.isFlippingB = false
        }
      }, 130)
    }, 120)
  }

  // ==================== Lead Indicator ====================

  private updateLeadIndicator(): void {
    const newLeadA = this.scoreA > this.scoreB
    const newLeadB = this.scoreB > this.scoreA

    // Vibrate when lead changes
    if (newLeadA !== this.leadVisibleA || newLeadB !== this.leadVisibleB) {
      if (newLeadA || newLeadB) {
        VibratorManager.vibrateResult()
      }
      animateTo({ duration: 250, curve: Curve.EaseInOut }, () => {
        this.leadVisibleA = newLeadA
        this.leadVisibleB = newLeadB
      })
    }
  }

  // ==================== Reset ====================

  private showResetDialog(): void {
    AlertDialog.show({
      title: '重置计分',
      message: '确定要将双方分数归零吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '重置',
        action: () => {
          this.resetScores()
        }
      }
    })
  }

  private resetScores(): void {
    // Flip both teams to zero simultaneously
    animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      this.flipAngleA = -90
      this.flipAngleB = -90
    })

    setTimeout(() => {
      this.scoreA = 0
      this.scoreB = 0
      this.displayA = 0
      this.displayB = 0
      this.flipAngleA = 90
      this.flipAngleB = 90
      this.leadVisibleA = false
      this.leadVisibleB = false

      animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
        this.flipAngleA = 0
        this.flipAngleB = 0
      })
    }, 120)

    VibratorManager.vibrateTap()
  }

  // ==================== Responsive Helpers ====================

  private getScoreFontSize(): number {
    if (this.currentBreakpoint.value === 'lg') return 80
    if (this.currentBreakpoint.value === 'md') return 68
    return 56
  }

  private getScoreBoxHeight(): number {
    if (this.currentBreakpoint.value === 'lg') return 100
    if (this.currentBreakpoint.value === 'md') return 88
    return 76
  }

  private getButtonSize(): number {
    if (this.currentBreakpoint.value === 'lg') return 52
    if (this.currentBreakpoint.value === 'md') return 46
    return 40
  }

  private getCardPadding(): number {
    if (this.currentBreakpoint.value === 'lg') return 24
    if (this.currentBreakpoint.value === 'md') return 20
    return 16
  }

  // ==================== Builders ====================

  @Builder
  TeamPanel(team: string) {
    Column({ space: 4 }) {
      // Team name — Brand color when leading
      Text(team === 'A' ? 'A 队' : 'B 队')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor((team === 'A' && this.leadVisibleA) || (team === 'B' && this.leadVisibleB) ?
          $r("app.color.Brand") : $r("app.color.FontIcon_Fore1"))
        .animation({ duration: 250, curve: Curve.EaseInOut })

      // Score display with flip animation
      Stack() {
        Text(`${team === 'A' ? this.displayA : this.displayB}`)
          .fontSize(this.getScoreFontSize())
          .fontWeight(FontWeight.Bold)
          .fontColor($r("app.color.Brand"))
          .rotate({
            x: 1,
            angle: team === 'A' ? this.flipAngleA : this.flipAngleB,
            perspective: 400
          })
      }
      .width('100%')
      .height(this.getScoreBoxHeight())
      .alignContent(Alignment.Center)
      .clip(true)

      // +/- Buttons
      Row({ space: 12 }) {
        // -1 button
        Row() {
          Text('-1')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r("app.color.FontIcon_Fore1"))
        }
        .width(this.getButtonSize())
        .height(this.getButtonSize())
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor($r("app.color.Comp_Bg2"))
        .borderRadius(12)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        .gesture(
          LongPressGesture({ repeat: true, duration: 200 })
            .onAction(() => {
              this.subtractScore(team)
            })
        )
        .onClick(() => {
          this.subtractScore(team)
        })

        // +1 button
        Row() {
          Text('+1')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r("app.color.control_fc_1"))
        }
        .width(this.getButtonSize())
        .height(this.getButtonSize())
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor($r("app.color.control_bgc_1"))
        .borderRadius(12)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        .gesture(
          LongPressGesture({ repeat: true, duration: 200 })
            .onAction(() => {
              this.addScore(team)
            })
        )
        .onClick(() => {
          this.addScore(team)
        })
      }

      // Lead indicator
      Text('领先')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.Brand"))
        .opacity((team === 'A' && this.leadVisibleA) || (team === 'B' && this.leadVisibleB) ? 1 : 0)
        .animation({ duration: 250, curve: Curve.EaseInOut })
        .margin({ top: 4 })
        .height(20)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(this.getCardPadding())
  }

  @Builder
  HeaderBar() {
    GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
      GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
        Row() {
          Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
        }
        .onClick(() => {
          router.back({ url: 'pages/IndexPage/Index' })
        })
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        .width('100%')
        .height($r("app.float.header_height"))
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 12 })
      }

      GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
        Row() {
          Text($r("app.string.page_score_counter")).fontColor($r("app.color.FontIcon_Fore1"))
        }
        .width('100%')
        .height($r("app.float.header_height"))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }

      GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
        Row() {
          Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingPage/SettingPage', params: new Params('no') })
        })
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        .width('100%')
        .height($r("app.float.header_height"))
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .padding({ right: 12 })
      }
    }
    .width('100%')
    .backgroundColor($r("app.color.Comp_Bg1"))
    .zIndex(10)
    .margin({ top: $r("app.float.header_margin") })
    .position({ top: $r("app.float.header_margin") })
    .padding({ top: this.statusBarHeight })
  }

  @Builder
  ScoreDiffBadge() {
    Row() {
      Text(`${Math.abs(this.scoreA - this.scoreB)}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.FontIcon_Fore2"))
    }
    .height(28)
    .padding({ left: 10, right: 10 })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg3"))
    .borderRadius(14)
    .opacity(this.scoreA !== this.scoreB ? 1 : 0)
    .animation({ duration: 250, curve: Curve.EaseInOut })
  }

  @Builder
  ScoreBoard() {
    // Unified card containing both teams
    Column() {
      if (this.isPortrait) {
        // Portrait: vertical layout (simulates rotated landscape)
        Column({ space: 0 }) {
          this.TeamPanel('A')
          Stack() {
            Divider()
              .color($r("app.color.border_primary"))
              .strokeWidth(1)
            this.ScoreDiffBadge()
          }
          .width('100%')
          .height(28)
          .alignContent(Alignment.Center)

          this.TeamPanel('B')
        }
        .width('100%')
      } else {
        // Landscape / square: horizontal layout
        Row({ space: 0 }) {
          this.TeamPanel('A')
          Stack() {
            Divider()
              .vertical(true)
              .color($r("app.color.border_primary"))
              .strokeWidth(1)
              .height('60%')
            this.ScoreDiffBadge()
          }
          .height('100%')
          .alignContent(Alignment.Center)

          this.TeamPanel('B')
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor($r("app.color.Comp_Bg1"))
    .borderRadius(24)
    .clip(true)
  }

  @Builder
  ResetButton() {
    Row() {
      Text('🔄 重置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.error"))
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .borderRadius(16)
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
    .onClick(() => {
      this.showResetDialog()
    })
    .margin({ top: 16 })
  }

  // ==================== Build ====================

  build() {
    Column() {
      // Header
      this.HeaderBar()

      // Content area
      Column() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: 12 }) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            Column() {
              this.ScoreBoard()
              this.ResetButton()
            }
            .width('100%')
          }
        }
        .margin(24)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default ScoreCounterPage
