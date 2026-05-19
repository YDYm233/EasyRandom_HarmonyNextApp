import { Roll, RollItem } from "./RollDataManager"

@Component
export struct RollWheel {
  @Prop data: Roll
  @Prop boxWidth: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear(): void {

  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.context)
        .onReady(() => {
          let ctx = this.context;
          const radius = ctx.width / 2;
          let list: Array<RollItem> = this.data.rollItems
          let totalWeight = list.reduce<number>((acc: number, single: RollItem) => acc + single.weight, 0);
          let startAngle = -list[0].weight / totalWeight * 180 + 90;

          list.forEach(single => {
            const endAngle: number = startAngle + (single.weight / totalWeight) * 360;
            const centerAngle = (startAngle + endAngle) / 2;
            ctx.beginPath();
            ctx.moveTo(radius, radius);
            ctx.arc(radius, radius, radius, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);
            ctx.closePath()
            ctx.fillStyle = single.color;
            ctx.fill();
            ctx.fillStyle = '#FFFFFF';
            ctx.textAlign = 'center';

            ctx.save()
            ctx.translate(radius, radius)
            ctx.rotate((centerAngle + 90) * Math.PI / 180)
            const texts: Array<string> = single.text.split('');
            const x = 0;
            const y = radius * 0.1 + (radius * 0.1 / texts.length);
            const lineHight = (radius - y) / (texts.length + 1)
            const fontSize = lineHight
            const font = fontSize.toString() + 'vp';
            ctx.font = font;
            for (let n: number = 0; n < texts.length; n++) {
              ctx.fillText(texts[n], x, (-radius + lineHight + y / 2 + n * lineHight), fontSize);
            }
            ctx.restore()

            startAngle = endAngle;
          })

          ctx.beginPath();
          ctx.moveTo(radius, radius);
          ctx.arc(radius, radius, radius / 10, -45, 275, false);
          ctx.closePath()
          ctx.fillStyle = 0xf1f3f5;
          ctx.fill();
        })
        .width('100%')
        .aspectRatio(1)

    }.width('100%').aspectRatio(1)
    .border({
      width: 10,
      color: $r("app.color.Comp_Bg3"),
      radius: '50%',
      style: BorderStyle.Solid
    })

  }
}