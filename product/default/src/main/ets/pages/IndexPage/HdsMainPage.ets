/**
 * HdsMainPage — API >= 23 的 HdsTabs 悬浮导航模式
 * 包含半透明 Header + HdsTabs 悬浮页签
 */
import RollPage from '../RollPage/RollWheelPage'
import AnswerPage from '../AnswerPage'
import AllasOne from '../AllasOne'
import TollsPage from '../ToolsPage'
import router from '@ohos.router'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { BreakpointState, BreakpointSystem } from '@ohos/common'
import { productViewManager } from '@kit.StoreKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import type { common, Want } from '@kit.AbilityKit'
import { HdsTabs, HdsTabsController, hdsMaterial } from '@kit.UIDesignKit'

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Component
export struct HdsMainPage {
  @State currentIndex: number = 0
  @State titles: Array<Resource> =
    [$r("app.string.page_name1"), $r("app.string.page_name2"), $r("app.string.page_name3"), $r("app.string.page_name4")]
  @State title: Resource = this.titles[0]
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  private hdsController: HdsTabsController = new HdsTabsController()

  aboutToAppear() {
    this.hdsController.changeIndex(this.currentIndex)
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  tabBarBuilder(
    title: Resource,
    targetIndex: number,
    selectedIcon: Resource,
    unselectIcon: Resource,
  ) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedIcon : unselectIcon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === targetIndex ? $r("app.color.Brand") : $r("app.color.FontIcon_Fore2"))
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? $r("app.color.Brand") : $r("app.color.FontIcon_Fore2"))
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex
      this.hdsController.changeIndex(targetIndex)
    })
  }

  build() {
    // Column() {
    //   // ========== Header 区域（半透明背景，融入悬浮光感） ==========
    //
    //       Row() {
    //         Image($r("app.media.link_myApp")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
    //       }
    //       .onClick(() => {
    //         let want: Want = {
    //           deviceId: '',
    //           bundleName: 'com.atomicservice.5765880207854873613',
    //           abilityName: 'EntryAbility',
    //           moduleName: "entry"
    //         }
    //         promptAction.showToast({ message: `正在尝试打开随易元服务` })
    //         let context = getContext(this) as common.UIAbilityContext
    //         context.startAbility(want, (err: BusinessError) => {
    //           if (err.code) {
    //             console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`)
    //             promptAction.showToast({ message: `尝试打开应用商店` })
    //             const storeWant: Want = {
    //               uri: `store://appgallery.huawei.com/app/detail?id=com.atomicservice.5765880207854873613`
    //             }
    //             context.startAbility(storeWant).then(() => {
    //             }).catch(() => {
    //               const wantParam: Want = {
    //                 parameters: { bundleName: 'com.atomicservice.5765880207854873613' }
    //               }
    //               const callback: productViewManager.ProductViewCallback = {
    //                 onError: (error: BusinessError) => {
    //                   hilog.error(0x0001, 'TAG', `loadService onError.code is ${error.code}, message is ${error.message}`)
    //                   promptAction.showToast({ message: '跳转失败' })
    //                 }
    //               }
    //               productViewManager.loadProduct(context, wantParam, callback)
    //             })
    //           }
    //         })
    //       })
    //       .width('100%')
    //       .height($r("app.float.header_height"))
    //       .justifyContent(FlexAlign.Start)
    //       .alignItems(VerticalAlign.Center)
    //       .padding({ left: 12 })
    //
    //
    //       Row() {
    //         Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
    //       }
    //       .width('100%')
    //       .height($r("app.float.header_height"))
    //       .justifyContent(FlexAlign.End)
    //       .alignItems(VerticalAlign.Center)
    //       .padding({ right: 12 })
    //       .onClick(() => {
    //         router.pushUrl({
    //           url: 'pages/SettingPage/SettingPage',
    //           params: new Params('aboutus')
    //         }).then(() => {
    //           console.info("success.")
    //         }).catch((err: BusinessError) => {
    //           console.error(`err, code is ${err.code}, message is ${err.message}.`)
    //         })
    //       })
    //       .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
    //


      // ========== HdsTabs 悬浮导航 ==========
      HdsTabs({
        controller: this.hdsController,
        index: 0,
        barPosition: BarPosition.End
      }) {
        TabContent() {
          RollPage()        .height('100%')
        }
        // .padding({ top: $r("app.float.header_height"), bottom: 100 })
        .height('100%')
        .backgroundColor($r("app.color.Comp_Bg2"))
        .borderWidth(5)
        .borderColor(Color.Orange)
        .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP,LayoutSafeAreaEdge.BOTTOM,])
        .tabBar(this.tabBarBuilder($r('app.string.page_name1'), 0, $r('app.media.page_icon1_selected'),
          $r('app.media.page_icon1')))

        TabContent() {
          AnswerPage()
        }
        // .padding({ top: $r("app.float.header_height"), bottom: 100 })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .borderWidth(5)
        .borderColor(Color.Orange)
        .tabBar(this.tabBarBuilder($r('app.string.page_name3'), 1, $r('app.media.page_icon3_selected'),
          $r('app.media.page_icon3')))

        TabContent() {
          TollsPage()
        }
        // .padding({ top: $r("app.float.header_height"), bottom: 100 })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name4'), 2, $r('app.media.page_icon4_selected'),
          $r('app.media.page_icon4')))

        TabContent() {
          AllasOne()
        }
        // .padding({ top: $r("app.float.header_height"), bottom: 100 })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name2'), 3, $r('app.media.page_icon2_selected'),
          $r('app.media.page_icon2')))
      }
      .onChange((index: number) => {
        this.title = this.titles[index]
      })
      .scrollable(false)
      .vertical(false)
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .barFloatingStyle({
        // barBottomMargin: 10,
        // gradientMask: {
        //   maskColor: '#99FFFFFF',
        //   maskHeight: 120
        // },
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      })
      .animationDuration(0)
      .borderWidth(5)
      .borderColor(Color.Red)
      .width('100%').height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      // .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP,LayoutSafeAreaEdge.BOTTOM,])  // 设置布局区域延伸取左和上方向，至系统避让区SYSTEM

    // .backgroundColor($r("app.color.Comp_Bg1"))
    // }.width('100%').height('100%')      .borderWidth(5)
    // .borderColor(Color.Green)
  }
}
