import { BreakpointSystem,Breakpoint,BreakpointOptions,BreakpointType,BreakpointState } from '@ohos/common'
import { router, RouterOptions } from '@kit.ArkUI'

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


class AppItem{
  name:string
  img:Resource
  url:string|null
  params:string|null
  colors: Array<[ResourceColor, number]>|null
  constructor(name:string,img:Resource,url:string,  params:string|null,colors: Array<[ResourceColor, number]>|null) {
    this.name=name;
    this.img=img;
    this.url=url
    this.params=params
    this.colors=colors
  }
}
let Swipers:Array<AppItem>=[
  new AppItem('真心话大冒险',$r("app.media.icon_HonestOrChallenge"),
    'C_more/HonestOrChallenge','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('幸运转盘',$r("app.media.icon_Rolls"),
    'pages/Index','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('答案之书',$r("app.media.icon_RandomPlaces"),
    'C_random/RandomColors','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),
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

  @Builder swiperItem(app:AppItem) {
    Image(app.img)
      .width('100%')
      .aspectRatio(1)
      .objectFit(ImageFit.Fill)
      .borderRadius(16)
      .backgroundColor(0x00beff)
      .onClick(()=>{
        router.pushUrl({url:app.url,params:app.params})
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
    .displayCount(this.currentBreakpoint.value === 'sm' ?1 : (this.currentBreakpoint.value === 'md' ? 2 : 3))
    .width('100%')
    .padding({ left: 12, right: 12, bottom: 16, top: 16 })
  }
}


let Apps:Array<AppItem>=[
  new AppItem('颜色搭配',$r("app.media.icon_RandomColors"),
    'C_random/RandomColors','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('扔硬币',$r("app.media.icon_FlipCoin"),
    'C_random/FlipCoin','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('抽签',$r("app.media.icon_RandomNames"),
    'C_random/RandomNames','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('掷骰子',$r("app.media.icon_RollDices"),
    'C_random/RollDices','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('吃什么',$r("app.media.icon_RollNumbers"),
    'C_random/RandomFoods','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('随机数',$r("app.media.icon_RollNumbers"),
    'C_random/RandomNumbers','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),

  new AppItem('人生必去的100个地方',$r("app.media.avatar"),
    'C_random/RandomPlaces','',[[0x00beff,0],[0xffeb00,0.5],[0xffff00,1]]),
]
@Component
struct AppList{
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }
  private apps:Array<AppItem> = Apps;
  @Builder
  appListItem(app:AppItem) {
    Column() {

      Image(app.img)
        .width(this.currentBreakpoint.value === 'lg' ? 120 : 112)//80 56
        .height(this.currentBreakpoint.value === 'lg' ? 120 : 112)//80 56
        .margin({ bottom: 8 })
        //.backgroundColor(app.bgc)
        .linearGradient({angle:180,colors:app.colors})
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
    .onClick(()=>{
        router.pushUrl({url:app.url,params:app.params})
    })
  }
  build() {
    Column() {
      Row(){
        Text('热门功能').fontSize(20).fontWeight(FontWeight.Bold)
      }.justifyContent(FlexAlign.Start).width('100%').height(40).alignItems(VerticalAlign.Center)
      List({ space: this.currentBreakpoint.value === 'lg' ? 22 : 20}) {
        ForEach(this.apps, (app: AppItem)=> {
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