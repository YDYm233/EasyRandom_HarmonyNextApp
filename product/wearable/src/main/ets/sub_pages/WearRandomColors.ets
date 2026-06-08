import { Random, ExColor } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 手表端 — 随机颜色
 * 全屏着色 + 居中显示色值文本
 */
@Component
export struct WearRandomColors {
  @State rgba: string = 'rgba(128,128,128,1)';
  @State textColor: string = 'rgba(255,255,255,1)';
  @State colorName: string = '#808080';

  build() {
    Stack() {
      Text(this.colorName)
        .fontSize(WearScreenUtil.resultFontSize)
        .fontWeight(700)
        .fontColor(this.textColor)
        .textCase(TextCase.UpperCase)
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding(WearScreenUtil.safePadding)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.rgba)
    .onClick(() => {
      const RR = Random(0, 255, true);
      const GG = Random(0, 255, true);
      const BB = Random(0, 255, true);
      this.rgba = `rgba(${RR},${GG},${BB},1)`;
      this.colorName = ExColor(this.rgba).toUpperCase();
      if ((RR + GG + BB) >= 382) {
        this.textColor = 'rgba(0,0,0,1)';
      } else {
        this.textColor = 'rgba(255,255,255,1)';
      }
    })
  }
}
