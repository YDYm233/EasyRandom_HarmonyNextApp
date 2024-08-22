import { BreakpointState, BreakpointSystem } from '@ohos/common'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct RandomPage {
  build() {
    List() {
      ListItem() {
        Banner()
      }

      ListItem() {
        AppList()
      }
    }
    .width("100%")
  }
}


export default RandomPage


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

let Swipers: Array<AppItem> = [
  new AppItem('真心话大冒险', $r("app.media.icon_HonestOrChallenge"),
    'components/HonestOrChallenge', '', [[0xFF6347, 0], [0xFFD700, 0.5], [0xFFA500, 1]]),

  new AppItem('幸运转盘', $r("app.media.icon_Rolls"),
    'pages/Index', '', [[0x00BFFF, 0], [0x1E90FF, 0.5], [0x00008B, 1]]),

  new AppItem('答案之书', $r("app.media.icon_RandomPlaces"),
    'pages/Index', '', [[0x00beff, 0], [0xffeb00, 0.5], [0xffff00, 1]]),
]

@Component
struct Banner {
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  swiperItem(app: AppItem) {
    Image(app.img)
      .width('100%')
      .aspectRatio(1)
      .objectFit(ImageFit.Fill)
      .borderRadius(16)
      .backgroundColor(0x00beff)
      .onClick(() => {
        router.pushUrl({ url: app.url, params: app.params })
      })
  }

  build() {
    Swiper() {
      this.swiperItem(Swipers[0])
      this.swiperItem(Swipers[1])
      this.swiperItem(Swipers[2])
    }
    .autoPlay(false)
    .indicator(true)
    .itemSpace(10)
    .displayCount(this.currentBreakpoint.value === 'sm' ? 1 : (this.currentBreakpoint.value === 'md' ? 2 : 3))
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      bottom: 36,
      top: 16
    })
  }
}


let Apps: Array<AppItem> = [
  new AppItem('颜色搭配', $r("app.media.icon_RandomColors"),
    'components/RandomColors', '', [[0xDDA0DD, 0], [0xEE82EE, 0.5], [0x9400D3, 1]]),

  new AppItem('扔硬币', $r("app.media.icon_FlipCoin"),
    'components/FlipCoin', '', [[0xFF6347, 0], [0xFFD700, 0.5], [0xFFA500, 1]]),

  new AppItem('抽签', $r("app.media.icon_RandomNames"),
    'components/RandomNames', '', [[0x98FB98, 0], [0x32CD32, 0.5], [0x006400, 1]]),

  new AppItem('掷骰子', $r("app.media.icon_RollDices"),
    'components/RollDices', '', [[0x6A5ACD, 0], [0x483D8B, 0.5], [0x0000FF, 1]]),

  new AppItem('吃什么', $r("app.media.icon_RandomFoods"),
    'components/RandomFoods', '', [[0xADFF2F, 0], [0x7FFF00, 0.5], [0x008000, 1]]),

  new AppItem('随机数', $r("app.media.icon_RollNumbers"),
    'components/RandomNumbers', '', [[0xFFDAB9, 0], [0xFFE4B5, 0.5], [0xB8860B, 1]]),

]

@Component
struct AppList {
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  private apps: Array<AppItem> = Apps;

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  appListItem(app: AppItem) {
    Column() {

      Image(app.img)
        .width(this.currentBreakpoint.value === 'lg' ? 120 : 112)//80 56
        .height(this.currentBreakpoint.value === 'lg' ? 120 : 112)//80 56
        .margin({ bottom: 8 })//.backgroundColor(app.bgc)
        .linearGradient({ angle: 180, colors: app.colors })
        .clip(true)
        .aspectRatio(1)
        .borderRadius(16)
      Text(app.name)
        .width(this.currentBreakpoint.value === 'lg' ? 120 : 112)//80 56
        .height(32)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor('#18181A')
        .margin({ bottom: 8 })
    }
    .onClick(() => {
      router.pushUrl({ url: app.url, params: app.params })
    })
  }

  build() {
    Column() {
      Row() {
        Text('热门功能').fontSize(20).fontWeight(FontWeight.Bold)
      }.justifyContent(FlexAlign.Start).width('100%').height(40).alignItems(VerticalAlign.Center)

      List({ space: this.currentBreakpoint.value === 'lg' ? 22 : 20 }) {
        ForEach(this.apps, (app: AppItem) => {
          ListItem() {
            this.appListItem(app)
          }
        })
      }
      .width('100%')
      .height(this.currentBreakpoint.value === 'lg' ? 320 : 280)
      .listDirection(Axis.Horizontal)
    }
    .width('100%')
    .height(this.currentBreakpoint.value === 'lg' ? 338 : 218)
    .padding({ bottom: 8, left: 12, right: 12 })
  }
}