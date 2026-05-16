import { Random } from '@ohos/common'
import Header from '../../components/Header'


@Entry
@Component
struct RollBlessings_V2 {
  build() {
    Column() {
      Header({ title:" 测试版木鱼" })
      Scroll() {
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
              md: 4,
              lg: 6
            },
            offset: {
              sm: 0,
              md: 2,
              lg: 3
            }
          }) {
            Row() {
              RollBlessingsBox().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .padding({ top: $r("app.string.header_height") })
    }
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct RollBlessingsBox {
  @State blessings_word: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  @State luck_value: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 0]

  build() {
    Column() {

    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)

  }
}


export default RollBlessings_V2
