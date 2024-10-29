import { BreakpointState, BreakpointSystem, Random } from '@ohos/common';
import OptBoxs from './RollOpts';
import { Roll, RollItem, rolls } from '../../datas/rolls';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct RollPage {
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }
  build() {
    Scroll() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: 12 }) {
        GridCol({ span: { sm: 4, md: 4, lg: 4 }, offset: { sm: 0, md: 2, lg: 4 } }) {
          Row() {
            PieChartsShow()
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }          .width('100%')
      }
      .margin(this.currentBreakpoint.value=='sm'?12: 24)
    }.width('100%').height('100%').backgroundColor($r("app.color.view_bgc_2"))
  }
}


AppStorage.setOrCreate('allRolls', rolls);

@Component
struct PieChartsShow{
  @StorageLink('allRolls') dataList: Roll[] = rolls
  @State title: string = this.dataList[0].rollName
  @State rotateAngle: number = 0
  @State isRoll: boolean = false
  @State duration: number = 0
  @State swiperIndex: number = 0
  @State loveIndex: number = 0
  @State isSheetShow: boolean = false
  @State isDialogShow: boolean = false
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  private swiperController: SwiperController = new SwiperController()

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  neirong() {
    Column() {
      OptBoxs().width('100%').height('100%')
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_pre")).fillColor($r("app.color.control_fc_2")).width('75%').aspectRatio(1.4)
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .backgroundColor($r("app.color.control_bgc_2"))
          .height('100%')
          .aspectRatio(1)
          .onClick(() => {
            this.swiperController.showPrevious()
          })
        }
        .height('100%')
        .layoutWeight(1)

        Row() {
          Text(this.title)
            .fontColor(0x333333)
            .fontWeight(800)
            .height('100%')
            .aspectRatio(3)
            .textAlign(TextAlign.Center)
        }
        .height('100%')
        .aspectRatio(3)
        .layoutWeight(8)

        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_next")).fillColor($r("app.color.control_fc_2")).width('75%').aspectRatio(1.4)
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .position({ right: 0 })
          .backgroundColor($r("app.color.control_bgc_2"))
          .height('100%')
          .aspectRatio(1)
          .onClick(() => {
            this.swiperController.showNext()
          })
        }
        .height('100%')
        .layoutWeight(1)
      }.justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('11.11%')

      //组件轮播区
      Swiper(this.swiperController) {
        ForEach(this.dataList, (item: Roll) => {
          Row() {
            PieChart({ data: item })
              .width('100%')
              .position({top:0,left:0})
              .rotate({
                angle: this.rotateAngle
              })
              .border({
                width:0,
                color: 0xf1f3f5,
                radius: '50%',
                style: BorderStyle.Solid
              })
              .animation({ duration: this.duration, curve: Curve.Ease })
            Image($r("app.media.needle"))
              .zIndex(8)
              .width('40%')
              .aspectRatio(1)
              .fillColor($r('app.color.container_bgc_2'))
              .position({top:'30%',left:'30%'})
              //.backgroundImagePosition(Alignment.Center)
          }
          .width('90%')
          .margin('5%')
          .aspectRatio(1)

        }, (item: Roll) => item.index)

      }
      .width('100%')
      .aspectRatio(1)
      .border({
        width: 0,
        color: 0xfff,
        radius: 10,
        style: BorderStyle.Dotted
      })
     // .cachedCount(2)
      .loop(true)
      .indicatorInteractive(true)
      .duration(1000)
      .itemSpace(0)
      .onChange((index: number) => {
        this.swiperIndex = index
        this.title = this.dataList[index].rollName
      })
      .onAnimationStart(() => {
        this.duration = 0;
        this.rotateAngle = 0;
      })

      //底部控制区
      Row() {
        Row() {

          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_pin"))
              .fillColor(this.swiperIndex != this.loveIndex ? $r("app.color.control_fc_2") : "#ffffff")
              .width('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .backgroundColor(this.swiperIndex != this.loveIndex ? $r("app.color.control_bgc_2") :
          $r("app.color.control_bgc_1"))
          .height('100%')
          .aspectRatio(1)
          .onClick(() => {
            if (this.loveIndex != this.swiperIndex) {
              this.loveIndex = this.swiperIndex;
            } else {
              this.loveIndex = -1;
            }
          })
        }
        .height('100%')
        .layoutWeight(1)

        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: this.isRoll }) {
            if (this.isRoll == false) {
              Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(800)
            } else {
              LoadingProgress().color($r("app.color.control_fc_1")).height('75%')
            }
            //Image($r("app.media.page_icon1_selected")).fillColor($r("app.color.control_fc_1")).height('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            this.duration = 3000
            this.isRoll = true;
            this.rotateAngle = Random(0, 360, true) + 360 * 18;
            setTimeout(() => {
              this.isRoll = false;
              this.duration = 0;
              this.rotateAngle = this.rotateAngle - 360 * 18
            }, this.duration);
          })
          .backgroundColor($r("app.color.control_bgc_1"))
          .height('100%')
          .aspectRatio(3)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        }
        .height('100%')
        .aspectRatio(3)
        .layoutWeight(4)

        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_plus")).fillColor($r("app.color.control_fc_2")).width('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .position({ right: 0 })
          .backgroundColor($r("app.color.control_bgc_2"))
          .height('100%')
          .aspectRatio(1)

          .onClick(() => {

            //this.isSheetShow = true;
          promptAction.showToast({
            message: '功能完善中 未来将支持更改转盘选项'
          })

          })
        }
        .height('100%')
        .layoutWeight(1)
      }.justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('11.11%')
      .position({ left: 0, bottom: 0 })

    }
    .width('100%')
    .aspectRatio(7 / 9)
    .border({
      width: 0,
      color: 0xFF7A07,
      radius: '5.56%',
      style: BorderStyle.Dotted
    })
    .backgroundColor(0xffffff)
    .bindSheet($$this.isSheetShow, this.neirong(), {
      dragBar: true,
      blurStyle: BlurStyle.Thin,
      title: { title: '编辑' },
      enableOutsideInteractive: true,
      mode: SheetMode.EMBEDDED,
      borderWidth: 2,
      borderColor: 0x20000000,
      borderStyle: BorderStyle.Solid,
      height: this.currentBreakpoint.value == 'sm' ? SheetSize.LARGE : SheetSize.FIT_CONTENT,
      detents: this.currentBreakpoint.value == 'sm' ? [SheetSize.LARGE, SheetSize.MEDIUM] : null,
      preferType: this.currentBreakpoint.value == 'sm' ? SheetType.BOTTOM :
        (this.currentBreakpoint.value == 'md' ? SheetType.CENTER : SheetType.CENTER),
      width: this.currentBreakpoint.value == 'sm' ? '100%' : (this.currentBreakpoint.value == 'md' ? '50%' : '40%'),
    })
  }
}

