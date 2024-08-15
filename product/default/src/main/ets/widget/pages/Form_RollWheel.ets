import {rolls, Roll, RollBox, RollItem } from '../../C_roll/RollPage'
import { Random } from '@ohos/common'
import { preferences } from '@kit.ArkData';
import { emitter } from '@kit.BasicServicesKit';
let datas: Roll = rolls[0]
let preferenceTheme: preferences.Preferences | null = null;
@Entry
@Component
struct WidgetCard {
  @State roll: Roll = datas
  @State angle: number = 0

  build() {
    Row() {
      Column() {
        RollBox({ data: this.roll })
          .animation({
            curve: Curve.EaseOut,
            playMode: PlayMode.Normal
          })
          .rotate({
            angle: this.angle
          })
      }.width('90%')
      .border({
        width: 10,
        color: 0xF1F3AF5,
        radius: '50%',
        style: BorderStyle.Solid
      })
    }
    .onClick(() => {
      this.angle = Random(0, 360, true) + 360 * 1;
    })
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}