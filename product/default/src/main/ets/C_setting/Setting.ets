@Entry
@Component
struct Setting {
  build() {
    List({ space: 12 }) {
      ListItem() {
      }
      .padding({ top: 8, bottom: 8 })
      .width('100%')

    }
    .padding({ left: 12, right: 12 })
    .width('100%')
    .height('100%')
    .backgroundColor('#bfc')
  }
}

export default Setting