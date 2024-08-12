import { Random,Randoms } from '@ohos/common'
import  Header from '../Component/Header'
import { CounterType, CounterComponent } from '@kit.ArkUI';
@Entry
@Component
struct RollDices {

  build() {
    Column() {
      Header({ title: '掷筛子' })
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
            md: 6,
            lg: 8
          },
          offset: {
            sm: 0,
            md: 1,
            lg: 2
          }
        }) {
          Scroll() {
            Dices().width('100%')
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
      .padding({top:$r("app.string.header_height")})

    }.height('100%')
    .backgroundColor($r("app.color.view_bgc_2"))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
@Component
struct Dices{
  @State imgs:Resource[]=[$r("app.media.dice1"),$r("app.media.dice2"),$r("app.media.dice3"),$r("app.media.dice4"),$r("app.media.dice5"),$r("app.media.dice6")]
  @State imgsrc:Resource=this.imgs[Random(0,this.imgs.length-1,true)]
  build(){
  Column(){
    Row(){
      Image(this.imgsrc).height('70%').animation({duration:100})
    }.width('100%').height('80%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
    Row(){
      Button('开始')
        .backgroundColor($r("app.color.control_bgc_1"))
        .height('80%')
        .fontWeight(800)
        .aspectRatio(2)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        .onClick(()=>{
          let selected:Resource =this.imgs[Random(0,this.imgs.length-1,true)];
          let index=0;
          let loop=setInterval(()=>{
          this.imgsrc =  this.imgs[Random(0,this.imgs.length-1,true)];
            if(index>15){
              this.imgsrc=selected
              clearInterval(loop)
            }
            index++;
          },60)
        })
    }.height('20%')
  }.aspectRatio(1).backgroundColor($r("app.color.view_bgc_1")).borderRadius(24)
  }
}