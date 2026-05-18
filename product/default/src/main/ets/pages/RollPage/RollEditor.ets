import { Roll, RollItem } from '../../static_datas/rolls'
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

// 转盘管理列表内容（作为半模态内 Navigation 的主内容区）
@Component
struct RollManageContent {
  @StorageLink('allRolls') allRolls: Roll[] = []
  @Consume('navPathStack') navPathStack: NavPathStack

  build() {
    Column() {
      // 列表区域
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
        List({ space: 8 }) {
          ForEach(this.allRolls, (roll: Roll) => {
            ListItem() {
              this.RollCard(roll)
            }
          }, (roll: Roll) => roll.index)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .padding({ left: 16, right: 16, top: 8 })
        .alignListItem(ListItemAlign.Center)
      }

      // 底部"新建转盘"按钮
      Button({ type: ButtonType.Capsule, stateEffect: true }) {
        Row() {
          Image($r('sys.symbol.plus'))
            .width(18).height(18)
            .fillColor(Color.White)
          Text(' 新建转盘').fontSize(15).fontColor(Color.White).fontWeight(600)
        }
      }
      .backgroundColor($r('app.color.Brand'))
      .width('90%')
      .height(44)
      .margin({ bottom: 16, top: 8 })
      .borderRadius(22)
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
      .onClick(() => {
        this.quickCreateAndEnter()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.Comp_Bg2'))
  }

  @Builder
  RollCard(roll: Roll) {
    Row() {
      // 颜色圆点
      Row()
        .width(10).height(10)
        .borderRadius(5)
        .backgroundColor(roll.rollItems.length > 0 ? roll.rollItems[0].color : '#CCCCCC')
        .margin({ right: 10 })
      Text(roll.rollName)
        .fontSize(16)
        .fontWeight(600)
        .fontColor($r('app.color.FontIcon_Fore1'))
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(`${roll.rollItems.length}个选项`)
        .fontSize(12)
        .fontColor($r('app.color.FontIcon_Fore3'))
        .margin({ right: 6 })
      Image($r('sys.symbol.chevron_right'))
        .width(18).height(18)
        .fillColor($r('app.color.FontIcon_Fore3'))
    }
    .width('100%')
    .padding({ left: 16, right: 12, top: 16, bottom: 16 })
    .borderRadius(12)
    .backgroundColor($r('app.color.Comp_Bg1'))
    .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.97 })
    .onClick(() => {
      this.navPathStack.pushPathByName('RollDetailEditor', new RollDetailParams(roll.index))
    })
  }

  // ==================== 操作方法 ====================

  private persist(): void {
    const ctx = getContext(this).getApplicationContext()
    saveRollsToPrefs(ctx, this.allRolls)
  }

  private quickCreateAndEnter(): void {
    const newIndex = `custom_${Date.now()}`
    // 随机子选项数量 2~5
    const subCount = Math.floor(Math.random() * 4) + 2
    const items: RollItem[] = []
    for (let i = 0; i < subCount; i++) {
      const color = COLOR_PRESETS[Math.floor(Math.random() * COLOR_PRESETS.length)]
      const weight = Math.floor(Math.random() * 5) + 1 // 1~5
      items.push(new RollItem(`${newIndex}_${i}`, `选项${i + 1}`, weight, color))
    }
    const roll = new Roll(newIndex, '新建转盘', items)
    this.allRolls.push(roll)
    this.persist()
    this.navPathStack.pushPathByName('RollDetailEditor', new RollDetailParams(newIndex))
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
