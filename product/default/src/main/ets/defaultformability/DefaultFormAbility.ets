import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit'

const PREF_NAME: string = 'blessing_muyu'
const KEY_CLICK_COUNT: string = 'click_count'
const PIN_PREF_NAME: string = 'roll_wheel_card_pin'
const KEY_PINNED_ROLL: string = 'pinned_roll_data'

export default class DefaultFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    const formName = want.parameters?.[formInfo.FormParam.NAME_KEY] as string

    // RollWheelCard：从 Preferences 读取 pin 按钮保存的转盘数据
    if (formName === 'RollWheelCard') {
      try {
        const ctx = this.context.getApplicationContext()
        // 清除缓存以确保跨进程读取到最新数据
        preferences.removePreferencesFromCacheSync(ctx, PIN_PREF_NAME)
        const pref = preferences.getPreferencesSync(ctx, { name: PIN_PREF_NAME })
        const rollJson = pref.getSync(KEY_PINNED_ROLL, '') as string

        if (rollJson.length > 0) {
          const roll: Record<string, Object> = JSON.parse(rollJson) as Record<string, Object>
          const formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string

          hilog.info(0x0000, 'testTag',
            '[RollWheelCard onAddForm] formId: %{public}s, rollName: %{public}s, items: %{public}d',
            formId, roll['rollName'] as string, (roll['rollItems'] as Array<Object>).length)

          const formData: Record<string, string> = {
            'formId': formId,
            'rollName': roll['rollName'] as string,
            'rollItemsJson': JSON.stringify(roll['rollItems'])
          }
          return formBindingData.createFormBindingData(formData)
        }
      } catch (e) {
        hilog.error(0x0000, 'testTag', '[RollWheelCard onAddForm] 读取转盘数据失败: %{public}s', JSON.stringify(e))
      }
    }

    return formBindingData.createFormBindingData('')
  }

  onCastToNormalForm(formId: string) {
  }

  onUpdateForm(formId: string) {
  }

  /**
   * 卡片 message 事件回调
   */
  onFormEvent(formId: string, message: string): void {
    try {
      const params: Record<string, Object> = JSON.parse(message) as Record<string, Object>

      // RollWheelCard 点击事件：输出卡片数据和 formId 日志
      if (params['event'] === 'roll_wheel_click') {
        hilog.info(0x0000, 'testTag',
          '[卡片点击] formId: %{public}s, 转盘名称: %{public}s, 选项数: %{public}d, 选项: %{public}s',
          formId, params['rollName'] as string, params['itemCount'] as number, params['items'] as string)
        return
      }

      // BlessingMuyu 功德计数
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
      hilog.error(0x0000, 'testTag', '卡片事件处理失败: %{public}s', JSON.stringify(e))
    }
  }

  onRemoveForm(formId: string) {
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY
  }
};
