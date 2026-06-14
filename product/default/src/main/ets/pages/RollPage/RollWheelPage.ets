import { BreakpointState, BreakpointSystem } from '@ohos/system-utils';
import { Random } from '@ohos/basic-utils';
import{RollWheel}from './RollWheel'
import { Roll, RollItem, defaultRolls, initRollsData } from './RollDataManager';
import { RollEditSheet } from './RollEditor';
import { VibratorManager } from '@ohos/system-utils';
import { formProvider, formInfo } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { ApiVersionUtil } from '@ohos/system-utils'
import { promptAction } from '@kit.ArkUI'
import { RollWheelCardAddSheet } from './RollWheelCardAddSheet'

@Component
struct RollPage {
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @StorageProp('statusBarHeight') statusBarHeight: number = 0
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
    // .padding({ left:12, right:12 })
    .padding({ left:18, right:18,top: $r("app.float.header_height") ,bottom:$r('app.float.footer_height')})
    // .margin({bottom:this.statusBarHeight })
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
  @State showPoint: boolean = true
  @State isSheetShow: boolean = false
  @State dataVersion: number = 0
  @State sheetType: 'edit' | 'cardAdd' = 'edit' // 弹出层类型
  @State showResults: string[] = Array(defaultRolls.length).fill('') // 存储每个转盘的结果
  @State hasInteracted: boolean = false // 是否已交互过（用于显示"点击以开始"提示）
  private swiperController: SwiperController = new SwiperController()

  aboutToAppear() {
    if (this.dataList.length > 0) {
      this.title = this.dataList[0].rollName
      // showResults数组已在定义时用defaultRolls.length初始化
      // 如果dataList与defaultRolls长度不同，onDataListChange会处理
    }
  }

  onDataListChange() {
    this.dataVersion++
    // 更新showResults数组，保持与dataList长度一致
    const newResults = new Array<string>(this.dataList.length).fill('')
    // 保留已有的结果（如果索引有效）
    for (let i: number = 0; i < Math.min(this.showResults.length, this.dataList.length); i++) {
      newResults[i] = this.showResults[i]
    }
    this.showResults = newResults
    
    if (this.swiperIndex < this.dataList.length) {
      this.title = this.dataList[this.swiperIndex].rollName
    } else if (this.dataList.length > 0) {
      this.swiperIndex = 0
      this.title = this.dataList[0].rollName
    } else {
      this.title = ''
    }
  }

  // 计算转盘结果（参考手表端 WearRollWheel.calculateResult）
  private calculateResult(finalAngle: number): void {
    const currentIndex = this.swiperIndex
    const roll = this.dataList[currentIndex]
    if (!roll || !roll.rollItems || roll.rollItems.length === 0) {
      return
    }

    const items = roll.rollItems
    const totalWeight = items.reduce((sum: number, item: RollItem) => sum + item.weight, 0)
    if (totalWeight <= 0) {
      return
    }

    // 指针在 12 点钟方向，canvas 中对应 -90°（或 270°）
    // 转盘旋转 finalAngle 度，指针等效于反向移动
    let pointerDeg = (-90 - finalAngle) % 360
    if (pointerDeg < 0) {
      pointerDeg += 360
    }

    // 扇区边界（与 RollWheel 绘制逻辑保持一致）
    // 第一个扇区起始角 = -w0/totalW * 180 + 90
    let sectorStartDeg = -(items[0].weight / totalWeight) * 180 + 90
    let hitIndex = 0

    for (let i: number = 0; i < items.length; i++) {
      const sectorSizeDeg = (items[i].weight / totalWeight) * 360
      const sectorEndDeg = sectorStartDeg + sectorSizeDeg

      // 归一化到 [0, 360)
      const startNorm = ((sectorStartDeg % 360) + 360) % 360
      const endNorm = ((sectorEndDeg % 360) + 360) % 360

      if (startNorm <= endNorm) {
        // 扇区不跨越 0°
        if (pointerDeg >= startNorm && pointerDeg < endNorm) {
          hitIndex = i
          break
        }
      } else {
        // 扇区跨越 360°/0°
        if (pointerDeg >= startNorm || pointerDeg < endNorm) {
          hitIndex = i
          break
        }
      }

      sectorStartDeg = sectorEndDeg
    }

    // 更新结果
    const newResults = [...this.showResults]
    newResults[currentIndex] = `${items[hitIndex].text}`
    this.showResults = newResults
  }

