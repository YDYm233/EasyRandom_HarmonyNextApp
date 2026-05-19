import { preferences } from '@kit.ArkData'

// ═══════════════════════════════════════════
//  常量 & 预设
// ═══════════════════════════════════════════

const PREF_NAME: string = 'roll_wheel_data'
const KEY_ROLLS: string = 'all_rolls'
const APP_STORAGE_KEY: string = 'allRolls'

/** 预设颜色板（18 色） */
export const COLOR_PRESETS: string[] = [
  '#ffcba50b', '#ffa87cf4', '#ffe81b58', '#ff38ed44', '#fff7942c', '#ff68ead0',
  '#ffff007a', '#ff0cdec5', '#ff05f80b', '#ffecb609', '#ff5f16e1', '#499821',
  '#ffde6e12', '#ff3498db', '#ff9b59b6', '#ff1abc9c', '#ffe74c3c', '#fff39c12'
]

// ═══════════════════════════════════════════
//  数据模型
// ═══════════════════════════════════════════

/** 转盘子选项 */
export class RollItem {
  id: string         // 唯一标识
  text: string       // 显示文字
  weight: number     // 权重（正数）
  color: string      // 扇形填充色

  constructor(id: string, text: string, weight: number, color: string) {
    this.id = id
    this.text = text
    this.weight = weight
    this.color = color
  }
}

/** 转盘 */
export class Roll {
  index: string              // 唯一标识
  rollName: string           // 转盘名称
  rollItems: Array<RollItem> // 子选项列表

  constructor(index: string, rollName: string, rollItems: Array<RollItem>) {
    this.index = index
    this.rollName = rollName
    this.rollItems = rollItems
  }
}

// ═══════════════════════════════════════════
//  ID 生成器
// ═══════════════════════════════════════════

let _idCounter: number = Date.now()

/** 生成新的转盘 index */
export function generateRollId(): string {
  return `roll_${++_idCounter}`
}

/** 生成新的子选项 id */
export function generateItemId(): string {
  return `item_${++_idCounter}`
}

/** 随机选取一个预设颜色 */
export function randomPresetColor(): string {
  return COLOR_PRESETS[Math.floor(Math.random() * COLOR_PRESETS.length)]
}

// ═══════════════════════════════════════════
//  数据操作辅助
// ═══════════════════════════════════════════

/** 从 allRolls 中查找指定 index 的转盘 */
export function findRoll(allRolls: Roll[], index: string): Roll | undefined {
  return allRolls.find((r: Roll) => r.index === index)
}

/**
 * 在转盘中添加子选项 — 生成新数组引用以触发 ForEach 增量刷新
 */
export function addRollItem(roll: Roll): RollItem {
  const item = new RollItem(generateItemId(), '新选项', 1, randomPresetColor())
  roll.rollItems = [...roll.rollItems, item]
  return item
}

/**
 * 在转盘中删除子选项（保留至少 2 个）— 生成新数组引用以触发 ForEach 增量刷新
 */
export function removeRollItem(roll: Roll, itemIdx: number): boolean {
  if (roll.rollItems.length <= 2) {
    return false
  }
  const updated = [...roll.rollItems]
  updated.splice(itemIdx, 1)
  roll.rollItems = updated
  return true
}

/** 从 allRolls 中删除转盘，返回被删除的 Roll 或 undefined */
export function removeRoll(allRolls: Roll[], roll: Roll): Roll | undefined {
  const idx = allRolls.indexOf(roll)
  if (idx >= 0) {
    return allRolls.splice(idx, 1)[0]
  }
  return undefined
}

/** 创建一个带默认子选项的转盘 */
export function createDefaultRoll(name: string): Roll {
  const items: RollItem[] = [
    new RollItem(generateItemId(), '选项一', 1, randomPresetColor()),
    new RollItem(generateItemId(), '选项二', 1, randomPresetColor())
  ]
  return new Roll(generateRollId(), name, items)
}

// ═══════════════════════════════════════════
//  默认示例数据
// ═══════════════════════════════════════════

export const rolls: Array<Roll> = [
  new Roll('0', '吃什么？', [
    new RollItem('0', '梅菜扣肉', 2, '#ffcba50b'),
    new RollItem('1', '西湖醋鱼', 3, '#ffa87cf4'),
    new RollItem('2', '西红柿炒鸡蛋', 2, '#ffe81b58'),
    new RollItem('3', '海带炖肉', 3, '#ff38ed44'),
    new RollItem('4', '穿过你的黑发我的手', 2, '#fff7942c'),
    new RollItem('5', '蚂蚁上树', 3, '#ff68ead0'),
  ]),
  new Roll('1', '随机颜色', [
    new RollItem('0', '粉色', 2, '#ffff007a'),
    new RollItem('1', '蓝色', 3, '#ff0cdec5'),
  ]),
  new Roll('2', '抽奖', [
    new RollItem('0', '三等奖', 4, '#ff05f80b'),
    new RollItem('1', '特等奖', 1, '#ffecb609'),
    new RollItem('2', '感谢参与', 5, '#499821'),
    new RollItem('3', '二等奖', 3, '#ff5f16e1'),
    new RollItem('4', '一等奖', 2, '#ffe81b58'),
  ]),
  new Roll('3', '幸运嘉宾', [
    new RollItem('0', '小绿', 1, '#ff05f80b'),
    new RollItem('1', '小明', 1, '#ff5f16e1'),
    new RollItem('2', '小红', 1, '#ffe81b58'),
    new RollItem('3', '小橙', 1, '#ffecb609'),
    new RollItem('4', '小岑', 1, '#499821'),
    new RollItem('5', '小阳', 1, '#ffde6e12'),
    new RollItem('6', '夏树', 1, '#ff3498db'),
  ]),
]

// ═══════════════════════════════════════════
//  持久化 & AppStorage 同步
// ═══════════════════════════════════════════

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
 * 使用浅拷贝新数组引用以触发 @StorageLink 更新
 */
export function saveRollsToPrefs(context: Context, data: Roll[]): void {
  try {
    const pref = preferences.getPreferencesSync(context, { name: PREF_NAME })
    pref.putSync(KEY_ROLLS, JSON.stringify(data))
    pref.flushSync()
    // [...data] 创建新数组引用 → @StorageLink 检测到变化 → 所有监听组件刷新
    AppStorage.setOrCreate(APP_STORAGE_KEY, [...data])
  } catch (_e) {
    // ignore
  }
}

/**
 * 初始化 AppStorage 中的转盘数据（优先从 Preferences 加载）
 */
export function initRollsData(context: Context): void {
  const saved = loadRollsFromPrefs(context)
  AppStorage.setOrCreate(APP_STORAGE_KEY, saved)
}
