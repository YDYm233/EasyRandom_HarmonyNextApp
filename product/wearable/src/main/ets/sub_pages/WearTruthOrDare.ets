// 真心话大冒险页面 - P0 功能
// 指针旋转方案：屏幕左右分屏，中间指针旋转，停止后弹窗显示结果
// 参照: docs/wearable-page-impl.md §6

import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';
import { honests, challenges } from '../utils/WearTruthOrDareData';

/**
 * 随机文本结果接口
 */
interface IRandomTextResult {
  text: string;
  index: number;
}

/**
 * 真心话大冒险组件（指针旋转版）
 *
 * 交互规则：
 * - 屏幕左右分屏：左半屏粉色（真心话），右半屏蓝色（大冒险）
 * - 中间固定显示指针图标
 * - 点击指针区域 → 指针旋转（5-8圈 + 随机偏移）
 * - 旋转结束后根据指针最终角度判定结果，弹窗显示题目
 * - 弹窗显示期间可点击关闭，或 2 秒后自动关闭
 */
@Component
export struct WearTruthOrDare {
  // === 指针旋转状态 ===
  @State rotateAngle: number = 0;
  @State isSpinning: boolean = false;

  // === 结果弹窗状态 ===
  @State showResult: boolean = false;
  @State resultText: string = '';
  @State resultType: 'honest' | 'challenge' = 'honest';

  // === 防重复状态 ===
  @State lastHonestIndex: number = -1;
  @State lastChallengeIndex: number = -1;

  // === 配色方案（参考 default 真心话大冒险页面）===
  private readonly HONEST_BG: number = 0xFF7299;         // 粉色 - 真心话区域（同 default）
  private readonly HONEST_RESULT_BG: number = 0xCC5A7A;   // 深粉 - 弹窗背景
  private readonly CHALLENGE_BG: number = 0x23ADE5;       // 蓝色 - 大冒险区域（同 default）
  private readonly CHALLENGE_RESULT_BG: number = 0x1A8AB8; // 深蓝 - 弹窗背景

  /**
   * 从题库随机获取一条（防止连续重复）
   */
  private getRandomText(source: string[], lastIndex: number): IRandomTextResult {
    if (source.length === 0) {
      return { text: '暂无题目', index: -1 };
    }
    if (source.length === 1) {
      return { text: source[0], index: 0 };
    }
    let idx = Random(0, source.length - 1, true);
    if (idx === lastIndex) {
      idx = (idx + 1) % source.length;
    }
    return { text: source[idx], index: idx };
  }

  /**
   * 开始旋转指针
   */
  private startSpin(): void {
    if (this.isSpinning) {
      return; // 防止动画期间重复点击
    }
    this.isSpinning = true;
    this.showResult = false;

    // 随机旋转 5~8 圈 + 随机偏移角度
    const extraTurns: number = Random(5, 8, true);
    const randomOffset: number = Random(0, 359, true);
    const targetAngle: number = this.rotateAngle + extraTurns * 360 + randomOffset;

    // 使用 animateTo 控制旋转动画
    animateTo({
      duration: 1000,
      curve: Curve.Ease,
      onFinish: () => {
        this.onSpinFinish(targetAngle);
      }
    }, () => {
      this.rotateAngle = targetAngle;
    });
  }

  /**
   * 旋转结束，判定结果
   */
  private onSpinFinish(finalAngle: number): void {
    // 取模 360，得到最终指向角度（0~359），用 round 避免浮点误差
    let normalizedAngle: number = Math.round(finalAngle % 360);
    if (normalizedAngle < 0) {
      normalizedAngle += 360;
    }

    // 判定逻辑（pointer_m.svg 默认指向右侧，即 0° = 右/大冒险）：
    //   180~359 度 → 指针指向左侧（真心话区域）
    //   0~179 度   → 指针指向右侧（大冒险区域）
    const isHonest: boolean = normalizedAngle >= 180;
    const source: string[] = isHonest ? honests : challenges;
    const lastIdx: number = isHonest ? this.lastHonestIndex : this.lastChallengeIndex;
    const result: IRandomTextResult = this.getRandomText(source, lastIdx);

    if (isHonest) {
      this.lastHonestIndex = result.index;
    } else {
      this.lastChallengeIndex = result.index;
    }

    this.resultText = result.text;
    this.resultType = isHonest ? 'honest' : 'challenge';
    this.showResult = true;
    this.isSpinning = false;
  }

  /**
   * 关闭结果弹窗
   */
  private closeResult(): void {
    this.showResult = false;
  }

  build() {
    Stack() {
      // === 底层：左右分屏背景 ===
      Row() {
        // 左半屏：真心话（粉色）
        Column() {
          Text('真心话')
            .fontSize(WearScreenUtil.buttonFontSize)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width('50%')
        .height('100%')
        .backgroundColor(this.HONEST_BG)
        .justifyContent(FlexAlign.Center)

        // 右半屏：大冒险（蓝色）
        Column() {
          Text('大冒险')
            .fontSize(WearScreenUtil.buttonFontSize)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width('50%')
        .height('100%')
        .backgroundColor(this.CHALLENGE_BG)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')

      // === 中间层：指针（可旋转）===
      Column() {
        Image($r("app.media.pointer_m"))
          .width(WearScreenUtil.scaledSize(80))
          .height(WearScreenUtil.scaledSize(80))
          .fillColor(Color.White)
          .aspectRatio(1)
      }
      .rotate({ angle: this.rotateAngle })
      .onClick(() => {
        this.startSpin();
      })

      // === 弹窗层：结果显示 ===
      if (this.showResult) {
        Stack() {
          // 半透明遮罩（全屏）
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(0x88000000)
            .onClick(() => {
              this.closeResult();
            })

          // 结果卡片（居中悬浮，onClick 空函数阻止事件冒泡）
          Column() {
            Text(this.resultType === 'honest' ? '💗 真心话' : '🔥 大冒险')
              .fontSize(WearScreenUtil.subFontSize)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })

            Text(this.resultText)
              .fontSize(WearScreenUtil.subFontSize - 2)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .maxLines(4)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('85%')

            // 关闭按钮
            Button('知道了')
              .width(WearScreenUtil.scaledSize(80))
              .height(WearScreenUtil.scaledSize(28))
              .fontSize(WearScreenUtil.subFontSize - 2)
              .backgroundColor(0x66FFFFFF)
              .margin({ top: 16 })
              .onClick(() => {
                this.closeResult();
              })
          }
          .onClick(() => {})
          .width('80%')
          .backgroundColor(
            this.resultType === 'honest'
              ? this.HONEST_RESULT_BG
              : this.CHALLENGE_RESULT_BG
          )
          .borderRadius(WearScreenUtil.scaledSize(12))
          .padding(WearScreenUtil.scaledSize(16))
        }
        .width('100%')
        .height('100%')
        .alignContent(Alignment.Center)
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
