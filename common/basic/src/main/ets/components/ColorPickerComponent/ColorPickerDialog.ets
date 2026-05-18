/**
 * 专业颜色选择器 — Popup 气泡 + 按钮一体化组件
 *
 * 包含:
 *   ColorPickerView       — @Component 取色面板（色相滑块 + 色盘）
 *   ColorPickerButton     — 小巧方形按钮，点击弹出 Popup 气泡取色
 *
 * 多设备适配:
 *   view 自身 constraintSize 限制 400×480，Scroll layoutWeight 撑满，
 *   色盘格 aspectRatio 自适应——窄屏格子小全显，宽屏格子大可滚。
 */

// ===================================================================
//  常量 & 工具函数
// ===================================================================

const SAT_LEVELS: number[] = [20, 40, 60, 80, 100]
const LIGHT_LEVELS: number[] = [85, 65, 45, 25]

interface HslColor { h: number; s: number; l: number }

// ---- HSL ↔ Hex 转换 ----

function hexToHsl(hex: string): HslColor {
  let r = 0, g = 0, b = 0
  const clean = hex.replace('#', '')
  if (clean.length === 3) {
    r = parseInt(clean[0] + clean[0], 16) / 255
    g = parseInt(clean[1] + clean[1], 16) / 255
    b = parseInt(clean[2] + clean[2], 16) / 255
  } else if (clean.length >= 6) {
    const offset = clean.length === 8 ? 2 : 0
    r = parseInt(clean.substring(offset, offset + 2), 16) / 255
    g = parseInt(clean.substring(offset + 2, offset + 4), 16) / 255
    b = parseInt(clean.substring(offset + 4, offset + 6), 16) / 255
  }
  const max = Math.max(r, g, b), min = Math.min(r, g, b), delta = max - min
  let h = 0, s = 0
  const l = (max + min) / 2 * 100
  if (delta > 0) {
    s = (l > 50 ? delta / (2 - max - min) : delta / (max + min)) * 100
    if (max === r) h = ((g - b) / delta + (g < b ? 6 : 0)) * 60
    else if (max === g) h = ((b - r) / delta + 2) * 60
    else h = ((r - g) / delta + 4) * 60
  }
  return { h: Math.round(h), s: Math.round(s), l: Math.round(l) }
}

function hslToHex(h: number, s: number, l: number): string {
  s /= 100; l /= 100
  const a = s * Math.min(l, 1 - l)
  const f = (n: number): number => {
    const k = (n + h / 30) % 12
    return Math.round((l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1)) * 255)
  }
  const toHex = (v: number): string => v.toString(16).padStart(2, '0')
  return `#ff${toHex(f(0))}${toHex(f(8))}${toHex(f(4))}`
}

// ===================================================================
//  ColorPickerView — 纯 @Component 取色面板
// ===================================================================

/**
 * 取色面板（色相滑块 + 饱和度×明度色盘 + 当前预览）。
 * 不含弹窗逻辑，可嵌入任意容器。
 *
 * 回调: onConfirm(color) — 用户确定; onClose() — 取消/外部关闭
 */
@Component
export struct ColorPickerView {
  @Prop initialColor: string = '#74619134'
  onConfirm?: (color: string) => void
  onClose?: () => void

  @State private hue: number = 0
  @State private sat: number = 100
  @State private light: number = 50
  @State private previewColor: string = '#ffcba50b'
  @State private barWidth: number = 0

  aboutToAppear(): void {
    this.resetToColor(this.initialColor)
  }

  // ---- 内部方法 ----

  private resetToColor(hex: string): void {
    const hsl = hexToHsl(hex)
    this.hue = hsl.h
    this.sat = hsl.s
    this.light = hsl.l
    this.previewColor = hex
  }

  private syncPreview(): void {
    this.previewColor = hslToHex(this.hue, this.sat, this.light)
  }

  private cellColor(sat: number, light: number): string {
    return hslToHex(this.hue, sat, light)
  }

