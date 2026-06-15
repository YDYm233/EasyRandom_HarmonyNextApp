import router from '@ohos.router';
import { VibratorManager, VibrationUsage } from '@ohos/system-utils';

class Params {
  type: string
  constructor(tuple: string) { this.type = tuple }
}

interface EffectItem {
  title: string
  desc: string
  action: () => void
}

@Entry
@Component
struct VibrationDemoPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State activeCard: string = ''

  private readonly tapEffects: EffectItem[] = [
    { title: '轻触', desc: '50ms', action: () => VibratorManager.vibrateTap() },
    { title: '按键', desc: 'SHARP', action: () => VibratorManager.vibrateKeyPress() },
    { title: '双击', desc: 'SOFT×2', action: () => VibratorManager.vibrateDoubleTap() },
    { title: '重击', desc: 'HARD', action: () => VibratorManager.vibrateHeavyClick() },
    { title: '滴答', desc: '20ms', action: () => VibratorManager.vibrateTick() },
    { title: '确认', desc: 'HARD 60%', action: () => VibratorManager.vibrateConfirm() },
    { title: '拒绝', desc: 'SHARP×2', action: () => VibratorManager.vibrateReject() },
  ]

  private readonly timeEffects: EffectItem[] = [
    { title: '短振 100ms', desc: 'TOUCH', action: () => VibratorManager.vibrateShort() },
    { title: '中振 300ms', desc: 'FEEDBACK', action: () => VibratorManager.vibrateMedium() },
    { title: '长振 600ms', desc: 'TOUCH', action: () => VibratorManager.vibrateTime(600, VibrationUsage.TOUCH) },
  ]

  private readonly rhythmEffects: EffectItem[] = [
    { title: '涟漪', desc: '衰减', action: () => VibratorManager.vibrateRipple() },
    { title: '脉冲', desc: '科技感', action: () => VibratorManager.vibratePulse() },
    { title: '连振', desc: 'TOUCH', action: () => VibratorManager.vibrateTime(60, VibrationUsage.TOUCH) },
    { title: '敲门', desc: '三连', action: () => VibratorManager.vibrateKnock() },
    { title: '戏剧', desc: '渐强', action: () => VibratorManager.vibrateDramatic() },
    { title: '消息', desc: 'TOUCH', action: () => VibratorManager.vibrateTime(100, VibrationUsage.TOUCH) },
  ]

  private readonly funEffects: EffectItem[] = [
    { title: '木鱼', desc: '20ms防抖', action: () => VibratorManager.vibrateMuyu() },
    { title: '滚动', desc: '骰子感', action: () => VibratorManager.vibrateRoll() },
    { title: '结果', desc: 'HARD×2', action: () => VibratorManager.vibrateResult() },
    { title: '魔法', desc: 'SOFT×3', action: () => VibratorManager.vibrateMagic() },
    { title: '胜利', desc: '三短一长', action: () => VibratorManager.vibrateVictory() },
    { title: '揭晓', desc: '悬念', action: () => VibratorManager.vibrateReveal() },
    { title: 'SOS', desc: '···−−−···', action: () => VibratorManager.vibrateSOS() },
    { title: '心跳', desc: '咚咚', action: () => VibratorManager.vibrateHeartbeat() },
  ]

  build() {
    Column() {
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
            Text($r("app.string.page_vibration_demo")).fontColor($r("app.color.FontIcon_Fore1"))
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

      Scroll() {
        GridRow({ columns: { sm: 4, md: 6, lg: 8 }, gutter: 12 }) {
          GridCol({ span: { sm: 4, md: 4, lg: 6 }, offset: { sm: 0, md: 1, lg: 1 } }) {
            Column({ space: 20 }) {

              this.Section('🎛 触控反馈', this.tapEffects)
              this.Section('⏱ 时长振动', this.timeEffects)
              this.Section('🎼 节奏振动', this.rhythmEffects)
              this.Section('🎮 趣味场景', this.funEffects)

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
  Section(title: string, items: EffectItem[]) {
    Column({ space: 10 }) {
      Text(title).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r("app.color.FontIcon_Fore1")).width('100%')
      Grid() {
        ForEach(items, (item: EffectItem) => {
          GridItem() {
            Column() {
              Text(item.title).fontSize(14)
                .fontColor(this.activeCard === item.title ? $r("app.color.Brand") : $r("app.color.FontIcon_Fore1"))
                .maxLines(1)
              Text(item.desc).fontSize(11)
                .fontColor(this.activeCard === item.title ? $r("app.color.Brand") : $r("app.color.FontIcon_Fore2"))
                .maxLines(1).margin({ top: 2 })
            }
            .width('100%').aspectRatio(2)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            .backgroundColor(this.activeCard === item.title ? $r("app.color.Comp_Bg1") : $r("app.color.Comp_Bg2"))
            .borderRadius(10)
            .scale({ x: this.activeCard === item.title ? 1.05 : 1 })
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onClick(() => {
              item.action()
              this.activeCard = item.title
              setTimeout(() => { this.activeCard = '' }, 200)
            })
          }
        }, (item: EffectItem) => item.title)
      }
      .columnsTemplate('1fr 1fr 1fr').rowsGap(8).columnsGap(8)
    }
    .width('100%')
  }
}

export default VibrationDemoPage
