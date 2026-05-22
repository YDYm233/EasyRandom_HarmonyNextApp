import { ExColor, Random } from '@ohos/common'
import router from '@ohos.router';

class Params {
  type: string
  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct RandomColors {
  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.back({ url: 'pages/Index' })
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
            Text($r("app.string.page_random_colors")).fontColor($r("app.color.FontIcon_Fore1"))
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
      .height($r("app.float.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })
      Scroll() {
        GridRow({
          columns: {
            sm: 4,
            md: 8,
            lg: 12
          },
          gutter: 12
        }) {
          GridCol({
            span: {
              sm: 4,
              md: 6,
              lg: 8
            },
            offset: {
              sm: 0,
              md: 1,
              lg: 2
            }
          }) {
           Row() {
              ColorsBox().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')  .padding({ top: $r("app.float.header_height") })
    }.height('100%')   .backgroundColor($r("app.color.Comp_Bg3"))   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct ColorsBox {
  @State RR: number = 187
  @State GG: number = 255
  @State BB: number = 204
  @State AA: number = 255
  @State AA_fixed: number = Number((this.AA / 255).toFixed())
  @State RGB: string = '#bfc'
  @State RGBA: string = '#bbffccff'
  @State bgc: string = ExColor(this.RGBA)
  @State blurColor: LinearGradient =
    new LinearGradient([{ color: this.RGB, offset: 0 }, { color: this.RGBA, offset: 1 }])
  @State blurRedColor: LinearGradient =
    new LinearGradient([{ color: this.RGBA, offset: 0 }, { color: 0xffffcc, offset: 1 }])
  @State  blurGreenColor: LinearGradient =
    new LinearGradient([{ color: this.RGBA, offset: 0 }, { color: 0xbbffcc, offset: 1 }])
  @State  blurBlueColor: LinearGradient =
    new LinearGradient([{ color: this.RGB, offset: 0 }, { color: 0xbbffff, offset: 1 }])

  build() {
    Column() {
      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12
        },
        gutter: 12
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Row() {
          }
          .width('100%')
          .aspectRatio(1)
          .backgroundColor(this.bgc)
          .borderRadius(24)

        }


        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Column() {
            Row() {
              Text(this.RGBA).fontWeight(FontWeight.Bold).textCase(TextCase.UpperCase)            .fontColor($r("app.color.FontIcon_Fore1"))
            }
            .layoutWeight(1)
            .onClick(() => {
              this.RGBA = ExColor(this.RGBA);
            })

            Row() {
              Text('R:')
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .padding(0)
                .height('80%')
                .width('10%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
              Slider({
                value: this.RR,
                min: 0,
                max: 255,
                style: SliderStyle.OutSet
              })
                .width('70%')
                .trackColor(this.blurRedColor)
                .selectedColor('rgba(0,0,0,0)')
                .blockColor('#333')
                .trackThickness(120)
                .blockBorderWidth(20)
                .blockBorderColor('#80ff0000')
                .onChange(
                  (newValue: number, mode: SliderChangeMode) => {
                    this.RR = Number(newValue.toFixed(2));
                    mode = 2;
                    this.RGBA =
                      'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.RGB = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 0.2 + ')'
                    let A: string = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 1 + ')'
                    this.blurColor = new LinearGradient([{ color: this.RGB, offset: 0.2 }, { color: A, offset: 0.8 }])
                    //let Red:string = 'rgba(' + 255 + ',' + this.GG + ',' + this.BB + ',' +  (this.AA / 255).toFixed(2) + ')'
                    //let GB:string = 'rgba(' + 0 + ',' + this.GG + ',' + this.BB + ',' +  (this.AA / 255).toFixed(2) + ')'
                    //this.blurRedColor= new LinearGradient([{ color: GB, offset: 0.2 }, { color:Red, offset: 0.8 }])
                    let Green: string =
                      'rgba(' + this.RR + ',' + 255 + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    let RB: string =
                      'rgba(' + this.RR + ',' + 0 + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.blurGreenColor =
                      new LinearGradient([{ color: RB, offset: 0.2 }, { color: Green, offset: 0.8 }])
                    let Blue: string =
                      'rgba(' + this.RR + ',' + this.GG + ',' + 255 + ',' + (this.AA / 255).toFixed(2) + ')'
                    let RG: string =
                      'rgba(' + this.RR + ',' + this.GG + ',' + 0 + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.blurBlueColor = new LinearGradient([{ color: RG, offset: 0.2 }, { color: Blue, offset: 0.8 }])
                    this.bgc = this.RGBA
                  }
                )
              TextInput({ text: this.RR.toString(), placeholder: '红' })
                .padding(0)
                .height('80%')
                .width('20%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .underlineColor(0x333333)
                .type(InputType.Number)
                .maxLength(3)
                .enterKeyType(EnterKeyType.Done)
                .onChange((value: string) => {
                  let newValue: number = Number(value);
                  if (newValue > 255) {
                    newValue = 255;
                  } else if (newValue < 0) {
                    newValue = 0;
                  }
                  this.RR = newValue;
                  this.RGBA =
                    'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + Number((this.AA / 255).toFixed(2)) + ')';
                  this.bgc = this.RGBA
                })
            }
            .layoutWeight(1)
            .width('100%')

            Row() {
              Text('G:')
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .padding(0)
                .height('80%')
                .width('10%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
              Slider({
                value: this.GG,
                min: 0,
                max: 255,
                style: SliderStyle.OutSet
              })
                .width('70%')
                .trackColor(this.blurGreenColor)
                .selectedColor('rgba(0,0,0,0)')
                .blockColor('#333')
                .trackThickness(120)
                .blockBorderWidth(20)
                .blockBorderColor('#8000ff00')
                .onChange(
                  (newValue: number, mode: SliderChangeMode) => {
                    this.GG = Number(newValue.toFixed(2));
                    mode = 2;
                    this.RGBA =
                      'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.RGB = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 0.2 + ')'
                    let A: string = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 1 + ')'
                    this.blurColor = new LinearGradient([{ color: this.RGB, offset: 0.2 }, { color: A, offset: 0.8 }])
                    let Red: string =
                      'rgba(' + 255 + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    let GB: string =
                      'rgba(' + 0 + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.blurRedColor = new LinearGradient([{ color: GB, offset: 0.2 }, { color: Red, offset: 0.8 }])
                    //let Green:string = 'rgba(' + this.RR + ',' + 255 + ',' + this.BB + ',' + (this.AA / 255).toFixed(2)  + ')'
                    //let RB:string = 'rgba(' + this.RR + ',' +0+ ',' + this.BB + ',' + (this.AA / 255).toFixed(2)  + ')'
                    //this.blurGreenColor= new LinearGradient([{ color: RB, offset: 0.2 }, { color: Green, offset: 0.8}])
                    let Blue: string =
                      'rgba(' + this.RR + ',' + this.GG + ',' + 255 + ',' + (this.AA / 255).toFixed(2) + ')'
                    let RG: string =
                      'rgba(' + this.RR + ',' + this.GG + ',' + 0 + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.blurBlueColor = new LinearGradient([{ color: RG, offset: 0.2 }, { color: Blue, offset: 0.8 }])
                    this.bgc = this.RGBA
                  }
                )
              TextInput({ text: this.GG.toString(), placeholder: '绿' })
                .padding(0)
                .height('80%')
                .width('20%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .underlineColor(0x333333)
                .type(InputType.Number)
                .maxLength(3)
                .enterKeyType(EnterKeyType.Done)
                .onChange((value: string) => {
                  let newValue: number = Number(value);
                  if (newValue > 255) {
                    newValue = 255;
                  } else if (newValue < 0) {
                    newValue = 0;
                  }
                  this.GG = newValue;
                  this.RGBA = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                  this.RGB = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 0.2 + ')'
                  this.bgc = this.RGBA
                })
            }
            .layoutWeight(1)
            .width('100%')

            Row() {
              Text('B:')
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .padding(0)
                .height('80%')
                .width('10%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
              Slider({
                value: this.BB,
                min: 0,
                max: 255,
                style: SliderStyle.OutSet
              })
                .width('70%')
                .trackColor(this.blurBlueColor)
                .selectedColor('rgba(0,0,0,0)')
                .blockColor('#333')
                .trackThickness(120)
                .blockBorderWidth(20)
                .blockBorderColor('#800000ff')
                .onChange(
                  (newValue: number, mode: SliderChangeMode) => {
                    this.BB = Number(newValue.toFixed(2));
                    mode = 2;
                    this.RGBA =
                      'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.RGB = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 0.2 + ')'
                    let A: string = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 1 + ')'
                    this.blurColor = new LinearGradient([{ color: this.RGB, offset: 0.2 }, { color: A, offset: 0.8 }])
                    let Red: string =
                      'rgba(' + 255 + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    let GB: string =
                      'rgba(' + 0 + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.blurRedColor = new LinearGradient([{ color: GB, offset: 0.2 }, { color: Red, offset: 0.8 }])
                    let Green: string =
                      'rgba(' + this.RR + ',' + 255 + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    let RB: string =
                      'rgba(' + this.RR + ',' + 0 + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                    this.blurGreenColor =
                      new LinearGradient([{ color: RB, offset: 0.2 }, { color: Green, offset: 0.8 }])
                    //let Blue:string = 'rgba(' + this.RR + ',' + this.GG + ',' + 255 + ',' +  (this.AA / 255).toFixed(2) + ')'
                    //let RG:string = 'rgba(' + this.RR + ',' + this.GG + ',' + 0 + ',' +  (this.AA / 255).toFixed(2) + ')'
                    //this.blurBlueColor= new LinearGradient([{ color: RG, offset: 0.2 }, { color: Blue, offset: 0.8 }])
                    this.bgc = this.RGBA
                  }
                )
              TextInput({ text: this.BB.toString(), placeholder: '蓝' })
                .padding(0)
                .height('80%')
                .width('20%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .underlineColor(0x333333)
                .type(InputType.Number)
                .maxLength(3)
                .enterKeyType(EnterKeyType.Done)
                .onChange((value: string) => {
                  let newValue: number = Number(value);
                  if (newValue > 255) {
                    newValue = 255;
                  } else if (newValue < 0) {
                    newValue = 0;
                  }
                  this.BB = newValue;
                  this.RGBA =
                    'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + Number((this.AA / 255).toFixed(2)) + ')';
                  this.bgc = this.RGBA
                })
            }
            .layoutWeight(1)
            .width('100%')


            Row() {
              Text('A:')
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .padding(0)
                .height('80%')
                .width('10%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
              Slider({
                value: this.AA,
                min: 0,
                max: 255,
                style: SliderStyle.OutSet
              })
                .width('70%')
                .trackColor(this.blurColor)
                .selectedColor('rgba(0,0,0,0)')
                .blockColor('#333')
                .trackThickness(120)
                .blockBorderWidth(20)
                .blockBorderColor(this.RGBA)
                .onChange(
                  (newValue: number, mode: SliderChangeMode) => {
                    this.AA = newValue;
                    mode = 2;
                    this.RGBA =
                      'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + (newValue / 255).toFixed(2) + ')'
                    //let A:string = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 1 + ')'
                    //this.RGB = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 0.2 + ')'
                    //this.blurColor= new LinearGradient([{ color: this.RGB, offset: 0.2 }, { color: A, offset: 0.8 }])
                    let Red: string =
                      'rgba(' + 255 + ',' + this.GG + ',' + this.BB + ',' + (newValue / 255).toFixed(2) + ')'
                    let GB: string =
                      'rgba(' + 0 + ',' + this.GG + ',' + this.BB + ',' + (newValue / 255).toFixed(2) + ')'
                    this.blurRedColor = new LinearGradient([{ color: GB, offset: 0.2 }, { color: Red, offset: 0.8 }])
                    let Green: string =
                      'rgba(' + this.RR + ',' + 255 + ',' + this.BB + ',' + (newValue / 255).toFixed(2) + ')'
                    let RB: string =
                      'rgba(' + this.RR + ',' + 0 + ',' + this.BB + ',' + (newValue / 255).toFixed(2) + ')'
                    this.blurGreenColor =
                      new LinearGradient([{ color: RB, offset: 0.2 }, { color: Green, offset: 0.8 }])
                    let Blue: string =
                      'rgba(' + this.RR + ',' + this.GG + ',' + 255 + ',' + (newValue / 255).toFixed(2) + ')'
                    let RG: string =
                      'rgba(' + this.RR + ',' + this.GG + ',' + 0 + ',' + (newValue / 255).toFixed(2) + ')'
                    this.blurBlueColor = new LinearGradient([{ color: RG, offset: 0.2 }, { color: Blue, offset: 0.8 }])
                    this.bgc = this.RGBA
                  }
                )
              TextInput({ text: this.AA.toString(), placeholder: '透明度' })
                .padding(0)
                .height('80%')
                .width('20%')
                .fontColor($r("app.color.FontIcon_Fore1"))
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .underlineColor(0x333333)
                .type(InputType.Number)
                .maxLength(3)
                .enterKeyType(EnterKeyType.Done)
                .onChange((value: string) => {
                  let newValue: number = Number(value);
                  if (newValue > 255) {
                    newValue = 255;
                  } else if (newValue < 0) {
                    newValue = 0;
                  }
                  this.AA = newValue;
                  this.RGBA =
                    'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + Number((this.AA / 255).toFixed(2)) + ')';
                  this.bgc = this.RGBA
                })
            }
            .layoutWeight(1)
            .width('100%')

            Row() {
              Button() {
                Text('开始').fontColor($r("app.color.control_fc_1"))
              }
              .backgroundColor($r("app.color.control_bgc_1"))
              .height('90%')
              .aspectRatio(2)
              .padding(0)
              .margin(0)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
              .onClick(() => {
                this.RR = Random(0, 255, true)
                this.GG = Random(0, 255, true)
                this.BB = Random(0, 255, true)
                this.AA = Random(0, 255, false)
                this.RGBA = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                this.RGB = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 0.2 + ')'
                let A: string = 'rgba(' + this.RR + ',' + this.GG + ',' + this.BB + ',' + 1 + ')'
                this.blurColor = new LinearGradient([{ color: this.RGB, offset: 0.2 }, { color: A, offset: 0.8 }])
                let Red: string = 'rgba(' + 255 + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                let GB: string = 'rgba(' + 0 + ',' + this.GG + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                this.blurRedColor = new LinearGradient([{ color: GB, offset: 0.2 }, { color: Red, offset: 0.8 }])
                let Green: string =
                  'rgba(' + this.RR + ',' + 255 + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                let RB: string = 'rgba(' + this.RR + ',' + 0 + ',' + this.BB + ',' + (this.AA / 255).toFixed(2) + ')'
                this.blurGreenColor = new LinearGradient([{ color: RB, offset: 0.2 }, { color: Green, offset: 0.8 }])
                let Blue: string =
                  'rgba(' + this.RR + ',' + this.GG + ',' + 255 + ',' + (this.AA / 255).toFixed(2) + ')'
                let RG: string = 'rgba(' + this.RR + ',' + this.GG + ',' + 0 + ',' + (this.AA / 255).toFixed(2) + ')'
                this.blurBlueColor = new LinearGradient([{ color: RG, offset: 0.2 }, { color: Blue, offset: 0.8 }])
                this.bgc = this.RGBA
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .aspectRatio(1)
          .borderRadius(24)
          .backgroundColor($r("app.color.Comp_Bg1"))
        }
      }
    }
  }
}

export default RandomColors