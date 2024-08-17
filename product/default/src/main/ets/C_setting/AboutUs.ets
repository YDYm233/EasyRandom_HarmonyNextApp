import { webview } from '@kit.ArkWeb';

@Component
struct AboutUs {
  controller: webview.WebviewController = new webview.WebviewController();
  build() {
    Column(){
      Web({src:$rawfile("MyInfo.html"),controller:this.controller})

    }
  }
}

export default AboutUs