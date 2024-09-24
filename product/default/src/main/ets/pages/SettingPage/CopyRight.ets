@Component
struct CopyRight {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination(){
    GridRow({columns:{sm:4,md:8,lg:12}}) {
      GridCol({span:{sm:4,md:6,lg:8},offset:{sm:0,md:1,lg:2}}){
        Column() {
          Text('随易软件版权声明©')
            .textAlign(TextAlign.Center)
            .fontSize(24)
            .margin({ bottom: 20 })
            .fontWeight(700)
            .width('100%')
          Text('本“随易”软件已获得电子版权认证，版权归闫东阳所有。本人支持开源，您可以自由使用、修改和分发本软件的代码。但请注意，使用本软件相关代码和功能未经授权不可用于盈利性商业用途。')
            .textAlign(TextAlign.Start)
            .textIndent(32)
            .fontSize(16)
            .margin({ bottom: 15 })
            .width('100%')
          Text('对于违反本版权声明的行为，权利人将依法追究其法律责任。')
            .textAlign(TextAlign.Start)
            .textIndent(32)
            .fontSize(16)
            .margin({ bottom: 15 })
            .width('100%')
          Text('')
            .textAlign(TextAlign.Start)
            .textIndent(32)
            .fontSize(16)
            .margin({ bottom: 15 })
            .width('100%')
        }
        .justifyContent(FlexAlign.Center)
        .height('100%')
      }
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }.title('版权声明')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      //console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}

export default CopyRight