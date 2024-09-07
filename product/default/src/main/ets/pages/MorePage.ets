import { BreakpointState, BreakpointSystem } from '@ohos/common';
import router from '@ohos.router';

class AppItem {
  name: string
  img: Resource
  url: string | null
  params: string | null
  colors: Array<[ResourceColor, number]> | null

  constructor(name: string, img: Resource, url: string, params: string | null,
    colors: Array<[ResourceColor, number]> | null) {
    this.name = name;
    this.img = img;
    this.url = url
    this.params = params
    this.colors = colors
  }
}

let Apps: Array<AppItem> = [
  new AppItem('八卦', $r("app.media.icon_DevineBaGua"),
    'components/DevineBaGua', '', [[0x00beff, 0], [0xffeb00, 0.5], [0xffff00, 1]]),

  new AppItem('祝福木鱼', $r("app.media.MuYu"),
    'components/RollBlessings', '', [[0x00beff, 0], [0xffeb00, 0.5], [0xffff00, 1]]),

  new AppItem('人生必去的100个地方', $r("app.media.icon_RandomPlace"),
    'components/RandomPlaces', '', null),

  new AppItem('二维码转换', $r("app.media.QRcode"),
    'components/TransQR', '', [[0x00beff, 0], [0xffeb00, 0.5], [0xffff00, 1]]),

];

@Entry
@Component
struct MorePage {
  @State DataList: Array<AppItem> = Apps;
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State fontSize: number = 16;

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  ListItem(app: AppItem) {
    Row() {
      Column() {
        Row() {
          Image(app.img)
            .height('96%')
            .margin('2%')
            .aspectRatio(1)
            .border({
              color: Color.Blue,
              width: 0,
              style: BorderStyle.Solid,
              radius: 12
            })
          Text(app.name.toString())
            .opacity(0.88)
            .fontColor(0x000000)
            .fontSize('80%')
            .fontWeight(800)
            .textAlign(TextAlign.Center)
        }
        .position({ left: 0 })
      }
      .width('98%')
      .margin({ left: '1%', right: '1%', top: '5%' })
      .aspectRatio(5 / 2)
      .backgroundColor($r("app.color.view_bgc_1"))
      .border({
        color: Color.Red,
        width: 0,
        style: BorderStyle.Solid,
        radius: 12
      })
    }
    .width('100%')
    .border({
      color: Color.Blue,
      width: 0,
      style: BorderStyle.Solid,
      radius: 12
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)

    .onClick(() => {
      router.pushUrl({ url: app.url, params: app.params })
    })
  }

  build() {
    Column() {
        List() {
          ForEach(this.DataList, (app: AppItem) => {
            ListItem() {
              this.ListItem(app)
            }
          })
        }
        .width('100%')
        .height('100%')
        .lanes(this.currentBreakpoint.value === 'sm' ? 1 : (this.currentBreakpoint.value === 'md' ? 2 : 3))
        .padding({ left:this.currentBreakpoint.value=='sm'?6:12,right:this.currentBreakpoint.value=='sm'?6:12})
    }

  }
}

export default MorePage