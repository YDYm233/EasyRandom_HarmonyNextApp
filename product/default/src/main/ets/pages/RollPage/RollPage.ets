import { BreakpointState, BreakpointSystem, Random } from '@ohos/common';

import { Roll, RollItem, rolls } from '../../static_datas/rolls';
import { promptAction } from '@kit.ArkUI';
import { initRollsData } from './RollDataManager';
import { RollEditSheet } from './RollEditor';

@Entry
@Component
struct RollPage {
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
    // 初始化持久化转盘数据到 AppStorage
    initRollsData(getContext(this).getApplicationContext())
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().detach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }

  build() {
    Column() {
      PieChartsShow({ breakpoint: this.currentBreakpoint })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg3"))
    .padding({ left: 12, right: 12 })
  }
}


@Component
struct PieChartsShow {
  @StorageLink('allRolls') @Watch('onDataListChange') dataList: Roll[] = rolls
  @Prop breakpoint: BreakpointState<string>
  @State title: string = this.dataList.length > 0 ? this.dataList[0].rollName : ''
  @State rotateAngle: number = 0
  @State isRoll: boolean = false
  @State duration: number = 0
  @State swiperIndex: number = 0
  @State loveIndex: number = -1
  @State showPoint: boolean = true
  @State isSheetShow: boolean = false
  private swiperController: SwiperController = new SwiperController()

  aboutToAppear() {
    if (this.dataList.length > 0) {
      this.title = this.dataList[0].rollName
    }
  }

  onDataListChange() {
    if (this.swiperIndex < this.dataList.length) {
      this.title = this.dataList[this.swiperIndex].rollName
    } else if (this.dataList.length > 0) {
      this.swiperIndex = 0
      this.title = this.dataList[0].rollName
    } else {
      this.title = ''
    }
  }

  @Builder
  sheetContent() {
    RollEditSheet()
  }

  build() {
    Column() {
      Row() {
        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_pre")).fillColor($r("app.color.Brand")).width('75%').aspectRatio(1.4)
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .backgroundColor($r("app.color.Comp_Bg3"))
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
            .fontColor($r("app.color.FontIcon_Fore1"))
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
            Image($r("app.media.func_next")).fillColor($r("app.color.Brand")).width('75%').aspectRatio(1.4)
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .position({ right: 0 })
          .backgroundColor($r("app.color.Comp_Bg3"))
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

      // 转盘轮播区
      Swiper(this.swiperController) {
        ForEach(this.dataList, (item: Roll) => {
          Row() {
            PieChart({ data: item })
              .width('100%')
              .position({ top: 0, left: 0 })
              .rotate({
                angle: this.rotateAngle
              })
              .border({
                width: 0,
                color: $r("app.color.Cont_Bg1"),
                radius: '50%',
                style: BorderStyle.Solid
              })
              .animation({ duration: this.duration, curve: Curve.Ease })
            if (this.showPoint) {
              Image($r("app.media.needle"))
                .zIndex(8)
                .width('40%')
                .aspectRatio(1)
                .fillColor($r("app.color.FontIcon_Back1"))
                .position({ top: '30%', left: '30%' })
            }
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
        color: $r("app.color.Comp_Bg2"),
        radius: 10,
        style: BorderStyle.Dotted
      })
      .loop(true)
      .indicatorInteractive(true)
      .duration(1000)
      .itemSpace(0)
      .onClick(() => {
        this.showPoint = !this.showPoint;
      })
      .onChange((index: number) => {
        this.swiperIndex = index
        if (index < this.dataList.length) {
          this.title = this.dataList[index].rollName
        }
      })
      .onAnimationStart(() => {
        this.duration = 0;
        this.rotateAngle = 0;
      })

      // 底部控制区
      Row() {
        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_pin"))
              .fillColor(this.swiperIndex != this.loveIndex ? $r("app.color.Brand") : "#ffffff")
              .width('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .backgroundColor(this.swiperIndex != this.loveIndex ? $r("app.color.Comp_Bg3") :
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
              Text('开始').fontColor(Color.White).fontWeight(800)
            } else {
              LoadingProgress().color(Color.White).height('75%')
            }
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            this.duration = 1600
            this.isRoll = true;
            this.rotateAngle = Random(0, 360, true) + 360 * 18;
            setTimeout(() => {
              this.isRoll = false;
              this.duration = 0;
              this.rotateAngle = this.rotateAngle - 360 * 18
            }, this.duration);
          })
          .backgroundColor($r("app.color.Brand"))
          .height('100%')
          .aspectRatio(3)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        }
        .height('100%')
        .aspectRatio(3)
        .layoutWeight(4)

        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_plus")).fillColor($r("app.color.Brand")).width('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .position({ right: 0 })
          .backgroundColor($r("app.color.Comp_Bg3"))
          .height('100%')
          .aspectRatio(1)
          .onClick(() => {
            this.isSheetShow = true
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
    .backgroundColor($r("app.color.Comp_Bg1"))
    .constraintSize(this.breakpoint.value === 'sm' ? { maxWidth: 520, maxHeight: 668 } : { maxWidth: 400, maxHeight: 520 })
    .bindSheet($$this.isSheetShow, this.sheetContent(), {
      height: SheetSize.FIT_CONTENT,
      dragBar: true,
      onDisappear: () => {
        if (this.swiperIndex < this.dataList.length) {
          this.title = this.dataList[this.swiperIndex].rollName
        }
      }
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
          let ctx = this.context;
          const radius = ctx.width / 2;
          let list: Array<RollItem> = this.data.rollItems
          let totalWeight = list.reduce<number>((acc: number, single: RollItem) => acc + single.weight, 0);
          let startAngle = -list[0].weight / totalWeight * 180 + 90;

          list.forEach(single => {
            const endAngle: number = startAngle + (single.weight / totalWeight) * 360;
            const centerAngle = (startAngle + endAngle) / 2;
            ctx.beginPath();
            ctx.moveTo(radius, radius);
            ctx.arc(radius, radius, radius, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);
            ctx.closePath()
            ctx.fillStyle = single.color;
            ctx.fill();
            ctx.fillStyle = '#FFFFFF';
            ctx.textAlign = 'center';

            ctx.save()
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
            ctx.restore()

            startAngle = endAngle;
          })

          ctx.beginPath();
          ctx.moveTo(radius, radius);
          ctx.arc(radius, radius, radius / 10, -45, 275, false);
          ctx.closePath()
          ctx.fillStyle = 0xf1f3f5;
          ctx.fill();
        })
        .width('100%')
        .aspectRatio(1)

    }.width('100%').aspectRatio(1)
    .border({
      width: 10,
      color: $r("app.color.Comp_Bg3"),
      radius: '50%',
      style: BorderStyle.Solid
    })

  }
}

export default RollPage

export { rolls, Roll, RollItem }
