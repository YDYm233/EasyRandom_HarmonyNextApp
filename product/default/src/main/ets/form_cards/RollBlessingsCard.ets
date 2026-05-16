@Entry
@Component
struct RollBlessingsCard {
  readonly TITLE: string = 'Hello World'
  readonly ACTION_TYPE: string = 'router'
  readonly ABILITY_NAME: string = 'EntryAbility'
  readonly MESSAGE: string = 'add detail'
  readonly FULL_WIDTH_PERCENT: string = '100%'
  readonly FULL_HEIGHT_PERCENT: string = '100%'

  build() {
    Row() {
      Column() {
        Text(this.TITLE)
          .fontSize($r('app.float.font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.item_title_font'))
      }
      .width(this.FULL_WIDTH_PERCENT)
    }
    .height(this.FULL_HEIGHT_PERCENT)
    .onClick(() => {
      postCardAction(this, {
        action: this.ACTION_TYPE,
        abilityName: this.ABILITY_NAME,
        params: {
          message: this.MESSAGE,
          cardClick: 'blessing_muyu'  // 标记：卡片点击，由 EntryAbility 处理计数
        }
      })
    })
  }
}
export default RollBlessingsCard
