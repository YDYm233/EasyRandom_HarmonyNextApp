import { Random } from '@ohos/common'
import Header from './Header'


@Entry
@Component
struct RollFlip {
  build() {
    Column() {
      Header({ title: '丢硬币' })
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
              lg: 4
            },
            offset: {
              sm: 0,
              md: 2,
              lg: 4
            }
          }) {
            Row() {
             Coin().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')  .padding({ top: $r("app.string.header_height") })
    }.height('100%').backgroundColor($r("app.color.view_bgc_2"))    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct Coin {
  @State angle: number = 0
  @State x: string = '0%'
  @State duration: number =1200
  @State ForB: boolean = true
  @State F: number = 1
  @State B: number = 0
  @State isFliping: boolean = false

  build() {
    Column() {
      Row() {
        Stack() {
          Image($r("app.media.coin1"))
            .width('100%')
            .aspectRatio(1)
            .position({ top: 0, left: 0 })
              .opacity(this.B)
          Image($r("app.media.coin2"))
            .width('100%')
            .aspectRatio(1)
            .position({ top: 0, left: 0 })
           .opacity(this.F)
            .objectFit(ImageFit.Contain)
        }
        .width('40%')
        .aspectRatio(1)
        //.backgroundColor(0xbbffcc)
        .borderRadius('50%')
        .clip(true)
        .margin({ bottom: '10%' })
        .rotate({ x: 1, angle: this.angle })
        .animation({ duration: this.duration / 2,curve:Curve.Linear })
        .translate({ y: this.x })
      }
      .height('80%').width('100%').alignItems(VerticalAlign.Bottom).justifyContent(FlexAlign.Center)


      Row() {
        Button() {
          Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold).fontSize('50%')
        }
        .onClick(() => {
          this.duration = 1800;
          let profit= 360 * 3 + 180 * Random(1, 2, true);
          this.angle = this.angle +profit;
          this.x = '-40%';
          this.isFliping = true
          let loop = setInterval(() => {
            if (this.ForB) {
              this.F = 0;
              this.B = 1;
            } else {
              this.F = 1;
              this.B = 0;
            }
            //console.log(this.duration / (this.angle / 180) + '正反？' + this.ForB);
            this.ForB = !this.ForB;
          }, this.duration / (profit / 180));
          setTimeout(()=>{this.x='0%'},this.duration/2)
          setTimeout(()=>{
            clearInterval(loop)
            this.duration = 0;
            this.isFliping = false
          },this.duration)
        })
        .enabled(!this.isFliping)
        .backgroundColor($r("app.color.control_bgc_1"))
        .height('60%')
        .aspectRatio(2)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      }
      .height('20%').width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.view_bgc_1"))
    .clip(true)

  }
}

export default RollFlip