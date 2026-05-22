import BaGuaCard from '../form_cards/BaGuaCard'
import BlessingMuyuCard from '../form_cards/BlessingMuyuCard'
import FlipCoinCard from '../form_cards/FlipCoinCard'
import RandomColorsCard from '../form_cards/RandomColorsCard'
import RollDiceCard from '../form_cards/RollDiceCard'
import RollWheelCard from '../form_cards/RollWheelCard'

import { AddFormMenuItem } from '@kit.ArkUI';
import { formBindingData } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, } from '@kit.ArkUI'

const tag = 'AddFormMenuItem';
@Preview
@Entry
@Component
struct AllasOneTest {
   private readonly  titleFontColor = 0x333333
  private readonly  titleFontSize = 16
  private readonly  cardBorderRadius =24


  @Builder
  MyMenu(target:string,compId:string,size?:number) {
    Menu() {
      AddFormMenuItem(
        {
          bundleName: 'com.atomicservice.5765880207854873613', // 包名
          abilityName: 'EntryFormAbility', // 模块ability名称
          parameters: {
            'ohos.extra.param.key.form_dimension': size || 2,
            'ohos.extra.param.key.form_name': target,
            'ohos.extra.param.key.module_name': 'entry'
          },
        },
        compId,
        {
          formBindingData: formBindingData.createFormBindingData({}),
          // formBindingData: formBindingData.createFormBindingData({ data: 'share' }),
          callback: (error, formId) => {
            hilog.info(0x3900, tag, `callback info：error = ${JSON.stringify(error)}, formId = ${formId}`);
            if (error?.code === 0) {
              hilog.info(0x3900, tag, "添加至桌面成功");
              promptAction.showToast({
                message: '添加至桌面成功'
              })
            } else {
              hilog.info(0x3900, tag, "添加至桌面失败，请尝试其它添加方式");
              promptAction.showToast({
                message: '添加至桌面失败，请尝试其它添加方式'
              })
            }
          },
          style: {
            // options: {
            //   startIcon: $r("app.media.icon"), // 菜单图标,可以自己提供。系统默认采用"sys.media.ic_public_add"
            //   content: "添加到桌面",  // 菜单内容，可以自己提供。默认使用"sys.string.ohos_add_form_to_desktop"
            //   endIcon: $r("app.media.icon") // 菜单图标，可以自己提供
            // }
          }
        }
      )
    }
  }
  build() {
    Scroll() {
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
            BaGuaCard()        .id('addforms@d46313145')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor(0xffffff)
              .borderRadius(this.cardBorderRadius)
              .clip(true)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            Row() {
              Text($r("app.string.BaGuaCard_display_name"))
                .textAlign(TextAlign.Center)
                .fontSize(this.titleFontSize)
                .fontColor(this.titleFontColor)
                .border({ style: BorderStyle.Solid, width: 1, color: 0xfffffff })
            }
            .width('100%')
            .aspectRatio(5)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

            //.backgroundColor(0x00ff00)
          }
          .width('100%')
          .height('100%')

        }
        .aspectRatio(10 / 12)
        .bindContextMenu(this.MyMenu('BaGuaCard','addforms@d46313145'), ResponseType.LongPress, {
          placement: Placement.TopLeft
        })

