/**
 * Index — 应用入口
 *   当前 target API 12，默认加载 LegacyMainPage（传统 Tabs）
 *   待项目升级至 API 23+ 后，切换到 HdsMainPage（HdsTabs 悬浮导航 + 半透明 Header）
 */
import router from '@ohos.router'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { CommonConstants, GlobalContext, Logger } from '@ohos/basic-utils'
import { webview } from '@kit.ArkWeb'
import { preferences } from '@kit.ArkData'
import deviceInfo from '@ohos.deviceInfo'
import { common } from '@kit.AbilityKit'
import { LegacyMainPage } from './LegacyMainPage'
import { HdsMainPage } from './HdsMainPage'
class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct Index {
  @State customDialogId: number = 0
  @State isFirst: string = '首次'
  @State isHdsSupported: boolean = false
  controller: webview.WebviewController = new webview.WebviewController()
  /** Options 页面 Toggle 切换时同步到此标志位 */
  @StorageLink('isFullScreenEnabled') isFullScreenEnabled: boolean = false

  aboutToAppear() {
    // 检测 API 版本：>=23 可启用 HdsTabs 悬浮导航
    try {
      this.isHdsSupported = deviceInfo.sdkApiVersion >= 23
    } catch (e) {
      this.isHdsSupported = false
    }
  }

  @Builder
  PrivacyPolicyDialog() {
    Column() {
      Row() {
        Web({ src: $rawfile("privacypolicy.html"), controller: this.controller }).width("100%")
      }.width('100%').height('70%').borderRadius(12).clip(true)

      Row() {
        Text('点此查看详细信息').onClick(() => {
          // router.pushUrl({
          //   url: 'pages/SettingPage/SettingPage',
          //   params: new Params('privatepolicy')
          // })
          router.pushUrl({ url: 'pages/SettingPage/SettingPage', params: { type: 'privatepolicy' } })
            .then(() => {
            console.info("success.")
          }).catch((err: BusinessError) => {
            console.error(`err, code is ${err.code}, message is ${err.message}.`)
          })
          promptAction.closeCustomDialog(this.customDialogId)
        }).textAlign(TextAlign.Start).width('100%').margin({ left: 20 })
      }.width('100%').height('8%')
      .justifyContent(FlexAlign.Center)

      Column({ space: 8 }) {
        Button('拒绝并退出应用')
          .width('80%')
          .height(36)
          .backgroundColor($r("app.color.warning"))
          .fontColor(Color.White)
          .onClick(() => {
            promptAction.closeCustomDialog(this.customDialogId)
            // 退出应用
            const context = getContext(this) as common.UIAbilityContext
            context.terminateSelf()
          })
        Button('同意')
          .width('80%')
          .height(36)
          .backgroundColor($r("app.color.Brand"))
          .fontColor(Color.White)
          .onClick(() => {
            this.saveIsPrivacy()
            promptAction.showToast({ message: '您可前往 设置>隐私政策 查看详情' })
            promptAction.closeCustomDialog(this.customDialogId)
          })
      }
      .width('100%')
      .height('22%')
      .justifyContent(FlexAlign.Center)
    }.padding(10)
  }

  getDataPreferences(common: Object) {
    return preferences.getPreferences(getContext(common), CommonConstants.PREFERENCES_FILE_NAME)
  }

  saveIsPrivacy() {
    let prefs: Promise<preferences.Preferences> = this.getDataPreferences(this)
    prefs.then((result: preferences.Preferences) => {
      let privacyPut = result.put(CommonConstants.PREFERENCES_KEY_PRIVACY, false)
      result.flush()
      privacyPut.then(() => {
        Logger.info(CommonConstants.LAUNCHER_PAGE_TAG, 'Put the value of startup Successfully.')
      }).catch((err: Error) => {
        Logger.error(CommonConstants.LAUNCHER_PAGE_TAG, 'Put the value of startup Failed, err: ' + err)
      })
    }).catch((err: Error) => {
      Logger.error(CommonConstants.LAUNCHER_PAGE_TAG, 'Get the preferences Failed, err: ' + err)
    })
  }

  onPageShow(): void {
    this.getDataPreferences(this).then((prefs: preferences.Preferences) => {
      prefs.get(CommonConstants.PREFERENCES_KEY_PRIVACY, true)
        .then((value: preferences.ValueType) => {
          Logger.info(CommonConstants.LAUNCHER_PAGE_TAG, 'onPageShow value: ' + value)
          if (value) {
            let isJumpPrivacy: boolean = (GlobalContext.getContext()
              .getObject('isJumpPrivacy') as boolean) ?? false
            if (!isJumpPrivacy) {
              promptAction.openCustomDialog({
                builder: () => {
                  this.PrivacyPolicyDialog()
                },
                showInSubWindow: false,
                isModal: true,
                offset: { dx: 0, dy: 5 },
                backgroundColor: 0xd9ffffff,
                cornerRadius: 24,
                backgroundBlurStyle: BlurStyle.Regular,
                width: 320,
                height: 550,
                onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                  // 拦截点击空白区域关闭弹窗
                  if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
                    // 不执行关闭操作，阻止弹窗关闭
                    return
                  }
                  // 其他关闭方式（如返回键）也阻止
                  if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
                    return
                  }
                  // 允许通过按钮关闭
                  dismissDialogAction.dismiss()
                }
              }).then((dialogId: number) => {
                this.customDialogId = dialogId
              })
            }
          } else {
            this.isFirst = '非首次'
          }
        })
    })
  }

  build() {
    Column() {
      // 当前项目 target API 12，加载 LegacyMainPage
      // 升级 API 23+ 后，将 import 替换并切换为 HdsMainPage
      if (this.isHdsSupported) {
        HdsMainPage()
          // .backgroundColor(Color.Blue)
      } else {
        LegacyMainPage()
          // .backgroundColor(Color.Red)
      }
    }
    // .backgroundColor(Color.Green)
    .width('100%')
    .height('100%')
  }
}
