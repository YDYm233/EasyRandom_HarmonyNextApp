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

  @Builder
  FontSheetBuilder() {
    Column({ space: 20 }) {
      // ── 字体族 ──
      Column({ space: 8 }) {
        Text('字体').fontSize(15).fontWeight(FontWeight.Bold).width('100%')
        Select(this.fontFamilies.map((f: string): SelectOpt => ({ value: f })))
          .selected(this.fontFamilyIndex)
          .value(this.fontFamily)
          .height(44)
          .onSelect((index: number, _value: string) => {
            this.fontFamilyIndex = index
            this.fontFamily = this.fontFamilies[index]
          })
      }
      .width('100%')

      // ── 字重 ──
      Column({ space: 8 }) {
        Text('字重').fontSize(15).fontWeight(FontWeight.Bold).width('100%')
        Select(this.fontWeightOptions.map((opt: FontWeightOption): SelectOpt => ({ value: opt.label })))
          .selected(this.fontWeightIndex)
          .value(this.fontWeightOptions[this.fontWeightIndex].label)
          .height(44)
          .onSelect((index: number, _value: string) => {
            this.fontWeightIndex = index
            this.fontWeight = this.fontWeightOptions[index].value
          })
      }
      .width('100%')

      // ── 字号（吸附式拖条）──
      Column({ space: 6 }) {
        Row() {
          Text('字号').fontSize(15).fontWeight(FontWeight.Bold)
          Blank()
          Text(this.fontSize.toString()).fontSize(14).fontColor($r("app.color.FontIcon_Fore1")).fontWeight(FontWeight.Bold)
        }
        .width('100%')
        Row({ space: 4 }) {
          ForEach(this.fontSizePresets, (size: number) => {
            Text(size.toString())
              .fontSize(9)
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
      Column() {
        Marquee({ start: true, src: this.padText(this.text) })
          .width('100%')
          .height(36)
          .fontSize(20)
          .fontColor(this.fontColor)
          .fontFamily(this.fontFamily)
          .fontWeight(this.fontWeight)
          .scrollDirection(this.scrollFromLeft ? MarqueeScrollDirection.RIGHT : MarqueeScrollDirection.LEFT)
      }
      .width('100%')
      .padding(8)
      .backgroundColor(this.bgColor)
      .borderRadius(8)
    }
    .width('100%')
    .padding(24)
  }

  build() {
    Column({ space: 16 }) {
      // ── 文字输入 ──
      Column({ space: 6 }) {
        Text('弹幕内容').fontSize(13).fontColor($r("app.color.FontIcon_Fore2")).width('100%')
        TextArea({ text: this.text, placeholder: '请输入要展示的文字...' })
          .height(80)
          .fontSize(16)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .backgroundColor($r("app.color.Comp_Bg2"))
          .borderRadius(8)
          .padding(10)
          .onChange((value: string) => { this.text = value })
      }
      .width('100%')

      // ── 颜色选择 ──
      Row({ space: 20 }) {
        Row({ space: 8 }) {
          Text('颜色').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
          ColorPickerButton({
            initialColor: this.fontColor,
            onColorChange: (color: string) => { this.fontColor = color }
          })
        }
        .alignItems(VerticalAlign.Center)

        Row({ space: 8 }) {
          Text('背景').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
          ColorPickerButton({
            initialColor: this.bgColor,
            onColorChange: (color: string) => { this.bgColor = color }
          })
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')

      // ── 字体设置（次级菜单入口）──
      Row() {
        Row() {
          Text('字体').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
          Blank()
          Text(this.fontLabel).fontSize(13).fontColor($r("app.color.FontIcon_Fore1"))
          Image($r("app.media.func_setting")).width(16).height(16).fillColor($r("app.color.FontIcon_Fore3")).margin({ left: 4 })
        }
        .height(44)
        .width('100%')
        .padding({ left: 12, right: 12 })
        .backgroundColor($r("app.color.Comp_Bg2"))
        .borderRadius(8)
        .onClick(() => {
          this.showFontSheet = true
        })
      }
      .width('100%')

      // ── 速度 ──
      Row({ space: 12 }) {
        Text('速度').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
        Slider({
          value: this.speed,
          min: 30,
          max: 120,
          step: 10,
          style: SliderStyle.OutSet
        })
        .layoutWeight(1)
        .onChange((value: number) => { this.speed = value })
        Text(this.speed.toString()).fontSize(12).fontColor($r("app.color.FontIcon_Fore2")).width(24).textAlign(TextAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // ── 展示方向（横向 / 竖向）──
      Row({ space: 12 }) {
        Text('展示').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
        Row({ space: 8 }) {
          Button('横向')
            .fontSize(12).height(32)
            .fontColor($r("app.color.FontIcon_Fore1"))
            .backgroundColor(this.isVertical ? $r("app.color.Comp_Bg2") : $r("app.color.Brand"))
            .onClick(() => { this.isVertical = false })
          Button('竖向')
            .fontSize(12).height(32)
            .fontColor($r("app.color.FontIcon_Fore1"))
            .backgroundColor(this.isVertical ? $r("app.color.Brand") : $r("app.color.Comp_Bg2"))
            .onClick(() => { this.isVertical = true })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // ── 滚动方向（左→右 / 右→左）──
      Row({ space: 12 }) {
        Text('滚动').fontSize(13).fontColor($r("app.color.FontIcon_Fore2"))
        Row({ space: 8 }) {
          Button('左→右')
            .fontSize(12).height(32)
            .fontColor($r("app.color.FontIcon_Fore1"))
            .backgroundColor(this.scrollFromLeft ? $r("app.color.Brand") : $r("app.color.Comp_Bg2"))
            .onClick(() => { this.scrollFromLeft = true })
          Button('右→左')
            .fontSize(12).height(32)
            .fontColor($r("app.color.FontIcon_Fore1"))
            .backgroundColor(this.scrollFromLeft ? $r("app.color.Comp_Bg2") : $r("app.color.Brand"))
            .onClick(() => { this.scrollFromLeft = false })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // ── 预览 ──
      Column() {
        Marquee({ start: true, src: this.padText(this.text) })
          .width('100%')
          .height(40)
          .fontSize(20)
          .fontColor(this.fontColor)
          .fontFamily(this.fontFamily)
          .fontWeight(this.fontWeight)
          .scrollDirection(this.scrollFromLeft ? MarqueeScrollDirection.RIGHT : MarqueeScrollDirection.LEFT)
        Text('预览').fontSize(11).fontColor($r("app.color.FontIcon_Fore3")).width('100%').textAlign(TextAlign.Center).margin({ top: 4 })
      }
      .width('100%')
      .padding(8)
      .backgroundColor(this.bgColor)
      .borderRadius(8)

      // ── 开始按钮 ──
      Button('开始弹幕')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.control_fc_1"))
        .backgroundColor($r("app.color.Brand"))
        .borderRadius(24)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
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
              scrollFromLeft: this.scrollFromLeft
            }
          })
        })
    }
    .width('100%')
    .padding(20)
    .borderRadius(16)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .bindSheet($$this.showFontSheet, this.FontSheetBuilder(), { height: 420 })
  }
}

export default TextMarquee
