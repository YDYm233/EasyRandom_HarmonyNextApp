import { Random } from '@ohos/common';
import {rolls} from'./RollPage'
import router from '@ohos.router';

class RollItem { //转盘子选项
  id: string
  text: string
  weight: number
  color: string
  constructor(id: string, text: string, weight: number, color: string) {
    this.text = text;
    this.weight = weight;
    this.color = color;
    this.id = id
  }
}
class Roll { //转盘
  index: string
  rollName: string
  rollItems: RollItem[] //所有转盘子选项
  constructor(index: string, rollName: string, rollItems: RollItem[]) {
    this.index = index;
    this.rollName = rollName;
    this.rollItems = rollItems;
  }
}




//所有轮盘
@Entry
@Component
struct OptBoxs {
  @StorageLink('allRolls') boxsList: Roll[] = rolls;
 // @State boxsList:Roll[]=AppStorage.get('allrolls') as Roll[]

  build() {
    Column() {
      List({space:12}) {
        ForEach(this.boxsList, (item: Roll) => {
          ListItem() {
            Opts({ optsList: item })
              .width('100%')
          }
          .width('100%')
          .border({
            width: 0,
            color: 0xff0000,
            radius: 12,
            style: BorderStyle.Solid
          })
          .clip(true)
        },
        //)
          (item: Roll) => item.index)
        ListItem() {
          Row(){
            Button(){
            Image($r("app.media.func_plus")).fillColor(0x88333333).width('80%').margin('10%')
            }.height('70%').backgroundColor(0xf1f3f5).aspectRatio(1).borderRadius('50%')
          }.width('100%').aspectRatio(5).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
          .backgroundColor(0xffffff)
          .onClick(()=>{
            let afterData = AppStorage.get('allRolls') as Array<Roll>;
            let tailData:Roll=new Roll((Number(afterData[afterData.length-1].index)+1).toString(),'新转盘',[new RollItem('0','请输入',1,'#00beff')])
            this.boxsList.push(tailData)
            AppStorage.setAndLink('allroos',this.boxsList)
          })
        }
        .aspectRatio(5)
        .width('100%')
        .border({
          width: 0,
          color: 0xff0000,
          radius:12,
          style: BorderStyle.Solid
        })
        .clip(true)
      }
      .backgroundColor(0xf1f3f5)
      .alignListItem(ListItemAlign.Center)
      .height('100%')
      .width('100%')
      .border({
        width: 0,
        color: 0x20000000,
        radius: 12,
        style: BorderStyle.Solid
      })
      .clip(true)
      .padding('5%')

      Row() {
        Button() {
          Text('刷新').fontColor(0xffffff).fontWeight(800)
        }
        .backgroundColor($r("app.color.control_bgc_1"))
        .height('80%')
        .aspectRatio(2)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        .onClick(() => {
          let afterData = AppStorage.get('allRolls') as Array<Roll>;
          for (let i = 0; i < afterData.length; i++) {
            let s = afterData[i]
            console.log('\n轮盘(' + s.index + '):' + s.rollName + ':\n')
            for (let j = 0; j < s.rollItems.length; j++) {
              let ss = s.rollItems[j];
              console.log('选项(' + ss.id + '):' + ss.text)
            }
          }
        })

        Button() {
          Text('应用').fontColor(0xffffff).fontWeight(800)
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/Index' })
        })
        .height('80%')
        .backgroundColor($r("app.color.control_bgc_1"))
        .aspectRatio(2)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
      }.height(60).justifyContent(FlexAlign.SpaceAround).
      width('100%').alignItems(VerticalAlign.Center)
      //.backgroundColor(0xff0000)
.position({bottom:-60,left:0})
    }.width('100%').backgroundColor($r("app.color.view_bgc_1"))
    .height('100%')
    .padding({bottom:60})

  }
}

//单个轮盘
@Reusable
@Component
struct Opts {
  @StorageLink('allRolls') boxsList: Roll[] = rolls
  @Prop optsList: Roll
  @State rollIndex: string = this.optsList.index
  @State isShow: boolean = false
aboutToAppear(): void {
  this.optsList=this.boxsList[Number(this.optsList.index)]
  }
  build() {

    Column() {
      Row() {
        Text(this.optsList.rollName )
        Button() {
          Image($r("app.media.func_detail")).fillColor(0x88333333).width('80%').margin('10%')        .rotate({z:1,angle:this.isShow?0:-90})
        }
        .height('60%')
        .backgroundColor(0xf1f3f5)
        .aspectRatio(1)

        .animation({duration:400,curve:Curve.EaseIn})
        .onClick(() => {
          this.isShow = !this.isShow
        })
      }.aspectRatio(5).width('100%').justifyContent(FlexAlign.SpaceBetween).padding({left:'4%',right:'4%'})      .backgroundColor(0xffffff)
      .borderRadius(12)
      if (this.isShow) {
        Column() {
          ForEach(this.optsList.rollItems, (item: RollItem) => {
            ListItem() {
              Opt({ optLink: item, rollIndex: this.rollIndex })
                .width('100%')
            }
            .width('100%')

          },(item: RollItem) => item.id)
          Row() {
            Row() {
              Button() {
                Text('删除列表').fontColor($r("app.color.warning")).decoration({type: TextDecorationType.Underline,color:$r("app.color.warning")})

              }
              .backgroundColor('rgba(0,0,0,0)')
              .height('60%')
              .onClick(() => {
                let afterData=this.boxsList.filter(item => item.index != this.optsList.index);
                this.boxsList=afterData
                //AppStorage.setAndLink('allrolls',afterData)
              })
              Button() {
                Text('新建选项').fontColor($r("app.color.control_bgc_1")).decoration({type: TextDecorationType.Underline,color:$r("app.color.control_bgc_1")})
              }
              .backgroundColor('rgba(0,0,0,0)')
              .height('60%')
              .onClick(() => {
                let tailData = new RollItem(this.optsList.rollItems.length.toString(), '请输入', 1, '#00beff')
                this.optsList.rollItems.push(tailData)
                let afterData=AppStorage.get('allRolls')as Array<Roll>
                afterData[Number(this.optsList.index)]=this.optsList
                //afterData[Number(this.optsList.index)].rollItems.push(tailData)
               AppStorage.set('allRolls',afterData)

                this.isShow=false;
                setTimeout(()=>{
                  this.isShow=true;
                },20)

              })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .aspectRatio(6)
            .width('100%')
            .padding({ left: '15%', right: '15%' })
            .clip(true)
            .border({
              width: 0,
              color: 0x00fff0,
              radius: 8,
              style: BorderStyle.Solid
            })
          }
          Divider()
        }.width('90%').margin({ left: '5%', right: '5%' })      .backgroundColor(0xf1f3f5)
      }
    }
  }
}

//单个选项
//@Reusable
@Component
struct Opt {
  @StorageLink('allRolls') boxsList: Roll[] = rolls;
  @Prop rollIndex: string;
  @Prop optLink: RollItem
  @State optData: RollItem = this.optLink
  @State isShow: boolean = true
  @State isEdit: boolean = false
  @State newText: string = ''
  @State newWeight: number = 1
  @State newColor: string = '#00beff'

