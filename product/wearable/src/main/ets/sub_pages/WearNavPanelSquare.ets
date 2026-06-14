import { VibratorManager } from '@ohos/system-utils'

const BRAND_BLUE: number = 0xFF007AFF
const CARD_BG: number = 0x1AFFFFFF
const SUB_BG: number = 0x14FFFFFF
const TEXT_PRIMARY: number = 0xFFE0E0E0
const TEXT_SECONDARY: number = 0xFF888888
const TEXT_SECTION_LABEL: number = 0xFF555555
const CARD_PAD_H: number = 14
const CARD_PAD_V: number = 5

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
export struct WearNavPanelSquare {
  onNavigate: (index: number) => void = () => {}
  @StorageProp('hapticEnabled') hapticEnabled: boolean = false
  @State showSupportCode: boolean = false
  private listScroller: Scroller = new Scroller()

  aboutToAppear(): void {
    VibratorManager.setEnabled(this.hapticEnabled)
  }

  @Builder
  sectionHeader(title: string) {
    Text(title)
      .fontSize(12)
      .fontColor(TEXT_SECTION_LABEL)
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .margin({ bottom: 6 })
  }

  build() {
    Stack() {
      Stack({ alignContent: Alignment.Start }) {
        List({ scroller: this.listScroller }) {
          ListItem() {
            Text()
          }
          .height(24)

          ListItem() {
            Text('随易手表端')
              .fontSize(20)
              .fontColor(TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .width('100%')
          }
          .padding({ left: CARD_PAD_H, right: CARD_PAD_H, bottom: 1 })

          ListItemGroup({ header: this.sectionHeader('公告') }) {
            ListItem() {
              Text('公告📢：欢迎体验随易手表端首个版本')
                .fontSize(13)
                .fontColor(TEXT_PRIMARY)
                .width('100%')
            }
            .padding({ left: CARD_PAD_H, right: CARD_PAD_H, top: CARD_PAD_V, bottom: CARD_PAD_V })
            .backgroundColor(CARD_BG)
            .borderRadius(14)

            ListItem() {
              Text('版本预告：下阶段将实现主应用与手表端的数据同步功能。')
                .fontSize(13)
                .fontColor(TEXT_SECONDARY)
                .width('100%')
            }
            .padding({ left: CARD_PAD_H, right: CARD_PAD_H, top: CARD_PAD_V, bottom: CARD_PAD_V })
            .backgroundColor(CARD_BG)
            .borderRadius(14)
            .margin({ top: 8 })
          }

          ListItemGroup({ header: this.sectionHeader('快捷跳转') }) {
            ListItem() {
              Row({ space: 8 }) {
                ForEach(QUICK_ENTRIES, (entry: QuickEntry) => {
                  Column() {
                    Text(entry.emoji)
                      .fontSize(18)
                    Text(entry.label)
                      .fontSize(10)
                      .fontColor(TEXT_PRIMARY)
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  .height(48)
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
            }
            .padding({ left: CARD_PAD_H, right: CARD_PAD_H, top: CARD_PAD_V, bottom: CARD_PAD_V })
            .backgroundColor(CARD_BG)
            .borderRadius(14)
          }
          .margin({ top: 8 })

          ListItemGroup({ header: this.sectionHeader('设置') }) {
            ListItem() {
              Row() {
                Text('震动反馈')
                  .fontSize(13)
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
            }
            .padding({ left: CARD_PAD_H, right: CARD_PAD_H, top: CARD_PAD_V, bottom: CARD_PAD_V })
            .backgroundColor(CARD_BG)
            .borderRadius(14)
          }
          .margin({ top: 8 })

          ListItemGroup({ header: this.sectionHeader('关于') }) {
            ListItem() {
              Row({ space: 10 }) {
                Image($r('app.media.app_icon_wear'))
                  .width(36)
                  .height(36)
                  .borderRadius(8)
                Column() {
                  Text('随易手表端')
                    .fontSize(13)
                    .fontColor(TEXT_PRIMARY)
                    .fontWeight(FontWeight.Medium)
                  Text('V0.0.1')
                    .fontSize(11)
                    .fontColor(TEXT_SECONDARY)
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start)
                .height(36)
                .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
            }
            .padding({ left: CARD_PAD_H, right: CARD_PAD_H, top: CARD_PAD_V, bottom: CARD_PAD_V })
            .backgroundColor(CARD_BG)
            .borderRadius(14)

            ListItem() {
              Column() {
                Text('作者 闫东阳')
                  .fontSize(13)
                  .fontColor(TEXT_PRIMARY)
                Text('支持开发者')
                  .fontSize(11)
                  .fontColor(0xFF00BEFF)
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Center)
              .width('100%')
            }
            .padding({ left: CARD_PAD_H, right: CARD_PAD_H, top: CARD_PAD_V, bottom: CARD_PAD_V })
            .borderRadius(14)
            .margin({ top: 8 })
            .onClick(() => {
              VibratorManager.vibrateTap()
              this.showSupportCode = !this.showSupportCode
            })
          }
          .margin({ top: 8 })

          ListItem() {
            Text()
          }
          .height(24)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        ScrollBar({ scroller: this.listScroller, direction: ScrollBarDirection.Vertical, state: BarState.Auto }) {
          Text()
            .width(4)
            .height(100)
            .borderRadius(2)
            .backgroundColor(TEXT_SECTION_LABEL)
        }
        .width(4)
        .height('60%')
      }

      if (this.showSupportCode) {
        Column() {
          Image($r('app.media.support_code'))
            .width('70%')
            .aspectRatio(1)
            .borderRadius(12)
          Text('扫码支持开发者')
            .fontSize(11)
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
