import { BreakpointState, BreakpointSystem } from '@ohos/common';
import router from '@ohos.router';

class ToolItem {
  emoji: string
  name: Resource
  url: string
  category: string

  constructor(emoji: string, name: Resource, url: string, category: string) {
    this.emoji = emoji;
    this.name = name;
    this.url = url;
    this.category = category;
  }
}

/** 热门推荐 */
const TOOLS_HOT: Array<ToolItem> = [
  new ToolItem('✨', $r("app.string.page_answer_book"), 'sub_pages/answer_book/AnswerBookPage', '热门推荐'),
  new ToolItem('🪐', $r("app.string.page_honest_or_challenge"),
    'sub_pages/honest_or_challenge/HonestOrChallenge', '热门推荐'),
];

/** 小工具分类 */
const TOOLS_SMALL: Array<ToolItem> = [
  new ToolItem('🎲', $r("app.string.page_roll_dices"), 'sub_pages/flip_dices/RollDices', '小工具'),
  new ToolItem('🪙', $r("app.string.page_flip_coin"), 'sub_pages/flip_coin/FlipCoin', '小工具'),
  new ToolItem('🔢', $r("app.string.page_random_numbers"), 'sub_pages/random_numbers/RandomNumbers', '小工具'),
  new ToolItem('🔤', $r("app.string.page_abcd"), 'sub_pages/random_abcd/RandomABCD', '小工具'),
  new ToolItem('🎯', $r("app.string.page_random_places"), 'sub_pages/random_places/RandomPlaces', '小工具'),
  new ToolItem('📱', $r("app.string.page_qrcode"), 'sub_pages/trans_qr/TransQR', '小工具'),
  new ToolItem('🎨', $r("app.string.page_random_colors"), 'sub_pages/random_colors/RandomColors', '小工具'),
];

/** 趣味玩法分类 */
const TOOLS_FUN: Array<ToolItem> = [
  new ToolItem('☯️', $r("app.string.page_bagua"), 'sub_pages/devine_bagua/DevineBaGua', '趣味玩法'),
  new ToolItem('🪵', $r("app.string.page_muyu"), 'sub_pages/blessing_muyu/BlessingMuyu_V2', '趣味玩法'),
  new ToolItem('🍔🍜', $r("app.string.page_random_foods"), 'sub_pages/random_foods/RandomFoods', '趣味玩法'),
  new ToolItem('📖 ', $r("app.string.page_answer_book"), 'sub_pages/answer_book/AnswerBookPage', '趣味玩法'),
  new ToolItem('🎭', $r("app.string.page_honest_or_challenge"),
    'sub_pages/honest_or_challenge/HonestOrChallenge', '趣味玩法'),
  new ToolItem('👤', $r("app.string.page_random_names"), 'sub_pages/random_names/RandomNames', '趣味玩法'),
];

@Entry
@Component
struct ToolsPage {
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  private getPaddingH(): number {
    if (this.currentBreakpoint.value === 'sm') {
      return 8;
    }
    return 16;
  }

  /** 普通胶囊卡片 */
  @Builder
  CapsuleCard(item: ToolItem) {
    Row() {
      Text(item.emoji)
        .fontSize(14)
      Text(item.name)
        .fontSize(12)
        .fontColor($r("app.color.FontIcon_Fore1"))
        .margin({ left: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 10, right: 14, top: 6, bottom: 6 })
    .backgroundColor($r("app.color.Comp_Bg1"))
    .borderRadius(20)
    .margin({ right: 8, bottom: 8 })
    .onClick(() => {
      router.pushUrl({ url: item.url })
    })
  }

  /** 热门推荐胶囊卡片（高亮样式） */
  @Builder
  HotCapsuleCard(item: ToolItem) {
    Row() {
      Text(item.emoji)
        .fontSize(16)
      Text(item.name)
        .fontSize(13)
        .fontColor($r("app.color.FontIcon_Fore1"))
        .fontWeight(FontWeight.Medium)
        .margin({ left: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 12, right: 16, top: 8, bottom: 8 })
    .backgroundColor($r("app.color.Comp_Bg1"))
    .border({ width: 1, color: $r("app.color.Brand"), style: BorderStyle.Solid, radius: 20 })
    .margin({ right: 8, bottom: 8 })
    .onClick(() => {
      router.pushUrl({ url: item.url })
    })
  }

  /** 分类标题 */
  @Builder
  SectionHeader(emoji: string, title: string) {
    Row() {
      Text(`${emoji} ${title}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.FontIcon_Fore1"))
    }
    .width('100%')
    .padding({ left: this.getPaddingH(), top: 24, bottom: 10 })
  }

  /** 胶囊流式布局区域 */
  @Builder
  CapsuleSection(items: Array<ToolItem>, isHot: boolean) {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(items, (item: ToolItem) => {
        if (isHot) {
          this.HotCapsuleCard(item)
        } else {
          this.CapsuleCard(item)
        }
      })
    }
    .width('100%')
    .padding({ left: this.getPaddingH(), right: this.getPaddingH() })
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 热门推荐
          this.SectionHeader('🔥', '热门推荐')
          this.CapsuleSection(TOOLS_HOT, true)

          // 小工具
          this.SectionHeader('🛠️', '小工具')
          this.CapsuleSection(TOOLS_SMALL, false)

          // 趣味玩法
          this.SectionHeader('🎮', '趣味玩法')
          this.CapsuleSection(TOOLS_FUN, false)

          Blank().height(24)
        }.alignItems(HorizontalAlign.Start)
        .width('100%')
      }    .height('100%')
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }

    .backgroundColor($r("app.color.Comp_Bg3"))
    .width('100%')
    .height('100%')
  }
}

export default ToolsPage;
