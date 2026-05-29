/**
 * HdsMainPage — API >= 23 的 HdsTabs 悬浮导航模式
 * 包含沉浸光感悬浮按钮（带动效） + HdsTabs 悬浮页签（匹配合适 Symbol）
 */
import RollPage from '../RollPage/RollWheelPage'
import AnswerPage from '../AnswerPage'
import AllasOne from '../AllasOne'
import TollsPage from '../ToolsPage'
import router from '@ohos.router'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction, SymbolGlyphModifier, curves } from '@kit.ArkUI'
import { BreakpointState, BreakpointSystem } from '@ohos/common'
import { productViewManager } from '@kit.StoreKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import type { common, Want } from '@kit.AbilityKit'
import { HdsTabs, HdsTabsController, hdsMaterial } from '@kit.UIDesignKit'

interface TabSymbolConfig {
  normal: SymbolGlyphModifier
  selected: SymbolGlyphModifier
}

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Component
export struct HdsMainPage {
  @State currentIndex: number = 0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  private hdsController: HdsTabsController = new HdsTabsController()
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @StorageProp('navIndicatorHeight') navIndicatorHeight: number = 0

  // 设备材质等级
  @State customMaterialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE

  // 悬浮按钮按压动效缩放
  @State linkBtnScale: number = 1.0
  @State settingBtnScale: number = 1.0
  // 悬浮按钮按压光晕
  @State linkBtnGlow: number = 0
  @State settingBtnGlow: number = 0

