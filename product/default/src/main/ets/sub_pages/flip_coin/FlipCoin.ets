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
struct RollFlip {
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
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_flip_coin")).fontColor($r("app.color.FontIcon_Fore1"))
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
      .height('100%')  .padding({ top: $r("app.float.header_height") })
    }.height('100%')          .backgroundColor($r("app.color.Comp_Bg3"))   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
  @State profit:number =0

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
        .animation({ duration: this.duration / this.profit,curve:Curve.Linear })
        //.translate({ y: this.x })
      }
      .height('80%').width('100%').alignItems(VerticalAlign.Bottom).justifyContent(FlexAlign.Center)


      Row() {
        Button() {
          Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold).fontSize('50%')
        }
        .onClick(() => {
          this.duration = 2000;
          this.profit=  Random(1, 4, true)+2;
          this.isFliping = true;
          let count =1;
          this.x='-40%'
          let loop = setInterval(() => {
            this.angle=this.angle+180;
              setTimeout(()=>{
                this.ForB = !this.ForB;
                if (this.ForB) {
                  this.F = 0;
                  this.B = 1;
                }
                else if(!this.ForB){
                  this.F = 1;
                  this.B = 0;
                }
              },this.duration/this.profit/2)
           if(count>=this.profit){
             clearInterval(loop)
           }
           count++;
          }, this.duration / (this.profit) );
          //setTimeout(()=>{this.x='0%'},this.duration/2)

          setTimeout(()=>{
            this.x='0%'
            this.isFliping = false
            console.log('次数'+this.profit.toString()+'间隔:'+(this.duration / (this.profit)).toString() + '正反？' + this.ForB);
          },this.duration-30)
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
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)

  }
}

export default RollFlip