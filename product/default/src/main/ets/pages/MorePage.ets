import { BreakpointState, BreakpointSystem } from '@ohos/system-utils';
import router from '@ohos.router';

class AppItem {
  name: Resource
  img: Resource
  url: string | null
  params: string | null
  colors: Array<[ResourceColor, number]> | null

  constructor(name: Resource, img: Resource, url: string, params: string | null,
    colors: Array<[ResourceColor, number]> | null) {
    this.name = name;
    this.img = img;
    this.url = url
    this.params = params
    this.colors = colors
  }
}

let Apps: Array<AppItem> = [
  new AppItem($r("app.string.page_bagua"), $r("app.media.BaGua"),
    'sub_pages/devine_bagua/DevineBaGuaPage', '', [[0xFF00BEFF, 0], [0xffeb00, 0.5], [0xffff00, 1]]),

  // new AppItem($r("app.string.page_muyu"), $r("app.media.MuYu"),
  //   'sub_pages/blessing_muyu/BlessingMuyuPage', '', [[0xFF00BEFF, 0], [0xffeb00, 0.5], [0xffff00, 1]]),
  new AppItem($r("app.string.page_muyu"), $r("app.media.MuYu"),
    'sub_pages/blessing_muyu/BlessingMuyu_V2Page', '', [[0xFF00BEFF, 0], [0xffeb00, 0.5], [0xffff00, 1]]),


  new AppItem($r("app.string.page_random_places"), $r("app.media.icon_RandomPlace"),
    'sub_pages/random_places/RandomPlacesPage', '', null),

  new AppItem($r("app.string.page_qrcode"), $r("app.media.QRcode"),
    'sub_pages/trans_qr/TransQRPage', '', [[0xFF00BEFF, 0], [0xffeb00, 0.5], [0xffff00, 1]]),

  new AppItem($r("app.string.page_honest_or_challenge"), $r("app.media.icon_HonestOrChallenge"),
    'sub_pages/honest_or_challenge/HonestOrChallengePage', '', [[0xFF6347, 0], [0xFFD700, 0.5], [0xFFA500, 1]]),

  new AppItem($r("app.string.page_abcd"), $r("app.media.icon_RandomPlaces"),
    'sub_pages/random_abcd/RandomABCDPage', '', [[0xFF00BEFF, 0], [0xffeb00, 0.5], [0xffff00, 1]]),

  new AppItem($r("app.string.page_random_colors"), $r("app.media.icon_RandomColors"),
    'sub_pages/random_colors/RandomColorsPage', '', [[0xDDA0DD, 0], [0xEE82EE, 0.5], [0x9400D3, 1]]),

  new AppItem($r("app.string.page_flip_coin"), $r("app.media.icon_FlipCoin"),
    'sub_pages/flip_coin/FlipCoinPage', '', [[0xFF6347, 0], [0xFFD700, 0.5], [0xFFA500, 1]]),

  new AppItem($r("app.string.page_random_names"), $r("app.media.icon_RandomNames"),
    'sub_pages/random_names/RandomNamesPage', '', [[0x98FB98, 0], [0x32CD32, 0.5], [0x006400, 1]]),

  new AppItem($r("app.string.page_roll_dices"), $r("app.media.icon_RollDices"),
    'sub_pages/flip_dices/RollDicesPage', '', [[0x6A5ACD, 0], [0x483D8B, 0.5], [0x0000FF, 1]]),

  new AppItem($r("app.string.page_random_foods"), $r("app.media.icon_RandomFoods"),
    'sub_pages/random_foods/RandomFoodsPage', '', [[0xADFF2F, 0], [0x7FFF00, 0.5], [0x008000, 1]]),

  new AppItem($r("app.string.page_random_numbers"), $r("app.media.icon_RollNumbers"),
    'sub_pages/random_numbers/RandomNumbersPage', '', [[0xFFDAB9, 0], [0xFFE4B5, 0.5], [0xB8860B, 1]]),

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
            //.backgroundColor($r("app.color.FontIcon_Fore1"))
            .fillColor($r("app.color.FontIcon_Fore1"))
            .border({
              color: $r("app.color.Brand"),
              width: 0,
              style: BorderStyle.Solid,
              radius: 12
            })
          Text(app.name)
            .opacity(0.88)
            .fontColor($r("app.color.FontIcon_Fore1"))
            .fontSize('80%')
            .fontWeight(800)
            .textAlign(TextAlign.Center)
        }
        .position({ left: 0 })
      }
      .width('98%')
      .margin({ left: '1%', right: '1%', top: '5%' })
      .aspectRatio(5 / 2)
      .backgroundColor($r("app.color.Comp_Bg1"))
      .border({
        color: $r("app.color.FontIcon_Fore4"),
        width: 0,
        style: BorderStyle.Solid,
        radius: 12
      })
    }
    .width('100%')
    .border({
      color: $r("app.color.Brand"),
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
    .backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default MorePage