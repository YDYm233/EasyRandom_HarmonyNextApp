import { BreakpointState, BreakpointSystem } from '@ohos/common';
import { productViewManager } from '@kit.StoreKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction, PromptAction } from '@kit.ArkUI';
class AppItem {
  name: string|Resource
  img: Resource
  url: string
  params: string | null
  color:  null | Color
  constructor(name: string|Resource, img: Resource, url: string, params: string | null,
    color:  null | Color) {
    this.name = name;
    this.img = img;
    this.url = url
    this.params = params
    this.color = color
  }
}
const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
const AppName = '随易APP'
const AppBundleName = 'ydy.App.EasyRandom'
const LinkAppName:string = '随易元服务'
const LinkAppBundleName:string = 'com.atomicservice.5765880207854873613'

function startBrowsableAbility(context: common.UIAbilityContext,src:string): void {
  let want: Want = {
    action: 'ohos.want.action.viewData',
    entities: ['entity.system.browsable'],
    uri:src
  };
  context.startAbility(want)
    .then(() => {
      promptAction.showToast({
        message: '正在尝试跳转浏览器'
      })
    })
    .catch((err: BusinessError) => {
      promptAction.showToast({
        message: '跳转失败'
      })
      console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
    });
}
@Builder
export function Illustrate() {
  IllustrateComponent();
}

