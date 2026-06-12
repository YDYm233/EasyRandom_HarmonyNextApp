import { ArcList, ArcListItem, } from '@kit.ArkUI'
import WearScreenUtil from '../utils/WearScreenUtil'
import { LengthMetrics } from '@kit.ArkUI'

// 主题色（与全局一致）
const BRAND_BLUE: number = 0xFF007AFF
const CARD_BG: number = 0x1AFFFFFF
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
 * 圆形屏导航面板 — ArcList 弧形菜单
 *
 * 使用 ArcList + ArcListItem 专为圆形屏幕设计，
 * 子项沿圆弧排列，支持表冠滚动和链式动画。
 */
@Component
export struct WearNavPanelRound {
  onNavigate: (index: number) => void = () => {}

  @StorageProp('hapticEnabled') hapticEnabled: boolean = true
  @State private tapIdx: number = -1

  build() {
    Stack() {
      // 弧形列表（沿圆弧排列）
      ArcList() {
        // ── 快捷跳转 Section ──
        ForEach(QUICK_ENTRIES, (entry: QuickEntry) => {
          ArcListItem() {
            Row() {
              Text(entry.emoji)
                .fontSize(22)
                .margin({ right: 12 })

              Text(entry.label)
                .fontSize(14)
                .fontColor(TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .justifyContent(FlexAlign.Start)
          }
          .onClick(() => {
            this.onNavigate(entry.targetIndex)
          })
        }, (entry: QuickEntry) => entry.label)

        // ── 设置 Section ──
        ArcListItem() {
          Row() {
            Text('震动反馈')
              .fontSize(14)
              .fontColor(TEXT_PRIMARY)
              .layoutWeight(1)

            Toggle({ type: ToggleType.Switch, isOn: this.hapticEnabled })
              .selectedColor(BRAND_BLUE)
              .onChange((isOn: boolean) => {
                this.hapticEnabled = isOn
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
        }

        // ── 关于 Section ──
        ArcListItem() {
          Column() {
            Text('随易')
              .fontSize(15)
              .fontColor(TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
            Text('手表端 1.0.0')
              .fontSize(11)
              .fontColor(TEXT_SECONDARY)
              .margin({ top: 2 })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width(WearScreenUtil.screenWidth)
      .height(WearScreenUtil.screenHeight)
      .borderRadius(WearScreenUtil.screenWidth)   // 关键：设为屏幕宽度实现弧形排列
      .space(LengthMetrics.px(6))
      .chainAnimation(true)                      // 链式联动动画
      .fadingEdge(true)                         // 边缘渐隐
      .focusable(true)
      .focusOnTouch(true)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}
