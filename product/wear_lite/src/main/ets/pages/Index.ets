// product/wear_lite/src/main/ets/pages/Index.ets
// Lite Wearable 主入口 — 使用基础 Swiper，避开 ArcSwiper/Canvas 2D 等高级 API

/**
 * 手表端（Lite Wearable）主页
 *
 * 与 wearable 模块的区别：
 *   - 不使用 ArcSwiper/ArcSwiperController（lite wearable 不支持）
 *   - 不使用 CanvasRenderingContext2D（lite wearable 不支持）
 *   - 仅使用基础 ArkUI 组件：Swiper, Column, Text, Button, Stack
 *   - deviceTypes: ["liteWearable"]
 *
 * 页面排列：[0]负一屏 ← [1]幸运转盘★(默认) → [2]木鱼 → ... → [8]随机颜色
 */
@Entry
@Component
struct Index {
  private swiperController: SwiperController = new SwiperController();

  build() {
    Swiper(this.swiperController) {
      // [0] 负一屏 — 快捷导航
      this.buildPage('🧭', '快捷导航')

      // [1] 幸运转盘 — P0 默认页
      this.buildPage('🎡', '幸运转盘')

      // [2] 祝福木鱼 — P0
      this.buildPage('🪵', '祝福木鱼')

      // [3] 真心话大冒险 — P0
      this.buildPage('💬', '真心话大冒险')

      // [4] 掷骰子
      this.buildPage('🎲', '掷骰子')

      // [5] 丢硬币
      this.buildPage('🪙', '丢硬币')

      // [6] ABCD 选择
      this.buildPage('🔤', 'ABCD')

      // [7] 八卦占卜
      this.buildPage('☯', '八卦占卜')

      // [8] 随机颜色
      this.buildPage('🎨', '随机颜色')
    }
    .index(1)          // 默认显示幸运转盘
    .loop(false)       // 不循环（负一屏不应循环到最右侧）
    .indicator(
      new DotIndicator()
        .color(0x33FFFFFF)
        .selectedColor(0xFFD4A017)
    )
    .duration(300)
  }

  @Builder
  buildPage(icon: string, name: string) {
    Column() {
      Text(icon)
        .fontSize(36)
      Text(name)
        .fontSize(14)
        .fontColor(0xFFCCCCCC)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(0xFF1A1A1A)
  }
}