@Component
struct IllustrateComponent {
  private readonly  Apps: Array<AppItem> = [
  new AppItem('联系我们', $r("app.media.contactus_fill"),
    '', '',0xf10ff5),
  new AppItem('微博留言', $r("app.media.link_weibo"),
    'https://weibo.com/5858421461/OuE5WnqyO', '', 0xffff00),
  new AppItem('B站留言', $r("app.media.link_bilibili"),
    'https://www.bilibili.com/video/BV135tie7E5P/?p=1&spm_id_from=pageDriver', '', 0xFF7299),
  new AppItem('官方网站', $r("app.media.link_myself"),
    'http://www.m233.top', '', 0x00BEFF),
    new AppItem('给个好评', $r("app.media.addoil_thumb"),
      '', '', 0xfebb00),
    new AppItem('赞赏我们', $r("app.media.addoil_flower"),
      '', '', 0xff3366),
    new AppItem(LinkAppName, $r("app.media.link_myApp"),
      '', '', 0x00BEFF),
    new AppItem('版权声明', $r("app.media.illustrate"),
      '', '', 0xBBFFCC),
];
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  @State fontSize: number = 16;
  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }
  @State customDialogId:number = 0;
  @Builder
  CustomDialog() {
    Column() {
      Text('感谢您的支持与鼓励').fontSize(30).lineHeight(36).fontWeight(FontWeight.Bold)
        .margin({bottom:12})
      Row(){
        Text('') .width('100%').textAlign(TextAlign.Start).fontSize(16).fontColor(0x88333333).fontStyle(FontStyle.Italic)
        Text('') .width('100%').textAlign(TextAlign.End).fontSize(16).fontColor(0x88333333)
      }
      .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween)
      .width('100%').height(20)
      .margin({bottom:24})
      Text('本App暂无支付功能')
        .width('100%').textAlign(TextAlign.Start)
        .fontSize(18)
        .margin({bottom:12})
      Text('您可以为我的B站账户充电、在应用市场给我评价、在我的帖子回消息、反馈Bug、或向我提出任何改进意见来鼓励我')
        .width('100%').textAlign(TextAlign.Start)
        .fontSize(18)
        .margin({bottom:12})


    }.padding(24)
  }
  @Builder
  itemHead(text: string) {
    Text(text)
      .fontSize(20)
      .width("100%")
      .padding(10)      .fontColor($r("app.color.FontIcon_Fore1"))
  }
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination() {
    Column() {
      List() {
        ListItemGroup({ header: this.itemHead('问题反馈'), space: 8 }) {
          ////微信群
          ListItem() {
            Column() {
              Row() {
                Row() {
                  Image(this.Apps[0].img).width('60%').fillColor(0xffffff)
                }
                .height('70%')
                .aspectRatio(1)
                .borderRadius('50%')
                .backgroundColor(this.Apps[0].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)

              Row() {
                Text(this.Apps[0].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            .onClick(() => {
              this.pageInfos.pushPath({ name: '问题反馈' })
            })
          }

          ////微博
          ListItem() {
            Column() {
              Row() {
                Row() {
                  Image(this.Apps[1].img).width('70%')
                  //.fillColor(0xffffff)
                }
                .height('70%')
                .aspectRatio(1)
                .borderRadius('50%')
                .backgroundColor(this.Apps[1].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)

              Row() {
                Text(this.Apps[1].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {

            const uri: string = this.Apps[1].url
            startBrowsableAbility(context, uri)
          })

          ////
          ListItem() {
            Column() {
              Row() {
                Row() {
                  Image(this.Apps[2].img).width('70%').fillColor(0xffffff)
                }
                .height('70%')
                .aspectRatio(1)
                .borderRadius('50%')
                .backgroundColor(this.Apps[2].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)

              Row() {
                Text(this.Apps[2].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            const uri: string = this.Apps[2].url
            startBrowsableAbility(context, uri)
          })

          ////
          ListItem() {
            Column() {
              Row() {
                Row() {
                  Image(this.Apps[3].img).width('70%').fillColor(0xffffff)
                }
                .height('70%')
                .aspectRatio(1)
                .borderRadius('50%')
                .backgroundColor(this.Apps[3].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)

              Row() {
                Text(this.Apps[3].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            const uri: string = this.Apps[3].url
            startBrowsableAbility(context, uri)
          })
        }
        ListItemGroup({ header: this.itemHead('赞赏我们'), space: 8 }) {
          ////
          ListItem() {
            Column() {
              Row() {
                Row() {
                  Image(this.Apps[4].img).width('60%').fillColor(0xffffff)
                }
                .height('70%')
                .aspectRatio(1)
                .borderRadius('50%')
                .backgroundColor(this.Apps[4].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)

              Row() {
                Text(this.Apps[4].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            .onClick(() => {
              const want: Want = {
                uri: `store://appgallery.huawei.com/app/detail?id=${AppBundleName}`
              };
              promptAction.showToast({
                message: '正在尝试转到应用商店查看'+AppName
              })
              context.startAbility(want).then(() => {
                //拉起成功
              }).catch(() => {
                //跳转应用商店失败
                // 尝试打开应用详情
                const wantParam: Want = {
                  parameters: {
                    bundleName: AppBundleName
                  }
                }
                const callback: productViewManager.ProductViewCallback = {
                  onError: (error: BusinessError) => {
                    hilog.error(0x0001, 'TAG', `loadService onError.code is ${error.code}, message is ${error.message}`)
                    promptAction.showToast({
                      message: '跳转失败'
                    })
                  }
                }
                productViewManager.loadProduct(context, wantParam, callback);
              })
            })
          }
          ListItem() {
            Column(){
              Row(){
                Row() {
                  Image(this.Apps[5].img).width('60%').fillColor(0xffffff)
                }.height('70%').aspectRatio(1).borderRadius('50%').backgroundColor(this.Apps[5].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)         .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              Row(){
                Text(this.Apps[5].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            .onClick(()=>{
              promptAction.openCustomDialog({
                builder: () => {
                  this.CustomDialog()
                },
                showInSubWindow: false,
                offset: { dx: 0, dy: 5 },
                backgroundColor: 0xd9ffffff,
                cornerRadius: 24,
                backgroundBlurStyle: BlurStyle.Regular,

              }).then((dialogId: number) => {
                this.customDialogId = dialogId
              })
            })
          }
        }

        ListItemGroup({ header: this.itemHead('更多'), space: 8 }) {
          ////体验更多服务
          ListItem() {
            Column(){
              Row(){
                Row() {
                  Image(this.Apps[6].img).width('60%').fillColor(0xffffff)
                }.height('70%').aspectRatio(1).borderRadius('50%').backgroundColor(this.Apps[6].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)         .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              Row(){
                Text(this.Apps[6].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            .onClick(()=>{
              console.log(LinkAppBundleName)
              console.log(LinkAppName)
              let want: Want = {
                deviceId: '',
                bundleName:LinkAppBundleName,
                abilityName: 'EntryAbility',
                moduleName:"entry"
              };
              promptAction.showToast({
                message: `正在尝试打开${LinkAppName}`
              })
              //const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
              let context = getContext(this) as common.UIAbilityContext;
              context.startAbility(want, (err: BusinessError) => {
                if (err.code) {
                  console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);//拉取应用失败信息
                  //打开失败
                  // 尝试跳转应用商店
                  promptAction.showToast({
                    message: `尝试打开应用商店`
                  })
                  const want: Want = {
                    uri: `store://appgallery.huawei.com/app/detail?id=${LinkAppBundleName}`
                  };
                  context.startAbility(want).then(() => {
                    //跳转应用商店成功
                  }).catch(() => {
                    //跳转应用商店失败
                    // 尝试打开应用详情
                    const wantParam: Want = {
                      parameters: {
                        bundleName: LinkAppBundleName
                      }
                    }
                    const callback: productViewManager.ProductViewCallback = {
                      onError: (error: BusinessError) => {
                        hilog.error(0x0001, 'TAG', `loadService onError.code is ${error.code}, message is ${error.message}`)//显示应用详情失败
                       //统统失败
                        // 弹出错误信息
                        promptAction.showToast({
                          message: '跳转失败'
                        })
                      }
                    }
                    productViewManager.loadProduct(context, wantParam, callback);//打开应用详情
                  })
                }
              });
            })
          }
          //////版权声明
          ListItem() {
            Column(){
              Row(){
                Row() {
                  Image(this.Apps[7].img).width('60%').fillColor(0xffffff)
                }.height('70%').aspectRatio(1).borderRadius('50%').backgroundColor(this.Apps[7].color)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)         .clip(true)
              }.width('100%').height('70%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              Row(){
                Text(this.Apps[7].name)
              }
              .width('100%').height('30%')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Top)
            }
            .width('90%')
            .aspectRatio(1)
            .margin('5%')
            .borderRadius(16)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg1"))
            .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            .onClick(()=>{
              this.pageInfos.pushPath({ name: '版权声明' })
            })
          }
      }
}
      .width('100%')
      .height('100%')
      .lanes(this.currentBreakpoint.value === 'sm' ? 2 : (this.currentBreakpoint.value === 'md' ? 3 : 4))
      .padding({ left:this.currentBreakpoint.value=='sm'?6:12,right:this.currentBreakpoint.value=='sm'?6:12})
    }     .backgroundColor($r("app.color.Comp_Bg2"))
}
   .title('更多信息')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素

      return true
    })
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}


// export default IllustrateComponent