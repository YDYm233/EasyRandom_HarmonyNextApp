
import WearScreenUtil from '../utils/WearScreenUtil'

// 主题色
const BRAND_BLUE: number = 0xFF007AFF
const CARD_BG: number = 0x1AFFFFFF
const SUB_BG: number = 0x14FFFFFF
const TEXT_PRIMARY: number = 0xFFFFFFFF
const TEXT_SECONDARY: number = 0xFFCCCCCC

// 快捷跳转入口
interface QuickEntry {
  emoji: string
  label: string
  targetIndex: number
}

const QUICK_ENTRIES: QuickEntry[] = [
  { emoji: '🎡', label: '幸运转盘', targetIndex: 1 },
  { emoji: '🎯', label: '真心话',     targetIndex: 3 },
  { emoji: '☯️',  label: '八卦',       targetIndex: 7 },
]

/**
 * 方形屏导航面板 — List + ListItemGroup
 *
 * 使用标准 List 组件，ListItemGroup 分区，
 * 语义清晰，符合方形屏的线性布局习惯。
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
      // ── 快捷跳转 Section ──
      ListItemGroup({ header: this.sectionHeader('快捷跳转') }) {
        ListItem() {
          Row({ space: 8 }) {
            ForEach(QUICK_ENTRIES, (entry: QuickEntry) => {
              Column() {
                Text(entry.emoji)
                  .fontSize(20)
                Text(entry.label)
                  .fontSize(10)
                  .fontColor(TEXT_PRIMARY)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .height(52)
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
        .padding({ left: 14, right: 14, top: 4, bottom: 4 })
      }

      // ── 设置 Section ──
      ListItemGroup({ header: this.sectionHeader('设置') }) {
        ListItem() {
          Row() {
            Text('震动反馈')
              .fontSize(13)
              .fontColor(TEXT_PRIMARY)
              .layoutWeight(1)

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.hapticEnabled })
              .selectedColor(BRAND_BLUE)
              .onChange((isOn: boolean) => {
                this.hapticEnabled = isOn
              })
          }
          .width('100%')
        }
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor(CARD_BG)
        .borderRadius(16)
      }
      .margin({ top: 12 })

      // ── 关于 Section ──
      ListItemGroup({ header: this.sectionHeader('关于') }) {
        ListItem() {
          Row({ space: 10 }) {
            // Image($r('app.media.app_icon'))
            //   .width(40)
            //   .height(40)
            //   .borderRadius(10)

            Column() {
              Text('随易')
                .fontSize(14)
                .fontColor(TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
              Text('手表端公测版')
                .fontSize(11)
                .fontColor(TEXT_SECONDARY)
                .margin({ top: 2 })
              Text('v1.0.0')
                .fontSize(11)
                .fontColor(TEXT_SECONDARY)
                .margin({ top: 1 })
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
        }
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor(CARD_BG)
        .borderRadius(16)
      }
      .margin({ top: 12, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({ top: 16 })
  }
}
