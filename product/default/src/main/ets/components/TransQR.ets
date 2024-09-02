import { Randoms } from '@ohos/common';
import Header from './Header';
import { CounterComponent, CounterType } from '@kit.ArkUI';

@Entry
@Component
struct TransQR {
  build() {
    Column() {
      Header({ title: '转换二维码' })
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
  @State QrCode:string = 'https://developer.huawei.com/consumer/cn/'
  @State WebSrc: string = '示例地址 ：华为开发者 \n https://developer.huawei.com/consumer/cn/'
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
          Row(){
            QRCode(this.QrCode).width('100%')
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .aspectRatio(1)
        }
        .borderRadius(24).backgroundColor($r("app.color.view_bgc_1"))


        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Column() {
            Row() {
              Text('在此输入文本或链接：')
                .textAlign(TextAlign.Center)
                .alignSelf(ItemAlign.Center)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .layoutWeight(1)
            TextArea({ text: this.WebSrc, placeholder: '\n本app不会收集或保存您在此输入的数据' })
              .padding(12)
              .layoutWeight(4)
              .onChange((value: string) => {
                this.WebSrc = value;
              })
            Row() {
              Button() {
                Text('确认').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold)
              }
              .onClick(() => {
                this.QrCode=this.WebSrc;
              })

              .backgroundColor($r("app.color.control_bgc_1"))
              .height('80%')
              .aspectRatio(2)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
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

export default TransQR