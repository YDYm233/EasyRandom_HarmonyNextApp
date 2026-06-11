// 真心话大冒险页面 - P0 功能
// 上下分屏双模式，上半屏「真心话」下半屏「大冒险」
// 参照: docs/wearable-page-impl.md §6

import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';
import { honests, challenges } from '../utils/WearTruthOrDareData';

/**
 * 真心话大冒险组件
 * 
 * 交互规则：
 * - 点击某区域 → 该区域显示结果 + 变暗表明已出题
 * - 可再次点击出下一题（不与上一题重复）
 * - 两个区域独立操作
 */
@Component
export struct WearTruthOrDare {
  // === 真心话状态 ===
  @State honestText: string = '真心话';
  @State honestActive: boolean = false;
  @State lastHonestIndex: number = -1;

  // === 大冒险状态 ===
  @State challengeText: string = '大冒险';
  @State challengeActive: boolean = false;
  @State lastChallengeIndex: number = -1;

  // === 配色方案 ===
  private readonly HONEST_COLOR_ACTIVE: string = '#FF7299';
  private readonly HONEST_COLOR_RESULT: string = '#CC5A7A';
  private readonly CHALLENGE_COLOR_ACTIVE: string = '#23ADE5';
  private readonly CHALLENGE_COLOR_RESULT: string = '#1A8AB8';

  /**
   * 从题库随机获取一条（防止连续重复）
   * @param source 题库数组
   * @param lastIndex 上次题号
   * @returns { text, index }
   */
  private getRandomText(source: string[], lastIndex: number): { text: string; index: number } {
    // 边界处理：题库为空
    if (source.length === 0) {
      return { text: '暂无题目', index: -1 };
    }

    // 题库只有 1 条，直接返回
    if (source.length === 1) {
      return { text: source[0], index: 0 };
    }

    // 随机选取（防止连续重复）
    let idx = Random(0, source.length - 1, true);
    if (idx === lastIndex) {
      idx = (idx + 1) % source.length;
    }
    return { text: source[idx], index: idx };
  }

  build() {
    Column() {
      // === 上半区：真心话 ===
      Column() {
        // 图标 + 标题
        if (!this.honestActive) {
          Column() {
            Text('💗')
              .fontSize(WearScreenUtil.buttonFontSize * 1.5)
              .margin({ bottom: 8 })
            Text('真心话')
              .fontSize(WearScreenUtil.buttonFontSize)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
        } else {
          // 题目展示
          Text(this.honestText)
            .fontSize(WearScreenUtil.subFontSize)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('90%')
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(
        this.honestActive ? this.HONEST_COLOR_RESULT : this.HONEST_COLOR_ACTIVE
      )
      .justifyContent(FlexAlign.Center)
      .padding(WearScreenUtil.safePadding)
      .onClick(() => {
        const result = this.getRandomText(honests, this.lastHonestIndex);
        this.honestText = result.text;
        this.lastHonestIndex = result.index;
        this.honestActive = true;
        // 震动反馈（try-catch 防止不可用时报错）
        try {
          // VibratorManager.vibrateResult(); // 需确认 wearable API
        } catch (e) {
          // 静默失败
        }
      })

      // === 分隔线 ===
      Divider()
        .color(0x33FFFFFF)
        .height(1)

      // === 下半区：大冒险 ===
      Column() {
        // 图标 + 标题
        if (!this.challengeActive) {
          Column() {
            Text('🔥')
              .fontSize(WearScreenUtil.buttonFontSize * 1.5)
              .margin({ bottom: 8 })
            Text('大冒险')
              .fontSize(WearScreenUtil.buttonFontSize)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
        } else {
          // 题目展示
          Text(this.challengeText)
            .fontSize(WearScreenUtil.subFontSize)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('90%')
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(
        this.challengeActive ? this.CHALLENGE_COLOR_RESULT : this.CHALLENGE_COLOR_ACTIVE
      )
      .justifyContent(FlexAlign.Center)
      .padding(WearScreenUtil.safePadding)
      .onClick(() => {
        const result = this.getRandomText(challenges, this.lastChallengeIndex);
        this.challengeText = result.text;
        this.lastChallengeIndex = result.index;
        this.challengeActive = true;
        // 震动反馈（try-catch 防止不可用时报错）
        try {
          // VibratorManager.vibrateResult(); // 需确认 wearable API
        } catch (e) {
          // 静默失败
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
