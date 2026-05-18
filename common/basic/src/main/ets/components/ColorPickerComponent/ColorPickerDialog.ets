/**
 * 专业颜色选择器 — Popup 气泡 + 按钮一体化组件
 *
 * 包含:
 *   ColorPickerView       — @Component 取色面板（色相滑块 + 透明度滑块 + 2D 色块）
 *   ColorPickerButton     — 小巧按钮，点击弹出 Popup 气泡取色
 *
 * 设计约束:
 *   - 面板 constraintSize 限制 440×380，适配多种设备
 *   - 2D 色块 layoutWeight 弹性撑满，各子组件响应式自适应
 *   - 暗色模式通过 $r 资源自动适配
 */

// ═══════════════════════════════════════════════════════════════════════
//  类型 & 常量
// ═══════════════════════════════════════════════════════════════════════

/** HSL 颜色模型（h: 0-360, s/l: 0-100, a: 0-1） */
interface HslColor { h: number; s: number; l: number; a: number }

/** 8-bit RGB 分量 */
interface RgbComponents { r: number; g: number; b: number }

/** 颜色格式切换顺序：Hex → RGBA → HSLA */
enum ColorFormat { HEX, RGBA, HSLA }

/** 滑块与指示器通用尺寸 */
const THUMB_SIZE = 18
const THUMB_HALF = 9
const THUMB_STROKE = 2.5
const BAR_INNER_W = 20
const BAR_OUTER_W = 22
const BAR_RADIUS = 10

// ═══════════════════════════════════════════════════════════════════════
//  颜色转换工具函数
// ═══════════════════════════════════════════════════════════════════════

/**
 * HSL → RGB 整数分量（0-255），不含 Alpha。
 * 供 hslToHex / hslToRgbaString 共用，避免重复实现。
 */
function hslToRgbComponents(h: number, s: number, l: number): RgbComponents {
  s /= 100
  l /= 100
  const chroma = s * Math.min(l, 1 - l)
  const hueNorm = h / 30
  const compute = (n: number): number => {
    const k = (n + hueNorm) % 12
    return Math.round((l - chroma * Math.max(Math.min(k - 3, 9 - k, 1), -1)) * 255)
  }
  return { r: compute(0), g: compute(8), b: compute(4) }
}

/** 十六进制颜色 → HSL（支持 #RGB / #RRGGBB / #AARRGGBB 格式） */
function hexToHsl(hex: string): HslColor {
  let r = 0, g = 0, b = 0, a = 1
  const clean = hex.replace('#', '')
  if (clean.length === 3) {
    r = parseInt(clean[0] + clean[0], 16) / 255
    g = parseInt(clean[1] + clean[1], 16) / 255
    b = parseInt(clean[2] + clean[2], 16) / 255
  } else if (clean.length >= 6) {
    // 8 位格式 #AARRGGBB 跳过前 2 位 alpha
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
    if (max === r) {
      h = ((g - b) / delta + (g < b ? 6 : 0)) * 60
    } else if (max === g) {
      h = ((b - r) / delta + 2) * 60
    } else {
      h = ((r - g) / delta + 4) * 60
    }
  }
  return { h: Math.round(h), s: Math.round(s), l: Math.round(l), a: Math.round(a * 100) / 100 }
}

/** HSL → 十六进制颜色 #AARRGGBB */
function hslToHex(h: number, s: number, l: number, a: number = 1): string {
  const rgb = hslToRgbComponents(h, s, l)
  const toHex = (v: number): string => v.toString(16).padStart(2, '0')
  const alphaHex = Math.round(a * 255).toString(16).padStart(2, '0')
  return `#${alphaHex}${toHex(rgb.r)}${toHex(rgb.g)}${toHex(rgb.b)}`
}

