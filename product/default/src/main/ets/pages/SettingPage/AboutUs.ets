
@Builder
export function AboutUs() {
  AboutUsComponent();
}

@Component
struct AboutUsComponent {
  @State isShowQR:boolean =false
  @State qrSrc:string[] = ['https://gitee.com/Yan_m233/app_EasyRandom',"https://www.bilibili.com/opus/971320804050468900?spm_id_from=333.1365.0.0","https://weibo.com/5858421461/OuE5WnqyO"]
  @State popupTitle:string[]=['官方网站','哔哩哔哩','微博']
  @State themeColor:Color[] =[0xFF00BEFF,0xFF7299,0xFFEB00]
  @State themeIcon:Resource[]=[$r("app.media.link_myself"),$r("app.media.link_bilibili"),$r("app.media.link_weibo")]
  @State index:number = 0
  @State linkTitle:string='点击前往'+this.popupTitle[this.index]
  @Builder QRCodeBox(){
    Column() {
      Row() {
        Text(this.popupTitle[this.index]).fontWeight(700).textAlign(TextAlign.Center)      .width('100%')
      }
      .width('100%')
      .aspectRatio(10)    .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      Row() {
        QRCode(this.qrSrc[this.index])      .width('100%')
          .color($r("app.color.FontIcon_Fore1"))
          .backgroundColor($r("app.color.Comp_Bg1"))
      }
      .width('100%')
      .aspectRatio(1)
      Row() {
        Row(){
          Hyperlink(this.qrSrc[this.index],this.linkTitle).color(0xffffff)
        }.backgroundColor(this.themeColor[this.index]).padding(5).borderRadius(12).height('80%')
      }
      .width('100%')
      .aspectRatio(5)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width(280)
    .aspectRatio(5/7)
    .padding(24)
    .backgroundColor($r("app.color.Comp_Bg1"))
  }
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    NavDestination(){
    Row(){
    Column() {
      Row() {
        Image($r("app.media.Avatar"))
          .width('40%')
          .aspectRatio(1)
          //.padding(2)
          //.backgroundColor(0xffffff)
          .margin({ left:'30%',right:'30%',top:'20%',bottom:'10%' })
          .border({width:5,color:Color.Gray,radius:800})
          .bindPopup($$this.isShowQR, {
            builder: this.QRCodeBox(),
            placement: Placement.Bottom,
            //mask: {color:'#33000000'},
            popupColor: $r("app.color.Comp_Bg1"),
            enableArrow: true,
            showInSubWindow: false,
            onStateChange: (e) => {
              if (!e.isVisible) {
                this.isShowQR = false
              }
            }
          })
      }.width(300)
      Row(){
        Text('个人介绍：闫东阳，个人开发者、大四在读 \n社媒昵称：门二三三')          .fontColor($r("app.color.FontIcon_Fore1"))
      }
      .width('100%')
      .height(80)
      .padding(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      GridRow({columns:{sm:12,md:12,lg:12},gutter:12}){
        GridCol({span:{sm:6,md:4,lg:4}}) {
          Row() {
            Image(this.themeIcon[0]).width('25%').aspectRatio(1).fillColor(0xffffff)
            Text(this.popupTitle[0]).height('100%').width('60%').fontColor(0xffffff).textAlign(TextAlign.Center).fontWeight(600)
          }.width('80%').padding({left:'5%',right:'5%'}).margin({ left:'10%',right:'10%' }).aspectRatio(3).backgroundColor(this.themeColor[0]).borderRadius(12)
        }.align(Alignment.Center)
        //.backgroundColor(0xbeff00)
        .onClick(()=>{
          this.index=0
          this.linkTitle='点击前往'+this.popupTitle[this.index]
            this.isShowQR=true;
        })
        GridCol({span:{sm:6,md:4,lg:4}}) {
          Row() {
            Image(this.themeIcon[1]).width('25%').aspectRatio(1)
              //.backgroundColor(0xffffff)
            Text(this.popupTitle[1]).height('100%').width('60%').fontColor(0xffffff).textAlign(TextAlign.Center).fontWeight(600)
          }.width('80%').padding({left:'5%',right:'5%'}).margin({ left:'10%',right:'10%' }).aspectRatio(3).backgroundColor(this.themeColor[1]).borderRadius(12)
        }.align(Alignment.Center)
        //.backgroundColor(0xbeff00)
        .onClick(()=>{
          this.index=1
          this.linkTitle='点击前往'+this.popupTitle[this.index]
          this.isShowQR=true;
        })
        GridCol({span:{sm:6,md:4,lg:4}}) {
          Row() {
            Image(this.themeIcon[2]).width('25%').aspectRatio(1)
              //.backgroundColor(0xffffff)
            Text(this.popupTitle[2]).height('100%').width('60%').fontColor(0xffffff).textAlign(TextAlign.Center).fontWeight(600)
          }.width('80%').padding({left:'5%',right:'5%'}).margin({ left:'10%',right:'10%' }).aspectRatio(3).backgroundColor(this.themeColor[2]).borderRadius(12)
        }.align(Alignment.Center)
        //.backgroundColor(0xbeff00)
        .onClick(()=>{
          this.index=2
          this.linkTitle='点击前往'+this.popupTitle[this.index]
          this.isShowQR=true;
        })
}
      .width('100%')
     // .backgroundColor(0xffeb00)
    }
    //.backgroundColor(0x00ff00)
    .width('100%')
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r("app.color.Comp_Bg2"))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }  .title('开发者团队')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      //console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
}

// export default AboutUsComponent