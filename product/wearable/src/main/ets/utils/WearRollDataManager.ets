// ═══════════════════════════════════════════
//  手表端精简版转盘数据管理
//  仅包含默认数据 + 核心工具函数，不引入 Preferences 持久化
// ═══════════════════════════════════════════

import { Random } from '@ohos/common';

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
  new Roll('1', '随机颜色', [
    new RollItem('0', '红色', 1, '#ffe74c3c'),
    new RollItem('1', '橙色', 1, '#fff39c12'),
    new RollItem('2', '黄色', 1, '#ffecb609'),
    new RollItem('3', '绿色', 1, '#ff38ed44'),
    new RollItem('4', '蓝色', 1, '#ff3498db'),
    new RollItem('5', '紫色', 1, '#ff9b59b6'),
    new RollItem('6', '粉色', 1, '#ffff007a'),
    new RollItem('7', '白色', 1, '#ffde6e12'),
  ]),
];

/** 随机选取一个预设颜色 */
export function randomPresetColor(): string {
  return COLOR_PRESETS[Random(0, COLOR_PRESETS.length - 1, true)];
}