  private isCellSelected(sat: number, light: number): boolean {
    return this.sat === sat && this.light === light
  }

  // ---- UI ----

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row() {
        Text('选取颜色')
          .fontSize(16).fontWeight(600)
          .fontColor($r('app.color.FontIcon_Fore1'))
      }
      .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 10 })

      Divider()
        .color($r('app.color.Comp_Bg3'))
        .width('100%')

      // 取色区（可滚动）
      Scroll() {
        Column({ space: 14 }) {
          this.HueBar()
          this.SatLightGrid()
          this.PreviewRow()
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      // 底部按钮
      Divider().color($r('app.color.Comp_Bg3'))
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(14)
          .type(ButtonType.Normal)
          .backgroundColor($r('app.color.Comp_Bg2'))
          .fontColor($r('app.color.FontIcon_Fore1'))
          .layoutWeight(1).height(42).borderRadius(10)
          .onClick(() => this.onClose?.())

        Button('确定')
          .fontSize(14)
          .type(ButtonType.Normal)
          .backgroundColor($r('app.color.Brand'))
          .fontColor(Color.White)
          .layoutWeight(1).height(42).borderRadius(10)
          .onClick(() => this.onConfirm?.(this.previewColor))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 14 })
    }
    .width('100%')
    // ★ 极限尺寸：宽度≤400，高度≤480 → 宽高比≈1:1.2，适配多设备
    .constraintSize({ maxWidth: 400, maxHeight: 480 })
    .borderRadius(16)
    .backgroundColor($r('app.color.Comp_Bg1'))
  }

  // ==================== 色相条 ====================

  @Builder
  HueBar() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text('色相').fontSize(12).fontColor($r('app.color.FontIcon_Fore3')).width(26)
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%').height(24).borderRadius(12)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [
                ['#FF0000', 0.0], ['#FFFF00', 0.17],
                ['#00FF00', 0.33], ['#00FFFF', 0.50],
                ['#0000FF', 0.67], ['#FF00FF', 0.83],
                ['#FF0000', 1.0]
              ]
            })
            .onAreaChange((_: Area, newArea: Area) => {
              this.barWidth = newArea.width as number
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down || event.type === TouchType.Move) {
                const ratio = Math.max(0, Math.min(1,
                  event.touches[0].x / this.barWidth))
                this.hue = Math.round(ratio * 360)
                this.syncPreview()
              }
            })
          Circle()
            .width(18).height(18)
            .fill(Color.White)
            .strokeWidth(2.5)
            .stroke(this.previewColor)
            .shadow({ radius: 4, color: '#33000000' })
            .offset({
              x: this.barWidth > 0 ? (this.hue / 360) * this.barWidth - 9 : 0,
              y: 0
            })
            .hitTestBehavior(HitTestMode.None)
        }
        .layoutWeight(1).height(28)
      }
      .width('100%').alignItems(VerticalAlign.Center)
    }
  }

  // ==================== 饱和度 × 明度色盘 ====================

  @Builder
  SatLightGrid() {
    Column({ space: 6 }) {
      Row({ space: 4 }) {
        Text('饱和度 →').fontSize(10).fontColor($r('app.color.FontIcon_Fore3')).width(26)
        Blank()
        Text('← 明度').fontSize(10).fontColor($r('app.color.FontIcon_Fore3'))
      }
      Column({ space: 4 }) {
        ForEach(LIGHT_LEVELS, (light: number) => {
          Row({ space: 4 }) {
            ForEach(SAT_LEVELS, (sat: number) => {
              this.Cell(sat, light)
            }, (s: number) => `${s}_${light}`)
          }
        }, (l: number) => `${l}`)
      }
    }
  }

  @Builder
  Cell(sat: number, light: number) {
    Row() {
      if (this.isCellSelected(sat, light)) {
        Text('✓')
          .fontSize(11).fontWeight(700)
          .fontColor(light > 50 ? '#333' : Color.White)
      }
    }
    .layoutWeight(1).aspectRatio(1).borderRadius(6)
    .backgroundColor(this.cellColor(sat, light))
    .justifyContent(FlexAlign.Center)
    .scale(this.isCellSelected(sat, light) ? { x: 1.12, y: 1.12 } : { x: 1, y: 1 })
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onClick(() => { this.sat = sat; this.light = light; this.syncPreview() })
  }

  // ==================== 预览 + 十六进制 ====================

  @Builder
  PreviewRow() {
    Row({ space: 12 }) {
      Circle()
        .width(40).height(40)
        .fill(this.previewColor)
        .strokeWidth(2)
        .stroke($r('app.color.Comp_Bg3'))
        .shadow({ radius: 6, color: this.previewColor, offsetY: 2 })
      Column({ space: 2 }) {
        Text('当前颜色').fontSize(10).fontColor($r('app.color.FontIcon_Fore3'))
        Text(this.previewColor.toUpperCase())
          .fontSize(13).fontWeight(500)
          .fontColor($r('app.color.FontIcon_Fore1'))
          .fontFamily('monospace')
      }.alignItems(HorizontalAlign.Start)
      Blank()
      Row() {
        SymbolGlyph($r('sys.symbol.arrow_counterclockwise'))
          .fontSize(16)
          .fontColor([$r('app.color.FontIcon_Fore3')])
      }
      .width(32).height(32).borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.Comp_Bg2'))
      .onClick(() => this.resetToColor(this.initialColor))
    }
    .width('100%')
    .padding({ top: 4, bottom: 4, left: 8, right: 8 })
    .backgroundColor($r('app.color.Comp_Bg2'))
    .borderRadius(12)
  }
}

