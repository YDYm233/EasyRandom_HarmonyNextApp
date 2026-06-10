// product/wearable/src/main/ets/sub_pages/WearRollWheel.ets
import { ArcSwiper, ArcSwiperController } from '@kit.ArkUI';
import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';
import { Roll, RollItem, defaultRolls } from '../utils/WearRollDataManager';

@Component
export struct WearRollWheel {
  @State dataList: Roll[] = defaultRolls;
  @State dataVersion: number = 0;
  @State rotateAngle: number = 0;
  @State isSpinning: boolean = false;
  @State currentRollIndex: number = 0;
  @State resultText: string = '';

  private arcController: ArcSwiperController = new ArcSwiperController();
  private swiperController: SwiperController = new SwiperController();

  build() {
    if (WearScreenUtil.isRoundScreen()) {
      this.buildRoundLayout();
    } else {
      this.buildSquareLayout();
    }
  }

  @Builder
  buildRoundLayout() {
    ArcSwiper(this.arcController) {
      ForEach(this.dataList, (roll: Roll, index: number) => {
        this.buildSingleWheel(roll, index);
      }, (roll: Roll): string => `${roll.index}_v${this.dataVersion}`)
    }
    .vertical(true)
    .indicator(false)
    .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
    .onChange((index: number) => {
      this.currentRollIndex = index;
    })
  }

  @Builder
  buildSquareLayout() {
    Swiper(this.swiperController) {
      ForEach(this.dataList, (roll: Roll, index: number) => {
        this.buildSingleWheel(roll, index);
      }, (roll: Roll): string => `${roll.index}_v${this.dataVersion}`)
    }
    .vertical(true)
    .indicator(true)
    .onChange((index: number) => {
      this.currentRollIndex = index;
    })
  }

  @Builder
  buildSingleWheel(roll: Roll, index: number) {
    Column() {
      Text(roll.rollName)
        .fontSize(WearScreenUtil.buttonFontSize)
        .fontColor(0xFFD4A017)
        .fontWeight(FontWeight.Bold)
        .margin({ top: WearScreenUtil.safePadding, bottom: 8 })

      Stack() {
        RollBox({
          roll: roll,
          rotateAngle: this.rotateAngle,
          canvasSize: WearScreenUtil.scaledSize(260)
        })
          .width(WearScreenUtil.scaledSize(260))
          .height(WearScreenUtil.scaledSize(260))

        Text('▼')
          .fontSize(WearScreenUtil.buttonFontSize * 1.5)
          .fontColor(0xFFFFD700)
          .position({ x: '50%', y: 0 })
          .translate({ x: '-50%', y: -4 })
          .rotate({ angle: 180 })
      }
      .width(WearScreenUtil.scaledSize(260))
      .height(WearScreenUtil.scaledSize(260))

      if (this.resultText.length > 0 && this.currentRollIndex === index) {
        Text(this.resultText)
          .fontSize(WearScreenUtil.subFontSize)
          .fontColor(0xFF00FF00)
          .margin({ top: 8 })
      }

      Text('点击转盘开始')
        .fontSize(WearScreenUtil.subFontSize - 2)
        .fontColor(0x66FFFFFF)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.isSpinning) return;
      this.isSpinning = true;
      this.resultText = '';
      const targetAngle: number = this.rotateAngle + 360 * 8 + Random(0, 360, true);
      this.rotateAngle = targetAngle;
      setTimeout(() => {
        const normalizedAngle: number = targetAngle % 360;
        const pointerAngle: number = (360 - normalizedAngle) % 360;
        const sectorAngle: number = 360 / roll.rollItems.length;
        const hitIndex: number = Math.floor(pointerAngle / sectorAngle) % roll.rollItems.length;
        this.resultText = `🎉 ${roll.rollItems[hitIndex].text}`;
        this.isSpinning = false;
      }, 1100);
    })
  }

  aboutToDisappear(): void {
    this.arcController = null!;
    this.swiperController = null!;
  }
}

@Component
struct RollBox {
  @Prop roll: Roll;
  @Prop @Watch('onAngleChange') rotateAngle: number = 0;
  @Prop canvasSize: number = 260;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.drawWheel();
  }

  onAngleChange(): void {
    this.drawWheel();
  }

  private drawWheel(): void {
    const ctx: CanvasRenderingContext2D = this.canvasContext;
    const size: number = this.canvasSize;
    const cx: number = size / 2;
    const cy: number = size / 2;
    const radius: number = size / 2 - 4;

    ctx.clearRect(0, 0, size, size);

    const items: RollItem[] = this.roll.rollItems;
    if (!items || items.length === 0) return;

    const itemCount: number = items.length;
    const sectorAngleDeg: number = 360 / itemCount;
    const sectorAngleRad: number = (sectorAngleDeg * Math.PI) / 180;
    const offsetRad: number = (this.rotateAngle * Math.PI) / 180;

    for (let i: number = 0; i < itemCount; i++) {
      const startAngle: number = i * sectorAngleRad - Math.PI / 2 + offsetRad;
      const endAngle: number = startAngle + sectorAngleRad;

      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.arc(cx, cy, radius, startAngle, endAngle);
      ctx.closePath();
      ctx.fillStyle = items[i].color;
      ctx.fill();

      ctx.strokeStyle = 'rgba(255,255,255,0.3)';
      ctx.lineWidth = 1;
      ctx.stroke();

      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(startAngle + sectorAngleRad / 2);
      ctx.fillStyle = '#FFFFFF';
      ctx.font = `${WearScreenUtil.subFontSize}px sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      const textRadius: number = radius * 0.6;
      ctx.fillText(items[i].text, textRadius, 0);
      ctx.restore();
    }

    ctx.beginPath();
    ctx.arc(cx, cy, radius * 0.15, 0, Math.PI * 2);
    ctx.fillStyle = '#1a1a1a';
    ctx.fill();
    ctx.strokeStyle = 'rgba(255,255,255,0.5)';
    ctx.lineWidth = 2;
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(cx, cy, 3, 0, Math.PI * 2);
    ctx.fillStyle = '#FFD700';
    ctx.fill();
  }

  build() {
    Canvas(this.canvasContext)
      .width(this.canvasSize)
      .height(this.canvasSize)
  }

  aboutToDisappear(): void {
    this.canvasContext = null!;
  }
}
