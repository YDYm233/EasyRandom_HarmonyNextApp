/**
 * 专业颜色选择器 — Popup 气泡 + 按钮一体化组件
 *
 * 包含:
 *   ColorPickerView       — @Component 取色面板（色相滑块 + 透明度滑块 + 2D 色块）
 *   ColorPickerButton     — 小巧方形按钮，点击弹出 Popup 气泡取色
 *
 * 多设备适配:
 *   view 自身 constraintSize 限制 440×380（宽扁比例），2D 色块 layoutWeight 弹性撑满，
 *   各子组件响应式自适应，无需滚动。mask 与 shadow 均使用 $r 资源适配暗色模式。
 */

// ===================================================================
//  常量 & 工具函数
// ===================================================================

interface HslColor { h: number; s: number; l: number; a: number }

// ---- HSL ↔ Hex 转换（含 Alpha）----

function hexToHsl(hex: string): HslColor {
  let r = 0, g = 0, b = 0, a = 1
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
    if (clean.length === 8) {
      a = parseInt(clean.substring(0, 2), 16) / 255
    }
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
  return { h: Math.round(h), s: Math.round(s), l: Math.round(l), a: Math.round(a * 100) / 100 }
}

function hslToHex(h: number, s: number, l: number, a: number = 1): string {
  s /= 100; l /= 100
  const k1 = s * Math.min(l, 1 - l)
  const f = (n: number): number => {
    const k = (n + h / 30) % 12
    return Math.round((l - k1 * Math.max(Math.min(k - 3, 9 - k, 1), -1)) * 255)
  }
  const toHex = (v: number): string => v.toString(16).padStart(2, '0')
  const alphaHex = Math.round(a * 255).toString(16).padStart(2, '0')
  return `#${alphaHex}${toHex(f(0))}${toHex(f(8))}${toHex(f(4))}`
}

// ===================================================================
//  ColorPickerView — 纯 @Component 取色面板
// ===================================================================

