import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';

/**
 * ABCD 随机选择 — 2x2 四象限 + 旋转指针
 * 参考 default 项目 ABCDCard
 */
@Component
export struct WearRandomABCD {
  @State angle: number = 0;
  @State activeIndex: number = -1;

  private readonly CARD: number = WearScreenUtil.scaledSize(150);
  private readonly QUAD: number = this.CARD / 2;
  private readonly PNTR: number = WearScreenUtil.scaledSize(56);
  private readonly BG_NORMAL: number = 0xFF444444;
  private readonly BG_ACTIVE: number = 0xFFD4A017;

  /** 获取象限背景色 */
  private getQuadBg(idx: number): number {
    return idx === this.activeIndex ? this.BG_ACTIVE : this.BG_NORMAL;
  }

  /** 点击旋转 */
  private spin(): void {
    this.activeIndex = -1;

    const extra: number = Random(1, 360, true) + 360 * 3;
    this.angle += extra;
    if (this.angle > 36000000) {
      this.angle = Random(1, 360, true) + 360 * 3;
    }

    animateTo({
      duration: 1000,
      curve: Curve.Ease,
      onFinish: () => {
        let norm: number = Math.round(this.angle % 360);
        if (norm < 0) norm += 360;

        if (norm < 90) {
          this.activeIndex = 1; // B
        } else if (norm < 180) {
          this.activeIndex = 3; // D
        } else if (norm < 270) {
          this.activeIndex = 2; // C
        } else {
          this.activeIndex = 0; // A
        }
      }
    }, () => { });
  }

  build() {
    Column() {
      Stack() {
        // 四象限背景
        Stack() {
          // A — 左上
          Column() {
            Text('A')
              .fontSize(WearScreenUtil.subFontSize + 6)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(this.QUAD)
          .height(this.QUAD)
          .backgroundColor(this.getQuadBg(0))
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius({ topLeft: WearScreenUtil.scaledSize(12) })
          .position({ x: 0, y: 0 })

          // B — 右上
          Column() {
            Text('B')
              .fontSize(WearScreenUtil.subFontSize + 6)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(this.QUAD)
          .height(this.QUAD)
          .backgroundColor(this.getQuadBg(1))
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius({ topRight: WearScreenUtil.scaledSize(12) })
          .position({ x: this.QUAD, y: 0 })

          // C — 左下
          Column() {
            Text('C')
              .fontSize(WearScreenUtil.subFontSize + 6)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(this.QUAD)
          .height(this.QUAD)
          .backgroundColor(this.getQuadBg(2))
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius({ bottomLeft: WearScreenUtil.scaledSize(12) })
          .position({ x: 0, y: this.QUAD })

          // D — 右下
          Column() {
            Text('D')
              .fontSize(WearScreenUtil.subFontSize + 6)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(this.QUAD)
          .height(this.QUAD)
          .backgroundColor(this.getQuadBg(3))
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius({ bottomRight: WearScreenUtil.scaledSize(12) })
          .position({ x: this.QUAD, y: this.QUAD })
        }
        .width(this.CARD)
        .height(this.CARD)
        .borderRadius(WearScreenUtil.scaledSize(12))

        // 旋转指针
        Image($r("app.media.pointer_m"))
          .width(this.PNTR)
          .height(this.PNTR)
          .fillColor(0xFFD4A017)
          .rotate({ angle: this.angle })
          .position({
            x: (this.CARD - this.PNTR) / 2,
            y: (this.CARD - this.PNTR) / 2
          })
      }
      .width(this.CARD)
      .height(this.CARD)

      Text('点击转盘')
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0x66FFFFFF)
        .margin({ top: 16 })
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
