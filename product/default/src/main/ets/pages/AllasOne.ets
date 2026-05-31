import {BaGuaCardDisplay} from '../form_display/BaGuaCardDisplay'
import {ABCDCardDisplay} from '../form_display/ABCDCardDisplay'
import {BlessingMuyuCardDisplay} from '../form_display/BlessingMuyuCardDisplay'
import {FlipCoinCardDisplay} from '../form_display/FlipCoinCardDisplay'
import {RandomColorsCardDisplay} from '../form_display/RandomColorsCardDisplay'
import {RollDiceCardDisplay} from '../form_display/RollDiceCardDisplay'
import RollWheelCard from '../form_cards/RollWheelCard'

import { AddFormMenuItem, promptAction } from '@kit.ArkUI'
import { formBindingData } from '@kit.FormKit'

const BUNDLE = 'ydy.App.EasyRandom'
const FORM_ABILITY = 'DefaultFormAbility'
const MODULE_NAME = 'default'
//此页面静态文本存储位置 AppScope page_card_text.json资源文件中
@Entry
@Component
struct AllasOne {
  private readonly cardRadius = 24
  @StorageLink('cardAddedToDesktop') cardAddedToDesktop: boolean = false

  @Builder AddFormMenu(formName: string, compId: string, dim: number) {

    Menu() {
      AddFormMenuItem(
        {
          bundleName: BUNDLE,
          abilityName: FORM_ABILITY,
          parameters: {
            'ohos.extra.param.key.form_dimension': dim,
            'ohos.extra.param.key.form_name': formName,
            'ohos.extra.param.key.module_name': MODULE_NAME
          }
        },
        compId,
        {
          formBindingData: formBindingData.createFormBindingData({}),
          callback: (error: BusinessError, formId: string) => {
            if (error?.code === 0) {
              this.cardAddedToDesktop = true
              promptAction.showToast({ message: $r("app.string.toast_add_form_success") })
            } else {
              promptAction.showToast({ message: $r("app.string.toast_add_form_fail") })
            }
          }
        }
      )
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column() {
          GridRow({
            columns: {
              sm: 4,
              md: 8,
              lg: 12
            },
            gutter: 24
          }) {

            //八卦
            GridCol({
              span: 2,
              offset: 0
            }) {
              Column() {
                BaGuaCardDisplay()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_bagua')
                Row() {
                  Text($r("app.string.BaGuaCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(5)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/12)
            .bindContextMenu(this.AddFormMenu('BaGuaCard', 'card_bagua', 2), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

            //硬币
            GridCol({
              span: 2,
              offset: 0
            }) {
              Column() {
                FlipCoinCardDisplay()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_flipCoin')
                Row() {
                  Text($r("app.string.FlipCoinCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(5)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/12)
            .bindContextMenu(this.AddFormMenu('FlipCoinCard', 'card_flipCoin', 2), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

            //骰子
            GridCol({
              span: 2,
              offset: 0
            }) {
              Column() {
                RollDiceCardDisplay()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_rollDice')
                Row() {
                  Text($r("app.string.RollDiceCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(5)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/12)
            .bindContextMenu(this.AddFormMenu('RollDiceCard', 'card_rollDice', 2), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

            //颜色
            GridCol({
              span: 2,
              offset: 0
            }) {
              Column() {
                RandomColorsCardDisplay()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_randomColors')
                Row() {
                  Text($r("app.string.RandomColorsCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(5)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/12)
            .bindContextMenu(this.AddFormMenu('RandomColorsCard', 'card_randomColors', 2), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

            //转盘 (小)
            GridCol({
              span: 2,
              offset: 0
            }) {
              Column() {
                RollWheelCard()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_rollWheel_sm')
                Row() {
                  Text($r("app.string.RollWheelCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(5)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/12)
            .bindContextMenu(this.AddFormMenu('RollWheelCard', 'card_rollWheel_sm', 2), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

            //木鱼
            GridCol({
              span: 2,
              offset: 0
            }) {
              Column() {
                BlessingMuyuCardDisplay()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_blessingMuyu')
                Row() {
                  Text($r("app.string.BlessingMuyuCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(5)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/12)
            .bindContextMenu(this.AddFormMenu('BlessingMuyuCard', 'card_blessingMuyu', 2), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

            //ABCD
            GridCol({
              span: 2,
              offset: 0
            }) {
              Column() {
                ABCDCardDisplay()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_ABCD')
                Row() {
                  Text($r("app.string.ABCDCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(5)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/12)
            .bindContextMenu(this.AddFormMenu('ABCDCard', 'card_ABCD', 2), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

            //转盘 (大)
            GridCol({
              span: 4,
              offset: 0
            }) {
              Column() {
                RollWheelCard()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor($r("app.color.Comp_Bg1"))
                  .borderRadius(this.cardRadius)
                  .clip(true)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
                  .id('card_rollWheel_lg')
                Row() {
                  Text($r("app.string.RollWheelCard_display_name"))
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .fontColor($r("app.color.FontIcon_Fore1"))
                }
                .width('100%')
                .aspectRatio(10)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height('100%')
            }
            .aspectRatio(10/11)
            .bindContextMenu(this.AddFormMenu('RollWheelCard', 'card_rollWheel_lg', 4), ResponseType.LongPress, {
              placement: Placement.TopLeft
            })

          }
          .padding(24)
          // .backgroundColor($r("app.color.Comp_Bg2"))
          .width('100%')
        }
      }
      .height('100%')
      .width('100%')
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)


      .padding({ top: $r("app.float.header_height") ,bottom:$r('app.float.footer_height')})


      // 悬浮提示 —— 首次添加卡片成功后消失并持久化
      if (!this.cardAddedToDesktop) {
        Text($r("app.string.allasone_hint"))
          .fontSize(14)
          .fontColor($r("app.color.FontIcon_Fore1"))
          .textAlign(TextAlign.Center)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .borderRadius(20)
          .backgroundColor($r("app.color.hint_bg"))
          .backdropBlur(12)
          .border({
            width: 0.5,
            color: $r("app.color.hint_border"),
            style: BorderStyle.Solid
          })
          .shadow({
            radius: 24,
            color: $r("app.color.hint_shadow"),
            offsetY: 6
          })
          .margin({ bottom:120, left: 24, right: 24 })
          .transition(
            TransitionEffect.asymmetric(
              // 进场：从下方淡入上浮
              TransitionEffect.OPACITY
                .animation({ duration: 500, curve: Curve.EaseOut })
                .combine(TransitionEffect.translate({ y: 24 })
                  .animation({ duration: 500, curve: Curve.EaseOut })),
              // 出场：向上淡出消失
              TransitionEffect.OPACITY
                .animation({ duration: 300, curve: Curve.EaseIn })
                .combine(TransitionEffect.translate({ y: -20 })
                  .animation({ duration: 300, curve: Curve.EaseIn }))
            )
          )
      }
    }

    .backgroundColor($r("app.color.Comp_Bg3"))
    .height('100%')
    .width('100%')
  }
}
export default AllasOne
