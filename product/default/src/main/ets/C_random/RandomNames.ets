import { Random,Randoms } from '@ohos/common'
import  Header from '../Component/Header'
import { CounterType, CounterComponent } from '@kit.ArkUI';
@Entry
@Component
struct RandomNames {

  build() {
    Column() {
      Header({ title: '抽签' })
      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12
        },
        gutter: 12
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 6,
            lg: 8
          },
          offset: {
            sm: 0,
            md: 1,
            lg: 2
          }
        }) {
          Scroll() {
            NamesBox().width('100%')
          }
          .width('100%')
          .height('100%')
          .align(Alignment.Center)
          //.alignItems(VerticalAlign.Center)
        }
        .height('100%')
      }
      .height('100%')
      .margin({ left: 12, right: 12 })
      .padding({top:$r("app.string.header_height")})
    }.height('100%')
    .backgroundColor($r("app.color.view_bgc_2"))
  }
}

@Component
struct NamesBox {
  @State textValue:string='小红\n小兰\n小明'
  @State texts:string[]=[]
  @State indexs:number[]=[]
  @State number:number=1;
  @State max:number=3;
  @Builder
  ListItem(name:string,index:number) {
    Row() {
          Text(index+name)
            .opacity(0.88)
            .fontColor('#000000')
            .fontSize(20)
    }.width('90%').height('12%').margin('5%')
    .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
    .border({color:Color.Blue,width:1,style:BorderStyle.Solid,radius:12})

  }
  build() {
    Column() {
      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12
        },
        gutter: 12
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
         List(){
           ForEach(this.texts,(name:string,index:number) => {
             ListItem() {
               this.ListItem(name,index)
             }
           })
         }.alignListItem(ListItemAlign.Center)
          .width('90%')
          .margin('5%')
          .aspectRatio(1)
          .border({width:2,color:0x20808080,radius:12})
        }.borderRadius(24).backgroundColor($r("app.color.view_bgc_1"))


        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Column() {
            Row() {
                Text('请输入您的数据列表').textAlign(TextAlign.Center).alignSelf(ItemAlign.Center).fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .layoutWeight(1)
            TextArea({text:this.textValue,placeholder:'\n本app不会收集或保存您的列表数据'}).padding(8).layoutWeight(4)
              .onChange((value: string) => {
                this.textValue = value;
                const valueArray=this.textValue.split('\n')
                const filterArray = valueArray.filter(line => line.trim() !== '');
                this.max=filterArray.length;
              })
            Row(){
              Row(){
                Text('数量:').height('100%').fontWeight(FontWeight.Bold)
                CounterComponent({
                  options: {
                    type: CounterType.COMPACT,
                    numberOptions: {
                      value: 1,
                      min: 1,
                      max:this.max,
                      step: 1,
                      focusable:true,
                      onChange:(value:number)=>{this.number=value}
                    }
                  }
                }).height('110%').padding({top:'9%',left:'4%'})
              }
              .alignItems(VerticalAlign.Center)
              .height('100%')
              .aspectRatio(3)
              Button() {
                Text('开始').fontColor($r("app.color.control_fc_1")).fontWeight(FontWeight.Bold)
              }
              .onClick(()=>{
                const valueArray=this.textValue.split('\n')
                const filterArray = valueArray.filter(line => line.trim() !== '');
                this.max=filterArray.length;
                this.indexs=Randoms(0,filterArray.length-1,true,this.number,false)
                console.log('valueArray:'+filterArray)
                console.log('indexs:'+this.indexs.toString())
                let i:number=0;
                while(i<this.number){
                  let x:number=this.indexs[i]
                  this.texts[i]=filterArray[x]
                  this.indexs[i]=i+1;
                  //console.log('x:'+x)
                  //console.log('text['+i+']:'+this.texts[i])
                  i++;
                }
              })

              .backgroundColor($r("app.color.control_bgc_1"))
              .height('80%')
              .aspectRatio(2)
              .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
            }.width('100%').layoutWeight(1).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
          }.height('100%')
          .aspectRatio(1)
        }  .padding({left:'5%',right:'5%',top:'4%',bottom:'1%'}) .width('100%').aspectRatio(1)         .backgroundColor(0xffffff)          .border({width:0,color:0xf33333,radius:24})
      }
    }
  }
}

export default RandomNames