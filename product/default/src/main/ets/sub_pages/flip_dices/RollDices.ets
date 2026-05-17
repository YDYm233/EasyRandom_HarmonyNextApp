import { Random } from '@ohos/common';
import router from '@ohos.router';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct RollDices {
  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.back({ url: 'pages/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_roll_dices")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SettingPage/SettingPage',
              params: new Params('no')
            }).then(() => {
              console.info("success.");
            })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%')
      .height($r("app.string.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.string.header_margin") })
      .position({ top: $r("app.string.header_margin") })
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