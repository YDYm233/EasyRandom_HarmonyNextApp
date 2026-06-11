// ═════════════════════════════════════════════════
//  WearRollWheel — 幸运转盘（手表端）
//
//  参考: product/default/.../form_display/RollWheelCardDisplay.ets
//  差异: 纵向 Swiper 切换转盘 | 圆/方屏双容器 | 指针固定12点方向
// ═════════════════════════════════════════════════

import { ArcSwiper, ArcSwiperController } from '@kit.ArkUI';
import { Random } from '@ohos/common';
import WearScreenUtil from '../utils/WearScreenUtil';
import { Roll, RollItem, defaultRolls } from '../utils/WearRollDataManager';

@Component
export struct WearRollWheel {
  @State rotateAngles: number[] = Array(defaultRolls.length).fill(0);
  @State isSpinning: boolean = false;
  @State currentIndex: number = 0;
  @State showResult: string = '';
  @State pointerSize: number = 75; // 指针尺寸，默认值

  private arcController: ArcSwiperController = new ArcSwiperController();
  private swiperController: SwiperController = new SwiperController();

  private get wheelSize(): number {
    return WearScreenUtil.scaledSize(247);
  }

  aboutToAppear(): void {
    this.pointerSize = WearScreenUtil.scaledSize(75);
  }

  build() {
    if (WearScreenUtil.isRoundScreen()) {
      this.buildRoundLayout();
    } else {
      this.buildSquareLayout();
    }
  }

  // ════════ 圆形屏：ArcSwiper 纵向 ════════
  @Builder
  buildRoundLayout() {
    ArcSwiper(this.arcController) {
      ForEach(defaultRolls, (roll: Roll, index: number) => {
        this.buildSingleWheel(roll, index);
      }, (roll: Roll): string => roll.index)
    }
    .vertical(true)
    .indicator(false)
    .digitalCrownSensitivity(CrownSensitivity.MEDIUM)
    .onChange((idx: number) => {
      this.currentIndex = idx;
    })
    .width('100%')
    .height('100%')
  }

  // ════════ 方形屏：普通 Swiper 纵向 ════════
  @Builder
  buildSquareLayout() {
    Swiper(this.swiperController) {
      ForEach(defaultRolls, (roll: Roll, index: number) => {
        this.buildSingleWheel(roll, index);
      }, (roll: Roll): string => roll.index)
    }
    .vertical(true)
    .loop(true)
    .indicator(false)
    .onChange((idx: number) => {
      this.currentIndex = idx;
    })
    .width('100%')
    .height('100%')
  }

  // ════════ 单个转盘页 ════════
  @Builder
  buildSingleWheel(roll: Roll, index: number) {
    Column() {
      // 转盘 + 指针：Stack 叠加
      Stack({ alignContent: Alignment.Center }) {
        // 底层：转盘（仅它旋转）
        RollBox({ roll: roll })
          .width(this.wheelSize)
          .aspectRatio(1)
          .rotate({ angle: this.rotateAngles[index] })

        // 顶层：指针 SVG（居中叠加，固定不动）
        Image($r("app.media.pointer_m"))
          .width(this.pointerSize)
          .height(this.pointerSize)
      }
      .width(this.wheelSize)
      .height(this.wheelSize)
      .margin({ top: 4 })

      // 结果/提示文字（淡入动效）
      Column() {
        if (this.showResult.length > 0 && this.currentIndex === index) {
          Text(this.showResult)
            .fontSize(WearScreenUtil.subFontSize)
            .fontColor(0xFF00FF00)
        } else {
          Text('点击转盘开始')
            .fontSize(WearScreenUtil.subFontSize - 2)
            .fontColor(0x66FFFFFF)
        }
      }
      .height(28)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.spinWheel(roll, index);
    })
  }

  // ════════ 旋转逻辑 ════════
  private spinWheel(roll: Roll, index: number): void {
    if (this.isSpinning) {
      return;
    }
    this.isSpinning = true;
    this.showResult = '';

    const oldAngle = this.rotateAngles[index];
    const randomOffset = Random(0, 360, true);
    const fullSpins = 360 * 8;
    const newAngle = oldAngle + fullSpins + randomOffset;

    animateTo({
      duration: 1000,
      curve: Curve.Ease,
      onFinish: () => {
        this.calculateResult(roll, newAngle);
      }
    }, () => {
      const updated = [...this.rotateAngles];
      updated[index] = newAngle;
      this.rotateAngles = updated;
    })
  }

  // ════════ 结果判定（权重感知 + 同 default 模块绘制逻辑） ════════
  private calculateResult(roll: Roll, finalAngle: number): void {
    const items = roll.rollItems;
    if (!items || items.length === 0) {
      this.isSpinning = false;
      return;
    }

    const totalWeight = items.reduce((s: number, item: RollItem) => s + item.weight, 0);
    if (totalWeight <= 0) {
      this.isSpinning = false;
      return;
    }

    // 指针在 12 点钟方向，canvas 中对应 -90°（或 270°）
    // 转盘旋转 finalAngle 度，指针等效于反向移动
    let pointerDeg = (-90 - finalAngle) % 360;
    if (pointerDeg < 0) {
      pointerDeg += 360;
    }

    // 扇区边界（与 RollBox.drawWheel 绘制逻辑保持一致）
    // 第一个扇区起始角 = -w0/totalW * 180 + 90
    let sectorStartDeg = -(items[0].weight / totalWeight) * 180 + 90;
    let hitIndex = 0;

    for (let i = 0; i < items.length; i++) {
      const sectorSizeDeg = (items[i].weight / totalWeight) * 360;
      const sectorEndDeg = sectorStartDeg + sectorSizeDeg;

      // 归一化到 [0, 360)
      const startNorm = ((sectorStartDeg % 360) + 360) % 360;
      const endNorm = ((sectorEndDeg % 360) + 360) % 360;

      if (startNorm <= endNorm) {
        // 扇区不跨越 0°
        if (pointerDeg >= startNorm && pointerDeg < endNorm) {
          hitIndex = i;
          break;
        }
      } else {
        // 扇区跨越 360°/0°
        if (pointerDeg >= startNorm || pointerDeg < endNorm) {
          hitIndex = i;
          break;
        }
      }

      sectorStartDeg = sectorEndDeg;
    }

    this.showResult = `${items[hitIndex].text}`;
    this.isSpinning = false;
  }

  aboutToDisappear(): void {
    this.arcController = null!;
    this.swiperController = null!;
  }
}

