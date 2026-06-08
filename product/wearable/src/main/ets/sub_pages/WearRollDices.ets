import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 手表端 — 掷骰子
 * 点击骰子随机切换 1~6 点
 */
@Component
export struct WearRollDices {
  @State diceImageIndex: Resource = $r("app.media.dice5");
  private diceImages: Resource[] = [
    $r("app.media.dice1"), $r("app.media.dice2"), $r("app.media.dice3"),
    $r("app.media.dice4"), $r("app.media.dice5"), $r("app.media.dice6")
  ];

  build() {
    Column() {
      Image(this.diceImageIndex)
        .width(WearScreenUtil.mainImageWidth)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .animation({ duration: 600 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(WearScreenUtil.safePadding)
    .onClick(() => {
      this.diceImageIndex = this.diceImages[Random(0, this.diceImages.length - 1, true)];
    })
  }
}
