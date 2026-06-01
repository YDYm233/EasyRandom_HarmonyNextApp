// 页面路径要注册进 file:../product/default/src/main/resources/base/profile/main_pages.json
// 页面名称要注册进 file:../AppScope/resources/base/element/page_desc.json
// 页面入口要写进 file:../product/default/src/main/ets/pages/ToolsPage.ets

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
struct AStandard {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  build() {
    Column() {
      // ────────────────── 标题栏 ──────────────────
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
            Text($r("app.string.page_xxx")).fontColor($r("app.color.FontIcon_Fore1"))
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
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      // ────────────────── 内容区域 ──────────────────
      Scroll() {
        GridRow({
          columns: { sm: 4, md: 8, lg: 12 },
          gutter: 12
        }) {
          GridCol({
            span: { sm: 4, md: 4, lg: 4 },
            offset: { sm: 0, md: 2, lg: 4 }
          }) {
            Row() {
              ContentBox().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)
      }
      .width('100%')
      .height('100%')
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
  }
}

@Component
struct ContentBox {
  build() {
    Column() {

    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)
  }
}

export default AStandard
