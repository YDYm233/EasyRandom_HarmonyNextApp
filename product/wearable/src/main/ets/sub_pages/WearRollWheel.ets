import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';
import { Roll, RollItem, defaultRolls } from '../utils/WearRollDataManager';

/**
 * 手表端 — 幸运转盘
 * Canvas 绘制扇形转盘 + Swiper 切换多个转盘
 */
@Component
export struct WearRollWheel {
  @State rotateAngle: number = 0;
  private dataList: Roll[] = defaultRolls;

  build() {
    Swiper() {
      ForEach(this.dataList, (roll: Roll, idx: number) => {
        Column() {
          Stack() {
            RollBoxCanvas({ data: roll, rotateAngle: this.rotateAngle })
              .width(WearScreenUtil.scaledSize(260))
              .aspectRatio(1)

            // 中心指针
            Image($r("app.media.pointer_m"))
              .zIndex(8)
              .width(WearScreenUtil.scaledSize(80))
              .aspectRatio(1)
              .fillColor($r("app.color.FontIcon_Back1"))
          }

          Text(roll.rollName)
            .fontSize(WearScreenUtil.subFontSize)
            .fontColor($r("app.color.FontIcon_Fore1"))
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding(WearScreenUtil.safePadding)
        .onClick(() => {
          this.rotateAngle = this.rotateAngle + Random(0, 360, true) + 360 * 8;
        })
      }, (roll: Roll) => roll.index)
    }
    .loop(true)
    .indicator(true)
  }
}

/**
 * Canvas 转盘扇形绘制
 */
@Component
struct RollBoxCanvas {
  @Prop data: Roll;
  @Prop rotateAngle: number;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private drawWheel(): void {
    const ctx = this.canvasContext;
    const canvasWidth = ctx.width;
    if (canvasWidth <= 0) return;
    ctx.clearRect(0, 0, canvasWidth, canvasWidth);

    const radius = canvasWidth / 2;
    const items: Array<RollItem> = this.data.rollItems;
    if (items.length === 0) return;

    const totalWeight = items.reduce<number>((sum, item) => sum + item.weight, 0);
    if (totalWeight === 0) return;

    let startAngle = -items[0].weight / totalWeight * 180 + 90;

    items.forEach((item: RollItem) => {
      const endAngle: number = startAngle + (item.weight / totalWeight) * 360;
      const centerAngle = (startAngle + endAngle) / 2;

      ctx.globalCompositeOperation = 'xor';
      ctx.beginPath();
      ctx.moveTo(radius, radius);
      ctx.arc(radius, radius, radius,
        startAngle * Math.PI / 180,
        endAngle * Math.PI / 180, false);
      ctx.closePath();
      ctx.fillStyle = item.color;
      ctx.fill();

      // 文字
      ctx.fillStyle = '#FFFFFF';
      ctx.textAlign = 'center';
      ctx.save();
      ctx.translate(radius, radius);
      ctx.rotate((centerAngle + 90) * Math.PI / 180);

      const chars: Array<string> = item.text.split('');
      const lineHeight = (radius * 0.7) / (chars.length + 1);
      const fontSizePx = lineHeight * 0.9;
      ctx.font = `${fontSizePx}vp`;

      const startY = -(radius * 0.55) + lineHeight;
      for (let i = 0; i < chars.length; i++) {
        ctx.fillText(chars[i], 0, startY + i * lineHeight);
      }
      ctx.restore();

      startAngle = endAngle;
    });

    // 中心圆
    ctx.beginPath();
    ctx.moveTo(radius, radius);
    ctx.arc(radius, radius, radius / 10, -45, 275, false);
    ctx.closePath();
    ctx.fillStyle = '#f1f3f5';
    ctx.fill();
  }

  build() {
    Canvas(this.canvasContext)
      .onReady(() => this.drawWheel())
      .width('100%')
      .aspectRatio(1)
  }
}
