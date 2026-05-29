import { Random } from '@ohos/common'
import router from '@ohos.router';
import { placeAttraction, placesArray } from '../../static_datas/places'
import { promptAction } from '@kit.ArkUI'

class Params {
  type: string

  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct RandomFoods {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

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
            Text($r("app.string.page_random_places")).fontColor($r("app.color.FontIcon_Fore1"))
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
      // .height($r("app.float.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

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
              Places().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%').padding({ top: $r("app.float.header_height") })
    }
    .padding({ top: this.statusBarHeight })
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct Places {
  @State places: placeAttraction[] = placesArray
  @State index: number = Random(0, this.places.length - 1, true)
  @State placeNames: string[] = this.places.map(obj => obj.name)
  @State placeTitle: string = this.placeNames[this.index]
  @State place: placeAttraction = this.places[this.index]
  @State isRoll: boolean = false
  @State customDialogId: number = 0;

  @Builder
  CustomDialog() {
    Column() {
      Text(this.place.name).fontSize(30).lineHeight(36).fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })
      Row() {
        Text(this.place.category)
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r("app.color.FontIcon_Fore2"))
          .fontStyle(FontStyle.Italic)
        Text('' + this.place.country)
          .width('100%')
          .textAlign(TextAlign.End)
          .fontSize(16)
          .fontColor($r("app.color.FontIcon_Fore2"))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(20)
      .margin({ bottom: 24 })

      Text('位置:' + this.place.location)
        .width('100%').textAlign(TextAlign.Start)
        .fontSize(18)
        .margin({ bottom: 12 })
      Text('详情:' + this.place.description)
        .width('100%').textAlign(TextAlign.Start)
        .fontSize(18)
        .margin({ bottom: 12 })


    }.padding(24)
  }

  showPopup() {
    promptAction.openCustomDialog({
      builder: () => {
        this.CustomDialog()
      },
      showInSubWindow: false,
      offset: { dx: 0, dy: 5 },
      backgroundColor: 0xd9ffffff,
      cornerRadius: 24,
      backgroundBlurStyle: BlurStyle.Regular,
      //width: 320,
      // height: 500,

    }).then((dialogId: number) => {
      this.customDialogId = dialogId
    })
  }

  build() {
    Column() {
      Row() {
        Text(this.placeTitle).height('70%').fontSize(24).fontWeight(500)
        if (!this.isRoll) {
          Text('[点击查看详情]').height('30%')
        }
      }
      .width('100%')
      .height('80%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.showPopup()
      })

      Row() {
        Button('开始')
          .backgroundColor($r("app.color.control_bgc_1"))
          .height('80%')
          .fontWeight(800)
          .aspectRatio(2)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .enabled(!this.isRoll)
          .onClick(() => {
            this.isRoll = true;
            let index = Random(0, this.places.length - 1, true)
            let count = 0;
            let loop = setInterval(() => {
              if (count < 8) {
                this.placeTitle = this.places[Random(0, this.places.length - 1, true)].name;
              } else if (count == 8) {
                this.placeTitle = this.placeNames[index];
                this.place = this.places[index];
                this.isRoll = false;
              } else if (count > 9) {
                clearInterval(loop)
              }
              count++;
            }, 120)
          })
      }.height('20%')

    }.aspectRatio(1).backgroundColor($r("app.color.Comp_Bg1")).borderRadius(24)

  }
}
