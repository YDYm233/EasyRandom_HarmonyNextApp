import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 八卦占卜 — 点击旋转八卦符号，随机卜出一个卦象
 * 参考 default 项目 BaGuaCard
 */
@Component
export struct WearDevineBaGua {
  private readonly TRIGRAMS: string[] = [
    '☰', '☱', '☲', '☳', '☴', '☵', '☶', '☷'
  ];
  private readonly NAMES: string[] = [
    '乾', '兑', '离', '震', '巽', '坎', '艮', '坤'
  ];

  @State displayTri: string = '☯';
  @State displayName: string = '';
  @State angle: number = 0;

  private spin(): void {
    this.displayName = '';

    const extra: number = Random(0, 7, true) * 45 + 45 * 8;
    this.angle += extra;
    if (this.angle > 36000000) {
      this.angle = Random(0, 7, true) * 45 + 45 * 8;
    }

    animateTo({
      duration: 1200,
      curve: Curve.Ease,
      onFinish: () => {
        const steps: number = Math.round(this.angle / 45);
        const idx: number = ((steps % 8) + 8) % 8;
        this.displayTri = this.TRIGRAMS[idx];
        this.displayName = this.NAMES[idx];
      }
    }, () => { });
  }

  build() {
    Column() {
      // 八卦旋转盘
      Column() {
        Text(this.displayTri)
          .fontSize(WearScreenUtil.scaledSize(60))
          .fontColor(0xFFD4A017)
          .rotate({ angle: this.angle })
      }
      .width(WearScreenUtil.scaledSize(130))
      .height(WearScreenUtil.scaledSize(130))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(WearScreenUtil.scaledSize(65))
      .backgroundColor(0x22FFFFFF)

      // 卦名
      if (this.displayName !== '') {
        Text(this.displayName)
          .fontSize(WearScreenUtil.subFontSize + 6)
          .fontColor(0xFFD4A017)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 12 })
      }

      Text('点击占卜')
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0x66FFFFFF)
        .margin({ top: this.displayName !== '' ? 6 : 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.spin();
    })
  }
}
