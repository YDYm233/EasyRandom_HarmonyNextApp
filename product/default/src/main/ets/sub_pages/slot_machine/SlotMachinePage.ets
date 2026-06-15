import router from '@ohos.router';
import { BreakpointState, BreakpointSystem } from '@ohos/system-utils';
import { VibratorManager, VibrationUsage } from '@ohos/system-utils';
import { curves } from '@kit.ArkUI';

class Params {
  type: string
  constructor(tuple: string) { this.type = tuple }
}

const ICONS: string[] = ['🍒', '⭐', '🔔', '🍀', '💎', '7️⃣']
const ICON_COUNT: number = ICONS.length
const WEIGHT_JACKPOT: number = 0.03
const WEIGHT_TWO: number = 0.15
const VISIBLE_ROWS: number = 3
const ICON_HEIGHT: number = 60

@Entry
@Component
struct SlotMachinePage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State reelOffsets: number[] = [0, 0, 0]
  @State reelStrips: number[][] = [
    [0, 1, 2, 3, 4, 5],
    [0, 1, 2, 3, 4, 5],
    [0, 1, 2, 3, 4, 5]
  ]
  @State isSpinning: boolean = false
  @State resultText: string = ''
  @State comboCount: number = 0
  @State showResult: boolean = false
  @State resultProgress: number = 0
  @State stoppedCount: number = 0
  @State triggerSwitch: number = 0
  @State winIndex: number = -1
  private timers: number[] = []
  private finalIcons: number[] = [0, 0, 0]

  aboutToAppear(): void {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
    this.clearAllTimers()
  }

  private clearAllTimers(): void {
    this.timers.forEach((t: number) => clearTimeout(t))
    this.timers = []
  }

  getIconHeight(): number {
    return this.currentBreakpoint.value === 'lg' ? 72 :
           this.currentBreakpoint.value === 'md' ? 66 : ICON_HEIGHT
  }

  getReelWindowHeight(): number {
    return this.getIconHeight() * VISIBLE_ROWS
  }

  private buildReelStrip(finalIcon: number): number[] {
    const extraCycles = 3
    const totalIcons = extraCycles * ICON_COUNT + ICON_COUNT
    const strip: number[] = []
    for (let i = 0; i < totalIcons; i++) {
      strip.push(i % ICON_COUNT)
    }
    const finalPos = totalIcons - VISIBLE_ROWS + 1
    strip[finalPos] = finalIcon
    return strip
  }

  startSpin(): void {
    if (this.isSpinning) return
    this.isSpinning = true
    this.showResult = false
    this.resultText = ''
    this.resultProgress = 0
    this.stoppedCount = 0
    this.winIndex = -1
    this.triggerSwitch++

    this.finalIcons = this.determineResult()

    this.reelStrips = [
      this.buildReelStrip(this.finalIcons[0]),
      this.buildReelStrip(this.finalIcons[1]),
      this.buildReelStrip(this.finalIcons[2])
    ]
    this.reelOffsets = [0, 0, 0]

    for (let i = 0; i < 3; i++) {
      this.spinReel(i)
    }
  }

  private spinReel(reelIndex: number): void {
    const delay = reelIndex * 400
    this.timers.push(setTimeout(() => {
      const iconH = this.getIconHeight()
      const strip = this.reelStrips[reelIndex]
      const targetOffset = (strip.length - VISIBLE_ROWS) * iconH

      animateTo({
        duration: 2000 + reelIndex * 800,
        curve: curves.cubicBezierCurve(0.15, 0.0, 0.05, 1.0),
        delay: 0,
        onFinish: () => {
          const fi = this.finalIcons[reelIndex]
          this.reelStrips[reelIndex] = [
            (fi - 1 + ICON_COUNT) % ICON_COUNT,
            fi,
            (fi + 1) % ICON_COUNT
          ]
          this.reelStrips = [...this.reelStrips]
          this.reelOffsets[reelIndex] = 0
          this.reelOffsets = [...this.reelOffsets]
          this.onReelStopped(reelIndex)
        }
      }, () => {
        this.reelOffsets[reelIndex] = targetOffset
        this.reelOffsets = [...this.reelOffsets]
      })
    }, delay) as number)
  }

  private onReelStopped(reelIndex: number): void {
    this.stoppedCount++
    this.resultProgress = this.stoppedCount
    VibratorManager.vibrateTime(30, VibrationUsage.TOUCH)
    if (this.stoppedCount >= 3) {
      this.isSpinning = false
      this.triggerSwitch++
      this.judgeResult()
    }
  }

  private determineResult(): number[] {
    const r = Math.random()
    if (r < WEIGHT_JACKPOT) {
      const icon = Math.floor(Math.random() * ICON_COUNT)
      return [icon, icon, icon]
    } else if (r < WEIGHT_JACKPOT + WEIGHT_TWO) {
      const icon = Math.floor(Math.random() * ICON_COUNT)
      const other = (icon + Math.floor(Math.random() * (ICON_COUNT - 1)) + 1) % ICON_COUNT
      return [icon, icon, other]
    } else {
      const a = Math.floor(Math.random() * ICON_COUNT)
      let b = Math.floor(Math.random() * ICON_COUNT)
      while (b === a) b = Math.floor(Math.random() * ICON_COUNT)
      let c = Math.floor(Math.random() * ICON_COUNT)
      while (c === a || c === b) c = Math.floor(Math.random() * ICON_COUNT)
      return [a, b, c]
    }
  }

  private judgeResult(): void {
    const a = this.finalIcons[0]
    const b = this.finalIcons[1]
    const c = this.finalIcons[2]
    if (a === b && b === c) {
      this.resultText = `🎉 三连中奖！${ICONS[a]} × 3`
      this.comboCount++
      this.winIndex = -2
      VibratorManager.vibrateTime(500, VibrationUsage.TOUCH)
    } else if (a === b || b === c || a === c) {
      this.resultText = '🤏 差一点！'
      if (a === b) this.winIndex = 0
      else if (b === c) this.winIndex = 1
      else this.winIndex = 2
      VibratorManager.vibrateTime(100, VibrationUsage.TOUCH)
    } else {
      this.resultText = '😅 再来一次！'
      this.comboCount = 0
      this.winIndex = -1
    }
    this.showResult = true
  }

  @Builder
  ReelView(index: number) {
    Stack() {
      Column() {
        ForEach(this.reelStrips[index], (iconIdx: number, pos: number) => {
          Row() {
            Text(ICONS[iconIdx])
              .fontSize(this.currentBreakpoint.value === 'lg' ? 42 :
                        this.currentBreakpoint.value === 'md' ? 38 : 34)
          }
          .width('100%')
          .height(this.getIconHeight())
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }, (iconIdx: number, pos: number) => `${index}_${pos}_${iconIdx}`)
      }
      .translate({ y: -this.reelOffsets[index] })

      Row() {
        Row()
          .width('100%').height(1)
          .backgroundColor($r("app.color.Brand"))
          .opacity(0.6)
      }
      .width('100%')
      .height(this.getIconHeight())
      .position({ y: this.getIconHeight() })
      .zIndex(10)
      .hitTestBehavior(HitTestMode.None)

      Column() {}
        .width('100%').height(this.getIconHeight())
        .position({ y: 0 })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .opacity(0.4)
        .zIndex(9)
        .hitTestBehavior(HitTestMode.None)

      Column() {}
        .width('100%').height(this.getIconHeight())
        .position({ y: this.getIconHeight() * 2 })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .opacity(0.4)
        .zIndex(9)
        .hitTestBehavior(HitTestMode.None)
    }
    .width('30%')
    .height(this.getReelWindowHeight())
    .clip(true)
    .backgroundColor($r("app.color.Comp_Bg2"))
    .borderRadius(16)
    .border(this.winIndex === index || this.winIndex === -2
      ? { width: 2, color: $r("app.color.Brand"), style: BorderStyle.Solid, radius: 16 }
      : { width: 1, color: $r("app.color.border_secondary"), style: BorderStyle.Solid, radius: 16 })
    .animation(this.winIndex >= -1 ? { duration: 400, curve: Curve.EaseOut } : { duration: 0 })
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => { router.back({ url: 'pages/IndexPage/Index' }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center).padding({ left: 12 })
        }
        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_slot_machine")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
        }
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => { router.pushUrl({ url: 'pages/SettingPage/SettingPage', params: new Params('no') }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center).padding({ right: 12 })
        }
      }
      .width('100%').backgroundColor($r("app.color.Comp_Bg1")).zIndex(10)
      .margin({ top: $r("app.float.header_margin") }).position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      Scroll() {
        GridRow({ columns: { sm: 4, md: 6, lg: 8 }, gutter: 12 }) {
          GridCol({ span: { sm: 4, md: 4, lg: 6 }, offset: { sm: 0, md: 1, lg: 1 } }) {
            Column({ space: 16 }) {

              Row({ space: 8 }) {
                this.ReelView(0)
                this.ReelView(1)
                this.ReelView(2)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceEvenly)

              Column() {
                if (this.showResult) {
                  Text(this.resultText)
                    .fontSize(16).fontWeight(FontWeight.Bold)
                    .fontColor($r("app.color.Brand"))
                    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut }))
                } else if (this.isSpinning) {
                  Progress({ value: this.resultProgress, total: 3, type: ProgressType.Linear })
                    .width('100%').height(4)
                    .color($r("app.color.Brand"))
                    .backgroundColor($r("app.color.Comp_Bg3"))
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .constraintSize({ minHeight: 24 })

              if (this.comboCount > 0) {
                Text(`连中: ${this.comboCount}`)
                  .fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
              }

              Button({ type: ButtonType.Normal }) {
                Row({ space: 8 }) {
                  SymbolGlyph(this.isSpinning ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
                    .fontSize(22)
                    .fontColor([$r("app.color.control_fc_1")])
                    .symbolEffect(
                      new ReplaceSymbolEffect(EffectScope.WHOLE),
                      this.triggerSwitch
                    )
                  Text(this.isSpinning ? '转动中' : '拉杆')
                    .fontSize(17).fontWeight(FontWeight.Bold)
                    .fontColor($r("app.color.control_fc_1"))
                }
              }
              .width('100%').height(52)
              .backgroundColor($r("app.color.Brand")).borderRadius(26)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
              .enabled(!this.isSpinning)
              .opacity(!this.isSpinning ? 1 : 0.6)
              .onClick(() => {
                if (!this.isSpinning) {
                  this.startSpin()
                }
              })

            }
            .width('100%').padding(24).borderRadius(20)
            .backgroundColor($r("app.color.Comp_Bg1"))
          }
        }
        .margin(24)
      }
      .width('100%').height('100%').scrollBar(BarState.Auto)
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%').backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default SlotMachinePage
