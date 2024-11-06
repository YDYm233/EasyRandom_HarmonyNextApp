//import{PieChart,PieChartData,Chart} from '../chart/PieChart'
import{PieChart_V2,ChartData,Chart} from '../chart/PieChart_V2'
import{PieChart_V3} from '../chart/PieChart_V3'
import{RoseChartClass,RoseChartDemoData,RoseChart}from '../chart/RadarChart'
@Entry
@Component
struct RandomColors {
  build() {
    Column() {
      Scroll() {
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
            Row() {
              DemoComponent().width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }.height('100%')   .backgroundColor(0xf1f3f5)   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
const demoData: Array<Chart> = [//所有转盘
  new Chart( '吃什么？', [
    new ChartData('0', '梅菜扣肉', 1, 0xffcba50b),
    new ChartData('1', '西湖醋鱼', 3, 0xffa87cf4),
    new ChartData('2', '西红柿炒鸡蛋', 5, 0xffe81b58),
    new ChartData('3', '海带炖肉', 1, 0xff38ed44),
    new ChartData('4', '穿过你的黑发我的手', 2, 0xfff7942c),
    new ChartData('5', '蚂蚁上树', 3, 0xff68ead0),
  ]),
  new Chart('随机颜色', [
    new ChartData('0', '粉色', 2, 0xffff007a),
    new ChartData('1', '蓝色', 3, 0xff0cdec5),
  ]),
  new Chart( '抽奖', [
    new ChartData('0', '三等奖', 4, 0xff05f80b),//#ff05f80b
    new ChartData('3', '特等奖', 1, 0xffecb609),
    new ChartData('4', '感谢参与', 5, 0x499821),
    new ChartData('1', '二等奖', 3, '#ff5f16e1'),
    new ChartData('2', '一等奖', 2, 0x12345678),
  ]),
  new Chart('幸运嘉宾:', [
    new ChartData('0', '小绿', 1, 0xff05f80b),
    new ChartData('1', '小明', 1.2, '#ff5f16e1'),
    new ChartData('2', '小红', 1.1, '#ffe81b58'),
    new ChartData('3', '小橙', 1.5, '#ffecb609'),
    new ChartData('4', '小岑', 2.1, '#499821'),
    new ChartData('5', '小阳', 1.3, '#ffde6e12'),
    new ChartData('6', '夏树', 1.8, '#ffecb609'),
  ]),
]
@Component
struct DemoComponent {
  @State data:Chart = demoData[0]
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
          Row() {
           //RoseChart({data:RoseChartDemoData[0]})      .width('100%').position({top:0,left:0})
            //RoseChart({data:RoseChartDemoData[1]})      .width('100%').position({top:0,left:0})
            RoseChart({data:RoseChartDemoData[1],showText:false,nodeRadius:0})      .width('100%').position({top:0,left:0})
            //PieChart({data:demoData[0]})
            //PieChart_V2({data:demoData[3]})
            //PieChart_V3({data:demoData[0]})     .width('100%').position({top:0,left:0})
          }
          .width('100%')
          .aspectRatio(1)
          .backgroundColor(0xffffff)
          .borderRadius(24)
        }


        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Column(){
            Text('更改测试数据')
             Row(){
               Button('测试数据1').onClick(()=>{this.data=demoData[0]}).layoutWeight(1)
               Button('测试数据1').onClick(()=>{this.data=demoData[1]}).layoutWeight(1)
               Button('测试数据1').onClick(()=>{this.data=demoData[2]}).layoutWeight(1)
               Button('测试数据1').onClick(()=>{this.data=demoData[3]}).layoutWeight(1)
             }
          }
          .width('100%')
          .aspectRatio(3)
          .backgroundColor(0xffffff)
          .borderRadius(24)
        }
      }
    }
  }
}

export default RandomColors