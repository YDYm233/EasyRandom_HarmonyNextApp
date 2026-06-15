import router from '@ohos.router';
import { BreakpointState, BreakpointSystem } from '@ohos/system-utils';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

class Params {
  type: string
  constructor(tuple: string) { this.type = tuple }
}

const CHAR_UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
const CHAR_LOWER = 'abcdefghijklmnopqrstuvwxyz'
const CHAR_DIGIT = '0123456789'
const CHAR_SYMBOL = '!@#$%^&*()_+-=[]{}|;:,.<>?'

function generate(len: number, upper: boolean, lower: boolean, digit: boolean, symbol: boolean): string {
  let pool = ''
  if (upper) pool += CHAR_UPPER
  if (lower) pool += CHAR_LOWER
  if (digit) pool += CHAR_DIGIT
  if (symbol) pool += CHAR_SYMBOL
  if (pool.length === 0) return ''

  // 保证每种选中类型至少出现一次
  const required: string[] = []
  if (upper) required.push(CHAR_UPPER)
  if (lower) required.push(CHAR_LOWER)
  if (digit) required.push(CHAR_DIGIT)
  if (symbol) required.push(CHAR_SYMBOL)

  let result = ''
  for (let i = 0; i < required.length && i < len; i++) {
    const chars = required[i]
    result += chars[Math.floor(Math.random() * chars.length)]
  }
  for (let i = result.length; i < len; i++) {
    result += pool[Math.floor(Math.random() * pool.length)]
  }

  // Fisher-Yates shuffle
  const arr = result.split('')
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    const t = arr[i]; arr[i] = arr[j]; arr[j] = t
  }
  return arr.join('')
}

function calcStrength(pwd: string, upper: boolean, lower: boolean, digit: boolean, symbol: boolean): number {
  if (pwd.length === 0) return 0
  let score = 0
  if (pwd.length >= 6) score += 10
  if (pwd.length >= 10) score += 10
  if (pwd.length >= 16) score += 10
  if (pwd.length >= 24) score += 10
  const types = [upper, lower, digit, symbol].filter(Boolean).length
  score += types * 10
  let radix = 0
  if (upper) radix += 26
  if (lower) radix += 26
  if (digit) radix += 10
  if (symbol) radix += 28
  const entropy = pwd.length * Math.log2(radix)
  if (entropy >= 60) score += 10
  if (entropy >= 80) score += 5
  if (entropy >= 100) score += 5
  if (score >= 80) return 3
  if (score >= 60) return 2
  if (score >= 40) return 1
  return 0
}

const LEVEL_LABELS: string[] = ['弱', '中', '强', '极强']

