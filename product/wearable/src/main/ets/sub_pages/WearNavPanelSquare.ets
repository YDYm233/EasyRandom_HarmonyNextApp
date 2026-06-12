
// 主题色
const BRAND_BLUE: number = 0xFF007AFF
const CARD_BG: number = 0x1AFFFFFF
const SUB_BG: number = 0x14FFFFFF
const TEXT_PRIMARY: number = 0xFFE0E0E0
const TEXT_SECONDARY: number = 0xFF888888

// 快捷跳转入口
interface QuickEntry {
  emoji: string
  label: string
  targetIndex: number
}

const QUICK_ENTRIES: QuickEntry[] = [
  { emoji: '🎡', label: '幸运转盘', targetIndex: 1 },
  { emoji: '🎯', label: '真心话',   targetIndex: 3 },
  { emoji: '☯️', label: '八卦',     targetIndex: 7 },
]

/**
 * 方形屏导航面板 — List + ListItemGroup
 */
@Component
export struct WearNavPanelSquare {
  onNavigate: (index: number) => void = () => {}

  @StorageProp('hapticEnabled') hapticEnabled: boolean = true

  @Builder
  sectionHeader(title: string) {
    Text(title)
      .fontSize(12)
      .fontColor(BRAND_BLUE)
      .fontWeight(FontWeight.Bold)
      .width('100%')
      .margin({ bottom: 6 })
  }

  build() {
    List() {
      // ── 顶部占位 ──
      ListItem() {
        Text()
      }
      .height(60)

      // ── 顶部大标题 ──
      ListItem() {
        Text('随易手表端')
          .fontSize(20)
          .fontColor(TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')
      }
      .padding({ left: 14, right: 14, bottom: 1 })

      // ── 公告 Section ──
      ListItemGroup({ header: this.sectionHeader('公告') }) {
        ListItem() {
          Text('测试文本1')
            .fontSize(13)
            .fontColor(TEXT_PRIMARY)
            .width('100%')
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(CARD_BG)
        .borderRadius(14)

        ListItem() {
          Text('测试文本2')
            .fontSize(13)
            .fontColor(TEXT_PRIMARY)
            .width('100%')
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(CARD_BG)
        .borderRadius(14)
        .margin({ top: 8 })
      }
      .margin({ top: 0 })

      // ── 快捷跳转 Section ──
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
                this.onNavigate(entry.targetIndex)
              })
            }, (entry: QuickEntry) => entry.label)
          }
          .width('100%')
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(CARD_BG)
        .borderRadius(14)
      }
      .margin({ top: 1 })

      // ── 设置 Section ──
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
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(CARD_BG)
        .borderRadius(14)
      }
      .margin({ top: 1 })

      // ── 关于 Section ──
      ListItemGroup({ header: this.sectionHeader('关于') }) {
        // 卡片 1：应用信息
        ListItem() {
          Row({ space: 10 }) {
            Image($r('app.media.app_icon'))
              .width(36)
              .height(36)
              .borderRadius(8)

            Column() {
              Text('随易手表端')
                .fontSize(13)
                .fontColor(TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
              Blank()
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
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(CARD_BG)
        .borderRadius(14)

        // 卡片 2：作者 & 支持
        ListItem() {
          Column() {
            Text('作者 闫东阳')
              .fontSize(13)
              .fontColor(TEXT_PRIMARY)
            Text('支持开发者')
              .fontSize(11)
              .fontColor(BRAND_BLUE)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(CARD_BG)
        .borderRadius(14)
        .margin({ top: 8 })
      }
      .margin({ top: 1, bottom: 16 })

      // ── 底部占位 ──
      ListItem() {
        Text()
      }
      .height(60)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .chainAnimation(true)
  }
}
