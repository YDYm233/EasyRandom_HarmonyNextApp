import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 手表端 — 丢硬币
 * 点击硬币翻转动画随机选择正/反面
 */
@Component
export struct WearFlipCoin {
  @State coinFace: Resource = $r("app.media.coin1");
  @State angle: number = 0;
  private coinImages: Resource[] = [$r("app.media.coin1"), $r("app.media.coin2")];

  build() {
    Column() {
      Image(this.coinFace)
        .width(WearScreenUtil.mainImageWidth)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .borderRadius('50%')
        .clip(true)
        .rotate({ x: 1, angle: this.angle })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(WearScreenUtil.safePadding)
    .onClick(() => {
      this.coinFace = this.coinImages[Random(0, this.coinImages.length - 1, true)];
      animateTo({
        duration: 1000,
        iterations: 1,
        curve: Curve.Linear
      }, () => {
        this.angle = this.angle + Random(2, 3, true) * 180;
      });
    })
  }
}
