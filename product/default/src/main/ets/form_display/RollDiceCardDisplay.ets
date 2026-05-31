import {Random} from '@ohos/common'
// @Entry
@Component
export struct RollDiceCardDisplay {
  readonly FULL_WIDTH_PERCENT: string = '70%';
  @State diceImageArray: Resource[] =
    [$r("app.media.dice1"), $r("app.media.dice2"), $r("app.media.dice3"), $r("app.media.dice4"), $r("app.media.dice5"),
      $r("app.media.dice6")]
  @State diceImageIndex: Resource = $r("app.media.dice5");
  //this.diceImageArray[Random(0, this.diceImageArray.length - 1, true)]
  build() {
    Row() {
        Image(this.diceImageIndex)
          .width(this.FULL_WIDTH_PERCENT)
          .aspectRatio(1)
          .animation({duration:600})
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height('100%')
      .onClick(() => {
      this.diceImageIndex= this.diceImageArray[Random(0, this.diceImageArray.length - 1, true)]
     })
  }
}
// export default RollDiceCard