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
 *
 * 结构：
 *   标题 "随易手表端"
 *   公告 label → 2 张子卡片（共用 label）
 *   快捷跳转 label → 1 张卡片（3 按钮）
 *   设置 label → 1 张卡片
 *   关于 label → 1 张卡片
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
      List({ space: WearScreenUtil.listItemSpace }) {
        this.buildContent()
      }
      .width(WearScreenUtil.contentWidthRatio)
      .height('100%')
      .alignListItem(ListItemAlign.Center)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ top: 24, bottom: 36 })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }

  // ═══════ 方形屏 ═══════
  @Builder
  buildSquarePanel() {
    List({ space: 14 }) {
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({ left: 14, right: 14, top: 22, bottom: 36 })
  }

  // ═══════ 内容区 ═══════
  @Builder
  buildContent() {
    // 标题
    ListItem() { this.buildTitle() }

    // 公告 Section（一个 label 下两张子卡片）
    ListItem() { this.buildAnnouncementSection() }

    // 快捷跳转 Section
    ListItem() { this.buildQuickJumpSection() }

    // 设置 Section
    ListItem() { this.buildSettingSection() }

    // 关于 Section
    ListItem() { this.buildAboutSection() }
  }

  // ═══════ 尺寸 & 圆角 ═══════
  private get boxPadding(): number   { return this.isRound ? 14 : 12 }
  private get boxRadius(): number    { return this.isRound ? 24 : 16 }
  private get subRadius(): number    { return this.isRound ? 18 : 12 }
  private get labelSize(): number    { return WearScreenUtil.subFontSize }
  private get labelGap(): number     { return 8 }
  private get cardMinH(): number     { return this.isRound ? 56 : 48 }
  private get subMinH(): number      { return this.isRound ? 48 : 40 }

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

  // ═══════ Section label 建造器 ═══════
  @Builder
  sectionLabel(text: string) {
    Text(text)
      .fontSize(this.labelSize)
      .fontColor(BRAND_BLUE)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .width('100%')
      .margin({ bottom: this.labelGap })
  }

  // ═══════ 公告 Section — 1 个 label + 2 张子卡片 ═══════
  @Builder
  buildAnnouncementSection() {
    Column() {
      this.sectionLabel('公告')

      // 子卡片 1
      Text('欢迎使用随易手表端公测版！')
        .fontSize(13)
        .fontColor(TEXT_PRIMARY)
        .width('100%')
        .constraintSize({ minHeight: this.subMinH })
        .padding(this.boxPadding)
        .borderRadius(this.subRadius)
        .backgroundColor(SUB_BG)

      // 子卡片 2
      Text('功能预告：下个版本将支持从手机端同步数据')
        .fontSize(13)
        .fontColor(TEXT_PRIMARY)
        .width('100%')
        .constraintSize({ minHeight: this.subMinH })
        .padding(this.boxPadding)
        .borderRadius(this.subRadius)
        .backgroundColor(SUB_BG)
        .margin({ top: 8 })
    }
    .width('100%')
  }

  // ═══════ 快捷跳转 Section — 1 个 label + 1 张卡片（3 按钮） ═══════
  @Builder
  buildQuickJumpSection() {
    Column() {
      this.sectionLabel('快捷跳转')

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
          .borderRadius(this.subRadius)
          .backgroundColor(SUB_BG)
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
      .constraintSize({ minHeight: this.cardMinH })
      .padding(this.boxPadding)
      .borderRadius(this.boxRadius)
      .backgroundColor(CARD_BG)
    }
    .width('100%')
  }

  // ═══════ 设置 Section ═══════
  @Builder
  buildSettingSection() {
    Column() {
      this.sectionLabel('设置')

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
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minHeight: this.cardMinH })
      .padding(this.boxPadding)
      .borderRadius(this.boxRadius)
      .backgroundColor(CARD_BG)
    }
    .width('100%')
  }

  // ═══════ 关于 Section ═══════
  @Builder
  buildAboutSection() {
    Column() {
      this.sectionLabel('关于')

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
      .constraintSize({ minHeight: this.cardMinH })
      .padding(this.boxPadding)
      .borderRadius(this.boxRadius)
      .backgroundColor(CARD_BG)
    }
    .width('100%')
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
