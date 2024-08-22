@Component
struct Container {
  build() {
    Column() {
      Text('页面火速开发中')
      Text('邮箱：3014551329@qq.com')
      Image($r('app.media.weixin')).width('100%')
      Text('您还可以通过我的社交账户“门二三三”来留言告知我')
    }
  }
}

@Component
struct ContactUs {
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


export default ContactUs