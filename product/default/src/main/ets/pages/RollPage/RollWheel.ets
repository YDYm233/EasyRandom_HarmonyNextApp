import { Roll, RollItem } from "./RollDataManager"

@Component
export struct RollWheel {
  @Prop data: Roll
  @Prop boxWidth: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.canvasContext)
        .onReady(() => {
          const ctx = this.canvasContext
          const radius = ctx.width / 2
          const rollItems: Array<RollItem> = this.data.rollItems
          const totalWeight = rollItems.reduce<number>(
            (sum: number, rollItem: RollItem) => sum + rollItem.weight, 0)
          let startAngle = -rollItems[0].weight / totalWeight * 180 + 90

          rollItems.forEach((rollItem: RollItem) => {
            const sweepAngle: number = (rollItem.weight / totalWeight) * 360
            const endAngle: number = startAngle + sweepAngle
            const centerAngle = (startAngle + endAngle) / 2

            // 绘制扇形
            ctx.beginPath()
            ctx.moveTo(radius, radius)
            ctx.arc(radius, radius, radius,
              startAngle * Math.PI / 180,
              endAngle * Math.PI / 180, false)
            ctx.closePath()
            ctx.fillStyle = rollItem.color
            ctx.fill()

            // 绘制文字
            ctx.fillStyle = '#FFFFFF'
            ctx.textAlign = 'center'
            ctx.save()
            ctx.translate(radius, radius)
            ctx.rotate((centerAngle + 90) * Math.PI / 180)

            const chars: Array<string> = rollItem.text.split('')
            const topOffset = radius * 0.1 + (radius * 0.1 / chars.length)
            const lineHeight = (radius - topOffset) / (chars.length + 1)
            const fontSizePx = lineHeight
            ctx.font = fontSizePx.toString() + 'vp'

            for (let i: number = 0; i < chars.length; i++) {
              ctx.fillText(chars[i], 0,
                (-radius + lineHeight + topOffset / 2 + i * lineHeight),
                fontSizePx)
            }
            ctx.restore()

            startAngle = endAngle
          })

          // 中心圆
          ctx.beginPath()
          ctx.moveTo(radius, radius)
          ctx.arc(radius, radius, radius / 10, -45, 275, false)
          ctx.closePath()
          ctx.fillStyle = 0xf1f3f5
          ctx.fill()
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
