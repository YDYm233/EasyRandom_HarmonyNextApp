import { Random } from '@ohos/common'
import Header from './Header'
'

@Entry
@Component
struct RollBlessings {
  build() {
    Column() {
      Header({ title: '祝福木鱼' })
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
          Scroll() {
            Blessings().width('100%')
          }
          .width('100%')
          .height('100%')
          .align(Alignment.Center)

          //.alignItems(VerticalAlign.Center)
        }
        .height('100%')
      }
      .height('100%')
      .margin({ left: 12, right: 12 })
      .padding({ top: $r("app.string.header_height") })
    }.height('100%')
    .backgroundColor($r("app.color.view_bgc_2"))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
export struct Blessings {
  @State blessings: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  @State positions: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State durations: number[] = [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
  @State opacityArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State random: number = 1
  @State luck: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 0]

  build() {
    Column() {
      Row() {
        Text(this.blessings[0] + ' +' + this.random)
          .position({ bottom: this.positions[0] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[0] })
          .opacity(this.opacityArray[0])
          .fontSize('50%')
          .fontWeight(FontWeight.Bold)
        Text(this.blessings[1] + ' +' + this.random)
          .position({ bottom: this.positions[1] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[1] })
          .opacity(this.opacityArray[1])
        Text(this.blessings[2] + ' +' + this.random)
          .position({ bottom: this.positions[2] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[2] })
          .opacity(this.opacityArray[2])
        Text(this.blessings[3] + ' +' + this.random)
          .position({ bottom: this.positions[3] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[3] })
          .opacity(this.opacityArray[3])
        Text(this.blessings[4] + ' +' + this.random)
          .position({ bottom: this.positions[4] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[4] })
          .opacity(this.opacityArray[4])
        Text(this.blessings[5] + ' +' + this.random)
          .position({ bottom: this.positions[5] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[5] })
          .opacity(this.opacityArray[5])
        Text(this.blessings[6] + ' +' + this.random)
          .position({ bottom: this.positions[6] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[6] })
          .opacity(this.opacityArray[6])
        Text(this.blessings[7] + ' +' + this.random)
          .position({ bottom: this.positions[7] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[7] })
          .opacity(this.opacityArray[7])
        Text(this.blessings[8] + ' +' + this.random)
          .position({ bottom: this.positions[8] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[8] })
          .opacity(this.opacityArray[8])
        Text(this.blessings[9] + ' +' + this.random)
          .position({ bottom: this.positions[9] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[9] })
          .opacity(this.opacityArray[9])
      }.height('30%').width('100%')

      Row() {
        Image($r("app.media.MuYu"))
          .width('90%').aspectRatio(1)// .backgroundColor(0xbbffcc)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            let index = Random(0, this.blessings.length - 1, true)
            this.durations[index] = Random(800, 1000, true)
            this.random = this.luck[Random(0, this.luck.length - 1, true)]
            this.opacityArray[index] = 1
            this.positions[index] = 50
            setTimeout(() => {
              this.opacityArray[index] = 0
              this.durations[index] = 0
              this.positions[index] = 0
            }, this.durations[index])
          })
      }.height('70%').width('100%')
      //.backgroundColor(0x00beff)
      .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.view_bgc_1"))
    .clip(true)

  }
}


export default RollBlessings