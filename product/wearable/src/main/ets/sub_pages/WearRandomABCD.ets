import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * ABCD 随机选择 — 2x2 四象限 + 旋转指针
 * 参考 default 项目 ABCDCardDisplay
 */
@Component
export struct WearRandomABCD {
  @State angle: number = 30;
  @State duration: number = 800;
  @State colors: Resource[] = [
    $r("app.color.Comp_Bg4"),
    $r("app.color.Comp_Bg4"),
    $r("app.color.Comp_Bg4"),
    $r("app.color.Comp_Bg4")
  ];
  @State fontColors: Resource[] = [
    $r("app.color.FontIcon_Fore1"),
    $r("app.color.FontIcon_Fore1"),
    $r("app.color.FontIcon_Fore1"),
    $r("app.color.FontIcon_Fore1")
  ];

  private readonly CARD: number = WearScreenUtil.scaledSize(216);
  private readonly QUAD: number = this.CARD / 2;
  private readonly PNTR: number = WearScreenUtil.scaledSize(72);
  private readonly BORDER: number = WearScreenUtil.scaledSize(5);
  private readonly RADIUS: number = WearScreenUtil.scaledSize(20);
  private readonly FONT_SIZE: number = WearScreenUtil.scaledSize(43);

  build() {
    Column() {
      Stack() {
        // 四象限背景
        Stack() {
          // A — 左上
          Text('A')
            .width(this.QUAD)
            .height(this.QUAD)
            .backgroundColor(this.colors[0])
            .fontColor(this.fontColors[0])
            .fontWeight(FontWeight.Bold)
            .fontSize(this.FONT_SIZE)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: this.BORDER,
              color: $r("app.color.Comp_Bg2"),
              radius: { topLeft: this.RADIUS }
            })
            .clip(true)
            .position({ x: 0, y: 0 })

          // B — 右上
          Text('B')
            .width(this.QUAD)
            .height(this.QUAD)
            .backgroundColor(this.colors[1])
            .fontColor(this.fontColors[1])
            .fontWeight(FontWeight.Bold)
            .fontSize(this.FONT_SIZE)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: this.BORDER,
              color: $r("app.color.Comp_Bg2"),
              radius: { topRight: this.RADIUS }
            })
            .clip(true)
            .position({ x: this.QUAD, y: 0 })

          // C — 左下
          Text('C')
            .width(this.QUAD)
            .height(this.QUAD)
            .backgroundColor(this.colors[2])
            .fontColor(this.fontColors[2])
            .fontWeight(FontWeight.Bold)
            .fontSize(this.FONT_SIZE)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: this.BORDER,
              color: $r("app.color.Comp_Bg2"),
              radius: { bottomLeft: this.RADIUS }
            })
            .clip(true)
            .position({ x: 0, y: this.QUAD })

          // D — 右下
          Text('D')
            .width(this.QUAD)
            .height(this.QUAD)
            .backgroundColor(this.colors[3])
            .fontColor(this.fontColors[3])
            .fontWeight(FontWeight.Bold)
            .fontSize(this.FONT_SIZE)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: this.BORDER,
              color: $r("app.color.Comp_Bg2"),
              radius: { bottomRight: this.RADIUS }
            })
            .clip(true)
            .position({ x: this.QUAD, y: this.QUAD })
        }
        .width(this.CARD)
        .height(this.CARD)

        // 旋转指针（居中显示）
        Image($r("app.media.pointer_m"))
          .width(this.PNTR)
          .aspectRatio(1)
          .fillColor($r("app.color.FontIcon_Fore2"))
          .rotate({ angle: this.angle })
          .animation({ duration: this.duration, curve: Curve.Ease })
      }
      .width(this.CARD)
      .height(this.CARD)
      .alignContent(Alignment.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      // 重置所有颜色
      this.colors[0] = $r("app.color.Comp_Bg4");
      this.colors[1] = $r("app.color.Comp_Bg4");
      this.colors[2] = $r("app.color.Comp_Bg4");
      this.colors[3] = $r("app.color.Comp_Bg4");
      this.fontColors[0] = $r("app.color.FontIcon_Fore1");
      this.fontColors[1] = $r("app.color.FontIcon_Fore1");
      this.fontColors[2] = $r("app.color.FontIcon_Fore1");
      this.fontColors[3] = $r("app.color.FontIcon_Fore1");

      // 旋转指针
      this.angle += Random(1, 360, true) + 360 * 3;
      if (this.angle > 36000000) {
        this.angle = Random(1, 360, true) + 360 * 3;
      }

      // 延迟高亮结果
      animateTo({
        duration: 1,
        iterations: 1,
        curve: Curve.EaseIn,
        delay: 1000
      }, () => {
        const normAngle = this.angle % 360;
        if (normAngle < 90) {
          this.colors[1] = $r("app.color.Brand"); // B
        } else if (normAngle < 180) {
          this.colors[3] = $r("app.color.Brand"); // D
        } else if (normAngle < 270) {
          this.colors[2] = $r("app.color.Brand"); // C
        } else {
          this.colors[0] = $r("app.color.Brand"); // A
        }
      });
    })
  }
}
