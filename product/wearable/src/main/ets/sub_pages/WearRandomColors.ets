import { Random, ExColor } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 随机颜色 — 点击生成随机颜色并显示颜色代码
 * 参考 default 项目 RandomColorsCardDisplay
 */
@Component
export struct WearRandomColors {
  @State rgba: string = 'rgba(187,255,204,1)';
  @State colorCode: string = '#BBFFCC';
  @State textColor: string = 'rgba(0,0,0,1)';

  build() {
    Column() {
      Text(this.colorCode)
        .fontSize(WearScreenUtil.scaledSize(32))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textColor)
        .textCase(TextCase.UpperCase)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.rgba)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .animation({ duration: 400, curve: Curve.Ease })
    .onClick(() => {
      this.generateRandomColor();
    })
  }

  // 生成随机颜色
  private generateRandomColor(): void {
    const RR = Random(0, 255, true);
    const GG = Random(0, 255, true);
    const BB = Random(0, 255, true);
    const AA = Random(0, 255, false);

    // 生成 RGBA 颜色字符串
    this.rgba = `rgba(${RR},${GG},${BB},${(AA / 255).toFixed(2)})`;

    // 生成颜色代码（HEX格式）
    this.colorCode = ExColor(this.rgba);

    // 根据亮度自动选择文字颜色
    // 亮度计算：R+G+B >= 382 为亮色，使用黑字；否则使用白字
    if (RR + GG + BB >= 382) {
      this.textColor = 'rgba(0,0,0,1)';
    } else {
      this.textColor = 'rgba(255,255,255,1)';
    }
  }
}