/** HSL → rgba() 字符串 */
function hslToRgbaString(h: number, s: number, l: number, a: number = 1): string {
  const rgb = hslToRgbComponents(h, s, l)
  return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${a})`
}

/** HSL → hsla() 字符串 */
function hslToHslaString(h: number, s: number, l: number, a: number = 1): string {
  return `hsla(${h}°, ${s}%, ${l}%, ${a})`
}

/** RGB(A) → HSL */
function rgbToHsl(r: number, g: number, b: number, a: number = 1): HslColor {
  const rn = r / 255, gn = g / 255, bn = b / 255
  const max = Math.max(rn, gn, bn), min = Math.min(rn, gn, bn)
  const l = (max + min) / 2
  let h = 0, s = 0
  if (max !== min) {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    if (max === rn) {
      h = ((gn - bn) / d + (gn < bn ? 6 : 0)) / 6
    } else if (max === gn) {
      h = ((bn - rn) / d + 2) / 6
    } else {
      h = ((rn - gn) / d + 4) / 6
    }
  }
  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100),
    a: Math.round(a * 100) / 100
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  ColorPickerView — 纯 @Component 取色面板
// ═══════════════════════════════════════════════════════════════════════

/**
 * 取色面板（色相条 + 透明度条 + 饱和度×明度 2D 色块 + 当前预览）。
 * 不含弹窗逻辑，可嵌入任意容器。
 *
 * @param initialColor 初始颜色（#AARRGGBB / #RRGGBB 格式）
 * @param onConfirm 用户点击"确定"回调，参数为最终颜色字符串
 * @param onClose 用户取消 / 外部关闭回调
 */
@Component
export struct ColorPickerView {
  // ---- Props & Callbacks ----

  @Prop initialColor: string = '#74619134'
  onConfirm?: (color: string) => void
  onClose?: () => void

  // ---- HSL(A) 核心状态 ----

  @State private hue: number = 0
  @State private sat: number = 100
  @State private light: number = 50
  @State private alpha: number = 1

  // ---- 派生显示状态 ----

  @State private previewColor: string = '#ff0ba5cb'
  @State private r: number = 0
  @State private g: number = 0
  @State private b: number = 0
  @State private aPercent: number = 100          // 0-100，UI 显示用
  @State private colorFormatIndex: number = ColorFormat.HEX

  // ---- 滑块轨道尺寸（onAreaChange 动态测量）----

  @State private hueTrackH: number = 0
  @State private alphaTrackH: number = 0
  @State private blockWidth: number = 0
  @State private blockHeight: number = 0

  // ─── Lifecycle ──────────────────────────────────────────────────

  aboutToAppear(): void {
    this.resetToColor(this.initialColor)
  }

  // ─── Color State Management ─────────────────────────────────────

  /** 重置到指定颜色 */
  private resetToColor(hex: string): void {
    const hsl = hexToHsl(hex)
    this.hue = hsl.h
    this.sat = hsl.s
    this.light = hsl.l
    this.alpha = hsl.a
    this.previewColor = hex
    this.syncRgbaFromHex()
  }

  /**
   * 由 HSL 状态同步更新 previewColor 与 RGBA 分量。
   * 合并在一次 HSL→RGB 计算中完成，避免 hex↔RGB 冗余往返。
   */
  private syncFromHsl(): void {
    const rgb = hslToRgbComponents(this.hue, this.sat, this.light)
    this.r = rgb.r
    this.g = rgb.g
    this.b = rgb.b
    const toHex = (v: number): string => v.toString(16).padStart(2, '0')
    const alphaHex = Math.round(this.alpha * 255).toString(16).padStart(2, '0')
    this.previewColor = `#${alphaHex}${toHex(rgb.r)}${toHex(rgb.g)}${toHex(rgb.b)}`
    this.aPercent = Math.round(this.alpha * 100)
  }

  /** 从 previewColor 十六进制字符串反向解析 RGBA 分量 */
  private syncRgbaFromHex(): void {
    const hex = this.previewColor.replace('#', '')
    const offset = hex.length >= 8 ? 2 : 0
    this.r = parseInt(hex.substring(offset, offset + 2), 16)
    this.g = parseInt(hex.substring(offset + 2, offset + 4), 16)
    this.b = parseInt(hex.substring(offset + 4, offset + 6), 16)
    const aHex = hex.length >= 8 ? hex.substring(0, 2) : 'ff'
    this.aPercent = Math.round(parseInt(aHex, 16) / 255 * 100)
  }

  /** 由 RGBA 输入框反向同步到 HSL 状态 */
  private syncFromRgba(): void {
    const hsl = rgbToHsl(this.r, this.g, this.b, this.aPercent / 100)
    this.hue = hsl.h
    this.sat = hsl.s
    this.light = hsl.l
    this.alpha = hsl.a
    this.previewColor = hslToHex(this.hue, this.sat, this.light, this.alpha)
  }

  /** 按当前选中格式返回颜色字符串 */
  private formatColor(): string {
    if (this.colorFormatIndex === ColorFormat.HEX) {
      return this.previewColor.toUpperCase()
    }
    if (this.colorFormatIndex === ColorFormat.RGBA) {
      return hslToRgbaString(this.hue, this.sat, this.light, this.alpha)
    }
    return hslToHslaString(this.hue, this.sat, this.light, this.alpha)
  }

  /** 循环切换颜色显示格式 */
  private cycleColorFormat(): void {
    this.colorFormatIndex = (this.colorFormatIndex + 1) % 3
  }

  // ─── Build ──────────────────────────────────────────────────────

  build() {
    Column({ space: 0 }) {
      this.TitleBar()
      Column({ space: 4 }) {
        // 三列布局：2D 色块 | 色相条 | 透明度条
        Row({ space: 8 }) {
          Column({ space: 4 }) {
            Column() {
              this.ColorBlock()
            }
            .layoutWeight(1).width('100%').height('100%')
            this.RgbaInputs()
          }
          .layoutWeight(1).height('100%')

          Column({ space: 4 }) {
            this.HueBar()
          }
          .width(28).height('100%')

          Column({ space: 4 }) {
            this.AlphaBar()
          }
          .width(28).height('100%')
        }
        .layoutWeight(1).width('100%')

        Divider()
        this.PreviewRow()
        this.ActionButtons()
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8, bottom: 6 })
    }
    .width('100%')
    .constraintSize({ maxWidth: 440, maxHeight: 380 })
    .borderRadius(16)
    .backgroundColor($r('app.color.Comp_Bg1'))
    .shadow({ radius: 24, color: $r('app.color.shadow'), offsetY: 8 })
  }

  // ─── Sub-Builders — 标题栏 ─────────────────────────────────────

  @Builder
  TitleBar() {
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
  }

  // ─── Sub-Builders — 色相条（垂直）───────────────────────────────

  /**
   * 垂直色相条：0°（红）在顶部 → 360°（红）在底部。
   * 触摸位置 y 映射为 0-360° 色相角。
   */
  @Builder
  HueBar() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        // 色相渐变轨道
        Column()
          .width(BAR_INNER_W).height('100%').borderRadius(BAR_RADIUS)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['#FF0000', 0.000],
              ['#FF4400', 0.083],
              ['#FF8800', 0.167],
              ['#CCDD00', 0.250],
              ['#00FF00', 0.333],
              ['#00FF88', 0.417],
              ['#00FFFF', 0.500],
              ['#0088FF', 0.583],
              ['#0000FF', 0.667],
              ['#7700FF', 0.750],
              ['#FF00FF', 0.833],
              ['#FF0088', 0.917],
              ['#FF0000', 1.000]
            ]
          })
          .onAreaChange((_: Area, newArea: Area) => {
            this.hueTrackH = newArea.height as number
          })
          .onTouch((event: TouchEvent) => {
            if (this.hueTrackH > 0 &&
              (event.type === TouchType.Down || event.type === TouchType.Move)) {
              const ratio = Math.max(0, Math.min(1,
                event.touches[0].y / this.hueTrackH))
              this.hue = Math.round(ratio * 360)
              this.syncFromHsl()
            }
          })

        // 拖拽指示器
        Circle()
          .width(THUMB_SIZE).height(THUMB_SIZE)
          .fill(Color.White)
          .strokeWidth(THUMB_STROKE)
          // 使用当前色相纯色描边，避免极端明度下描边不可见
          .stroke(hslToHex(this.hue, 100, 50))
          .shadow({ radius: 4, color: $r('app.color.shadow') })
          .offset({
            y: this.hueTrackH > 0 ? (this.hue / 360) * this.hueTrackH - THUMB_HALF : 0
          })
          .hitTestBehavior(HitTestMode.None)
      }
      .width(BAR_OUTER_W).layoutWeight(1)
    }
    .alignItems(HorizontalAlign.Center).layoutWeight(1)
  }

  // ─── Sub-Builders — 透明度条（垂直）─────────────────────────────

  /**
   * 垂直透明度条：顶部 alpha=1（不透明）→ 底部 alpha=0（全透明）。
   * 棋盘格底纹用于可视化半透明区域。
   */
  @Builder
  AlphaBar() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        // 棋盘格底纹
        Column()
          .width(BAR_INNER_W).height('100%').borderRadius(BAR_RADIUS)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#D5D5D5', 0], ['#AAAAAA', 0.5], ['#D5D5D5', 1]]
          })

        // Alpha 渐变：顶部不透明 → 底部透明
        Column()
          .width(BAR_INNER_W).height('100%').borderRadius(BAR_RADIUS)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              [`#ff${this.previewColor.substring(3)}`, 0],
              [`#00${this.previewColor.substring(3)}`, 1]
            ]
          })
          .onAreaChange((_: Area, newArea: Area) => {
            this.alphaTrackH = newArea.height as number
          })
          .onTouch((event: TouchEvent) => {
            if (this.alphaTrackH > 0 &&
              (event.type === TouchType.Down || event.type === TouchType.Move)) {
              const y = Math.max(0, Math.min(this.alphaTrackH, event.touches[0].y))
              this.alpha = Math.round((1 - y / this.alphaTrackH) * 100) / 100
              this.syncFromHsl()
            }
          })

        // 拖拽指示器
        Circle()
          .width(THUMB_SIZE).height(THUMB_SIZE)
          .fill(Color.White)
          .strokeWidth(THUMB_STROKE)
          .stroke($r('app.color.Comp_Bg3'))
          .shadow({ radius: 4, color: $r('app.color.shadow') })
          .offset({
            y: this.alphaTrackH > 0 ? (1 - this.alpha) * this.alphaTrackH - THUMB_HALF : 0
          })
          .hitTestBehavior(HitTestMode.None)
      }
      .width(BAR_OUTER_W).layoutWeight(1)
    }
    .alignItems(HorizontalAlign.Center).layoutWeight(1)
  }

  // ─── Sub-Builders — 饱和度×明度 2D 色块 ─────────────────────────

  /**
   * 2D 取色区域：水平轴 = 饱和度 (0→100)，垂直轴 = 明度 (100→0)。
   * 底层：白 → 纯色水平渐变；顶层：透明 → 黑垂直渐变叠加。
   */
  @Builder
  ColorBlock() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 底层：水平饱和度渐变（白 → 当前色相纯色）
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

      // 选中位置指示器（空心圆环）
      Circle()
        .width(THUMB_SIZE).height(THUMB_SIZE)
        .fill(Color.Transparent)
        .strokeWidth(2)
        .stroke(Color.White)
        .shadow({ radius: 8, color: '#44000000' })
        .offset({
          x: this.blockWidth > 0 ? (this.sat / 100) * this.blockWidth - THUMB_HALF : 0,
          y: this.blockHeight > 0 ? ((100 - this.light) / 100) * this.blockHeight - THUMB_HALF : 0
        })
        .hitTestBehavior(HitTestMode.None)
    }
    .width('100%').height('100%')
    .borderRadius(BAR_RADIUS)
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
          this.syncFromHsl()
        }
      }
    })
  }

  // ─── Sub-Builders — RGBA 数值输入 ───────────────────────────────

  @Builder
  RgbaInputs() {
    Row({ space: 6 }) {
      this.RgbaField('#FF4444', 'R', (v: number) => { this.r = v; this.syncFromRgba() })
      this.RgbaField('#44BB44', 'G', (v: number) => { this.g = v; this.syncFromRgba() })
      this.RgbaField('#4488FF', 'B', (v: number) => { this.b = v; this.syncFromRgba() })
      this.RgbaField('#888888', 'A', (v: number) => { this.aPercent = v; this.syncFromRgba() })
    }
    .width('100%')
  }

  /**
   * 单个 RGBA 通道输入框。
   * @param dotColor 标识圆点颜色
   * @param label 通道标签（R/G/B/A）
   * @param onChange 值变更回调
   */
  @Builder
  RgbaField(dotColor: string, label: string, onChange: (v: number) => void) {
    Column({ space: 4 }) {
      // 标签行
      Row({ space: 4 }) {
        Circle()
          .width(6).height(6)
          .fill(dotColor)
        Text(label)
          .fontSize(11).fontWeight(600)
          .fontColor($r('app.color.FontIcon_Fore3'))
      }

      // 数值输入
      TextInput({ text: this.getChannelValue(label).toString() })
        .type(InputType.Number)
        .fontSize(12)
        .fontFamily('monospace')
        .textAlign(TextAlign.Center)
        .width('100%').height(30)
        .borderRadius(6)
        .backgroundColor($r('app.color.Comp_Bg2'))
        .borderColor($r('app.color.Comp_Bg3'))
        .borderWidth(0.5)
        .onChange((value: string) => {
          let num = parseInt(value)
          if (isNaN(num)) {
            if (value === '') {
              onChange(0)
            }
            return
          }
          const max = label === 'A' ? 100 : 255
          num = Math.max(0, Math.min(max, num))
          onChange(num)
        })
    }
    .layoutWeight(1)
  }

  /** 根据通道标签返回当前值 */
  private getChannelValue(label: string): number {
    if (label === 'R') {
      return this.r
    }
    if (label === 'G') {
      return this.g
    }
    if (label === 'B') {
      return this.b
    }
    return this.aPercent
  }

  // ─── Sub-Builders — 预览行 ─────────────────────────────────────

  @Builder
  PreviewRow() {
    Row({ space: 10 }) {
      // 颜色预览圆
      Circle()
        .width(28).height(28)
        .fill(this.previewColor)
        .strokeWidth(2)
        .stroke($r('app.color.Comp_Bg3'))
        .shadow({ radius: 4, color: this.previewColor, offsetY: 1 })

      // 格式标签 & 颜色值
      Column({ space: 2 }) {
        Row({ space: 4 }) {
          Text(this.getFormatLabel())
            .fontSize(11).fontColor($r('app.color.Brand'))
            .fontWeight(600)
        }
        Text(this.formatColor())
          .fontSize(13).fontWeight(500)
          .fontColor($r('app.color.FontIcon_Fore1'))
          .fontFamily('monospace')
      }.alignItems(HorizontalAlign.Start)

      Blank()

      // 格式切换按钮
      Row() {
        SymbolGlyph($r('sys.symbol.repeat'))
          .fontSize(14)
          .fontColor([$r('app.color.FontIcon_Fore3')])
      }
      .width(32).height(32).borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.Comp_Bg2'))
      .onClick(() => this.cycleColorFormat())
    }
    .width('100%')
    .padding({ top: 3, bottom: 3, left: 6, right: 6 })
    .backgroundColor($r('app.color.Comp_Bg2'))
    .borderRadius(12)
  }

  /** 当前格式的标签文字 */
  private getFormatLabel(): string {
    if (this.colorFormatIndex === ColorFormat.HEX) {
      return 'HEX'
    }
    if (this.colorFormatIndex === ColorFormat.RGBA) {
      return 'RGBA'
    }
    return 'HSLA'
  }

  // ─── Sub-Builders — 底部按钮 ────────────────────────────────────

  @Builder
  ActionButtons() {
    Row({ space: 12 }) {
      Button('取消')
        .fontSize(14)
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.Comp_Bg2'))
        .fontColor($r('app.color.FontIcon_Fore1'))
        .layoutWeight(1).height(32).borderRadius(8)
        .onClick(() => this.onClose?.())

      Button('确定')
        .fontSize(14)
        .type(ButtonType.Normal)
        .backgroundColor($r('app.color.Brand'))
        .fontColor(Color.White)
        .layoutWeight(1).height(32).borderRadius(8)
        .onClick(() => this.onConfirm?.(this.previewColor))
    }
    .width('100%')
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  ColorPickerButton — 按钮 + bindPopup 气泡组件
// ═══════════════════════════════════════════════════════════════════════

/**
 * 小巧颜色按钮，点击弹出 Popup 取色面板。
 *
 * 使用方式:
 *   ColorPickerButton({
 *     initialColor: item.color,
 *     onColorChange: (newColor: string) => { item.color = newColor; persist() }
 *   })
 *
 * 交互流程: 点击按钮 → Popup 取色面板 → 确定后按钮色即时刷新 & 回调父组件
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

  /** Popup 内嵌取色面板 */
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
      // 当前颜色色块
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
