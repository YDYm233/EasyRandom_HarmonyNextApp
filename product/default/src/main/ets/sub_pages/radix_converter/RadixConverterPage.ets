import router from '@ohos.router';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BreakpointSystem, BreakpointState } from '@ohos/system-utils';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

class RadixResult {
  base2: string = ''
  base8: string = ''
  base10: string = ''
  base16: string = ''
}

@Entry
@Component
struct RadixConverterPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State inputValue: string = ''
  @State fromBase: number = 10
  @State result: RadixResult | null = null
  @State inputError: string = ''
  @State copiedBase: number = -1  // 短暂高亮被复制的行

  // 四种进制定义
  private readonly BASES: number[] = [2, 8, 10, 16]
  private readonly BASE_LABELS: Record<number, string> = {
    2: '二进制',
    8: '八进制',
    10: '十进制',
    16: '十六进制'
  } as Record<number, string>

  aboutToAppear(): void {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  // ── 进制转换 ──
  private convertRadix(value: string, fromBase: number): RadixResult | null {
    const trimmed = value.trim()
    if (trimmed === '') return null
    const decimal = parseInt(trimmed, fromBase)
    if (isNaN(decimal)) return null
    const res = new RadixResult()
    res.base2 = decimal.toString(2)
    res.base8 = decimal.toString(8)
    res.base10 = decimal.toString(10)
    res.base16 = decimal.toString(16).toUpperCase()
    return res
  }

  // ── 输入校验 ──
  private validateInput(value: string, base: number): boolean {
    const trimmed = value.trim()
    if (trimmed === '') return true
    switch (base) {
      case 2: return /^[01]+$/.test(trimmed)
      case 8: return /^[0-7]+$/.test(trimmed)
      case 10: return /^[0-9]+$/.test(trimmed)
      case 16: return /^[0-9a-fA-F]+$/.test(trimmed)
      default: return false
    }
  }

  private getErrorHint(value: string, base: number): string {
    const trimmed = value.trim()
    if (trimmed === '' || this.validateInput(trimmed, base)) return ''
    switch (base) {
      case 2: return '二进制仅允许 0 和 1'
      case 8: return '八进制仅允许 0-7'
      case 10: return '十进制仅允许 0-9'
      case 16: return '十六进制仅允许 0-9 和 A-F'
      default: return '输入不合法'
    }
  }

  // ── 输入过滤（进制切换时） ──
  private filterInput(value: string, base: number): string {
    switch (base) {
      case 2: return value.replace(/[^01]/g, '')
      case 8: return value.replace(/[^0-7]/g, '')
      case 10: return value.replace(/[^0-9]/g, '')
      case 16: return value.replace(/[^0-9a-fA-F]/g, '')
      default: return value
    }
  }

  // ── 状态更新 ──
  private updateResult(): void {
    this.inputError = this.getErrorHint(this.inputValue, this.fromBase)
    if (this.inputError !== '') {
      this.result = null
      return
    }
    this.result = this.convertRadix(this.inputValue, this.fromBase)
  }

  onInputChange(value: string): void {
    this.inputValue = value
    this.updateResult()
  }

  onBaseChange(newBase: number): void {
    this.fromBase = newBase
    this.inputValue = this.filterInput(this.inputValue, newBase)
    this.updateResult()
  }

  // ── 复制 ──
  private copyValue(text: string, base: number): void {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      promptAction.showToast({ message: '已复制', duration: 1500 })
      this.copiedBase = base
      // 400ms 后取消高亮
      setTimeout(() => { this.copiedBase = -1 }, 400)
    } catch (e) {
      promptAction.showToast({ message: '复制失败' })
    }
  }

  // ── 获取指定进制的结果值 ──
  private getResultByBase(base: number): string {
    if (this.result === null) return '—'
    switch (base) {
      case 2: return this.result.base2
      case 8: return this.result.base8
      case 10: return this.result.base10
      case 16: return this.result.base16
      default: return '—'
    }
  }

  // ── 断点辅助 ──
  private isLg(): boolean { return this.currentBreakpoint.value === 'lg' }
  private isMd(): boolean { return this.currentBreakpoint.value === 'md' }
  private getTextInputHeight(): number { return this.isLg() ? 56 : this.isMd() ? 52 : 48 }
  private getCardPadding(): number { return this.isLg() ? 24 : this.isMd() ? 20 : 16 }
  private getResultFontSize(): number { return this.isLg() ? 18 : this.isMd() ? 17 : 16 }
  private getBaseButtonHeight(): number { return this.isLg() ? 44 : this.isMd() ? 40 : 36 }
  private getResultRowGap(): number { return this.isLg() ? 12 : this.isMd() ? 10 : 8 }

  // ── Builder: 进制选择按钮 ──
  @Builder
  BaseButton(label: string, base: number) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontWeight(this.fromBase === base ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.fromBase === base ? $r("app.color.Brand") : $r("app.color.FontIcon_Fore1"))
    }
    .width('100%')
    .height(this.getBaseButtonHeight())
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.fromBase === base ? $r("app.color.Comp_Bg2") : $r("app.color.Comp_Bg3"))
    .borderRadius(10)
    .border({
      width: this.fromBase === base ? 2 : 1,
      color: this.fromBase === base ? $r("app.color.Brand") : $r("app.color.border_primary")
    })
    .animation({ duration: 100 })
    .onClick(() => this.onBaseChange(base))
  }

  // ── Builder: 结果行 ──
  @Builder
  ResultRow(label: string, base: number) {
    Row() {
      // 标签
      Text(label)
        .fontSize(13)
        .fontColor($r("app.color.FontIcon_Fore2"))
        .width(56)

      // 当前进制标记
      if (this.fromBase === base) {
        Text('✦')
          .fontSize(12)
          .fontColor($r("app.color.Brand"))
          .margin({ left: 2, right: 2 })
      } else {
        Text('  ')
          .fontSize(12)
          .margin({ left: 2, right: 2 })
      }

      // 数值
      Text(this.getResultByBase(base))
        .fontSize(this.getResultFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getResultByBase(base) === '—' ? $r("app.color.FontIcon_Fore3") : $r("app.color.Brand"))
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)

      // 复制按钮
      Text('📋')
        .fontSize(18)
        .fontColor(this.copiedBase === base ? $r("app.color.Brand") : $r("app.color.FontIcon_Fore2"))
        .opacity(this.getResultByBase(base) === '—' ? 0.3 : 1)
        .margin({ left: 8 })
        .onClick(() => {
          if (this.getResultByBase(base) !== '—') {
            this.copyValue(this.getResultByBase(base), base)
          }
        })
    }
    .width('100%')
    .height(48)
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg2"))
    .borderRadius(12)
  }

  build() {
    Column() {
      // ── Header ──
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
            Text($r("app.string.page_radix_converter")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/SettingPage/SettingPage', params: new Params('no') })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center).padding({ right: 12 })
        }
      }
      .width('100%').backgroundColor($r("app.color.Comp_Bg1")).zIndex(10)
      .margin({ top: $r("app.float.header_margin") }).position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      // ── 内容区 ──
      Scroll() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: 12 }) {
          GridCol({ span: { sm: 4, md: 4, lg: 6 }, offset: { sm: 0, md: 2, lg: 3 } }) {
            Column({ space: 16 }) {
              // 输入区
              Text('输入数值')
                .fontSize(14)
                .fontColor($r("app.color.FontIcon_Fore2"))
                .width('100%')

              TextInput({ text: this.inputValue, placeholder: '请输入数值' })
                .width('100%')
                .height(this.getTextInputHeight())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.FontIcon_Fore1"))
                .backgroundColor($r("app.color.Comp_Bg2"))
                .borderRadius(12)
                .padding({ left: 12, right: 12 })
                .type(InputType.Normal)
                .onChange((value: string) => this.onInputChange(value))

              // 错误提示
              if (this.inputError !== '') {
                Text(this.inputError)
                  .fontSize(12)
                  .fontColor($r("app.color.error"))
                  .width('100%')
                  .margin({ top: -8 })
              }

              // 进制选择标签
              Text('输入进制')
                .fontSize(14)
                .fontColor($r("app.color.FontIcon_Fore2"))
                .width('100%')
                .margin({ top: 4 })

              // 进制选择按钮：sm 用 2×2 Grid，md/lg 用横排 4 列
              if (this.currentBreakpoint.value === 'sm') {
                Grid() {
                  ForEach(this.BASES, (base: number) => {
                    GridItem() {
                      this.BaseButton(this.BASE_LABELS[base], base)
                    }
                  }, (base: number) => `base_${base}`)
                }
                .columnsTemplate('1fr 1fr')
                .rowsGap(8)
                .columnsGap(8)
                .width('100%')
              } else {
                Row({ space: 8 }) {
                  ForEach(this.BASES, (base: number) => {
                    this.BaseButton(this.BASE_LABELS[base], base)
                  }, (base: number) => `base_${base}`)
                }
                .width('100%')
              }

              // 分隔线
              Divider()
                .color($r("app.color.border_primary"))
                .strokeWidth(1)
                .margin({ top: 4, bottom: 4 })

              // 转换结果
              Column({ space: this.getResultRowGap() }) {
                this.ResultRow('二进制', 2)
                this.ResultRow('八进制', 8)
                this.ResultRow('十进制', 10)
                this.ResultRow('十六进制', 16)
              }
              .width('100%')
            }
            .width('100%')
            .padding(this.getCardPadding())
            .borderRadius(24)
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

export default RadixConverterPage
