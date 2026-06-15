import router from '@ohos.router';
import { VibratorManager, VibrationUsage } from '@ohos/system-utils';
import { camera } from '@kit.CameraKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { encode, getMorseSymbols, GAP_SYMBOL, GAP_LETTER, delay } from './MorseEngine';

class Params {
  type: string
  constructor(tuple: string) { this.type = tuple }
}

const PRESETS: string[] = ['SOS', 'HELP', 'LOVE', 'OK', 'CQ']

@Entry
@Component
struct MorseCodePage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State inputText: string = ''
  @State morseText: string = ''
  @State isPlaying: boolean = false
  @State dotMs: number = 450
  @State useVibrate: boolean = true
  @State useTorch: boolean = false
  @State useScreenFlash: boolean = false
  @State flashOn: boolean = false
  @State flashOff: boolean = false
  @State currentSymbolIndex: number = -1
  @State totalSymbols: number = 0
  @State progressPercent: number = 0
  private camMgr: camera.CameraManager | null = null
  private torchReady: boolean = false

  aboutToAppear(): void {
    this.initTorch()
  }

  async initTorch(): Promise<void> {
    try {
      const camMgr = camera.getCameraManager(getContext(this))
      if (camMgr.isTorchSupported() && camMgr.isTorchModeSupported(camera.TorchMode.ON)) {
        this.camMgr = camMgr
        this.torchReady = true
      }
    } catch (e) {
      this.torchReady = false
    }
  }

  setTorch(on: boolean): void {
    if (!this.torchReady || !this.camMgr) return
    try { this.camMgr.setTorchMode(on ? camera.TorchMode.ON : camera.TorchMode.OFF) } catch (e) {}
  }

  aboutToDisappear(): void {
    this.stopPlay()
    this.setTorch(false)
  }

  onInputChange(value: string): void {
    this.inputText = value
    this.morseText = encode(value)
    this.totalSymbols = getMorseSymbols(value).length
  }

  selectPreset(text: string): void {
    this.inputText = text
    this.morseText = encode(text)
    this.totalSymbols = getMorseSymbols(text).length
  }

  copyMorse(): void {
    if (this.morseText.length === 0) return
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.morseText)
      pasteboard.getSystemPasteboard().setData(data)
      promptAction.showToast({ message: '已复制摩斯码' })
    } catch (e) {}
  }

  private signalStart(): void {
    if (this.useVibrate) VibratorManager.vibrateTime(this.dotMs, VibrationUsage.TOUCH)
    if (this.useTorch) this.setTorch(true)
    if (this.useScreenFlash) { this.flashOn = true; this.flashOff = false }
  }

  private signalEnd(): void {
    if (this.useTorch) this.setTorch(false)
    if (this.useScreenFlash) { this.flashOn = false; this.flashOff = true }
  }

  private signalClear(): void {
    this.flashOn = false
    this.flashOff = false
  }

  async startPlay(): Promise<void> {
    if (this.morseText.length === 0 || this.isPlaying) return
    if (!this.useVibrate && !this.useTorch && !this.useScreenFlash) return
    this.isPlaying = true
    this.currentSymbolIndex = 0
    this.progressPercent = 0
    const symbols = getMorseSymbols(this.inputText)
    this.totalSymbols = symbols.length

    for (let i = 0; i < symbols.length; i++) {
      if (!this.isPlaying) break
      this.currentSymbolIndex = i
      this.progressPercent = Math.round(((i + 1) / symbols.length) * 100)
      const ch = symbols[i]
      switch (ch) {
        case '.':
          this.signalStart()
          await delay(this.dotMs)
          this.signalEnd()
          await delay(GAP_SYMBOL)
          break
        case '-':
          this.signalStart()
          await delay(this.dotMs * 3)
          this.signalEnd()
          await delay(GAP_SYMBOL)
          break
      }
    }
    this.isPlaying = false
    this.setTorch(false)
    this.signalClear()
    this.currentSymbolIndex = -1
    this.progressPercent = 100
  }

  stopPlay(): void {
    this.isPlaying = false
    this.setTorch(false)
    this.signalClear()
    this.currentSymbolIndex = -1
  }

  build() {
    Stack() {
      Column() {
        // ==================== 标题栏 ====================
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
              Text($r("app.string.page_morse_code")).fontColor($r("app.color.FontIcon_Fore1"))
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

        // ==================== 内容区 ====================
        Scroll() {
          GridRow({ columns: { sm: 4, md: 6, lg: 8 }, gutter: 12 }) {
            GridCol({ span: { sm: 4, md: 4, lg: 6 }, offset: { sm: 0, md: 1, lg: 1 } }) {
              Column({ space: 20 }) {

                // ── 摩斯码显示区 ──
                Column({ space: 8 }) {
                  Row() {
                    Text('摩斯电码')
                      .fontSize(14).fontWeight(FontWeight.Medium)
                      .fontColor($r("app.color.FontIcon_Fore1"))
                    Blank()
                    if (this.morseText.length > 0 && !this.isPlaying) {
                      Row() {
                        Text('📋 复制').fontSize(12).fontColor($r("app.color.FontIcon_Back1"))
                      }
                      .onClick(() => this.copyMorse())
                      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })
                    }
                  }
                  .width('100%')

                  Column() {
                    Text(this.morseText || '…')
                      .fontSize(28).fontWeight(FontWeight.Bold)
                      .fontColor($r("app.color.Brand"))
                      .fontFamily('monospace').letterSpacing(6)
                      .textAlign(TextAlign.Center).width('100%')
                      .constraintSize({ minHeight: 60 })
                  }
                  .width('100%').padding(24)
                  .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(12)
                }
                .width('100%')

                // ── 播放进度条 ──
                if (this.isPlaying || this.progressPercent > 0) {
                  Column({ space: 4 }) {
                    Row() {
                      Text('播放进度').fontSize(12).fontColor($r("app.color.FontIcon_Fore2"))
                      Blank()
                      Text(`${this.progressPercent}%`).fontSize(12).fontWeight(FontWeight.Bold).fontColor($r("app.color.Brand"))
                    }
                    .width('100%')
                    Progress({ value: this.progressPercent, total: 100, type: ProgressType.Linear })
                      .width('100%').height(6)
                      .color($r("app.color.Brand")).backgroundColor($r("app.color.Comp_Bg2"))
                  }
                  .width('100%')
                }

                // ── 输出方式 ──
                Column({ space: 8 }) {
                  Text('输出方式').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1")).width('100%')
                  Row() {
                    this.CheckBox('🔊 震动', this.useVibrate, (v: boolean) => { this.useVibrate = v })
                    this.CheckBox('📸 手电筒', this.useTorch, (v: boolean) => { this.useTorch = v })
                    this.CheckBox('💻 屏幕', this.useScreenFlash, (v: boolean) => { this.useScreenFlash = v })
                  }
                  .width('100%').justifyContent(FlexAlign.SpaceEvenly)
                  if (this.useTorch && !this.torchReady) {
                    Text('⚠ 设备不支持手电筒').fontSize(11).fontColor($r("app.color.FontIcon_Fore2")).margin({ top: 2 })
                  }
                }
                .width('100%')

                // ── 拍速 ──
                Column({ space: 8 }) {
                  Row() {
                    Text('拍速').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1"))
                    Blank()
                    Text(`${this.dotMs} ms`).fontSize(14).fontWeight(FontWeight.Bold).fontColor($r("app.color.Brand"))
                  }
                  .width('100%')
                  Slider({ value: this.dotMs, min: 40, max: 1500, step: 10, style: SliderStyle.OutSet })
                    .blockColor($r("app.color.Brand")).trackColor($r("app.color.Comp_Bg3")).selectedColor($r("app.color.Brand"))
                    .showSteps(false).trackThickness(6).blockSize({ width: 20, height: 20 })
                    .onChange((v: number) => { this.dotMs = v })
                }
                .width('100%')

                // ── 文字输入区 ──
                Column({ space: 8 }) {
                  Text('输入文字').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1")).width('100%')
                  TextArea({ text: this.inputText, placeholder: '请输入文字…' })
                    .height(90).fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                    .backgroundColor($r("app.color.Comp_Bg2")).borderRadius(12).padding(12)
                    .onChange((value: string) => this.onInputChange(value))
                }
                .width('100%')

                // ── 快捷短语 ──
                Column({ space: 8 }) {
                  Text('快捷短语').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1")).width('100%')
                  Row() {
                    ForEach(PRESETS, (item: string) => {
                      Button(item).fontSize(13).type(ButtonType.Capsule)
                        .onClick(() => this.selectPreset(item)).margin({ right: 10 })
                        .backgroundColor($r("app.color.Comp_Bg2")).fontColor($r("app.color.FontIcon_Fore1"))
                    })
                  }
                  .width('100%')
                }
                .width('100%')

                // ── 播放按钮 ──
                if (this.isPlaying) {
                  Button('⏹ 停止播放')
                    .width('100%').height(52).fontSize(17).fontWeight(FontWeight.Bold)
                    .fontColor($r("app.color.control_fc_1")).backgroundColor($r("app.color.Brand")).borderRadius(26)
                    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
                    .onClick(() => this.stopPlay())
                } else {
                  Button('▶ 开始播放')
                    .width('100%').height(52).fontSize(17).fontWeight(FontWeight.Bold)
                    .fontColor($r("app.color.control_fc_1")).backgroundColor($r("app.color.Brand")).borderRadius(26)
                    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
                    .onClick(() => this.startPlay())
                    .enabled(this.morseText.length > 0 && (this.useVibrate || this.useTorch || this.useScreenFlash))
                    .opacity(this.morseText.length > 0 && (this.useVibrate || this.useTorch || this.useScreenFlash) ? 1 : 0.5)
                }

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

      // 全屏闪烁遮罩 — 白色（覆盖标题栏）
      if (this.flashOn) {
        Column()
          .width('100%').height('100%')
          .backgroundColor('#FFFFFF')
          .hitTestBehavior(HitTestMode.None)
      }
      // 全屏闪烁遮罩 — 黑色间隔（覆盖标题栏）
      if (this.flashOff) {
        Column()
          .width('100%').height('100%')
          .backgroundColor('#000000')
          .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%').height('100%')
  }

  @Builder
  CheckBox(label: string, checked: boolean, onChange: (v: boolean) => void) {
    Row({ space: 6 }) {
      Checkbox()
        .select(checked).selectedColor($r("app.color.Brand"))
        .onChange((v: boolean) => onChange(v))
      Text(label).fontSize(13).fontColor($r("app.color.FontIcon_Fore1"))
    }
  }
}

export default MorseCodePage
