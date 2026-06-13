import {Random} from '@ohos/basic-utils'
import { DEFAULT } from '@ohos/hypium';

// @Entry
@Component
export struct BaGuaCardDisplay {
  readonly FULL_WIDTH_PERCENT: string = '90%';
  @State rotateAngle:number = 0;
  build() {
    Row() {
      Image($r("app.media.BaGua"))
        .width(this.FULL_WIDTH_PERCENT)
        .aspectRatio(1)
        .animation({duration:600})
        .rotate({
          angle: this.rotateAngle
        })
        .borderRadius(24)
        .clip(true)
        .animation({ duration: 1000, curve: Curve.Ease })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.rotateAngle =this.rotateAngle+ Random(0, 7, true)*45 + 45 * 18;
    })
  }
}
// export default BaGuaCardDisplay