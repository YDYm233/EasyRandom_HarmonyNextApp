import router from '@ohos.router';
import { AboutUs } from './AboutUs';
import { ContactUs } from './ContactUs';
import { Options } from './Options';
import { PrivacyPolicy } from './PrivacyPolicy';
import { Illustrate } from './MoreOpt';
import { CopyRight } from './CopyRight';
import { AnnouncementPage } from './AnnouncementPage';
import { promptAction } from '@kit.ArkUI';
import { BreakpointState, BreakpointSystem } from '@ohos/system-utils';
import { resourceManager } from '@kit.LocalizationKit';

// ============ 类型定义 ============

/**
 * 设置页面类型枚举
 * 用于定义从外部跳转到设置页时的目标页面
 */
enum SettingPageType {
  DEFAULT = 'default',           // 默认（不指定页面）
  PRIVATE_POLICY = 'privatepolicy', // 隐私政策
  ABOUT_US = 'aboutus',          // 开发者团队
  ANNOUNCEMENT = 'announcement',  // 公告与功能
  OPTIONS='options'
}

/**
 * 设置页面参数类
 * 提供类型安全的参数解析
 */
class SettingParams {
  type: SettingPageType = SettingPageType.DEFAULT
  
  constructor(type: string = '') {
    if (type && Object.values(SettingPageType).includes(type as SettingPageType)) {
      this.type = type as SettingPageType
    }
  }
}

/**
 * 路由参数类（用于类型转换）
 */
class Params {
  type: string = ''
  constructor(tuple?: string) {
    if (tuple) {
      this.type = tuple
    }
  }
}

/**
 * 设置页面路由策略类
 * 根据参数和断点状态决定初始显示的页面
 */
class SettingPageStrategy {
  /**
   * 获取初始页面名称
   * @param params 页面参数
   * @param breakpoint 当前断点值
   * @returns 页面名称，空字符串表示不预加载子页面
   */
  static getInitialPage(params: SettingParams, breakpoint: string): string {
    // 策略1：隐私政策
    if (params.type === SettingPageType.PRIVATE_POLICY) {
      return '隐私政策'
    }
    
    // 策略2：公告页面
    if (params.type === SettingPageType.ANNOUNCEMENT) {
      return '公告与功能'
    }
    
    // 策略3：开发者团队
    if (params.type === SettingPageType.ABOUT_US) {
      return '开发者团队'
    }
    
    // 策略4：无参/参数无效时的处理
    if (breakpoint === 'sm') {
      // sm设备：显示主设置页
      return ''
    } else {
      // 非sm设备：显示公告页
      return '通用设置'
    }
  }
}

// ============ 菜单项定义 ============

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
let announcement = new Item('公告与功能', $r("app.media.illustrate"), 0x00BEFF)

// ============ 主组件 ============

@Entry({ routeName: 'Setting' })
@Component
struct Setting {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State appInfoText: string = 'App'

  onPageShow(): void {
  }

  /**
   * 页面初始化生命周期
   * 优化后的逻辑：
   * 1. 先初始化断点系统
   * 2. 类型安全地解析参数
   * 3. 使用策略模式决定初始页面
   * 4. 加载应用信息
   */
  aboutToAppear() {
    // 步骤1：初始化断点系统（优先执行）
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
    
    // 步骤2：解析路由参数（类型安全）
    const routerParams = router.getParams() as Params
    const paramType: string = (routerParams && routerParams.type) ? routerParams.type : ''
    const params = new SettingParams(paramType)
    
    // 步骤3：使用策略决定初始页面
    const breakpoint = this.currentBreakpoint.value || 'sm'
    const initialPage = SettingPageStrategy.getInitialPage(
      params, 
      breakpoint
    )
    
    // 步骤4：压入初始页面到导航栈
    if (initialPage) {
      this.pageInfos.pushPath({ name: initialPage })
      console.info(`[SettingPage] 初始页面: ${initialPage}, 参数类型: ${params.type}, 断点: ${this.currentBreakpoint.value}`)
    } else {
      console.info(`[SettingPage] 显示主设置页, 参数类型: ${params.type}, 断点: ${this.currentBreakpoint.value}`)
    }
    
    // 步骤5：加载应用信息
    this.loadAppInfo()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  /**
   * 加载应用信息
   * 提取为独立方法，提高可读性
   */
  private loadAppInfo(): void {
    const resMgr = getContext(this).resourceManager
    this.appInfoText = resMgr.getStringSync($r('app.string.app_name').id)
      + resMgr.getStringSync($r('app.string.app_version').id)
  }

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
      console.info(`[SettingPage] 打开页面: ${item.title}`)
    })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
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
            router.back({ url: 'pages/IndexPage/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })

          Row() {
            Text('设置').height(24).fontWeight(800).textAlign(TextAlign.Center).fontColor($r("app.color.FontIcon_Fore1"))
          }.height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

          Row() {
          //   Image($r("app.media.func_share")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          //
          // } .onClick(() => {
          //   promptAction.showToast({
          //     message: '功能开发中'
          //   })
          }
          // .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .height('100%').aspectRatio(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(56)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r("app.color.Comp_Bg1"))

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
                  .fontSize(16)
                  .fontColor($r("app.color.FontIcon_Fore1"))
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
              this.SettingItem(announcement)
            }
            ListItem() {
              this.SettingItem(aboutUs)
            }
            ListItem() {
              this.SettingItem(privacyPolicy)
            }
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r("app.color.Comp_Bg3"))
    }
    .padding({ top: this.statusBarHeight })
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg1"))
    .mode(NavigationMode.Auto)
    .hideTitleBar(true)
    .hideToolBar(true)
    .minContentWidth('420vp')
    .backButtonIcon(this.currentBreakpoint.value=='sm'?$r("app.media.func_back"):null)
  }
}

export default Setting
