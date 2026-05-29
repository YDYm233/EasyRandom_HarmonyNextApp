import { Random } from '@ohos/common'
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { BreakpointState, BreakpointSystem } from '@ohos/common';

class Params {
  type: string

  constructor(tuple: string) {
    this.type = tuple
  }
}

@Entry
@Component
struct DevineBaGua {
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
            Text($r("app.string.page_bagua")).fontColor($r("app.color.FontIcon_Fore1"))
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
      // .height($r("app.float.header_height"))
      .padding({ top: this.statusBarHeight })
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
              md: 4,
              lg: 6
            },
            offset: {
              sm: 0,
              md: 2,
              lg: 3
            }
          }) {
            Row() {
              BaGuaBox().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)
        // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .padding({ top: $r("app.float.header_height") })
    }
    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}


@Component
  //阴爻
struct YinYao {
  build() {
    Row() {
      Row() {
      }.height('100%').width('40%').backgroundColor($r("app.color.Yin"))

      Row() {
      }.height('100%').width('20%').backgroundColor($r("app.color.Yang"))

      Row() {
      }.height('100%').width('40%').backgroundColor($r("app.color.Yin"))
    }
  }
}

@Preview
@Component
struct TaiJi {
  build() {
    Column() {
      Column().width('50%').height('100%').position({ left: 0, top: 0 }).backgroundColor($r("app.color.Yang"))
      Column().width('50%').height('100%').position({ right: 0, bottom: 0 }).backgroundColor($r("app.color.Yin"))

      Row() {
        Column()
          .width('20%')
          .aspectRatio(1)
          .margin('40%')
          .backgroundColor($r("app.color.Yin"))
          .borderRadius('50%')
      }
      .width('50%')
      .aspectRatio(1)
      .position({ left: '25%', top: 0 })
      .backgroundColor($r("app.color.Yang"))
      .borderRadius('50%')

      Row() {
        Column()
          .width('20%')
          .aspectRatio(1)
          .margin('40%')
          .backgroundColor($r("app.color.Yang"))
          .borderRadius('50%')
      }
      .width('50%')
      .aspectRatio(1)
      .position({ right: '25%', bottom: 0 })
      .backgroundColor($r("app.color.Yin"))
      .borderRadius('50%')
    }
    .width('100%')
    .aspectRatio(1)
    .border({ width: 0, color: $r("app.color.Comp_Bg2"), radius: '50%' })
    .clip(true)
  }
}

@Component
  //阳爻
struct YangYao {
  build() {
    Row() {
    }.height('100%').width('100%').backgroundColor($r("app.color.Yin"))
  }
}

