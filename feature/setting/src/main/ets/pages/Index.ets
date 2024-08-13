import router from '@ohos.router';
import AboutUs from '../components/AboutUs'
import Options from '../components/Options'
import PrivacyPolicy from '../components/PrivacyPolicy'
import Agreement from '../components/Agreement'
import CopyRight from '../components/CopyRight'
class Item{
  title:string
  icon:Resource
  constructor(title:string,icon:Resource) {
    this.title=title
    this.icon=icon
  }
}
let aboutUs = new Item('开发者团队',$r("app.media.page_icon3"))
let options = new Item('通用设置',$r("app.media.page_icon3"))
let privacyPolicy = new Item('隐私政策',$r("app.media.page_icon3"))
let agreement = new Item('用户协议',$r("app.media.page_icon3"))
let copyRight = new Item('版权声明',$r("app.media.page_icon3"))
let donateUs = new Item('赞赏我们',$r("app.media.page_icon3"))
@Entry({ routeName: 'Setting' })
@Component
struct Setting {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
       if (name === "通用设置") {
      Options()
    } else if (name === "隐私政策") {
      PrivacyPolicy()
    }  else if (name === "用户协议") {
         Agreement()
       }else if (name === "版权声明") {
         CopyRight()
       }else if (name === "赞赏我们") {

       }
       else{
         AboutUs()
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
      Image(item.icon)
        .aspectRatio(1)
        .height('40%')
    Text( item.title)
    .width("80%")
    .height('100%')
    .fontSize(16)
    .fontWeight(500)
    .textAlign(TextAlign.End)
    .onClick(()=>{
      this.pageInfos.pushPath({ name:  item.title})
    })
}.width('100%')       .height(72)    .borderRadius(24).padding({left:24,right:24})
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
          ListItem() {
           Image($r("app.media.app_icon")).width('30%').aspectRatio(1).margin({left:'35%',right:'35%',top:'10%',bottom:'10%'})
          }
          .align(Alignment.Center)

            ListItem() {
              this.SettingItem(aboutUs)
            }

          ListItemGroup({ header: this.itemHead('通用')}) {
            ListItem() {
              this.SettingItem(options)
            }
            }

          ListItemGroup({ header: this.itemHead('关于')}) {
            ListItem() {
              this.SettingItem(privacyPolicy)
            }
            ListItem() {
              this.SettingItem(agreement)
            }
            ListItem() {
              this.SettingItem(copyRight)
            }
          }

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