import router from '@ohos.router';
import { AboutUs } from './AboutUs';
import { ContactUs } from './ContactUs';
import { Options } from './Options';
import { PrivacyPolicy } from './PrivacyPolicy';
import { Illustrate } from './MoreOpt';
import { CopyRight } from './CopyRight';
import { promptAction } from '@kit.ArkUI';
import { BreakpointState, BreakpointSystem } from '@ohos/common';
import { resourceManager } from '@kit.LocalizationKit';

class Item {
  title: string
  icon: Resource
  color: Color

  constructor(title: string, icon: Resource, color: Color) {
    this.title = title
    this.icon = icon
    this.color = color
  }
}

let aboutUs = new Item('开发者团队', $r("app.media.aboutus_fill"), 0xfff05)
let contactUs = new Item('问题反馈', $r("app.media.contactus_fill"), 0xf10ff5)

let options = new Item('通用设置', $r("app.media.func_setting"), 0x01f3ff)

let privacyPolicy = new Item('隐私政策', $r("app.media.privacypolicy"), 0xFF00BEFF)
let copyRight = new Item('版权声明', $r("app.media.addoil_thumb"), 0xfebb00)
let illustrate = new Item('更多信息', $r("app.media.illustrate"), 0xbeff00)
let addOil = new Item('赞赏我们', $r("app.media.addoil_flower"), 0xffbe00)
let moreOpt = new Item ('更多操作',$r("app.media.func_more"),0xFFBBEE)
class Params {
  type:string
  constructor(tuple:string) {
    this.type = tuple
  }
}
@Entry({ routeName: 'Setting' })
@Component
struct Setting {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State appInfoText: string = 'App'
onPageShow(): void {

}
  aboutToAppear() {
    let params = router.getParams() as Params;
    console.info(`参数：${params.type}`)
    if(this.currentBreakpoint.value!='sm'&&params.type!='privatepolicy')this.pageInfos.pushPath({ name:'开发者团队' } )
    else if(params.type=='privatepolicy')this.pageInfos.pushPath({ name:'隐私政策' } )
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
    const resMgr = getContext(this).resourceManager;
    this.appInfoText = resMgr.getStringSync($r('app.string.app_name').id)
      + resMgr.getStringSync($r('app.string.app_version').id);
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }
  // @Builder
  // PageMap(name: string) {
  //   if (name == "版权声明") {
  //     CopyRight()
  //   } else if (name == "通用设置") {
  //     Options()
  //   } else if (name == "问题反馈") {
  //     ContactUs()
  //   } else if (name == "隐私政策") {
  //     PrivacyPolicy()
  //   } else if (name == "更多操作") {
  //     Illustrate()
  //   } else { //默认开发者团队页面
  //     AboutUs()
  //   }
  // }

  @Builder
  itemHead(text: string) {
    Text(text)
      .fontSize(20)
      .width("100%")
      .padding(10)
      .fontColor($r("app.color.FontIcon_Fore1"))
  }

  @Builder
  SettingItem(item: Item) {
    Row() {
      Row() {
        Image(item.icon).fillColor(Color.White).width('70%').margin('15%')
      }
      .aspectRatio(1)
      .height('60%')
      .borderRadius('50%')
      .backgroundColor(item.color)

      Text(item.title)
        .width("60%")
        .height('100%')
        .fontSize(16)
        .fontWeight(500)
        .textAlign(TextAlign.Start)
        .margin({ left: 8 })
        .fontColor($r("app.color.FontIcon_Fore1"))
      Row() {
        Image($r("app.media.func_next")).width('60%').margin('20%').fillColor($r("app.color.FontIcon_Fore1"))
      }
      .aspectRatio(1)
      .height('60%')
      .borderRadius('50%')

    }
    .onClick(() => {
      this.pageInfos.pushPath({ name: item.title })
      console.log("click"+item.title)
     // console.log('name' + item.title)
    })          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
    .width('100%')
    .height(50)
    .borderRadius(12)
    .padding({ left: 24, right: 24 })
    .backgroundColor($r("app.color.Comp_Bg1"))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  build() {
      Navigation(this.pageInfos) {
        Column(){
        Row() {
          Row() {
            Image($r("app.media.func_back")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .height('100%')
          .aspectRatio(1)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.back({ url: 'pages/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })

          Row() {
            Text('设置').height(24).fontWeight(800).textAlign(TextAlign.Center).fontColor($r("app.color.FontIcon_Fore1"))
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

          Row() {
            Image($r("app.media.func_share")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))

          } .onClick(() => {
            promptAction.showToast({
              message: '功能开发中'
            })
          })          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(56)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.Comp_Bg1"))
        // .backgroundColor('rgba(0,0,0,0)')

        List({ space: 12 }) {
          ListItem() {
            Column() {
              Image($r("app.media.app_icon"))
                .width('40%')
                .aspectRatio(1)
                .margin({
                  left: '30%',
                  right: '30%',
                  top: '10%',
                  bottom: '10%'
                })
              Row() {
                Text(this.appInfoText)
                  .textAlign(TextAlign.End)
                  .fontWeight(600)
                  .fontSize(16)          .fontColor($r("app.color.FontIcon_Fore1"))
              }
              .justifyContent(FlexAlign.SpaceAround)
              .alignItems(VerticalAlign.Center)
              .margin({
                bottom: '4%'
              })
              .height(30)
              .width('100%')
            }
          }

          ListItemGroup({ header: this.itemHead('关于'), space: 8 }) {
            ListItem() {
              this.SettingItem(aboutUs)
            }
            ListItem() {
              this.SettingItem(privacyPolicy)
            }
            // ListItem() {
            // this.SettingItem(illustrate)
            //  }
          }
          ListItemGroup({ header: this.itemHead('通用'), space: 8 }) {
            ListItem() {
              this.SettingItem(options)
            }
            ListItem() {
              this.SettingItem(moreOpt)
            }
          }




          //列表底部抬高
          .margin({bottom:120})
        }
        .padding({
          left: 12,
          right: 12,
          top: 0,
          bottom: 0
        })
        .width("100%")
        .height('100%')
      //  .backgroundColor(0x00beff)
       // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
        .height('100%')
        .backgroundColor($r("app.color.Comp_Bg3"))
       // .backgroundColor(0xfff000)
       // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .padding(0)
      .width('100%')
      .height('100%')
      .backgroundColor($r("app.color.Comp_Bg1"))
      .mode(NavigationMode.Auto)
      // .navDestination(this.PageMap) // 使用系统路由表配置
      .hideTitleBar(true)
      .hideToolBar(true)
      .minContentWidth('420vp')
      .backButtonIcon(this.currentBreakpoint.value=='sm'?$r("app.media.func_back"):null)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
     // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}


export default Setting