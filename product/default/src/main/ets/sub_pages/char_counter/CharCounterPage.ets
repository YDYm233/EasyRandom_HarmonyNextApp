import router from '@ohos.router';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BreakpointSystem, BreakpointState } from '@ohos/system-utils';

class Params {
  type: string
  constructor(tuple: string) { this.type = tuple }
}

interface CharStats {
  charsTotal: number
  charsNoSpace: number
  lines: number
  paragraphs: number
  words: number
  cjkChars: number
}

@Entry
@Component
struct CharCounterPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State inputText: string = ''
  @State stats: CharStats = { charsTotal: 0, charsNoSpace: 0, lines: 0, paragraphs: 0, words: 0, cjkChars: 0 }
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  aboutToAppear(): void {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  calcStats(text: string): CharStats {
    const charsTotal = text.length
    const charsNoSpace = text.replace(/\s/g, '').length
    const lines = text === '' ? 0 : text.split('\n').length
    const paragraphs = text === '' ? 0 : text.split(/\n\s*\n/).filter((p: string) => p.trim() !== '').length
    const cjkChars = (text.match(/[\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\uac00-\ud7af]/g) || []).length
    const words = text.trim() === '' ? 0 : text.trim().split(/[\s,;:!?.]+/).filter((w: string) => w !== '').length
    return { charsTotal, charsNoSpace, lines, paragraphs, words, cjkChars }
  }

  clear(): void {
    this.inputText = ''
    this.stats = { charsTotal: 0, charsNoSpace: 0, lines: 0, paragraphs: 0, words: 0, cjkChars: 0 }
  }

  copySummary(): void {
    try {
      const s = this.stats
      const summary = `字数: ${s.cjkChars + s.words}  字符: ${s.charsTotal}  行数: ${s.lines}  段落: ${s.paragraphs}  单词: ${s.words}`
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, summary)
      pasteboard.getSystemPasteboard().setData(data)
      promptAction.showToast({ message: '已复制' })
    } catch (e) {
      promptAction.showToast({ message: '复制失败' })
    }
  }

  @Builder
  StatCard(label: string, value: number) {
    Column() {
      Text(label).fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
      Text(`${value}`).fontSize(26).fontWeight(FontWeight.Bold).fontColor($r("app.color.Brand")).margin({ top: 4 })
    }
    .width('100%').height(72).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(12)
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
            Text($r("app.string.page_char_counter")).fontColor($r("app.color.FontIcon_Fore1"))
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

      Column() {
        Column({ space: 20 }) {

          TextArea({ placeholder: '在此粘贴或输入文字…' })
            .onChange((value: string) => {
              this.inputText = value
              this.stats = this.calcStats(value)
            })
            .width('100%').height(140)
            .fontSize(16).fontColor($r("app.color.FontIcon_Fore1"))
            .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(12).padding(12)

          Grid() {
            GridItem() { this.StatCard('字数', this.stats.cjkChars + this.stats.words) }
            GridItem() { this.StatCard('字符', this.stats.charsTotal) }
            GridItem() { this.StatCard('行数', this.stats.lines) }
            GridItem() { this.StatCard('不含空格', this.stats.charsNoSpace) }
            GridItem() { this.StatCard('段落', this.stats.paragraphs) }
            GridItem() { this.StatCard('英文单词', this.stats.words) }
          }
          .columnsTemplate(this.currentBreakpoint.value === 'sm' ? '1fr 1fr' : '1fr 1fr 1fr')
          .rowsGap(10).columnsGap(10)

          Row({ space: 12 }) {
            Button('清空').type(ButtonType.Normal).fontSize(14).height(44)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(12).layoutWeight(1)
              .onClick(() => this.clear())
            Button('📋 复制统计').type(ButtonType.Normal).fontSize(14).height(44)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(12).layoutWeight(1)
              .onClick(() => this.copySummary())
          }
          .width('100%')

        }
        .width('100%').padding(20).borderRadius(20)
        .backgroundColor($r("app.color.Comp_Bg1"))
      }
      .padding(24).layoutWeight(1)
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%').backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default CharCounterPage