// ═════════════════════════════════════════════════
//  RollBox — Canvas 转盘绘制（参考 default 模块）
//  遵循 default RollWheelCardDisplay 的绘制逻辑：
//    - 权重感知扇区
//    - 逐字符竖排文字
//    - onReady 触发首绘
// ═════════════════════════════════════════════════
@Component
struct RollBox {
  @Prop roll: Roll;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.canvasContext)
        .onReady(() => {
          this.drawWheel();
        })
        .width('100%')
        .aspectRatio(1)
    }
    .width('100%')
    .aspectRatio(1)
    .border({
      width: 8,
      color: $r("app.color.Comp_Bg4"),
      radius: '50%',
      style: BorderStyle.Solid
    })
  }

  private drawWheel(): void {
    const ctx = this.canvasContext;
    const canvasWidth = ctx.width;
    if (canvasWidth <= 0) {
      return;
    }

    ctx.clearRect(0, 0, canvasWidth, canvasWidth);

    const radius = canvasWidth / 2;
    const items = this.roll.rollItems;
    if (!items || items.length === 0) {
      return;
    }

    const totalWeight = items.reduce<number>(
      (sum: number, item: RollItem) => sum + item.weight, 0
    );
    if (totalWeight <= 0) {
      return;
    }

    // 扇区起始角（与 default 模块一致）
    // startAngle: -w0/totalW * 180 + 90（度）→ 12点位置
    let startAngleDeg = -(items[0].weight / totalWeight) * 180 + 90;

    items.forEach((item: RollItem, idx: number) => {
      const sectorSizeDeg = (item.weight / totalWeight) * 360;
      const endAngleDeg = startAngleDeg + sectorSizeDeg;
      const centerAngleDeg = (startAngleDeg + endAngleDeg) / 2;

      // 绘制扇区
      ctx.beginPath();
      ctx.moveTo(radius, radius);
      ctx.arc(
        radius, radius, radius,
        (startAngleDeg * Math.PI) / 180,
        (endAngleDeg * Math.PI) / 180,
        false
      );
      ctx.closePath();
      ctx.fillStyle = item.color;
      ctx.fill();

      // 扇区边框
      ctx.strokeStyle = 'rgba(255,255,255,0.15)';
      ctx.lineWidth = 1;
      ctx.stroke();

      // 逐字符竖排文字（参考 default 模块）
      const chars = item.text.split('');
      ctx.fillStyle = '#FFFFFF';
      ctx.textAlign = 'center';
      ctx.save();
      ctx.translate(radius, radius);
      ctx.rotate(((centerAngleDeg + 90) * Math.PI) / 180);

      // 计算文字区域
      const textRadiusStart = radius * 0.1;
      const availableRadius = radius - textRadiusStart;
      const lineHeight = availableRadius / (chars.length + 1);
      const fontSizePx = Math.min(lineHeight, 16);

      ctx.font = `${fontSizePx}vp sans-serif`;
      for (let i = 0; i < chars.length; i++) {
        const y = -radius + lineHeight * (i + 1) + textRadiusStart;
        ctx.fillText(chars[i], 0, y);
      }
      ctx.restore();

      startAngleDeg = endAngleDeg;
    });

    // 中心装饰圆（参考 default 模块）
    ctx.beginPath();
    ctx.moveTo(radius, radius);
    ctx.arc(radius, radius, radius * 0.08, 0, Math.PI * 2);
    ctx.closePath();
    ctx.fillStyle = 0xEE1A1A1A;
    ctx.fill();
    ctx.strokeStyle = 'rgba(255,255,255,0.4)';
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  aboutToDisappear(): void {
    this.canvasContext = null!;
  }
}
