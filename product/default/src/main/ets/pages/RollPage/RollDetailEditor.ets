import { Roll, RollItem } from '../../static_datas/rolls'
import { promptAction } from '@kit.ArkUI'
import { saveRollsToPrefs } from './RollDataManager'

/** 预设颜色板 */
const COLOR_PRESETS: string[] = [
  '#ffcba50b', '#ffa87cf4', '#ffe81b58', '#ff38ed44', '#fff7942c', '#ff68ead0',
  '#ffff007a', '#ff0cdec5', '#ff05f80b', '#ffecb609', '#ff5f16e1', '#499821',
  '#ffde6e12', '#ff3498db', '#ff9b59b6', '#ff1abc9c', '#ffe74c3c', '#fff39c12'
]

@Component
export struct RollDetailEditor {
  @Prop rollIndex: string = ''
  @StorageLink('allRolls') allRolls: Roll[] = []
  @Consume('navPathStack') navPathStack: NavPathStack
  @State expandColorIdx: number = -1 // 展开颜色选择器的 item 索引

  /** 获取当前编辑的转盘 */
  private getRoll(): Roll | undefined {
    return this.allRolls.find((r: Roll) => r.index === this.rollIndex)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 0 }) {
          // ====== 缩略预览（居中、约束尺寸） ======
          if (this.getRoll()) {
            Row() {
              PieChartMini({ data: this.getRoll()! })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 16, bottom: 16 })
          }

          // ====== 名称编辑卡片 ======
          if (this.getRoll()) {
            Column() {
              Row() {
                Text('转盘名称')
                  .fontSize(13)
                  .fontColor($r('app.color.FontIcon_Fore3'))
                  .width(56)
                TextInput({ text: this.getRoll()!.rollName })
                  .fontSize(15)
                  .fontWeight(600)
                  .layoutWeight(1)
                  .backgroundColor($r('app.color.Comp_Bg2'))
                  .borderRadius(8)
                  .height(40)
                  .padding({ left: 12, right: 12 })
                  .onChange((v: string) => {
                    const roll = this.getRoll()
                    if (roll) {
                      roll.rollName = v
                      this.persist()
                    }
                  })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor($r('app.color.Comp_Bg1'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, bottom: 16 })
          }

          // ====== 选项列表区域 ======
          if (this.getRoll()) {
            // 区域标题
            Row() {
              Text('选项列表')
                .fontSize(15)
                .fontWeight(600)
                .fontColor($r('app.color.FontIcon_Fore1'))
              Blank()
              Button() {
                Row() {
                  Image($r('sys.symbol.plus_circle'))
                    .width(16).height(16)
                    .fillColor($r('app.color.Brand'))
                  Text('添加选项').fontSize(13).fontColor($r('app.color.Brand')).margin({ left: 4 })
                }
              }
              .type(ButtonType.Normal)
              .backgroundColor(0)
              .height(32)
              .onClick(() => {
                this.addItem()
              })
            }
            .width('100%')
            .padding({ left: 16, right: 10, bottom: 8 })

            // 选项卡片列表
            List({ space: 10 }) {
              ForEach(this.getRoll()!.rollItems, (item: RollItem, itemIdx: number) => {
                ListItem() {
                  this.ItemEditor(item, itemIdx)
                }
                .swipeAction({
                  end: {
                    builder: () => {
                      this.DeleteItemSwipeButton()
                    },
                    onAction: () => {
                      this.deleteItem(itemIdx)
                    },
                    actionAreaDistance: 72
                  }
                })
              }, (item: RollItem) => `${this.getRoll()!.index}_${item.id}`)
            }
            .scrollBar(BarState.Off)
            .padding({ left: 16, right: 16 })
            .alignListItem(ListItemAlign.Center)
            .height(this.getRoll() ? Math.max(180, this.getRoll()!.rollItems.length * 130) : 180)

            // ====== 删除转盘（底部弱化入口） ======
            Row() {
              Button() {
                Row() {
                  Image($r('sys.symbol.trash'))
                    .width(16).height(16)
                    .fillColor($r('app.color.FontIcon_Fore3'))
                  Text('删除转盘').fontSize(13).fontColor($r('app.color.FontIcon_Fore3')).margin({ left: 4 })
                }
              }
              .type(ButtonType.Normal)
              .backgroundColor(0)
              .height(36)
              .onClick(() => {
                AlertDialog.show({
                  title: '确认删除',
                  message: `确定要删除转盘「${this.getRoll()!.rollName}」吗？此操作不可撤销。`,
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  primaryButton: {
                    value: '取消',
                    action: () => {
                    }
                  },
                  secondaryButton: {
                    value: '删除',
                    fontColor: '#FFE74C3C',
                    action: () => {
                      this.deleteRoll()
                    }
                  }
                })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 20, bottom: 20 })
          }

          // 转盘未找到
          if (!this.getRoll()) {
            Column() {
              Image($r('sys.symbol.questionmark_circle'))
                .width(40).height(40)
                .fillColor($r('app.color.FontIcon_Fore3'))
                .margin({ bottom: 12 })
              Text('转盘不存在')
                .fontSize(15)
                .fontColor($r('app.color.FontIcon_Fore3'))
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .height(200)
          }
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.Comp_Bg2'))
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.TopStart)
    }
    .title(this.getRoll() ? `「${this.getRoll()!.rollName}」` : '编辑转盘')
    .onBackPressed(() => {
      this.navPathStack.pop()
      return true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }

  @Builder
  ItemEditor(item: RollItem, itemIdx: number) {
    Column({ space: 0 }) {
      // 第一行：文字 + 占比
      Row({ space: 8 }) {
        TextInput({ text: item.text })
          .fontSize(14)
          .layoutWeight(3)
          .backgroundColor($r('app.color.Comp_Bg2'))
          .borderRadius(6)
          .height(38)
          .padding({ left: 10, right: 10 })
          .onChange((v: string) => {
            item.text = v
            this.persist()
          })
        Row({ space: 4 }) {
          Text('占比')
            .fontSize(12)
            .fontColor($r('app.color.FontIcon_Fore3'))
          TextInput({ text: item.weight.toString() })
            .fontSize(13)
            .type(InputType.Number)
            .width(48)
            .backgroundColor($r('app.color.Comp_Bg2'))
            .borderRadius(6)
            .height(38)
            .onChange((v: string) => {
              const n = parseInt(v)
              if (!isNaN(n) && n > 0) {
                item.weight = n
                this.persist()
              }
            })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })

      // 第二行：颜色选择器
      Row({ space: 6 }) {
        // 当前颜色大圆指示
        Row()
          .width(32).height(32)
          .borderRadius(16)
          .backgroundColor(item.color)
          .border({ width: 2, color: $r('app.color.Comp_Bg3') })
          .shadow({ radius: 4, color: item.color, offsetY: 1 })
          .margin({ right: 6 })

        // 颜色色板（网格排列，横滑）
        Scroll() {
          Row({ space: 5 }) {
            ForEach(COLOR_PRESETS, (color: string) => {
              Row() {
                if (item.color.toLowerCase() === color.toLowerCase()) {
                  Text('✓').fontSize(10).fontColor(Color.White).fontWeight(700)
                }
              }
              .width(28).height(28)
              .borderRadius(14)
              .backgroundColor(color)
              .justifyContent(FlexAlign.Center)
              .shadow({ radius: 2, color: color, offsetY: 1 })
              .scale(item.color.toLowerCase() === color.toLowerCase() ? { x: 1.15, y: 1.15 } : { x: 1, y: 1 })
              .animation({ duration: 150, curve: Curve.EaseOut })
              .onClick(() => {
                item.color = color
                this.persist()
              })
            }, (c: string) => c)
          }
          .padding({ left: 2 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 12, right: 10, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.Comp_Bg1'))
    .borderRadius(12)
  }

  @Builder
  DeleteItemSwipeButton() {
    Row() {
      Image($r('sys.symbol.trash'))
        .width(20).height(20)
        .fillColor(Color.White)
      Text('删除').fontSize(14).fontColor(Color.White).margin({ left: 4 })
    }
    .width(72)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFE74C3C')
    .borderRadius({ topRight: 12, bottomRight: 12 })
  }

  // ==================== 操作方法 ====================

  private persist(): void {
    const ctx = getContext(this).getApplicationContext()
    saveRollsToPrefs(ctx, this.allRolls)
  }

  private addItem(): void {
    const roll = this.getRoll()
    if (!roll) {
      return
    }
    const newId = Date.now().toString()
    const fallbackColor = COLOR_PRESETS[Math.floor(Math.random() * COLOR_PRESETS.length)]
    roll.rollItems.push(new RollItem(newId, '新选项', 1, fallbackColor))
    this.persist()
  }

  private deleteItem(itemIdx: number): void {
    const roll = this.getRoll()
    if (!roll) {
      return
    }
    if (roll.rollItems.length <= 2) {
      promptAction.showToast({ message: '至少保留2个选项' })
      return
    }
    roll.rollItems.splice(itemIdx, 1)
    this.persist()
  }

  private deleteRoll(): void {
    const roll = this.getRoll()
    if (!roll) {
      return
    }
    const idx = this.allRolls.indexOf(roll)
    if (idx >= 0) {
      this.allRolls.splice(idx, 1)
      this.persist()
      promptAction.showToast({ message: '转盘已删除' })
      this.navPathStack.pop()
    }
  }
}

// 缩略预览图
@Component
struct PieChartMini {
  @Prop data: Roll
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.context)
        .onReady(() => {
          let ctx = this.context;
          ctx.clearRect(0, 0, ctx.width, ctx.width)
          const radius = ctx.width / 2;
          let list: Array<RollItem> = this.data.rollItems
          let totalWeight = list.reduce<number>((acc: number, single: RollItem) => acc + single.weight, 0);
          let startAngle = -list[0].weight / totalWeight * 180 + 90;

          list.forEach(single => {
            const endAngle: number = startAngle + (single.weight / totalWeight) * 360;
            ctx.beginPath();
            ctx.moveTo(radius, radius);
            ctx.arc(radius, radius, radius, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);
            ctx.closePath()
            ctx.fillStyle = single.color;
            ctx.fill();
            startAngle = endAngle;
          })

          // 中心圆
          ctx.beginPath();
          ctx.moveTo(radius, radius);
          ctx.arc(radius, radius, radius / 10, -45, 275, false);
          ctx.closePath()
          ctx.fillStyle = 0xf1f3f5;
          ctx.fill();
        })
        .width('100%')
        .aspectRatio(1)
    }
    .width('50%')
    .aspectRatio(1)
    .constraintSize({ maxWidth: 200 })
    .border({
      width: 5,
      color: $r("app.color.Comp_Bg3"),
      radius: '50%',
      style: BorderStyle.Solid
    })
  }
}
