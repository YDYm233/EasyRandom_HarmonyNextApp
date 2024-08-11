import router from '@ohos.router';

@Entry({ routeName: 'Setting' })
@Component
struct Setting {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  private arr: number[] = [1, 2, 3];

  @Builder
  PageMap(name: string) {
       if (name === "NavDestinationTitle2") {
      pageTwoTmp()
    } else if (name === "NavDestinationTitle3") {
      pageThreeTmp()
    }   else {
      pageOneTmp()
    }
  }

  build() {
    Column() {
      Navigation(this.pageInfos) {
        Row(){
          Row(){
            Image($r("app.media.func_back")).height(24).width(24)
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
          .onClick(()=>{
              router.back({ url: 'default/src/main/ets/pages/Index' })
          })
          Row(){
            Text('设置').height(24).fontWeight(800).textAlign(TextAlign.Center)
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
          Row(){
            Image($r("app.media.func_share")).height(24).width(24)
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height($r("app.string.header_height")).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween)
        List({ space: 12 }) {
          ForEach(this.arr, (item:string) => {
            ListItem() {
              Text("NavRouter" + item)
                .width("100%")
                .height(72)
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .fontSize(16)
                .fontWeight(500)
                .textAlign(TextAlign.Center)
                .onClick(()=>{
                  this.pageInfos.pushPath({ name: "NavDestinationTitle" + item})
                })
            }
          }, (item:string):string => item)
        }
        .width("90%")
        .margin({ top: 12 })
      }
      .mode(NavigationMode.Auto)
      .navDestination(this.PageMap)
      .minContentWidth('420vp')
      .backButtonIcon($r("app.media.func_back"))
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}

// PageOne.ets
@Component
export struct pageOneTmp {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      Column() {
        Text("NavDestinationContent1")
      }.width('100%').height('100%')
    }.title("NavDestinationTitle1")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}

// PageTwo.ets
@Component
export struct pageTwoTmp {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      Column() {
        Text("NavDestinationContent2")
      }.width('100%').height('100%')
    }.title("NavDestinationTitle2")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}

// PageThree.ets
@Component
export struct pageThreeTmp {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      Column() {
        Text("NavDestinationContent3")
      }.width('100%').height('100%')
    }.title("NavDestinationTitle3")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}

export  default Setting