@Entry
@Component
struct PasswordGenPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State password: string = ''
  @State length: number = 16
  @State useUpper: boolean = true
  @State useLower: boolean = true
  @State useDigit: boolean = true
  @State useSymbol: boolean = true
  @State strength: number = 0

  aboutToAppear(): void {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
    this.regenerate()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  regenerate(): void {
    this.password = generate(this.length, this.useUpper, this.useLower, this.useDigit, this.useSymbol)
    this.strength = calcStrength(this.password, this.useUpper, this.useLower, this.useDigit, this.useSymbol)
  }

  onToggle(changed: string): void {
    const active = [this.useUpper, this.useLower, this.useDigit, this.useSymbol].filter(Boolean).length
    if (active === 0) return  // 至少保留一种
    this.regenerate()
  }

  copyPassword(): void {
    if (this.password.length === 0) return
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.password)
      pasteboard.getSystemPasteboard().setData(data)
      promptAction.showToast({ message: '已复制' })
    } catch (e) {}
  }

  build() {
    Column() {
      // ==================== 标题栏 ====================
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24).fontColor([$r('app.color.FontIcon_Fore1')])
          }
          .onClick(() => { router.back({ url: 'pages/IndexPage/Index' }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center).padding({ left: 12 })
        }
        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_password_gen")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
        }
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            SymbolGlyph($r('sys.symbol.gearshape'))
              .fontSize(24).fontColor([$r('app.color.FontIcon_Fore1')])
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

      // ==================== 内容区 ====================
      Scroll() {
        GridRow({ columns: { sm: 4, md: 6, lg: 8 }, gutter: 12 }) {
          GridCol({ span: { sm: 4, md: 4, lg: 6 }, offset: { sm: 0, md: 1, lg: 1 } }) {
            Column({ space: 20 }) {

              // ── 密码显示 ──
              Column({ space: 8 }) {
                Row() {
                  Text('密码').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1"))
                  Blank()
                  if (this.password.length > 0) {
                    Row({ space: 4 }) {
                      Text('📋').fontSize(14)
                      Text('复制').fontSize(12).fontColor($r("app.color.FontIcon_Back1"))
                    }
                    .onClick(() => this.copyPassword())
                    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })
                  }
                }
                .width('100%')

                Column() {
                  Text(this.password || '点击下方按钮生成密码')
                    .fontSize(this.currentBreakpoint.value === 'lg' ? 20 :
                             this.currentBreakpoint.value === 'md' ? 18 : 16)
                    .fontColor(this.password.length > 0
                      ? $r("app.color.FontIcon_Fore1") : $r("app.color.FontIcon_Fore2"))
                    .fontFamily('monospace').letterSpacing(2)
                    .textAlign(TextAlign.Center).width('100%')
                    .wordBreak(WordBreak.BREAK_ALL)
                    .constraintSize({ minHeight: 48 })
                }
                .width('100%').padding(20)
                .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(12)
              }
              .width('100%')

              // ── 长度 ──
              Column({ space: 8 }) {
                Row() {
                  Text('长度').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1"))
                  Blank()
                  Text(`${this.length}`).fontSize(14).fontWeight(FontWeight.Bold).fontColor($r("app.color.Brand"))
                }
                .width('100%')
                Row() {
                  Text('6').fontSize(11).fontColor($r("app.color.FontIcon_Fore2"))
                  Slider({
                    value: this.length, min: 6, max: 64, step: 1,
                    style: SliderStyle.OutSet
                  })
                  .blockColor($r("app.color.Brand")).trackColor($r("app.color.Comp_Bg3"))
                  .selectedColor($r("app.color.Brand")).showSteps(false)
                  .trackThickness(6).blockSize({ width: 20, height: 20 })
                  .onChange((v: number) => { this.length = v; this.regenerate() })
                  .layoutWeight(1)
                  Text('64').fontSize(11).fontColor($r("app.color.FontIcon_Fore2"))
                }
                .width('100%')
              }
              .width('100%')

              // ── 字符集 ──
              Column({ space: 4 }) {
                Text('字符集').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1")).width('100%')
                Column() {
                  this.CharRow('ABC', 'Aa', '大写字母', this.useUpper,
                    (v: boolean) => { this.useUpper = v; this.regenerate() }, true)
                  Divider().color($r("app.color.Comp_Bg3")).width('100%')
                  this.CharRow('abc', 'aa', '小写字母', this.useLower,
                    (v: boolean) => { this.useLower = v; this.regenerate() }, false)
                  Divider().color($r("app.color.Comp_Bg3")).width('100%')
                  this.CharRow('123', '#', '数字', this.useDigit,
                    (v: boolean) => { this.useDigit = v; this.regenerate() }, false)
                  Divider().color($r("app.color.Comp_Bg3")).width('100%')
                  this.CharRow('!@#', '@', '符号', this.useSymbol,
                    (v: boolean) => { this.useSymbol = v; this.regenerate() }, false)
                }
                .width('100%').borderRadius(12)
                .backgroundColor($r("app.color.Comp_Bg2"))
              }
              .width('100%')

              // ── 强度 ──
              Column({ space: 6 }) {
                Row() {
                  Text('强度').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1"))
                  Blank()
                  Text(LEVEL_LABELS[this.strength]).fontSize(14).fontWeight(FontWeight.Bold)
                    .fontColor(this.strength >= 2 ? $r("app.color.Brand") :
                               this.strength >= 1 ? '#FFBB00' : '#F44336')
                }
                .width('100%')
                Progress({ value: (this.strength + 1) * 25, total: 100, type: ProgressType.Linear })
                  .width('100%').height(6)
                  .color(this.strength >= 2 ? $r("app.color.Brand") :
                         this.strength >= 1 ? '#FFBB00' : '#F44336')
                  .backgroundColor($r("app.color.Comp_Bg2"))
              }
              .width('100%')

              // ── 操作按钮 ──
              Row({ space: 12 }) {
                Button() {
                  Row({ space: 6 }) {
                    Text('🔄').fontSize(18)
                    Text('换一个').fontSize(15).fontColor($r("app.color.Brand"))
                  }
                }
                .type(ButtonType.Capsule).height(48)
                .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(24)
                .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
                .onClick(() => this.regenerate())
                .layoutWeight(1)

                Button() {
                  Row({ space: 6 }) {
                    Text('📋').fontSize(18)
                    Text('复制').fontSize(15).fontColor($r("app.color.control_fc_1"))
                  }
                }
                .type(ButtonType.Capsule).height(48)
                .backgroundColor($r("app.color.Brand")).borderRadius(24)
                .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
                .onClick(() => this.copyPassword())
                .layoutWeight(1)
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

  @Builder
  CharRow(sample: string, icon: string, label: string, checked: boolean, onChange: (v: boolean) => void, first: boolean) {
    Row() {
      Row({ space: 10 }) {
        Text(icon).fontSize(18)
        Column({ space: 2 }) {
          Text(label).fontSize(14).fontColor($r("app.color.FontIcon_Fore1"))
          Text(sample).fontSize(11).fontColor($r("app.color.FontIcon_Fore2"))
            .fontFamily('monospace')
        }
      }
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: checked })
        .selectedColor($r("app.color.Brand"))
        .onChange((v: boolean) => onChange(v))
    }
    .width('100%').padding({ left: 16, right: 16, top: first ? 14 : 12, bottom: first ? 12 : 10 })
  }
}

export default PasswordGenPage
