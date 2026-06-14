import { ArcList, ArcListItem, LengthMetrics } from '@kit.ArkUI'
import { VibratorManager } from '@ohos/system-utils'
import WearScreenUtil from '../utils/WearScreenUtil'

const BRAND_BLUE: number = 0xFF007AFF
const CARD_BG: number = 0x1AFFFFFF
const SUB_BG: number = 0x14FFFFFF
const TEXT_PRIMARY: number = 0xFFE0E0E0
const TEXT_SECONDARY: number = 0xFF888888
const TEXT_SECTION_LABEL: number = 0xFF555555

interface QuickEntry {
  emoji: string
  label: string
  targetIndex: number
}

const QUICK_ENTRIES: QuickEntry[] = [
  { emoji: '🎡', label: '幸运转盘', targetIndex: 1 },
  { emoji: '🎯', label: '真心话',   targetIndex: 3 },
  { emoji: '☯️', label: '八卦',     targetIndex: 6 },
]

@Component
export struct WearNavPanelRound {
  onNavigate: (index: number) => void = () => {}
  @StorageProp('hapticEnabled') hapticEnabled: boolean = false
  @State showSupportCode: boolean = false

  aboutToAppear(): void {
    VibratorManager.setEnabled(this.hapticEnabled)
  }

  build() {
    Stack() {
      ArcList() {
        ArcListItem() {
          Text()
        }
        .height(20)

        ArcListItem() {
          Text('随易手表端')
            .fontSize(18)
            .fontColor(TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
        }

        ArcListItem() {
          Text('公告')
            .fontSize(11)
            .fontColor(TEXT_SECTION_LABEL)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .width('100%')
        }

        ArcListItem() {
          Text('公告📢：欢迎体验随易手表端首个版本')
            .fontSize(12)
            .fontColor(TEXT_PRIMARY)
            .width('100%')
            .padding({ left: WearScreenUtil.safePadding, right: WearScreenUtil.safePadding, top: 10, bottom: 10 })
        }
        .borderRadius(22)
        .backgroundColor(CARD_BG)

        ArcListItem() {
          Text('版本预告：下阶段将实现数据同步功能')
            .fontSize(12)
            .fontColor(TEXT_SECONDARY)
            .width('100%')
            .padding({ left: WearScreenUtil.safePadding, right: WearScreenUtil.safePadding, top: 10, bottom: 10 })
        }
        .borderRadius(22)
        .backgroundColor(CARD_BG)

        ArcListItem() {
          Text('快捷跳转')
            .fontSize(11)
            .fontColor(TEXT_SECTION_LABEL)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .width('100%')
        }

        ArcListItem() {
          Row({ space: 6 }) {
            ForEach(QUICK_ENTRIES, (entry: QuickEntry) => {
              Column() {
                Text(entry.emoji)
                  .fontSize(16)
                Text(entry.label)
                  .fontSize(9)
                  .fontColor(TEXT_PRIMARY)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .height(28)
              .backgroundColor(SUB_BG)
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                VibratorManager.vibrateTap()
                this.onNavigate(entry.targetIndex)
              })
            }, (entry: QuickEntry) => entry.label)
          }
          .width('100%')
          .padding({ left: WearScreenUtil.safePadding, right: WearScreenUtil.safePadding, top: 5, bottom: 5 })
        }
        .borderRadius(22)
        .backgroundColor(CARD_BG)

        ArcListItem() {
          Text('设置')
            .fontSize(11)
            .fontColor(TEXT_SECTION_LABEL)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .width('100%')
        }

        ArcListItem() {
          Row() {
            Text('震动反馈')
              .fontSize(12)
              .fontColor(TEXT_PRIMARY)
            Toggle({ type: ToggleType.Switch, isOn: this.hapticEnabled })
              .selectedColor(BRAND_BLUE)
              .onChange((isOn: boolean) => {
                this.hapticEnabled = isOn
                VibratorManager.setEnabled(isOn)
                VibratorManager.vibrateTap()
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .padding({ left: WearScreenUtil.safePadding, right: WearScreenUtil.safePadding, top: 5, bottom: 5 })
        }
        .borderRadius(22)
        .backgroundColor(CARD_BG)

        ArcListItem() {
          Text('关于')
            .fontSize(11)
            .fontColor(TEXT_SECTION_LABEL)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .width('100%')
        }

        ArcListItem() {
          Row({ space: 6 }) {
            Image($r('app.media.app_icon_wear'))
              .width(22)
              .height(22)
              .borderRadius(5)
            Column() {
              Text('随易手表端')
                .fontSize(11)
                .fontColor(TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
              Text('V0.0.1')
                .fontSize(9)
                .fontColor(TEXT_SECONDARY)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(HorizontalAlign.Start)
            .height(22)
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .padding({ left: WearScreenUtil.safePadding, right: WearScreenUtil.safePadding, top: 5, bottom: 5 })
        }
        .borderRadius(22)
        .backgroundColor(CARD_BG)

        ArcListItem() {
          Column() {
            Text('作者 闫东阳')
              .fontSize(11)
              .fontColor(TEXT_PRIMARY)
            Text('支持开发者')
              .fontSize(9)
              .fontColor(0xFF00BEFF)
              .margin({ top: 1 })
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .padding({ left: WearScreenUtil.safePadding, right: WearScreenUtil.safePadding, top: 5, bottom: 5 })
        }
        .onClick(() => {
          VibratorManager.vibrateTap()
          this.showSupportCode = !this.showSupportCode
        })

        ArcListItem() {
          Text()
        }
        .height(20)
      }
      .width(WearScreenUtil.screenWidth)
      .height(WearScreenUtil.screenHeight)
      .borderRadius(WearScreenUtil.screenWidth)
      .space(LengthMetrics.px(6))
      .fadingEdge(true)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .scrollBar(BarState.Off)

      if (this.showSupportCode) {
        Column() {
          Image($r('app.media.support_code'))
            .width('60%')
            .aspectRatio(1)
            .borderRadius(12)
          Text('扫码支持开发者')
            .fontSize(10)
            .fontColor(TEXT_SECONDARY)
            .margin({ top: 6 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(0xCC000000)
        .onClick(() => {
          this.showSupportCode = false
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
