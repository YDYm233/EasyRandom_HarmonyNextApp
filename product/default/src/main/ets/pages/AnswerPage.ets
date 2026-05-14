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
    .backgroundColor($r("app.color.Comp_Bg3"))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct AnswerBook {
  @State angle: number = -180;
  private readonly  duration: number = 1000
  @State ForB: boolean = false
  @State foreVisible: Visibility = Visibility.None
  @State backVisible: Visibility = Visibility.Visible
  @State answers: string[] = answers
  @State answer: string = this.answers[Random(0, this.answers.length - 1, true)]
  @State isRolling:boolean=false
  aboutToDisappear() {
    this.angle = -180;
    this.ForB = false
    this.foreVisible = Visibility.None
    this.backVisible = Visibility.Visible
  }

  build() {
    Column() {
      Row() {
        Text($r("app.string.AnswerBook")).fontWeight(800)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%').textAlign(TextAlign.Center)
          .aspectRatio(9 / 2)
      }

      Column() {
        Row() {

        }
        .backgroundImage($r("app.media.CardBackground"))
        .backgroundImageSize({ width: '100%' })
        .position({ left: 0, top: 0 })
        .backgroundColor(0xffbeff)
        .width('100%')
        .height('100%')
        .visibility(this.backVisible)

        Row() {
          Text(this.answer).width('80%').margin('10%').textAlign(TextAlign.Center)
            .fontColor($r("app.color.FontIcon_Fore1"))
        }
        .position({ left: 0, top: 0 })
        .backgroundColor($r("app.color.Comp_Bg1"))
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
      .animation({ duration: this.duration,curve:Curve.EaseInOut })
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      .enabled(!this.isRolling)
      .onClick(() => {
        this.isRolling=true
        if (this.ForB == false) {
          this.ForB = true;
          setTimeout(() => {
            this.foreVisible = Visibility.Visible
            this.backVisible = Visibility.None
            this.isRolling=false
          }, this.duration / 2)
          this.angle = 0
        } else {
          this.ForB = false;
          setTimeout(() => {
            this.foreVisible = Visibility.None
            this.backVisible = Visibility.Visible
            this.answer = this.answers[Random(0, this.answers.length - 1, true)]
            this.isRolling=false
          }, this.duration / 2)
          this.angle = -180
        }


      })
    }.height('100%').aspectRatio(1 / 2)

    //.margin({bottom:'5%'})
  }
}

export default AnswerPage