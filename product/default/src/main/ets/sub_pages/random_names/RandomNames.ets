import { Randoms } from '@ohos/common';
import Header from '../../components/Header';
import {names}from '../../datas/names'
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
    }.height('100%')          .backgroundColor($r("app.color.Comp_Bg3"))  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct NamesBox {
  @State textValue: string =names
  @State texts: string[] = []
  @State indexs: number[] = []
  @State number: number = 1;
  @State max: number = 4;

  @Builder
  ListItem(name: string, index: number) {
    Row() {
      Text(index.toString())
        .width('10%')
        .aspectRatio(1)
        .fontSize(16)
        .backgroundColor($r("app.color.Comp_Bg3"))
        .borderRadius('50%')
        .margin('2.5%')
        .textAlign(TextAlign.Center)
      Text(name)
        .width('90%')
        .opacity(0.88)
        .fontColor($r("app.color.FontIcon_Fore1"))
        .fontSize(20)
        .textAlign(TextAlign.Center)
    }
    .width('90%')
    .height('20%')
    .padding({ left: '5%', right: '5%' })
    //.margin('5%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
.borderRadius(6)
    .backgroundColor($r("app.color.Comp_Bg1"))

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
          .backgroundColor($r("app.color.Comp_Bg2"))
          .border({ width: 4, color:$r("app.color.Comp_Bg2"), radius: 12 })
        }.borderRadius(24).backgroundColor($r("app.color.Comp_Bg1"))


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
                .fontColor($r("app.color.FontIcon_Fore1"))
            }
            .width('100%')
            .layoutWeight(1)

            TextArea({ text: this.textValue, placeholder: '\n本app不会收集或保存您的列表数据' })
              .padding(8)
              .fontColor($r("app.color.FontIcon_Fore2"))
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
                Row() {
                Counter() {
                  Text(this.number.toString())
                }
                .onInc(() => {
                  this.number++
                  if (this.number > this.max) {
                    this.number = this.max;
                  }
                })
                .onDec(() => {
                  this.number--
                  if (this.number < 0) {
                    this.number = 0;
                  }
                })
                  .height('80%')
                  .aspectRatio(3)
              }
                .height('80%')
              }
              .justifyContent(FlexAlign.SpaceBetween)
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
                this.texts=[''];
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
        .backgroundColor($r("app.color.Comp_Bg1"))
        .border({ width: 0, color: $r("app.color.Comp_Bg2") ,radius: 24 })
      }
    }
  }
}

export default RandomNames