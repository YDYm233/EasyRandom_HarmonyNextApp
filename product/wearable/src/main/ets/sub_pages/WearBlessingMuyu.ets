import WearScreenUtil from '../utils/WearScreenUtil';

@Component
export struct WearBlessingMuyu {
  build() {
    Column() {
      Text('🪵')
        .fontSize(WearScreenUtil.buttonFontSize)
      Text('祝福木鱼')
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0xFFCCCCCC)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
