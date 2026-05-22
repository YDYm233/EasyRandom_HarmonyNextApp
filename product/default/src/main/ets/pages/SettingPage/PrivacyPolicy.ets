import { webview } from '@kit.ArkWeb';

@Builder
export function PrivacyPolicy() {
  PrivacyPolicyComponent();
}

@Component
struct PrivacyPolicyComponent {
  @State src: string | Resource = $rawfile("privacypolicy.html")
  controller: webview.WebviewController = new webview.WebviewController();
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
      Web({ src: this.src, controller: this.controller }).width("100%").height("100%")
    }.title('隐私政策')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      //console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}

// export default PrivacyPolicyComponent