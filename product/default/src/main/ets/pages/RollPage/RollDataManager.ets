import { preferences } from '@kit.ArkData'
import { Roll, RollItem, rolls } from '../../static_datas/rolls'

const PREF_NAME: string = 'roll_wheel_data'
const KEY_ROLLS: string = 'all_rolls'

/**
 * 从 Preferences 加载转盘数据，若无则返回默认数据
 */
export function loadRollsFromPrefs(context: Context): Roll[] {
  try {
    const pref = preferences.getPreferencesSync(context, { name: PREF_NAME })
    if (pref.hasSync(KEY_ROLLS)) {
      const raw: string = pref.getSync(KEY_ROLLS, '') as string
      if (raw.length > 0) {
        const parsed: Array<Roll> = JSON.parse(raw)
        return parsed.map((r: Roll) => {
          const items = r.rollItems.map((_item: RollItem) =>
            new RollItem(_item.id, _item.text, _item.weight, _item.color))
          return new Roll(r.index, r.rollName, items)
        })
      }
    }
  } catch (_e) {
    // fallback to defaults
  }
  return rolls
}

/**
 * 将转盘数据保存到 Preferences，并同步更新 AppStorage
 */
export function saveRollsToPrefs(context: Context, data: Roll[]): void {
  try {
    const pref = preferences.getPreferencesSync(context, { name: PREF_NAME })
    pref.putSync(KEY_ROLLS, JSON.stringify(data))
    pref.flushSync()
    AppStorage.setOrCreate('allRolls', data)
  } catch (_e) {
    // ignore
  }
}

/**
 * 初始化 AppStorage 中的转盘数据（优先从 Preferences 加载）
 */
export function initRollsData(context: Context): void {
  const saved = loadRollsFromPrefs(context)
  AppStorage.setOrCreate('allRolls', saved)
}