@Component
struct Kan {
  build() {
    Column() {
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct Kun {
  build() {
    Column() {
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct Zhen {
  build() {
    Column() {
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct Xun {
  build() {
    Column() {
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct Qian {
  build() {
    Column() {
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct Dui {
  build() {
    Column() {
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct Gen {
  build() {
    Column() {
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct Li {
  build() {
    Column() {
      YangYao().layoutWeight(1)
      Row().layoutWeight(1)
      YinYao().layoutWeight(1)
      Row().layoutWeight(1)
      YangYao().layoutWeight(1)
    }.backgroundColor($r("app.color.Yang")).aspectRatio(4 / 3)
  }
}

@Component
struct BaGuaBox {
  readonly widthRate: number = 20
  readonly widthPer: string = this.widthRate.toString() + '%';
  readonly heightMargin: string = 3 + '%'
  readonly widthMargin: string = ((100 - this.widthRate) / 2).toString() + '%';
  public guas: Array<string> = ['太极', '坎', '坤', '震', '巽', '乾', '兑', '艮', '离']
  public angles: Array<number> = [180, 45, 270, 315, 135, 90, 225, 0];
  readonly duration: number = 2000;
  @State angle: number = 0;
  @State gua: string = ''
  @State isRoll: boolean = false;
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  @State customDialogId: number = 0

  showPopup() {
    promptAction.openCustomDialog({
      builder: () => {
        this.result()
      },
      showInSubWindow: false,
      offset: { dx: 5, dy: 5 },
      backgroundColor: 0xd9ffffff,
      cornerRadius: 24,
      //backgroundBlurStyle: BlurStyle.Regular,
      width: this.currentBreakpoint.value == 'sm' ? '80%' :
        (this.currentBreakpoint.value == 'md' ? '50%' : '30%'),
      //height: this.currentBreakpoint.value == 'sm' ? '40%' :
      // (this.currentBreakpoint.value == 'md' ? '50%' : '50%'),
    }).then((dialogId: number) => {
      this.customDialogId = dialogId
    })
  }

  @Builder
  result() {
    Column() {
      Row().layoutWeight(1)
      Row() {
        //'太极','坎', '坤', '震', '巽', '乾', '兑', '艮', '离']
        if (this.gua == '坎') {
          Kan()
        } else if (this.gua == '坤') {
          Kun()
        } else if (this.gua == '震') {
          Zhen()
        } else if (this.gua == '巽') {
          Xun()
        } else if (this.gua == '乾') {
          Qian()
        } else if (this.gua == '兑') {
          Dui()
        } else if (this.gua == '艮') {
          Gen()
        } else if (this.gua == '离') {
          Li()
        } else {
          Text('')
        }
      }
      .padding(36)
      .layoutWeight(3)

      Text(this.gua)
        .fontSize(48)
        .fontWeight(600)
        .layoutWeight(2)
        .fontColor($r("app.color.FontIcon_Fore1"))
    }
    .width('100%')
    .aspectRatio(1)
    .backgroundColor($r("app.color.FontIcon_Back2"))
  }

  build() {
    Column() {
      Row() {
        Row() {
          Row() {
            TaiJi()
              .width('40%').margin('30%').border({ width: 2, color: 0xf1f3f5, radius: '50%' })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: 0 })


          Row() {
            Kan()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[0] })


          Row() {
            Kun()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[1] })


          Row() {
            Zhen()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[2] })


          Row() {
            Xun()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[3] })


          Row() {
            Qian()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[4] })


          Row() {
            Dui()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[5] })


          Row() {
            Gen()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[6] })


          Row() {
            Li()
              .width(this.widthPer)
              .position({ y: this.heightMargin, x: this.widthMargin })
          }
          .width('100%')
          .height('100%')
          .position({ top: 0, left: 0 })
          .rotate({ angle: this.angles[7] })
        }
        .width('90%')
        .aspectRatio(1) // .animation({ duration: 1000,curve:Curve.Linear,playMode: PlayMode.Normal})
        .rotate({ z: 1, angle: this.angle })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r("app.color.Comp_Bg1"))
      .width('100%')
      .aspectRatio(1)
      .borderRadius(12)
      .clip(true)

      Row() {
        Button() {
          if (!this.isRoll) {
            Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold)
          } else {
            LoadingProgress()
          }
        }
        .enabled(!this.isRoll)
        .onClick(() => {
          this.isRoll = true;
          let index = Random(0, 7, true);
          //this.angle = Math.floor(this.angle/360)*360+(360-this.angles[index]) + 360 * 6;
          animateTo({
            duration: this.duration,
            iterations: 1,
            curve: Curve.Linear
          }, () => {
            this.angle = Math.floor(this.angle / 360) * 360 + (360 - this.angles[index]) + 360 * 6;
          })

          console.log(index.toString())
          console.log(this.angle.toString() + ' ~~~ ' + (this.angle % 360).toString())
          setTimeout(() => {
            this.gua = this.guas[index+1];
            this.showPopup()
            console.log(this.gua)
            this.isRoll = false;
          }, this.duration)
        })
        .backgroundColor($r("app.color.Brand"))
        .height('80%')
        .aspectRatio(2)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      }.width('100%').justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center).aspectRatio(6)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    //.position({top:0,left:0})
    .width('100%')
    .aspectRatio(5 / 6)

  }
}
