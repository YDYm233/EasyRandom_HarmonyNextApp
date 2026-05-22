
@Entry
@Component
struct TextMarquee {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @State text:string = '测试文本TestText测试文本TestText测试文本TestText'
  @State fontColor:Color = 0xffffff
  @State backColor:Color = 0x000000
  @State isStart:boolean=true
  @State isRotate:boolean=false

  // @Builder
  // MarqueeView() {
  //   NavDestination() {
  //     Row() {
  //       Marquee({ start: this.isStart, fromStart: false, src: this.text })
  //         .height(100)
  //         .width(1000)
  //         .fontSize(80)
  //         .fontWeight(800)
  //         .fontColor(this.fontColor)
  //       .rotate({z:1,angle:this.isRotate?0:90})
  //     }
  //     .backgroundColor(this.backColor)
  //     .onClick(()=>{
  //       this.isStart=!this.isStart;
  //     })
  //     .justifyContent(FlexAlign.Center)
  //     .alignItems(VerticalAlign.Center)
  //     .width('100%')
  //     .height('100%')
  //   }
  //   .hideTitleBar(true)
  //   .onBackPressed(() => {
  //     const popDestinationInfo = this.pageInfos.pop()
  //     return true
  //   })
  // }
  build() {
    Navigation(this.pageInfos) {
      Column(){


      }
      .onClick(() => {
        this.pageInfos.pushPath({ name: 'MarqueeView'})
      })
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      .width('100%')
      .height('100%')
      .backgroundColor(0xf1f3f5)
    }
    .padding(0)
    .width('100%')
    .height('100%')
    .backgroundColor(0xffffff)
    .mode(NavigationMode.Stack)
    // .navDestination(this.MarqueeView)
    .hideTitleBar(true)
    .hideToolBar(true)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Builder
export function MarqueeViewBuilder() {
  TextMarqueeView();
}

@Component
struct TextMarqueeView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State isStart:boolean=true
  @State isRotate:boolean=false
  @State text:string = '测试文本TestText测试文本TestText测试文本TestText'
  @State fontColor:Color = 0xffffff
  @State backColor:Color = 0x000000
  
  build() {
    NavDestination() {
      Row() {
        Marquee({ start: this.isStart, fromStart: false, src: this.text })
          .height(100)
          .width(1000)
          .fontSize(80)
          .fontWeight(800)
          .fontColor(this.fontColor)
        .rotate({z:1,angle:this.isRotate?0:90})
      }
      .backgroundColor(this.backColor)
      .onClick(()=>{
        this.isStart=!this.isStart;
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop()
      return true
    })
  }
}

