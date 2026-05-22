import { BreakpointState, BreakpointSystem, Random } from '@ohos/common';
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { challenges, honests } from '../../static_datas/challenges';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct HonestOrChallenge {

  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State honests: string[] = honests
  @State challenges: string[] = challenges
  @State selectedText: string = this.challenges[Random(0, this.challenges.length - 1, true)]
  @State HorC: boolean = true;
  @State pointAngle: number = 0;
  readonly  duration: number = 1000
  @State index: number = 0
  @State honestColor: Color = 0xFF7299
  @State challengeColor: Color = 0x23ADE5
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  showPopup() {
    promptAction.openCustomDialog({
      builder: () => {
        this.customDialogBuilder()
      },
      showInSubWindow: false,
      offset: { dx: 5, dy: 5 },
      backgroundColor: 0xd9ffffff,
      cornerRadius: 24,
      backgroundBlurStyle: BlurStyle.Regular,
      width: this.currentBreakpoint.value == 'sm' ? '80%' :
        (this.currentBreakpoint.value == 'md' ? '50%' : '30%'),
      height: this.currentBreakpoint.value == 'sm' ? '20%' :
        (this.currentBreakpoint.value == 'md' ? '20%' : '20%'),
    }).then((dialogId: number) => {
      this.customDialogId = dialogId
    })
  }
  @State customDialogId: number = 0
  @Builder
  customDialogBuilder() {
    Column() {
      Text(this.selectedText)
        .height('70%')
        .fontWeight(700)
        .fontSize(20)
        .margin({ left: '5%', right: '5%' })
        .textAlign(TextAlign.Center)
      Row() {
        Button(this.HorC == true ? '换大冒险' : '换真心话').onClick(() => {
          if (this.HorC == true) {
            this.selectedText = this.challenges[Random(0, this.challenges.length - 1, true)]
          } else {
            this.selectedText = this.honests[Random(0, this.challenges.length - 1, true)]
          }
          this.HorC = !this.HorC;
        })
          .backgroundColor(this.HorC == true ? this.challengeColor : this.honestColor)
        Blank().width('20%')
        Button("再来一条").onClick(() => {
          if (this.HorC == true) {
            let index = Random(0, this.honests.length - 1, true)
            if (index != this.index) {
              this.index = index
            } else {
              index = index - 1;
              if (index < 0) {
                index = this.honests.length - 1;
              }
              this.index = index
            }

            this.selectedText = this.honests[index]
          } else {
            let index = Random(0, this.challenges.length - 1, true)
            if (index != this.index) {
              this.index = index
            } else {
              index = index - 1;
              if (index < 0) {
                index = this.challenges.length - 1;
              }
              this.index = index
            }
            this.selectedText = this.challenges[index]
          }
          // promptAction.closeCustomDialog(this.customDialogId)
        }).backgroundColor(this.HorC == true ? this.honestColor : this.challengeColor)
      }.height('30%')
    }
  }

  build() {
    Column() {
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
            Text($r("app.string.page_honest_or_challenge")).fontColor($r("app.color.FontIcon_Fore1"))
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
      .height($r("app.float.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      Row() {
        Column() {
            Image($r("app.media.needle"))
              .width('100%')
              .aspectRatio(1)
              .fillColor(0xffffff)
          .rotate({ z: 1, angle: this.currentBreakpoint.value == 'sm' ? this.pointAngle + 90 : this.pointAngle })
          .animation({ duration: this.duration, curve: Curve.Ease })
        }
        .onClick(() => {
          let target = Random(1, 360, true) + 360 * 3;
          this.pointAngle+= target;
          //console.log(this.pointAngle.toString())
          if (this.pointAngle > 3600000) {
            this.pointAngle = this.pointAngle - 3600000
          }
          let angle = this.pointAngle % 360
          if (angle == 0 || angle == 180) {
            //  console.log('无事发生')
            promptAction.showToast({
              message: '无事发生'
            })
          } else {
            if (angle > 0 && angle < 180) {
              this.HorC = false
              this.selectedText = this.challenges[Random(0, this.challenges.length - 1, true)]
            } else {
              this.HorC = true
              this.selectedText = this.honests[Random(0, this.challenges.length - 1, true)]
            }
            setTimeout(() => {
                  this.showPopup()
            }, this.duration)
          }
        })
      }
      .width(this.currentBreakpoint.value == 'sm' ? '50%' : '40%')
      .height(this.currentBreakpoint.value == 'sm' ? '30%' : '40%')
      .position(this.currentBreakpoint.value == 'sm' ? { left: '25%', top: '35%' } : { left: '30%', top: '30%' })
      .zIndex(10)
      .margin({ top: 25 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      //.backgroundColor(0x333333)
      //.padding({top:50})
      GridRow({
        columns: {
          xs: 4,
          sm: 4,
          md: 8,
          lg: 12
        }
      }) {

        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Row() {
            Text('真心话')
              .fontWeight(800)
              .width((this.currentBreakpoint.value == 'sm' ? 300 : 120))
              .height((this.currentBreakpoint.value == 'sm' ? 100 : 420))
              .fontSize((this.currentBreakpoint.value == 'sm' ? 100 : 120))
              .fontColor(0xffffff)//  .backgroundColor(0x00beff)
              .position(this.currentBreakpoint.value == 'sm' ? null : { left: 50, top: 50 })
              .margin(this.currentBreakpoint.value == 'sm' ? { top: 100 } : null)

          }.width('100%').height('100%').alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Center)

        }
        .width('100%')
        .height(this.currentBreakpoint.value == 'sm' ? '50%' : '100%')
        .backgroundColor(this.honestColor)
        .onClick(() => {
          this.selectedText = this.honests[Random(0, this.challenges.length - 1, true)]
          this.HorC = true
          this.showPopup()
        })

        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Row() {
            Text('大冒险')
              .fontWeight(800)
              .width((this.currentBreakpoint.value == 'sm' ? 300 : 120))
              .height((this.currentBreakpoint.value == 'sm' ? 100 : 420))
              .fontSize((this.currentBreakpoint.value == 'sm' ? 100 : 120))
              .fontColor(0xffffff)//  .backgroundColor(0x00beff)
              .position(this.currentBreakpoint.value == 'sm' ? null : { right: 50, bottom: 50 })
              .margin(this.currentBreakpoint.value == 'sm' ? { bottom: 100 } : null)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }.width('100%').height('100%').alignItems(VerticalAlign.Bottom).justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(this.currentBreakpoint.value == 'sm' ? '50%' : '100%')
        .backgroundColor(this.challengeColor)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .onClick(() => {
          this.selectedText = this.challenges[Random(0, this.challenges.length - 1, true)]
          this.HorC = false
          this.showPopup()
        })
      }
      .height('100%')
      .padding({ top: $r("app.float.header_height") })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }.padding({ top: this.statusBarHeight }).height('100%')
    .backgroundColor(this.honestColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}