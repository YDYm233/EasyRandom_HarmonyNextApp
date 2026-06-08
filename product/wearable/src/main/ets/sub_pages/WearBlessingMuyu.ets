import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 手表端 — 祝福木鱼
 * 点击木鱼图片敲击，显示祝福文字 + 气泡动画
 */
@Component
export struct WearBlessingMuyu {
  private readonly BLESSINGS: string[] = [
    '幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐'
  ];
  private readonly LUCK: number[] = [
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3,
    5, 5,
    0
  ];
  private readonly COLOR_PRESETS: string[] = [
    '#D4A017', '#FF6B6B', '#FF8C00', '#FF1493', '#00CED1',
    '#7B68EE', '#FF4500', '#32CD32', '#FF69B4', '#00BFFF'
  ];

  @State blessingText: string = '点击木鱼';
  @State blessingColor: string = this.COLOR_PRESETS[0];
  @State bubbleScale: number = 1;
  @State bubbleTranslateY: number = 0;
  @State tapVersion: number = 0;

  build() {
    Column() {
      // 祝福文字
      Text(this.blessingText)
        .fontSize(WearScreenUtil.subFontSize)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.blessingColor)
        .scale({ x: this.bubbleScale, y: this.bubbleScale })
        .translate({ y: this.bubbleTranslateY })

      Blank()
        .height(WearScreenUtil.scaledSize(20))

      // 木鱼图片
      Image($r('app.media.MuYu'))
        .width(WearScreenUtil.mainImageWidth)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.tapVersion++;
          const version = this.tapVersion;
          const idx = Random(0, this.BLESSINGS.length - 1, true);
          const count = this.LUCK[Random(0, this.LUCK.length - 1, true)];
          this.blessingText = this.BLESSINGS[idx] + ' +' + count;
          this.blessingColor = this.COLOR_PRESETS[Random(0, this.COLOR_PRESETS.length - 1, true)];

          // 气泡弹跳动画
          this.bubbleScale = 0.6;
          this.bubbleTranslateY = 10;
          animateTo({
            duration: 250, curve: Curve.EaseOut,
            onFinish: () => {
              if (this.tapVersion !== version) return;
              animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
                this.bubbleScale = 1.0;
                this.bubbleTranslateY = 0;
              });
            }
          }, () => {
            this.bubbleScale = 1.06;
            this.bubbleTranslateY = -2;
          });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(WearScreenUtil.safePadding)
  }
}