  // 页签图标：按各 Tab 语义匹配系统 Symbol
  // Tab0 → RollPage（随机/轮盘）  → repeat
  // Tab1 → AnswerPage（问答）     → questionmark_circle
  // Tab2 → TollsPage（工具）      → gearshape
  // Tab3 → AllasOne（全部/收藏）  → heart
  private tabSymbols: TabSymbolConfig[] = [
    {
      normal: new SymbolGlyphModifier($r('sys.symbol.puzzle'))
        .fontColor([$r('sys.color.ohos_id_color_bottom_tab_icon_off')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Normal),
      selected: new SymbolGlyphModifier($r('sys.symbol.puzzle_fill'))
        .fontColor([$r('sys.color.ohos_id_color_activated')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Bold)
    },
    {
      normal: new SymbolGlyphModifier($r('sys.symbol.book_pages_fill'))
        .fontColor([$r('sys.color.ohos_id_color_bottom_tab_icon_off')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Normal),
      selected: new SymbolGlyphModifier($r('sys.symbol.book_open_fill'))
        .fontColor([$r('sys.color.ohos_id_color_activated')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Bold)
    },
    {
      normal: new SymbolGlyphModifier($r('sys.symbol.briefcase'))
        .fontColor([$r('sys.color.ohos_id_color_bottom_tab_icon_off')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Normal),
      selected: new SymbolGlyphModifier($r('sys.symbol.briefcase_fill'))
        .fontColor([$r('sys.color.ohos_id_color_activated')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Bold)
    },
    {
      normal: new SymbolGlyphModifier($r('sys.symbol.rectangle_on_rectangle'))
        .fontColor([$r('sys.color.ohos_id_color_bottom_tab_icon_off')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Normal),
      selected: new SymbolGlyphModifier($r('sys.symbol.rectangle_on_rectangle_fill'))
        .fontColor([$r('sys.color.ohos_id_color_activated')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontWeight(FontWeight.Bold)
    }
  ]

  aboutToAppear() {
    this.hdsController.changeIndex(this.currentIndex)
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()

    let materialTypes: Array<hdsMaterial.MaterialType> = hdsMaterial.getSystemMaterialTypes()
    if (materialTypes.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
      this.customMaterialLevel = hdsMaterial.MaterialLevel.SMOOTH
    }
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        // Row().height(this.navIndicatorHeight).width('100%').border({ color: Color.Red, width: 3 }).backgroundColor(Color.Transparent)
        HdsTabs({
          controller: this.hdsController,
          index: 0,
          barPosition: BarPosition.End
        }) {
          TabContent() {
            RollPage().height('100%')
          }
          .height('100%')
          // .padding({ top:this.navIndicatorHeight,bottom: this.statusBarHeight})
          .tabBar(new BottomTabBarStyle({
            normal: this.tabSymbols[0].normal,
            selected: this.tabSymbols[0].selected
          }, $r('app.string.page_name1')))
          .backgroundColor(Color.Transparent)


          TabContent() {
            AnswerPage().height('100%')
          }
          .height('100%')
          // .padding({ top:this.navIndicatorHeight,bottom: this.statusBarHeight})
          .tabBar(new BottomTabBarStyle({
            normal: this.tabSymbols[1].normal,
            selected: this.tabSymbols[1].selected
          }, $r('app.string.page_name3')))
          .backgroundColor(Color.Transparent)


          TabContent() {
            TollsPage().height('100%')
          }
          .height('100%')
          // .padding({ top:this.navIndicatorHeight,bottom: this.statusBarHeight})
          .tabBar(new BottomTabBarStyle({
            normal: this.tabSymbols[2].normal,
            selected: this.tabSymbols[2].selected
          }, $r('app.string.page_name4')))
          // .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
          // .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
          // .backgroundColor(Color.Transparent)
          .backgroundColor(Color.Transparent)


          TabContent() {
            AllasOne().height('100%')
          }
          .height('100%')
          // .padding({ top:this.navIndicatorHeight,bottom: this.statusBarHeight})
          .tabBar(new BottomTabBarStyle({
            normal: this.tabSymbols[3].normal,
            selected: this.tabSymbols[3].selected
          }, $r('app.string.page_name2')))
          .backgroundColor(Color.Transparent)

        }
        // .border({width:3,color:Color.Red})
        // .backgroundColor($r('app.color.Harmony'))
        // .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
        .onChange((index: number) => {
          this.currentIndex = index
        })
        .scrollable(false)
        .vertical(false)
        .barOverlap(true)
        .barPosition(BarPosition.End)
        .barFloatingStyle({
          barBottomMargin: this.statusBarHeight,
          barWidth: { smallWidth: 300, mediumWidth: 360, largeWidth: 400 },
          // gradientMask: { maskColor: '#99FFFFFF', maskHeight: 100 },
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.ADAPTIVE,
            materialLevel: this.customMaterialLevel
          }
        })
        .animationDuration(300)

        // .height('100%')
        // .width('100%')
        // .backgroundColor(Color.Transparent)
        // .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
        // .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
        // .height(LayoutPolicy.matchParent)
        // .padding({bottom:this.statusBarHeight})
      }.backgroundColor(Color.Transparent)
      // ========== 右上方沉浸光感悬浮按钮（按压动效 + 光感材质）==========
      Row({ space: 8 }) {
        // 按钮1：打开随易元服务
        Button() {
          SymbolGlyph($r('sys.symbol.link'))
            .fontSize(20)
            .fontColor([$r('app.color.FontIcon_Fore1')])
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor(this.customMaterialLevel === hdsMaterial.MaterialLevel.SMOOTH ?
          'rgba(255,255,255,0.5)' : 'rgba(255,255,255,0.15)')
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

        // 按钮2：打开设置页
        Button() {
          SymbolGlyph($r('sys.symbol.gearshape'))
            .fontSize(20)
            .fontColor([$r('app.color.FontIcon_Fore1')])
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor(this.customMaterialLevel === hdsMaterial.MaterialLevel.SMOOTH ?
          'rgba(255,255,255,0.5)' : 'rgba(255,255,255,0.15)')
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
      .margin({ top: this.statusBarHeight + 8, right: 12 })
    }
    // .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    // .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    // .padding({bottom:this.statusBarHeight})
    .backgroundColor(Color.Transparent)
  }
}
