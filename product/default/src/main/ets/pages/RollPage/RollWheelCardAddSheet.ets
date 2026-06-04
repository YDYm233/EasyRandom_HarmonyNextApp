import { AddFormMenuItem } from '@kit.ArkUI'
import { formBindingData } from '@kit.FormKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Roll, RollItem, defaultRolls } from './RollDataManager'

const TAG = 'RollWheelCardAddSheet'
const DOMAIN = 0x0000

/**
 * 转盘卡片添加弹出层
 * 用于API 18以下版本，提供卡片预览和添加功能
 */
@Component
export struct RollWheelCardAddSheet {
  // 当前转盘数据
  @Prop currentRoll: Roll = defaultRolls[0]
  // 弹出层关闭回调
  onClose: () => void = () => {}
  
  // 组件ID，用于AddFormMenuItem绑定
  private addDesktopBtnId: string = 'add_desktop_btn_' + Date.now()
  
  // 卡片预览数据
  @State previewRotateAngle: number = 0

  /**
   * 添加到桌面的菜单
   */
  @Builder
  AddDesktopMenu() {
    Menu() {
      AddFormMenuItem(
        {
          bundleName: 'ydy.App.EasyRandom',
          abilityName: 'DefaultFormAbility',
          parameters: {
            'ohos.extra.param.key.form_dimension': 2,
            'ohos.extra.param.key.form_name': 'RollWheelCard',
            'ohos.extra.param.key.module_name': 'default',
            'ohos.extra.param.key.form_location': 0 // 0表示桌面
          }
        },
        this.addDesktopBtnId,
        {
          formBindingData: formBindingData.createFormBindingData({
            rollName: this.currentRoll.rollName,
            rollItemsJson: JSON.stringify(this.currentRoll.rollItems)
          }),
          callback: (error, formId) => {
            if (error?.code === 0) {
              hilog.info(DOMAIN, TAG, '添加到桌面成功, formId: %{public}s', formId)
              this.onClose()
            } else {
              hilog.error(DOMAIN, TAG, '添加到桌面失败: %{public}s', JSON.stringify(error))
            }
          }
        }
      )
    }
  }

  build() {
    Column() {
      // 顶部拖拽指示条
      Row() {
        Row()
          .width(40)
          .height(4)
          .backgroundColor($r("app.color.Comp_Bg3"))
          .borderRadius(2)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 12, bottom: 16 })
      
      // 标题区域
      Column() {
        Text('添加转盘卡片')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r("app.color.FontIcon_Fore1"))
        
        Text('长按下方按钮将卡片添加到桌面')
          .fontSize(14)
          .fontColor($r("app.color.FontIcon_Fore2"))
          .margin({ top: 6 })
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 卡片预览区域
      Column() {
        // 卡片容器 - 模拟桌面卡片样式
        Column() {
          Row() {
            RollWheelPreview({ data: this.currentRoll, rotateAngle: this.previewRotateAngle })
              .width('75%')
              .aspectRatio(1)
            
            Image($r("app.media.pointer_m"))
              .zIndex(8)
              .width('22%')
              .aspectRatio(1)
              .fillColor($r("app.color.FontIcon_Back1"))
              .position({ top: '39%', left: '39%' })
          }
          .width('100%')
          .height('75%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          
          // 转盘名称
          Text(this.currentRoll.rollName)
            .fontColor($r("app.color.FontIcon_Fore1"))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('90%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        }
        .width('85%')
        .aspectRatio(1)
        .padding(12)
        .backgroundColor($r("app.color.Comp_Bg1"))
        .borderRadius(16)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 24 })
      
      // 操作按钮区域
      Column({ space: 12 }) {
        // 添加到桌面按钮
        Button('添加到桌面')
          .id(this.addDesktopBtnId)
          .width('85%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r("app.color.Brand"))
          .fontColor(Color.White)
          .borderRadius(25)
          .bindContextMenu(this.AddDesktopMenu, ResponseType.LongPress, {
            placement: Placement.Top
          })
        
        // 取消按钮
        Button('取消')
          .width('85%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r("app.color.Comp_Bg2"))
          .fontColor($r("app.color.FontIcon_Fore1"))
          .borderRadius(25)
          .onClick(() => {
            this.onClose()
          })
      }
      .width('100%')
      .padding({ bottom: 32 })
    }
    .width('100%')
    .backgroundColor($r("app.color.Comp_Bg1"))
    .borderRadius({ topLeft: 28, topRight: 28 })
  }
}

/**
 * 转盘预览组件（简化版，用于预览）
 */
@Component
struct RollWheelPreview {
  @Prop data: Roll = defaultRolls[0]
  @Prop rotateAngle: number = 0
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.canvasContext)
        .onReady(() => {
          this.drawWheel()
        })
        .width('100%')
        .aspectRatio(1)
    }
    .width('100%')
    .aspectRatio(1)
    .rotate({ angle: this.rotateAngle })
    .border({
      width: 5,
      color: $r("app.color.Comp_Bg4"),
      radius: '50%',
      style: BorderStyle.Solid
    })
  }

  private drawWheel(): void {
    const ctx = this.canvasContext
    const canvasWidth = ctx.width
    if (canvasWidth <= 0) {
      return
    }
    ctx.clearRect(0, 0, canvasWidth, canvasWidth)
    const radius = canvasWidth / 2
    const rollItems: Array<RollItem> = this.data.rollItems
    if (rollItems.length === 0) {
      return
    }
    const totalWeight = rollItems.reduce<number>(
      (sum: number, rollItem: RollItem) => sum + rollItem.weight, 0)
    if (totalWeight === 0) {
      return
    }
    let startAngle = -rollItems[0].weight / totalWeight * 180 + 90

    rollItems.forEach((rollItem: RollItem) => {
      const endAngle: number = startAngle + (rollItem.weight / totalWeight) * 360
      const centerAngle = (startAngle + endAngle) / 2

      ctx.globalCompositeOperation = 'xor'
      ctx.beginPath()
      ctx.moveTo(radius, radius)
      ctx.arc(radius, radius, radius,
        startAngle * Math.PI / 180,
        endAngle * Math.PI / 180, false)
      ctx.closePath()
      ctx.fillStyle = rollItem.color
      ctx.fill()

      ctx.fillStyle = '#FFFFFF'
      ctx.textAlign = 'center'
      ctx.save()
      ctx.translate(radius, radius)
      ctx.rotate((centerAngle + 90) * Math.PI / 180)

      const chars: Array<string> = rollItem.text.split('')
      const topOffset = radius * 0.1 + (radius * 0.1 / chars.length)
      const lineHeight = (radius - topOffset) / (chars.length + 1)
      const fontSizePx = lineHeight
      ctx.font = fontSizePx.toString() + 'vp'

      for (let i: number = 0; i < chars.length; i++) {
        ctx.fillText(chars[i], 0,
          (-radius + lineHeight + topOffset / 2 + i * lineHeight),
          fontSizePx)
      }
      ctx.restore()

      startAngle = endAngle
    })

    ctx.beginPath()
    ctx.moveTo(radius, radius)
    ctx.arc(radius, radius, radius / 10, -45, 275, false)
    ctx.closePath()
    ctx.fillStyle = 0xf1f3f5
    ctx.fill()
  }
}
