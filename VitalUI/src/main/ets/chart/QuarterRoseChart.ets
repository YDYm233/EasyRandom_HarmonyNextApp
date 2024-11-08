export class ChartData { //饼状图子类
  id: string
  text: string
  weight: number
  color: string | number | CanvasGradient | CanvasPattern;

  constructor(id: string, text: string, weight: number, color: string | number | CanvasGradient | CanvasPattern) {
    this.id = id
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}

export class Chart {
  chartName: string
  chartDatas: Array<ChartData> //所有饼状图子类
  constructor(chartName: string, chartDatas: Array<ChartData>) {
    this.chartName = chartName;
    this.chartDatas = chartDatas;
  }
}

export class RoseChartClass extends Chart {
  backgroundColor: string | number | CanvasGradient | CanvasPattern;

  constructor(chartName: string, chartDatas: Array<ChartData>,
    backgroundColor: string | number | CanvasGradient | CanvasPattern) {
    super(chartName, chartDatas);
    this.backgroundColor = backgroundColor
  }
}

@Component
struct QRoseChart {
  @Prop data: Chart
  @Prop rate: number = 0.8; //绘制主体占Canvas组件的比例
  @Prop showAxis: boolean = true; //是否绘制坐标轴
  @Prop showText: boolean = true; //是否绘制文本
  //@Prop showDot:boolean
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Canvas(this.context)
      .onReady(() => {
        const min = 1;
        const max = 3;
        const datas: Array<ChartData> = this.data.chartDatas //获取传入数据
        const num = this.data.chartDatas.length;

        const ctx = this.context; //获取指定Canvas组件
        const center = ctx.width / 2 //获取半径（宽度）
        const radius = center * this.rate;
        const centerX = center - radius;
        const centerY = center+radius;
        let startAngle = 270; //此处角度控制开始渲染的位置
        for (let j = 0; j <= 5; j++) { //绘制坐标
          const l = radius / 5 * j*2
          if (j === 0) {
            ctx.moveTo(centerX, centerY);
          } else {
            ctx.beginPath();
            ctx.arc(centerX, centerY, l, 3/2*Math.PI, 2*Math.PI)
            ctx.moveTo(centerX, centerY);
            ctx.closePath();
          }

          ctx.strokeStyle = 0x80666666;
          ctx.lineWidth = 1.5;
          ctx.stroke();
        }
        for (let i = 0; i <= num; i++) {
          const angle = i/ (num)*0.5*Math.PI+1.5*Math.PI;
          const _x = centerX + Math.cos(angle) * radius*2;
          const _y = centerY + Math.sin(angle) * radius*2;
          ctx.beginPath();
           ctx.moveTo(centerX, centerY);
           ctx.lineTo(_x, _y);
          ctx.lineTo(centerX, centerY);
          ctx.closePath();
          ctx.strokeStyle = 'grey';
          ctx.lineWidth = 1.5;
          ctx.stroke();
        }

        datas.forEach(single => { //以下为循环绘制代码，其核心思想是通过绘制小扇形来拼接为圆形，通过权重/总权重*360便可以计算出合适的扇形角度。
          const endAngle: number = startAngle + 90 / (datas.length ); //计算占比角度方便绘制
          const centerAngle = (startAngle + endAngle) / 2; //计算对称轴角度，以便确定文字绘制位置
          const value = (single.weight > min ? single.weight - min : min) / ((max - min)) * radius*2;
          ctx.beginPath(); //开始
          ctx.moveTo(centerX, centerY); //中心点
          ctx.arc(centerX, centerY, value, startAngle * Math.PI / 180, endAngle * Math.PI / 180, false); //绘制扇形
          ctx.closePath() //闭合路径区域
          ctx.fillStyle = single.color; //选定背景颜色
          ctx.fill(); //绘制背景颜色


          //ctx.save()
          //ctx.translate(centerX, centerY)
          //ctx.rotate((centerAngle + 270) * Math.PI / 180)
          const textX = centerX+Math.cos(centerAngle)*radius*2;
          const textY = centerY+Math.sin(centerAngle)*radius*2;
          ctx.font = '30px sans-serif'
          ctx.textAlign = 'center'
          ctx.textBaseline = 'middle'
          ctx.fillText(single.text, textX, textY,20);
          //ctx.restore() //文字绘制完毕


          startAngle = endAngle; //每次循环完毕前刷新绘制角度
        })
      })
      .width('100%')
      .aspectRatio(1)
  }
}

export { QRoseChart }