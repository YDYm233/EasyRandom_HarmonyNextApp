// 真心话大冒险题库数据 - P0 功能
// 精简版 10 条起步，后续可扩展
// 参照: docs/wearable-page-impl.md §6.6

/**
 * 真心话语题库
 * 适合聚会社交场景，话题轻松有趣
 */
export const honests: string[] = [
  '你最近一次撒谎是什么时候？说的是什么？',
  '你最害怕失去什么？',
  '你做过最尴尬的事情是什么？',
  '你暗恋过谁？',
  '你最想改掉的坏习惯是什么？',
  '你在公共场合做过最丢脸的事是什么？',
  '你做过最冒险的事情是什么？',
  '如果可以回到过去，你最想改变什么？',
  '你最不想让别人知道的秘密是什么？',
  '你上一次哭是什么时候？为什么？',
];

/**
 * 大冒险题库
 * 适合聚会社交场景，挑战轻松可执行
 */
export const challenges: string[] = [
  '用新闻联播的腔调进行一分钟即兴演讲',
  '给未在场的朋友的朋友圈点赞，从第一条开始，一直点到最新的一条',
  '用方言给 1 个人打电话聊一分钟',
  '做一个大家都觉得很丑的鬼脸，并保持 10 秒钟',
  '蒙眼涂口红',
  '单脚站立 3 分钟',
  '给朋友打电话，唱《青藏高原》的高音部分',
  '一口气喝完一瓶矿泉水',
  '和在场的一位异性对视 10 秒',
  '模仿一位在场的人，让大家猜是谁',
];

/**
 * 题目数量接口
 */
export interface ITruthOrDareCount {
  honest: number;
  challenge: number;
}

/**
 * 获取题目总数
 */
export function getTotalCount(): ITruthOrDareCount {
  return {
    honest: honests.length,
    challenge: challenges.length,
  };
}