  build() {
    if (this.isShow) {
      Row() {
        if (this.isEdit) {
          Row() {
            Button() {//删除
              Image($r("app.media.func_delete")).fillColor($r("app.color.warning"))
            }.height('70%').aspectRatio(1).borderRadius('50%').backgroundColor(0xf1f3f5).padding('5%')
            .onClick(() => {
              let oldOpts: RollItem[] = this.boxsList[Number(this.rollIndex)].rollItems
              let oldRolls: Roll[] = this.boxsList
              oldOpts.splice(Number(this.optData.id), 1)
              oldRolls[Number(this.rollIndex)].rollItems = oldOpts;
              AppStorage.set('allRolls', oldRolls)
              //let datas = AppStorage.get('allRolls') as Array<Roll>;
              //let datastring = datas[Number(this.rollIndex)].rollItems.toString()
              //console.log(oldRolls.toString())
              //console.log(oldOpts.toString())
              //console.log(datastring)
              this.isShow=false
            })
          }.height('100%').layoutWeight(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)
        }
        Row() {
          TextInput({ text: this.rollIndex + this.optData.text + this.optData.id, placeholder: '请输入您的选项' })
            .width('65%')
            .padding(0)
            .maxLength(12)
            .onChange((value: string) => {
              this.newText = value
            })
            .fontWeight(this.isEdit ? 500 : 800)
            .backgroundColor(this.isEdit ? '#f1f3f5' : '#ffffff')
            .textAlign(this.isEdit ? TextAlign.Center : TextAlign.Start)

          if (this.isEdit) { //权重 背景颜色
            TextInput({ text: this.optData.weight.toString() })
              .padding(0)
              .borderRadius(2)
              .fontWeight(800)
              .type(InputType.Number)
              .width('10%').textAlign(TextAlign.Center)
              .onChange((value: string) => {
                this.newWeight = Number(value)
              })
            Column() {
              Row()
                .height('40%')
                .aspectRatio(1)
                .border({ color: this.optData.color, style: BorderStyle.Solid, width:0 })
                .backgroundColor(this.optData.color)
                .onClick(() => {
                  let rgb: string = '#00beff'
                  rgb = 'rgb(' + Random(50, 220, true) + ',' + Random(50, 220, true) + ',' + Random(50, 220, true) + ')'
                  this.optData.color = rgb
                  this.newColor = rgb
                })
            }
            .height('100%')
            .width('15%')
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

          } else { //修改按钮
            Row() {
              Button() {
                Image($r("app.media.func_edit"))
              }.height('70%').aspectRatio(1).borderRadius(12).backgroundColor('rgba(0,0,0,0)').padding('5%')
              .onClick(() => {
                this.isEdit = !this.isEdit
              }) //修改
            }.height('100%').layoutWeight(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.End)
          }
        }.height('100%').alignItems(VerticalAlign.Center).layoutWeight(7).justifyContent(FlexAlign.SpaceBetween).padding({left:'5%',right:'5%'})

        if (this.isEdit) {
          Row() {
            Button() {
              Image($r("app.media.func_confirm")).fillColor($r("app.color.control_bgc_1"))
            }.height('70%').aspectRatio(1).borderRadius('50%').backgroundColor(0xf1f3f5).padding('5%')
            .onClick(() => { //确认
              let afterData=AppStorage.get('allRolls')as Array<Roll>;
              let newOpt=new RollItem(this.optData.id,this.newText,this.newWeight,this.newColor)
              afterData[Number(this.rollIndex)].rollItems[this.optData.id]=newOpt
              AppStorage.set('allRolls',afterData);
              this.isEdit = !this.isEdit;

            })
          }.height('100%').layoutWeight(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.End)
        }

      }
      .animation({duration:800})
      .justifyContent(FlexAlign.SpaceBetween)
      .aspectRatio(6)
      .width('100%')
      .padding({ left: '3%', right: '3%' })
      .clip(true)
      .border({
        width: 0,
        color: 0xf1f3f5,
        radius: 8,
        style: BorderStyle.Solid
      })      .backgroundColor(0xffffff)
    }
  }
}


export default OptBoxs