import { Random,Randoms } from '@ohos/common'
import  Header from '../Component/Header'
import { promptAction } from '@kit.ArkUI'
import { BreakpointState, BreakpointSystem } from '@ohos/common';
import { CounterType, CounterComponent } from '@kit.ArkUI';
@Entry
@Component
struct HonestOrChallenge{
  private customDialogComponentId: number = 0
@State customDialogId:number=0
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })
  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }
  @State honests:string[]=['真心话1','真心话2','真心话3','真心话4']
  @State challenges:string[]=['大冒险1','大冒险2','大冒险3','大冒险4']
  @State selectedText:string=this.challenges[Random(0,this.challenges.length-1,true)]
  @State HorC:boolean=true;
  @State pointAngle:number=0;
  @State duration:number=1000
  @State index:number=0
  @State honestColor:Color=0xff0000
  @State challengeColor:Color=0x0000ff
  @Builder customDialogBuilder() {
  Column() {
    Text(this.selectedText).height('70%').fontWeight(800).fontSize(24)
    Row() {
      Button(this.HorC==true?'换大冒险':'换真心话').onClick(() => {
        if(this.HorC==true){
          this.selectedText=this.challenges[Random(0,this.challenges.length-1,true)]
        }
        else{
          this.selectedText=this.honests[Random(0,this.challenges.length-1,true)]
        }
        this.HorC=!this.HorC;
      })
        .backgroundColor(this.HorC==true?this.challengeColor:this.honestColor)
      Blank().width('20%')
      Button("再来一条").onClick(() => {
        if(this.HorC==true){
          let index = Random(0,this.honests.length-1,true)
          if(index!=this.index){
            this.index=index
          }
          else{
            index=index-1;
            if(index<0){
              index=this.honests.length-1;
            }
            this.index=index
          }

          this.selectedText=this.honests[index]
        }
        else{
          let index = Random(0,this.challenges.length-1,true)
          if(index!=this.index){
            this.index=index
          }
          else{
            index=index-1;
            if(index<0){
              index=this.challenges.length-1;
            }
            this.index=index
          }
          this.selectedText=this.challenges[index]
        }
        // promptAction.closeCustomDialog(this.customDialogId)
      })        .backgroundColor(this.HorC==true?this.honestColor:this.challengeColor)
    }.height('30%')
  }
}
  build() {
    Column() {
      Header({ title: '真心话大冒险' })
      Row(){
        Column(){
          Text('111')
        }
        .onClick(()=>{
          this.duration=1000;
          let target=Random(1,360,true)+360*2;
          this.pointAngle=this.pointAngle+target
          console.log(this.pointAngle.toString())
          if(this.pointAngle>3600000){
            this.pointAngle=this.pointAngle-3600000
          }
          let angle = this.pointAngle%360
          if(angle==0||angle==180){
            console.log('无事发生')
          }
          else {
            if(angle>0&&angle<180){
              this.HorC=false
              this.selectedText=this.challenges[Random(0,this.challenges.length-1,true)]
            }
            else{
              this.HorC=true
              this.selectedText=this.honests[Random(0,this.challenges.length-1,true)]
            }
            promptAction.openCustomDialog({
              builder: () => {
                this.customDialogBuilder()
              },
              showInSubWindow: false,
              offset: { dx: 5, dy: 5 },
              backgroundColor: 0xd9ffffff,
              cornerRadius: 24,
              backgroundBlurStyle: BlurStyle.Regular,
              width: this.currentBreakpoint.value == 'sm' ? '80%' :
                (this.currentBreakpoint.value == 'md' ? '50%' : '30%'),
              height: this.currentBreakpoint.value == 'sm' ? '20%' :
                (this.currentBreakpoint.value == 'md' ? '20%' : '20%'),

            }).then((dialogId: number) => {
              this.customDialogId = dialogId
            })
          }
        })
        .animation({ duration: this.duration, curve: Curve.Ease })
        .rotate({z:1,angle:this.currentBreakpoint.value=='sm'?this.pointAngle+90:this.pointAngle})
        .height('80%')
        .aspectRatio(1)
        .backgroundColor(0x00beff)
        .borderRadius('50%')
      }
      .width(this.currentBreakpoint.value=='sm'?'20%':'16%')
      .height(this.currentBreakpoint.value=='sm'?'10%':'14%')
      .position(this.currentBreakpoint.value=='sm'?{left:'40%',top:'45%'}:{left:'42%',top:'43%'}).zIndex(10)
      .margin({top:25}).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
      //.padding({top:50})
      GridRow({
        columns: {
          xs:4,
          sm: 4,
          md: 8,
          lg: 12
        }
      }) {

        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Row() {
            Text('真心话')
              .fontWeight(800)
              .width((this.currentBreakpoint.value == 'sm' ? 300 : 120))
              .height((this.currentBreakpoint.value == 'sm' ? 100 : 420))
              .fontSize((this.currentBreakpoint.value == 'sm' ? 100 : 120))
              .fontColor(0xffffff)
              .backgroundColor(0x00beff)
              .position(this.currentBreakpoint.value == 'sm' ? null : { left: 50, top: 50 })
              .margin(this.currentBreakpoint.value == 'sm' ? {top:100} :null)

          }.width('100%').height('100%').alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Center)


        }
        .width('100%')
        .height(this.currentBreakpoint.value=='sm'?'50%':'100%')
        .backgroundColor(this.honestColor)
        .onClick(() => {
          this.selectedText=this.honests[Random(0,this.challenges.length-1,true)]
          this.HorC=true
          promptAction.openCustomDialog({
            builder: () => {
              this.customDialogBuilder()
            },
            showInSubWindow: false,
            offset: { dx: 5, dy: 5 },
            backgroundColor: 0xd9ffffff,
            cornerRadius: 24,
            backgroundBlurStyle:BlurStyle.Regular,
            width:  this.currentBreakpoint.value=='sm'?'80%':(this.currentBreakpoint.value=='md'?'50%':'30%'),
            height: this.currentBreakpoint.value=='sm'?'20%':(this.currentBreakpoint.value=='md'?'20%':'20%'),

          }).then((dialogId: number) => {
            this.customDialogId = dialogId
          })

        })

        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg:6
          }
        }) {
          Row() {
            Text('大冒险')
              .fontWeight(800)
              .width((this.currentBreakpoint.value == 'sm' ? 300 : 120))
              .height((this.currentBreakpoint.value == 'sm' ? 100 : 420))
              .fontSize((this.currentBreakpoint.value == 'sm' ? 100 : 120))
              .fontColor(0xffffff)
              .backgroundColor(0x00beff)
              .position(this.currentBreakpoint.value == 'sm' ? null : { right: 50, bottom: 50 })
              .margin(this.currentBreakpoint.value == 'sm' ? {bottom:100} :null)
          }.width('100%').height('100%').alignItems(VerticalAlign.Bottom).justifyContent(FlexAlign.Center)
          }
          .width('100%')
        .height(this.currentBreakpoint.value=='sm'?'50%':'100%')
        .backgroundColor(this.challengeColor)
        .onClick(() => {
          this.selectedText=this.challenges[Random(0,this.challenges.length-1,true)]
          this.HorC=false
          promptAction.openCustomDialog({
            builder: () => {
              this.customDialogBuilder()//22
            },
            showInSubWindow: false,
            alignment:DialogAlignment.Center,
            isModal:true,
            offset: { dx: 5, dy: 5 },
            backgroundColor: 0xd9ffffff,
            cornerRadius: 24,
            backgroundBlurStyle:BlurStyle.Regular,
            width:  this.currentBreakpoint.value=='sm'?'80%':(this.currentBreakpoint.value=='md'?'50%':'30%'),
            height: this.currentBreakpoint.value=='sm'?'20%':(this.currentBreakpoint.value=='md'?'20%':'20%'),

          }).then((dialogId: number) => {
            this.customDialogId = dialogId
          })
        })
      }
      .height('100%')
      .padding({top:$r("app.string.header_height")})
    }.height('100%')
    .backgroundColor(this.honestColor)
  }
}