import {Random} from '@ohos/common'
import { Roll, RollItem, rolls } from '../datas/rolls';
@Entry
@Component
struct RollWheelCard {
  readonly FULL_WIDTH_PERCENT: string = '90%';
  @State coinImageArray: Resource[] = [$r("app.media.coin1"), $r("app.media.coin2")]
  @State rotateAngle:number = 0;
  build() {
    Row() {
      RollBox({data:rolls[0]})
        .width(this.FULL_WIDTH_PERCENT)
        .aspectRatio(1)
        .animation({duration:600})
        .rotate({
          angle: this.rotateAngle
        })
        .animation({ duration: 1000, curve: Curve.Ease })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.rotateAngle =this.rotateAngle+this.rotateAngle+ Random(0, 360, true) + 360 * 8;
    })
  }
}
@Component
struct RollBox {
  @Prop data: Roll
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.context)
        .onReady(() => {
          let ctx = this.context;
          console.log('ctx.width:' + ctx.width)
          ctx.clearRect(0, 0, ctx.width, ctx.width)
          const contextWidth = ctx.width;
          const r = contextWidth / 2;
          let list: Array<RollItem> = this.data.rollItems
          let totalWeight = list.reduce<number>((acc: number, single: RollItem) => acc + single.weight, 0);
          let startAngle = -list[0].weight / totalWeight * 180 + 90;
          list.forEach(single => {
            const endAngle: number = startAngle + (single.weight / totalWeight) * 360;
            const centerAngle = (startAngle + endAngle) / 2;
            ctx.globalCompositeOperation = 'xor'
            ctx.beginPath();
            ctx.moveTo(r, r); // 中心点
            ctx.arc(r, r, r, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);
            ctx.closePath()
            ctx.fillStyle = single.color;
            ctx.fill();
            ctx.fillStyle = '#FFFFFF';
            ctx.textAlign = 'center';
            ctx.save()
            ctx.translate(r, r)
            ctx.rotate((centerAngle + 90) * Math.PI / 180)
            let texts: Array<string> = single.text.split('');
            const x = 0;
            const y = r * 0.1 + (r * 0.1 / texts.length);
            const lineHight = (r - y) / (texts.length + 1)
            const fontSize = lineHight
            const font = fontSize.toString() + 'vp';
            ctx.font = font;
            for (let n: number = 0; n < texts.length; n++) {
              ctx.fillText(texts[n], x, (-r + lineHight + y / 2 + n * lineHight), fontSize);
            }
            ctx.restore()
            startAngle = endAngle;
          })
          ctx.beginPath();
          ctx.moveTo(r, r); // 中心点
          ctx.arc(r, r, r / 10, -45, 275, false);
          ctx.closePath()
          ctx.fillStyle = 0xf1f3f5;
          ctx.fill();
        })
        .width('100%')
        .aspectRatio(1)
    }.width('100%').aspectRatio(1)
    .border({
      width: 8,
      color: 0xf1f3f5,
      radius: '50%',
      style: BorderStyle.Solid
    })
  }
}