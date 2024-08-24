import {Random} from '@ohos/common'
@Entry
@Component
struct FlipCoinCardCard {
  readonly ACTION_TYPE: string = 'router';
  readonly ABILITY_NAME: string = 'EntryAbility';
  readonly MESSAGE: string = 'add detail';
  readonly FULL_WIDTH_PERCENT: string = '70%';
  readonly FULL_HEIGHT_PERCENT: string = '70%';
  @State coinImageArray: Resource[] = [$r("app.media.coin1"), $r("app.media.coin2")]
  @State coinImageIndex: Resource = this.coinImageArray[Random(0, this.coinImageArray.length - 1, true)]
  build() {
    Row() {
      Image(this.coinImageIndex)
        .width(this.FULL_WIDTH_PERCENT)
        .aspectRatio(1)
        .animation({duration:600})
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.coinImageIndex= this.coinImageArray[Random(0, this.coinImageArray.length - 1, true)]
    })
  }
}

export default FlipCoinCardCard