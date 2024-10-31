import { Random } from '@ohos/common';
import Header from './Header';

@Entry
@Component
struct RollDices {
  build() {
    Column() {
      Header({ title: '掷骰子' })
      Scroll() {
        GridRow({
          columns: {
            sm: 4,
            md: 8,
            lg: 12
          },
          gutter: 12
        }) {
          GridCol({
            span: {
              sm: 4,
              md: 4,
              lg: 4
            },
            offset: {
              sm: 0,
              md: 2,
              lg: 4
            }
          }) {
            Row() {
              RollDiceBox().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')  .padding({ top: $r("app.string.header_height") })
    }.height('100%')    .backgroundColor($r("app.color.Comp_Bg3"))    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct RollDiceBox {
  @State diceImageArray: Resource[] =
    [$r("app.media.dice1"), $r("app.media.dice2"), $r("app.media.dice3"), $r("app.media.dice4"), $r("app.media.dice5"),
      $r("app.media.dice6")]
  @State diceImageIndex: Resource = this.diceImageArray[Random(0, this.diceImageArray.length - 1, true)]

  build() {
    Column() {
      Row() {
        Image(this.diceImageIndex).height('70%').animation({ duration: 100 })
      }.width('100%').height('80%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

      Row() {
        Button('开始')
          .backgroundColor($r("app.color.control_bgc_1"))
          .height('80%')
          .fontWeight(800)
          .aspectRatio(2)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            let selected: Resource = this.diceImageArray[Random(0, this.diceImageArray.length - 1, true)];
            let index = 0;
            let loop = setInterval(() => {
              this.diceImageIndex = this.diceImageArray[Random(0, this.diceImageArray.length - 1, true)];
              if (index > 15) {
                this.diceImageIndex = selected
                clearInterval(loop)
              }
              index++;
            }, 60)
          })
      }.height('20%')
    }.aspectRatio(1)    .backgroundColor($r("app.color.Comp_Bg1")) .borderRadius(24)
  }
}