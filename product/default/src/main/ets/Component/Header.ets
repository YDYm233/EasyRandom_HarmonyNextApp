import router from '@ohos.router';
//import  '@ohos/setting/src/main/ets/pages/Index'
@Component
export default struct Header {
  @Prop title: string
  build() {
    Column() {
      GridRow({columns:{sm:12,md:12,lg:12}}) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp')
          }
          .onClick(()=>{
            router.back({url:'pages/Index'})
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
            Text(this.title)
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24)
          }
          .onClick(()=>{
            router.pushUrl({
              url: 'C_setting/SettingPage'
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

    }
    .width('100%')
    .height($r("app.string.header_height"))
    .backgroundColor($r("app.color.view_bgc_1"))
    .zIndex(10)
    .margin({ top: $r("app.string.header_margin") })
    .position({ top: $r("app.string.header_margin") })
  }
}