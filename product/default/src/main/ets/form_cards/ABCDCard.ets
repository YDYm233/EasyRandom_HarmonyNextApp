import { Random } from '@ohos/basic-utils'
import { DEFAULT } from '@ohos/hypium'

/**
 * ABCD 随机选择卡片 — 2x2 四象限 + 旋转指针
 * 优化UI细节，参考wearable版本
 */
@Entry
@Component
export struct ABCDCard {
  @State angle: number = 30
  @State duration: number = 800
  @State colors: Resource[] = [
    $r("app.color.Comp_Bg4"),
    $r("app.color.Comp_Bg4"), 
    $r("app.color.Comp_Bg4"),
    $r("app.color.Comp_Bg4")
  ]
  @State fontColors: Resource[] = [
    $r("app.color.FontIcon_Fore1"),
    $r("app.color.FontIcon_Fore1"),
    $r("app.color.FontIcon_Fore1"),
    $r("app.color.FontIcon_Fore1")
  ]

  build() {
    Column() {
      // ABCD 四象限选择器
      Stack() {
        // 四象限背景容器
        Stack() {
          // A — 左上
          Text('A')
            .width('50%')
            .height('50%')
            .backgroundColor(this.colors[0])
            .fontColor(this.fontColors[0])
            .fontWeight(FontWeight.Bold)
            .fontSize(48)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: 4,
              color: $r("app.color.Comp_Bg2"),
              radius: { topLeft: $r('sys.float.ohos_id_corner_radius_card') }
            })
            .clip(true)
            .position({ x: 0, y: 0 })

          // B — 右上
          Text('B')
            .width('50%')
            .height('50%')
            .backgroundColor(this.colors[1])
            .fontColor(this.fontColors[1])
            .fontWeight(FontWeight.Bold)
            .fontSize(48)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: 4,
              color: $r("app.color.Comp_Bg2"),
              radius: { topRight: $r('sys.float.ohos_id_corner_radius_card') }
            })
            .clip(true)
            .position({ x: '50%', y: 0 })

          // C — 左下
          Text('C')
            .width('50%')
            .height('50%')
            .backgroundColor(this.colors[2])
            .fontColor(this.fontColors[2])
            .fontWeight(FontWeight.Bold)
            .fontSize(48)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: 4,
              color: $r("app.color.Comp_Bg2"),
              radius: { bottomLeft: $r('sys.float.ohos_id_corner_radius_card') }
            })
            .clip(true)
            .position({ x: 0, y: '50%' })

          // D — 右下
          Text('D')
            .width('50%')
            .height('50%')
            .backgroundColor(this.colors[3])
            .fontColor(this.fontColors[3])
            .fontWeight(FontWeight.Bold)
            .fontSize(48)
            .textAlign(TextAlign.Center)
            .border({
              style: BorderStyle.Solid,
              width: 4,
              color: $r("app.color.Comp_Bg2"),
              radius: { bottomRight: $r('sys.float.ohos_id_corner_radius_card') }
            })
            .clip(true)
            .position({ x: '50%', y: '50%' })
        }
        .width('100%')
        .height('100%')

        // 旋转指针（居中显示）
        Image($r("app.media.pointer_m"))
          .width('60%')
          .aspectRatio(1)
          .fillColor($r("app.color.FontIcon_Fore2"))
          .rotate({ angle: this.angle })
          .animation({ duration: this.duration, curve: Curve.Ease })
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg2"))
    .padding(4)
    .onClick(() => {
      // 重置所有颜色
      this.colors[0] = $r("app.color.Comp_Bg4")
      this.colors[1] = $r("app.color.Comp_Bg4")
      this.colors[2] = $r("app.color.Comp_Bg4")
      this.colors[3] = $r("app.color.Comp_Bg4")
      this.fontColors[0] = $r("app.color.FontIcon_Fore1")
      this.fontColors[1] = $r("app.color.FontIcon_Fore1")
      this.fontColors[2] = $r("app.color.FontIcon_Fore1")
      this.fontColors[3] = $r("app.color.FontIcon_Fore1")

      // 旋转指针，动画结束后高亮结果
      animateTo({
        duration: this.duration,
        curve: Curve.Ease,
        onFinish: () => {
          const normAngle = this.angle % 360
          if (normAngle < 90) {
            this.colors[1] = $r("app.color.Brand")
            this.fontColors[1] = $r("app.color.FontIcon_Back1")
          } else if (normAngle < 180) {
            this.colors[3] = $r("app.color.Brand")
            this.fontColors[3] = $r("app.color.FontIcon_Back1")
          } else if (normAngle < 270) {
            this.colors[2] = $r("app.color.Brand")
            this.fontColors[2] = $r("app.color.FontIcon_Back1")
          } else {
            this.colors[0] = $r("app.color.Brand")
            this.fontColors[0] = $r("app.color.FontIcon_Back1")
          }
        }
      }, () => {
        this.angle += Random(1, 360, true) + 360 * 3
        if (this.angle > 36000000) {
          this.angle = Random(1, 360, true) + 360 * 3
        }
      })
    })
  }
}
export default ABCDCard