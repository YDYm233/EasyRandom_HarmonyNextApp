import RandomPage from './RandomPage'
import RollPage from './RollPage/RollPage'
import MorePage from './MorePage'
import AnswerPage from './AnswerPage'
import router from '@ohos.router';
import { BusinessError } from '@kit.BasicServicesKit';
@Entry({ routeName: 'Index' })
@Component
struct TabBar {
  @State currentIndex: number = 0;
  @State isWrap: boolean = true
  @State titles:Array<Resource>=[$r("app.string.page_name1"),$r("app.string.page_name2"),$r("app.string.page_name3"),$r("app.string.page_name4")]
  @State title:Resource = this.titles[0]
  private tabsController: TabsController = new TabsController();

  @Builder
  tabBarBuilder(
    title: Resource,
    targetIndex: number,
    selectedIcon: Resource,
    unselectIcon: Resource,
  ) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedIcon : unselectIcon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex===targetIndex?0x00beff:'rgba(0,0,0,0.6)')
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? 0x00beff: 'rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
    }
   // .border({ width: 1, color: '#ff0000', style: BorderStyle.Dotted })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })

  }

  build() {
    //头部内容显示
    Column() {
      GridRow() {
        GridCol({ span: { sm: 3, md: 2, lg: 1} }) {
          Row() {
           // Image($r("app.media.func_back")).height('24vp').width('24vp')
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }
        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text(this.title)
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24)
          }
          .width('100%')
          .height($r("app.string.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
          .onClick(()=>{
            router.pushUrl({
              url: 'SettingPage/SettingPage'
            }).then(() => {
              console.info("success.");
           }).catch((err: BusinessError) => {
              console.error(`err, code is ${err.code}, message is ${err.message}.`);
           })
          })
        }
      }
      .width('100%')
      .height($r("app.string.header_height"))
      .backgroundColor($r("app.color.view_bgc_1"))
      .zIndex(10)
      .margin({ top: $r("app.string.header_margin") })
      .position({ top: $r("app.string.header_margin") })

    //导航

      Tabs({
        barPosition: BarPosition.End,
        index: 0,
        controller: this.tabsController
      }) {

        TabContent() {
          RollPage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name1'), 0, $r('app.media.page_icon1_selected'),
          $r('app.media.page_icon1')));

        TabContent() {
          RandomPage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name2'), 1, $r('app.media.page_icon2_selected'),
          $r('app.media.page_icon2')));

        TabContent() {
          AnswerPage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name3'), 2, $r('app.media.page_icon3_selected'),
          $r('app.media.page_icon3')));

        TabContent() {
          MorePage()
        }
        .padding({ top: $r("app.string.header_height") }).backgroundColor($r("app.color.view_bgc_2"))
        .tabBar(this.tabBarBuilder($r('app.string.page_name4'), 3, $r('app.media.page_icon4_selected'),
          $r('app.media.page_icon4')));
      }
      .onChange((index:number)=>{
        this.title=this.titles[index]
      })
      .scrollable(false)
      .vertical(false)
      .divider({
        strokeWidth: 0.8,
        color: '#0D182431'
      })
      .backgroundColor($r("app.color.view_bgc_1"))
      .padding({ top: $r("app.string.header_margin"), bottom: $r("app.string.footer_margin") })
      .barHeight(56)
    }

  }
}



