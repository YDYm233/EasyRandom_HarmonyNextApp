import { Roll, RollItem } from '../../static_datas/rolls'
import { promptAction } from '@kit.ArkUI'
import { saveRollsToPrefs } from './RollDataManager'

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
    Column() {
      Text('新建转盘')
        .fontSize(18)
        .fontWeight(700)
        .fontColor($r('app.color.FontIcon_Fore1'))
        .margin({ bottom: 16 })
      TextInput({ placeholder: '输入转盘名称', text: this.inputName })
        .fontSize(15)
        .backgroundColor($r('app.color.Comp_Bg2'))
        .borderRadius(8)
        .height(44)
        .width('100%')
        .onChange((v: string) => {
          this.inputName = v
        })
        .margin({ bottom: 20 })
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(14)
          .backgroundColor($r('app.color.Comp_Bg3'))
          .fontColor($r('app.color.FontIcon_Fore2'))
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
          })
        Button('创建')
          .fontSize(14)
          .backgroundColor($r('app.color.Brand'))
          .fontColor(Color.White)
          .layoutWeight(1)
          .onClick(() => {
            if (this.inputName.trim().length === 0) {
              promptAction.showToast({ message: '名称不能为空' })
              return
            }
            this.onConfirm?.(this.inputName.trim())
            this.controller.close()
          })
      }
      .width('100%')
    }
    .padding(20)
  }
}

