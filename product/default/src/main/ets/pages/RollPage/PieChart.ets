export class PieChartOption { //转盘子选项
  id: string
  text: string
  weight: number
  color: string

  constructor(id: string, text: string, weight: number, color: string) {
    this.id = id
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}
export class ChartData{ //转盘
  id: string
  chartName: string
  chartOptions: Array<PieChartOption> //所有转盘子选项
  constructor(id: string, rollName: string, rollItems: Array<PieChartOption>) {
    this.id = id;
    this.chartName = rollName;
    this.chartOptions = rollItems;
  }
}
@Component
struct PieChart {
  @Prop data: ChartData
  @Prop showDot:boolean
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  build() {
      Canvas(this.context)
        .onReady(() => {
          let ctx = this.context;                                        //获取指定Canvas组件
          const radius =  ctx.width / 2;                           //获取半径（宽度）
          let list: Array<PieChartOption> = this.data.chartOptions    //获取传入数据
          let totalWeight = list.reduce<number>((acc: number, single: PieChartOption) => acc + single.weight, 0);   //计算出总权重，子选项将根据与总权重的比例计算出角度。
          let startAngle = -list[0].weight / totalWeight * 180 + 90;                                                                           //此处角度控制开始渲染的位置，出于个人习惯我将第一个选项调整为正上方(默认角度为正右）

          list.forEach(single => {  //以下为循环绘制代码，其核心思想是通过绘制小扇形来拼接为圆形，通过权重/总权重*360便可以计算出合适的扇形角度。
            const endAngle: number = startAngle + (single.weight / totalWeight) * 360;    //计算占比角度方便绘制
            const centerAngle = (startAngle + endAngle) / 2;    //计算对称轴角度，以便确定绘制位置
            ctx.beginPath();                        //开始
            ctx.moveTo(radius, radius);   //中心点
            ctx.arc(radius, radius, radius, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);  //绘制扇形
            ctx.closePath()                    //闭合路径区域
            ctx.fillStyle = single.color; //选定背景颜色
            ctx.fill();                                //绘制背景颜色
            ctx.fillStyle = '#FFFFFF';    //指定文字颜色
            ctx.textAlign = 'center';     //指定对齐方式

            ctx.save()          //以下语句用于绘制扇形上的文字，该方案不适合较长文本，请根据实际需求使用或更改
            ctx.translate(radius, radius)
            ctx.rotate((centerAngle + 90) * Math.PI / 180)
            const texts: Array<string> = single.text.split('');
            const x = 0;
            const y = radius * 0.1 + (radius * 0.1 / texts.length);
            const lineHeight = (radius - y) / (texts.length + 1)
            const fontSize = lineHeight
            const font = fontSize.toString() + 'vp';
            ctx.font = font;
            for (let n: number = 0; n < texts.length; n++) {
              ctx.fillText(texts[n], x, (-radius + lineHeight + y / 2 + n * lineHeight), fontSize);
            }
            ctx.restore()       //文字绘制完毕

            startAngle = endAngle;  //每次循环完毕前刷新绘制角度
          })
          if(this.showDot) {//是否显示中央小圆点
            ctx.beginPath(); //以下语句用于绘制饼状图中央小圆，可省略
            ctx.moveTo(radius, radius)
            ctx.arc(radius, radius, radius / 10, -45, 275, false);
            ctx.closePath()
            ctx.fillStyle = 0xf1f3f5;
            ctx.fill();
          }
        })
        .width('100%')
        .aspectRatio(1)


  }
}