/**
 * 取色面板（色相滑块 + 透明度滑块 + 饱和度×明度 2D 色块 + 当前预览）。
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
  @State private alpha: number = 1
  @State private previewColor: string = '#ff0ba5cb'
  @State private hueBarWidth: number = 0
  @State private alphaBarW: number = 0
  @State private blockWidth: number = 0
  @State private blockHeight: number = 0

  aboutToAppear(): void {
    this.resetToColor(this.initialColor)
  }

  // ---- 内部方法 ----

  private resetToColor(hex: string): void {
    const hsl = hexToHsl(hex)
    this.hue = hsl.h
    this.sat = hsl.s
    this.light = hsl.l
    this.alpha = hsl.a
    this.previewColor = hex
  }

  private syncPreview(): void {
    this.previewColor = hslToHex(this.hue, this.sat, this.light, this.alpha)
  }

  // ---- UI ----

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row() {
        Text('选取颜色')
          .fontSize(16).fontWeight(600)
          .fontColor($r('app.color.FontIcon_Fore1'))
        Blank()
        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(14)
            .fontColor([$r('app.color.FontIcon_Fore2')])
        }
        .width(28).height(28).borderRadius(14)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.Comp_Bg2'))
        .onClick(() => this.onClose?.())
      }
      .width('100%').padding({ left: 16, right: 16, top: 10, bottom: 6 })

      // 取色面板主体
      Column({ space: 6 }) {
        this.HueBar()
        this.AlphaBar()
        this.ColorBlock()
        this.PreviewRow()
        // 底部按钮
        Row({ space: 12 }) {
          Button('取消')
            .fontSize(14)
            .type(ButtonType.Normal)
            .backgroundColor($r('app.color.Comp_Bg2'))
            .fontColor($r('app.color.FontIcon_Fore1'))
            .layoutWeight(1).height(38).borderRadius(10)
            .onClick(() => this.onClose?.())

          Button('确定')
            .fontSize(14)
            .type(ButtonType.Normal)
            .backgroundColor($r('app.color.Brand'))
            .fontColor(Color.White)
            .layoutWeight(1).height(38).borderRadius(10)
            .onClick(() => this.onConfirm?.(this.previewColor))
        }
        .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8, bottom: 10 })
    }
    .width('100%')
    .constraintSize({ maxWidth: 440, maxHeight: 380 })
    .borderRadius(16)
    .backgroundColor($r('app.color.Comp_Bg1'))
    .shadow({ radius: 24, color: $r('app.color.shadow'), offsetY: 8 })
  }

  // ==================== 色相条 ====================

  @Builder
  HueBar() {
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Text('色相').fontSize(12).fontColor($r('app.color.FontIcon_Fore3')).width(36)
        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%').height(22).borderRadius(11)
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
              this.hueBarWidth = newArea.width as number
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down || event.type === TouchType.Move) {
                const ratio = Math.max(0, Math.min(1,
                  event.touches[0].x / this.hueBarWidth))
                this.hue = Math.round(ratio * 360)
                this.syncPreview()
              }
            })
          Circle()
            .width(18).height(18)
            .fill(Color.White)
            .strokeWidth(2.5)
            .stroke(this.previewColor)
            .shadow({ radius: 4, color: $r('app.color.shadow') })
            .offset({
              x: this.hueBarWidth > 0 ? (this.hue / 360) * this.hueBarWidth - 9 : 0,
              y: 0
            })
            .hitTestBehavior(HitTestMode.None)
        }
        .layoutWeight(1).height(24)
      }
      .width('100%').alignItems(VerticalAlign.Center)
    }
  }

  // ==================== 透明度条 ====================

  @Builder
  AlphaBar() {
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Text('透明度').fontSize(12).fontColor($r('app.color.FontIcon_Fore3')).width(36)
        Stack({ alignContent: Alignment.Start }) {
          // 透明度提示底纹（浅灰→深灰→浅灰，模拟棋盘格暗示透明区域）
          Row()
            .width('100%').height(22).borderRadius(11)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#D5D5D5', 0], ['#AAAAAA', 0.5], ['#D5D5D5', 1]]
            })
          // Alpha 颜色渐变（透明 → 完全不透明）
          Row()
            .width('100%').height(22).borderRadius(11)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [
                [`#00${this.previewColor.substring(3)}`, 0],
                [`#ff${this.previewColor.substring(3)}`, 1]
              ]
            })
            .onAreaChange((_: Area, newArea: Area) => {
              this.alphaBarW = newArea.width as number
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down || event.type === TouchType.Move) {
                const ratio = Math.max(0, Math.min(1,
                  event.touches[0].x / this.alphaBarW))
                this.alpha = Math.round(ratio * 100) / 100
                this.syncPreview()
              }
            })
          // 指示器
          Circle()
            .width(18).height(18)
            .fill(Color.White)
            .strokeWidth(2.5)
            .stroke($r('app.color.Comp_Bg3'))
            .shadow({ radius: 4, color: $r('app.color.shadow') })
            .offset({
              x: this.alphaBarW > 0 ? this.alpha * this.alphaBarW - 9 : 0,
              y: 0
            })
            .hitTestBehavior(HitTestMode.None)
        }
        .layoutWeight(1).height(24)
      }
      .width('100%').alignItems(VerticalAlign.Center)
    }
  }

  // ==================== 饱和度 × 明度 2D 色块 ====================

  @Builder
  ColorBlock() {
    Column({ space: 2 }) {

      Stack({ alignContent: Alignment.TopStart }) {
        // 底层：水平饱和度渐变（白 → 纯色）
        Row()
          .width('100%').height('100%')
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#FFFFFF', 0], [hslToHex(this.hue, 100, 50), 1]]
          })

        // 顶层：垂直明度渐变（透明 → 黑）
        Row()
          .width('100%').height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#00FFFFFF', 0], ['#FF000000', 1]]
          })

        // 选中指示器（外白内空圆环）
        Circle()
          .width(18).height(18)
          .fill(Color.Transparent)
          .strokeWidth(2)
          .stroke(Color.White)
          .shadow({ radius: 8, color: '#44000000' })
          .offset({
            x: this.blockWidth > 0 ? (this.sat / 100) * this.blockWidth - 9 : 0,
            y: this.blockHeight > 0 ? ((100 - this.light) / 100) * this.blockHeight - 9 : 0
          })
          .hitTestBehavior(HitTestMode.None)
      }
      .width('100%')
      .layoutWeight(1)
      .constraintSize({ minHeight: 80, maxHeight: 130 })
      .borderRadius(10)
      .clip(true)
      .onAreaChange((_: Area, newArea: Area) => {
        this.blockWidth = newArea.width as number
        this.blockHeight = newArea.height as number
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down || event.type === TouchType.Move) {
          if (this.blockWidth > 0 && this.blockHeight > 0) {
            const rx = Math.max(0, Math.min(1,
              event.touches[0].x / this.blockWidth))
            const ry = Math.max(0, Math.min(1,
              event.touches[0].y / this.blockHeight))
            this.sat = Math.round(rx * 100)
            this.light = Math.round((1 - ry) * 100)
            this.syncPreview()
          }
        }
      })
    }
  }

  // ==================== 预览 + 十六进制 ====================

  @Builder
  PreviewRow() {
    Row({ space: 12 }) {
      Circle()
        .width(36).height(36)
        .fill(this.previewColor)
        .strokeWidth(2)
        .stroke($r('app.color.Comp_Bg3'))
        .shadow({ radius: 6, color: this.previewColor, offsetY: 2 })
      Column({ space: 3 }) {
        Text('当前颜色').fontSize(10).fontColor($r('app.color.FontIcon_Fore3'))
        Text(this.previewColor.toUpperCase())
          .fontSize(14).fontWeight(500)
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
      mask: { color: $r('app.color.popup_mask') },
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
