import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 抛硬币 — 点击触发 3D 翻转动画，随机显示正/反
 * 参考 default 项目 FlipCoinCard
 */
@Component
export struct WearFlipCoin {
  @State flipAngle: number = 0;
  @State result: string = '正';
  @State color: number = 0xFFFFD700;

  /** 开始翻硬币 */
  private flip(): void {
    const target = Random(0, 1, true) === 0 ? '正' : '反';

    animateTo({
      duration: 800,
      curve: Curve.EaseOut,
      onFinish: () => {
        this.result = target;
        this.color = target === '正' ? 0xFFFFD700 : 0xFFC0C0C0;
      }
    }, () => {
      this.flipAngle += 720;
    });
  }

  build() {
    Column() {
      // 硬币可视化
      Column() {
        Column() {
          Text(this.result)
            .fontSize(WearScreenUtil.resultFontSize)
            .fontColor(this.color)
            .fontWeight(FontWeight.Bold)
        }
        .width(WearScreenUtil.scaledSize(120))
        .height(WearScreenUtil.scaledSize(120))
        .borderRadius(WearScreenUtil.scaledSize(60))
        .backgroundColor(0xFF2B2B2B)
        .border({
          width: WearScreenUtil.scaledSize(3),
          color: this.color,
          style: BorderStyle.Solid
        })
        .justifyContent(FlexAlign.Center)
        .rotate({ x: 1, angle: this.flipAngle })
      }

      Text('点击抛硬币')
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0x66FFFFFF)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.flip();
    })
  }
}
