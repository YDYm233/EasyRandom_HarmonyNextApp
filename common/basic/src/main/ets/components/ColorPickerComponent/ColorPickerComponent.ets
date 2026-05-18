/**
 * 颜色选择器组件 - 可复用的视觉化颜色选择器
 *
 * 功能特性：
 * - 预设颜色色板（横向滚动，选中带 ✓ + 缩放动画）
 * - 可视化自定义取色面板（色相滑块 + 饱和度/明度色盘）
 * - 纯视觉操作，无需手动输入十六进制颜色值
 * - 颜色变更回调
 */
// 默认预设颜色板
const DEFAULT_COLOR_PRESETS: string[] = [
  '#ffcba50b', '#ffa87cf4', '#ffe81b58', '#ff38ed44', '#fff7942c', '#ff68ead0',
  '#ffff007a', '#ff0cdec5', '#ff05f80b', '#ffecb609', '#ff5f16e1', '#499821',
  '#ffde6e12', '#ff3498db', '#ff9b59b6', '#ff1abc9c', '#ffe74c3c', '#fff39c12'
]

/** HSL 颜色表示 */
interface HslColor {
  h: number // 0-360
  s: number // 0-100
  l: number // 0-100
}

/** 色盘色块尺寸：饱和度(列) × 明度(行) */
const PALETTE_SAT_LEVELS: number[] = [20, 40, 60, 80, 100]
const PALETTE_LIGHT_LEVELS: number[] = [85, 65, 45, 25]

@Component
export struct ColorPickerComponent {
  /** 当前选中的颜色 */
  @Prop selectedColor: string = '#ffcba50b'
  /** 预设颜色数组（可选，默认使用内置色板） */
  @Prop presetColors: string[] = DEFAULT_COLOR_PRESETS
  /** 颜色变更回调 */
  onColorChange?: (color: string) => void

  /** 自定义面板开关 */
  @State showCustomPanel: boolean = false
  /** HSL 分量 */
  @State hueValue: number = 0
  @State satValue: number = 100
  @State lightValue: number = 50
  /** 色相滑块宽度（vp） */
  @State hueBarWidth: number = 0
  /** 当前 HSL 对应的十六进制颜色 */
  @State customPreviewColor: string = '#ff0000'

  // ==================== 生命周期 ====================

  aboutToAppear(): void {
    const hsl = ColorPickerComponent.hexToHsl(this.selectedColor)
    this.hueValue = hsl.h
    this.satValue = hsl.s
    this.lightValue = hsl.l
    this.customPreviewColor = ColorPickerComponent.hslToHex(hsl.h, hsl.s, hsl.l)
  }

  // ==================== HSL ↔ Hex 转换 ====================

  static hexToHsl(hex: string): HslColor {
    // 支持 #RGB / #RRGGBB / #AARRGGBB
    let r = 0, g = 0, b = 0
    const clean = hex.replace('#', '')
    if (clean.length === 3) {
      r = parseInt(clean[0] + clean[0], 16) / 255
      g = parseInt(clean[1] + clean[1], 16) / 255
      b = parseInt(clean[2] + clean[2], 16) / 255
    } else if (clean.length >= 6) {
      const offset = clean.length === 8 ? 2 : 0 // 跳过 AA
      r = parseInt(clean.substring(offset, offset + 2), 16) / 255
      g = parseInt(clean.substring(offset + 2, offset + 4), 16) / 255
      b = parseInt(clean.substring(offset + 4, offset + 6), 16) / 255
    }
    const max = Math.max(r, g, b)
    const min = Math.min(r, g, b)
    const delta = max - min
    let h = 0
    let s = 0
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
    return { h: Math.round(h), s: Math.round(s), l: Math.round(l) }
  }

