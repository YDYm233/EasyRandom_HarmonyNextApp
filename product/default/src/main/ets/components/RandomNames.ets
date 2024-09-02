import { Randoms } from '@ohos/common';
import Header from './Header';
import { CounterComponent, CounterType } from '@kit.ArkUI';

@Entry
@Component
struct RandomNames {
  build() {
    Column() {
      Header({ title: '抽签' })
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
              md: 6,
              lg: 8
            },
            offset: {
              sm: 0,
              md: 1,
              lg: 2
            }
          }) {
            Row() {
              NamesBox().width('100%')
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
struct NamesBox {
  @State textValue: string = '小红\n小兰\n小明'
  @State texts: string[] = []
  @State indexs: number[] = []
  @State number: number = 1;
  @State max: number = 3;

  @Builder
  ListItem(name: string, index: number) {
    Row() {
      Text(index.toString())
        .width('10%')
        .aspectRatio(1)
        .fontSize(16)
        .backgroundColor(0xf1f3f5)
        .borderRadius('50%')
        .margin('2.5%')
        .textAlign(TextAlign.Center)
      Text(name)
        .width('90%')
        .opacity(0.88)
        .fontColor(0x000000)
        .fontSize(20)
        .textAlign(TextAlign.Center)
    }
    .width('90%')
    .height('20%')
    .padding({ left: '5%', right: '5%' })
    //.margin('5%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .border({
      color: Color.Blue,
      width: 0,
      style: BorderStyle.Solid,
      radius: 12
    })
    .backgroundColor(0xffffff)

  }

  build() {
    Column() {
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
          }
        }) {
          List({ space: 6 }) {
            ForEach(this.texts, (name: string, index: number) => {
              ListItem() {
                this.ListItem(name, index)
              }
            })
          }
          .alignListItem(ListItemAlign.Center)
          .width('90%')
          .margin('5%')
          .padding({ top: '5%' })
          .aspectRatio(1)
          .backgroundColor(0xf1f3f5)
          .border({ width: 4, color: 0x20808080, radius: 12 })
        }.borderRadius(24).backgroundColor($r("app.color.view_bgc_1"))


        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Column() {
            Row() {
              Text('请输入您的数据列表')
                .textAlign(TextAlign.Center)
                .alignSelf(ItemAlign.Center)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .layoutWeight(1)

            TextArea({ text: this.textValue, placeholder: '\n本app不会收集或保存您的列表数据' })
              .padding(8)
              .layoutWeight(4)
              .onChange((value: string) => {
                this.textValue = value;
                const valueArray = this.textValue.split('\n')
                const filterArray = valueArray.filter(line => line.trim() !== '');
                this.max = filterArray.length;
              })
            Row() {
              Row() {
                Text('数量:').height('100%').fontWeight(FontWeight.Bold)
                CounterComponent({
                  options: {
                    type: CounterType.COMPACT,
                    numberOptions: {
                      value: 1,
                      min: 1,
                      max: this.max,
                      step: 1,
                      focusable: true,
                      onChange: (value: number) => {
                        this.number = value
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
                const valueArray = this.textValue.split('\n')
                const filterArray = valueArray.filter(line => line.trim() !== '');
                this.max = filterArray.length;
                this.indexs = Randoms(0, filterArray.length - 1, true, this.number, false)
                //console.log('valueArray:'+filterArray)
                // console.log('indexs:'+this.indexs.toString())
                let i: number = 0;
                while (i < this.number) {
                  let x: number = this.indexs[i]
                  this.texts[i] = filterArray[x]
                  this.indexs[i] = i + 1;
                  //console.log('x:'+x)
                  //console.log('text['+i+']:'+this.texts[i])
                  i++;
                }
              })

              .backgroundColor($r("app.color.control_bgc_1"))
              .height('100%')
              .aspectRatio(2)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            }.width('100%').layoutWeight(1).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
          }.height('100%')
          .aspectRatio(1)
        }
        .padding({
          left: '5%',
          right: '5%',
          top: '4%',
          bottom: '1%'
        })
        .width('100%')
        .aspectRatio(1)
        .backgroundColor(0xffffff)
        .border({ width: 0, color: 0xf33333, radius: 24 })
      }
    }
  }
}

export default RandomNames