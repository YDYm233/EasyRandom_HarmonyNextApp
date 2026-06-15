import router from '@ohos.router';
import { VibratorManager } from '@ohos/system-utils';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct MetronomePage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  // 节拍器状态
  @State bpm: number = 120
  @State isRunning: boolean = false
  @State beatLit: boolean = false
  @State currentBeat: number = 0
  @State useVibration: boolean = true
  @State timeSignature: number = 4 // 4/4拍
  
  private timerId: number = 0
  private readonly minBPM: number = 40
  private readonly maxBPM: number = 208

  // 启动/停止节拍器
  toggleMetronome(): void {
    if (this.isRunning) {
      this.stopMetronome()
    } else {
      this.startMetronome()
    }
  }

  // 启动节拍器
  startMetronome(): void {
    if (this.isRunning) {
      return
    }
    
    this.isRunning = true
    this.currentBeat = 0
    this.beatLit = true
    if (this.useVibration) {
      VibratorManager.vibrateShort()
    }
    
    const interval = 60000 / this.bpm // 每拍间隔(ms)
    
    // 清除可能存在的旧定时器
    if (this.timerId) {
      clearTimeout(this.timerId)
    }
    
    const beat = () => {
      if (!this.isRunning) {
        return
      }
      
      // 更新当前拍数
      this.currentBeat = (this.currentBeat % this.timeSignature) + 1
      
      // 触发节拍灯和震动
      this.beatLit = true
      if (this.useVibration) {
        VibratorManager.vibrateShort()
      }
      
      // 60ms后关闭节拍灯
      setTimeout(() => {
        this.beatLit = false
      }, 60)
      
      // 设置下一次节拍
      this.timerId = setTimeout(beat, interval) as number
    }
    
    // 启动第一个节拍
    this.timerId = setTimeout(beat, interval) as number
  }

  // 停止节拍器
  stopMetronome(): void {
    this.isRunning = false
    this.beatLit = false
    if (this.timerId) {
      clearTimeout(this.timerId)
      this.timerId = 0
    }
  }

  // 调整BPM
  changeBPM(value: number): void {
    this.bpm = Math.max(this.minBPM, Math.min(this.maxBPM, value))
    // 如果正在运行，重启定时器以应用新的BPM
    if (this.isRunning) {
      this.stopMetronome()
      this.startMetronome()
    }
  }

  // 快速调整BPM
  adjustBPM(delta: number): void {
    this.changeBPM(this.bpm + delta)
  }

  // 切换拍号
  toggleTimeSignature(): void {
    this.timeSignature = this.timeSignature === 4 ? 3 : 4
    this.currentBeat = 0
  }

  // 组件销毁时清理定时器
  aboutToDisappear(): void {
    this.stopMetronome()
  }

  build() {
    Column() {
      // 顶部标题栏
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => { router.back({ url: 'pages/IndexPage/Index' }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_metronome")).fontColor($r("app.color.FontIcon_Fore1"))
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
          .justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%').backgroundColor($r("app.color.Comp_Bg1")).zIndex(10)
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
          // 节拍器显示区域
          GridCol({
            span: {
              sm: 4,
              md: 4,
              lg: 6
            }
          }) {
            Column() {
              // 当前BPM显示
              Text(`♩ = ${this.bpm}`)
                .fontSize(48)
                .fontColor($r("app.color.FontIcon_Fore1"))
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .margin({ bottom: 40 })

              // 节拍灯
              Column() {
                Circle()
                  .width(120)
                  .height(120)
                  .fill(this.beatLit ? $r("app.color.Brand") : $r("app.color.Comp_Bg2"))
                  .shadow({
                    radius: this.beatLit ? 40 : 0,
                    color: this.beatLit ? $r("app.color.Brand") : Color.Transparent
                  })
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .border({
                width: 2,
                color: $r("app.color.border_primary"),
                radius: 16
              })
              .backgroundColor($r("app.color.Comp_Bg1"))
              .padding(20)

              // 拍数指示器
              Row() {
                ForEach(new Array<number>(this.timeSignature).fill(0).map((_, i: number) => i + 1), (beatNum: number) => {
                  Circle()
                    .width(24)
                    .height(24)
                    .fill(beatNum === this.currentBeat ? $r("app.color.SubBrand") : $r("app.color.Comp_Bg2"))
                    .margin({ left: 8, right: 8 })
                })
              }
              .margin({ top: 20 })
              .justifyContent(FlexAlign.Center)
              .width('100%')
            }
            .width('100%')
            .padding(24)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }

          // 控制区域
          GridCol({
            span: {
              sm: 4,
              md: 4,
              lg: 6
            }
          }) {
            Column() {
              // BPM调节滑块
              Row() {
                Text('BPM:')
                  .fontSize(18)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .width('20%')
                  .textAlign(TextAlign.Start)
                
                Text(this.bpm.toString())
                  .fontSize(24)
                  .fontColor($r("app.color.Brand"))
                  .fontWeight(FontWeight.Bold)
                  .width('20%')
                  .textAlign(TextAlign.Center)
                
                Text(`${this.minBPM}-${this.maxBPM}`)
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .width('20%')
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .margin({ bottom: 16 })

              Slider({
                value: this.bpm,
                min: this.minBPM,
                max: this.maxBPM,
                step: 1,
                style: SliderStyle.OutSet
              })
              .width('100%')
              .trackColor($r("app.color.border_primary"))
              .selectedColor($r("app.color.Brand"))
              .blockColor($r("app.color.Brand"))
              .showTips(true)
              .onChange((value: number) => {
                this.changeBPM(value)
              })
              .margin({ bottom: 32 })

              // 快速调整按钮
              Row() {
                Button('-1')
                  .width('30%')
                  .fontSize(16)
                  .fontColor(Color.White)
                  .backgroundColor($r("app.color.Comp_Bg2"))
                  .onClick(() => {
                    this.adjustBPM(-1)
                  })
                
                Button('+1')
                  .width('30%')
                  .fontSize(16)
                  .fontColor(Color.White)
                  .backgroundColor($r("app.color.Comp_Bg2"))
                  .onClick(() => {
                    this.adjustBPM(1)
                  })
                  .margin({ left: 16 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 32 })

              // 开始/暂停按钮
              Button(this.isRunning ? '⏸ 暂停' : '▶ 开始')
                .width('80%')
                .height(60)
                .fontSize(20)
                .fontColor(Color.White)
                .backgroundColor(this.isRunning ? '#FFBB00' : '#4CAF50')
                .onClick(() => {
                  this.toggleMetronome()
                })
                .margin({ bottom: 32 })

              // 拍数设置
              Row() {
                Text('拍数:')
                  .fontSize(18)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .width('30%')
                  .textAlign(TextAlign.Start)
                
                Button(`${this.timeSignature}/4`)
                  .width('40%')
                  .fontSize(16)
                  .fontColor(Color.White)
                  .backgroundColor($r("app.color.Comp_Bg2"))
                  .onClick(() => {
                    this.toggleTimeSignature()
                  })
              }
              .width('100%')
              .margin({ bottom: 32 })

              // 震动开关
              Row() {
                Text('震动:')
                  .fontSize(18)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .width('30%')
                  .textAlign(TextAlign.Start)
                
                Toggle({ type: ToggleType.Switch, isOn: this.useVibration })
                  .width('40%')
                  .onChange((isOn: boolean) => {
                    this.useVibration = isOn
                  })
              }
              .width('100%')
            }
            .width('100%')
            .padding(24)
            .backgroundColor($r("app.color.Comp_Bg1"))
            .borderRadius(16)
          }
        }
        .margin(24)
      }
      .width('100%')
      .height('100%')
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default MetronomePage