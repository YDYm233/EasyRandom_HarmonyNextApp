import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'

const PREF_NAME: string = 'blessing_muyu'
const KEY_CLICK_COUNT: string = 'click_count'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate')
    this.handleCardClick(want)
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStorage.setOrCreate('windowStage', windowStage)
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '')
        return
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.')
    })
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

  /**
   * 当卡片点击后路由到此 Ability 时触发
   * 解析 cardClick 参数，自增功德计数
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant')
    this.handleCardClick(want)
  }

  private handleCardClick(want: Want): void {
    try {
      if (want.parameters && typeof want.parameters === 'object') {
        // postCardAction 的 params 会以 JSON 字符串形式存在 want.parameters.params 中
        const rawParams = want.parameters['params'] as string | undefined
        if (rawParams) {
          const params: Record<string, string> = JSON.parse(rawParams)
          if (params['cardClick'] === 'blessing_muyu') {
            this.incrementBlessingCount()
          }
        }
      }
    } catch (_e) {
      // 非卡片点击或解析失败，忽略
    }
  }

  private incrementBlessingCount(): void {
    try {
      const ctx = this.context.getApplicationContext()
      preferences.removePreferencesFromCacheSync(ctx, PREF_NAME)
      const pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME })
      const current = pref.getSync(KEY_CLICK_COUNT, 0) as number
      pref.putSync(KEY_CLICK_COUNT, current + 1)
      pref.flushSync()
      hilog.info(0x0000, 'testTag', '功德计数(卡片): %{public}d', current + 1)
    } catch (e) {
      hilog.error(0x0000, 'testTag', '功德计数持久化失败: %{public}s', JSON.stringify(e))
    }
  }
}
