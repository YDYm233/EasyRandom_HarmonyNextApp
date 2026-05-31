/**
 * LegacyMainPage — API < 23 的传统 Tabs 模式
 * 包含实色 Header + 底部固定 Tabs 导航
 */
import RollPage from '../RollPage/RollWheelPage'
import AnswerPage from '../AnswerPage'
import AllasOne from '../CardsPage'
import TollsPage from '../ToolsPage'
import router from '@ohos.router'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction, curves } from '@kit.ArkUI'
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
  // Header 悬浮按钮按压动效
  @State linkBtnScale: number = 1.0
  @State settingBtnScale: number = 1.0
  @State linkBtnGlow: number = 0
  @State settingBtnGlow: number = 0
  @State tabTrigger: number = -1
  @State tabPressTarget: number = -1
  @State tabPressScale: number = 1.0
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
      SymbolGlyph(this.currentIndex === targetIndex ? selectedIcon : unselectIcon)
        .fontSize(24)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .fontColor([this.currentIndex === targetIndex
          ? $r('app.color.Brand')
          : $r('app.color.FontIcon_Fore3')])
        .symbolEffect(
          new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP),
          this.tabTrigger === targetIndex ? this.tabTrigger : -1
        )
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
    .scale({
      x: this.tabPressTarget === targetIndex ? this.tabPressScale : 1.0,
      y: this.tabPressTarget === targetIndex ? this.tabPressScale : 1.0
    })
    .onClick(() => {
      if (this.currentIndex !== targetIndex) {
        this.tabsController.changeIndex(targetIndex)
        this.tabPressTarget = targetIndex
        this.tabPressScale = 0.85
        animateTo({ duration: 250, curve: curves.springMotion(0.35, 0.75) }, () => {
          this.currentIndex = targetIndex
          this.tabTrigger = targetIndex
          this.tabPressScale = 1.0
        })
      }
    })
  }

  build() {
    Column() {
      // ========== Header 区域（实色背景） ==========
      GridRow({ columns: 12 }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Button() {
              SymbolGlyph($r('sys.symbol.link'))
                .fontSize(20)
                .fontColor([$r('app.color.FontIcon_Fore1')])
            }
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('rgba(255,255,255,0.15)')
            .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
            .shadow({
              radius: 8 * this.linkBtnGlow,
              color: 'rgba(255,255,255,0.6)',
              offsetX: 0,
              offsetY: 0
            })
            .scale({ x: this.linkBtnScale, y: this.linkBtnScale })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
                  this.linkBtnScale = 0.88
                  this.linkBtnGlow = 1
                })
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                animateTo({ duration: 350, curve: curves.springMotion(0.5, 0.8) }, () => {
                  this.linkBtnScale = 1.0
                  this.linkBtnGlow = 0
                })
              }
            })
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
                        hilog.error(0x0001, 'TAG',
                          `loadService onError.code is ${error.code}, message is ${error.message}`)
                        promptAction.showToast({ message: '跳转失败' })
                      }
                    }
                    productViewManager.loadProduct(context, wantParam, callback)
                  })
                }
              })
            })
          }
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
            Button() {
              SymbolGlyph($r('sys.symbol.gearshape'))
                .fontSize(20)
                .fontColor([$r('app.color.FontIcon_Fore1')])
            }
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('rgba(255,255,255,0.15)')
            .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
            .shadow({
              radius: 8 * this.settingBtnGlow,
              color: 'rgba(255,255,255,0.6)',
              offsetX: 0,
              offsetY: 0
            })
            .scale({ x: this.settingBtnScale, y: this.settingBtnScale })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
                  this.settingBtnScale = 0.88
                  this.settingBtnGlow = 1
                })
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                animateTo({ duration: 350, curve: curves.springMotion(0.5, 0.8) }, () => {
                  this.settingBtnScale = 1.0
                  this.settingBtnGlow = 0
                })
              }
            })
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
          }
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
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
        // .padding({ top: $r("app.float.header_height") })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name1'), 0, $r('sys.symbol.puzzle_fill'),
          $r('sys.symbol.puzzle_fill')))

        TabContent() {
          AnswerPage()
        }
        // .padding({ top: $r("app.float.header_height") })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name3'), 1, $r('sys.symbol.book_pages_fill'),
          $r('sys.symbol.book_pages_fill')))

        TabContent() {
          TollsPage()
        }
        // .padding({ top: $r("app.float.header_height") })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name4'), 2, $r('sys.symbol.briefcase_fill'),
          $r('sys.symbol.briefcase_fill')))

        TabContent() {
          AllasOne()
        }
        // .padding({ top: $r("app.float.header_height") })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name2'), 3, $r('sys.symbol.rectangle_on_rectangle_fill'),
          $r('sys.symbol.rectangle_on_rectangle_fill')))
      }
      .onAnimationStart((index: number, targetIndex: number) => {
        this.title = this.titles[targetIndex]
      })
      .scrollable(false)
      .vertical(false)
      .barOverlap(true)
      .backgroundColor($r("app.color.Comp_Bg1"))

      .divider({
        strokeWidth: 0.8,
        color: $r("app.color.FontIcon_Fore4")
      })
.barBackgroundColor($r("app.color.Comp_Bg1"))
      .barBackgroundBlurStyle(BlurStyle.NONE)
      .backgroundColor($r("app.color.Comp_Bg1"))
      // .padding({ top: $r("app.float.header_margin"), bottom: $r("app.float.footer_margin") })
      .barHeight(56)
    }.width('100%').height('100%')
    .padding({ top: this.statusBarHeight, bottom: this.navIndicatorHeight })

  }
}
