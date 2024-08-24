import BaGuaCard from '../widgets/BaGuaCard'
import FlipCoinCard from '../widgets/FlipCoinCardCard'
import RandomColorsCard from '../widgets/RandomColorsCard'
import RollBlessingsCard from '../widgets/RollBlessingsCard'
import RollDiceCard from '../widgets/RollDiceCard'
import RollWheelCard from '../widgets/RollWheelCard'
@Entry
@Component
struct All_as_One {


  build() {
    GridRow({
      columns: {
        sm: 4,
        md: 8,
        lg: 12
      },
      gutter: 12
    }) {
      GridCol({
        span: 2,
        offset: 0
      }) {
        BaGuaCard()
      }
      .aspectRatio(1)
      .backgroundColor(0xffffff)
      .borderRadius(24)
      .clip(true)
      GridCol({
        span: 2,
        offset: 0
      }) {
        FlipCoinCard()
      }
      .aspectRatio(1)
      .backgroundColor(0xffffff)
      .borderRadius(24)
      .clip(true)
      GridCol({
        span: 2,
        offset: 0
      }) {
        RollDiceCard()
      }
      .aspectRatio(1)
      .backgroundColor(0xffffff)
      .borderRadius(24)
      .clip(true)
      GridCol({
        span: 2,
        offset: 0
      }) {
        RandomColorsCard()
      }
      .aspectRatio(1)
      .backgroundColor(0xffffff)
      .borderRadius(24)
      .clip(true)
      GridCol({
        span: 2,
        offset: 0
      }) {
        RollWheelCard()
      }
      .aspectRatio(1)
      .backgroundColor(0xffffff)
      .borderRadius(24)
      .clip(true)
      GridCol({
        span: 2,
        offset: 0
      }) {
        RollBlessingsCard()
      }
      .aspectRatio(1)
      .backgroundColor(0xffffff)
      .borderRadius(24)
      .clip(true)
    }
    .height('100%')
    .padding(12)
    .backgroundColor(0xf1f3f5)
    .height('100%')
    .width('100%')
  }
}