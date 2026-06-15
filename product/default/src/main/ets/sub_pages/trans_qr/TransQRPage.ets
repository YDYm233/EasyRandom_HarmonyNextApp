import router from '@ohos.router';

class Params {
  type: string

  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct TransQR {
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
            Text($r("app.string.page_qrcode")).fontColor($r("app.color.FontIcon_Fore1"))
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
              md: 6,
              lg: 8
            },
            offset: {
              sm: 0,
              md: 1,
              lg: 2
            }
          }) {
            Row() {
              NamesBox().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)
        // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%').padding({ top: $r("app.float.header_height") })
    }
    // .padding({ top: this.statusBarHeight })
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg2"))
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct NamesBox {
  @State QrCode: string = 'https://developer.huawei.com/consumer/cn/'
  @State WebSrc: string = '示例地址 ：华为开发者 \n https://developer.huawei.com/consumer/cn/'

  build() {
    Column() {
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
            lg: 6
          }
        }) {
          Row() {
            QRCode(this.QrCode).width('90%').margin('5%')
              .color($r("app.color.FontIcon_Fore1"))
              .backgroundColor($r("app.color.Comp_Bg1"))
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .aspectRatio(1)
        }
        .borderRadius(24).backgroundColor($r("app.color.Comp_Bg1"))


        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Column() {
            Row() {
              Text('在此输入文本或链接：')
                .textAlign(TextAlign.Center)
                .alignSelf(ItemAlign.Center)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.FontIcon_Fore1"))
            }
            .width('100%')
            .layoutWeight(1)

            TextArea({ text: this.WebSrc, placeholder: '\n本app不会收集或保存您在此输入的数据' })
              .padding(12)
              .layoutWeight(4)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .backgroundColor($r("app.color.Comp_Bg1"))
              .onChange((value: string) => {
                this.WebSrc = value;
              })
            Row() {
              Button() {
                Text('确认').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold)
              }
              .onClick(() => {
                this.QrCode = this.WebSrc;
              })

              .backgroundColor($r("app.color.control_bgc_1"))
              .height('80%')
              .aspectRatio(2)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
          }.height('100%')
          .aspectRatio(1)
        }
        .padding({
          left: '5%',
          right: '5%',
          top: '4%',
          bottom: '1%'
        })
        .width('100%')
        .aspectRatio(1)
        .backgroundColor($r("app.color.Comp_Bg1"))
        .border({ width: 0, color: $r("app.color.FontIcon_Fore4"), radius: 24 })
      }
    }
  }
}

export default TransQR