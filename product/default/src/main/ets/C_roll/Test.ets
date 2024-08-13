import { Random } from '@ohos/common';
//import{Roll,RollItem}from'./RollPage'
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

//@Observed class RollItems extends Array<RollItem>{}
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

//@Observed class Rolls extends Array<Roll>{}


let rolls: Array<Roll> = [                                //所有转盘
  new Roll('0', '随机一个颜色吧啦啦啦啦啦啦', [
    new RollItem('0','粉色', 2, '#ffff007a'),
    new RollItem('1','蓝色', 3, '#ff0cdec5'),
  ]),
  new Roll('1', '吃啥？', [
    new RollItem('0','梅菜扣肉', 2, '#ff05f80b'),
    new RollItem('1','西湖醋鱼', 3, '#ff5f16e1'),
    new RollItem('2','西红柿炒鸡蛋', 2, '#ffe81b58'),
    new RollItem('3','海带炖肉', 3, '#ffecb609'),
    new RollItem('4','穿过你的黑发我的手', 2, '#499821'),
    new RollItem('5','蚂蚁上树', 3, '#ff68ead0'),
  ]),
  new Roll('2', '周几', [
    new RollItem('0','1', 2, '#ff05f80b'),
    new RollItem('1','2', 3, '#ff5f16e1'),
    new RollItem('2','3', 1, '#ffe81b58'),
    new RollItem('3','4', 3, '#ffecb609'),
    new RollItem('4','5', 5, '#499821'),
    new RollItem('5','6', 3, '#ffde6e12'),
    new RollItem('6','7', 3, '#ffecb609'),
  ]),
]
//AppStorage.setOrCreate('allRolls', rolls);

//所有轮盘
@Entry
@Component
struct OptBoxs {
  @StorageLink('allRolls') boxsList: Roll[] = rolls;
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
            width: 1,
            color: 0xff0000,
            radius: 24,
            style: BorderStyle.Solid
          })
        },)
          //(item: Roll) => item.index)
        ListItem() {
          Row(){
            Button(){
            Image($r("app.media.func_plus"))
            }.height('70%').backgroundColor(0xf1f3f5).aspectRatio(1).borderRadius('50%')
          }.width('100%').aspectRatio(5).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
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
          width: 1,
          color: 0xff0000,
          radius: 24,
          style: BorderStyle.Solid
        })
      }
      .alignListItem(ListItemAlign.Center)
      .height('100%')
      .width('100%')
      .border({
        width: 2,
        color: 0x20000000,
        radius: 24,
        style: BorderStyle.Solid
      })
      .padding('2%')

      Row() {
        Button() {
          Text('刷新')
        }
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
        .width('30%').aspectRatio(2)

        Button() {
          Text('应用')
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/Index' })
        })
        .width('30%').aspectRatio(2)
      }.height(50).justifyContent(FlexAlign.SpaceAround).width('100%').alignItems(VerticalAlign.Center).backgroundColor(0xff0000)
.position({bottom:-60,left:0})
    }.width('100%').backgroundColor($r("app.color.view_bgc_1"))
    .height('100%')
    .padding({bottom:60})

  }
}

//单个轮盘
//@Reusable
@Component
struct Opts {
  @StorageLink('allRolls') boxsList: Roll[] = rolls
  @StorageLink('confirmRolls') newRolls: Roll[] = rolls
  @Prop optsList: Roll
  @State rollIndex: string = this.optsList.index
  @State isShow: boolean = false
aboutToAppear(): void {
  this.optsList=this.boxsList[Number(this.optsList.index)]
  }
  build() {

    Column() {
      Row() {
        Text(this.optsList.rollName + this.rollIndex+'ok')
        Button() {
          Image($r("app.media.func_detail")).width('100%').aspectRatio(1)
        }
        .height('60%')
        .backgroundColor(0xf1f3f5)
        .aspectRatio(1)
        .rotate({z:1,angle:this.isShow?0:-90})
        .animation({duration:400,curve:Curve.EaseIn})
        .onClick(() => {
          this.isShow = !this.isShow
        })
      }.aspectRatio(5).width('100%').justifyContent(FlexAlign.SpaceBetween).padding({left:'4%',right:'4%'})

      if (this.isShow) {
        Column() {
          Divider()
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
                Text('删除列表')
              }
              .height('60%')
              .onClick(() => {
                let afterData=this.boxsList.filter(item => item.index != this.optsList.index);
                this.boxsList=afterData
                AppStorage.setAndLink('allrolls',afterData)
              })
              Button() {
                Text('添加选项')
              }
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
            .padding({ left: '3%', right: '3%' })
            .clip(true)
            .border({
              width: 1,
              color: 0x00fff0,
              radius: 8,
              style: BorderStyle.Solid
            })
          }
          Divider()
        }.width('90%').margin({ left: '5%', right: '5%' })
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
                .border({ color: this.optData.color, style: BorderStyle.Solid, width: 1 })
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
        width: 1,
        color: 0x00fff0,
        radius: 8,
        style: BorderStyle.Solid
      })
    }
  }
}


export default OptBoxs