  @Builder
  sheetContent() {
    if (this.sheetType === 'edit') {
      RollEditSheet()
    } else {
      RollWheelCardAddSheet({
        currentRoll: this.dataList[this.swiperIndex],
        onClose: () => {
          this.isSheetShow = false
        }
      })
    }
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
          if (this.showResults[this.swiperIndex] && this.showResults[this.swiperIndex].length > 0) {
            // 状态3：已出结果
            Text(this.showResults[this.swiperIndex])
              .fontColor($r("app.color.Brand"))
              .fontWeight(FontWeight.Bold)
              .height('100%')
              .aspectRatio(3)
              .textAlign(TextAlign.Center)
          } else if (this.isRoll) {
            // 状态2：旋转中，显示转盘名称
            Text(this.dataList.length > 0 && this.swiperIndex < this.dataList.length ? this.dataList[this.swiperIndex].rollName : '')
              .fontColor(Color.Red)  // 改为红色测试
              .fontWeight(800)
              .height('100%')
              .aspectRatio(3)
              .textAlign(TextAlign.Center)
          } else if (!this.hasInteracted) {
            // 状态1：页面刚加载，未交互过
            Text('点击以开始')
              .fontColor(Color.Red)  // 改为红色测试
              .fontWeight(800)
              .height('100%')
              .aspectRatio(3)
              .textAlign(TextAlign.Center)
          } else {
            // 状态1b：已交互过，无结果时显示转盘名称
            Text(this.dataList.length > 0 && this.swiperIndex < this.dataList.length ? this.dataList[this.swiperIndex].rollName : '')
              .fontColor(Color.Red)  // 改为红色测试
              .fontWeight(800)
              .height('100%')
              .aspectRatio(3)
              .textAlign(TextAlign.Center)
          }
        }
        .height('100%')
        .aspectRatio(3)
        .layoutWeight(8)
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
              Image($r("app.media.pointer_xl"))
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
        this.hasInteracted = true;
      })
      .onChange((newIndex: number) => {
        this.swiperIndex = newIndex
        this.hasInteracted = true
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
              .fillColor($r("app.color.Brand"))
              .width('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .backgroundColor($r("app.color.Comp_Bg3"))
          .height('100%')
          .aspectRatio(1)
          .onClick(() => {
            // 获取当前展示的转盘数据
            const currentRoll = this.dataList[this.swiperIndex]
            if (!currentRoll) {
              return
            }

            // 将当前转盘数据序列化并保存到 Preferences，供 DefaultFormAbility 在 onAddForm 中读取
            try {
              const ctx = getContext(this).getApplicationContext()
              const pref = preferences.getPreferencesSync(ctx, { name: 'roll_wheel_card_pin' })
              pref.putSync('pinned_roll_data', JSON.stringify(currentRoll))
              pref.flushSync()
              hilog.info(0x0000, 'testTag',
                '[Pin按钮] 已保存转盘数据: %{public}s, 选项数: %{public}d',
                currentRoll.rollName, currentRoll.rollItems.length)

              // 显示保存成功提示
              promptAction.showToast({
                message: `已保存"${currentRoll.rollName}"到桌面卡片`,
                duration: 2000
              })

              // 检查API版本，决定使用哪种方式添加卡片到桌面
              const currentApiVersion = ApiVersionUtil.getCurrentApiVersion()
              hilog.info(0x0000, 'testTag', '[Pin按钮] 当前API版本: %{public}d', currentApiVersion)

              if (currentApiVersion >= 18) {
                // API 18及以上：使用 formProvider.openFormManager 打开卡片管理器
                const want: Want = {
                  bundleName: 'ydy.App.EasyRandom',
                  abilityName: 'DefaultFormAbility',
                  parameters: {
                    'ohos.extra.param.key.form_dimension': 2,
                    'ohos.extra.param.key.form_name': 'RollWheelCard',
                    'ohos.extra.param.key.module_name': 'default'
                  }
                }
                formProvider.openFormManager(want)
                hilog.info(0x0000, 'testTag', '[Pin按钮] formProvider.openFormManager 成功打开')
              } else {
                // API 18以下：显示卡片添加弹出层
                this.sheetType = 'cardAdd'
                this.isSheetShow = true
                hilog.info(0x0000, 'testTag', '[Pin按钮] API版本低于18，显示卡片添加弹出层')
              }
            } catch (e) {
              hilog.error(0x0000, 'testTag', '[Pin按钮] 异常: %{public}s', JSON.stringify(e))
              promptAction.showToast({
                message: '保存失败，请重试',
                duration: 2000
              })
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
            VibratorManager.vibrateRoll();
            this.duration = 1600
            this.isRoll = true;
            this.hasInteracted = true;
            
            // 清空当前转盘的结果
            const currentIndex = this.swiperIndex
            if (currentIndex >= 0 && currentIndex < this.showResults.length) {
              const newResults = [...this.showResults]
              newResults[currentIndex] = ''
              this.showResults = newResults
            }
            
            const finalAngle = Random(0, 360, true) + 360 * 18;
            this.rotateAngle = finalAngle;
            setTimeout(() => {
              this.isRoll = false;
              this.duration = 0;
              this.rotateAngle = finalAngle - 360 * 18
              VibratorManager.vibrateVictory();
              // 计算并显示结果
              this.calculateResult(finalAngle);
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
            this.sheetType = 'edit'
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
      height: this.sheetType === 'edit' ? SheetSize.FIT_CONTENT : 660,
      dragBar: this.sheetType === 'edit' && this.breakpoint.value === 'sm', // 编辑模式且手机端显示拖拽条
      showClose: this.sheetType === 'cardAdd' || this.breakpoint.value !== 'sm', // PC模式显示关闭按钮
      backgroundColor: this.sheetType === 'cardAdd' ? Color.Transparent : $r("app.color.Comp_Bg2"),
      blurStyle: this.sheetType === 'cardAdd' ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.COMPONENT_THICK,
      onDisappear: () => {
        if (this.sheetType === 'edit') {
          // 重新从 Preferences 加载数据到 AppStorage，使主页面转盘同步编辑变更
          initRollsData(getContext(this).getApplicationContext())
          if (this.swiperIndex < this.dataList.length) {
            this.title = this.dataList[this.swiperIndex].rollName
          }
        } else {
          hilog.info(0x0000, 'testTag', '[Pin按钮] 卡片添加弹出层关闭')
        }
      }
    })

  }
}



export default RollPage

