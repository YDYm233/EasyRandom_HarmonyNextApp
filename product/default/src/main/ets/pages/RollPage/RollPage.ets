import { BreakpointState, BreakpointSystem, Random } from '@ohos/common';
import OptBoxs from './RollOpts';
import { Roll, RollItem, rolls } from '../../datas/rolls';
@Entry
@Component
struct RollPage {
  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: 12 }) {
        GridCol({ span: { sm: 4, md: 4, lg: 4 }, offset: { sm: 0, md: 2, lg: 4 } }) {
          Row() {
            RollBoxs()
          }
          .width('100%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
        }
        .height('100%')
      }
      .height('100%')
      .margin({ left: 12, right: 12 })
    }.width('100%').height('100%').backgroundColor($r("app.color.view_bgc_2"))
  }
}


AppStorage.setOrCreate('allRolls', rolls);
@Component
struct RollBoxs {
  @StorageLink('allRolls')dataList:Roll[]=rolls
  @State title:string=this.dataList[0].rollName
  @State rotateAngle: number = 0
  @State isRoll: boolean = false
  @State duration: number = 0
  @State swiperIndex:number =0
  @State loveIndex:number=0
  @State isSheetShow:boolean=false
  @State isDialogShow:boolean=false
  @State currentBreakpoint: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg" })

  private swiperController: SwiperController = new SwiperController()
  aboutToAppear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {
    BreakpointSystem.getInstance().attach(this.currentBreakpoint)
    BreakpointSystem.getInstance().stop()
  }
  @Builder neirong(){
    Column() {
      OptBoxs().width('100%').height('100%')
    }
  }
  build() {
    Column() {
      Row() {
        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_pre")).fillColor($r("app.color.control_fc_2")).width('75%').aspectRatio(1.4)
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .backgroundColor($r("app.color.control_bgc_2"))
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
            .fontColor(0x333333)
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
            Image($r("app.media.func_next")).fillColor($r("app.color.control_fc_2")).width('75%').aspectRatio(1.4)
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .position({ right: 0 })
          .backgroundColor($r("app.color.control_bgc_2"))
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
      //组件轮播区
      Swiper(this.swiperController) {
        ForEach(this.dataList, (item: Roll) => {
          Row() {
            RollBox({ data: item })
              .width('100%')
          }
          .width('90%')
          .margin('5%')
          .aspectRatio(1)
          .rotate({
            angle: this.rotateAngle
          })
          .border({
            width: 1,
            color: 0xf1f3f5,
            radius: '50%',
            style: BorderStyle.Solid
          })
          .animation({ duration: this.duration, curve: Curve.Ease })
        }, (item: Roll) => item.index)

      }
      .width('100%')
      .aspectRatio(1)
      .border({
        width: 0,
        color: 0xfff,
        radius: 10,
        style: BorderStyle.Dotted
      })
      .cachedCount(2)
      .loop(true)
      .indicatorInteractive(true)
      .duration(1000)
      .itemSpace(0)
      .onChange((index:number) => {
        this.swiperIndex=index
        this.title=this.dataList[index].rollName
      })
      .onAnimationStart(() => {
        this.duration = 0;
        this.rotateAngle = 0;
      })

//底部控制区
      Row() {
        Row() {

          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_pin")).fillColor(this.swiperIndex!=this.loveIndex?$r("app.color.control_fc_2"):"#ffffff").width('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .backgroundColor(this.swiperIndex!=this.loveIndex?$r("app.color.control_bgc_2"):$r("app.color.control_bgc_1"))
          .height('100%')
          .aspectRatio(1)
          .onClick(() => {
            if(this.loveIndex!=this.swiperIndex){
              this.loveIndex=this.swiperIndex;
            }
            else{
              this.loveIndex=-1;
            }
          })
        }
        .height('100%')
        .layoutWeight(1)

        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: this.isRoll }) {
            if (this.isRoll == false) {
              Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(800)
            } else {
              LoadingProgress().color($r("app.color.control_fc_1")).height('75%')
            }
            //Image($r("app.media.page_icon1_selected")).fillColor($r("app.color.control_fc_1")).height('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .onClick(() => {
            this.duration = 3000
            this.isRoll = true;
            this.rotateAngle = Random(0, 360, true) + 360 * 18;
            setTimeout(() => {
              this.isRoll = false;
              this.duration = 0;
              this.rotateAngle = this.rotateAngle - 360 * 18
            }, this.duration);
          })
          .backgroundColor($r("app.color.control_bgc_1"))
          .height('100%')
          .aspectRatio(3)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        }
        .height('100%')
        .aspectRatio(3)
        .layoutWeight(4)

