import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * 手表端 — ABCD 选择器
 * 四格直铺布局 + 旋转指针（简化版，手表屏幕空间优先）
 */
@Component
export struct WearRandomABCD {
  @State angle: number = 30;
  @State highlightIndex: number = -1; // -1 = 无高亮

  build() {
    Stack() {
      // ABCD 四格
      Column() {
        Row() {
          this.buildCell('A', 0);
          this.buildCell('B', 1);
        }
        Row() {
          this.buildCell('C', 2);
          this.buildCell('D', 3);
        }
      }
      .width('100%')
      .height('100%')

      // 旋转指针
      Image($r("app.media.needle"))
        .width(WearScreenUtil.scaledSize(60))
        .aspectRatio(1)
        .fillColor($r("app.color.FontIcon_Fore2"))
        .rotate({ angle: this.angle })
        .animation({ duration: 800, curve: Curve.Ease })
    }
    .width('100%')
    .height('100%')
    .padding(WearScreenUtil.safePadding)
    .onClick(() => {
      this.highlightIndex = -1;
      this.angle += Random(1, 360, true) + 360 * 3;
      if (this.angle > 36000000) {
        this.angle = Random(1, 360, true) + 360 * 3;
      }
      // 延迟高亮结果
      const finalAngle = this.angle;
      setTimeout(() => {
        const mod = finalAngle % 360;
        if (mod < 90) this.highlightIndex = 3;      // D
        else if (mod < 180) this.highlightIndex = 2; // C
        else if (mod < 270) this.highlightIndex = 1; // B
        else this.highlightIndex = 0;                 // A
      }, 900);
    })
  }

  @Builder
  buildCell(label: string, index: number) {
    Text(label)
      .width('50%')
      .height('50%')
      .fontSize(WearScreenUtil.resultFontSize)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.highlightIndex === index ?
        $r("app.color.Brand") : $r("app.color.Comp_Bg4"))
      .fontColor(this.highlightIndex === index ?
        Color.White : $r("app.color.FontIcon_Fore1"))
  }
}
