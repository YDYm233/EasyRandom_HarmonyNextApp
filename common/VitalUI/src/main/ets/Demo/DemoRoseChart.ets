//import{PieChart,PieChartData,Chart} from '../chart/PieChart'
import { ChartData, RoseChart, RoseChartClass } from '../chart/RoseChart'
import { QRoseChart} from '../chart/QuarterRoseChart'

const RoseChartDemoData: RoseChartClass[] = [//所有转盘
  new RoseChartClass('属性', [
    new ChartData('0', '敏捷', 2.2, 0x88cba50b),
    new ChartData('1', '力量', 1.8, 0x88a87cf4),
    new ChartData('1', '智慧', 3.1, 0x88887cf4),
    new ChartData('2', '耐力', 2.2, 0x88191b58),
    new ChartData('2', '天赋', 2.1, 0x88e11328),
    new ChartData('3', '速度', 3.2, 0x8838ed44),
    new ChartData('4', '法力', 2.2, 0x88f7942c),
   // new ChartData('5', '生命', 1, 0xff68ead0),
  ], ''),
  new RoseChartClass('属性', [
    new ChartData('0', '敏捷', 2, 0xffcba50b),
    new ChartData('1', '力量', 3, 0xffa87cf4),
    new ChartData('1', '智慧', 3, 0xffa87cf4),
    new ChartData('2', '耐力', 2, 0xffe81b58),
    new ChartData('2', '天赋', 2, 0xffe81b58),
    new ChartData('3', '速度', 3, 0xff38ed44),
    new ChartData('4', '法力', 2, 0xfff7942c),
    new ChartData('5', '生命', 3, 0xff68ead0),
  ], 'rgba(230,30,130,0.4)'),
]

@Entry
@Component
struct DemoRadarChart {
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
        .margin(24).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }.height('100%').backgroundColor(0xf1f3f5).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct DemoComponent {
  @State index: string = 'default'
  @State nodeRadius: Length = 3 //是否绘制折线处的节点
  @State showAix: boolean = true; //是否绘制坐标轴
  @State showText: boolean = true; //是否绘制文本

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
            if (this.index == 'default') {
              RoseChart({ data: RoseChartDemoData[0], showAxis: true, showText: true })
                .width('100%')
                .position({ top: 0, left: 0 })
            } else if (this.index == 'noNode') {
              QRoseChart({ data: RoseChartDemoData[0], showAxis: true, showText: true })
                .width('100%')
                .position({ top: 0, left: 0 })
            } else if (this.index == 'noAxis') {
              RoseChart({ data: RoseChartDemoData[0], showAxis: false, showText: true })
                .width('100%')
                .position({ top: 0, left: 0 })
            } else if (this.index == 'noText') {
              RoseChart({ data: RoseChartDemoData[0], showAxis: true, showText: false })
                .width('100%')
                .position({ top: 0, left: 0 })
            }

          }

          //PieChart({data:demoData[0]})
          //PieChart_V2({data:demoData[3]})
          //PieChart_V3({data:demoData[0]})     .width('100%').position({top:0,left:0})
        }
        .width('100%')
        .aspectRatio(1)
        .backgroundColor(0xffffff)
        .borderRadius(24)


        GridCol({
          span: {
            sm: 4,
            md: 4,
            lg: 6
          }
        }) {
          Column() {
            Text('更改测试数据').layoutWeight(1)
            Column() {
              Row() {
                Button('示例1：默认').onClick(() => {
                  this.index = 'default'
                }).height('80%')
              }.layoutWeight(1)

              Row() {
                Button('示例2：无节点').onClick(() => {
                  this.index = 'noNode'
                }).height('80%')
              }.layoutWeight(1)

              Row() {
                Button('示例3：无坐标').onClick(() => {
                  this.index = 'noAxis'
                }).height('80%')
              }.layoutWeight(1)

              Row() {
                Button('示例4：无文字').onClick(() => {
                  this.index = 'noText'
                }).height('80%')
              }.layoutWeight(1)
            }.layoutWeight(2)
          }
          .width('100%')
          .aspectRatio(1)
          .backgroundColor(0xffffff)
          .borderRadius(24)
        }
      }
    }
  }
}

export default DemoRadarChart