  static hslToHex(h: number, s: number, l: number): string {
    s /= 100
    l /= 100
    const a = s * Math.min(l, 1 - l)
    const f = (n: number): number => {
      const k = (n + h / 30) % 12
      const c = l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1)
      return Math.round(c * 255)
    }
    const toHex = (v: number): string => v.toString(16).padStart(2, '0')
    return `#ff${toHex(f(0))}${toHex(f(8))}${toHex(f(4))}`
  }

  // ==================== 内部方法 ====================

  private applyCustomColorFromSliders(): void {
    this.customPreviewColor = ColorPickerComponent.hslToHex(this.hueValue, this.satValue, this.lightValue)
    this.onColorChange?.(this.customPreviewColor)
  }

  private isSameColor(a: string, b: string): boolean {
    return a.toLowerCase() === b.toLowerCase()
  }

  // ==================== UI 构建 ====================

  build() {
    Column({ space: 0 }) {
      // 第一行：预设色板 + 展开按钮
      Row({ space: 6 }) {
        // 预设颜色（横向滚动）
        Scroll() {
          Row({ space: 6 }) {
            ForEach(this.presetColors, (color: string) => {
              this.PresetColorDot(color)
            }, (c: string) => c)
          }
          .padding({ left: 2, right: 2 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .layoutWeight(1)

        // 自定义面板展开/收起按钮
        Row() {
          SymbolGlyph($r('sys.symbol.paintbrush_fill'))
            .fontSize(18)
            .fontColor([$r('app.color.FontIcon_Fore3')])
        }
        .width(32).height(32)
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.showCustomPanel ? $r('app.color.Brand') : $r('app.color.Comp_Bg2'))
        .onClick(() => {
          if (!this.showCustomPanel) {
            const hsl = ColorPickerComponent.hexToHsl(this.selectedColor)
            this.hueValue = hsl.h
            this.satValue = hsl.s
            this.lightValue = hsl.l
            this.customPreviewColor = this.selectedColor
          }
          this.showCustomPanel = !this.showCustomPanel
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 第二区域：自定义取色面板（可折叠）
      if (this.showCustomPanel) {
        Column({ space: 10 }) {
          // 色相滑块
          this.HueSlider()

          // 饱和度 + 明度色盘
          this.SatLightGrid()
        }
        .width('100%')
        .padding({ top: 10, left: 4, right: 4, bottom: 4 })
        .animation({ duration: 200, curve: Curve.EaseOut })
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      }
    }
    .width('100%')
  }

  // ==================== 色相滑块 ====================

  @Builder
  HueSlider() {
    Column({ space: 4 }) {
      Row({ space: 6 }) {
        Text('色相')
          .fontSize(11)
          .fontColor($r('app.color.FontIcon_Fore3'))
          .width(32)

        Stack() {
          // 彩虹渐变背景条
          Row()
            .width('100%')
            .height(22)
            .borderRadius(11)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [
                ['#FF0000', 0.0],
                ['#FFFF00', 0.17],
                ['#00FF00', 0.33],
                ['#00FFFF', 0.50],
                ['#0000FF', 0.67],
                ['#FF00FF', 0.83],
                ['#FF0000', 1.0]
              ]
            })
            .onAreaChange((_: Area, newArea: Area) => {
              this.hueBarWidth = newArea.width as number
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down || event.type === TouchType.Move) {
                const ratio = Math.max(0, Math.min(1, event.touches[0].x / this.hueBarWidth))
                this.hueValue = Math.round(ratio * 360)
                this.applyCustomColorFromSliders()
              }
            })

          // 当前位置指示器
          Circle()
            .width(16).height(16)
            .fill(Color.White)
            .strokeWidth(2)
            .stroke($r('app.color.Comp_Bg3'))
            .offset({
              x: this.hueBarWidth > 0 ? (this.hueValue / 360) * this.hueBarWidth - 8 : 0,
              y: 0
            })
            .hitTestBehavior(HitTestMode.None)
        }
        .layoutWeight(1)
        .alignContent(Alignment.Start)
      }
      .width('100%')
    }
    .width('100%')
  }

  // ==================== 饱和度/明度色盘 ====================

  private cellHex(sat: number, light: number): string {
    return ColorPickerComponent.hslToHex(this.hueValue, sat, light)
  }

  private isCellSelected(sat: number, light: number): boolean {
    return this.satValue === sat && this.lightValue === light &&
      this.isSameColor(this.customPreviewColor, this.cellHex(sat, light))
  }

  @Builder
  SatLightGrid() {
    Column({ space: 2 }) {
      ForEach(PALETTE_LIGHT_LEVELS, (light: number) => {
        Row({ space: 2 }) {
          ForEach(PALETTE_SAT_LEVELS, (sat: number) => {
            this.ColorCell(sat, light)
          }, (sat: number) => `${sat}_${light}`)
        }
      }, (light: number) => `${light}`)
    }
    .width('100%')
  }

  @Builder
  ColorCell(sat: number, light: number) {
    Row() {
      if (this.isCellSelected(sat, light)) {
        Text('✓')
          .fontSize(10)
          .fontColor(light > 50 ? '#333' : Color.White)
          .fontWeight(700)
      }
    }
    .layoutWeight(1)
    .aspectRatio(1)
    .borderRadius(6)
    .backgroundColor(this.cellHex(sat, light))
    .justifyContent(FlexAlign.Center)
    .border(this.isCellSelected(sat, light) ? { width: 2, color: $r('app.color.Brand') } : {})
    .onClick(() => {
      this.satValue = sat
      this.lightValue = light
      this.applyCustomColorFromSliders()
    })
  }

  // ==================== 预设色块 ====================

  @Builder
  PresetColorDot(color: string) {
    Row() {
      if (this.isSameColor(this.selectedColor, color)) {
        Text('✓')
          .fontSize(10)
          .fontColor(this.isSameColor(color, '#ffff007a') || this.isSameColor(color, '#ff05f80b')
            ? '#333' : Color.White)
          .fontWeight(700)
      }
    }
    .width(28).height(28)
    .borderRadius(14)
    .backgroundColor(color)
    .justifyContent(FlexAlign.Center)
    .shadow({
      radius: this.isSameColor(this.selectedColor, color) ? 4 : 2,
      color: color,
      offsetY: 1
    })
    .scale(this.isSameColor(this.selectedColor, color) ? { x: 1.15, y: 1.15 } : { x: 1, y: 1 })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .onClick(() => {
      this.onColorChange?.(color)
    })
  }
}