@Component
export struct RollEditor {
  @StorageLink('allRolls') allRolls: Roll[] = []
  @State expandIndex: number = -1
  private newRollDialog: CustomDialogController = new CustomDialogController({
    builder: NewRollDialog({ onConfirm: (name: string) => {
      this.createRoll(name)
    } }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true,
    cornerRadius: 16
  })

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('转盘管理')
          .fontSize(18)
          .fontWeight(700)
          .fontColor($r('app.color.FontIcon_Fore1'))
        Blank()
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Row() {
            Image($r('sys.symbol.plus'))
              .width(14).height(14)
              .fillColor(Color.White)
            Text('新建').fontSize(13).fontColor(Color.White).margin({ left: 4 })
          }
        }
        .backgroundColor($r('app.color.Brand'))
        .onClick(() => {
          this.newRollDialog.open()
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 转盘列表
      if (this.allRolls.length === 0) {
        Column() {
          Text('暂无转盘')
            .fontSize(15)
            .fontColor($r('app.color.FontIcon_Fore3'))
            .margin({ top: 60 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.allRolls, (roll: Roll, idx: number) => {
              this.RollCard(roll, idx)
            }, (roll: Roll) => roll.index)
          }
          .padding({ left: 16, right: 16, bottom: 40 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  RollCard(roll: Roll, idx: number) {
    Column() {
      // 折叠状态：摘要行
      Row() {
        // 颜色圆点
        Row()
          .width(10).height(10)
          .borderRadius(5)
          .backgroundColor(roll.rollItems.length > 0 ? roll.rollItems[0].color : '#CCCCCC')
          .margin({ right: 8 })
        Text(roll.rollName)
          .fontSize(16)
          .fontWeight(600)
          .fontColor($r('app.color.FontIcon_Fore1'))
          .layoutWeight(1)
        Text(`${roll.rollItems.length}个选项`)
          .fontSize(12)
          .fontColor($r('app.color.FontIcon_Fore3'))
          .margin({ right: 10 })
        Image($r('sys.symbol.chevron_right'))
          .width(18).height(18)
          .fillColor($r('app.color.FontIcon_Fore3'))
          .rotate({ angle: this.expandIndex === idx ? 90 : 0 })
          .animation({ duration: 200 })
      }
      .width('100%')
      .padding({ left: 16, right: 12, top: 14, bottom: 14 })
      .borderRadius(12)
      .backgroundColor($r('app.color.Comp_Bg1'))
      .onClick(() => {
        this.expandIndex = this.expandIndex === idx ? -1 : idx
      })

      // 展开状态：详细编辑
      if (this.expandIndex === idx) {
        Column({ space: 10 }) {
          Divider().color($r('app.color.Comp_Bg3')).width('100%')

          // 修改转盘名称
          Row() {
            Text('名称').fontSize(14).fontColor($r('app.color.FontIcon_Fore2')).width(36)
            TextInput({ text: roll.rollName })
              .fontSize(14)
              .layoutWeight(1)
              .backgroundColor($r('app.color.Comp_Bg2'))
              .borderRadius(8)
              .height(36)
              .onChange((v: string) => {
                roll.rollName = v
                this.persist()
              })
          }
          .width('100%')
          .padding({ left: 8, right: 8 })

          // 子选项列表标题
          Row() {
            Text('选项列表').fontSize(13).fontColor($r('app.color.FontIcon_Fore2'))
            Blank()
            Button() {
              Row() {
                Image($r('sys.symbol.plus_circle'))
                  .width(15).height(15)
                  .fillColor($r('app.color.Brand'))
                Text('添加').fontSize(12).fontColor($r('app.color.Brand')).margin({ left: 3 })
              }
            }
            .type(ButtonType.Normal)
            .backgroundColor(0)
            .height(30)
            .onClick(() => {
              this.addRollItem(roll)
            })
          }
          .width('100%')
          .padding({ left: 8, right: 4 })

          // 子选项
          ForEach(roll.rollItems, (item: RollItem, itemIdx: number) => {
            this.ItemEditor(roll, item, itemIdx)
          }, (item: RollItem) => `${roll.index}_${item.id}`)

          // 删除转盘
          Button() {
            Row() {
              Image($r('sys.symbol.trash'))
                .width(16).height(16)
                .fillColor('#FFE74C3C')
              Text(' 删除此转盘').fontSize(13).fontColor('#FFE74C3C')
            }
          }
          .type(ButtonType.Normal)
          .backgroundColor('#1AE74C3C')
          .borderRadius(8)
          .width('100%')
          .height(38)
          .margin({ top: 4 })
          .onClick(() => {
            AlertDialog.show({
              title: '确认删除',
              message: `确定要删除"${roll.rollName}"吗？`,
              autoCancel: true,
              alignment: DialogAlignment.Center,
              primaryButton: { value: '取消', action: () => {} },
              secondaryButton: {
                value: '删除',
                fontColor: '#E74C3C',
                action: () => {
                  this.deleteRoll(idx)
                }
              }
            })
          })
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 12 })
      }
    }
    .borderRadius(12)
    .backgroundColor($r('app.color.Comp_Bg1'))
  }

  @Builder
  ItemEditor(roll: Roll, item: RollItem, itemIdx: number) {
    Column({ space: 8 }) {
      // 文字 + 占比 + 删除
      Row({ space: 6 }) {
        TextInput({ text: item.text })
          .fontSize(13)
          .layoutWeight(2)
          .backgroundColor($r('app.color.Comp_Bg3'))
          .borderRadius(6)
          .height(32)
          .padding({ left: 8, right: 8 })
          .onChange((v: string) => {
            item.text = v
            this.persist()
          })
        Row() {
          Text('占比')
            .fontSize(11)
            .fontColor($r('app.color.FontIcon_Fore3'))
            .margin({ right: 3 })
          TextInput({ text: item.weight.toString() })
            .fontSize(13)
            .type(InputType.Number)
            .width(44)
            .backgroundColor($r('app.color.Comp_Bg3'))
            .borderRadius(6)
            .height(32)
            .onChange((v: string) => {
              const n = parseInt(v)
              if (!isNaN(n) && n > 0) {
                item.weight = n
                this.persist()
              }
            })
        }
        .layoutWeight(1)
        Image($r('sys.symbol.minus_circle'))
          .width(22).height(22)
          .fillColor('#FFE74C3C')
          .onClick(() => {
            if (roll.rollItems.length <= 2) {
              promptAction.showToast({ message: '至少保留2个选项' })
              return
            }
            roll.rollItems.splice(itemIdx, 1)
            this.persist()
          })
      }
      .width('100%')

      // 颜色选择器
      Row({ space: 4 }) {
        Text('颜色').fontSize(11).fontColor($r('app.color.FontIcon_Fore3')).margin({ right: 4 })
        Scroll() {
          Row({ space: 4 }) {
            ForEach(COLOR_PRESETS, (color: string) => {
              Row() {
                if (item.color.toLowerCase() === color.toLowerCase()) {
                  Text('✓').fontSize(10).fontColor(Color.White)
                }
              }
              .width(22).height(22)
              .borderRadius(11)
              .backgroundColor(color)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                item.color = color
                this.persist()
              })
            }, (c: string) => c)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 8, right: 4, top: 8, bottom: 8 })
    .backgroundColor($r('app.color.Comp_Bg2'))
    .borderRadius(8)
  }

  // ==================== 操作方法 ====================

  private persist(): void {
    const ctx = getContext(this).getApplicationContext()
    saveRollsToPrefs(ctx, this.allRolls)
  }

  private addRollItem(roll: Roll): void {
    const newId = Date.now().toString()
    const fallbackColor = COLOR_PRESETS[Math.floor(Math.random() * COLOR_PRESETS.length)]
    roll.rollItems.push(new RollItem(newId, '新选项', 1, fallbackColor))
    this.persist()
  }

  private deleteRoll(idx: number): void {
    this.allRolls.splice(idx, 1)
    if (this.expandIndex === idx) {
      this.expandIndex = -1
    } else if (this.expandIndex > idx) {
      this.expandIndex--
    }
    this.persist()
    promptAction.showToast({ message: '已删除' })
  }

  private createRoll(name: string): void {
    const newIndex = `custom_${Date.now()}`
    const roll = new Roll(newIndex, name, [
      new RollItem(`${newIndex}_0`, '选项A', 1, COLOR_PRESETS[0]),
      new RollItem(`${newIndex}_1`, '选项B', 1, COLOR_PRESETS[1])
    ])
    this.allRolls.push(roll)
    this.persist()
    promptAction.showToast({ message: `已创建"${name}"` })
  }
}
