@Component
struct Container{
  build(){
    List(){}
  }
}

@Component
struct Options{
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
            lg: 4
          },
          offset: {
            sm: 0,
            md: 2,
            lg: 4
          }
        }) {
          Row() {
            Container()
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


export default Options