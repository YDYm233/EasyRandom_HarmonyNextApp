@Component
struct Container {
  build() {
    Column() {
      Text('邮箱：3014551329@qq.com')    . fontColor($r("app.color.FontIcon_Fore1"))
      Image('http://m233.top/easyrandom/weixin.jpg').width('100%')
      Text('您还可以尝试通过以下链接来留言告知我')         . fontColor($r("app.color.FontIcon_Fore1"))
      Hyperlink('https://www.bilibili.com/opus/971320804050468900?spm_id_from=333.1365.0.0','B站')
      Hyperlink('https://weibo.com/5858421461/OuE5WnqyO','微博')
    }
  }
}

@Builder
export function ContactUs() {
  ContactUsComponent();
}

@Component
struct ContactUsComponent {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
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
      }.height('100%')              .backgroundColor($r("app.color.Comp_Bg2"))
    }.title('问题反馈')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      //console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}


// export default ContactUsComponent