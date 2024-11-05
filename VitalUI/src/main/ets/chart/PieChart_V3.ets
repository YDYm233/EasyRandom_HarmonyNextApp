export class PieChartOption { //饼状图子类
  id: string
  text: string
  weight: number
  color: string;
  constructor(id: string, text: string, weight: number, color: string) {
    this.id = id
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}
export class Chart{ //饼状图类
  chartName: string
  chartDatas: Array<PieChartOption> //所有饼状图子类
  constructor(id: string, rollName: string, rollItems: Array<PieChartOption>) {
    this.chartName = rollName;
    this.chartDatas = rollItems;
  }
}
@Component
struct PieChart {
  @Prop data: Chart
  @Prop showDot:boolean
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  build() {
    Canvas(this.context)
      .onReady(() => {
        let ctx = this.context;                                        //获取指定Canvas组件
        const radius =  ctx.width / 2;                           //获取半径（宽度）
        let data: Array<PieChartOption> = this.data.chartDatas    //获取传入数据
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
          ctx.arc(200, 200, 180, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);
          ctx.fillStyle = sector.color;
          ctx.fill();

          // 绘制文本
          ctx.font = '20px Arial';
          ctx.fillStyle = 'white';
          ctx.textAlign = 'center';
          const textX = 200 + 160 * Math.cos(centerAngle * Math.PI / 180);
          const textY = 200 + 160 * Math.sin(centerAngle * Math.PI / 180);
          ctx.fillText(sector.text, textX, textY);

          // 更新起始角度
          startAngle = endAngle;
        })
      })
      .width('100%')
      .aspectRatio(1)
  }
}