        Row() {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Image($r("app.media.func_plus")).fillColor($r("app.color.control_fc_2")).width('75%')
          }
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .position({ right: 0 })
          .backgroundColor($r("app.color.control_bgc_2"))
          .height('100%')
          .aspectRatio(1)

          .onClick(() => {

                  this.isSheetShow=true;


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
      width:0,
      color: 0xFF7A07,
      radius: '5.56%',
      style: BorderStyle.Dotted
    })
    .backgroundColor(0xffffff)
    .bindSheet($$this.isSheetShow,this.neirong() , {
      dragBar:true,  blurStyle:BlurStyle.Thin,       title:{title:'编辑'},enableOutsideInteractive:true,
      mode:SheetMode.EMBEDDED,
      borderWidth:2,
      borderColor:0x20000000,
      borderStyle:BorderStyle.Solid,
      height:this.currentBreakpoint.value == 'sm' ?SheetSize.LARGE: SheetSize.FIT_CONTENT,
      detents:this.currentBreakpoint.value=='sm'?[SheetSize.LARGE,SheetSize.MEDIUM]:null,
      preferType: this.currentBreakpoint.value == 'sm' ?SheetType.BOTTOM: (this.currentBreakpoint.value =='md'  ? SheetType.CENTER: SheetType.POPUP),
      width:this.currentBreakpoint.value == 'sm' ?'100%': (this.currentBreakpoint.value == 'md' ? '50%' : '40%'),

    })
  }
}

@Component
struct RollBox {
  @Prop data: Roll
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @Prop boxWidth:number
aboutToAppear(): void {

}
  build() {
    Flex( {direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center})
    {
      Canvas(this.context)
          .onSizeChange((oldValue:SizeOptions,newValue:SizeOptions)=>{
          //console.log('boxWidth=='+this.boxWidth)
        //  console.log('SizeChange===old:'+oldValue.width+'  ----new:'+newValue.width)
          //this.boxWidth=Number(newValue.width)
          })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          //this.boxWidth=Number(newValue.width)
          //console.log('AreaChange===old:'+oldValue.width+'  ----new:'+newValue.width)
        })
        .onReady(() => {
          let ctx = this.context;
          console.log('ctx.width:' + ctx.width)
          ctx.clearRect(0, 0, ctx.width, ctx.width)
          //const contextWidth = Number(newValue.width);
          const contextWidth = ctx.width;
          //const contextWidth = this.boxWidth
          const r = contextWidth / 2;
          let list: Array<RollItem> = this.data.rollItems
          let totalWeight = list.reduce<number>((acc: number, single: RollItem) => acc + single.weight, 0);
          let startAngle = - list[0].weight / totalWeight * 180+90;

          list.forEach(single => {
            const endAngle: number = startAngle + (single.weight / totalWeight) * 360;
            const centerAngle = (startAngle + endAngle) / 2;
            ctx.globalCompositeOperation = 'xor'
            ctx.beginPath();
            ctx.moveTo(r, r); // 中心点
            ctx.arc(r, r, r, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);
            ctx.closePath()
            ctx.fillStyle = single.color;
            ctx.fill();
            ctx.fillStyle = '#FFFFFF';
            ctx.textAlign = 'center';
            ctx.save()
            ctx.translate(r, r)
            //ctx.rotate((centerAngle - 90) * Math.PI / 180)
            ctx.rotate((centerAngle + 90) * Math.PI / 180)
            let texts: Array<string> = single.text.split('');
            const x = 0;
            const y = r * 0.1 + (r * 0.1 / texts.length);
            const lineHight = (r - y) / (texts.length+1)
            const fontSize = lineHight
            const font = fontSize.toString() + 'vp';
            ctx.font = font;
            for (let n: number = 0; n < texts.length; n++) {
              ctx.fillText(texts[n], x, (-r+lineHight+y/2+ n * lineHight), fontSize);
            }
            ctx.restore()
            startAngle = endAngle;
          })
          ctx.beginPath();
          ctx.moveTo(r, r); // 中心点
          ctx.arc(r, r, r / 10, -45, 275, false);
          ctx.closePath()
          ctx.fillStyle = 0xf1f3f5;
          ctx.fill();
        })
        .width('100%')
        .aspectRatio(1)
    }.width('100%')   .aspectRatio(1)
    .border({
      width: 10,
      color: 0xf1f3f5,
      radius: '50%',
      style: BorderStyle.Solid
    })
  }
}
export default RollPage
export{rolls,Roll,RollItem,RollBox,RollBoxs}