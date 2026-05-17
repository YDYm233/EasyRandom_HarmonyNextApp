import { Random } from '@ohos/common'
import router from '@ohos.router';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct RollBlessings {
  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.back({ url: 'pages/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_muyu")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.string.header_height"))
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
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%')
      .height($r("app.string.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.string.header_margin") })
      .position({ top: $r("app.string.header_margin") })
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
  @State blessings: string[] = ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  @State translateY: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State opacityArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State scaleArray: number[] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  @State zIndexArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State randomValues: number[] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  @State luck: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 0]
  private maxZIndex: number = 0

  build() {
    Column() {
      // 祝福文字叠加区 —— 每行文字带独立背景、缩放、层级
      Stack() {
        // 0
        Column() {
          Text(this.blessings[0] + ' +' + this.randomValues[0])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[0] })
        .opacity(this.opacityArray[0])
        .scale({ x: this.scaleArray[0], y: this.scaleArray[0] })
        .zIndex(this.zIndexArray[0])

        // 1
        Column() {
          Text(this.blessings[1] + ' +' + this.randomValues[1])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[1] })
        .opacity(this.opacityArray[1])
        .scale({ x: this.scaleArray[1], y: this.scaleArray[1] })
        .zIndex(this.zIndexArray[1])

        // 2
        Column() {
          Text(this.blessings[2] + ' +' + this.randomValues[2])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[2] })
        .opacity(this.opacityArray[2])
        .scale({ x: this.scaleArray[2], y: this.scaleArray[2] })
        .zIndex(this.zIndexArray[2])

        // 3
        Column() {
          Text(this.blessings[3] + ' +' + this.randomValues[3])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[3] })
        .opacity(this.opacityArray[3])
        .scale({ x: this.scaleArray[3], y: this.scaleArray[3] })
        .zIndex(this.zIndexArray[3])

        // 4
        Column() {
          Text(this.blessings[4] + ' +' + this.randomValues[4])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[4] })
        .opacity(this.opacityArray[4])
        .scale({ x: this.scaleArray[4], y: this.scaleArray[4] })
        .zIndex(this.zIndexArray[4])

        // 5
        Column() {
          Text(this.blessings[5] + ' +' + this.randomValues[5])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[5] })
        .opacity(this.opacityArray[5])
        .scale({ x: this.scaleArray[5], y: this.scaleArray[5] })
        .zIndex(this.zIndexArray[5])

        // 6
        Column() {
          Text(this.blessings[6] + ' +' + this.randomValues[6])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[6] })
        .opacity(this.opacityArray[6])
        .scale({ x: this.scaleArray[6], y: this.scaleArray[6] })
        .zIndex(this.zIndexArray[6])

        // 7
        Column() {
          Text(this.blessings[7] + ' +' + this.randomValues[7])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[7] })
        .opacity(this.opacityArray[7])
        .scale({ x: this.scaleArray[7], y: this.scaleArray[7] })
        .zIndex(this.zIndexArray[7])

        // 8
        Column() {
          Text(this.blessings[8] + ' +' + this.randomValues[8])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[8] })
        .opacity(this.opacityArray[8])
        .scale({ x: this.scaleArray[8], y: this.scaleArray[8] })
        .zIndex(this.zIndexArray[8])

        // 9
        Column() {
          Text(this.blessings[9] + ' +' + this.randomValues[9])
            .fontSize('50%')
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .translate({ y: this.translateY[9] })
        .opacity(this.opacityArray[9])
        .scale({ x: this.scaleArray[9], y: this.scaleArray[9] })
        .zIndex(this.zIndexArray[9])
      }
      .height('30%')
      .width('100%')
      .alignContent(Alignment.Center)
      .clip(false)

      // 木鱼图片区
      Row() {
        Image($r("app.media.MuYu"))
          .width('90%').aspectRatio(1)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            let index = Random(0, this.blessings.length - 1, true)
            let riseMs = Random(300, 450, true)
            let holdMs = Random(700, 1100, true)
            this.randomValues[index] = this.luck[Random(0, this.luck.length - 1, true)]

            // 起始态：下方不可见、缩小、层级最高
            this.translateY[index] = 40
            this.scaleArray[index] = 0.7
            this.opacityArray[index] = 0
            this.zIndexArray[index] = ++this.maxZIndex

            // 阶段1：升起 + 放大过冲 → FastOutSlowIn（先快后慢，有冲刺感）
            animateTo({ duration: riseMs, curve: Curve.FastOutSlowIn }, () => {
              this.translateY[index] = 0
              this.scaleArray[index] = 1.05
              this.opacityArray[index] = 1
            })

            // 阶段2：回弹→ EaseIn（慢起快收，自然回稳）
            animateTo({ duration: 160, curve: Curve.EaseIn, delay: riseMs }, () => {
              this.scaleArray[index] = 1.0
            })

            // 阶段3：上浮 + 微缩 + 淡出 → EaseOut（快起慢收，轻盈飘走）
            animateTo({ duration: 500, curve: Curve.EaseOut, delay: riseMs + 160 + holdMs }, () => {
              this.translateY[index] = -28
              this.scaleArray[index] = 0.88
              this.opacityArray[index] = 0
            })
          })
      }.height('70%').width('100%')
      .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)

  }
}


export default RollBlessings
