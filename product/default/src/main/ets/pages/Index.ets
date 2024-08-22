import RandomPage from './RandomPage'
import RollPage from './RollPage/RollPage'
import MorePage from './MorePage'
import AnswerPage from './AnswerPage'
import router from '@ohos.router'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { BreakpointState, BreakpointSystem } from '@ohos/common'
import { webview } from '@kit.ArkWeb'
import { preferences } from '@kit.ArkData'
import CommonConstants from '../constants/CommonConstants'
import { GlobalContext } from '../constants/GlobalContext'
import Logger from '../constants/Logger'

@Entry({ routeName: 'Index' })
@Component
struct TabBar {
  @State customDialogId: number = 0
  @State currentIndex: number = 0;
  @State isWrap: boolean = true
  @State isFirst: string = '首次'
  @State titles: Array<Resource> =
    [$r("app.string.page_name1"), $r("app.string.page_name2"), $r("app.string.page_name3"), $r("app.string.page_name4")]
  @State title: Resource = this.titles[0]
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  controller: webview.WebviewController = new webview.WebviewController();
  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  PrivacyPolicyDialog() {
    Column() {
      Row() {
        Web({ src: $rawfile("privacypolicy.html"), controller: this.controller }).width("100%")
      }.width('100%').height('80%')

      Row() {
        Hyperlink('http://www.m233.top/easyrandom/privacypolicy.html', '点击查看详细信息') {
        }.width('100%')
      }.width('100%').height('8%')
      .justifyContent(FlexAlign.Center)

      Row() {
        Button('拒绝')
          .height('80%')
          .aspectRatio(2)
          .backgroundColor($r("app.color.warning"))
          .fontColor($r("app.color.control_fc_1"))
          .onClick(() => {
            promptAction.closeCustomDialog(this.customDialogId)
            promptAction.showToast({
              message: '您可前往 设置>隐私政策 查看详情'
            })
          })
        Button('同意')
          .height('80%')
          .aspectRatio(2)
          .backgroundColor($r("app.color.control_bgc_1"))
          .fontColor($r("app.color.control_fc_1"))
          .onClick(() => {
            this.saveIsPrivacy()
            promptAction.showToast({
              message: '您可前往 设置>隐私政策 查看详情'
            })
            promptAction.closeCustomDialog(this.customDialogId)
          })
      }
      .width('100%')
      .height('12%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: '10%', right: '10%' })
    }.padding(12)
  }

  getDataPreferences(common: Object) {
    return preferences.getPreferences(getContext(common), CommonConstants.PREFERENCES_FILE_NAME);
  }

  saveIsPrivacy() {
    let preferences: Promise<preferences.Preferences> = this.getDataPreferences(this);
    preferences.then((result: preferences.Preferences) => {
      let privacyPut = result.put(CommonConstants.PREFERENCES_KEY_PRIVACY, false);
      result.flush();
      privacyPut.then(() => {
        Logger.info(CommonConstants.LAUNCHER_PAGE_TAG, 'Put the value of startup Successfully.');
      }).catch((err: Error) => {
        Logger.error(CommonConstants.LAUNCHER_PAGE_TAG, 'Put the value of startup Failed, err: ' + err);
      });
    }).catch((err: Error) => {
      Logger.error(CommonConstants.LAUNCHER_PAGE_TAG, 'Get the preferences Failed, err: ' + err);
    });
  }

  onPageShow(): void {
    this.getDataPreferences(this).then((preferences: preferences.Preferences) => {
      // 获取隐私协议状态值
      preferences.get(CommonConstants.PREFERENCES_KEY_PRIVACY, true)
        .then((value: preferences.ValueType) => {
          Logger.info(CommonConstants.LAUNCHER_PAGE_TAG, 'onPageShow value: ' + value);
          if (value) {
            let isJumpPrivacy: boolean = (GlobalContext.getContext()
              .getObject('isJumpPrivacy') as boolean) ?? false;
            if (!isJumpPrivacy) {
              promptAction.openCustomDialog({
                builder: () => {
                  this.PrivacyPolicyDialog()
                },
                showInSubWindow: false,
                offset: { dx: 0, dy: 5 },
                backgroundColor: 0xd9ffffff,
                cornerRadius: 24,
                backgroundBlurStyle: BlurStyle.Regular,
                width: 320,
                height: 500,

              }).then((dialogId: number) => {
                this.customDialogId = dialogId
              })
            }
          } else {
            this.isFirst = '非首次'
            console.log('非首次')
          }
        });
    });

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
        .fillColor(this.currentIndex === targetIndex ? 0x00beff : 'rgba(0,0,0,0.6)')
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? 0x00beff : 'rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
    }
    // .border({ width: 1, color: '#ff0000', style: BorderStyle.Dotted })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })

  }

  build() {
    //头部内容显示
    Column() {
      GridRow() {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            // Image($r("app.media.func_back")).height('24vp').width('24vp')
            //Text(this.isFirst)
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text(this.title)
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24)
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SettingPage/SettingPage'
            }).then(() => {
              console.info("success.");
            }).catch((err: BusinessError) => {
              console.error(`err, code is ${err.code}, message is ${err.message}.`);
            })
          })
        }
      }
      .width('100%')
      .height($r("app.string.header_height"))
      .backgroundColor($r("app.color.view_bgc_1"))
      .zIndex(10)
      .margin({ top: $r("app.string.header_margin") })
      .position({ top: $r("app.string.header_margin") })

      //导航

      Tabs({
        barPosition: BarPosition.End,
        index: 0,
        controller: this.tabsController
      }) {

        TabContent() {
          RollPage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name1'), 0, $r('app.media.page_icon1_selected'),
          $r('app.media.page_icon1')));

        TabContent() {
          RandomPage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name2'), 1, $r('app.media.page_icon2_selected'),
          $r('app.media.page_icon2')));

        TabContent() {
          AnswerPage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name3'), 2, $r('app.media.page_icon3_selected'),
          $r('app.media.page_icon3')));

        TabContent() {
          MorePage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name4'), 3, $r('app.media.page_icon4_selected'),
          $r('app.media.page_icon4')));
      }
      .onChange((index: number) => {
        this.title = this.titles[index]
      })
      .scrollable(false)
      .vertical(false)
      .divider({
        strokeWidth: 0.8,
        color: '#0D182431'
      })
      .backgroundColor($r("app.color.view_bgc_1"))
      .padding({ top: $r("app.string.header_margin"), bottom: $r("app.string.footer_margin") })
      .barHeight(56)
    }

  }
}