@Component
struct PieChart {
  @Prop data: Roll
  @Prop boxWidth: number
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear(): void {

  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.context)
        .onReady(() => {
          let ctx = this.context;                                        //获取指定Canvas组件
          const radius =  ctx.width / 2;                           //获取半径（宽度）
          let list: Array<RollItem> = this.data.rollItems    //获取传入数据
          let totalWeight = list.reduce<number>((acc: number, single: RollItem) => acc + single.weight, 0);   //计算出总权重，子选项将根据与总权重的比例计算出角度。
          let startAngle = -list[0].weight / totalWeight * 180 + 90;                                                                           //此处角度控制开始渲染的位置，出于个人习惯我将第一个选项调整为正上方(默认角度为正右）

          list.forEach(single => {  //以下为循环绘制代码，其核心思想是通过绘制小扇形来拼接为圆形，通过权重/总权重*360便可以计算出合适的扇形角度。
            const endAngle: number = startAngle + (single.weight / totalWeight) * 360;    //计算占比角度方便绘制
            const centerAngle = (startAngle + endAngle) / 2;    //计算对称轴角度，以便确定绘制位置
            ctx.beginPath();                        //开始
            ctx.moveTo(radius, radius);   //中心点
            ctx.arc(radius, radius, radius, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);  //绘制扇形
            ctx.closePath()                    //闭合路径区域
            ctx.fillStyle = single.color; //选定背景颜色
            ctx.fill();                                //绘制背景颜色
            ctx.fillStyle = '#FFFFFF';    //指定文字颜色
            ctx.textAlign = 'center';     //指定对齐方式

            ctx.save()          //以下语句用于绘制扇形上的文字，该方案不适合较长文本，请根据实际需求使用或更改
            ctx.translate(radius, radius)
            ctx.rotate((centerAngle + 90) * Math.PI / 180)
            const texts: Array<string> = single.text.split('');
            const x = 0;
            const y = radius * 0.1 + (radius * 0.1 / texts.length);
            const lineHight = (radius - y) / (texts.length + 1)
            const fontSize = lineHight
            const font = fontSize.toString() + 'vp';
            ctx.font = font;
            for (let n: number = 0; n < texts.length; n++) {
              ctx.fillText(texts[n], x, (-radius + lineHight + y / 2 + n * lineHight), fontSize);
            }
            ctx.restore()       //文字绘制完毕

            startAngle = endAngle;  //每次循环完毕前刷新绘制角度
          })

          ctx.beginPath();  //以下语句用于绘制饼状图中央小圆，可省略
          ctx.moveTo(radius, radius);
          ctx.arc(radius, radius, radius/ 10, -45, 275, false);
          ctx.closePath()
          ctx.fillStyle = 0xf1f3f5;
          ctx.fill();
        })
        .width('100%')
        .aspectRatio(1)
      //将以上代码补全进上文PieChart()组件中

    }.width('100%').aspectRatio(1)
    .border({
      width: 10,
      color: 0xf1f3f5,
      radius: '50%',
      style: BorderStyle.Solid
    })

  }
}

export default RollPage

export { rolls, Roll, RollItem}