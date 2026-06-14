@Component
struct Container {
  build() {
    Column() {
      Image($r("app.media.qqcode"))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .height('100%')
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
      }.height('100%')
      .backgroundColor($r("app.color.Comp_Bg2"))
    }.title('问题反馈')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop()
      return true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}
