import { Random } from '@ohos/common';
import { answers } from '../../static_datas/answers';
import router from '@ohos.router';

class Params {
  type: string

  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct AnswerPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  build() {
    Column() {
      // Header
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.back({ url: 'pages/IndexPage/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.AnswerBook")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SettingPage/SettingPage',
              params: new Params('no')
            }).then(() => {
              console.info("success.");
            })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%')
      // .height($r("app.float.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      Scroll() {
        GridRow({
          columns: { sm: 4, md: 8, lg: 12 },
          gutter: 12
        }) {
          GridCol({
            span: { sm: 4, md: 4, lg: 4 },
            offset: { sm: 0, md: 2, lg: 4 }
          }) {
            AnswerBook().width('100%')
          }
        }
        .margin(24)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .padding({ top: $r("app.float.header_height") })
    }

    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))

    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct AnswerBook {
  @State angle: number = -180;
  private readonly duration: number = 1000
  @State ForB: boolean = false
  @State foreVisible: Visibility = Visibility.None
  @State backVisible: Visibility = Visibility.Visible
  @State answers: string[] = answers
  @State answer: string = this.answers[Random(0, this.answers.length - 1, true)]
  @State isRolling: boolean = false

  aboutToAppear() {
    const resMgr = getContext(this).resourceManager;
    resMgr.getStringArray($r('app.strarray.answers').id, (error, value) => {
      if (error === undefined && value && value.length > 0) {
        this.answers = value as string[];
        this.answer = this.answers[Random(0, this.answers.length - 1, true)];
      }
    });
  }

  aboutToDisappear() {
    this.angle = -180;
    this.ForB = false
    this.foreVisible = Visibility.None
    this.backVisible = Visibility.Visible
  }

  build() {
    Column() {
      // 翻页卡片区域
      Column() {
        // 背面（封面）
        Column() {
          Image($r("app.media.CardBackground"))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        }
        .width('100%')
        .height('100%')
        .visibility(this.backVisible)

        // 正面（答案）
        Column() {
          Scroll() {
            Text(this.answer)
              .width('100%')
              .padding(20)
              .textAlign(TextAlign.Center)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .fontSize(18)
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r("app.color.Comp_Bg1"))
        .visibility(this.foreVisible)
      }
      .width('100%')
      .aspectRatio(9 / 16)
      .borderRadius(24)
      .backgroundColor($r("app.color.Comp_Bg1"))
      .clip(true)
      .rotate({ y: 1, angle: this.angle })
      .animation({ duration: this.duration, curve: Curve.EaseInOut })
      .shadow({ radius: 16, color: '#22000000', offsetY: 4 })
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      .enabled(!this.isRolling)
      .onClick(() => {
        this.isRolling = true
        if (this.ForB == false) {
          this.ForB = true;
          setTimeout(() => {
            this.foreVisible = Visibility.Visible
            this.backVisible = Visibility.None
            this.isRolling = false
          }, this.duration / 2)
          this.angle = 0
        } else {
          this.ForB = false;
          setTimeout(() => {
            this.foreVisible = Visibility.None
            this.backVisible = Visibility.Visible
            this.answer = this.answers[Random(0, this.answers.length - 1, true)]
            this.isRolling = false
          }, this.duration / 2)
          this.angle = -180
        }
      })

      // 提示文字
      Text('点击卡片翻转查看答案')
        .fontSize(13)
        .fontColor($r("app.color.FontIcon_Fore2"))
        .margin({ top: 16 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}

export default AnswerPage
