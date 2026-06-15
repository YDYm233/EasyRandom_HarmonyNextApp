import router from '@ohos.router';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct MetronomePage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => { router.back({ url: 'pages/IndexPage/Index' }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text('节拍器').fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/SettingPage/SettingPage', params: new Params('no') })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%').backgroundColor($r("app.color.Comp_Bg1")).zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      Scroll() {
        Column() {
          // TODO: 功能待实现
        }
        .width('100%').padding({ top: $r("app.float.header_height") })
      }
      .width('100%').height('100%')
    }
    .height('100%').backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default MetronomePage
