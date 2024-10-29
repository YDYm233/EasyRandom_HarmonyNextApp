import { Random } from '@ohos/common'
import Header from './Header'

@Entry
@Component
struct DevineBaGua {
  build() {
    Column() {
      Header({ title: '八卦' })
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
              BaGuaBox().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')  .padding({ top: $r("app.string.header_height") })
    }.height('100%').backgroundColor($r("app.color.view_bgc_2"))    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
    .border({ width: 0, color: 0x808080, radius: '50%' })
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
  public guas: Array<string> = ['太极','坎', '坤', '震', '巽',  '乾', '兑', '艮', '离']
  public angles: Array<number> = [180, 45, 270, 315, 135, 90, 225, 0];
  public duration: number = 2000;
  @State angle: number = 0;
  @State gua:string = '请开始'
  @State isRoll: boolean = false;
@Builder result(){
  Column() {
    Text(this.gua)
      .fontSize(66)
      .fontWeight(700)
      .layoutWeight(2)
    Row(){
      //'太极','坎', '坤', '震', '巽', '乾', '兑', '艮', '离']
      if(this.gua=='坎'){
        Kan()
      }
      else if(this.gua=='坤'){
        Kun()
      }
      else if(this.gua=='震'){
        Zhen()
      }
      else if(this.gua=='巽'){
        Xun()
      }
      else if(this.gua=='乾'){
        Qian()
      }
      else if(this.gua=='兑'){
        Dui()
      }
      else if(this.gua=='艮'){
        Gen()
      }
      else if(this.gua=='离'){
        Li()
      }
      else{
        Text('')
      }
    }
    .padding(16)
    .layoutWeight(3)

    Row() {
      Button() {
        if (!this.isRoll) {
          Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold)
        }
        else{
          LoadingProgress()
        }
      }
      .enabled(!this.isRoll)
      .onClick(() => {
        this.isRoll = true;
        let index =Random(0, 7, true);
        this.angle = (this.angle%360)*360+(360-this.angles[index]) + 360 * 8;
        console.log(index.toString())
        console.log((this.angle%360).toString())
        console.log(this.gua)
        setTimeout(() => {

          this.gua=this.guas[index+1];
          this.isRoll = false;
        }, this.duration)
      })
      .backgroundColor($r("app.color.control_bgc_1"))
      .height('100%')
      .aspectRatio(2)
      .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
    }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
  }.height('100%')
  .aspectRatio(1)
}
  build() {
          Column() {
            Image($r('app.media.BaGua'))
              .width('100%')
              .aspectRatio(1)
              .position({top:0,left:0})
              .animation({ duration: 2000,curve:Curve.Ease })
              .rotate({ angle: this.angle })
          }
          .position({top:0,left:0})
          .backgroundColor(0xffffff)
          .width('100%')
          .aspectRatio(1)
          .borderRadius(12)
          .clip(true)
          .onClick(() => {
            this.isRoll = true;
            let index =Random(0, 7, true);
            this.angle = (this.angle%360)*360+(360-this.angles[index]) + 360 * 8;
            console.log(index.toString())
            console.log((this.angle%360).toString())
            console.log(this.gua)
            setTimeout(() => {

              this.gua=this.guas[index+1];
              this.isRoll = false;
            }, this.duration)
          })
  }
}
