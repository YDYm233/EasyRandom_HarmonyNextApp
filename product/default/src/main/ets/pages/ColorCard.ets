@Entry
@Component
struct ColorCard {
  build() {
    Row() {
      Column() {
        Button() {
          Image($r("app.media.page_icon1_selected")).fillColor($r("app.color.control_fc_1")).width(100)
        }
        .backgroundColor($r("app.color.control_bgc_1"))
        .width(200)
        .aspectRatio(2)
        .margin(25)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        Button() {
          Text('开始').fontColor($r("app.color.control_fc_1")).width(100)
        }
        .backgroundColor($r("app.color.control_bgc_1"))
        .width(200)
        .aspectRatio(2)
        .margin(25)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        Button() {
          Text('按钮2').fontColor($r("app.color.control_fc_2"))
        }
        .backgroundColor($r("app.color.control_bgc_2"))
        .width(200)
        .aspectRatio(2)
        .margin(25)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })

        Button() {
          Text('状态按钮').fontColor($r("app.color.control_fc_3"))
        }.backgroundColor($r("app.color.control_bgc_3")).width(200).aspectRatio(2).margin(25)

        Button() {
          Text('组件1').fontColor($r("app.color.container_fc_1"))
        }.backgroundColor($r("app.color.container_bgc_1")).width(200).aspectRatio(2).margin(25)

        Button() {
          Text('组件2').fontColor($r("app.color.container_fc_2"))
        }.backgroundColor($r("app.color.container_bgc_2")).width(200).aspectRatio(2).margin(25)


        Column() {
          Button() {
            Text('背景1').fontColor($r("app.color.control_fc_2"))
          }.backgroundColor($r("app.color.view_bgc_1")).width(200).aspectRatio(2).margin(25)

          Button() {
            Text('背景2').fontColor($r("app.color.control_fc_2"))
          }.backgroundColor($r("app.color.view_bgc_2")).width(200).aspectRatio(2).margin(25)

          Button() {
            Text('背景3').fontColor($r("app.color.control_fc_2"))
          }.backgroundColor($r("app.color.view_bgc_3")).width(200).aspectRatio(2).margin(25)

          Button() {
            Text('背景4').fontColor($r("app.color.control_fc_2"))
          }.backgroundColor($r("app.color.view_bgc_4")).width(200).aspectRatio(2).margin(25)
        }
      }
      .width(300)
      .height(1200)
    }
    .width(600)
    .height(1200)
    .backgroundColor($r("app.color.view_bgc_2"))
  }
}