import { Randoms } from '@ohos/common';
import Header from '../../components/Header';
import { CounterComponent, CounterType } from '@kit.ArkUI';
@Entry
@Component
struct RandomNames {
  build() {
    Column() {
      Header({ title: '随机数' })
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
              NumbersBox().width('100%')
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
    }.height('100%') .backgroundColor($r("app.color.Comp_Bg3"))   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct NumbersBox {
  @State numbers: number[] = []
  @State indexs: number[] = []
  @State min: number = 0;
  @State max: number = 3;
  @State number: number = this.max - this.min + 1;
  @State howmany: number = 1

  @Builder
  ListItem(title: number, index: number) {

    Badge({
      count: index + 1,
      style: {},
      position: BadgePosition.RightTop,
    }) {
      Text(title.toString())
        .opacity(0.88)
        .fontColor($r("app.color.FontIcon_Fore1"))
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height('100%')
        .fontWeight(800)
    }
    .width('100%')
    .backgroundColor($r("app.color.Comp_Bg1"))
    .border({
      color: $r("app.color.Comp_Bg3"),
      width: 1,
      style: BorderStyle.Solid,
      radius: 12
    })
  }

  build() {
    Column() {
      Scroll() {
        GridRow({ columns: 12 }) {
          ForEach(this.numbers, (title: number, index: number) => {
            GridCol({ span: 3 }) {
              this.ListItem(title, index)
            }.aspectRatio(1).margin('2%')
          })
        }.width('100%')
      }
      .width('100%')
      .border({ width: 2, color:$r("app.color.Comp_Bg3"), radius: 12 })
      .backgroundColor($r("app.color.Comp_Bg2"))
      .layoutWeight(5)
      .clip(true)

      Row() {
        Row() {
          Text('最小值:').height('100%').fontWeight(FontWeight.Bold)   .fontColor($r("app.color.FontIcon_Fore1"))
          TextInput({ text: this.min.toString(), placeholder: '最小值' })
            .padding(0)
            .height('60%')
            .width('20%')
            .fontColor($r("app.color.FontIcon_Fore1"))
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Bold)
            .underlineColor($r("app.color.FontIcon_Fore1"))
            .type(InputType.Number)
            .enterKeyType(EnterKeyType.Done)
            .onChange((value: string) => {
              if (Number(value) < this.max) {
                this.min = Number(value);
                this.number = this.max - this.min + 1;
              } else {
                this.min = 0;
                this.number = this.max + 1;
              }
            })
        }

        Row() {
          Text('最大值:').height('100%').fontWeight(FontWeight.Bold)   .fontColor($r("app.color.FontIcon_Fore1"))
          TextInput({ text: this.max.toString(), placeholder: '最大值' })
            .padding(0)
            .height('70%')
            .width('20%')
            .fontColor($r("app.color.FontIcon_Fore1"))
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Bold)
           //.underlineColor($r("app.color.FontIcon_Fore1"))
            .type(InputType.Number)
            .enterKeyType(EnterKeyType.Done)
            .onChange((value: string) => {
              if (Number(value) > this.min) {
                this.max = Number(value);
                this.number = this.max - this.min + 1;
              } else {
                this.max = this.max;
              }
            })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .layoutWeight(1)

      Row() {
        Row() {
          Text('数量:').height('100%').fontWeight(FontWeight.Bold)   .fontColor($r("app.color.FontIcon_Fore1"))
          CounterComponent({
            options: {
              type: CounterType.COMPACT,
              numberOptions: {
                value: 1,
                min: 1,
                max: this.number,
                step: 1,
                focusable: true,
                onChange: (value: number) => {
                  this.howmany = Number(value)
                }
              }
            }
          }).height('110%').padding({ top: '9%', left: '4%' })
        }
        .alignItems(VerticalAlign.Center)
        .height('100%')
        .aspectRatio(3)

        Button() {
          Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold)
        }
        .onClick(() => {
          this.numbers = Randoms(this.min, this.max, true, this.howmany, false)
        })

        .backgroundColor($r("app.color.Brand"))
        .height('80%')
        .aspectRatio(2)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      }.width('100%').layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .borderRadius(24)
    .padding('5%')
    .aspectRatio(1)
    .backgroundColor($r("app.color.Comp_Bg1"))
  }
}

export default RandomNames