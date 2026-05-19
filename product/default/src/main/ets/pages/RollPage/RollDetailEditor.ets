import { RollWheel } from './RollWheel'
import { promptAction } from '@kit.ArkUI'
import {
  Roll, RollItem,
  saveRollsToPrefs, removeRollItem, removeRoll, addRollItem
} from './RollDataManager'
import { ColorPickerButton } from '@ohos/common'

@Component
export struct RollDetailEditor {
  @Prop rollIndex: string = ''
  @StorageLink('allRolls') allRolls: Roll[] = []
  @Consume('navPathStack') navPathStack: NavPathStack
  @State rollNameInput: string = ''
  @State editorVersion: number = 0

  aboutToAppear(): void {
    const roll = this.resolveRoll()
    if (roll) {
      this.rollNameInput = roll.rollName
    }
  }

  private resolveRoll(): Roll | undefined {
    return this.allRolls.find((r: Roll) => r.index === this.rollIndex)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 0 }) {

          // ═══════ 转盘未找到 ═══════
          if (!this.resolveRoll()) {
            Column() {
              SymbolGlyph($r('sys.symbol.questionmark_circle'))
                .fontSize(40)
                .fontColor(['#FF999999'])
                .margin({ bottom: 12 })
              Text('转盘不存在')
                .fontSize(15).fontColor('#FF999999')
            }
            .width('100%').justifyContent(FlexAlign.Center).height(200)
          }

          // ═══════ 缩略预览 ═══════
          if (this.resolveRoll()) {
            Row() {
              if (this.editorVersion % 2 === 0) {
                RollWheel({ data: this.resolveRoll()! })
              } else {
                RollWheel({ data: this.resolveRoll()! })
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .constraintSize({ maxWidth: 200 })
            .padding({ top: 12, bottom: 4 })
          }

          // ═══════ 名称编辑卡片 + 删除 ═══════
          if (this.resolveRoll()) {
            Row({ space: 10 }) {
              Text('名称')
                .fontSize(13).fontColor('#FF999999')
              TextInput({ text: this.rollNameInput })
                .fontSize(15).fontWeight(600)
                .layoutWeight(1)
                .backgroundColor($r('app.color.Comp_Bg2'))
                .borderRadius(8).height(40)
                .padding({ left: 12, right: 12 })
                .onChange((v: string) => {
                  this.rollNameInput = v
                  const r = this.resolveRoll()
                  if (r) {
                    r.rollName = v
                    this.persist()
                  }
                })
              SymbolGlyph($r('sys.symbol.trash'))
                .fontSize(20)
                .fontColor(['#FF888888'])
                .padding(8)
                .onClick(() => this.confirmDeleteRoll())
            }
            .width('100%').alignItems(VerticalAlign.Center)
            .padding({ left: 16, right: 12, top: 12, bottom: 12 })
            .backgroundColor($r('app.color.Comp_Bg1'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, bottom: 12 })
          }

          // ═══════ 选项列表 ═══════
          if (this.resolveRoll()) {
            Row() {
              Text(`选项列表（${this.resolveRoll()!.rollItems.length}）`)
                .fontSize(15).fontWeight(600)
                .fontColor('#FF1A1A1A')
            }
            .width('100%')
            .padding({ left: 16, bottom: 8 })

            List({ space: 8 }) {
              ForEach(this.resolveRoll()!.rollItems,
                (item: RollItem, itemIdx: number) => {
                  ListItem() {
                    this.ItemEditor(item, itemIdx)
                  }
                  .swipeAction({
                    end: {
                      builder: () => { this.DeleteItemSwipeButton() },
                      onAction: () => { this.deleteItem(itemIdx) },
                      actionAreaDistance: 72
                    }
                  })
                },
                (item: RollItem) => `${this.resolveRoll()!.index}_${item.id}`
              )

              // 尾部：添加选项
              ListItem() {
                Row() {
                  SymbolGlyph($r('sys.symbol.plus_circle'))
                    .fontSize(24)
                    .fontColor(['#FF007AFF'])
                }
                .width('100%').height(44)
                .justifyContent(FlexAlign.Center)
                .borderRadius(12)
                .backgroundColor($r('app.color.Comp_Bg1'))
                .onClick(() => { this.addItem() })
              }
            }
            .scrollBar(BarState.Off)
            .padding({ left: 16, right: 16 })
            .alignListItem(ListItemAlign.Center)
            .constraintSize({ minHeight: 80 })
            .height((this.resolveRoll()!.rollItems.length + 1) * 110)
          }

        }
        .width('100%')
      }
      .width('100%').height('100%')
      .backgroundColor($r('app.color.Comp_Bg2'))
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.TopStart)
    }
    .title(this.resolveRoll() ? `「${this.resolveRoll()!.rollName}」` : '编辑转盘')
    .onBackPressed(() => { this.navPathStack.pop(); return true })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }

  // ════════════════ Builders ════════════════

  /**
   * 子选项编辑卡片 — 单行：颜色 | 名称 | 占比
   */
  @Builder
  ItemEditor(item: RollItem, itemIdx: number) {
    Column({ space: 0 }) {
      Row({ space: 6 }) {
        // 颜色 — 最左侧，无文字标签
        ColorPickerButton({
          initialColor: item.color,
          onColorChange: (color: string) => {
            item.color = color
            this.persist()
          }
        })

        // 选项名称
        TextInput({ text: item.text })
          .fontSize(14)
          .layoutWeight(1)
          .backgroundColor($r('app.color.Comp_Bg2'))
          .borderRadius(6).height(38)
          .padding({ left: 10, right: 10 })
          .onChange((v: string) => {
            item.text = v
            this.persist()
          })

        // 占比
        Text('占比')
          .fontSize(12).fontColor('#FF999999')
        TextInput({ text: item.weight.toString() })
          .fontSize(13)
          .type(InputType.Number)
          .width(44).height(38)
          .backgroundColor($r('app.color.Comp_Bg2'))
          .borderRadius(6)
          .textAlign(TextAlign.Center)
          .onChange((v: string) => {
            const n = parseInt(v)
            if (!isNaN(n) && n > 0) {
              item.weight = n
              this.persist()
            }
          })
      }
      .width('100%').alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 14, right: 10, top: 10, bottom: 10 })
    .backgroundColor($r('app.color.Comp_Bg1'))
    .borderRadius(12)
  }

  @Builder
  DeleteItemSwipeButton() {
    Row() {
      SymbolGlyph($r('sys.symbol.trash'))
        .fontSize(20)
        .fontColor([Color.White])
      Text('删除').fontSize(14).fontColor(Color.White).margin({ left: 4 })
    }
    .width(72).height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFE74C3C')
    .borderRadius({ topRight: 12, bottomRight: 12 })
  }

  // ════════════════ 操作方法 ════════════════

  private persist(): void {
    const ctx = getContext(this).getApplicationContext()
    saveRollsToPrefs(ctx, this.allRolls)
    this.editorVersion++
  }

  private addItem(): void {
    const roll = this.resolveRoll()
    if (!roll) {
      return
    }
    addRollItem(roll)
    this.persist()
  }

  private deleteItem(itemIdx: number): void {
    const roll = this.resolveRoll()
    if (!roll) {
      return
    }
    if (!removeRollItem(roll, itemIdx)) {
      promptAction.showToast({ message: '至少保留 2 个选项' })
      return
    }
    this.persist()
  }

  private confirmDeleteRoll(): void {
    const r = this.resolveRoll()
    if (!r) {
      return
    }
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除转盘「${r.rollName}」吗？此操作不可撤销。`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '删除',
        fontColor: '#FFE74C3C',
        action: () => { this.deleteRoll() }
      }
    })
  }

  private deleteRoll(): void {
    const roll = this.resolveRoll()
    if (!roll) {
      return
    }
    removeRoll(this.allRolls, roll)
    this.persist()
    promptAction.showToast({ message: '转盘已删除' })
    this.navPathStack.pop()
  }
}
