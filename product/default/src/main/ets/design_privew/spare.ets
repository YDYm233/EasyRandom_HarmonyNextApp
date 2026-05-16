@Preview
@Component
struct  spare{
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
build(){
  Column(){
    Column() {
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
      .margin('5%')
      .aspectRatio(1)
      .clip(true)
      .borderRadius('50%')
      .animation({ duration: this.duration})
      .rotate({ angle: this.angle })
    }
  }
}}

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
