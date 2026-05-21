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

let sIdCounter: number = Date.now()

/** 生成新的转盘 index */
export function generateRollId(): string {
  return `roll_${++sIdCounter}`
}

/** 生成新的子选项 id */
export function generateItemId(): string {
  return `item_${++sIdCounter}`
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
  return allRolls.find((roll: Roll) => roll.index === index)
}

/**
 * 在转盘中添加子选项 — 生成新数组引用以触发 ForEach 增量刷新
 */
export function addRollItem(roll: Roll): RollItem {
  const newItem = new RollItem(generateItemId(), '新选项', 1, randomPresetColor())
  roll.rollItems = [...roll.rollItems, newItem]
  return newItem
}

/**
 * 在转盘中删除子选项（保留至少 2 个）— 生成新数组引用以触发 ForEach 增量刷新
 */
export function removeRollItem(roll: Roll, itemIndex: number): boolean {
  if (roll.rollItems.length <= 2) {
    return false
  }
  const updated = [...roll.rollItems]
  updated.splice(itemIndex, 1)
  roll.rollItems = updated
  return true
}

/** 从 allRolls 中删除转盘，返回被删除的 Roll 或 undefined */
export function removeRoll(allRolls: Roll[], roll: Roll): Roll | undefined {
  const targetIndex = allRolls.indexOf(roll)
  if (targetIndex >= 0) {
    return allRolls.splice(targetIndex, 1)[0]
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
//  预设转盘数据
// ═══════════════════════════════════════════

export const defaultRolls: Array<Roll> = [
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
  new Roll('4', '真心话大冒险', [
    new RollItem('0', '真心话', 1, '#ffe74c3c'),
    new RollItem('1', '大冒险', 1, '#ff3498db'),
    new RollItem('2', '再来一次', 1, '#fff39c12'),
  ]),
  new Roll('5', '今天穿什么', [
    new RollItem('0', '休闲风', 2, '#ff1abc9c'),
    new RollItem('1', '运动装', 2, '#ff3498db'),
    new RollItem('2', '正装', 1, '#ff9b59b6'),
    new RollItem('3', '牛仔风', 2, '#ffde6e12'),
    new RollItem('4', '随性混搭', 3, '#ff05f80b'),
  ]),
  new Roll('6', '周末去哪', [
    new RollItem('0', '看电影', 2, '#fff7942c'),
    new RollItem('1', '逛公园', 3, '#ff38ed44'),
    new RollItem('2', '宅家追剧', 3, '#ff5f16e1'),
    new RollItem('3', '逛商场', 2, '#ffff007a'),
    new RollItem('4', '爬山', 1, '#ff68ead0'),
    new RollItem('5', '图书馆', 2, '#ffa87cf4'),
  ]),
  new Roll('7', '下午茶', [
    new RollItem('0', '奶茶', 3, '#ffcba50b'),
    new RollItem('1', '咖啡', 2, '#ff3498db'),
    new RollItem('2', '果汁', 2, '#ff38ed44'),
    new RollItem('3', '蛋糕', 3, '#ffff007a'),
    new RollItem('4', '冰淇淋', 2, '#ff1abc9c'),
    new RollItem('5', '水果捞', 2, '#fff39c12'),
    new RollItem('6', '小饼干', 2, '#ffde6e12'),
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
      const rawData: string = pref.getSync(KEY_ROLLS, '') as string
      if (rawData.length > 0) {
        const parsed: Array<Roll> = JSON.parse(rawData)
        return parsed.map((roll: Roll) => {
          const items = roll.rollItems.map((item: RollItem) =>
            new RollItem(item.id, item.text, item.weight, item.color))
          return new Roll(roll.index, roll.rollName, items)
        })
      }
    }
  } catch (_e) {
    // fallback to defaults
  }
  return defaultRolls
}

/**
 * 将转盘数据序列化写入 Preferences（不更新 AppStorage）
 * 用于编辑页面中的属性修改（颜色/名称/权重），避免深拷贝触发的全组件重建打断 TextInput。
 */
export function writeRollsToPrefs(context: Context, data: Roll[]): void {
  try {
    const pref = preferences.getPreferencesSync(context, { name: PREF_NAME })
    pref.putSync(KEY_ROLLS, JSON.stringify(data))
    pref.flushSync()
  } catch (_e) {
    // ignore
  }
}

/**
 * 将转盘数据保存到 Preferences，并同步更新 AppStorage
 * 深拷贝所有 Roll / RollItem 对象，确保 @Prop 等引用型装饰器能检测到变化
 * 仅用于结构性变更（增删选项/转盘），日常属性修改请用 writeRollsToPrefs
 */
export function saveRollsToPrefs(context: Context, data: Roll[]): void {
  try {
    const pref = preferences.getPreferencesSync(context, { name: PREF_NAME })
    pref.putSync(KEY_ROLLS, JSON.stringify(data))
    pref.flushSync()
    // 深拷贝：新 Roll → 新 RollItem → 新引用，触发所有监听组件的 @Prop / @StorageLink 刷新
    const cloned: Roll[] = data.map((roll: Roll) => {
      const items = roll.rollItems.map((item: RollItem) =>
        new RollItem(item.id, item.text, item.weight, item.color))
      return new Roll(roll.index, roll.rollName, items)
    })
    AppStorage.setOrCreate(APP_STORAGE_KEY, cloned)
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
