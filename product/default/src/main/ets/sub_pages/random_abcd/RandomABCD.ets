import { Random } from '@ohos/common'
import router from '@ohos.router';

class Params {
  type: string

  constructor(tuple: string) {
    this.type = tuple
  }
}


@Entry
@Component
struct RollFlip {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.back({ url: 'pages/IndexPage/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_abcd")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.float.header_height"))
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
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%')
      // .height($r("app.float.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

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
              ABCD().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%').padding({ top: $r("app.float.header_height") })
    }
    // .padding({ top: this.statusBarHeight })
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct ABCD {
  @State angle: number = 30
  @State duration: number = 2200
  @State colors: Resource[] =
    [$r("app.color.view_bgc_3"), $r("app.color.view_bgc_3"), $r("app.color.view_bgc_3"), $r("app.color.view_bgc_3")]
  @State fontColors: Color[] = [0x333333, 0x333333, 0x333333, 0x333333]

  build() {
    Column() {
      Column() {
        Text('A')
          .width('50%')
          .height('50%')
          .backgroundColor(this.colors[0])
          .fontColor(this.fontColors[0])
          .position({ left: 0, top: 0 })
          .border({
            style: BorderStyle.Solid,
            width: 5,
            color: $r("app.color.Comp_Bg2"),
            radius: 12
          })
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48)
          .textAlign(TextAlign.Center)
        Text('B')
          .width('50%')
          .height('50%')
          .backgroundColor(this.colors[1])
          .fontColor(this.fontColors[1])
          .position({ right: 0, top: 0 })
          .border({
            style: BorderStyle.Solid,
            width: 5,
            color: $r("app.color.Comp_Bg2"),
            radius: 12
          })
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48)
          .textAlign(TextAlign.Center)
        Text('C')
          .width('50%')
          .height('50%')
          .backgroundColor(this.colors[2])
          .fontColor(this.fontColors[2])
          .position({ left: 0, bottom: 0 })
          .border({
            style: BorderStyle.Solid,
            width: 5,
            color: $r("app.color.Comp_Bg2"),
            radius: 12
          })
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48)
          .textAlign(TextAlign.Center)
        Text('D')
          .width('50%')
          .height('50%')
          .backgroundColor(this.colors[3])
          .fontColor(this.fontColors[3])
          .position({ right: 0, bottom: 0 })
          .border({
            style: BorderStyle.Solid,
            width: 5,
            color: $r("app.color.Comp_Bg2"),
            radius: 12
          })
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48)
          .textAlign(TextAlign.Center)
        Image($r("app.media.needle"))
          .width('60%')
          .aspectRatio(1)
          .position({ left: '20%', top: '20%' })
          .fillColor($r("app.color.view_bgc_1"))
          //.backgroundColor($r("app.color.view_bgc_2"))
          .rotate({ angle: this.angle })
          .animation({ duration: this.duration, curve: Curve.Ease })
      }
      .width('100%')
      .padding(6)
      .aspectRatio(1)
      .borderRadius(12)
      .backgroundColor($r("app.color.Comp_Bg1"))
      .clip(true)

      Row() {
        Button('开始')
          .aspectRatio(2)
          .height('80%')
          .backgroundColor($r('app.color.brand'))
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            this.colors[0] = $r("app.color.view_bgc_3")
            this.colors[1] = $r("app.color.view_bgc_3")
            this.colors[2] = $r("app.color.view_bgc_3")
            this.colors[3] = $r("app.color.view_bgc_3")
            this.fontColors[0] = 0x333333;
            this.fontColors[1] = 0x333333;
            this.fontColors[2] = 0x333333;
            this.fontColors[3] = 0x333333;
            this.angle += Random(1, 360, true) + 360 * 3;
            if (this.angle > 36000000) {
              this.angle = Random(1, 360, true) + 360 * 3;
            }
            setTimeout(() => {
              if (this.angle % 360 < 90) {
                this.colors[1] = $r("app.color.Brand")
                this.fontColors[1] = 0xffffff;
              } else if (this.angle % 360 > 90 && this.angle % 360 < 180) {
                this.colors[3] = $r("app.color.Brand")
                this.fontColors[3] = 0xffffff;
              } else if (this.angle % 360 > 180 && this.angle % 360 < 270) {
                this.colors[2] = $r("app.color.Brand")
                this.fontColors[2] = 0xffffff;
              } else {
                this.colors[0] = $r("app.color.Brand")
                this.fontColors[0] = 0xffffff;
              }
            }, this.duration)

          })
      }.width('100%').aspectRatio(5)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .aspectRatio(5 / 6)
    .borderRadius(12)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)

  }
}

export default RollFlip