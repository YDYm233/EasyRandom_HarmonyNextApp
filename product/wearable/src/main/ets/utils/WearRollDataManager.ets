// ═══════════════════════════════════════════
//  手表端精简版转盘数据管理
//  仅包含默认数据 + 核心工具函数，不引入 Preferences 持久化
// ═══════════════════════════════════════════

import { Random } from '@ohos/basic-utils';

// ── 常量 ──
export const COLOR_PRESETS: string[] = [
  '#ffcba50b', '#ffa87cf4', '#ffe81b58', '#ff38ed44', '#fff7942c', '#ff68ead0',
  '#ffff007a', '#ff0cdec5', '#ff05f80b', '#ffecb609', '#ff5f16e1', '#499821',
  '#ffde6e12', '#ff3498db', '#ff9b59b6', '#ff1abc9c', '#ffe74c3c', '#fff39c12'
];

// ── 数据模型 ──
export class RollItem {
  id: string;
  text: string;
  weight: number;
  color: string;

  constructor(id: string, text: string, weight: number, color: string) {
    this.id = id;
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}

export class Roll {
  index: string;
  rollName: string;
  rollItems: Array<RollItem>;

  constructor(index: string, rollName: string, rollItems: Array<RollItem>) {
    this.index = index;
    this.rollName = rollName;
    this.rollItems = rollItems;
  }
}

// ── 预设转盘数据 ──
export const defaultRolls: Array<Roll> = [
  new Roll('0', '吃什么？', [
    new RollItem('0', '麻辣烫', 2, '#ffcba50b'),
    new RollItem('1', '汉堡薯条', 2, '#ffa87cf4'),
    new RollItem('2', '黑胡椒汤', 3, '#ffe81b58'),
    new RollItem('3', '盖浇饭', 2, '#ff38ed44'),
    new RollItem('4', '羊肉烩面', 3, '#fff7942c'),
    new RollItem('5', '火锅烤肉', 2, '#ff68ead0'),
  ]),
  new Roll('1', '喝什么？', [
    new RollItem('0', '奶茶', 3, '#ff9b59b6'),
    new RollItem('1', '咖啡', 2, '#ff3498db'),
    new RollItem('2', '可乐', 2, '#ffe74c3c'),
    new RollItem('3', '果汁', 3, '#fff39c12'),
    new RollItem('4', '白开水', 1, '#ff1abc9c'),
    new RollItem('5', '柠檬茶', 2, '#ffcba50b'),
    new RollItem('6', '豆奶', 2, '#ff68ead0'),
  ]),
  new Roll('2', '去哪儿玩？', [
    new RollItem('0', '电影院', 2, '#ffff007a'),
    new RollItem('1', '商场', 2, '#ff0cdec5'),
    new RollItem('2', '公园', 3, '#ff38ed44'),
    new RollItem('3', '宅家', 1, '#ffde6e12'),
    new RollItem('4', '奶茶店', 3, '#ffe81b58'),
    new RollItem('5', 'KTV', 2, '#ffa87cf4'),
    new RollItem('6', '图书馆', 2, '#ff3498db'),
  ]),
  new Roll('3', '随机颜色', [
    new RollItem('0', '红色', 1, '#ffe74c3c'),
    new RollItem('1', '橙色', 1, '#fff39c12'),
    new RollItem('2', '黄色', 1, '#ffecb609'),
    new RollItem('3', '绿色', 1, '#ff38ed44'),
    new RollItem('4', '蓝色', 1, '#ff3498db'),
    new RollItem('5', '紫色', 1, '#ff9b59b6'),
    new RollItem('6', '粉色', 1, '#ffff007a'),
    new RollItem('7', '白色', 1, '#ffde6e12'),
  ]),
  new Roll('4', '今天做什么？', [
    new RollItem('0', '学习', 3, '#ff3498db'),
    new RollItem('1', '运动', 2, '#ff38ed44'),
    new RollItem('2', '追剧', 2, '#ffe81b58'),
    new RollItem('3', '打游戏', 2, '#ffa87cf4'),
    new RollItem('4', '收拾房间', 1, '#ff1abc9c'),
    new RollItem('5', '约饭', 3, '#ffcba50b'),
    new RollItem('6', '逛街', 2, '#ffff007a'),
  ]),
  new Roll('5', '随机运动', [
    new RollItem('0', '跑步', 3, '#ffe74c3c'),
    new RollItem('1', '游泳', 2, '#ff3498db'),
    new RollItem('2', '瑜伽', 2, '#ff9b59b6'),
    new RollItem('3', '篮球', 3, '#fff39c12'),
    new RollItem('4', '跳绳', 2, '#ff38ed44'),
    new RollItem('5', '骑行', 2, '#ff68ead0'),
    new RollItem('6', '深蹲', 1, '#ffde6e12'),
    new RollItem('7', '拉伸', 1, '#ff1abc9c'),
  ]),
  new Roll('6', '电影类型', [
    new RollItem('0', '喜剧', 2, '#fff39c12'),
    new RollItem('1', '悬疑', 3, '#ff9b59b6'),
    new RollItem('2', '科幻', 2, '#ff3498db'),
    new RollItem('3', '动画', 2, '#ff1abc9c'),
    new RollItem('4', '恐怖', 2, '#ffe74c3c'),
    new RollItem('5', '爱情', 3, '#ffff007a'),
    new RollItem('6', '动作', 2, '#ffa87cf4'),
  ]),
];

/** 随机选取一个预设颜色 */
export function randomPresetColor(): string {
  return COLOR_PRESETS[Random(0, COLOR_PRESETS.length - 1, true)];
}
