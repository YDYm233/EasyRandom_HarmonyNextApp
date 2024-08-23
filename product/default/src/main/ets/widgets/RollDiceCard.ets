import {Random} from '@ohos/common'
@Entry
@Component
struct Widget1Card {
  readonly ACTION_TYPE: string = 'router';
  readonly ABILITY_NAME: string = 'EntryAbility';
  readonly MESSAGE: string = 'add detail';
  readonly FULL_WIDTH_PERCENT: string = '70%';
  readonly FULL_HEIGHT_PERCENT: string = '70%';
  @State diceImageArray: Resource[] =
    [$r("app.media.dice1"), $r("app.media.dice2"), $r("app.media.dice3"), $r("app.media.dice4"), $r("app.media.dice5"),
      $r("app.media.dice6")]
  @State diceImageIndex: Resource = this.diceImageArray[Random(0, this.diceImageArray.length - 1, true)]
  build() {
    Row() {
        Image(this.diceImageIndex)
          .width(this.FULL_WIDTH_PERCENT)
          .aspectRatio(1)
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