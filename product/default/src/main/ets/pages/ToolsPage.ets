import { BreakpointState, BreakpointSystem } from '@ohos/common';
import router from '@ohos.router';

class ToolItem {
  emoji: string
  name: string
  url: string
  category: string

  constructor(emoji: string, name: string, url: string, category: string) {
    this.emoji = emoji;
    this.name = name;
    this.url = url;
    this.category = category;
  }
}

/** 小工具分类 */
const TOOLS_SMALL: Array<ToolItem> = [
  new ToolItem('🎲', '掷骰子', 'sub_pages/flip_dices/RollDices', '小工具'),
  new ToolItem('🪙', '抛硬币', 'sub_pages/flip_coin/FlipCoin', '小工具'),
  new ToolItem('🔢', '随机数字', 'sub_pages/random_numbers/RandomNumbers', '小工具'),
  new ToolItem('🔤', '随机字母', 'sub_pages/random_abcd/RandomABCD', '小工具'),
  new ToolItem('🎯', '随机地点', 'sub_pages/random_places/RandomPlaces', '小工具'),
  new ToolItem('📱', '二维码', 'sub_pages/trans_qr/TransQR', '小工具'),
  new ToolItem('🎨', '随机颜色', 'sub_pages/random_colors/RandomColors', '小工具'),
];

/** 趣味玩法分类 */
const TOOLS_FUN: Array<ToolItem> = [
  new ToolItem('🔮', '占卜八卦', 'sub_pages/devine_bagua/DevineBaGua', '趣味玩法'),
  new ToolItem('🪵', '电子木鱼', 'sub_pages/blessing_muyu/BlessingMuyu_V2', '趣味玩法'),
  new ToolItem('🎭', '真心话大冒险', 'sub_pages/honest_or_challenge/HonestOrChallenge', '趣味玩法'),
  new ToolItem('🍔', '随机美食', 'sub_pages/random_foods/RandomFoods', '趣味玩法'),
  new ToolItem('👤', '随机姓名', 'sub_pages/random_names/RandomNames', '趣味玩法'),
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

  /** 根据断点返回网格列数 */
  private getColumns(): number {
    if (this.currentBreakpoint.value === 'sm') {
      return 3;
    }
    if (this.currentBreakpoint.value === 'md') {
      return 4;
    }
    return 5;
  }

  /** 根据断点返回水平内边距 */
  private getPaddingH(): number {
    if (this.currentBreakpoint.value === 'sm') {
      return 6;
    }
    return 12;
  }

  /** 单个工具卡片 */
  @Builder
  ToolCard(item: ToolItem) {
    Column() {
      Text(item.emoji)
        .fontSize(30)
        .textAlign(TextAlign.Center)
      Text(item.name)
        .fontSize(11)
        .fontColor($r("app.color.FontIcon_Fore2"))
        .margin({ top: 4 })
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .borderRadius(12)
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
    .padding({ left: this.getPaddingH(), top: 20, bottom: 10 })
  }

  /** 工具网格区域 */
  @Builder
  ToolSection(items: Array<ToolItem>) {
    Grid() {
      ForEach(items, (item: ToolItem) => {
        GridItem() {
          this.ToolCard(item)
        }
      })
    }
    .columnsTemplate(this.getColumnsTemplate())
    .rowsGap(8)
    .columnsGap(8)
    .padding({ left: this.getPaddingH(), right: this.getPaddingH() })
  }

  private getColumnsTemplate(): string {
    const cols = this.getColumns();
    let template = '';
    for (let i = 0; i < cols; i++) {
      template += (i > 0 ? ' ' : '') + '1fr';
    }
    return template;
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          this.SectionHeader('🎮', '趣味玩法')
          this.ToolSection(TOOLS_FUN)
          this.SectionHeader('🛠️', '小工具')
          this.ToolSection(TOOLS_SMALL)



          // 底部留白，避免被导航栏遮挡
          Blank().height(20)
        }
        .width('100%')
      }
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .backgroundColor($r("app.color.Comp_Bg3"))
    .width('100%')
    .height('100%')
  }
}

export default ToolsPage;
