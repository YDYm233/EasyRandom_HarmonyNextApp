import { Random } from '@ohos/common'

@Entry
@Component
struct BlessingMuyuCard {
  @State blessings: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  @State positions: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State opacityArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State random: number = 1
  @State luck: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 0]

  build() {
    Column() {
      // Blessing text area
      Row() {
        ForEach(this.blessings, (blessing: string, index: number) => {
          Text(blessing + ' +' + this.random)
            .position({ bottom: this.positions[index] })
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Bold)
            .fontSize('30%')
            .animation({ duration: this.positions[index] > 0 ? 200 : 0 })
            .opacity(this.opacityArray[index])
        }, (blessing: string, index: number) => index.toString())
      }
      .height('30%')
      .width('100%')

      // MuYu image area
      Row() {
        Image($r("app.media.MuYu"))
          .width('80%')
          .aspectRatio(1)
          .onClick(() => {
            let index = Random(0, this.blessings.length - 1, true)
            this.random = this.luck[Random(0, this.luck.length - 1, true)]
            // Show blessing text
            animateTo({
              duration: 200,
              curve: Curve.EaseIn
            }, () => {
              this.opacityArray[index] = 1
              this.positions[index] = 25
            })
            // Hide after delay
            animateTo({
              duration: 200,
              curve: Curve.EaseOut,
              delay: 800
            }, () => {
              this.opacityArray[index] = 0
              this.positions[index] = 0
            })
          })
      }
      .height('70%')
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .borderRadius(8)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)
  }
}

export default BlessingMuyuCard
