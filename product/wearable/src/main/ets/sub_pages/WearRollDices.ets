import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 掷骰子 — 点击随机切换骰子面
 * 参考 default 项目 RollDiceCard，手表端使用 Unicode 骰子字符替代图片
 */
@Component
export struct WearRollDices {
  private readonly FACES: string[] = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
  @State face: string = '⚄';
  @State scale: number = 1;

  build() {
    Column() {
      // 骰子显示区
      Column() {
        Text(this.face)
          .fontSize(WearScreenUtil.scaledSize(80))
          .fontColor(0xFFFFFFFF)
          .scale({ x: this.scale, y: this.scale })
          .animation({ duration: 200, curve: Curve.Ease })
      }
      .width(WearScreenUtil.scaledSize(120))
      .height(WearScreenUtil.scaledSize(120))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 提示文字
      Text('点击投掷')
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0x66FFFFFF)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.face = this.FACES[Random(0, 5, true)];

      // 弹跳动画：放大 → 回弹
      animateTo({
        duration: 100,
        curve: Curve.EaseOut,
        onFinish: () => {
          animateTo({ duration: 150, curve: Curve.EaseIn }, () => {
            this.scale = 1;
          });
        }
      }, () => {
        this.scale = 1.3;
      });
    })
  }
}
