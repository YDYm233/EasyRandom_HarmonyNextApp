import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'
import { CommonConstants } from '@ohos/common'

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | null = null

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate')
  }

  onDestroy(): void {
    if (this.mainWindow) {
      try {
        this.mainWindow.off('freeWindowModeChange')
      } catch (_err) {
        // API < 22 设备不支持该事件
      }
    }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStorage.setOrCreate('windowStage', windowStage)
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate')

    const mainWindow = windowStage.getMainWindowSync()
    this.mainWindow = mainWindow
    AppStorage.setOrCreate('mainWindow', mainWindow)

    // 初始设置窗口全屏 + 获取安全区高度
    this.applyFullScreen(mainWindow)

    // 监听自由多窗模式切换（API 22+，低版本静默降级）
    try {
      mainWindow.on('freeWindowModeChange', (_isFreeWindowMode: boolean) => {
        this.applyFullScreen(mainWindow)
      })
    } catch (_err) {
      // API < 22 设备不支持该事件
    }

    windowStage.loadContent('pages/IndexPage/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '')
        return
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.')
    })
  }

  /**
   * 根据当前窗口模式决定是否全屏并更新安全区高度
   * isInFreeWindowMode 为 API 22+ 接口，低版本设备用 try-catch 降级为 false
   */
  private applyFullScreen(mainWindow: window.Window): void {
    let isFreeWindow = false
    try {
      isFreeWindow = mainWindow.isInFreeWindowMode()
    } catch (_err) {
      // API < 22 设备不支持 isInFreeWindowMode，默认为正常模式
    }

    if (isFreeWindow) {
      // 自由多窗模式：退出全屏，清空安全区高度
      mainWindow.setWindowLayoutFullScreen(false)
      mainWindow.setWindowSystemBarEnable(['status', 'navigation'])
      AppStorage.setOrCreate('statusBarHeight', 0)
      AppStorage.setOrCreate('navIndicatorHeight', 0)
      AppStorage.setOrCreate('isFullScreenEnabled', false)
    } else {
      // 正常模式：开启全屏，获取安全区高度
      mainWindow.setWindowLayoutFullScreen(true)

      // 根据用户偏好设置控制系统栏显隐
      const isFullScreenEnabled = this.isFullScreenEnabled()
      AppStorage.setOrCreate('isFullScreenEnabled', isFullScreenEnabled)
      if (isFullScreenEnabled) {
        mainWindow.setWindowSystemBarEnable([])
        AppStorage.setOrCreate('statusBarHeight', 0)
        AppStorage.setOrCreate('navIndicatorHeight', 0)
      } else {
        mainWindow.setWindowSystemBarEnable(['status', 'navigation'])
        const systemAvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        const navIndicatorArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        AppStorage.setOrCreate('statusBarHeight', px2vp(systemAvoidArea.topRect.height))
        AppStorage.setOrCreate('navIndicatorHeight', px2vp(navIndicatorArea.bottomRect.height))
      }
    }
  }

  /** 从 Preferences 读取用户是否开启完全全屏 */
  private isFullScreenEnabled(): boolean {
    try {
      const pref = preferences.getPreferencesSync(this.context, { name: CommonConstants.PREFERENCES_FILE_NAME })
      return pref.getSync(CommonConstants.PREFERENCES_KEY_FULLSCREEN, false) as boolean
    } catch (_e) {
      return false
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground')
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground')
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant')
  }
}