        //硬币
        GridCol({
          span: 2,
          offset: 0
        }) {
          Column() {
            FlipCoinCard()     .id('addforms@d46313146')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor(0xffffff)
              .borderRadius(this.cardBorderRadius)
              .clip(true)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            Row() {
              Text($r("app.string.FlipCoinCard_display_name"))
                .textAlign(TextAlign.Center)
                .fontSize(this.titleFontSize)
                .fontColor(this.titleFontColor)
                .border({ style: BorderStyle.Solid, width: 1, color: 0xfffffff })
            }
            .width('100%')
            .aspectRatio(5)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
        .aspectRatio(10 / 12)
        .bindContextMenu(this.MyMenu('FlipCoinCard','addforms@d46313146'), ResponseType.LongPress, {
          placement: Placement.TopLeft
        })

        //骰子
        GridCol({
          span: 2,
          offset: 0
        }) {
          Column() {
            RollDiceCard() .id('addforms@d46313147')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor(0xffffff)
              .borderRadius(this.cardBorderRadius)
              .clip(true)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            Row() {
              Text($r("app.string.RollDiceCard_display_name"))
                .textAlign(TextAlign.Center)
                .fontSize(this.titleFontSize)
                .fontColor(this.titleFontColor)
                .border({ style: BorderStyle.Solid, width: 1, color: 0xfffffff })
            }
            .width('100%')
            .aspectRatio(5)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
        .aspectRatio(10 / 12)
        .bindContextMenu(this.MyMenu('RollDiceCard','addforms@d46313147'), ResponseType.LongPress, {
          placement: Placement.TopLeft
        })

        //颜色
        GridCol({
          span: 2,
          offset: 0
        }) {
          Column() {
            RandomColorsCard() .id('addforms@d46313148')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor(0xffffff)
              .borderRadius(this.cardBorderRadius)
              .clip(true)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            Row() {
              Text($r("app.string.RandomColorsCard_display_name"))
                .textAlign(TextAlign.Center)
                .fontSize(this.titleFontSize)
                .fontColor(this.titleFontColor)
                .border({ style: BorderStyle.Solid, width: 1, color: 0xfffffff })
            }
            .width('100%')
            .aspectRatio(5)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
        .aspectRatio(10 / 12)
        .bindContextMenu(this.MyMenu('RandomColorsCard','addforms@d46313148'), ResponseType.LongPress, {
          placement: Placement.TopLeft
        })

        //转盘
        GridCol({
          span: 2,
          offset: 0
        }) {
          Column() {
            RollWheelCard() .id('addforms@d46313149')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor(0xffffff)
              .borderRadius(this.cardBorderRadius)
              .clip(true)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            Row() {
              Text($r("app.string.RollWheelCard_display_name"))
                .textAlign(TextAlign.Center)
                .fontSize(this.titleFontSize)
                .fontColor(this.titleFontColor)
                .border({ style: BorderStyle.Solid, width: 1, color: 0xfffffff })
            }
            .width('100%')
            .aspectRatio(5)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
        .aspectRatio(10 / 12)
        .bindContextMenu(this.MyMenu('RollWheelCard','addforms@d46313149'), ResponseType.LongPress, {
          placement: Placement.TopLeft
        })

        //木鱼
        GridCol({
          span: 2,
          offset: 0
        }) {
          Column() {
            BlessingMuyuCard() .id('addforms@d46313150')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor(0xffffff)
              .borderRadius(this.cardBorderRadius)
              .clip(true)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            Row() {
              Text($r("app.string.BlessingMuyuCard_display_name"))
                .textAlign(TextAlign.Center)
                .fontSize(this.titleFontSize)
                .fontColor(this.titleFontColor)
                .border({ style: BorderStyle.Solid, width: 1, color: 0xfffffff })
            }
            .width('100%')
            .aspectRatio(5)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
        .aspectRatio(10 / 12)
        .bindContextMenu(this.MyMenu('RollBlessingsCard','addforms@d46313150'), ResponseType.LongPress, {
          placement: Placement.TopLeft
        })

        //转盘
        GridCol({
          span: 4,
          offset: 0
        }) {
          Column() {
            RollWheelCard() .id('addforms@d46313151')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor(0xffffff)
              .borderRadius(this.cardBorderRadius)
              .clip(true)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            Row() {
              Text($r("app.string.RollWheelCard_display_name"))
                .textAlign(TextAlign.Center)
                .fontSize(this.titleFontSize)
                .fontColor(this.titleFontColor)
                .border({ style: BorderStyle.Solid, width: 1, color: 0xfffffff })
            }
            .width('100%')
            .aspectRatio(10)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
        .aspectRatio(10 / 11)

      }
      .padding(24)
      .backgroundColor(0xf1f3f5)
      .width('100%')
      .bindContextMenu(this.MyMenu('RollWheelCard','addforms@d46313151',4), ResponseType.LongPress, {
        placement: Placement.TopLeft
      })
    }
    .height('100%')
    .width('100%')
    .scrollable(ScrollDirection.Vertical)
  }
}

