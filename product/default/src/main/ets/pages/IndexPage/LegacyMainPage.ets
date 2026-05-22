/**
 * LegacyMainPage — API < 23 的传统 Tabs 模式
 * 包含实色 Header + 底部固定 Tabs 导航
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

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Component
export struct LegacyMainPage {
  @State currentIndex: number = 0
  @State titles: Array<Resource> =
    [$r("app.string.page_name1"), $r("app.string.page_name2"), $r("app.string.page_name3"), $r("app.string.page_name4")]
  @State title: Resource = this.titles[0]
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  private tabsController: TabsController = new TabsController()
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @StorageProp('navIndicatorHeight') navIndicatorHeight: number = 0
  aboutToAppear() {
    this.tabsController.changeIndex(this.currentIndex)
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
      this.tabsController.changeIndex(targetIndex)
    })
  }

  build() {
    Column() {
      // ========== Header 区域（实色背景） ==========
      GridRow({ columns: 12 }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.link_myApp")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            let want: Want = {
              deviceId: '',
              bundleName: 'com.atomicservice.5765880207854873613',
              abilityName: 'EntryAbility',
              moduleName: "entry"
            }
            promptAction.showToast({ message: `正在尝试打开随易元服务` })
            let context = getContext(this) as common.UIAbilityContext
            context.startAbility(want, (err: BusinessError) => {
              if (err.code) {
                console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`)
                promptAction.showToast({ message: `尝试打开应用商店` })
                const storeWant: Want = {
                  uri: `store://appgallery.huawei.com/app/detail?id=com.atomicservice.5765880207854873613`
                }
                context.startAbility(storeWant).then(() => {
                }).catch(() => {
                  const wantParam: Want = {
                    parameters: { bundleName: 'com.atomicservice.5765880207854873613' }
                  }
                  const callback: productViewManager.ProductViewCallback = {
                    onError: (error: BusinessError) => {
                      hilog.error(0x0001, 'TAG', `loadService onError.code is ${error.code}, message is ${error.message}`)
                      promptAction.showToast({ message: '跳转失败' })
                    }
                  }
                  productViewManager.loadProduct(context, wantParam, callback)
                })
              }
            })
          })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text(this.title).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SettingPage/SettingPage',
              params: new Params('aboutus')
            }).then(() => {
              console.info("success.")
            }).catch((err: BusinessError) => {
              console.error(`err, code is ${err.code}, message is ${err.message}.`)
            })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        }
      }
      .width('100%')
      .height($r("app.float.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .position({ top: $r("app.float.header_margin") })

      // ========== 传统 Tabs 导航 ==========
      Tabs({
        barPosition: BarPosition.End,
        index: 0,
        controller: this.tabsController
      }) {
        TabContent() {
          RollPage()
        }
        .padding({ top: $r("app.float.header_height") }).backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name1'), 0, $r('app.media.page_icon1_selected'),
          $r('app.media.page_icon1')))

        TabContent() {
          AnswerPage()
        }
        .padding({ top: $r("app.float.header_height") }).backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name3'), 1, $r('app.media.page_icon3_selected'),
          $r('app.media.page_icon3')))

        TabContent() {
          TollsPage()
        }
        .padding({ top: $r("app.float.header_height") }).backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name4'), 2, $r('app.media.page_icon4_selected'),
          $r('app.media.page_icon4')))

        TabContent() {
          AllasOne()
        }
        .padding({ top: $r("app.float.header_height") }).backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name2'), 3, $r('app.media.page_icon2_selected'),
          $r('app.media.page_icon2')))
      }
      .onChange((index: number) => {
        this.title = this.titles[index]
      })
      .scrollable(false)
      .vertical(false)
      .divider({
        strokeWidth: 0.8,
        color: $r("app.color.FontIcon_Fore4")
      })

      .backgroundColor($r("app.color.Comp_Bg1"))
      .padding({ top: $r("app.float.header_margin"), bottom: $r("app.float.footer_margin") })
      .barHeight(56)
    }.width('100%').height('100%')      .padding({ top: this.statusBarHeight, bottom: this.navIndicatorHeight })
  }
}
