import { BreakpointState, BreakpointSystem, Random } from '@ohos/common';
import{RollWheel}from './RollWheel'
import { Roll, defaultRolls, initRollsData } from './RollDataManager';
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
      RollWheelsShow({ breakpoint: this.currentBreakpoint })
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
struct RollWheelsShow {
  @StorageLink('allRolls') @Watch('onDataListChange') dataList: Roll[] = defaultRolls
  @Prop breakpoint: BreakpointState<string>
  @State title: string = this.dataList.length > 0 ? this.dataList[0].rollName : ''
  @State rotateAngle: number = 0
  @State isRoll: boolean = false
  @State duration: number = 0
  @State swiperIndex: number = 0
  @State loveIndex: number = -1
  @State showPoint: boolean = true
  @State isSheetShow: boolean = false
  @State dataVersion: number = 0
  private swiperController: SwiperController = new SwiperController()

  aboutToAppear() {
    if (this.dataList.length > 0) {
      this.title = this.dataList[0].rollName
    }
  }

  onDataListChange() {
    this.dataVersion++
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
        ForEach(this.dataList, (roll: Roll) => {
          Row() {
            RollWheel({ data: roll })
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

        }, (roll: Roll) => `${roll.index}_v${this.dataVersion}`)

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
      .onChange((newIndex: number) => {
        this.swiperIndex = newIndex
        if (newIndex < this.dataList.length) {
          this.title = this.dataList[newIndex].rollName
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
      showClose: false,
      onDisappear: () => {
        // 重新从 Preferences 加载数据到 AppStorage，使主页面转盘同步编辑变更
        initRollsData(getContext(this).getApplicationContext())
        if (this.swiperIndex < this.dataList.length) {
          this.title = this.dataList[this.swiperIndex].rollName
        }
      }
    })
  }
}



export default RollPage

