import { RollWheel } from './RollWheel'
import { promptAction } from '@kit.ArkUI'
import {
  Roll, RollItem,
  writeRollsToPrefs, saveRollsToPrefs,
  removeRollItem, removeRoll, addRollItem
} from './RollDataManager'
import { ColorPickerButton } from '@ohos/vital-ui'

@Component
export struct RollDetailEditor {
  @Prop rollIndex: string = ''
  @StorageLink('allRolls') allRolls: Roll[] = []
  @Consume('navPathStack') navPathStack: NavPathStack
  @State rollNameInput: string = ''
  @State originalRollName: string = '' // 保存原始转盘名称
  @State editorVersion: number = 0
  // 保存每个 item 的原始值
  private originalItemTexts: Map<string, string> = new Map()
  private originalItemWeights: Map<string, number> = new Map()
  // 保存每个 item 的输入值（用于 TextInput 双向绑定）
  @State itemTextInputValues: Map<string, string> = new Map()
  @State itemWeightInputValues: Map<string, string> = new Map()

  aboutToAppear(): void {
    const roll = this.resolveRoll()
    if (roll) {
      this.rollNameInput = roll.rollName
      this.originalRollName = roll.rollName // 保存原始名称
      // 初始化所有 item 的原始值和输入值
      roll.rollItems.forEach((item: RollItem) => {
        this.originalItemTexts.set(item.id, item.text)
        this.originalItemWeights.set(item.id, item.weight)
        this.itemTextInputValues.set(item.id, item.text)
        this.itemWeightInputValues.set(item.id, item.weight.toString())
      })
    }
  }

