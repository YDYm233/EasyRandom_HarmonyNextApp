import{PieChart,PieChartData,Chart} from '../chart/PieChart'
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
    new PieChartData('0', '梅菜扣肉', 2, 0xffcba50b),
    new PieChartData('1', '西湖醋鱼', 3, 0xffa87cf4),
    new PieChartData('2', '西红柿炒鸡蛋', 2, 0xffe81b58),
    new PieChartData('3', '海带炖肉', 3, 0xff38ed44),
    new PieChartData('4', '穿过你的黑发我的手', 2, 0xfff7942c),
    new PieChartData('5', '蚂蚁上树', 3, 0xff68ead0),
  ]),
  new Chart('随机颜色', [
    new PieChartData('0', '粉色', 2, 0xffff007a),
    new PieChartData('1', '蓝色', 3, 0xff0cdec5),
  ]),
  new Chart( '抽奖', [
    new PieChartData('0', '三等奖', 4, 0xff05f80b),//#ff05f80b
    new PieChartData('3', '特等奖', 1, 0xffecb609),
    new PieChartData('4', '感谢参与', 5, 0x499821),
    new PieChartData('1', '二等奖', 3, '#ff5f16e1'),
    new PieChartData('2', '一等奖', 2, 0x12345678),
  ]),
  new Chart('幸运嘉宾:', [
    new PieChartData('0', '小绿', 1, 0xff05f80b),
    new PieChartData('1', '小明', 1, '#ff5f16e1'),
    new PieChartData('2', '小红', 1, '#ffe81b58'),
    new PieChartData('3', '小橙', 1, '#ffecb609'),
    new PieChartData('4', '小岑', 1, '#499821'),
    new PieChartData('5', '小阳', 1, '#ffde6e12'),
    new PieChartData('6', '夏树', 1, '#ffecb609'),
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
           PieChart({data:this.data})
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
               Button('测试数据1').onClick(()=>{this.data=demoData[1]}).layoutWeight(1)
               Button('测试数据1').onClick(()=>{this.data=demoData[2]}).layoutWeight(1)
               Button('测试数据1').onClick(()=>{this.data=demoData[3]}).layoutWeight(1)
               Button('测试数据1').onClick(()=>{this.data=demoData[4]}).layoutWeight(1)
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