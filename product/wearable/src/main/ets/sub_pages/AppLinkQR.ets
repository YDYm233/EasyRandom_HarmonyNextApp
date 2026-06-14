
@Component
 export struct AppLinkQR {
  private appLink: string = 'https://appgallery.huawei.com/app/detail?id=ydy.App.EasyRandom&channelId=SHARE&source=appshare'

  build() {
    Column() {
      // 标题
      Text('随易 App')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(0xFFFFFFFF)
        .margin({ bottom: 8 })

      // 二维码 - 使用适当尺寸防止溢出
      QRCode(this.appLink)
        .width(140)
        .height(140)
        .margin({ bottom: 8 })

      // 说明文字
      Text('扫码打开随易App')
        .fontSize(10)
        .fontColor(0xCCFFFFFF)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(12)
    .backgroundColor(0xFF1A1A1A)
  }
}
