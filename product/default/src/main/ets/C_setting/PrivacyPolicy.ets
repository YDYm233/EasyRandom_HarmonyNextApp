import { webview } from '@kit.ArkWeb';

@Component
struct PrivacyPolicy {
@State src:string|Resource='http://www.m233.top/easyrandom/privacypolicy.html'
  controller: webview.WebviewController = new webview.WebviewController();
  build() {
    Column(){
      Web({src:this.src,controller:this.controller})
        .onErrorReceive(()=>{
          this.src=$rawfile("privacypolicy.html")
        })
    }
  }
}
export default PrivacyPolicy