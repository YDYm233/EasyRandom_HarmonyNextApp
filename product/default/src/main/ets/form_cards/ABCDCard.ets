import {Random} from '@ohos/basic-utils'
import { DEFAULT } from '@ohos/hypium';

@Entry
@Component
struct ABCDCard {
  readonly FULL_WIDTH_PERCENT: string = '90%';
  @State angle: number = 30
  @State duration: number =800
  @State colors:Resource[]=[$r("app.color.Comp_Bg4"),$r("app.color.Comp_Bg4"),$r("app.color.Comp_Bg4"),$r("app.color.Comp_Bg4")]
  //@State fontColors:Color[]=[0x333333,0x333333,0x333333,0x333333]
  @State fontColors:Resource[]=[$r("app.color.FontIcon_Fore1"),$r("app.color.FontIcon_Fore1"),$r("app.color.FontIcon_Fore1"),$r("app.color.FontIcon_Fore1")]
  build() {
    Row() {
        Text('A').width('50%').height('50%')
          .backgroundColor(this.colors[0])
          .fontColor(this.fontColors[0])
          .position({left:0,top:0})
          .border({style:BorderStyle.Solid,width:5,color:$r("app.color.Comp_Bg2"),radius:12})
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48).textAlign(TextAlign.Center)
        Text('B').width('50%').height('50%')
          .backgroundColor(this.colors[1])
          .fontColor(this.fontColors[1])
          .position({right:0,top:0})
          .border({style:BorderStyle.Solid,width:5,color:$r("app.color.Comp_Bg2"),radius:12})
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48).textAlign(TextAlign.Center)
        Text('C').width('50%').height('50%')
          .backgroundColor(this.colors[2])
          .fontColor(this.fontColors[2])
          .position({left:0,bottom:0})
          .border({style:BorderStyle.Solid,width:5,color:$r("app.color.Comp_Bg2"),radius:12})
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48).textAlign(TextAlign.Center)
        Text('D').width('50%').height('50%')
          .backgroundColor(this.colors[3])
          .fontColor(this.fontColors[3])
          .position({right:0,bottom:0})
          .border({style:BorderStyle.Solid,width:5,color:$r("app.color.Comp_Bg2"),radius:12})
          .clip(true)
          .fontWeight(FontWeight.Bold)
          .fontSize(48).textAlign(TextAlign.Center)
        Image($r("app.media.needle")).width('60%').aspectRatio(1).position({left:'20%',top:'20%'})
          .fillColor($r("app.color.FontIcon_Fore2"))
            //.backgroundColor($r("app.color.view_bgc_2"))
          .rotate({angle:this.angle})
          .animation({ duration: this.duration, curve: Curve.Ease })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.colors[0]=$r("app.color.Comp_Bg4")
      this.colors[1]=$r("app.color.Comp_Bg4")
      this.colors[2]=$r("app.color.Comp_Bg4")
      this.colors[3]=$r("app.color.Comp_Bg4")
      this.fontColors[0]=$r("app.color.FontIcon_Fore1");
      this.fontColors[1]=$r("app.color.FontIcon_Fore1");
      this.fontColors[2]=$r("app.color.FontIcon_Fore1");
      this.fontColors[3]=$r("app.color.FontIcon_Fore1");
      this.angle+=Random(1,360,true)+360*3;
      if(this.angle>36000000){
        this.angle=Random(1,360,true)+360*3;
      }
      animateTo ( {
        duration: 1,
        iterations: 1,
        curve:Curve.EaseIn,
        delay:1000
      }, () => {
        if(this.angle%360<90){
          this.colors[1]=$r("app.color.Brand")
          //this.fontColors[1]=0xffffff;
        }
        else if(this.angle%360>90&&this.angle%360<180){
          this.colors[3]=$r("app.color.Brand")
          //this.fontColors[3]=0xffffff;
        }
        else if(this.angle%360>180&&this.angle%360<270){
          this.colors[2]=$r("app.color.Brand")
          //this.fontColors[2]=0xffffff;
        }
        else {
          this.colors[0]=$r("app.color.Brand")
          //this.fontColors[0]=0xffffff;
        }
      })
    })
  }
}
export default ABCDCard