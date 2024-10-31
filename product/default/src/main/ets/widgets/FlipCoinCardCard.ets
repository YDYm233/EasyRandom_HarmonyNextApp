import {Random} from '@ohos/common'
@Entry
@Component
struct FlipCoinCardCard {
  readonly FULL_WIDTH_PERCENT: string = '70%';
  @State coinImageArray: Resource[] = [$r("app.media.coin1"), $r("app.media.coin2")]
  @State coinImageIndex: Resource = this.coinImageArray[Random(0, this.coinImageArray.length - 1, true)]
  @State angle:number =0;
  build() {
    Row() {
      Stack() {
        Image($r("app.media.coin1"))
          .width('100%')
          .aspectRatio(1)
          .position({ top: 0, left: 0 })
          //.opacity(this.B)
        Image($r("app.media.coin2"))
          .width('100%')
          .aspectRatio(1)
          .position({ top: 0, left: 0 })
         // .opacity(this.F)
          .objectFit(ImageFit.Contain)
      }
      .width('67%')
      .aspectRatio(1)
      .borderRadius('50%')
      .clip(true)
      .margin({ bottom: '10%' })
      .rotate({ x: 1, angle: this.angle })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.coinImageIndex= this.coinImageArray[Random(0, this.coinImageArray.length - 1, true)]
      animateTo ( {
        duration: 1000,
        iterations: 1,
        curve:Curve.Linear
      }, () => {
        this.angle = this.angle+Random(2,3,true)*180;
      })
    })
  }
}

export default FlipCoinCardCard