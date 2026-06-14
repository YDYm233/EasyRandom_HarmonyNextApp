import { Random } from '@ohos/basic-utils'
import { DEFAULT } from '@ohos/hypium'

/**
 * ABCD 随机选择卡片展示 — 2x2 四象限 + 旋转指针
 * 优化UI细节，参考wearable版本
 */
@Component
export struct ABCDCardDisplay {
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
              width: 5,
              color: $r("app.color.Comp_Bg2"),
              radius: { topLeft: 12 }
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
              width: 5,
              color: $r("app.color.Comp_Bg2"),
              radius: { topRight: 12 }
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
              width: 5,
              color: $r("app.color.Comp_Bg2"),
              radius: { bottomLeft: 12 }
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
              width: 5,
              color: $r("app.color.Comp_Bg2"),
              radius: { bottomRight: 12 }
            })
            .clip(true)
            .position({ x: '50%', y: '50%' })
        }
        .width('100%')
        .height('100%')

        // 旋转指针（居中显示）
        Image($r("app.media.needle"))
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

      // 旋转指针
      this.angle += Random(1, 360, true) + 360 * 3
      if (this.angle > 36000000) {
        this.angle = Random(1, 360, true) + 360 * 3
      }

      // 延迟高亮结果
      animateTo({
        duration: 1,
        iterations: 1,
        curve: Curve.EaseIn,
        delay: 1000
      }, () => {
        const normAngle = this.angle % 360
        if (normAngle < 90) {
          this.colors[1] = $r("app.color.Brand") // B
        } else if (normAngle < 180) {
          this.colors[3] = $r("app.color.Brand") // D
        } else if (normAngle < 270) {
          this.colors[2] = $r("app.color.Brand") // C
        } else {
          this.colors[0] = $r("app.color.Brand") // A
        }
      })
    })
  }
}
// export default ABCDCard