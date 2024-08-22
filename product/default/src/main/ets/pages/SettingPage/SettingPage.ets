import router from '@ohos.router';
import AboutUs from './AboutUs';
import ContactUs from './ContactUs';
import Options from './Options';
import PrivacyPolicy from './PrivacyPolicy';
import Illustrate from './Illustrate';
import CopyRight from './CopyRight';
import AddOil from './AddOil';
import { promptAction } from '@kit.ArkUI';
class Item{
  title:string
  icon:Resource
  color:Color
  constructor(title:string,icon:Resource,color:Color) {
    this.title=title
    this.icon=icon
    this.color=color
  }
}
let aboutUs = new Item('开发者团队',$r("app.media.aboutus_fill"),0xfff05)
let contactUs = new Item('问题反馈',$r("app.media.contactus_fill"),0xf10ff5)

let options = new Item('通用设置',$r("app.media.func_setting"),0x01f3ff)

let privacyPolicy = new Item('隐私政策',$r("app.media.privacypolicy"),0x00beff)
let copyRight = new Item('版权声明',$r("app.media.addoil_thumb"),0xfebb00)
let illustrate = new Item('更多信息',$r("app.media.illustrate"),0xbeff00)

let addOil = new Item('赞赏我们',$r("app.media.addoil_flower"),0xffbe00)
@Entry({ routeName: 'Setting' })
@Component
struct Setting {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if(name=="问题反馈"){
            ContactUsView()
      }else if (name == "通用设置") {
         OptionsView()
       }else if (name == "使用说明") {
         IllustrateView()
       }else if (name == "隐私政策") {
         PrivacyPolicyView()
       }else if (name == "版权声明") {
         CopyRightView()
    }else if (name == "更多信息") {
        IllustrateView()
       }else if (name == "赞赏我们") {
         AddOilView()
       }
       else{//默认开发者团队页面
         AboutUsView()
       }
  }
  @Builder
  itemHead(text: string) {
    Text(text)
      .fontSize(20)
      .width("100%")
      .padding(10)
  }
@Builder SettingItem(item:Item){
    Row(){
      Row() {
        Image(item.icon).fillColor(0xffffff).width('70%').margin('15%')
      }
        .aspectRatio(1)
        .height('60%')
        .borderRadius('50%')
      .backgroundColor(item.color)

    Text( item.title)
    .width("60%")
    .height('100%')
    .fontSize(16)
    .fontWeight(500)
    .textAlign(TextAlign.Start)
      .margin({left:8})

      Row() {
        Image($r("app.media.func_next")).width('60%').margin('20%')      .fillColor(0x885e5e5e)
      }
      .aspectRatio(1)
      .height('60%')
      .borderRadius('50%')



    }    .onClick(()=>{
      this.pageInfos.pushPath({ name:  item.title})
      console.log('name'+item.title)
    })
.width('100%')       .height(50)    .borderRadius(12).padding({left:24,right:24})
.backgroundColor('#FFFFFF').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
  }
  build() {
    Column() {
      Navigation(this.pageInfos) {
        Row(){
          Row(){
            Image($r("app.media.func_back")).height(24).width(24)
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
          .onClick(()=>{
            router.back({url:'pages/Index'})
          })
          Row(){
            Text('设置').height(24).fontWeight(800).textAlign(TextAlign.Center)
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
          Row(){
            Image($r("app.media.func_share")).height(24).width(24)
              .onClick(()=>{
                promptAction.showToast({
                  message:'功能开发中'
                })
              })
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height($r("app.string.header_height")).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween)
        List({ space: 12 }) {
          ListItem() {
            Image($r("app.media.app_icon"))
              .width('30%')
              .aspectRatio(1)
              .margin({
                left: '35%',
                right: '35%',
                top: '10%',
                bottom: '10%'
              })
          }
          .align(Alignment.Center)


          ListItemGroup({ header: this.itemHead('关于') ,space:8}) {
            ListItem() {
              this.SettingItem(aboutUs)
            }
              ListItem() {
                this.SettingItem(contactUs)
              }
            }

          ListItemGroup({ header: this.itemHead('通用') ,space:8}) {
            ListItem() {
              this.SettingItem(options)
            }
          }

          ListItemGroup({ header: this.itemHead('声明'),space:8 }) {
            ListItem() {
              this.SettingItem(privacyPolicy)
            }
            ListItem() {
              this.SettingItem(copyRight)
            }
            ListItem() {
              this.SettingItem(illustrate)
            }
          }

          ListItemGroup({ header: this.itemHead('更多'),space:8 }) {
            ListItem() {
              this.SettingItem(addOil)
            }
          }

        }
        .padding({left:12,right:12})
        .width("100%")
        .height('100%')
        //.margin({ top: 12 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .mode(NavigationMode.Auto)
      .navDestination(this.PageMap)
      .minContentWidth('420vp')
      .backButtonIcon($r("app.media.func_back"))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

// PageOne.ets
@Component
export struct AboutUsView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
          AboutUs().width('100%').height('100%')
    }.title("开发者团队")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}

// Agreement.ets
@Component
export struct  IllustrateView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      Illustrate().width('100%').height('100%')
    }.title("用户协议")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}
// CopyRight.ets
@Component
export struct CopyRightView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      CopyRight().width('100%').height('100%')
    }.title("版权声明")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}
// Options.ets
@Component
export struct OptionsView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      Options().width('100%').height('100%')
    }.title(options.title)
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}
// Options.ets
@Component
export struct PrivacyPolicyView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      PrivacyPolicy().width('100%').height('100%')
    }.title(privacyPolicy.title).width("100%")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}
// AddOils.ets
@Component
export struct AddOilView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      AddOil().width('100%').height('100%')
    }.title(addOil.title)
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}
// ContactUs.ets
@Component
export struct  ContactUsView {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      ContactUs().width('100%').height('100%')
    }.title( contactUs.title)
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