  private resolveRoll(): Roll | undefined {
    return this.allRolls.find((roll: Roll) => roll.index === this.rollIndex)
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
              ForEach([this.editorVersion],
                (_version: number) => {
                  RollWheel({ data: this.resolveRoll()! })
                },
                (_version: number) => `${_version}`
              )
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
                .onChange((newValue: string) => {
                  // 实时更新输入框显示
                  this.rollNameInput = newValue
                })
                .onSubmit(() => {
                  this.validateRollName()
                })
                .onBlur(() => {
                  this.validateRollName()
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
                (item: RollItem, itemIndex: number) => {
                  ListItem() {
                    this.ItemEditor(item, itemIndex)
                  }
                  .swipeAction({
                    end: {
                      builder: () => { this.DeleteItemSwipeButton(itemIndex) },
                      onAction: () => { this.deleteItem(itemIndex) },
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
  ItemEditor(item: RollItem, itemIndex: number) {
    Column({ space: 0 }) {
      Row({ space: 6 }) {
        // 颜色 — 最左侧，无文字标签
        ColorPickerButton({
          initialColor: item.color,
          onColorChange: (color: string) => {
            item.color = color
            this.notifyEdit()
          }
        })

        // 选项名称
        TextInput({ text: this.itemTextInputValues.get(item.id) ?? '' })
          .fontSize(14)
          .layoutWeight(1)
          .backgroundColor($r('app.color.Comp_Bg2'))
          .borderRadius(6).height(38)
          .padding({ left: 10, right: 10 })
          .onChange((v: string) => {
            // 创建新 Map 触发 @State 更新
            const newMap = new Map(this.itemTextInputValues)
            newMap.set(item.id, v)
            this.itemTextInputValues = newMap
          })
          .onSubmit(() => {
            this.validateItemText(item)
          })
          .onBlur(() => {
            this.validateItemText(item)
          })

        // 占比
        Text('占比')
          .fontSize(12).fontColor('#FF999999')
        TextInput({ text: this.itemWeightInputValues.get(item.id) ?? '' })
          .fontSize(13)
          .type(InputType.Number)
          .width(44).height(38)
          .backgroundColor($r('app.color.Comp_Bg2'))
          .borderRadius(6)
          .textAlign(TextAlign.Center)
          .onChange((value: string) => {
            // 创建新 Map 触发 @State 更新
            const newMap = new Map(this.itemWeightInputValues)
            newMap.set(item.id, value)
            this.itemWeightInputValues = newMap
          })
          .onSubmit(() => {
            this.validateItemWeight(item)
          })
          .onBlur(() => {
            this.validateItemWeight(item)
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
  DeleteItemSwipeButton(itemIndex: number) {
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
    .onClick(() => { this.deleteItem(itemIndex) })
  }

  // ════════════════ 持久化策略 ════════════════

  /**
   * 属性编辑通知：先改内存对象，再静默写 Preferences，最后仅刷新预览轮盘。
   * 不触发 AppStorage 深拷贝，TextInput 不受干扰。
   */
  private notifyEdit(): void {
    const ctx = getContext(this).getApplicationContext()
    writeRollsToPrefs(ctx, this.allRolls)
    this.editorVersion++
  }

  /**
   * 结构性变更：增删选项/转盘后，需要完整 AppStorage 深拷贝以驱动列表刷新。
   */
  private notifyStructureChange(): void {
    const ctx = getContext(this).getApplicationContext()
    saveRollsToPrefs(ctx, this.allRolls)
    this.editorVersion++
  }

  // ════════════════ 操作方法 ════════════════

  /** 验证转盘名称：空数据恢复原值 */
  private validateRollName(): void {
    if (this.rollNameInput.trim() === '') {
      this.rollNameInput = this.originalRollName
      promptAction.showToast({ message: '名称不能为空，已恢复原名称' })
      return
    }
    // 保存新名称
    const roll = this.resolveRoll()
    if (roll) {
      roll.rollName = this.rollNameInput
      this.originalRollName = this.rollNameInput // 更新原始值
      this.notifyEdit()
    }
  }

  /** 验证选项名称：空数据恢复原值 */
  private validateItemText(item: RollItem): void {
    const inputText = this.itemTextInputValues.get(item.id) || ''
    if (inputText.trim() === '') {
      const originalText = this.originalItemTexts.get(item.id) || '选项'
      item.text = originalText
      // 创建新 Map 触发 @State 更新
      const newMap = new Map(this.itemTextInputValues)
      newMap.set(item.id, originalText)
      this.itemTextInputValues = newMap
      this.notifyEdit()
      promptAction.showToast({ message: '名称不能为空，已恢复原名称' })
      return
    }
    // 保存新名称
    item.text = inputText
    this.originalItemTexts.set(item.id, inputText)
    this.notifyEdit()
  }

  /** 验证占比：无效值恢复原值 */
  private validateItemWeight(item: RollItem): void {
    const inputWeight = this.itemWeightInputValues.get(item.id) || ''
    const parsedWeight = parseInt(inputWeight)
    if (inputWeight.trim() === '' || isNaN(parsedWeight) || parsedWeight <= 0) {
      const originalWeight = this.originalItemWeights.get(item.id) || 1
      item.weight = originalWeight
      // 创建新 Map 触发 @State 更新
      const newMap = new Map(this.itemWeightInputValues)
      newMap.set(item.id, originalWeight.toString())
      this.itemWeightInputValues = newMap
      this.notifyEdit()
      promptAction.showToast({ message: '占比必须为正整数，已恢复原值' })
      return
    }
    // 保存新占比
    item.weight = parsedWeight
    this.originalItemWeights.set(item.id, parsedWeight)
    this.notifyEdit()
  }

  private addItem(): void {
    const roll = this.resolveRoll()
    if (!roll) {
      return
    }
    const newItem = addRollItem(roll)
    // 初始化新 item 的原始值和输入值
    this.originalItemTexts.set(newItem.id, newItem.text)
    this.originalItemWeights.set(newItem.id, newItem.weight)
    // 创建新 Map 触发 @State 更新
    const newTextMap = new Map(this.itemTextInputValues)
    newTextMap.set(newItem.id, newItem.text)
    this.itemTextInputValues = newTextMap
    const newWeightMap = new Map(this.itemWeightInputValues)
    newWeightMap.set(newItem.id, newItem.weight.toString())
    this.itemWeightInputValues = newWeightMap
    this.notifyStructureChange()
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
    this.notifyStructureChange()
  }

  private confirmDeleteRoll(): void {
    const roll = this.resolveRoll()
    if (!roll) {
      return
    }
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除转盘「${roll.rollName}」吗？此操作不可撤销。`,
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
    this.notifyStructureChange()
    promptAction.showToast({ message: '转盘已删除' })
    this.navPathStack.pop()
  }
}
