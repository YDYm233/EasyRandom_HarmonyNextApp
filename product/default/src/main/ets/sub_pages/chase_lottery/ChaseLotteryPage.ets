import { BreakpointState, BreakpointSystem } from '@ohos/system-utils';
import { VibratorManager } from '@ohos/system-utils';
import router from '@ohos.router';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

interface CellPosition {
  row: number
  col: number
}

interface GridDimensions {
  rows: number
  cols: number
}

interface CenterRect {
  x: number
  y: number
  w: number
  h: number
}

@Entry
@Component
struct ChaseLotteryPage {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  // 格子数量
  @State cellCount: number = 8
  // 格子内容
  @State cells: string[] = ['🏆一等奖', '🎁二等奖', '🧧三等奖', '🎫四等奖',
    '🎰五等奖', '🎪六等奖', '🎀七等奖', '🍀八等奖']
  @State highlightIndex: number = -1
  @State isSpinning: boolean = false
  @State isDecelerating: boolean = false
  @State resultText: string = ''

  private timer: number = 0
  private speed: number = 150

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
    this.clearTimer()
  }

  clearTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = 0
    }
  }

  // ==================== Square Layout ====================

  private getGridDimensions(): GridDimensions {
    switch (this.cellCount) {
      case 6:
        return { rows: 3, cols: 3 } as GridDimensions
      case 8:
        return { rows: 3, cols: 3 } as GridDimensions
      case 10:
        return { rows: 3, cols: 4 } as GridDimensions
      case 12:
        return { rows: 4, cols: 4 } as GridDimensions
      default:
        return { rows: 3, cols: 3 } as GridDimensions
    }
  }

  private getPerimeterPositions(): CellPosition[] {
    const dims = this.getGridDimensions()
    const positions: CellPosition[] = []
    // Top: left → right
    for (let c = 0; c < dims.cols; c++) {
      positions.push({ row: 0, col: c } as CellPosition)
    }
    // Right: top+1 → bottom
    for (let r = 1; r < dims.rows; r++) {
      positions.push({ row: r, col: dims.cols - 1 } as CellPosition)
    }
    // Bottom: right-1 → left
    for (let c = dims.cols - 2; c >= 0; c--) {
      positions.push({ row: dims.rows - 1, col: c } as CellPosition)
    }
    // Left: bottom-1 → top+1
    for (let r = dims.rows - 2; r >= 1; r--) {
      positions.push({ row: r, col: 0 } as CellPosition)
    }
    return positions
  }

  private getCellPosition(index: number): CellPosition {
    const positions = this.getPerimeterPositions()
    return positions[index % positions.length]
  }

  private getCellSize(): number {
    if (this.currentBreakpoint.value === 'sm') return 72
    if (this.currentBreakpoint.value === 'md') return 84
    return 96
  }

  private getCellGap(): number {
    return 6
  }

  private getGridWidth(): number {
    const dims = this.getGridDimensions()
    return dims.cols * this.getCellSize() + (dims.cols - 1) * this.getCellGap()
  }

  private getGridHeight(): number {
    const dims = this.getGridDimensions()
    return dims.rows * this.getCellSize() + (dims.rows - 1) * this.getCellGap()
  }

  private getCellX(col: number): number {
    return col * (this.getCellSize() + this.getCellGap())
  }

  private getCellY(row: number): number {
    return row * (this.getCellSize() + this.getCellGap())
  }

  private getCenterRect(): CenterRect {
    const dims = this.getGridDimensions()
    const cellSize = this.getCellSize()
    const gap = this.getCellGap()
    const interiorCols = dims.cols - 2
    const interiorRows = dims.rows - 2
    return {
      x: cellSize + gap,
      y: cellSize + gap,
      w: interiorCols * cellSize + (interiorCols - 1) * gap,
      h: interiorRows * cellSize + (interiorRows - 1) * gap
    } as CenterRect
  }

  startSpin(): void {
    this.isSpinning = true
    this.speed = 150
    this.isDecelerating = false
    this.resultText = ''
    this.clearTimer()
    this.tick()
  }

  tick(): void {
    this.highlightIndex = (this.highlightIndex + 1) % this.cellCount
    VibratorManager.vibrateShort() // 短振动反馈
    this.timer = setTimeout(() => this.tick(), this.speed) as number
  }

  stopSpin(): void {
    this.isDecelerating = true
    this.decelerate()
  }

  decelerate(): void {
    if (this.speed >= 400) {
      this.clearTimer()
      this.isSpinning = false
      this.showResult()
      return
    }
    this.speed += 30
    this.highlightIndex = (this.highlightIndex + 1) % this.cellCount
    this.timer = setTimeout(() => this.decelerate(), this.speed) as number
  }

  showResult(): void {
    this.resultText = `${this.cells[this.highlightIndex]}`
    VibratorManager.vibrateResult() // 结果振动反馈
  }

  changeCount(n: number): void {
    if (this.isSpinning) return
    this.cellCount = n
    this.updateCellsByCount()
    this.highlightIndex = -1
    this.resultText = ''
  }

  updateCellsByCount(): void {
    // 根据格子数切换预设数据
    if (this.cellCount === 6) {
      this.cells = ['🏆一等奖', '🎁二等奖', '🧧三等奖', '🎫四等奖', '🎰五等奖', '🎪六等奖']
    } else if (this.cellCount === 8) {
      this.cells = ['🏆一等奖', '🎁二等奖', '🧧三等奖', '🎫四等奖',
        '🎰五等奖', '🎪六等奖', '🎀七等奖', '🍀八等奖']
    } else if (this.cellCount === 10) {
      this.cells = ['大吉', '上上签', '好运', '平安', '发财', '健康', '桃花', '事业', '学业', '贵人']
    } else if (this.cellCount === 12) {
      this.cells = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪']
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => { router.back({ url: 'pages/IndexPage/Index' }) })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_chase_lottery")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.pushUrl({ url: 'pages/SettingPage/SettingPage', params: new Params('no') })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%').height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%').backgroundColor($r("app.color.Comp_Bg1")).zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      Scroll() {
        Column() {
          // 方形跑马灯网格
          Stack() {
            // 格子：沿方形外圈顺时针排列
            ForEach(new Array<number>(this.cellCount).fill(0).map((_, i: number) => i), (i: number) => {
              Column() {
                Text(this.cells[i])
                  .fontSize(this.highlightIndex === i ? 16 : 13)
                  .fontColor(Color.White)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width(this.getCellSize())
              .height(this.getCellSize())
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.highlightIndex === i ? $r("app.color.SubBrand") : $r("app.color.Comp_Bg1"))
              .borderRadius(8)
              .scale({ x: this.highlightIndex === i ? 1.08 : 1, y: this.highlightIndex === i ? 1.08 : 1 })
              .animation({ duration: 80 })
              .position({ x: this.getCellX(this.getCellPosition(i).col), y: this.getCellY(this.getCellPosition(i).row) })
            }, (i: number) => `cell_${i}`)

            // 中心按钮
            Column() {
              if (this.isDecelerating) {
                // 减速中：Progress 加载状态，不可点击
                LoadingProgress()
                  .width(32)
                  .height(32)
              } else if (this.resultText) {
                // 结果展示，点击重新开始
                Text(this.resultText)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r("app.color.Brand"))
                  .textAlign(TextAlign.Center)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              } else if (this.isSpinning) {
                // 旋转中：可点击停止
                Text('停止')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
              } else {
                // 初始状态：开始
                Text('开始')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
              }
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(
              this.isDecelerating ? $r("app.color.FontIcon_Fore3") :
              this.isSpinning ? $r("app.color.error") :
              $r("app.color.Brand")
            )
            .borderRadius(12)
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
            .opacity(this.isDecelerating ? 0.7 : 1)
            .position({
              x: this.getCenterRect().x,
              y: this.getCenterRect().y
            })
            .width(this.getCenterRect().w)
            .height(this.getCenterRect().h)
            .onClick(() => {
              if (this.isDecelerating) return
              if (this.isSpinning) {
                this.stopSpin()
              } else {
                this.startSpin()
              }
            })
          }
          .width(this.getGridWidth())
          .height(this.getGridHeight())
          .margin({ top: 24 })

          // 格子数量切换
          Row() {
            ForEach([6, 8, 10, 12], (n: number) => {
              Button(`${n}`)
                .type(this.cellCount === n ? ButtonType.Capsule : ButtonType.Normal)
                .fontSize(this.currentBreakpoint.value === 'sm' ? 12 : 14)
                .fontColor(this.cellCount === n ? Color.White : $r("app.color.FontIcon_Fore1"))
                .backgroundColor(this.cellCount === n ? $r("app.color.Brand") : $r("app.color.Comp_Bg2"))
                .border({
                  width: 1,
                  color: this.cellCount === n ? $r("app.color.Brand") : $r("app.color.border_primary"),
                  radius: 20
                })
                .width(this.currentBreakpoint.value === 'sm' ? 40 : 48)
                .height(this.currentBreakpoint.value === 'sm' ? 40 : 48)
                .onClick(() => this.changeCount(n))
            }, (n: number) => `count_${n}`)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 24, bottom: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: $r("app.float.header_height") })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
  }
}

export default ChaseLotteryPage