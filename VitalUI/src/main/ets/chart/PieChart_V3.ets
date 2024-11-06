
export class PieChartData  { //饼状图子类
  id: string
  text: string
  weight: number
  color: string | number | CanvasGradient | CanvasPattern;
  constructor(id: string, text: string, weight: number, color:string | number | CanvasGradient | CanvasPattern) {
    this.id = id
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}
export class Chart{ //饼状图类
  chartName: string
  chartDatas: Array<PieChartData> //所有饼状图子类
  constructor(rollName: string, rollItems: Array<PieChartData>) {
    this.chartName = rollName;
    this.chartDatas = rollItems;
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
struct PieChart_V3 {
  @Prop data: Chart
  @Prop showDot:boolean=false
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  build() {
    Canvas(this.context)
      .onReady(() => {
        let ctx = this.context;                                        //获取指定Canvas组件
        const center = ctx.width/2
        const radius =  center*1;                           //获取半径（宽度）
        let data: Array<PieChartData> = this.data.chartDatas    //获取传入数据
      //  let totalWeight = data.reduce<number>((acc: number, single: PieChartOption) => acc + single.weight, 0);   //计算出总权重，子选项将根据与总权重的比例计算出角度。
      //  let startAngle = -data[0].weight / totalWeight * 180 + 90;                                                                           //此处角度控制开始渲染的位置，出于个人习惯我将第一个选项调整为正上方(默认角度为正右）

        let totalWeight = data.reduce((acc, sector) => acc + sector.weight, 0);
        let startAngle = 0;

        data.forEach(sector => {
          const endAngle = startAngle + (sector.weight / totalWeight) * 360;
          const centerAngle = (startAngle + endAngle) / 2;

          // 绘制扇形
          ctx.beginPath();
          ctx.moveTo(radius, radius); // 中心点
          ctx.arc(center, center, radius, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);
          ctx.fillStyle = sector.color;
          ctx.fill();

          // 绘制文本
          ctx.font = '20px Arial';
          ctx.fillStyle = 'white';
          ctx.textAlign = 'center';
          const textX = center + 160 * Math.cos(centerAngle * Math.PI / 180);
          const textY = center + 160 * Math.sin(centerAngle * Math.PI / 180);
          ctx.fillText(sector.text, textX, textY);

          // 更新起始角度
          startAngle = endAngle;
        })
      })
      .width('100%')
      .aspectRatio(1)
  }
}
export {PieChart_V3}