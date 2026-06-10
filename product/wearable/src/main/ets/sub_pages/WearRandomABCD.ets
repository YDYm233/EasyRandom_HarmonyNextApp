import WearScreenUtil from '../utils/WearScreenUtil';

@Component
export struct WearRandomABCD {
  build() {
    Column() {
      Text('🔤')
        .fontSize(WearScreenUtil.buttonFontSize)
      Text('ABCD')
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
