import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 手表端 — 八卦占卜
 * 点击八卦图随机旋转
 */
@Component
export struct WearDevineBaGua {
  @State rotateAngle: number = 0;

  build() {
    Column() {
      Image($r("app.media.BaGua"))
        .width(WearScreenUtil.mainImageWidth)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .borderRadius(24)
        .clip(true)
        .rotate({ angle: this.rotateAngle })
        .animation({ duration: 1000, curve: Curve.Ease })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(WearScreenUtil.safePadding)
    .onClick(() => {
      this.rotateAngle = this.rotateAngle + Random(0, 7, true) * 45 + 45 * 18;
    })
  }
}
