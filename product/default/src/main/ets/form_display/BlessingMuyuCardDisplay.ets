import { Random } from '@ohos/common'
import { preferences } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit'

const PREF_NAME: string = 'blessing_muyu'
const KEY_CLICK_COUNT: string = 'click_count'

@Component
export struct BlessingMuyuCardDisplay {
  private readonly BLESSINGS: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  private readonly LUCK: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      2, 2, 2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3,
      5, 5,
      0]
  private readonly COLOR_PRESETS: string[] = [
    '#D4A017', '#FF6B6B', '#FF8C00', '#FF1493', '#00CED1',
    '#7B68EE', '#FF4500', '#32CD32', '#FF69B4', '#00BFFF'
  ]

  @State blessingText: string = '点击木鱼'
  @State blessingColor: string = this.COLOR_PRESETS[0]
  @State bubbleScale: number = 1
  @State bubbleTranslateY: number = 0
  @State tapVersion: number = 0
  @State tapCount: number = 0
  private pref?: preferences.Preferences
  private appCtx?: Context

  aboutToAppear(): void {
    try {
      this.appCtx = getContext(this).getApplicationContext()
      this.pref = preferences.getPreferencesSync(this.appCtx, { name: PREF_NAME })
      const saved = this.pref.getSync(KEY_CLICK_COUNT, 0) as number
      if (saved > this.tapCount) {
        this.tapCount = saved
      }
    } catch (_e) {
      // fallback
    }
  }

  build() {
    Stack() {
      Column() {
        Text(this.blessingText)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.blessingColor)
          .scale({ x: this.bubbleScale, y: this.bubbleScale })
          .translate({ y: this.bubbleTranslateY })
          // .shadow({ radius: 4, color: '#40000000', offsetX: 0, offsetY: 2 })

        Blank()

        Image($r('app.media.MuYu'))
          .width('80%')
          .aspectRatio(1)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            // ── 本地动画 ──
            this.tapVersion++
            let version = this.tapVersion
            let idx = Random(0, this.BLESSINGS.length - 1, true)
            let count = this.LUCK[Random(0, this.LUCK.length - 1, true)]
            this.blessingText = this.BLESSINGS[idx] + ' +' + count
            this.blessingColor = this.COLOR_PRESETS[Random(0, this.COLOR_PRESETS.length - 1, true)]
            this.bubbleScale = 0.6
            this.bubbleTranslateY = 15
            animateTo({ duration: 300, curve: Curve.EaseOut, onFinish: () => {
              if (this.tapVersion !== version) return
              animateTo({ duration: 150, curve: Curve.EaseIn }, () => {
                this.bubbleScale = 1.0
                this.bubbleTranslateY = 0
              })
            }}, () => {
              this.bubbleScale = 1.08
              this.bubbleTranslateY = -2
            })

            // ── 计数：持久化 Preferences + hilog ──
            this.tapCount++
            hilog.info(0x0000, 'testTag', '祝福木鱼[组件]总数：%{public}d', this.tapCount)
            try {
              if (this.appCtx && this.pref) {
                this.pref.putSync(KEY_CLICK_COUNT, this.tapCount)
                this.pref.flushSync()
              }
            } catch (_e) {
              // fallback
            }
          })
      }
      .width('100%')
      .height('100%')
      .padding({ top: 12, bottom: 12 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .borderRadius(8)
    .backgroundColor($r('app.color.Comp_Bg1'))
    .clip(true)
  }
}
