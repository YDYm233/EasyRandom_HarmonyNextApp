import router from '@ohos.router';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BreakpointState, BreakpointSystem } from '@ohos/system-utils';

class Params {
  type: string
  constructor(tuple: string) { this.type = tuple }
}

interface QuoteItem {
  text: string
  author: string
}

const QUOTES: QuoteItem[] = [
  { text: '生活不是等待风暴过去，而是学会在雨中跳舞。', author: '佚名' },
  { text: '坚持就是胜利，放弃才是失败。', author: '佚名' },
  { text: '与其仰望星空，不如脚踏实地。', author: '佚名' },
  { text: '人生没有彩排，每天都是现场直播。', author: '佚名' },
  { text: '成功不是终点，失败也不是终结。', author: '丘吉尔' },
  { text: '勇敢不是不害怕，而是害怕时仍然前行。', author: '曼德拉' },
  { text: '梦想不会逃跑，逃跑的永远是自己。', author: '佚名' },
  { text: '最好的时光是现在。', author: '佚名' },
  { text: '相信自己，你能做到。', author: '佚名' },
  { text: '每一天都是新的开始。', author: '佚名' },
  { text: '世上无难事，只怕有心人。', author: '谚语' },
  { text: '千里之行，始于足下。', author: '老子' },
  { text: '学而不思则罔，思而不学则殆。', author: '孔子' },
  { text: '路漫漫其修远兮，吾将上下而求索。', author: '屈原' },
  { text: '不积跬步，无以至千里。', author: '荀子' },
  { text: '天行健，君子以自强不息。', author: '《周易》' },
  { text: '己所不欲，勿施于人。', author: '孔子' },
  { text: '三人行，必有我师焉。', author: '孔子' },
  { text: '知之为知之，不知为不知，是知也。', author: '孔子' },
  { text: '温故而知新，可以为师矣。', author: '孔子' },
  { text: '穷则独善其身，达则兼善天下。', author: '孟子' },
  { text: '宝剑锋从磨砺出，梅花香自苦寒来。', author: '佚名' },
  { text: '书山有路勤为径，学海无涯苦作舟。', author: '韩愈' },
  { text: '业精于勤荒于嬉，行成于思毁于随。', author: '韩愈' },
  { text: '纸上得来终觉浅，绝知此事要躬行。', author: '陆游' },
  { text: '山重水复疑无路，柳暗花明又一村。', author: '陆游' },
  { text: '长风破浪会有时，直挂云帆济沧海。', author: '李白' },
  { text: '天生我材必有用，千金散尽还复来。', author: '李白' },
  { text: '会当凌绝顶，一览众山小。', author: '杜甫' },
  { text: '不畏浮云遮望眼，自缘身在最高层。', author: '王安石' },
]

@Entry
@Component
struct DailyQuotePage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State currentIndex: number = Math.floor(Math.random() * QUOTES.length)
  @State quoteOpacity: number = 1
  @State cardScale: number = 1

  aboutToAppear(): void {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  private nextQuote(): void {
    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.quoteOpacity = 0
      this.cardScale = 0.96
    })
    setTimeout(() => {
      let next = this.currentIndex
      while (next === this.currentIndex && QUOTES.length > 1) {
        next = Math.floor(Math.random() * QUOTES.length)
      }
      this.currentIndex = next
      animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.quoteOpacity = 1
        this.cardScale = 1
      })
    }, 220)
  }

  private copyQuote(): void {
    const q = QUOTES[this.currentIndex]
    const text = `${q.text} —— ${q.author}`
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      promptAction.showToast({ message: '已复制' })
    } catch (e) {
      promptAction.showToast({ message: '复制失败' })
    }
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => { router.back({ url: 'pages/IndexPage/Index' }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center).padding({ left: 12 })
        }
        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_daily_quote")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
        }
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => { router.pushUrl({ url: 'pages/SettingPage/SettingPage', params: new Params('no') }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center).padding({ right: 12 })
        }
      }
      .width('100%').backgroundColor($r("app.color.Comp_Bg1")).zIndex(10)
      .margin({ top: $r("app.float.header_margin") }).position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      Scroll() {
        GridRow({ columns: { sm: 4, md: 6, lg: 8 }, gutter: 12 }) {
          GridCol({ span: { sm: 4, md: 4, lg: 6 }, offset: { sm: 0, md: 1, lg: 1 } }) {
            Column({ space: 24 }) {

              Column({ space: 16 }) {
                Text(`"${QUOTES[this.currentIndex].text}"`)
                  .fontSize(this.currentBreakpoint.value === 'lg' ? 20 :
                            this.currentBreakpoint.value === 'md' ? 18 : 16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .textAlign(TextAlign.Center)
                  .lineHeight(this.currentBreakpoint.value === 'lg' ? 32 :
                              this.currentBreakpoint.value === 'md' ? 28 : 24)

                Text(`—— ${QUOTES[this.currentIndex].author}`)
                  .fontSize(this.currentBreakpoint.value === 'sm' ? 12 : 14)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .textAlign(TextAlign.End)
                  .width('100%')
              }
              .width('100%')
              .padding(this.currentBreakpoint.value === 'lg' ? 32 :
                       this.currentBreakpoint.value === 'md' ? 24 : 20)
              .backgroundColor($r("app.color.Comp_Bg1"))
              .borderRadius(20)
              .shadow({ radius: 20, color: $r("app.color.shadow"), offsetX: 0, offsetY: 4 })
              .opacity(this.quoteOpacity)
              .scale({ x: this.cardScale, y: this.cardScale })

              Row({ space: 12 }) {
                Button({ type: ButtonType.Normal }) {
                  Row({ space: 6 }) {
                    SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
                      .fontSize(18)
                      .fontColor([$r("app.color.control_fc_1")])
                    Text('换一句')
                      .fontSize(15).fontWeight(FontWeight.Bold)
                      .fontColor($r("app.color.control_fc_1"))
                  }
                }
                .layoutWeight(1).height(48)
                .backgroundColor($r("app.color.Brand")).borderRadius(24)
                .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
                .onClick(() => this.nextQuote())

                Button({ type: ButtonType.Normal }) {
                  Row({ space: 6 }) {
                    Image($r("app.media.func_share")).height(18).width(18).fillColor($r("app.color.FontIcon_Fore1"))
                    Text('复制')
                      .fontSize(15).fontWeight(FontWeight.Bold)
                      .fontColor($r("app.color.FontIcon_Fore1"))
                  }
                }
                .layoutWeight(1).height(48)
                .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(24)
                .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
                .onClick(() => this.copyQuote())
              }
              .width('100%')

            }
            .width('100%').padding(24).borderRadius(20)
            .backgroundColor($r("app.color.Comp_Bg1"))
          }
        }
        .margin(24)
      }
      .width('100%').height('100%').scrollBar(BarState.Auto)
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%').backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default DailyQuotePage
