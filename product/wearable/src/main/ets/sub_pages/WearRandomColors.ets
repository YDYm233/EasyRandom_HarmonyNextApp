import WearScreenUtil from '../utils/WearScreenUtil';

@Component
export struct WearRandomColors {
  build() {
    Column() {
      Text('🎨')
        .fontSize(WearScreenUtil.buttonFontSize)
      Text('随机颜色')
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
