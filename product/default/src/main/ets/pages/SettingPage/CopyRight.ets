
import { webview } from '@kit.ArkWeb';
@Component
struct CopyRight {
  @State src:string|Resource='http://www.m233.top/easyrandom/copyright.html'
  controller: webview.WebviewController = new webview.WebviewController();
  build() {
    Column(){
      Web({src:this.src,controller:this.controller})
        .onErrorReceive(()=>{
          this.src=$rawfile("copyright.html")
        })
    }
  }
}
export default CopyRight