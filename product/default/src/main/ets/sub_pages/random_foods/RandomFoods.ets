import { Random } from '@ohos/common'
import Header from '../../components/Header'
import { foodsArray } from '../../static_datas/foods'

@Entry
@Component
struct RandomFoods {
  build() {
    Column() {
      Header({ title: '吃什么' })
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
              Foods().width('100%')
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
    }.height('100%')    .backgroundColor($r("app.color.Comp_Bg3"))     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct Foods {
  @State foods: string[] = foodsArray
  @State food: string = this.foods[Random(0, this.foods.length - 1, true)]
  @State isRoll: boolean = false
  build() {
    Column() {
      Row() {
        Text(this.food).height('70%').fontSize(24).fontWeight(500).fontColor( $r("app.color.FontIcon_Fore1"))
      }.width('100%').height('80%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)

      Row() {
        Button('开始')
          .backgroundColor($r("app.color.control_bgc_1"))
          .height('80%')
          .fontWeight(800)
          .aspectRatio(2)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .enabled(!this.isRoll)
          .onClick(() => {
            this.isRoll=true;
            let selected: string = this.foods[Random(0, this.foods.length - 1, true)];
            let index = 0;
            let loop = setInterval(() => {
              if(index<8){
              this.food = this.foods[Random(0, this.foods.length - 1, true)];
              console.log(this.food)
              }
              else if (index = 8) {
               // this.food = selected
                //this.isRoll=false;
                //console.log(index.toString())
              }
             else if (index > 9) {
                //clearInterval(loop)
              }
              index++;
            }, 120)
            setTimeout(()=>{
              this.food = selected
              this.isRoll=false;
              clearInterval(loop)
            },120*9)
          })
      }.height('20%')

    }.aspectRatio(1).backgroundColor($r("app.color.Comp_Bg1")).borderRadius(24)

  }
}
