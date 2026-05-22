@Preview
@Component
struct Components{
  build() {
    Row(){
      Button('normal').layoutWeight(1).aspectRatio(2).backgroundColor(0xffffff).fontColor(0xffffff)
      Button('normal').layoutWeight(1).aspectRatio(2).backgroundColor(0xffffff).fontColor(0xffffff)
      Button('normal').layoutWeight(1).aspectRatio(2).backgroundColor(0xffffff).fontColor(0xffffff)
    }
  }
}