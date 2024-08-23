import { SymbolGlyphModifier } from '@kit.ArkUI'

@Component
struct Container {
  @State text: string = "选择"
  @State index: number = 2
  @State space: number = 8
  @State arrowPosition: ArrowPosition = ArrowPosition.END
  @State symbolModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.ohos_star')).fontColor([Color.Green]);
  @State symbolModifier2: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.ohos_star')).fontColor([Color.Yellow]);
  @State symbolModifier3: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.heart')).fontColor([Color.Red]);
  build() {
    Column() {
      Row() {
        Text('题库强度')
        Select([{ value: '基础', symbolIcon: this.symbolModifier1 },
          { value: '热烈', symbolIcon: this.symbolModifier2 },
          { value: '情侣', symbolIcon: this.symbolModifier3 }])
          .selected(this.index)
          .value(this.text)
          .font({ size: 16, weight: 500 })
          .fontColor(0x182431)
          .selectedOptionFont({ size: 16, weight: 400 })
          .optionFont({ size: 16, weight: 400 })
          .space(this.space)
          .arrowPosition(this.arrowPosition)
          .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
          .onSelect((index: number, text?: string | undefined) => {
            console.info('Select:' + index)
            this.index = index;
            if (text) {
              this.text = text;
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding('6%')
      .alignItems(VerticalAlign.Center)
      .backgroundColor(0xffffff)
      .borderRadius(12)
      .width('90%')
    }.width('100%')
  }
}

@Component
struct Options {
  build() {
    Column() {
      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12
        },
        gutter: 12
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 6,
            lg: 8
          },
          offset: {
            sm: 0,
            md: 1,
            lg: 3
          }
        }) {
          Row() {
            Container()
          }
          .width('100%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
        }
        .height('100%')
      }
      .height('100%')
      .margin({ left: 12, right: 12 })
    }.height('100%').backgroundColor($r("app.color.view_bgc_2"))
  }
}


export default Options