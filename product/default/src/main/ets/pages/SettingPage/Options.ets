import { SymbolGlyphModifier } from '@kit.ArkUI'
@Component
struct Level{
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
    Row() {
      Text('题库强度:')
        .height('70%')
        .fontSize(18)
      Select([{ value: '基础',symbolIcon: this.symbolModifier1  },
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
        .height('70%')
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)

    //ListStyle
    .width('100%')
    .height(60)
    .backgroundColor(0xffffff)
    .borderRadius(12)
    .padding({left:24,right:24})
    //ListStyle
  }
}

@Component
struct Container{
  @Consume('pageInfos') pageInfos: NavPathStack;
  build(){
    NavDestination() {
      List({ space: 12 }) {
        ListItem() {
          Level()
        }
        .width('100%')

        ListItem() {

        }

        ListItem() {

        }

        ListItem() {
        }

        ListItem() {
        }
      }
      .padding(12)
      .width("100%")
      .height('100%')
      .backgroundColor(0xF1F3F5)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }.title('通用设置')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      //console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
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
            md: 8,
            lg: 10
          },
          offset: {
            sm: 0,
            md: 0,
            lg: 1
          }
        }) {
          Row() {
            Container()
          }
          .width('100%')
          .height('100%')
        }
        .height('100%')
      }
      .height('100%')
      .margin({ left: 24, right: 24 })
    }.height('100%').backgroundColor($r("app.color.view_bgc_2"))
  }
}


export default Options