// ===================================================================
//  ColorPickerButton — 小巧正方形颜色按钮 + bindPopup 气泡
// ===================================================================

/**
 * 使用方式：
 *   ColorPickerButton({
 *     initialColor: item.color,
 *     onColorChange: (newColor: string) => { item.color = newColor; persist() }
 *   })
 *
 * 点击按钮 → 弹出 Popup 气泡取色面板 → 确定后：
 *   1. 按钮颜色即时刷新（@State 自管）
 *   2. 回调通知父组件落盘
 */
@Component
export struct ColorPickerButton {
  @Prop initialColor: string = '#ffcba50b'
  onColorChange?: (color: string) => void

  @State private displayColor: string = '#ffcba50b'
  @State private showPopup: boolean = false

  aboutToAppear(): void {
    this.displayColor = this.initialColor
  }

  /** Popup 气泡内容 */
  @Builder
  popupBuilder() {
    ColorPickerView({
      initialColor: this.displayColor,
      onConfirm: (color: string) => {
        this.displayColor = color
        this.onColorChange?.(color)
        this.showPopup = false
      },
      onClose: () => {
        this.showPopup = false
      }
    })
  }

  build() {
    Row() {
      Column() {
      }
      .width(28).height(28).borderRadius(6)
      .backgroundColor(this.displayColor)
      .border({ width: 1.5, color: $r('app.color.Comp_Bg3') })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(10)
        .fontColor([$r('app.color.FontIcon_Fore3')])
        .margin({ left: 2 })
    }
    .height(32)
    .padding({ left: 6, right: 8 })
    .backgroundColor($r('app.color.Comp_Bg2'))
    .borderRadius(8)
    .alignItems(VerticalAlign.Center)
    .bindPopup(this.showPopup, {
      builder: this.popupBuilder,
      placement: Placement.Bottom,
      popupColor: Color.Transparent,
      backgroundBlurStyle: BlurStyle.NONE,
      enableArrow: true,
      autoCancel: true,
      radius: 16,
      mask: { color: '#33000000' },
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.showPopup = false
        }
      }
    })
    .onClick(() => {
      this.showPopup = !this.showPopup
    })
  }
}
