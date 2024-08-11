@Component
struct Standard {
  @State index: Array<Resource> = [$r("app.media.page_icon2_selected"), $r("app.media.page_icon2_selected")]
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
            md: 6,
            lg: 6
          },
          offset: {
            sm: 0,
            md: 1,
            lg: 3
          }
        }) {
          Row() {

          }
          .width('100%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
        }
        .height('100%')
      }
      .height('100%')
      .margin({ left: 12, right: 12 })
    }.height('100%').backgroundColor($r("app.color.view_bgc_2"))
  }
}
