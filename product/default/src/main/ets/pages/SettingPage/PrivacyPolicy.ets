import { webview } from '@kit.ArkWeb';

@Component
struct PrivacyPolicy {
  @State src: string | Resource = $rawfile("privacypolicy.html")
  controller: webview.WebviewController = new webview.WebviewController();
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      Web({ src: this.src, controller: this.controller }).width("100%")
    }.title('隐私政策').width("100%")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      //console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}

export default PrivacyPolicy