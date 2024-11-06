export class ChartData  { //饼状图子类
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
export class Chart{
  chartName: string
  chartDatas: Array<ChartData> //所有饼状图子类
  constructor(chartName: string, chartDatas: Array<ChartData>) {
    this.chartName = chartName;
    this.chartDatas = chartDatas;
  }
}
@Component
struct PieChart_V2 {
  @Prop data: Chart
  //@Prop showDot:boolean
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  build() {
    Canvas(this.context)
      .onReady(() => {
        const ctx = this.context;                                        //获取指定Canvas组件
        const center = ctx.width/2
        const radius =  center*1;                           //获取半径（宽度）
        const min = 1;
        const max = 3;
        let datas: Array<ChartData> = this.data.chartDatas    //获取传入数据
        let totalWeight = datas.reduce<number>((acc: number, single: ChartData) => acc + single.weight, 0);   //计算出总权重，子选项将根据与总权重的比例计算出角度。
        let startAngle = 0;                                                                           //此处角度控制开始渲染的位置，出于个人习惯我将第一个选项调整为正上方(默认角度为正右）

        datas.forEach(single => {  //以下为循环绘制代码，其核心思想是通过绘制小扇形来拼接为圆形，通过权重/总权重*360便可以计算出合适的扇形角度。
          const endAngle: number = startAngle + 360/(datas.length+1) ;    //计算占比角度方便绘制
          const centerAngle = (startAngle + endAngle) / 2;    //计算对称轴角度，以便确定文字绘制位置
          const value=(single.weight>min?single.weight-min:min)/((max-min))*radius;
          ctx.beginPath();                        //开始
          ctx.moveTo(center, center);   //中心点
          ctx.arc(center, center, value, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false);  //绘制扇形
          ctx.closePath()                    //闭合路径区域
          ctx.fillStyle = single.color; //选定背景颜色
          ctx.fill();                                //绘制背景颜色

          startAngle = endAngle;  //每次循环完毕前刷新绘制角度
        })
      })
      .width('100%')
      .aspectRatio(1)
  }
}
export { PieChart_V2}