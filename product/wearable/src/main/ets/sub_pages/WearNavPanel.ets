import WearScreenUtil from '../utils/WearScreenUtil';

// ══════════════════════════════════════════
//  快捷跳转入口定义
// ══════════════════════════════════════════
interface QuickEntry {
  emoji: string
  label: string
  targetIndex: number
}

const QUICK_ENTRIES: QuickEntry[] = [
  { emoji: '🎡', label: '幸运转盘', targetIndex: 1 },
  { emoji: '🎯', label: '真心话', targetIndex: 3 },
  { emoji: '☯️', label: '八卦', targetIndex: 7 },
]

// 主题色
const BRAND_BLUE: number = 0xFF007AFF
const CARD_BG: number = 0x1AFFFFFF       // 卡片 10% 白底
const SUB_BG: number = 0x14FFFFFF        // 子卡片 8% 白底
const TEXT_PRIMARY: number = 0xFFFFFFFF
const TEXT_SECONDARY: number = 0xFFCCCCCC

/**
 * 导航面板 — 圆/方屏双适配
 * 使用 Scroll + Column 替代 List + ListItem，避免 ListItem 对子组件的
 * 高度和圆角约束。borderRadius 直接用于 Column（已验证模式，参考 Muyu）。
 */
@Component
export struct WearNavPanel {
  onNavigate: (index: number) => void = () => {};

  @State isRound: boolean = false;
  @StorageProp('hapticEnabled') hapticEnabled: boolean = true;
  @State private tapIdx: number = -1;

  aboutToAppear(): void {
    this.isRound = WearScreenUtil.isRoundScreen();
  }

  build() {
    if (this.isRound) {
      this.buildRoundPanel()
    } else {
      this.buildSquarePanel()
    }
  }

  // ═══════ 圆形屏 ═══════
  @Builder
  buildRoundPanel() {
    Stack() {
      Scroll() {
        Column({ space: this.secGap }) {
          this.buildAllSections()
        }
        .width('100%')
        .padding({ top: 24, bottom: 36 })
        .alignItems(HorizontalAlign.Center)
      }
      .width(WearScreenUtil.contentWidthRatio)
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }

  // ═══════ 方形屏 ═══════
  @Builder
  buildSquarePanel() {
    Scroll() {
      Column({ space: this.secGap }) {
        this.buildAllSections()
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 22, bottom: 36 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  // ═══════ 全部 Section ═══════
  @Builder
  buildAllSections() {
    this.buildTitle()

    // 公告 Section
    this.sectionLabel('公告')
    this.announcementCard('欢迎使用随易手表端公测版！')
    this.announcementCard('功能预告：下个版本将支持从手机端同步数据')

    // 快捷跳转 Section
    this.sectionLabel('快捷跳转')
    this.buildQuickJumpCard()

    // 设置 Section
    this.sectionLabel('设置')
    this.buildSettingCard()

    // 关于 Section
    this.sectionLabel('关于')
    this.buildAboutCard()
  }

  // ═══════ 尺寸 & 圆角（计算属性） ═══════
  private get pad(): number      { return this.isRound ? 16 : 14 }
  private get r(): number        { return this.isRound ? 24 : 16 }
  private get rSub(): number     { return this.isRound ? 18 : 12 }
  private get minH(): number     { return this.isRound ? 72 : 64 }
  private get subH(): number     { return this.isRound ? 60 : 52 }
  private get secGap(): number   { return this.isRound ? 20 : 16 }
  private get itemGap(): number  { return 8 }

  // ═══════ 标题 ═══════
  @Builder
  buildTitle() {
    Text('随易手表端')
      .fontSize(this.isRound ? 22 : 20)
      .fontColor(TEXT_PRIMARY)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .width('100%')
      .margin({ top: 10, bottom: 16 })
  }

  // ═══════ 统一 Section Label ═══════
  @Builder
  sectionLabel(text: string) {
    Text(text)
      .fontSize(WearScreenUtil.subFontSize)
      .fontColor(BRAND_BLUE)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .width('100%')
      .margin({ bottom: 8 })
  }

  // ═══════ 公告子卡片 (单条) ═══════
  @Builder
  announcementCard(content: string) {
    Column() {
      Text(content)
        .fontSize(13)
        .fontColor(TEXT_PRIMARY)
        .width('100%')
    }
    .width('100%')
    .height(this.subH)
    .padding(this.pad)
    .backgroundColor(SUB_BG)
    .borderRadius(this.rSub)
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: this.itemGap })
  }

  // ═══════ 快捷跳转卡片 ═══════
  @Builder
  buildQuickJumpCard() {
    Row({ space: this.isRound ? 10 : 8 }) {
      ForEach(QUICK_ENTRIES, (entry: QuickEntry) => {
        Column() {
          Text(entry.emoji)
            .fontSize(this.isRound ? 24 : 22)
          Text(entry.label)
            .fontSize(11)
            .fontColor(TEXT_PRIMARY)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .height(this.isRound ? 60 : 54)
        .backgroundColor(SUB_BG)
        .borderRadius(this.rSub)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .scale({ x: this.tapIdx === entry.targetIndex ? 0.94 : 1.0,
                 y: this.tapIdx === entry.targetIndex ? 0.94 : 1.0 })
        .onClick(() => {
          this.playTapFeedback(entry.targetIndex)
          this.onNavigate(entry.targetIndex)
        })
      }, (entry: QuickEntry) => entry.label)
    }
    .width('100%')
    .height(this.minH)
    .padding(this.pad)
    .backgroundColor(CARD_BG)
    .borderRadius(this.r)
  }

  // ═══════ 设置卡片 ═══════
  @Builder
  buildSettingCard() {
    Row() {
      Text('震动反馈')
        .fontSize(13)
        .fontColor(TEXT_PRIMARY)

      Blank()

      Toggle({ type: ToggleType.Switch, isOn: this.hapticEnabled })
        .selectedColor(BRAND_BLUE)
        .onChange((isOn: boolean) => {
          this.hapticEnabled = isOn
        })
    }
    .width('100%')
    .height(this.minH)
    .padding(this.pad)
    .backgroundColor(CARD_BG)
    .borderRadius(this.r)
    .alignItems(VerticalAlign.Center)
  }

  // ═══════ 关于卡片 ═══════
  @Builder
  buildAboutCard() {
    Row({ space: 10 }) {
      Image($r('app.media.app_icon'))
        .width(40)
        .height(40)
        .borderRadius(10)

      Column() {
        Text($r('app.string.app_name'))
          .fontSize(14)
          .fontColor(TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
        Text($r('app.string.module_desc'))
          .fontSize(11)
          .fontColor(TEXT_SECONDARY)
          .margin({ top: 2 })
        Text($r('app.string.wearable_version'))
          .fontSize(11)
          .fontColor(TEXT_SECONDARY)
          .margin({ top: 1 })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(this.minH)
    .padding(this.pad)
    .backgroundColor(CARD_BG)
    .borderRadius(this.r)
  }

  // ═══════ 点击反馈 ═══════
  private playTapFeedback(idx: number): void {
    this.tapIdx = idx
    animateTo({ duration: 100, curve: Curve.EaseIn }, () => {})
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.tapIdx = -1
    })
  }
}
