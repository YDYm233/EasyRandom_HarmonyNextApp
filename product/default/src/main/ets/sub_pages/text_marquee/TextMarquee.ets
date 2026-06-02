// 页面路径要注册进 file:../product/default/src/main/resources/base/profile/main_pages.json
// 页面名称要注册进 file:../AppScope/resources/base/element/page_desc.json
// 页面入口要写进 file:../product/default/src/main/ets/pages/ToolsPage.ets

import { ColorPickerButton } from '@ohos/common';
import router from '@ohos.router';

class Params {
  type: string

  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct TextMarquee {
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.back({ url: 'pages/IndexPage/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_text_marquee")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SettingPage/SettingPage',
              params: new Params('no')
            }).then(() => {
              console.info("success.");
            })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%')
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      .padding({ top: this.statusBarHeight })

      Scroll() {
        GridRow({
          columns: { sm: 4, md: 8, lg: 12 },
          gutter: 12
        }) {
          GridCol({
            span: { sm: 4, md: 6, lg: 6 },
            offset: { sm: 0, md: 1, lg: 3 }
          }) {
            Row() {
              MarqueeEditor().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)
      }
      .width('100%')
      .height('100%')
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
  }
}

interface SelectOpt {
  value: string
}

interface FontWeightOption {
  label: string
  value: number
}

@Component
struct MarqueeEditor {
  @State text: string = '手持弹幕'
  @State fontColor: string = '#FFFFFF'
  @State bgColor: string = '#000000'
  @State fontFamily: string = 'HarmonyOS Sans'
  @State fontFamilyIndex: number = 0
  @State fontWeight: number = 700
  @State fontWeightIndex: number = 4
  @State showFontSheet: boolean = false
  @State speed: number = 60
  @State fontSize: number = 64
  @State isVertical: boolean = false
  @State scrollFromLeft: boolean = false
  @State isLoop: boolean = true
  @State loopCount: number = -1 // -1表示无限循环

  private readonly fontFamilies: string[] = ['HarmonyOS Sans', 'HarmonyOS Sans SC', 'HarmonyOS Sans TC']
  private readonly fontWeightOptions: FontWeightOption[] = [
    { label: '极细', value: 100 },
    { label: '细体', value: 200 },
    { label: '轻体', value: 300 },
    { label: '常规', value: 400 },
    { label: '中等', value: 500 },
    { label: '半粗', value: 600 },
    { label: '粗体', value: 700 },
    { label: '特粗', value: 800 },
    { label: '黑体', value: 900 },
  ]
  private readonly fontSizePresets: number[] = [24, 32, 40, 48, 56, 64, 72, 80, 96, 112, 128, 144, 160]
  private readonly displayDirectionOptions: SelectOpt[] = [
    { value: '横向展示' },
    { value: '竖向展示' }
  ]
  private readonly scrollDirectionOptions: SelectOpt[] = [
    { value: '← 从左向右' },
    { value: '从右向左 →' }
  ]
  private readonly loopCountOptions: SelectOpt[] = [
    { value: '无限循环' },
    { value: '循环 1 次' },
    { value: '循环 3 次' },
    { value: '循环 5 次' },
    { value: '循环 10 次' }
  ]

  private padText(src: string): string {
    if (src.length >= 20) {
      return src
    }
    return src + '　　　　'.repeat(12)
  }

  private snapFontSize(value: number): number {
    return this.fontSizePresets.reduce((prev, curr) =>
      Math.abs(curr - value) < Math.abs(prev - value) ? curr : prev
    )
  }

  private get fontLabel(): string {
    return this.fontFamily + ' / ' + this.fontWeightOptions[this.fontWeightIndex].label + ' / ' + this.fontSize.toString()
  }

  private getLoopCountIndex(): number {
    switch (this.loopCount) {
      case -1: return 0
      case 1: return 1
      case 3: return 2
      case 5: return 3
      case 10: return 4
      default: return 0
    }
  }

  private getLoopCountLabel(): string {
    if (this.loopCount === -1) {
      return '无限循环'
    }
    return '循环 ' + this.loopCount + ' 次'
  }

  private setLoopCountByIndex(index: number): void {
    switch (index) {
      case 0: this.loopCount = -1; break
      case 1: this.loopCount = 1; break
      case 2: this.loopCount = 3; break
      case 3: this.loopCount = 5; break
      case 4: this.loopCount = 10; break
      default: this.loopCount = -1
    }
    this.isLoop = this.loopCount !== 0
  }

  @Builder
  FontSheetBuilder() {
    Column({ space: 24 }) {
      // ── 标题 ──
      Row() {
        Text('字体设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r("app.color.FontIcon_Fore1"))
        Blank()
        Image($r("app.media.func_cancle"))
          .width(24)
          .height(24)
          .fillColor($r("app.color.FontIcon_Fore2"))
          .onClick(() => { this.showFontSheet = false })
      }
      .width('100%')

      // ── 字体族 ──
      Column({ space: 10 }) {
        Text('字体')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Select(this.fontFamilies.map((f: string): SelectOpt => ({ value: f })))
          .selected(this.fontFamilyIndex)
          .value(this.fontFamily)
          .height(48)
          .font({ size: 14 })
          .fontColor($r("app.color.FontIcon_Fore1"))
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .onSelect((index: number, _value: string) => {
            this.fontFamilyIndex = index
            this.fontFamily = this.fontFamilies[index]
          })
      }
      .width('100%')

      // ── 字重 ──
      Column({ space: 10 }) {
        Text('字重')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Select(this.fontWeightOptions.map((opt: FontWeightOption): SelectOpt => ({ value: opt.label })))
          .selected(this.fontWeightIndex)
          .value(this.fontWeightOptions[this.fontWeightIndex].label)
          .height(48)
          .font({ size: 14 })
          .fontColor($r("app.color.FontIcon_Fore1"))
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .onSelect((index: number, _value: string) => {
            this.fontWeightIndex = index
            this.fontWeight = this.fontWeightOptions[index].value
          })
      }
      .width('100%')

      // ── 字号（吸附式拖条）──
      Column({ space: 10 }) {
        Row() {
          Text('字号')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r("app.color.FontIcon_Fore1"))
          Blank()
          Text(this.fontSize.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r("app.color.Brand"))
        }
        .width('100%')
        Row({ space: 6 }) {
          ForEach(this.fontSizePresets, (size: number) => {
            Text(size.toString())
              .fontSize(10)
              .fontColor(this.fontSize === size ? $r("app.color.Brand") : $r("app.color.FontIcon_Fore3"))
              .fontWeight(this.fontSize === size ? FontWeight.Bold : FontWeight.Regular)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Slider({
          value: this.fontSize,
          min: this.fontSizePresets[0],
          max: this.fontSizePresets[this.fontSizePresets.length - 1],
          step: 1,
          style: SliderStyle.OutSet
        })
        .onChange((value: number) => {
          this.fontSize = this.snapFontSize(value)
        })
      }
      .width('100%')

      // ── 字体效果预览 ──
      Column({ space: 8 }) {
        Text('预览效果')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Column() {
          Marquee({ start: true, fromStart: this.scrollFromLeft, src: this.padText(this.text) })
            .width('100%')
            .height(44)
            .fontSize(22)
            .fontColor(this.fontColor)
            .fontFamily(this.fontFamily)
            .fontWeight(this.fontWeight)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.bgColor)
        .borderRadius(12)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 20, bottom: 32 })
  }

  build() {
    Column({ space: 20 }) {
      // ── 文字输入 ──
      Column({ space: 8 }) {
        Text('弹幕内容')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        TextArea({ text: this.text, placeholder: '请输入要展示的文字...' })
          .height(90)
          .fontSize(16)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .backgroundColor($r("app.color.Comp_Bg2"))
          .borderRadius(12)
          .padding(12)
          .onChange((value: string) => { this.text = value })
      }
      .width('100%')

      // ── 颜色选择 ──
      Column({ space: 8 }) {
        Text('颜色设置')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Row({ space: 16 }) {
          Row({ space: 8 }) {
            Text('文字').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
            ColorPickerButton({
              initialColor: this.fontColor,
              onColorChange: (color: string) => { this.fontColor = color }
            })
          }
          .alignItems(VerticalAlign.Center)
          .layoutWeight(1)

          Row({ space: 8 }) {
            Text('背景').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
            ColorPickerButton({
              initialColor: this.bgColor,
              onColorChange: (color: string) => { this.bgColor = color }
            })
          }
          .alignItems(VerticalAlign.Center)
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')

      // ── 字体设置（次级菜单入口）──
      Column({ space: 8 }) {
        Text('字体设置')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Row() {
          Text(this.fontLabel).fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
          Blank()
          Image($r("app.media.func_setting")).width(16).height(16).fillColor($r("app.color.FontIcon_Fore3"))
        }
        .height(48)
        .width('100%')
        .padding({ left: 16, right: 16 })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .borderRadius(12)
        .onClick(() => {
          this.showFontSheet = true
        })
      }
      .width('100%')

      // ── 速度 ──
      Column({ space: 8 }) {
        Row() {
          Text('滚动速度')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r("app.color.FontIcon_Fore1"))
          Blank()
          Text(this.speed.toString())
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r("app.color.Brand"))
        }
        .width('100%')
        Slider({
          value: this.speed,
          min: 30,
          max: 120,
          step: 10,
          style: SliderStyle.OutSet
        })
        .onChange((value: number) => { this.speed = value })
      }
      .width('100%')

      // ── 展示方向 ──
      Column({ space: 8 }) {
        Text('展示方向')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Select(this.displayDirectionOptions)
          .selected(this.isVertical ? 1 : 0)
          .value(this.isVertical ? '竖向展示' : '横向展示')
          .height(48)
          .font({ size: 14 })
          .fontColor($r("app.color.FontIcon_Fore1"))
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .onSelect((index: number, _value: string) => {
            this.isVertical = index === 1
          })
      }
      .width('100%')

      // ── 滚动方向 ──
      Column({ space: 8 }) {
        Text('滚动方向')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Select(this.scrollDirectionOptions)
          .selected(this.scrollFromLeft ? 0 : 1)
          .value(this.scrollFromLeft ? '← 从左向右' : '从右向左 →')
          .height(48)
          .font({ size: 14 })
          .fontColor($r("app.color.FontIcon_Fore1"))
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .onSelect((index: number, _value: string) => {
            this.scrollFromLeft = index === 0
          })
      }
      .width('100%')

      // ── 循环设置 ──
      Column({ space: 8 }) {
        Text('循环设置')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Select(this.loopCountOptions)
          .selected(this.getLoopCountIndex())
          .value(this.getLoopCountLabel())
          .height(48)
          .font({ size: 14 })
          .fontColor($r("app.color.FontIcon_Fore1"))
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .onSelect((index: number, _value: string) => {
            this.setLoopCountByIndex(index)
          })
      }
      .width('100%')

      // ── 预览 ──
      Column({ space: 8 }) {
        Text('效果预览')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .width('100%')
        Column() {
          Marquee({ start: true, fromStart: this.scrollFromLeft, src: this.padText(this.text) })
            .width('100%')
            .height(48)
            .fontSize(22)
            .fontColor(this.fontColor)
            .fontFamily(this.fontFamily)
            .fontWeight(this.fontWeight)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.bgColor)
        .borderRadius(12)
      }
      .width('100%')

      // ── 开始按钮 ──
      Button('开始弹幕')
        .width('100%')
        .height(52)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.control_fc_1"))
        .backgroundColor($r("app.color.Brand"))
        .borderRadius(26)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.95 })
        .onClick(() => {
          if (!this.text.trim()) {
            return
          }
          router.pushUrl({
            url: 'sub_pages/text_marquee/DisplayMarquee',
            params: {
              text: this.text,
              fontColor: this.fontColor,
              bgColor: this.bgColor,
              fontFamily: this.fontFamily,
              fontWeight: this.fontWeight,
              speed: this.speed,
              fontSize: this.fontSize,
              isVertical: this.isVertical,
              scrollFromLeft: this.scrollFromLeft,
              isLoop: this.isLoop,
              loopCount: this.loopCount
            }
          })
        })
    }
    .width('100%')
    .padding(24)
    .borderRadius(20)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .bindSheet($$this.showFontSheet, this.FontSheetBuilder(), { height: 420 })
  }
}

export default TextMarquee
