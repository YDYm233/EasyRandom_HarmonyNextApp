import { Blessings } from '../../components/RollBlessings'
import { Random } from '@ohos/common'

@Entry
@Component
struct WidgetCard {
  build() {
    Column() {
      Blessings().width('90%')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct Blessingsx {
  @State blessings: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  @State positions: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State durations: number[] = [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
  @State opacitys: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
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
          .opacity(this.opacitys[0])
          .fontSize(30)
        Text(this.blessings[1] + ' +' + this.random)
          .position({ bottom: this.positions[1] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[1] })
          .opacity(this.opacitys[1])
        Text(this.blessings[2] + ' +' + this.random)
          .position({ bottom: this.positions[2] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[2] })
          .opacity(this.opacitys[2])
        Text(this.blessings[3] + ' +' + this.random)
          .position({ bottom: this.positions[3] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[3] })
          .opacity(this.opacitys[3])
        Text(this.blessings[4] + ' +' + this.random)
          .position({ bottom: this.positions[4] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[4] })
          .opacity(this.opacitys[4])
        Text(this.blessings[5] + ' +' + this.random)
          .position({ bottom: this.positions[5] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[5] })
          .opacity(this.opacitys[5])
        Text(this.blessings[6] + ' +' + this.random)
          .position({ bottom: this.positions[6] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[6] })
          .opacity(this.opacitys[6])
        Text(this.blessings[7] + ' +' + this.random)
          .position({ bottom: this.positions[7] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[7] })
          .opacity(this.opacitys[7])
        Text(this.blessings[8] + ' +' + this.random)
          .position({ bottom: this.positions[8] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[8] })
          .opacity(this.opacitys[8])
        Text(this.blessings[9] + ' +' + this.random)
          .position({ bottom: this.positions[9] })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.durations[9] })
          .opacity(this.opacitys[9])
      }.height('30%').width('100%')

      Row() {
        Image($r("app.media.MuYu"))
          .width('90%').aspectRatio(1)
          .onClick(() => {
            let index = Random(0, this.blessings.length - 1, true)
            this.opacitys[index] = 0
            this.positions[index] = 0
            this.durations[index] = Random(800, 1000, true)
            this.random = this.luck[Random(0, this.luck.length - 1, true)]
            this.opacitys[index] = 1
            this.positions[index] = 50
            this.durations[index] = 0
          })
      }.height('70%').width('100%')
      //.backgroundColor(0x00beff)
      .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

    }.width('100%').aspectRatio(1).borderRadius(12).backgroundColor($r("app.color.view_bgc_1"))

  }
}

@Component
struct Blessingss {
  @State index: number = 0
  @State blessings: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  @State blessing: string = this.blessings[Random(0, this.blessings.length - 1, true)] + '+' + 1
  @State positionY: number = 0
  @State duration: number = 1000
  @State luck: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 0]

  build() {
    Column() {
      Row() {
        Text(this.blessing)
          .position({ bottom: this.positionY })
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .animation({ duration: this.duration })
          .fontSize('30%')
      }.height('30%').width('100%')

      Row() {
        Image($r("app.media.MuYu"))
          .width('90%').aspectRatio(1)

      }.height('70%').width('100%')
      .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.view_bgc_1"))
    .onClick(() => {
      this.blessing = this.blessings[Random(0, this.blessings.length - 1, true)] + ' +' +
      this.luck[Random(0, this.luck.length - 1, true)]
    })
  }
}