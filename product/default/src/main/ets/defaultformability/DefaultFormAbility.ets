import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit'

const PREF_NAME: string = 'blessing_muyu'
const KEY_CLICK_COUNT: string = 'click_count'

export default class DefaultFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    return formBindingData.createFormBindingData('')
  }

  onCastToNormalForm(formId: string) {
  }

  onUpdateForm(formId: string) {
  }

  /**
   * 卡片 message 事件回调
   * 卡片点击不打开应用，通过此回调自增计数到 Preferences
   */
  onFormEvent(formId: string, message: string): void {
    try {
      const params: Record<string, string> = JSON.parse(message)
      if (params['event'] === 'blessing_muyu_click') {
        const ctx = this.context.getApplicationContext()
        preferences.removePreferencesFromCacheSync(ctx, PREF_NAME)
        const pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME })
        const current = pref.getSync(KEY_CLICK_COUNT, 0) as number
        const newCount = current + 1
        pref.putSync(KEY_CLICK_COUNT, newCount)
        pref.flushSync()
        hilog.info(0x0000, 'testTag', '功德总数(卡片): %{public}d', newCount)
      }
    } catch (e) {
      hilog.error(0x0000, 'testTag', '卡片计数失败: %{public}s', JSON.stringify(e))
    }
  }

  onRemoveForm(formId: string) {
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY
  }
};
