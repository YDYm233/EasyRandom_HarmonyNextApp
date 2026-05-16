import BaGuaCard from '../widgets/BaGuaCard'
import FlipCoinCard from '../widgets/FlipCoinCard'
import RandomColorsCard from '../widgets/RandomColorsCard'
import RollBlessingsCard from '../widgets/RollBlessingsCard'
import RollDiceCard from '../widgets/RollDiceCard'
import RollWheelCard from '../widgets/RollWheelCard'
@Entry
@Component
struct AllasOne {
  private titleFontColor = 0x333333
  private  titleFontSize = 16
  build() {
    GridRow({
      columns: {
        sm: 4,
        md: 8,
        lg: 12
      },
      gutter: 24
    }) {


      //八卦
      GridCol({
        span: 2,
        offset: 0
      }) {
        Column() {
          BaGuaCard()
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(0xffffff)
            .borderRadius(24)
            .clip(true)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          Row() {
            Text($r("app.string.BaGuaCard_display_name"))
              .textAlign(TextAlign.Center)
              .fontSize(this.titleFontSize)
              .fontColor(this.titleFontColor)
              .border({style:BorderStyle.Solid,width:1,color:0xfffffff})
          }
          .width('100%')
          .aspectRatio(5)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          //.backgroundColor(0x00ff00)
        }
        .width('100%')
        .height('100%')
       // .backgroundColor(0x0000ff)
      }
    //  .backgroundColor(0xff0000)
      .aspectRatio(10/12)

      //硬币
      GridCol({
        span: 2,
        offset: 0
      }) {
        Column() {
          FlipCoinCard()
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(0xffffff)
            .borderRadius(24)
            .clip(true)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          Row() {
            Text($r("app.string.FlipCoinCard_display_name"))
              .textAlign(TextAlign.Center)
              .fontSize(this.titleFontSize)
              .fontColor(this.titleFontColor)
              .border({style:BorderStyle.Solid,width:1,color:0xfffffff})
          }
          .width('100%')
          .aspectRatio(5)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }
      .aspectRatio(10/12)

      //骰子
      GridCol({
        span: 2,
        offset: 0
      }) {
        Column() {
          RollDiceCard()
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(0xffffff)
            .borderRadius(24)
            .clip(true)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          Row() {
            Text($r("app.string.RollDiceCard_display_name"))
              .textAlign(TextAlign.Center)
              .fontSize(this.titleFontSize)
              .fontColor(this.titleFontColor)
              .border({style:BorderStyle.Solid,width:1,color:0xfffffff})
          }
          .width('100%')
          .aspectRatio(5)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }
      .aspectRatio(10/12)

      //颜色
      GridCol({
        span: 2,
        offset: 0
      }) {
        Column() {
          RandomColorsCard()
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(0xffffff)
            .borderRadius(24)
            .clip(true)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          Row() {
            Text($r("app.string.RandomColorsCard_display_name"))
              .textAlign(TextAlign.Center)
              .fontSize(this.titleFontSize)
              .fontColor(this.titleFontColor)
              .border({style:BorderStyle.Solid,width:1,color:0xfffffff})
          }
          .width('100%')
          .aspectRatio(5)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }
      .aspectRatio(10/12)


      //转盘
      GridCol({
        span: 2,
        offset: 0
      }) {
        Column() {
          RollWheelCard()
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(0xffffff)
            .borderRadius(24)
            .clip(true)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          Row() {
            Text($r("app.string.RollWheelCard_display_name"))
              .textAlign(TextAlign.Center)
              .fontSize(this.titleFontSize)
              .fontColor(this.titleFontColor)
              .border({style:BorderStyle.Solid,width:1,color:0xfffffff})
          }
          .width('100%')
          .aspectRatio(5)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }
      .aspectRatio(10/12)


      //木鱼
      GridCol({
        span: 2,
        offset: 0
      }) {
        Column() {
          RollBlessingsCard()
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(0xffffff)
            .borderRadius(24)
            .clip(true)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          Row() {
            Text($r("app.string.RollBlessingsCard_display_name"))
              .textAlign(TextAlign.Center)
              .fontSize(this.titleFontSize)
              .fontColor(this.titleFontColor)
              .border({style:BorderStyle.Solid,width:1,color:0xfffffff})
          }
          .width('100%')
          .aspectRatio(5)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }
      .aspectRatio(10/12)

      //转盘
      GridCol({
        span: 4,
        offset: 0
      }) {
        Column() {
          RollWheelCard()
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(0xffffff)
            .borderRadius(24)
            .clip(true)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          Row() {
            Text($r("app.string.RollWheelCard_display_name"))
              .textAlign(TextAlign.Center)
              .fontSize(this.titleFontSize)
              .fontColor(this.titleFontColor)
              .border({style:BorderStyle.Solid,width:1,color:0xfffffff})
          }
          .width('100%')
          .aspectRatio(10)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }
      .aspectRatio(10/11)



    }
    .padding(24)
    .backgroundColor(0xf1f3f5)
    .width('100%')

    .height('100%')
    .width('100%')
  }
}
export default AllasOne