@Component
struct Container {
  build() {
    Column() {
      Text('页面搭建中')
      Text('邮箱：3014551329@qq.com')
      Image('http://m233.top/easyrandom/weixin.jpg').width('100%')
      Text('您还可以尝试通过以下链接来留言告知我')
      Hyperlink('https://www.bilibili.com/opus/971320804050468900?spm_id_from=333.1365.0.0','B站')
      Hyperlink('https://weibo.com/5858421461/OuE5WnqyO','微博')
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