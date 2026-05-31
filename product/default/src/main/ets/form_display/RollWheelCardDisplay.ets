import { Random } from '@ohos/common'
import { Roll, RollItem, defaultRolls } from '../pages/RollPage/RollDataManager';

// @Entry
@Component
export struct RollWheelCardDisplay {
  readonly FULL_WIDTH_PERCENT: string = '90%';
  @State dataList: Roll[] = defaultRolls
  @State rotateAngle: number = 0;

  build() {
    Swiper() {
      ForEach(this.dataList, (roll: Roll) => {
        Row() {
          RollBox({ data: roll })
            .width(this.FULL_WIDTH_PERCENT)
            .aspectRatio(1)
            .animation({ duration: 600 })
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
          this.rotateAngle = this.rotateAngle + this.rotateAngle + Random(0, 360, true) + 360 * 8;
        })
      }, (roll: Roll) => roll.index)
    }
    .loop(true)
    .indicator(false)
  }
}

@Component
struct RollBox {
  @Prop data: Roll
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.canvasContext)
        .onReady(() => {
          const ctx = this.canvasContext
          ctx.clearRect(0, 0, ctx.width, ctx.width)
          const contextWidth = ctx.width
          const radius = contextWidth / 2
          const rollItems: Array<RollItem> = this.data.rollItems
          const totalWeight = rollItems.reduce<number>(
            (sum: number, rollItem: RollItem) => sum + rollItem.weight, 0)
          let startAngle = -rollItems[0].weight / totalWeight * 180 + 90

          rollItems.forEach((rollItem: RollItem) => {
            const endAngle: number = startAngle + (rollItem.weight / totalWeight) * 360
            const centerAngle = (startAngle + endAngle) / 2

            ctx.globalCompositeOperation = 'xor'
            ctx.beginPath()
            ctx.moveTo(radius, radius)
            ctx.arc(radius, radius, radius,
              startAngle * Math.PI / 180,
              endAngle * Math.PI / 180, false)
            ctx.closePath()
            ctx.fillStyle = rollItem.color
            ctx.fill()

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
      width: 8,
      color: $r("app.color.Comp_Bg4"),
      radius: '50%',
      style: BorderStyle.Solid
    })
  }
}

// export default RollWheelCard
