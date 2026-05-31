import { Random } from '@ohos/common'


@Component
export struct BlessingMuyuCardDisplay {
  private readonly BLESSINGS: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  private readonly LUCK: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      2, 2, 2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3,
      5, 5,
      0]

  @State blessingText: string = '点击木鱼'
  @State bubbleScale: number = 1
  @State bubbleTranslateY: number = 0
  @State tapVersion: number = 0

  build() {
    Stack() {
      Column() {
        Text(this.blessingText)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D4A017')
          .scale({ x: this.bubbleScale, y: this.bubbleScale })
          .translate({ y: this.bubbleTranslateY })
          .shadow({ radius: 4, color: '#40000000', offsetX: 0, offsetY: 2 })

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

            // ── 计数：message → DefaultFormAbility.onFormEvent → Preferences ──
            postCardAction(this, {
              action: 'message',
              params: { event: 'blessing_muyu_click' }
            })
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

// export default BlessingMuyuCard
