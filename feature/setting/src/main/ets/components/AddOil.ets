
@Component
struct Addoil {
  build() {
    RelativeContainer() {
      Text('加油')
        .id('PrivacyPolicyHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}
export default Addoil