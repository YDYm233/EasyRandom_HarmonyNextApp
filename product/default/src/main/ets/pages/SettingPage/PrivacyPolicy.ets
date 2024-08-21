import { webview } from '@kit.ArkWeb';

@Component
struct PrivacyPolicy {
@State src:string|Resource=$rawfile("privacypolicy.html")
  controller: webview.WebviewController = new webview.WebviewController();
  build() {
    Column(){
      Web({src:this.src,controller:this.controller}).width("100%")
    }.width("100%")
  }
}
export default PrivacyPolicy