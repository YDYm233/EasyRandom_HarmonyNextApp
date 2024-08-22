import { Random } from '@ohos/common';
import { answers } from '../datas/answers';

@Entry
@Component
struct AnswerPage {
  build() {
    Row() {
      AnswerBook()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.view_bgc_2"))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct AnswerBook {
  @State angle: number = -180;
  @State duration: number = 2000
  @State ForB: boolean = false
  @State foreVisible: Visibility = Visibility.None
  @State backVisible: Visibility = Visibility.Visible
  @State answers: string[] = answers
  @State answer: string = this.answers[Random(0, this.answers.length - 1, true)]

  aboutToDisappear() {
    this.angle = -180;
    this.duration = 2000
    this.ForB = false
    this.foreVisible = Visibility.None
    this.backVisible = Visibility.Visible
  }

  build() {
    Column() {
      Row() {
        Text('请在心中默念您的问题').fontWeight(800)
          .width('100%').textAlign(TextAlign.Center)
          .aspectRatio(9 / 2)
      }

      Column() {
        Row() {

        }
        .backgroundImage($r("app.media.CardBackground"))
        .backgroundImageSize({ width: '100%' })
        .position({ left: 0, top: 0 })
        .backgroundColor(0x00beff)
        .width('100%')
        .height('100%')
        .visibility(this.backVisible)

        Row() {
          Text(this.answer).width('80%').margin('10%').textAlign(TextAlign.Center)
        }
        .position({ left: 0, top: 0 })
        .backgroundColor(0xffffff)
        .width('100%')
        .height('100%')
        .visibility(this.foreVisible)

      }
      .width('90%')
      .margin('5%')
      .aspectRatio(9 / 16)
      .borderRadius(24)
      .clip(true)
      .rotate({ y: 1, angle: this.angle })
      .animation({ duration: this.duration })
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      .onClick(() => {
        if (this.ForB == false) {
          this.duration = 2000
          this.ForB = true;
          setTimeout(() => {
            this.foreVisible = Visibility.Visible
            this.backVisible = Visibility.None
          }, this.duration / 2)
          this.angle = 0

        } else {
          this.duration = 1200
          this.ForB = false;
          setTimeout(() => {
            this.foreVisible = Visibility.None
            this.backVisible = Visibility.Visible
            this.answer = this.answers[Random(0, this.answers.length - 1, true)]
          }, this.duration / 2)
          this.angle = -180
        }
      })
    }.height('100%').aspectRatio(1 / 2)

    //.margin({bottom:'5%'})
  }
}

export default AnswerPage