import { Random } from '@ohos/basic-utils';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 抛硬币 — 点击触发纵向翻转动画，随机显示正/反
 * 参考 default 项目 FlipCoinCardDisplay
 */
@Component
export struct WearFlipCoin {
  @State scaleY: number = 1; // Y 轴缩放，实现纵向翻转效果
  @State showFront: boolean = true; // true 显示正面，false 显示反面
  private isFlipping: boolean = false;

  // 参照 ABCD：CARD=216，圆形视觉略小故用 220 + 边框补偿
  private readonly COIN_SIZE: number = WearScreenUtil.scaledSize(220);
  private readonly BORDER: number = WearScreenUtil.scaledSize(5);

  build() {
    Column() {
      // 硬币可视化
      Stack() {
        if (this.showFront) {
          Image($r("app.media.coin1"))
            .width('100%')
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)
        } else {
          Image($r("app.media.coin2"))
            .width('100%')
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)
        }
      }
      .width(this.COIN_SIZE)
      .aspectRatio(1)
      .borderRadius('50%')
      .clip(true)
      .border({
        style: BorderStyle.Solid,
        width: this.BORDER,
        color: 0xFFD4A017
      })
      .shadow({
        radius: WearScreenUtil.scaledSize(18),
        color: 0x60D4A017,
        offsetX: 0,
        offsetY: WearScreenUtil.scaledSize(9)
      })
      .scale({ y: this.scaleY }) // Y 轴缩放实现纵向翻转

      Text('点击抛硬币')
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor($r("app.color.FontIcon_Fore2"))
        .margin({ top: WearScreenUtil.scaledSize(14) })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.isFlipping) return;
      this.isFlipping = true;

      // 随机决定最终结果
      const finalResult = Random(0, 1, true) === 0;
      
      // 根据当前状态和最终结果，计算正确的翻转次数
      // 如果当前状态 == 最终结果，翻转次数应该是偶数（翻回来）
      // 如果当前状态 != 最终结果，翻转次数应该是奇数（翻过去）
      let flipCount = Random(2, 3, true); // 基础翻转 2-3 次
      const needOddFlips = this.showFront !== finalResult; // 是否需要奇数次翻转
      
      // 调整翻转次数的奇偶性
      if (needOddFlips && flipCount % 2 === 0) {
        flipCount++; // 需要奇数次，当前是偶数，加1
      } else if (!needOddFlips && flipCount % 2 !== 0) {
        flipCount++; // 需要偶数次，当前是奇数，加1
      }

      // 执行翻转动画
      this.performFlip(flipCount, finalResult);
    })
  }

  // 执行翻转动画
  private performFlip(remainingFlips: number, finalResult: boolean): void {
    if (remainingFlips <= 0) {
      // 翻转结束，确保显示最终结果
      this.showFront = finalResult;
      this.scaleY = 1;
      this.isFlipping = false;
      return;
    }

    // 第一阶段：缩小到 0（翻转一半）
    animateTo({
      duration: 200,
      curve: Curve.EaseIn,
      onFinish: () => {
        // 每次翻转都切换到另一面
        this.showFront = !this.showFront;
        
        // 第二阶段：从 0 放大到 1（翻转另一半）
        animateTo({
          duration: 200,
          curve: Curve.EaseOut,
          onFinish: () => {
            // 继续下一次翻转
            this.performFlip(remainingFlips - 1, finalResult);
          }
        }, () => {
          this.scaleY = 1;
        });
      }
    }, () => {
      this.scaleY = 0;
    });
  }
}
