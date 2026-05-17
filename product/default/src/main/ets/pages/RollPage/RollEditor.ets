import { Roll, RollItem } from '../../static_datas/rolls'
import { Random } from '@ohos/common'
import { promptAction } from '@kit.ArkUI'
import { saveRollsToPrefs } from './RollDataManager'
import { RollDetailEditor } from './RollDetailEditor'

/** Navigation 推页参数：转盘详情页 */
export class RollDetailParams {
  rollIndex: string
  constructor(rollIndex: string) {
    this.rollIndex = rollIndex
  }
}

/** 预设颜色板 */
const COLOR_PRESETS: string[] = [
  '#ffcba50b', '#ffa87cf4', '#ffe81b58', '#ff38ed44', '#fff7942c', '#ff68ead0',
  '#ffff007a', '#ff0cdec5', '#ff05f80b', '#ffecb609', '#ff5f16e1', '#499821',
  '#ffde6e12', '#ff3498db', '#ff9b59b6', '#ff1abc9c', '#ffe74c3c', '#fff39c12'
]

@CustomDialog
struct NewRollDialog {
  controller: CustomDialogController
  @State inputName: string = ''
  onConfirm?: (name: string) => void

  build() {
    Column({ space: 0 }) {
      // 标题区域
      Row() {
        Text('新建转盘')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.FontIcon_Fore1'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 24, bottom: 20 })
      .backgroundColor($r('app.color.Comp_Bg1'))
      .borderRadius({ topLeft: 16, topRight: 16 })

      // 内容区域
      Column({ space: 16 }) {
        Text('为你的新转盘起一个名字')
          .fontSize(14)
          .fontColor($r('app.color.FontIcon_Fore2'))
          .width('100%')
          .textAlign(TextAlign.Start)
        
        TextInput({ placeholder: '输入转盘名称...', text: this.inputName })
          .fontSize(16)
          .backgroundColor($r('app.color.Comp_Bg2'))
          .borderRadius(12)
          .height(48)
          .width('100%')
          .padding({ left: 16, right: 16 })
          .border({
            width: 1,
            color: this.inputName.length > 0 ? $r('app.color.Brand') : $r('app.color.Comp_Bg3'),
            style: BorderStyle.Solid
          })
          .onChange((v: string) => {
            this.inputName = v
          })
        
        // 按钮区域
        Row({ space: 12 }) {
          Button('取消')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.Comp_Bg3'))
            .fontColor($r('app.color.FontIcon_Fore2'))
            .layoutWeight(1)
            .height(44)
            .borderRadius(8)
            .onClick(() => {
              this.controller.close()
            })
          Button('创建')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.inputName.trim().length > 0 ? $r('app.color.Brand') : $r('app.color.Comp_Bg3'))
            .fontColor(this.inputName.trim().length > 0 ? Color.White : $r('app.color.FontIcon_Fore3'))
            .layoutWeight(1)
            .height(44)
            .borderRadius(8)
            .onClick(() => {
              if (this.inputName.trim().length === 0) {
                promptAction.showToast({ message: '请输入转盘名称' })
                return
              }
              this.onConfirm?.(this.inputName.trim())
              this.controller.close()
            })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .padding({ left: 24, right: 24, bottom: 24 })
    }
    .width('80%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 24, color: '#1A000000', offsetX: 0, offsetY: 8 })
  }
}

// 转盘管理列表内容（作为半模态内 Navigation 的主内容区）
@Component
struct RollManageContent {
  @StorageLink('allRolls') allRolls: Roll[] = []
  @Consume('navPathStack') navPathStack: NavPathStack
  private newRollDialog: CustomDialogController = new CustomDialogController({
    builder: NewRollDialog({
      onConfirm: (name: string) => {
        this.createRoll(name)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true,
    cornerRadius: 16
  })

  build() {
    Column() {
      // 列表区域（始终显示列表，即使为空）
      List({ space: 8 }) {
        ForEach(this.allRolls, (roll: Roll) => {
          ListItem() {
            this.RollCard(roll)
          }
        }, (roll: Roll) => roll.index)
        // 新建转盘按钮作为最后一个列表项
        ListItem() {
          Row() {
            Image($r('sys.symbol.plus'))
              .width(28).height(28)
              .fillColor(Color.White)
          }
          .width('100%')
          .height(64)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .backgroundColor($r('app.color.Brand'))
          .borderRadius(12)
          .border({
            width: 2,
            color: $r('app.color.Brand'),
            style: BorderStyle.Solid
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
        }
        .onClick(() => {
          this.newRollDialog.open()
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .alignListItem(ListItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.Comp_Bg2'))
  }

  @Builder
  RollCard(roll: Roll) {
    Row() {
      // 颜色圆点 - 更大更醒目
      Row()
        .width(14).height(14)
        .borderRadius(7)
        .backgroundColor(roll.rollItems.length > 0 ? roll.rollItems[0].color : '#CCCCCC')
        .margin({ right: 12 })
        .shadow({ radius: 2, color: '#40000000', offsetX: 0, offsetY: 1 })
      
      Column({ space: 4 }) {
        Text(roll.rollName)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.FontIcon_Fore1'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(`${roll.rollItems.length}个选项`)
          .fontSize(13)
          .fontColor($r('app.color.FontIcon_Fore3'))
          .opacity(0.8)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      // 右侧箭头和计数区域
      Row({ space: 8 }) {
        if (roll.rollItems.length > 0) {
          Text(roll.rollItems.length.toString())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.Brand'))
            .backgroundColor($r('app.color.Comp_Bg3'))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
        }
        Image($r('sys.symbol.chevron_right'))
          .width(20).height(20)
          .fillColor($r('app.color.FontIcon_Fore3'))
          .opacity(0.7)
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 20, right: 16, top: 18, bottom: 18 })
    .borderRadius(14)
    .backgroundColor($r('app.color.Comp_Bg1'))
    .border({
      width: 1,
      color: $r('app.color.Comp_Bg3'),
      style: BorderStyle.Solid
    })
    .shadow({ radius: 6, color: '#0A000000', offsetX: 0, offsetY: 2 })
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.96 })
    .onClick(() => {
      this.navPathStack.pushPathByName('RollDetailEditor', new RollDetailParams(roll.index))
    })
  }

  // ==================== 操作方法 ====================

  private persist(): void {
    const ctx = getContext(this).getApplicationContext()
    saveRollsToPrefs(ctx, this.allRolls)
  }

  private createRoll(name: string): void {
    const newIndex = `custom_${Date.now()}`
    // 生成三个选项，权重1~10随机，颜色从预设中随机选取（不重复）
    const colorIndices: number[] = []
    while (colorIndices.length < 3) {
      const idx = Random(0, COLOR_PRESETS.length - 1, true)
      if (!colorIndices.includes(idx)) {
        colorIndices.push(idx)
      }
    }
    const rollItems = [
      new RollItem(`${newIndex}_0`, '选项A', Random(1, 10, true), COLOR_PRESETS[colorIndices[0]]),
      new RollItem(`${newIndex}_1`, '选项B', Random(1, 10, true), COLOR_PRESETS[colorIndices[1]]),
      new RollItem(`${newIndex}_2`, '选项C', Random(1, 10, true), COLOR_PRESETS[colorIndices[2]])
    ]
    const roll = new Roll(newIndex, name, rollItems)
    this.allRolls.push(roll)
    this.persist()
    promptAction.showToast({ message: `已创建"${name}"` })
  }
}

// 半模态窗口内的导航宿主，承载管理页→详情页的深层转场
@Component
export struct RollEditSheet {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string, param: ESObject) {
    if (name == 'RollDetailEditor') {
      RollDetailEditor({ rollIndex: (param as RollDetailParams).rollIndex })
    }
  }

  build() {
    Navigation(this.navPathStack) {
      RollManageContent()
    }
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .hideTitleBar(false)
    .hideToolBar(true)
    .title('转盘管理')
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.Comp_Bg2'))
  }
}
